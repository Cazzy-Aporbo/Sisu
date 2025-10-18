-- Save as: LearnHaskell.hs
-- Run in GHCi:   ghci LearnHaskell.hs
-- Run as a program:   runghc LearnHaskell.hs   or   ghc LearnHaskell.hs && ./LearnHaskell
--
-- This single file is a mini teach yourself Haskell with runnable examples.
-- Read the comments top-to-bottom and try expressions in GHCi.

module Main where

import Data.List (sort, nub, intercalate)
import Data.Char (toUpper)

-- 0) What is Haskell?
-- Purely functional, statically typed, with type inference.
-- You write expressions (no statements), and functions are first-class.
-- Functions don’t mutate state; instead, you build new values from old ones.

-- 1) Values, types, and type inference

-- Haskell infers types, but you can (and should) annotate them for clarity.

answer :: Int
answer = 42

greeting :: String
greeting = "hello"

-- Numeric literals are polymorphic; the compiler chooses a concrete type
-- from usage. Here we fix them:
aFloat :: Float
aFloat = 3.14

aDouble :: Double
aDouble = 2.71828

-- Booleans and chars
flag :: Bool
flag = True

exChar :: Char
exChar = 'A'

-- 2) Functions

-- Functions are just values with arguments.
-- Type: add takes two Ints and returns an Int.
add :: Int -> Int -> Int
add x y = x + y

-- Functions are curried by default: add 1 returns a function Int -> Int
inc :: Int -> Int
inc = add 1

-- No parentheses for arguments, but you do need them for grouping.
hypotenuse :: Floating a => a -> a -> a
hypotenuse x y = sqrt (x*x + y*y)

-- You can define functions with multiple equations and pattern matching.
first :: (a, b) -> a
first (x, _) = x

second :: (a, b) -> b
second (_, y) = y

-- 3) Lists, tuples, and basic operations
-

-- Lists are homogenous: all elements must have the same type.
nums :: [Int]
nums = [1,2,3,4,5]

wordsList :: [String]
wordsList = ["haskell","is","fun"]

-- Prepend with (:), concatenate with (++)
moreNums :: [Int]
moreNums = 0 : nums ++ [6]

-- List comprehensions
squares :: [Int]
squares = [ n*n | n <- [1..10] ]

evensUnder20 :: [Int]
evensUnder20 = [ n | n <- [1..20], even n ]

-- Tuples group values of possibly different types
person :: (String, Int, Bool)
person = ("Alice", 30, True)

-- 4) Pattern matching and guards

-- Pattern matching deconstructs data.
headSafe :: [a] -> Maybe a
headSafe []    = Nothing
headSafe (x:_) = Just x

-- Guards let you choose by conditions.
classifyScore :: Int -> String
classifyScore n
  | n < 0     = "invalid"
  | n < 60    = "fail"
  | n < 90    = "pass"
  | otherwise = "distinction"

-- Wildcards and as-patterns (@)
showFirstTwo :: [Int] -> String
showFirstTwo xs@(x:y:_) = "first=" ++ show x ++ ", second=" ++ show y ++ ", list=" ++ show xs
showFirstTwo _          = "not enough elements"

-- 5) Recursion


-- Recursion is fundamental. Sum of a list:
sumRec :: Num a => [a] -> a
sumRec []     = 0
sumRec (x:xs) = x + sumRec xs

-- Factorial
factorial :: (Eq a, Num a) => a -> a
factorial 0 = 1
factorial n = n * factorial (n - 1)

-- Tail recursion with an accumulator
factorial' :: (Eq a, Num a) => a -> a
factorial' n = go n 1
  where
    go 0 acc = acc
    go k acc = go (k-1) (k*acc)


-- 6) Higher-order functions (map, filter, fold)


-- map applies a function to each element
toUpperWords :: [String] -> [String]
toUpperWords = map (map toUpper)

-- filter keeps elements that satisfy a predicate
onlyShort :: Int -> [String] -> [String]
onlyShort k = filter (\w -> length w <= k)

-- foldl' and foldr reduce a list to a single value
concatCSV :: [String] -> String
concatCSV = intercalate ","

sumFold :: Num a => [a] -> a
sumFold = foldl (+) 0

-- 7) Algebraic data types (ADTs)

-- Define your own types. Here’s a tiny expression language:
data Expr
  = Lit Int
  | Add Expr Expr
  | Mul Expr Expr
  | Neg Expr
  deriving (Show, Eq)

-- Evaluate the expression:
eval :: Expr -> Int
eval (Lit n)   = n
eval (Add a b) = eval a + eval b
eval (Mul a b) = eval a * eval b
eval (Neg e)   = negate (eval e)

-- Example expression: (1 + 2) * (3 + -(4))
exampleExpr :: Expr
exampleExpr = Mul (Add (Lit 1) (Lit 2)) (Add (Lit 3) (Neg (Lit 4)))

-- 8) Maybe and Either: expressing absence and errors in types

-- Maybe a = Nothing | Just a
safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv x y = Just (x `div` y)

-- Either a b is often used for errors: Left = error, Right = result
data MathError = DivByZero | NegativeSqrt deriving (Show, Eq)

safeDivE :: Int -> Int -> Either MathError Int
safeDivE _ 0 = Left DivByZero
safeDivE x y = Right (x `div` y)

safeSqrtE :: Double -> Either MathError Double
safeSqrtE x
  | x < 0     = Left NegativeSqrt
  | otherwise = Right (sqrt x)

