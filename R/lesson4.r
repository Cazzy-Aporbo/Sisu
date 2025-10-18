library(tidyverse)
library(zoo)
library(forecast)
library(plotly)

set.seed(42)

num_portfolios <- 3
num_years <- 10

assets <- tibble(
  name        = c("StockA", "StockB", "BondA", "CryptoA"),
  mean_return = c(0.08,     0.12,     0.03,   0.25),
  sd_return   = c(0.15,     0.20,     0.05,   0.40)
)

dirichlet_like <- function(n) {
  w <- runif(n); w / sum(w)
}

simulate_portfolio <- function(weights, assets, years) {
  stopifnot(length(weights) == nrow(assets))
  draws <- map2_dfc(assets$mean_return, assets$sd_return,
                    ~ rnorm(years, mean = .x, sd = .y))
  as.numeric(as.matrix(draws) %*% weights)
}

portfolios <- tibble(portfolio_id = seq_len(num_portfolios)) %>%
  mutate(weights = map(portfolio_id, ~ dirichlet_like(nrow(assets)) %>% set_names(assets$name))) %>%
  mutate(yearly_returns = map(weights, ~ simulate_portfolio(.x, assets, num_years)))

portfolios <- portfolios %>%
  mutate(
    mean_return       = map_dbl(yearly_returns, ~ mean(.x)),
    sd_return         = map_dbl(yearly_returns, ~ sd(.x)),
    cumulative_return = map_dbl(yearly_returns, ~ prod(1 + .x) - 1),
    geo_mean_annual   = map_dbl(yearly_returns, ~ (prod(1 + .x))^(1/length(.x)) - 1)
  )

print(portfolios %>% select(portfolio_id, mean_return, sd_return, cumulative_return, geo_mean_annual))

portfolio_returns_df <- portfolios %>%
  select(portfolio_id, yearly_returns) %>%
  unnest(yearly_returns) %>%
  group_by(portfolio_id) %>%
  mutate(
    year            = row_number(),
    rolling_avg_3   = zoo::rollmean(yearly_returns, k = 3, fill = NA, align = "right"),
    intra_rank_year = rank(-yearly_returns, ties.method = "first")
  ) %>%
  ungroup() %>%
  group_by(year) %>%
  mutate(cross_rank = rank(-yearly_returns, ties.method = "first")) %>%
  ungroup()

print(portfolio_returns_df)

risk_summary <- portfolios %>%
  transmute(portfolio_id, mu = mean_return, sigma = sd_return) %>%
  mutate(
    prob_loss = pnorm(0, mean = mu, sd = sigma),
    VaR_95    = qnorm(0.05, mean = mu, sd = sigma),
    ES_95     = mu - sigma * dnorm(qnorm(0.05)) / 0.05
  )

print(risk_summary)

ts_forecasts <- portfolios %>%
  mutate(ts_obj = map(yearly_returns, ~ ts(.x, frequency = 1))) %>%
  mutate(model = map(ts_obj, auto.arima)) %>%
  mutate(fc = map(model, forecast, h = 5))

forecast_df <- ts_forecasts %>%
  transmute(portfolio_id, fc_tbl = map(fc, ~ as_tibble(.x))) %>%
  unnest(fc_tbl)

print(forecast_df %>% group_by(portfolio_id) %>% summarise(h = max(Index), .groups = "drop"))

ggplot(portfolio_returns_df, aes(x = year, y = yearly_returns, color = factor(portfolio_id))) +
  geom_line(linewidth = 1) +
  geom_line(aes(y = rolling_avg_3), linetype = "dashed", linewidth = 1) +
  labs(title = "Portfolio Returns with 3-Year Rolling Average",
       x = "Year", y = "Return", color = "Portfolio") +
  theme_minimal()

interactive_plot <- plot_ly(
  portfolio_returns_df,
  x = ~year, y = ~yearly_returns, color = ~factor(portfolio_id),
  type = "scatter", mode = "lines+markers",
  text = ~paste("Portfolio:", portfolio_id,
                "<br>Year:", year,
                "<br>Return:", round(yearly_returns, 3),
                "<br>Rolling(3):", round(rolling_avg_3, 3))
)
interactive_plot

write_csv(portfolio_returns_df, "portfolio_returns.csv")
write_csv(risk_summary, "portfolio_risk_summary.csv")

top_portfolios <- portfolio_returns_df %>%
  group_by(year) %>%
  slice_max(order_by = yearly_returns, n = 1, with_ties = FALSE) %>%
  ungroup()

print(top_portfolios)

walk(seq_len(nrow(top_portfolios)), ~ {
  cat(sprintf("Year %d — Top Portfolio: %d with Return: %.3f\n",
              top_portfolios$year[.x],
              top_portfolios$portfolio_id[.x],
              top_portfolios$yearly_returns[.x]))
})
