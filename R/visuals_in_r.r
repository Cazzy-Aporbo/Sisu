# Advanced R Visualization Step by Step

library(tidyverse)
library(plotly)

# 1. Create your dataset

set.seed(100)
students <- tibble(
  name = c("Alice","Bob","Charlie","Diana","Evan"),
  age = c(25,30,22,28,35),
  score = c(88,92,79,85,95),
  club = c("Math","Science","Art","Math","Science")
)

print(students)

# 2. Scatter plot

scatterPlot <- ggplot(students, aes(x = age, y = score)) +
  geom_point(size = 3, color = "blue") +
  labs(title = "Scatter Plot of Age vs Score", x = "Age", y = "Score") +
  theme_minimal()

print(scatterPlot)

# 3. Scatter plot with colors

students <- students %>%
  mutate(result = ifelse(score >= 85, "Pass","Fail"))

scatterColor <- ggplot(students, aes(x = age, y = score, color = result)) +
  geom_point(size = 4) +
  labs(title = "Scatter Plot with Result Colors", x = "Age", y = "Score") +
  theme_light()

print(scatterColor)

# 4. Bar plot

barPlot <- ggplot(students, aes(x = name, y = score, fill = club)) +
  geom_bar(stat = "identity") +
  labs(title = "Scores by Student and Club", x = "Student", y = "Score") +
  theme_minimal()

print(barPlot)

# 5. Box plot

boxPlot <- ggplot(students, aes(x = club, y = score, fill = club)) +
  geom_boxplot() +
  labs(title = "Box Plot of Scores by Club", x = "Club", y = "Score") +
  theme_classic()

print(boxPlot)

# 6. Line plot

students <- students %>%
  arrange(age) %>%
  mutate(cumulativeScore = cumsum(score))

linePlot <- ggplot(students, aes(x = name, y = cumulativeScore, group = 1)) +
  geom_line(color = "darkgreen", size = 1) +
  geom_point(color = "red", size = 3) +
  labs(title = "Cumulative Score by Student", x = "Student", y = "Cumulative Score") +
  theme_minimal()

print(linePlot)

# 7. Faceted scatter plot

facetPlot <- ggplot(students, aes(x = age, y = score, color = result)) +
  geom_point(size = 3) +
  facet_wrap(~club) +
  labs(title = "Faceted Scatter Plot by Club") +
  theme_light()

print(facetPlot)

# 8. Interactive plot with plotly

interactivePlot <- plot_ly(
  students, 
  x = ~age, 
  y = ~score, 
  color = ~club,
  text = ~paste("Name:", name, "<br>Score:", score, "<br>Club:", club),
  type = 'scatter', 
  mode = 'markers'
)

interactivePlot

# 9. Density plot

densityPlot <- ggplot(students, aes(x = score, fill = club)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Math" = "blue", "Science" = "green", "Art" = "orange")) +
  labs(title = "Density Plot of Scores by Club", x = "Score", y = "Density") +
  theme_light()

print(densityPlot)

# 10. Heatmap

scoreMatrix <- tibble(
  name = students$name,
  test1 = c(88,92,79,85,95),
  test2 = c(90,89,80,86,93),
  test3 = c(85,91,78,84,97)
)

scoreLong <- scoreMatrix %>%
  pivot_longer(cols = starts_with("test"), names_to = "test", values_to = "score")

heatmapPlot <- ggplot(scoreLong, aes(x = test, y = name, fill = score)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "yellow", high = "red") +
  labs(title = "Heatmap of Student Scores") +
  theme_minimal()

print(heatmapPlot)

# 11. Interactive heatmap with plotly

interactiveHeatmap <- plot_ly(
  scoreLong, x = ~test, y = ~name, z = ~score, type = "heatmap",
  colors = colorRamp(c("yellow","red"))
)

interactiveHeatmap