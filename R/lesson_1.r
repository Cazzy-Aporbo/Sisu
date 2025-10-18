## Basics: variables
x <- 10L                  # single integer
y <- 5L                   # another integer
name <- "Alice"           # text (character)
flag <- TRUE              # boolean (logical)

## Basic math
sum_xy  <- x + y
diff_xy <- x - y
prod_xy <- x * y
div_xy  <- x / y
exp_x   <- x^2
mod_xy  <- x %% y         # remainder
int_div <- x %/% y        # integer division

cat("sum_xy:", sum_xy, "\n")
cat("diff_xy:", diff_xy, "\n")
cat("prod_xy:", prod_xy, "\n")
cat("div_xy:", div_xy, "\n")
cat("exp_x:", exp_x, "\n")
cat("mod_xy:", mod_xy, "\n")
cat("int_div:", int_div, "\n\n")

## Using functions (with NA-safe examples)
nums_pair <- c(x, y, NA_integer_)
mean_value_raw <- mean(nums_pair)               # NA propagates
mean_value_ok  <- mean(nums_pair, na.rm = TRUE) # ignore NAs
max_value <- max(x, y)
min_value <- min(x, y)
sqrt_x    <- sqrt(x)
round_div <- round(div_xy, 2)

cat("mean_value_raw (with NA):", mean_value_raw, "\n")
cat("mean_value_ok  (na.rm=TRUE):", mean_value_ok, "\n")
cat("max_value:", max_value, "\n")
cat("min_value:", min_value, "\n")
cat("sqrt_x:", sqrt_x, "\n")
cat("round_div (2 d.p.):", round_div, "\n\n")

## Working with vectors
numbers <- c(2, 4, 6, 8, 10)
numbers_sum      <- sum(numbers)
numbers_mean     <- mean(numbers)
numbers_squared  <- numbers^2         # vectorized
numbers_filtered <- numbers[numbers > 5]
numbers_centered <- scale(numbers, center = TRUE, scale = FALSE)[,1]  # center only (base R friendly)

cat("numbers_sum:", numbers_sum, "\n")
cat("numbers_mean:", numbers_mean, "\n")
cat("numbers_squared:", paste(numbers_squared, collapse = ", "), "\n")
cat("numbers_filtered (>5):", paste(numbers_filtered, collapse = ", "), "\n")
cat("numbers_centered (mean ~ 0):", paste(round(numbers_centered, 2), collapse = ", "), "\n\n")

## Simple functions (with basic checks)
add_two_numbers <- function(a, b) {
  stopifnot(is.numeric(a), length(a) == 1L, !is.na(a))
  stopifnot(is.numeric(b), length(b) == 1L, !is.na(b))
  a + b
}

multiply_two_numbers <- function(a, b) {
  stopifnot(is.numeric(a), length(a) == 1L, !is.na(a))
  stopifnot(is.numeric(b), length(b) == 1L, !is.na(b))
  a * b
}

res1 <- add_two_numbers(7, 3)
res2 <- multiply_two_numbers(7, 3)

cat("add_two_numbers(7, 3):", res1, "\n")
cat("multiply_two_numbers(7, 3):", res2, "\n\n")

## Combining variables & math
final_score <- (x + y) * numbers_mean / length(numbers)
cat("final_score:", final_score, "\n\n")

## Bonus: quick summaries that are handy in practice
cat("summary(numbers):\n")
print(summary(numbers))

cat("\nQuantiles of numbers:\n")
print(quantile(numbers))

## Bonus: tiny conditional demo (vectorized)
is_big <- ifelse(numbers > numbers_mean, "above_mean", "below_or_equal")
cat("\nlabels vs mean:", paste(is_big, collapse = ", "), "\n")
