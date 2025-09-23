-- ======================================
-- Welcome to your Lua learning playground
-- ======================================

-- 1️⃣ Printing
print("Hello, Lua world!")

-- 2️⃣ Variables and Math
name = "Cazzy"
age = 25
x = 10
y = 5
sum = x + y
print("My name is " .. name .. " and I am " .. age .. " years old")
print("Sum of x + y is " .. sum)

-- 3️⃣ Function Example
function greet(person)
    print("Hello, " .. person .. "!")
end

greet("Cazzy")
greet("Friend")

-- 4️⃣ Loops
print("---- For Loop ----")
for i = 1, 5 do
    print("Counting: " .. i)
end

print("---- While Loop ----")
count = 1
while count <= 5 do
    print("While count: " .. count)
    count = count + 1
end

-- 5️⃣ Tables (arrays and dictionaries)
print("---- Tables ----")
fruits = {"apple", "banana", "cherry"}
print("First fruit: " .. fruits[1])

person = {name="Cazzy", age=25}
print("Person name: " .. person.name)
print("Person age: " .. person["age"])

-- 6️⃣ Conditional Statements
print("---- Conditional ----")
score = 85
if score >= 90 then
    print("Excellent!")
elseif score >= 70 then
    print("Good job!")
else
    print("Keep trying!")
end

-- 7️⃣ Interactive part
print("---- Mini Game ----")
print("Guess a number between 1 and 5:")

-- Random number between 1 and 5
math.randomseed(os.time())
local target = math.random(1,5)
local guess = io.read("*n") -- read number input

if guess == target then
    print("🎉 Amazing! You guessed it!")
else
    print("Oops! The number was " .. target)
end

print("Thanks for playing Lua, " .. name .. "!")