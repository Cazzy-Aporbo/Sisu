# ----------------------------
# 1. Loops
# ----------------------------
# For loop
for (i in 1:5) {
  print(paste("Iteration:", i))
}

# While loop
counter <- 1
while (counter <= 5) {
  print(paste("Counter is:", counter))
  counter <- counter + 1
}

# ----------------------------
# 2. Conditionals
# ----------------------------
x <- 12
if (x > 10) {
  print("x is greater than 10")
} else if (x == 10) {
  print("x is exactly 10")
} else {
  print("x is less than 10")
}

# ----------------------------
# 3. Creating Data Frames
# ----------------------------
names <- c("Alice", "Bob", "Charlie", "Diana", "Evan")
ages <- c(25, 30, 22, 28, 35)
scores <- c(88, 92, 79, 85, 95)

students <- data.frame(
  Name = names,
  Age = ages,
  Score = scores
)

print(students)

# ----------------------------
# 4. Accessing Data Frame Elements
# ----------------------------
print(students$Name)      # access column
print(students[2,])       # access row
print(students[3, "Score"]) # access single value

# ----------------------------
# 5. Conditional Filtering in Data Frames
# ----------------------------
high_scores <- students[students$Score > 90, ]
print(high_scores)

# ----------------------------
# 6. Simple Statistics
# ----------------------------
mean_score <- mean(students$Score)
median_score <- median(students$Score)
sd_score <- sd(students$Score)

print(paste("Mean:", mean_score))
print(paste("Median:", median_score))
print(paste("Standard Deviation:", sd_score))

# ----------------------------
# 7. Combining Loops, Conditionals, and Data Frames
# ----------------------------
# Flag students above average
students$AboveAverage <- FALSE

for (i in 1:nrow(students)) {
  if (students$Score[i] > mean_score) {
    students$AboveAverage[i] <- TRUE
  }
}

print(students)

# ----------------------------
# 8. Plotting Basics
# ----------------------------
# Bar plot of scores
barplot(students$Score, names.arg = students$Name, col = "skyblue",
        main = "Student Scores", ylab = "Score")

# Histogram of ages
hist(students$Age, col = "lightgreen", main = "Age Distribution", xlab = "Age")