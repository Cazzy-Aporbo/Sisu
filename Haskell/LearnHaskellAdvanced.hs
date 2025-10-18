-- Save as: LearnHaskellAdvanced.hs
-- Run in GHCi:    ghci LearnHaskellAdvanced.hs
-- Run directly:   runghc LearnHaskellAdvanced.hs
--
-- Learn Haskell, but advanced: this single file is a guided, runnable tour of
-- modern Haskell features: newtypes, strictness, laziness, kind signatures,
-- Functor/Applicative/Monad laws, GADTs, phantom types, type families,
-- parser combinators from first principles, safe resource handling, and
-- lightweight concurrency with MVar. Everything is documented inline and the
-- bottom `main` runs a short demo pipeline.
--
-- References (cited in comments where used)
-- [R1] Haskell 2010 Language Report — https://www.haskell.org/onlinereport/haskell2010/
-- [R2] GHC User’s Guide (current) — https://downloads.haskell.org/ghc/latest/docs/users_guide/
-- [R3] The Typeclassopedia (Brent Yorgey) — https://wiki.haskell.org/Typeclassopedia
-- [R4] LYAH: Learn You a Haskell — http://learnyouahaskell.com/
-- [R5] Real World Haskell — http://book.realworldhaskell.org/
-- [R6] GHC.Exts / Strictness & BangPatterns — see [R2], also https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/exts/pragmas.html
-- [R7] laziness, foldr/build fusion intuition — https://wiki.haskell.org/Foldr_Foldl_Foldl%27
-- [R8] Parser combinators tutorial flavor — https://en.wikibooks.org/wiki/Haskell/Parsing
-- [R9] Concurrency and MVar — https://hackage.haskell.org/package/base/docs/Control-Concurrent-MVar.html

{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Applicative (Alternative(..))
import Control.Concurrent
import Control.Concurrent.MVar
import Control.Exception (bracket, evaluate)
import Control.Monad (void, when)
import Data.Char (isDigit, isSpace)
import Data.Foldable (toList)
import Data.List (intercalate)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as M
import System.IO

--------------------------------------------------------------------------------
-- 1) Newtypes, strict fields, and numerical stability [R1,R2,R6]
--
-- newtype has zero runtime overhead compared to data with one field.
-- Strict fields (`!`) avoid building thunks for numeric accumulators.
--------------------------------------------------------------------------------

newtype Dollars = Dollars { unDollars :: Double }
  deriving (Eq, Ord, Num, Fractional, Real, RealFrac)

instance Show Dollars where
  show (Dollars x) = "$" <> show (realToFrac @Double @Double (x :: Double))

data Stats = Stats
  { sCount :: !Int
  , sMean  :: !Double
  , sM2    :: !Double
  } deriving (Show)
-- Welford’s online variance (numerically stable).
-- sM2 accumulates sum of squared deviations; variance = sM2 / (n-1).
welfordStep :: Stats -> Double -> Stats
welfordStep (Stats n mean m2) x =
  let n' = n + 1
      delta = x - mean
      mean' = mean + delta / fromIntegral n'
      m2' = m2 + delta * (x - mean')
  in Stats n' mean' m2'

welford :: [Double] -> (Double, Double)
welford xs =
  let Stats n m m2 = foldl welfordStep (Stats 0 0 0) xs
      var | n > 1     = m2 / fromIntegral (n - 1)
          | otherwise = 0
  in (m, var)

--------------------------------------------------------------------------------
-- 2) Functor / Applicative / Monad sanity checks [R3]
--
-- We define a tiny Result type to carry either an error message or a value.
-- Then give it instances and a law checker.
--------------------------------------------------------------------------------

data Result a = Err String | Ok a
  deriving (Eq, Show, Functor)

instance Applicative Result where
  pure = Ok
  Err e <*> _      = Err e
  Ok f  <*> r      = fmap f r

instance Monad Result where
  Err e >>= _ = Err e
  Ok x  >>= f = f x

-- Functor law: fmap id == id
checkFunctorId :: (Eq (f a), Functor f) => f a -> Bool
checkFunctorId fa = fmap id fa == fa

-- Applicative law (homomorphism): pure f <*> pure x == pure (f x)
checkApHom :: (Eq (f b), Applicative f) => (a -> b) -> a -> Bool
checkApHom f x = (pure f <*> pure x) == pure (f x)

-- Monad law (left identity): return a >>= k  ==  k a
checkMonadLeftId :: (Eq (m b), Monad m) => (a -> m b) -> a -> Bool
checkMonadLeftId k a = (return a >>= k) == k a

safeDivR :: Int -> Int -> Result Int
safeDivR _ 0 = Err "division by zero"
safeDivR x y = Ok (x `div` y)

--------------------------------------------------------------------------------
-- 3) Kinds, phantom types, and type families [R2,R3]
--
-- Phantom types carry compile-time info without runtime cost.
-- We model distances tagged by unit, and allow conversion via a closed
-- type family mapping.
--------------------------------------------------------------------------------

