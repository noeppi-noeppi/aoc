import Data.Char
import Data.Maybe
import Data.List

match :: [Int] -> [Int] -> Bool
match patterns cards
  | patterns == [] = True
  | otherwise = (filter (\l -> match (tail patterns) l) $ removeAllPossible (head patterns) cards) /= []

removeAllPossible :: Int -> [Int] -> [[Int]]
removeAllPossible amount nums = catMaybes $ map (removeNJ amount nums) nums

maybeHead :: Eq a => [a] -> Maybe a
maybeHead list
  | list == [] = Nothing
  | otherwise  = Just $ head list

removeNJ :: Int -> [Int] -> Int -> Maybe [Int]
removeNJ amount nums num = maybeHead $ catMaybes $ map (\(a,lm) -> lm >>= (\l -> removeN 1 l (amount - a))) $ map (\a -> (a,removeN num nums a)) (reverse [0..amount])

removeN :: Int -> [Int] -> Int -> Maybe [Int]
removeN num nums amount
  | amount == 0      = Just nums
  | nums == []       = Nothing
  | head nums == num = removeN num (tail nums) (amount - 1)
  | otherwise        = fmap ((head nums):) (removeN num (tail nums) amount)

isFiveKind :: Cards -> Bool
isFiveKind cards = match [5] (getCardList cards)

isFourKind :: Cards -> Bool
isFourKind cards = match [4] (getCardList cards)

isFullHouse :: Cards -> Bool
isFullHouse cards = match [3,2] (getCardList cards)

isThreeKind :: Cards -> Bool
isThreeKind cards = match [3] (getCardList cards)

isTwoPair :: Cards -> Bool
isTwoPair cards = match [2,2] (getCardList cards)

isOnePair :: Cards -> Bool
isOnePair cards = match [2] (getCardList cards)

combinationValue :: Cards -> Int
combinationValue cards
  | isFiveKind cards  = 6
  | isFourKind cards  = 5
  | isFullHouse cards = 4
  | isThreeKind cards = 3
  | isTwoPair cards   = 2
  | isOnePair cards   = 1
  | otherwise         = 0

data Cards = Cards { getCardList :: [Int] } deriving (Eq, Show)
instance Ord Cards where
  compare c1 c2
    | cv /= EQ  = cv
    | otherwise = (getCardList c1) `compare` (getCardList c2)
    where cv = (combinationValue c1) `compare` (combinationValue c2)

data Game = Game { getCards :: Cards, getWinValue :: Int } deriving (Eq, Show)
instance Ord Game where
  compare g1 g2 = (getCards g1) `compare` (getCards g2)

parseCard :: Char -> Int
parseCard char = case char of
  'T' -> 10
  'J' -> 1
  'Q' -> 11
  'K' -> 12
  'A' -> 13
  _ -> digitToInt char

parseCards :: String -> Cards
parseCards word = Cards cardList where cardList = map parseCard word

parseGame :: String -> Game
parseGame line = Game (parseCards $ parts!!0) (read $ parts!!1)
  where parts = words line

main = do
  games <- map parseGame <$> lines <$> getContents
  putStrLn $ show $ foldl (+) 0 $ map (\(a,b)->a*b) $ zip [1..] $ map getWinValue $ sort games
