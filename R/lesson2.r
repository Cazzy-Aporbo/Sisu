library(tidyverse)
library(plotly)

# ----------------------------
# 1. Loops vs Vectorization
# ----------------------------
numbers <- 1:10

# Using loop to square numbers
squared_loop <- numeric(length(numbers))
for (i in 1:length(numbers)) {
  squared_loop[i] <- numbers[i]^2
}
print(squared_loop)

# Using vectorized operation (more efficient)
squared_vector <- numbers^2
print(squared_vector)

# ----------------------------
# 2. More Statistics
# ----------------------------
scores <- c(88, 92, 79, 85, 95)

mean_score <- mean(scores)
median_score <- median(scores)
variance_score <- var(scores)
sd_score <- sd(scores)
mad_score <- mad(scores)           # Median Absolute Deviation
cor_age_score <- cor(students$Age, students$Score)  # correlation

print(paste("Mean:", mean_score))
print(paste("Median:", median_score))
print(paste("Variance:", variance_score))
print(paste("Standard Deviation:", sd_score))
print(paste("Median Absolute Deviation:", mad_score))
print(paste("Correlation Age vs Score:", round(cor_age_score, 2)))

# ----------------------------
# 3. Conditional Plotting
# ----------------------------
# Color points by pass/fail
pass_fail <- ifelse(students$Score >= 85, "Pass", "Fail")
ggplot(students, aes(x = Age, y = Score, color = pass_fail)) +
  geom_point(size = 3) +
  labs(title = "Conditional Plot: Age vs Score", x = "Age", y = "Score", color = "Result") +
  theme_minimal()

# ----------------------------
# 4. Cumulative & Grouped Statistics
# ----------------------------
# Add cumulative score column
students <- students %>%
  mutate(CumulativeScore = cumsum(Score))

# Group students by AboveAverage
group_summary <- students %>%
  group_by(AboveAverage) %>%
  summarise(
    mean_score = mean(Score),
    median_score = median(Score),
    sd_score = sd(Score),
    count = n()
  )
print(group_summary)

# ----------------------------
# 5. Interactive Plots with plotly
# ----------------------------
# Scatter plot of Age vs Score
p <- ggplot(students, aes(x = Age, y = Score, text = paste("Name:", Name, "<br>Score:", Score))) +
  geom_point(aes(color = AboveAverage), size = 4) +
  labs(title = "Interactive Age vs Score", x = "Age", y = "Score") +
  theme_minimal()

ggplotly(p)

# ----------------------------
# 6. Combining Multiple Concepts
# ----------------------------
# Highlight students with top 2 scores
top_students <- students %>%
  arrange(desc(Score)) %>%
  slice(1:2)

print(top_students)

# Loop to print congratulatory messages
for (i in 1:nrow(top_students)) {
  cat(paste("Congratulations", top_students$Name[i], "for scoring", top_students$Score[i], "!\n"))
}