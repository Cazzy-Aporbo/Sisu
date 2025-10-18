library(tidyverse)

set.seed(1)

## 1) Loops
for (i in seq_len(5)) {
  print(sprintf("Iteration: %d", i))
}

counter <- 1
while (counter <= 5) {
  print(sprintf("Counter is: %d", counter))
  counter <- counter + 1
}

## 2) Conditionals
x <- 12
if (x > 10) {
  print("x is greater than 10")
} else if (x == 10) {
  print("x is exactly 10")
} else {
  print("x is less than 10")
}

## 3) Creating Data Frames
names_vec  <- c("Alice", "Bob", "Charlie", "Diana", "Evan")
ages_vec   <- c(25, 30, 22, 28, 35)
scores_vec <- c(88, 92, 79, 85, 95)

students <- tibble(
  Name  = names_vec,
  Age   = ages_vec,
  Score = scores_vec
)

print(students)

## 4) Accessing Data Frame Elements
print(students$Name)          # column (base)
print(students[2, ])          # row (base)
print(students[3, "Score"])   # single value (base)
print(pull(students, Name))   # column (tidy)
print(slice(students, 2))     # row (tidy)
print(students %>% slice(3) %>% pull(Score))  # single value (tidy)

## 5) Conditional Filtering in Data Frames
high_scores_base <- students[students$Score > 90, ]
print(high_scores_base)

high_scores_tidy <- students %>% filter(Score > 90)
print(high_scores_tidy)

## 6) Simple Statistics
mean_score   <- mean(students$Score, na.rm = TRUE)
median_score <- median(students$Score, na.rm = TRUE)
sd_score     <- sd(students$Score, na.rm = TRUE)

print(sprintf("Mean: %.2f", mean_score))
print(sprintf("Median: %.2f", median_score))
print(sprintf("Standard Deviation: %.2f", sd_score))

## 7) Combining Loops, Conditionals, and Data Frames
students$AboveAverage <- FALSE
for (i in seq_len(nrow(students))) {
  if (students$Score[i] > mean_score) {
    students$AboveAverage[i] <- TRUE
  }
}
print(students)

## vectorized equivalent (clearer and faster)
students <- students %>%
  mutate(AboveAverage_vec = Score > mean_score)

stopifnot(identical(students$AboveAverage, students$AboveAverage_vec))

## 8) Plotting Basics (ggplot2 upgrades)
## Bar plot of scores, ordered by score
students <- students %>%
  mutate(Name = fct_reorder(Name, Score))

ggplot(students, aes(x = Name, y = Score, fill = AboveAverage)) +
  geom_col(width = 0.7, alpha = 0.9) +
  scale_fill_manual(values = c("#e76f51", "#2a9d8f")) +
  labs(title = "Student Scores", x = "Student", y = "Score", fill = "Above Avg") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

## Histogram of ages with density overlay
ggplot(students, aes(x = Age)) +
  geom_histogram(binwidth = 3, fill = "#a6cee3", color = "white") +
  geom_density(aes(y = after_stat(..count..)), linewidth = 1, color = "#1f78b4") +
  labs(title = "Age Distribution", x = "Age", y = "Count") +
  theme_minimal(base_size = 12)
