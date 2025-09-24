# ----------------------------
# 1. Functions with Arguments
# ----------------------------
# Function to calculate percentage of a number
percentage <- function(value, total) {
  return((value / total) * 100)
}

pct <- percentage(45, 200)
print(paste("Percentage:", round(pct, 2), "%"))

# ----------------------------
# 2. Functions Operating on Vectors
# ----------------------------
# Function to calculate z-scores
z_score <- function(x) {
  (x - mean(x)) / sd(x)
}

scores <- c(88, 92, 79, 85, 95)
z_scores <- z_score(scores)
print(z_scores)

# ----------------------------
# 3. Vectorized Operations
# ----------------------------
# Multiply all scores by 1.1 (increase by 10%)
adjusted_scores <- scores * 1.1
print(adjusted_scores)

# Conditional vectorized operation
pass_fail <- ifelse(scores >= 85, "Pass", "Fail")
print(pass_fail)

# ----------------------------
# 4. Working with Data Frames & Functions
# ----------------------------
students$ScoreZ <- z_score(students$Score)
students$Percentage <- percentage(students$Score, 100)

print(students)

# ----------------------------
# 5. Reading and Writing CSV Files
# ----------------------------
write_csv(students, "students_data.csv")   # save CSV
students_import <- read_csv("students_data.csv")  # read CSV
print(students_import)

# ----------------------------
# 6. Advanced Plots
# ----------------------------
library(ggplot2)

# Scatter plot of Age vs Score
ggplot(students, aes(x = Age, y = Score, color = AboveAverage)) +
  geom_point(size = 3) +
  labs(title = "Age vs Score", x = "Age", y = "Score") +
  theme_minimal()

# Boxplot of Scores
ggplot(students, aes(y = Score, x = "", fill = AboveAverage)) +
  geom_boxplot() +
  labs(title = "Score Distribution") +
  theme_minimal()

# Line plot of cumulative scores
students$CumulativeScore <- cumsum(students$Score)
ggplot(students, aes(x = Name, y = CumulativeScore, group = 1)) +
  geom_line(color = "blue", size = 1) +
  geom_point(color = "red", size = 2) +
  labs(title = "Cumulative Scores by Student", x = "Student", y = "Cumulative Score") +
  theme_minimal()