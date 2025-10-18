-- Save as: HaskellFundamentalsPro.hs
-- Run in GHCi: ghci HaskellFundamentalsPro.hs
-- Or: runghc HaskellFundamentalsPro.hs

module Main where

import Data.Char (toUpper, isSpace)
import Data.List (intercalate, sortBy)
import Data.Ord (comparing)

-- values and types
answer :: Int
answer = 42

pi' :: Double
pi' = 3.141592653589793

greet :: String
greet = "hello"

flag :: Bool
flag = True

-- functions
add :: Int -> Int -> Int
add x y = x + y

inc :: Int -> Int
inc = add 1

hyp :: Floating a => a -> a -> a
hyp x y = sqrt (x*x + y*y)

composeDemo :: String
composeDemo = (map toUpper . reverse) "haskell"

-- pattern matching
headSafe :: [a] -> Maybe a
headSafe []    = Nothing
headSafe (x:_) = Just x

-- lists and comprehensions
squares :: [Int]
squares = [n*n | n <- [1..10]]

evens :: [Int]
evens = [n | n <- [0..20], even n]

-- recursion and folds
sumRec :: Num a => [a] -> a
sumRec []     = 0
sumRec (x:xs) = x + sumRec xs

sumFold :: Num a => [a] -> a
sumFold = foldl (+) 0

concatWith :: String -> [String] -> String
concatWith sep = foldr step ""
  where
    step s ""  = s
    step s acc = s <> sep <> acc

-- algebraic data types
data Point = Point Double Double deriving (Eq, Show)

data Shape
  = Circle Point Double
  | Rectangle Point Point
  deriving (Eq, Show)

area :: Shape -> Double
area (Circle _ r) = pi' * r * r
area (Rectangle (Point x1 y1) (Point x2 y2)) =
  abs (x2 - x1) * abs (y2 - y1)

-- records and updates
data Person = Person { name :: String, age :: Int } deriving (Eq, Show)

haveBirthday :: Person -> Person
haveBirthday p = p { age = age p + 1 }

-- typeclasses
class Csv a where
  toCsv :: a -> String

instance Csv Person where
  toCsv (Person n a) = intercalate "," [n, show a]

-- Maybe and Either
safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv x y = Just (x `div` y)

data MathErr = DivZero | BadParse deriving (Eq, Show)

readInt :: String -> Either MathErr Int
readInt s = case reads s of
  [(n,"")] -> Right n
  _        -> Left BadParse

safeDivE :: Int -> Int -> Either MathErr Int
safeDivE _ 0 = Left DivZero
safeDivE x y = Right (x `div` y)

-- functor, applicative, monad
upperMaybe :: Maybe String -> Maybe String
upperMaybe = fmap (map toUpper)

sum3 :: Int -> Int -> Int -> Int
sum3 x y z = x + y + z

apDemo :: Maybe Int
apDemo = pure sum3 <*> Just 1 <*> Just 2 <*> Just 3

chainDemo :: Int -> Int -> Int -> Maybe Int
chainDemo x y z = do
  a <- safeDiv x y
  b <- safeDiv a z
  pure b

-- laziness helpers
naturals :: [Integer]
naturals = [0..]

takeEvenSquares :: Int -> [Integer]
takeEvenSquares k = take k [n*n | n <- naturals, even n]

trim :: String -> String
trim = f . f where f = reverse . dropWhile isSpace

-- small utilities
sortByAge :: [Person] -> [Person]
sortByAge = sortBy (comparing age)

greeter :: IO ()
greeter = do
  putStrLn "Your name:"
  n <- getLine
  putStrLn ("Hi, " <> n <> "!")

-- program entry
main :: IO ()
main = do
  putStrLn "Haskell fundamentals (professional, minimal commentary)"
  print answer
  putStrLn greet
  print (inc 41)
  print (hyp 3 (4 :: Double))
  print composeDemo
  print (headSafe ([] :: [Int]))
  print (headSafe [1,2,3 :: Int])
  print squares
  print evens
  print (sumRec [1..10 :: Int], sumFold [1..10 :: Int])
  putStrLn (concatWith "-" ["a","b","c"])
  let s1 = Circle (Point 0 0) 2
      s2 = Rectangle (Point 0 0) (Point 3 4)
  print (area s1, area s2)
  let p = Person "Eve" 20
  print p
  print (haveBirthday p)
  putStrLn (toCsv p)
  print (safeDiv 20 4, safeDiv 20 0)
  print (readInt "123", readInt "nope")
  print (safeDivE 10 2, safeDivE 10 0)
  print (upperMaybe (Just "hi"))
  print apDemo
  print (chainDemo 20 2 2)
  print (takeEvenSquares 6)
  putStrLn (trim "   haskell  ")
  print (sortByAge [Person "A" 30, Person "B" 20, Person "C" 25])
  putStrLn "Done."

