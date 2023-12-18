import Data.Char
import qualified Data.Map as Map

type Point = (Int, Int)
data Direction = North | East | South | West deriving (Eq, Show)

moveBy :: Int -> Point -> Direction -> Point
moveBy amount (x, y) North = (x, y - amount)
moveBy amount (x, y) East = (x + amount, y)
moveBy amount (x, y) South = (x, y + amount)
moveBy amount (x, y) West = (x - amount, y)
move :: Point -> Direction -> Point
move = moveBy 1

parseDirection :: Char -> Direction
parseDirection 'U' = North
parseDirection 'R' = East
parseDirection 'D' = South
parseDirection 'L' = West

parsePath :: String -> [Point]
parsePath input = reverse $ foldl (\list (dir, length) -> (moveBy length (head list) dir):list) [(0,0)] $ map (\line -> (parseDirection $ head line, read $ takeWhile isDigit $ drop 2 line)) $ lines input

countLength :: String -> Int
countLength input = sum $ map (\line -> read $ takeWhile isDigit $ drop 2 line) $ lines input

det :: (Point, Point) -> Int
det ((a, b), (c, d)) = a * d - b * c

area :: [Point] -> Int
area points = (abs $ sum $ map det (zip points $ (last points):points)) `div` 2

main = do
  input <- getContents
  path <- return $ parsePath input
  len <- return $ countLength input
  putStrLn $ show $ (area path) + (len `div` 2) + 1