-- 9) Typeclasses: Eq, Ord, Show, Num, Functor, Applicative, Monad

-- You’ve used Eq/Ord/Show already. Here’s a user type deriving them:
data Color = Red | Green | Blue deriving (Show, Eq, Ord, Enum, Bounded)

-- Functor, Applicative, Monad appear around containers/effects.
-- A quick taste with Maybe:

-- Functor: fmap applies a function “inside” the context
upperMaybe :: Maybe String -> Maybe String
upperMaybe = fmap (map toUpper)

-- Applicative: apply a function in a context to a value in a context
sum3 :: Int -> Int -> Int -> Int
sum3 x y z = x + y + z

apExample :: Maybe Int
apExample = pure sum3 <*> Just 1 <*> Just 2 <*> Just 3  -- Just 6

-- Monad: do-notation chains computations that might fail
safeChain :: Int -> Int -> Int -> Maybe Int
safeChain x y z = do
  a <- safeDiv x y
  b <- safeDiv a z
  pure b

-- 10) IO and do-notation
-- IO describes side effects. This prints a greeting.
sayHello :: IO ()
sayHello = do
  putStrLn "What is your name?"
  name <- getLine
  putStrLn ("Nice to meet you, " ++ name ++ "!")

-- Reading and processing a whole line:
wordCount :: IO ()
wordCount = do
  putStrLn "Paste a line and I will count words:"
  line <- getLine
  let n = length (words line)
  putStrLn ("Word count: " ++ show n)

-- 11) Small, practical exercises (try in GHCi)
-- :t expr   shows a type
-- :r        reloads the file after edits
-- :info T   shows info about a typeclass or type
-- map, filter, foldr/foldl, take, drop, zip, unzip are your daily friends.
-- 11a) Pure “pipeline” function: clean, unique, sorted words
cleanUniqueSorted :: String -> [String]
cleanUniqueSorted = sort . nub . words

-- 11b) A tiny, safe, “read int if possible”
readIntMaybe :: String -> Maybe Int
readIntMaybe s =
  case reads s of
    [(n, "")] -> Just n
    _         -> Nothing

-- 11c) Tiny REPL-style IO that sums two user ints if both parse
sumTwoFromInput :: IO ()
sumTwoFromInput = do
  putStrLn "Enter first integer:"
  s1 <- getLine
  putStrLn "Enter second integer:"
  s2 <- getLine
  case (readIntMaybe s1, readIntMaybe s2) of
    (Just x, Just y) -> putStrLn ("Sum = " ++ show (x + y))
    _                -> putStrLn "Please enter valid integers."


-- 12) A small “project”: CSV-like summarizer
-- Given a list of (name, score), compute average and top N.

type Name  = String
type Score = Int

avgScore :: [(Name, Score)] -> Maybe Double
avgScore [] = Nothing
avgScore xs = Just (fromIntegral (sum (map snd xs)) / fromIntegral (length xs))

topN :: Int -> [(Name, Score)] -> [(Name, Score)]
topN n = take n . reverse . sortOnSnd
  where
    sortOnSnd = sortOn snd
    sortOn :: Ord b => (a -> b) -> [a] -> [a]
    sortOn f = sortByCmp (\x y -> compare (f x) (f y))
    sortByCmp cmp = foldr insert []
      where
        insert x [] = [x]
        insert x (y:ys)
          | cmp x y == GT = y : insert x ys
          | otherwise     = x : y : ys


-- 13) Main: run a quick tour when executed as a program


main :: IO ()
main = do
  putStrLn "=== LearnHaskell quick tour ==="
  putStrLn ("answer = " ++ show answer)
  putStrLn ("greeting = " ++ show greeting)
  putStrLn ("inc 41 = " ++ show (inc 41))
  putStrLn ("hypotenuse 3 4 = " ++ show (hypotenuse 3 (4 :: Double)))
  putStrLn ("first person = " ++ show (first person))
  putStrLn ("second person = " ++ show (second person))
  putStrLn ("nums = " ++ show nums)
  putStrLn ("moreNums = " ++ show moreNums)
  putStrLn ("squares = " ++ show squares)
  putStrLn ("evensUnder20 = " ++ show evensUnder20)
  putStrLn ("headSafe [] = " ++ show (headSafe ([] :: [Int])))
  putStrLn ("headSafe [1,2,3] = " ++ show (headSafe [1,2,3 :: Int]))
  putStrLn ("classifyScore 91 = " ++ classifyScore 91)
  putStrLn ("sumRec [1..5] = " ++ show (sumRec [1..5 :: Int]))
  putStrLn ("factorial 5 = " ++ show (factorial 5))
  putStrLn ("eval exampleExpr = " ++ show (eval exampleExpr))
  putStrLn ("safeDiv 10 0 = " ++ show (safeDiv 10 0))
  putStrLn ("safeChain 20 2 2 = " ++ show (safeChain 20 2 2))
  putStrLn ("upperMaybe (Just \"hi\") = " ++ show (upperMaybe (Just "hi")))
  putStrLn "Try:  sayHello   or   wordCount   in GHCi for interactive IO."
  putStrLn "Try:  cleanUniqueSorted \"hi hi haskell is fun fun\""
  putStrLn "Try:  avgScore [(\"Ann\",88),(\"Bob\",91),(\"Cat\",95)]"
  putStrLn "Try:  topN 2 [(\"Ann\",88),(\"Bob\",91),(\"Cat\",95)]"

-- End of file
