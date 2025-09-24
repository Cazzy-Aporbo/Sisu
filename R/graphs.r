# ============================
# Advanced R Graphs Part 2
# Colors, Heatmaps, Density, Grouped Plots
# ============================

library(tidyverse)
library(plotly)

# ----------------------------
# 1. Simulated Dataset
# ----------------------------
set.seed(123)
students <- tibble(
  Name = c("Alice","Bob","Charlie","Diana","Evan"),
  Age = c(25,30,22,28,35),
  Score = c(88,92,79,85,95),
  Club = c("Math","Science","Art","Math","Science")
)

# ----------------------------
# 2. Custom Color Scales
# ----------------------------
ggplot(students, aes(x = Age, y = Score, color = Club, size = Score)) +
  geom_point() +
  scale_color_manual(values = c("Math" = "blue", "Science" = "green", "Art" = "orange")) +
  labs(title = "Custom Color Scatter Plot", x = "Age", y = "Score") +
  theme_minimal()

# ----------------------------
# 3. Grouped Line Plot
# ----------------------------
# Simulate yearly performance per club
performance <- tibble(
  Year = rep(2019:2023, 3),
  Club = rep(c("Math","Science","Art"), each = 5),
  AverageScore = c(80,82,85,87,90,78,80,83,85,88,75,77,79,80,82)
)

ggplot(performance, aes(x = Year, y = AverageScore, color = Club, group = Club)) +
  geom_line(size = 1.5) +
  geom_point(size = 3) +
  labs(title = "Average Score by Club Over Years", x = "Year", y = "Average Score") +
  theme_minimal()

# ----------------------------
# 4. Heatmap
# ----------------------------
# Simulate correlation matrix
scoreMatrix <- matrix(runif(25, 60, 100), nrow = 5)
rownames(scoreMatrix) <- students$Name
colnames(scoreMatrix) <- paste0("Test", 1:5)
scoreDF <- as_tibble(scoreMatrix, rownames = "Name") %>%
  pivot_longer(cols = starts_with("Test"), names_to = "Test", values_to = "Score")

ggplot(scoreDF, aes(x = Test, y = Name, fill = Score)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "yellow", high = "red") +
  labs(title = "Heatmap of Student Scores") +
  theme_minimal()

# ----------------------------
# 5. Density Plot
# ----------------------------
ggplot(students, aes(x = Score, fill = Club)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Math" = "blue", "Science" = "green", "Art" = "orange")) +
  labs(title = "Score Density by Club", x = "Score", y = "Density") +
  theme_light()

# ----------------------------
# 6. Interactive Heatmap with Plotly
# ----------------------------
interactiveHeatmap <- plot_ly(
  scoreDF, x = ~Test, y = ~Name, z = ~Score, type = "heatmap",
  colors = colorRamp(c("yellow","red"))
)
interactiveHeatmap

# ----------------------------
# 7. Faceted Density Plot
# ----------------------------
ggplot(students, aes(x = Score, fill = Club)) +
  geom_density(alpha = 0.7) +
  facet_wrap(~Club) +
  labs(title = "Faceted Density Plot by Club") +
  theme_minimal()

# ----------------------------
# 8. Combined Plot: Line + Points + Colors
# ----------------------------
ggplot(performance, aes(x = Year, y = AverageScore, group = Club, color = Club)) +
  geom_line(size = 1.2) +
  geom_point(size = 4) +
  scale_color_manual(values = c("Math" = "darkblue", "Science" = "darkgreen", "Art" = "darkorange")) +
  labs(title = "Club Performance Over Years", x = "Year", y = "Average Score") +
  theme_minimal()