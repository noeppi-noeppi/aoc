import Data.Char
import Data.List

isFiveKind :: Cards -> Bool
isFiveKind cards = a == e where (a, _, _, _, e) = getSortedCards cards

isFourKind :: Cards -> Bool
isFourKind cards = a == d || b == e where (a, b, _, d, e) = getSortedCards cards

isFullHouse :: Cards -> Bool
isFullHouse cards = (a == c && d == e) || (a == b && c == e) where (a, b, c, d, e) = getSortedCards cards

isThreeKind :: Cards -> Bool
isThreeKind cards = a == c || b == d || c == e where (a, b, c, d, e) = getSortedCards cards

isTwoPair :: Cards -> Bool
isTwoPair cards = (a == b && (c == d || d == e)) || (b == c && d == e) where (a, b, c, d, e) = getSortedCards cards

isOnePair :: Cards -> Bool
isOnePair cards = a == b || b == c || c == d || d == e where (a, b, c, d, e) = getSortedCards cards

combinationValue :: Cards -> Int
combinationValue cards
  | isFiveKind cards  = 6
  | isFourKind cards  = 5
  | isFullHouse cards = 4
  | isThreeKind cards = 3
  | isTwoPair cards   = 2
  | isOnePair cards   = 1
  | otherwise         = 0

data Cards = Cards { getCardList :: [Int], getSortedCards :: (Int, Int, Int, Int, Int) } deriving (Eq, Show)
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
  'J' -> 11
  'Q' -> 12
  'K' -> 13
  'A' -> 14
  _ -> digitToInt char

parseCards :: String -> Cards
parseCards word = Cards cardList (sortedCardList!!0, sortedCardList!!1, sortedCardList!!2, sortedCardList!!3, sortedCardList!!4)
  where
    cardList = map parseCard word
    sortedCardList = sort cardList

parseGame :: String -> Game
parseGame line = Game (parseCards $ parts!!0) (read $ parts!!1)
  where parts = words line

main = do
  games <- map parseGame <$> lines <$> getContents
  putStrLn $ show $ foldl (+) 0 $ map (\(a,b)->a*b) $ zip [1..] $ map getWinValue $ sort games
