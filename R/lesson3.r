library(tidyverse)

students <- tibble(
  Name = c("Alice", "Bob", "Charlie", "Diana", "Evan"),
  Age = c(25, 30, NA, 28, 35),
  Score = c(88, 92, 79, NA, 95)
)

print(students)
print(colSums(is.na(students)))

students <- students %>%
  mutate(
    Age   = if_else(is.na(Age),   round(mean(Age, na.rm = TRUE)), Age),
    Score = if_else(is.na(Score), round(mean(Score, na.rm = TRUE)), Score)
  )

print("After filling missing values:")
print(students)

normalize01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if ((rng[2] - rng[1]) == 0) return(rep(0, length(x)))
  (x - rng[1]) / (rng[2] - rng[1])
}

students <- students %>%
  mutate(
    Result = if_else(Score >= 85, "Pass", "Fail"),
    ScoreNormalized = normalize01(Score)
  )

print(students)

extra_info <- tibble(
  Name = c("Alice", "Bob", "Charlie", "Diana", "Evan"),
  Club = c("Math", "Science", "Art", "Math", "Science")
)

students_full <- students %>%
  left_join(extra_info, by = "Name")

print(students_full)

club_summary <- students_full %>%
  group_by(Club) %>%
  summarise(
    mean_score = mean(Score, na.rm = TRUE),
    max_score = max(Score, na.rm = TRUE),
    min_score = min(Score, na.rm = TRUE),
    count = n(),
    .groups = "drop"
  )

print(club_summary)

math_pass <- students_full %>%
  filter(Result == "Pass", Club == "Math")

print(math_pass)

ggplot(students_full, aes(x = Name, y = ScoreNormalized, fill = Result)) +
  geom_col() +
  labs(
    title = "Normalized Student Scores",
    x = "Student",
    y = "Normalized Score"
  ) +
  theme_minimal()

write_csv(students_full, "students_cleaned.csv")
