# ============================
# Advanced R Tutor Project
# Simulated Portfolio & Risk Analysis
# ============================

# Load libraries
library(tidyverse)
library(zoo)
library(forecast)
library(plotly)

# ----------------------------
# 1. Simulate Portfolio Data
# ----------------------------
set.seed(42)
numPortfolios <- 3
numYears <- 10
assets <- tibble(
  name = c("StockA", "StockB", "BondA", "CryptoA"),
  meanReturn = c(0.08, 0.12, 0.03, 0.25),
  sdReturn = c(0.15, 0.2, 0.05, 0.4)
)

# Function to generate yearly returns
simulatePortfolio <- function(weights, assets, years) {
  returns <- numeric(years)
  for (y in 1:years) {
    returns[y] <- sum(weights * rnorm(nrow(assets), assets$meanReturn, assets$sdReturn))
  }
  returns
}

# Random weights for portfolios
portfolios <- tibble(portfolioId = 1:numPortfolios) %>%
  mutate(weights = map(1:numPortfolios, ~{
    w <- runif(nrow(assets))
    w / sum(w)
  })) %>%
  mutate(yearlyReturns = map(weights, ~simulatePortfolio(.x, assets, numYears)))

# ----------------------------
# 2. Aggregate Portfolio Statistics
# ----------------------------
portfolios <- portfolios %>%
  mutate(
    meanReturn = map_dbl(yearlyReturns, mean),
    sdReturn = map_dbl(yearlyReturns, sd),
    cumulativeReturn = map_dbl(yearlyReturns, ~prod(1 + .x) - 1)
  )

print(portfolios)

# ----------------------------
# 3. Rolling Averages and Rankings
# ----------------------------
portfolioReturnsDF <- portfolios %>%
  select(portfolioId, yearlyReturns) %>%
  unnest(cols = c(yearlyReturns)) %>%
  group_by(portfolioId) %>%
  mutate(
    year = row_number(),
    rollingAverage = zoo::rollmean(yearlyReturns, k = 3, fill = NA, align = "right"),
    rankReturn = rank(-yearlyReturns)
  ) %>%
  ungroup()

print(portfolioReturnsDF)

# ----------------------------
# 4. Monte Carlo Simulation for Risk
# ----------------------------
numSimulations <- 10000
simulatedReturns <- rnorm(numSimulations, mean = mean(portfolioReturnsDF$yearlyReturns), sd = sd(portfolioReturnsDF$yearlyReturns))
probabilityLoss <- mean(simulatedReturns < 0)
cat("Probability of portfolio loss:", round(probabilityLoss, 3), "\n")

# ----------------------------
# 5. Time-Series Forecast
# ----------------------------
tsReturns <- ts(portfolioReturnsDF$yearlyReturns, frequency = 1)
forecastFit <- auto.arima(tsReturns)
forecastedReturns <- forecast(forecastFit, h = 5)
plot(forecastedReturns, main = "Forecasted Portfolio Returns")

# ----------------------------
# 6. Advanced Visualization
# ----------------------------
# Line plot with rolling average
ggplot(portfolioReturnsDF, aes(x = year, y = yearlyReturns, color = factor(portfolioId))) +
  geom_line(size = 1) +
  geom_line(aes(y = rollingAverage), linetype = "dashed", size = 1) +
  labs(title = "Portfolio Returns with Rolling Average", x = "Year", y = "Return", color = "Portfolio ID") +
  theme_minimal()

# Interactive plot with plotly
interactivePlot <- plot_ly(
  portfolioReturnsDF, x = ~year, y = ~yearlyReturns, color = ~factor(portfolioId),
  type = 'scatter', mode = 'lines+markers', text = ~paste("Portfolio:", portfolioId)
)
interactivePlot

# ----------------------------
# 7. Export Results
# ----------------------------
write_csv(portfolioReturnsDF, "portfolio_returns.csv")

# ----------------------------
# 8. Combine Concepts: Identify Top Portfolio per Year
# ----------------------------
topPortfolios <- portfolioReturnsDF %>%
  group_by(year) %>%
  slice_max(order_by = yearlyReturns, n = 1) %>%
  ungroup()

print(topPortfolios)

# Loop to print top portfolio messages
for (i in 1:nrow(topPortfolios)) {
  cat(paste("Year", topPortfolios$year[i], "- Top Portfolio:", topPortfolios$portfolioId[i],
            "with Return:", round(topPortfolios$yearlyReturns[i], 3), "\n"))
}