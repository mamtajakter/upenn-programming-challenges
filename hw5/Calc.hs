{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}
{-# OPTIONS_GHC -Wall #-}

module Calc where

-- Homework 5

import ExprT
import Parser
import qualified Data.Map as M
import qualified StackVM as S


--1--

eval :: ExprT-> Integer
eval (Lit a)= a
eval (Add a b)= eval a + eval b
eval (Mul a b)= eval a * eval b



--2--

evalStr:: String-> Maybe Integer
evalStr x= case y of
        Nothing -> Nothing
        Just n-> Just (eval n)
       where y=parseExp Lit Add Mul x


--3--

class Expr a where
    lit :: Integer-> a
    add :: a -> a -> a
    mul :: a -> a -> a


instance Expr ExprT where
   lit x = Lit x
   add a b = Add a b
   mul a b = Mul a b


reify :: ExprT-> ExprT
reify= id

--4--



instance Expr Integer where
   lit x= x
   add a b =   a  + b
   mul a b = a * b

instance Expr Bool where
   lit x
       | x<=0  = False
       | otherwise = True
   add a b= a || b
   mul a b = a && b



newtype MinMax = MinMax Integer deriving (Show, Eq)
newtype Mod7   = Mod7   Integer deriving (Show, Eq)


instance Expr MinMax where
   lit a = MinMax a
   add (MinMax a) (MinMax b)=  MinMax (max a b)
   mul (MinMax a) (MinMax b)=  MinMax (min a b)


instance Expr Mod7 where
   lit x = Mod7 ( x `mod` 7)
   add (Mod7 a) (Mod7 b)= Mod7 ((a+b) `mod` 7)
   mul (Mod7 a) (Mod7 b)= Mod7 ((a*b) `mod` 7)



testExp :: Expr a => Maybe a
testExp = parseExp lit add mul "(3 * -4) + 5"


testInteger = testExp :: Maybe Integer
testBool = testExp :: Maybe Bool
testMM = testExp :: Maybe MinMax
testSat = testExp :: Maybe Mod7
--testInteger = parseExp lit add mul "(3 * 4) + 5"

--5--



instance Expr S.Program where
   lit x = [S.PushI x]
   add a b =  a ++ b ++ [S.Add]
   mul a b = a ++ b ++ [S.Mul]



compile :: String -> Maybe S.Program
compile  =  parseExp lit add mul

--6-- I am stuck again, dont understand how to write  instance of function

class HasVars a where
    var :: String-> a


data VarExprT = VarLit Integer
           | VarAdd VarExprT VarExprT
           | VarMul VarExprT VarExprT
           | Var String
  deriving (Show, Eq)



instance Expr VarExprT where
   lit x = VarLit x
   add a b = VarAdd a b
   mul a b = VarMul a b

instance HasVars VarExprT where
   var s= Var s


instance HasVars  (M.Map String Integer-> Maybe Integer) where
   var x = M.lookup x

instance Expr (M.Map String Integer-> Maybe Integer) where
   lit x = \_-> Just x
   add x y= \a -> case (x a ) of
                   Nothing ->  case (y a) of
                         Nothing -> Nothing
                         Just m  -> Just m
                   Just n  -> case (y a) of
                         Nothing -> Just n
                         Just m  -> Just (m+n)
   mul x y = \a -> case (x a ) of
                   Nothing ->  case (y a) of
                         Nothing -> Nothing
                         Just m  -> Just m
                   Just n  -> case (y a) of
                         Nothing -> Just n
                         Just m  -> Just (m*n)


{-

a little example code of Map

type Name =String
type PhoneNum= String
type PhoneBook =M.Map Name PhoneNum

book :: PhoneBook
book = M.fromList [("A", "1"), ("B","2")]

book'= M.insert "C" "3" book

lookupTwo n1 n2 bk= (M.lookup n1 bk, M.lookup n2 bk)
-}
