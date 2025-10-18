library(tidyverse)
library(plotly)

set.seed(123)

students <- tibble(
  Name  = c("Alice","Bob","Charlie","Diana","Evan"),
  Age   = c(25,30,22,28,35),
  Score = c(88,92,79,85,95),
  Club  = factor(c("Math","Science","Art","Math","Science"),
                 levels = c("Math","Science","Art"))
)

club_cols <- c("Math" = "#3366CC", "Science" = "#2CA02C", "Art" = "#FF7F0E")

ggplot(students, aes(Age, Score, color = Club, size = Score)) +
  geom_point(alpha = 0.9) +
  scale_color_manual(values = club_cols) +
  scale_size(range = c(3, 7), guide = "none") +
  labs(title = "Custom Color Scatter Plot", x = "Age", y = "Score", color = "Club") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

performance <- tibble(
  Year         = rep(2019:2023, 3),
  Club         = rep(c("Math","Science","Art"), each = 5),
  AverageScore = c(80,82,85,87,90, 78,80,83,85,88, 75,77,79,80,82)
) %>%
  mutate(Club = factor(Club, levels = c("Math","Science","Art")))

ggplot(performance, aes(Year, AverageScore, color = Club, group = Club)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = club_cols) +
  labs(title = "Average Score by Club Over Years", x = "Year", y = "Average Score", color = "Club") +
  theme_minimal(base_size = 12)

score_mat <- matrix(runif(25, 60, 100), nrow = 5)
rownames(score_mat) <- students$Name
colnames(score_mat) <- paste0("Test", 1:5)

row_ord <- hclust(dist(scale(score_mat)))$order
col_ord <- hclust(dist(scale(t(score_mat))))$order
scoreDF <- as_tibble(score_mat[row_ord, col_ord], rownames = "Name") |>
  pivot_longer(-Name, names_to = "Test", values_to = "Score")

ggplot(scoreDF, aes(Test, Name, fill = Score)) +
  geom_tile(color = "white", linewidth = 0.25) +
  scale_fill_gradient(low = "#FDE725", high = "#440154") +
  labs(title = "Heatmap of Student Scores", x = "Test", y = "Student", fill = "Score") +
  theme_minimal(base_size = 12) +
  theme(panel.grid = element_blank())

ggplot(students, aes(Score, fill = Club)) +
  geom_density(alpha = 0.6, adjust = 1.1, color = NA) +
  scale_fill_manual(values = club_cols) +
  labs(title = "Score Density by Club", x = "Score", y = "Density", fill = "Club") +
  theme_light(base_size = 12)

interactiveHeatmap <- plot_ly(
  scoreDF,
  x = ~Test, y = ~Name, z = ~Score,
  type = "heatmap",
  colors = colorRamp(c("#FDE725", "#440154"))
)
interactiveHeatmap

ggplot(students, aes(Score, fill = Club)) +
  geom_density(alpha = 0.7, color = NA) +
  facet_wrap(~ Club, scales = "free_y") +
  scale_fill_manual(values = club_cols, guide = "none") +
  labs(title = "Faceted Density Plot by Club", x = "Score", y = "Density") +
  theme_minimal(base_size = 12)

last_year <- max(performance$Year)
lab_data <- performance |> filter(Year == last_year)

ggplot(performance, aes(Year, AverageScore, group = Club, color = Club)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 3) +
  geom_text(
    data = lab_data,
    aes(label = Club),
    hjust = -0.1, vjust = 0.5, size = 3.5, show.legend = FALSE
  ) +
  scale_color_manual(values = club_cols) +
  scale_x_continuous(limits = c(min(performance$Year), last_year + 0.6), breaks = unique(performance$Year)) +
  labs(title = "Club Performance Over Years", x = "Year", y = "Average Score", color = "Club") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")
