library(tidyverse)
library(plotly)

## reproducibility
set.seed(42)

## ensure we have a 'students' data frame; if none exists, make a tidy example
if (!exists("students") || !is.data.frame(students)) {
  students <- tibble::tibble(
    Name  = c("Alice","Bob","Carlos","Dee","Eden","Fatima","Grace","Hiro"),
    Age   = c(17, 18, 17, 19, 18, 17, 18, 19),
    Score = c(88, 92, 79, 85, 95, 83, 87, 90)
  )
}

## derive a useful flag for later plots/grouping
students <- students %>%
  mutate(
    AboveAverage = Score >= mean(Score, na.rm = TRUE)
  )

## 1) Loops vs Vectorization (and a tiny benchmark)
numbers <- 1:10

squared_loop <- {
  out <- numeric(length(numbers))
  for (i in seq_along(numbers)) out[i] <- numbers[i]^2
  out
}

squared_vector <- numbers^2

cat("squared_loop:   ", paste(squared_loop, collapse = " "), "\n")
cat("squared_vector: ", paste(squared_vector, collapse = " "), "\n")

## quick timing (base R only)
loop_time <- system.time({
  tmp <- numeric(1e4); for (i in seq_len(1e4)) tmp[i] <- i^2
})
vec_time  <- system.time({
  tmp <- (1:1e4)^2
})
cat(sprintf("loop_time  (sec): %.4f | vector_time (sec): %.4f\n\n", loop_time[3], vec_time[3]))

## 2) More Statistics (NA-safe and labeled)
scores <- c(88, 92, 79, 85, 95)
mean_score   <- mean(scores, na.rm = TRUE)
median_score <- median(scores, na.rm = TRUE)
variance     <- var(scores, na.rm = TRUE)
sd_score     <- sd(scores, na.rm = TRUE)
mad_score    <- mad(scores, na.rm = TRUE)

## robust correlation if columns exist
cor_age_score <- NA_real_
if (all(c("Age","Score") %in% names(students))) {
  ## use complete cases only
  cc <- stats::complete.cases(students$Age, students$Score)
  if (any(cc)) cor_age_score <- cor(students$Age[cc], students$Score[cc])
}

cat("Mean:", mean_score, "\n")
cat("Median:", median_score, "\n")
cat("Variance:", variance, "\n")
cat("Standard Deviation:", sd_score, "\n")
cat("Median Absolute Deviation:", mad_score, "\n")
cat("Correlation Age vs Score:", round(cor_age_score, 2), "\n\n")

## 3) Conditional Plotting (Pass/Fail coloring)
students <- students %>%
  mutate(Result = if_else(Score >= 85, "Pass", "Fail"))

p_static <- ggplot(students, aes(x = Age, y = Score, color = Result)) +
  geom_point(size = 3, alpha = 0.9) +
  labs(
    title = "Age vs Score (colored by Pass/Fail)",
    x = "Age",
    y = "Score",
    color = "Result"
  ) +
  theme_minimal() +
  scale_color_manual(values = c("Fail" = "#e76f51", "Pass" = "#2a9d8f"))

print(p_static)

## 4) Cumulative & Grouped Statistics
students <- students %>%
  arrange(Age, desc(Score)) %>%                   # deterministic order
  mutate(CumulativeScore = cumsum(Score))         # simple cumulative total

group_summary <- students %>%
  group_by(AboveAverage) %>%
  summarise(
    mean_score   = mean(Score, na.rm = TRUE),
    median_score = median(Score, na.rm = TRUE),
    sd_score     = sd(Score, na.rm = TRUE),
    count        = n(),
    .groups = "drop"
  )

print(group_summary)

## 5) Interactive Plot with plotly (rich tooltip)
p_interactive <- ggplot(students,
                        aes(x = Age, y = Score,
                            text = paste0(
                              "Name: ", Name,
                              "<br>Age: ", Age,
                              "<br>Score: ", Score,
                              "<br>Above Avg: ", AboveAverage
                            ))) +
  geom_point(aes(color = AboveAverage), size = 4, alpha = 0.9) +
  labs(title = "Interactive Age vs Score",
       x = "Age", y = "Score", color = "Above Avg") +
  theme_minimal()

suppressWarnings(print(ggplotly(p_interactive, tooltip = "text")))

## 6) Combining Multiple Concepts (top-N highlight + messages)
top_students <- students %>%
  slice_max(order_by = Score, n = 2, with_ties = TRUE) %>%
  arrange(desc(Score))

print(top_students)

walk(seq_len(nrow(top_students)), ~{
  cat(sprintf("Congratulations %s for scoring %s!\n",
              top_students$Name[.x],
              top_students$Score[.x]))
})

## bonus: tidy summaries in one line (handy pattern)
tidy_stats <- students %>%
  summarise(across(c(Age, Score),
                   list(mean = ~mean(.x, na.rm = TRUE),
                        sd   = ~sd(.x, na.rm = TRUE),
                        n    = ~sum(!is.na(.x))),
                   .names = "{.col}_{.fn}"))
print(tidy_stats)
