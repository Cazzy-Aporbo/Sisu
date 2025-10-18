library(tidyverse)

## seed + demo data (only if 'students' is missing)
set.seed(123)
if (!exists("students") || !is.data.frame(students)) {
  students <- tibble(
    Name  = c("Alice","Bob","Charlie","Diana","Evan"),
    Age   = c(25, 30, 22, 28, 35),
    Score = c(88, 92, 79, 85, 95),
    Club  = c("Math","Science","Art","Math","Science")
  )
}
students <- students %>%
  mutate(AboveAverage = Score >= mean(Score, na.rm = TRUE))

## helpers
percentage <- function(value, total) {
  if (length(total) == 1L && total == 0) {
    warning("percentage(): total is 0; returning NA_real_.")
    return(rep(NA_real_, length(value)))
  }
  (value / total) * 100
}

z_score <- function(x, na.rm = TRUE, sample = TRUE) {
  m <- if (na.rm) mean(x, na.rm = TRUE) else mean(x)
  s <- if (sample) sd(x, na.rm = na.rm) else sqrt(mean((x - m)^2, na.rm = na.rm))
  if (isTRUE(all.equal(s, 0))) return(rep(0, length(x)))
  (x - m) / s
}

theme_clean_small <- function() {
  theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_text(face = "bold"))
}

## 1) Functions with arguments
pct <- percentage(45, 200)
cat("Percentage:", round(pct, 2), "%\n")

## 2) Functions operating on vectors
scores   <- c(88, 92, 79, 85, 95)
z_scores <- z_score(scores)
print(z_scores)

## 3) Vectorized operations
adjusted_scores <- scores * 1.10
print(adjusted_scores)

pass_fail <- if_else(scores >= 85, "Pass", "Fail")
print(pass_fail)

## 4) Working with data frames & functions (column-wise, NA-safe)
students <- students %>%
  mutate(
    ScoreZ      = z_score(Score),
    Percentage  = percentage(Score, 100),
    PassFail    = if_else(Score >= 85, "Pass", "Fail"),
    ScoreCenter = Score - mean(Score, na.rm = TRUE),
    ScoreScale  = (Score - mean(Score, na.rm = TRUE)) / sd(Score, na.rm = TRUE)
  )

print(students)

## 5) Reading and writing CSV files
readr::write_csv(students, "students_data.csv")
students_import <- readr::read_csv("students_data.csv", show_col_types = FALSE)
cat("Imported rows:", nrow(students_import), "\n")
print(students_import %>% glimpse())

## 6) Advanced plots
## scatter with linear fit and labeled color legend
ggplot(students, aes(Age, Score, color = AboveAverage)) +
  geom_point(size = 3, alpha = 0.9) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) +
  scale_color_manual(values = c("FALSE" = "#e76f51", "TRUE" = "#2a9d8f"),
                     labels = c("Below Avg", "Above Avg")) +
  labs(title = "Age vs Score (with Linear Fit)", x = "Age", y = "Score", color = "Category") +
  theme_clean_small()

## boxplot + jitter to see individual points
ggplot(students, aes(x = AboveAverage, y = Score, fill = AboveAverage)) +
  geom_boxplot(width = 0.55, alpha = 0.7, outlier.shape = NA) +
  geom_jitter(width = 0.08, height = 0, size = 2, alpha = 0.85) +
  scale_fill_manual(values = c("#e76f51", "#2a9d8f"), guide = "none") +
  labs(title = "Score Distribution by Above/Below Average", x = NULL, y = "Score") +
  theme_clean_small()

## cumulative line (ordered by Name for deterministic display)
students <- students %>%
  arrange(Name) %>%
  mutate(CumulativeScore = cumsum(Score))

ggplot(students, aes(x = Name, y = CumulativeScore, group = 1)) +
  geom_line(color = "#1f77b4", linewidth = 1) +
  geom_point(color = "#d62728", size = 2.5) +
  labs(title = "Cumulative Scores by Student", x = "Student", y = "Cumulative Score") +
  theme_clean_small()

## extras: group-wise z-scores and a facet histogram
students <- students %>%
  group_by(Club) %>%
  mutate(ScoreZ_byClub = z_score(Score)) %>%
  ungroup()

ggplot(students, aes(Score, fill = Club)) +
  geom_histogram(position = "identity", alpha = 0.55, bins = 8, color = "white") +
  labs(title = "Score Distribution by Club", x = "Score", y = "Count", fill = "Club") +
  theme_clean_small()

## reusable plot factory (advanced bonus)
make_scatter <- function(df, x, y, color = NULL, add_smooth = TRUE) {
  aes_args <- aes(x = {{x}}, y = {{y}})
  if (!rlang::quo_is_null(enquo(color))) {
    aes_args <- aes(x = {{x}}, y = {{y}}, color = {{color}})
  }
  p <- ggplot(df, aes_args) + geom_point(size = 3, alpha = 0.9)
  if (add_smooth) p <- p + geom_smooth(method = "loess", se = FALSE, linewidth = 1)
  p + theme_clean_small()
}

make_scatter(students, Age, Score, color = Club)

## quick tidy summary export (handy for reports)
summary_tbl <- students %>%
  summarise(
    n        = n(),
    mean_age = mean(Age, na.rm = TRUE),
    mean_sc  = mean(Score, na.rm = TRUE),
    sd_sc    = sd(Score, na.rm = TRUE)
  )
readr::write_csv(summary_tbl, "students_summary.csv")
cat("Saved students_data.csv and students_summary.csv\n")
