# ----------------------------
# 1. Storing Variables
# ----------------------------
x <- 10          # store a single number
y <- 5           # store another number
name <- "Alice"  # store text (string)
flag <- TRUE     # store boolean value

# ----------------------------
# 2. Basic Math Operations
# ----------------------------
sum_xy <- x + y      # addition
diff_xy <- x - y     # subtraction
prod_xy <- x * y     # multiplication
div_xy <- x / y      # division
exp_x <- x^2         # exponentiation
mod_xy <- x %% y     # modulus (remainder)

# Print results
print(sum_xy)
print(diff_xy)
print(prod_xy)
print(div_xy)
print(exp_x)
print(mod_xy)

# ----------------------------
# 3. Using Functions
# ----------------------------
mean_value <- mean(c(x, y))   # mean of numbers
max_value <- max(x, y)        # maximum
min_value <- min(x, y)        # minimum
sqrt_x <- sqrt(x)             # square root
round_div <- round(div_xy, 2) # round to 2 decimals

print(mean_value)
print(max_value)
print(min_value)
print(sqrt_x)
print(round_div)

# ----------------------------
# 4. Working with Vectors
# ----------------------------
numbers <- c(2, 4, 6, 8, 10)   # create a vector
numbers_sum <- sum(numbers)     # sum of all elements
numbers_mean <- mean(numbers)   # mean of vector
numbers_squared <- numbers^2    # square each element
numbers_filtered <- numbers[numbers > 5] # filter values >5

print(numbers_sum)
print(numbers_mean)
print(numbers_squared)
print(numbers_filtered)

# ----------------------------
# 5. Simple Functions
# ----------------------------
add_two_numbers <- function(a, b) {
  result <- a + b
  return(result)
}

multiply_two_numbers <- function(a, b) {
  result <- a * b
  return(result)
}

# Using functions
res1 <- add_two_numbers(7, 3)
res2 <- multiply_two_numbers(7, 3)

print(res1)
print(res2)

# ----------------------------
# 6. Combining Variables & Math
# ----------------------------
final_score <- (x + y) * numbers_mean / length(numbers)
print(final_score)