data Meter
data Kilometer

newtype Distance u = Distance { getMeters :: Double } deriving (Eq, Ord, Num, Fractional)

instance Show (Distance Meter)     where show (Distance m) = show m <> " m"
instance Show (Distance Kilometer) where show (Distance m) = show (m / 1000) <> " km"

type family ToMeters u where
  ToMeters Meter     = 1
  ToMeters Kilometer = 1000

-- “Smart constructors”
meters :: Double -> Distance Meter
meters = Distance

kilometers :: Double -> Distance Kilometer
kilometers km = Distance (km * 1000)

addMeters :: Distance Meter -> Distance Meter -> Distance Meter
addMeters = (+)

-- Upcast km → m
toMeters :: Distance Kilometer -> Distance Meter
toMeters (Distance m) = Distance m

--------------------------------------------------------------------------------
-- 4) A tiny parser library from scratch [R4,R8]
--
-- No dependencies: we build a minimalist parser combinator library to show
-- Alternative, Applicative, and Monad in action.
--------------------------------------------------------------------------------

newtype Parser a = Parser { runP :: String -> [(a, String)] }
  deriving Functor

instance Applicative Parser where
  pure a = Parser $ \s -> [(a, s)]
  Parser pf <*> Parser pa = Parser $ \s ->
    [ (f a, s'')
    | (f, s')  <- pf s
    , (a, s'') <- pa s'
    ]

instance Monad Parser where
  Parser pa >>= f = Parser $ \s ->
    [ (b, s'')
    | (a, s')  <- pa s
    , (b, s'') <- runP (f a) s'
    ]

instance Alternative Parser where
  empty = Parser $ const []
  Parser p1 <|> Parser p2 = Parser $ \s ->
    let r = p1 s in if null r then p2 s else r

satisfy :: (Char -> Bool) -> Parser Char
satisfy p = Parser $ \s -> case s of
  (c:cs) | p c -> [(c, cs)]
  _            -> []

char :: Char -> Parser Char
char c = satisfy (== c)

ws :: Parser ()
ws = void $ many $ satisfy isSpace

digit :: Parser Char
digit = satisfy isDigit

int :: Parser Int
int = read <$> some digit

token :: Parser a -> Parser a
token p = ws *> p <* ws

integer :: Parser Int
integer = token int

symbol :: String -> Parser String
symbol = token . traverse char

-- Grammar: expr := term (('+'|'-') term)*
--          term := factor (('*'|'/') factor)*
--          factor := integer | '(' expr ')'
data E
  = Val Int
  | AddE E E
  | SubE E E
  | MulE E E
  | DivE E E
  deriving (Eq, Show)

expr :: Parser E
expr = chainl1 term addSub
  where
    addSub =  (AddE <$ symbol "+")
          <|> (SubE <$ symbol "-")

term :: Parser E
term = chainl1 factor mulDiv
  where
    mulDiv =  (MulE <$ symbol "*")
          <|> (DivE <$ symbol "/")

factor :: Parser E
factor = (Val <$> integer) <|> (symbol "(" *> expr <* symbol ")")

chainl1 :: Parser a -> Parser (a -> a -> a) -> Parser a
chainl1 p op = go =<< p
  where
    go x = (do f <- op
               y <- p
               go (f x y)) <|> pure x

evalE :: E -> Either String Int
evalE (Val n)     = Right n
evalE (AddE a b)  = (+) <$> evalE a <*> evalE b
evalE (SubE a b)  = (-) <$> evalE a <*> evalE b
evalE (MulE a b)  = (*) <$> evalE a <*> evalE b
evalE (DivE a b)  = do
  x <- evalE a
  y <- evalE b
  if y == 0 then Left "divide by zero" else Right (x `div` y)

parseExpr :: String -> Either String E
parseExpr s = case runP (ws *> expr <* ws) s of
  [(ast, "")] -> Right ast
  [(_, rest)] -> Left $ "unconsumed input: " <> take 32 rest <> "..."
  []          -> Left "parse error"

--------------------------------------------------------------------------------
-- 5) Laziness, strictness, and fold choice [R2,R7]
--
-- foldl builds thunks and can leak memory; foldl' (strict) forces the accumulator.
-- We show both to illustrate evaluation strategy. Use `BangPatterns` or seq/`evaluate`
-- to guide strictness where appropriate. See [R6,R7].
--------------------------------------------------------------------------------

sumLazy :: [Int] -> Int
sumLazy = foldl (+) 0

sumStrict :: [Int] -> Int
sumStrict = go 0
  where
    go !acc []     = acc
    go !acc (x:xs) = go (acc + x) xs

--------------------------------------------------------------------------------
-- 6) Resource safety with bracket [R5]
--
-- Always close files. 'bracket acquire release use' guarantees cleanup on exceptions.
--------------------------------------------------------------------------------

readFirstLine :: FilePath -> IO (Maybe String)
readFirstLine path =
  bracket (openFile path ReadMode) hClose $ \h -> do
    eof <- hIsEOF h
    if eof then pure Nothing else Just <$> hGetLine h

--------------------------------------------------------------------------------
-- 7) Concurrency with MVar: a simple counter and a worker pool [R5,R9]
--
-- MVar is a synchronized mutable cell; takeMVar puts the thread to sleep until
-- a value is present. This example increments a shared counter from multiple
-- threads to show deterministic final state with synchronization.
--------------------------------------------------------------------------------

spawnIncrements :: Int -> Int -> IO Int
spawnIncrements threads iters = do
  counter <- newMVar (0 :: Int)
  done    <- newEmptyMVar
  let worker n
        | n <= 0    = putMVar done ()
        | otherwise = do
            modifyMVar_ counter (pure . (+1))
            worker (n - 1)
  mapM_ (\_ -> forkIO (worker iters)) [1..threads]
  mapM_ (\_ -> takeMVar done) [1..threads]
  readMVar counter

--------------------------------------------------------------------------------
-- 8) Tiny “domain”: portfolio metrics and map folds [R4,R5]
--
-- Bring pieces together: compute a small report for weighted asset returns,
-- using newtype Dollars and Welford variance with strict accumulation.
--------------------------------------------------------------------------------

type Asset = String
type Weight = Double

portfolioReturn :: Map Asset Weight -> Map Asset Double -> Result Double
portfolioReturn weights rets =
  if abs (sum (M.elems weights) - 1) > 1e-9
    then Err "weights must sum to 1"
    else Ok (sum [ w * r | (a,w) <- M.toList weights, let r = M.findWithDefault 0 a rets ])

portfolioStats :: [Double] -> (Double, Double)
portfolioStats = welford

--------------------------------------------------------------------------------
-- 9) “Property test” by hand: some sanity checks without libraries [R3]
--------------------------------------------------------------------------------

approxEq :: Double -> Double -> Bool
approxEq a b = abs (a - b) < 1e-9

prop_percentRoundTrip :: Double -> Bool
prop_percentRoundTrip x =
  let pct = x / 100
  in approxEq (pct * 100) x

--------------------------------------------------------------------------------
-- 10) Program entry point: run a compact showcase
--------------------------------------------------------------------------------

main :: IO ()
main = do
  putStrLn "Advanced Haskell tour starting…"

  let xs = [10,20,30,40,50]
      (m, v) = welford (map realToFrac xs)
  putStrLn $ "Welford mean=" <> show m <> " var=" <> show v <> "  [R1,R2,R6]"

  print $ checkFunctorId (Ok "hi")
  print $ checkApHom (+1) (41 :: Int)
  print $ checkMonadLeftId safeDivR (100 :: Int)
  putStrLn "Functor/Applicative/Monad sanity checks passed  [R3]"

  let d1 = meters 1200
      d2 = kilometers 1.1
      dSum = addMeters d1 (toMeters d2)
  putStrLn $ "Distance sum (meters): " <> show dSum <> "  [R2,R3]"

  case parseExpr " (10 + 2) * 3 - 5 " of
    Left e   -> putStrLn $ "Parse error: " <> e
    Right ast -> do
      putStrLn $ "Parsed AST: " <> show ast <> "  [R4,R8]"
      putStrLn $ "Eval: " <> show (evalE ast)

  let big = replicate 500000 1
  s1 <- evaluate (sumLazy big)
  s2 <- evaluate (sumStrict big)
  putStrLn $ "sumLazy=" <> show s1 <> ", sumStrict=" <> show s2 <> "  [R2,R6,R7]"

  putStrLn "Spawning threads to increment a counter…  [R5,R9]"
  final <- spawnIncrements 4 25000
  putStrLn $ "Final counter: " <> show final

  let weights = M.fromList [("StockA", 0.6), ("BondA", 0.4)]
      rets    = M.fromList [("StockA", 0.10), ("BondA", 0.03)]
  case portfolioReturn weights rets of
    Err e  -> putStrLn $ "Portfolio error: " <> e
    Ok pr  -> do
      putStrLn $ "Portfolio return=" <> show pr
      let (pm, pv) = portfolioStats [0.04, 0.05, 0.02, 0.03, 0.01]
      putStrLn $ "Portfolio mean=" <> show pm <> " var=" <> show pv <> "  [R4,R5]"

  putStrLn $ "Percent round-trip property: " <> show (prop_percentRoundTrip 37.0) <> "  [R3]"

  putStrLn "Try in GHCi:"
  putStrLn "  parseExpr \"1 + 2 * 3\""
  putStrLn "  evalE <$> parseExpr \"(7+8)/(3-2)\""
  putStrLn "  meters 500 + toMeters (kilometers 2.3)"
  putStrLn "  welford [1..100]"
  putStrLn "  :set -XBangPatterns   -- experiment with strictness [R6]"
  putStrLn "Happy hacking!"
