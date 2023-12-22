import Data.Char
import Data.List
import Data.Maybe
import Data.Ord

type Position = (Int, Int, Int)
type Brick = (Position, Position)

parsePosition :: String -> Position
parsePosition string = (read n1, read n2, read n3)
  where n1 = takeWhile isDigit string
        s1 = tail $ dropWhile isDigit string
        n2 = takeWhile isDigit s1
        s2 = tail $ dropWhile isDigit s1
        n3 = takeWhile isDigit s2

parseBrick :: String -> Brick
parseBrick string = (parsePosition p1, parsePosition $ tail p2) where (p1, p2) = splitAt (fromJust $ '~' `elemIndex` string) string

inside :: Brick -> Position -> Bool
inside ((x1, y1, z1), (x2, y2, z2)) (x, y, z) = x1 <= x && x <= x2 && y1 <= y && y <= y2 && z1 <= z && z <= z2

overlap :: (Int, Int) -> (Int, Int) -> Bool
overlap (s1, e1) (s2, e2) = (s1 <= s2 && s2 <= e1) || (s1 <= e2 && e2 <= e1) || (s2 <= s1 && s1 <= e2) || (s2 <= e1 && e1 <= e2)

occupy :: Brick -> Brick -> Bool
occupy ((sx1, sy1, sz1), (ex1, ey1, ez1)) ((sx2, sy2, sz2), (ex2, ey2, ez2)) = overlapX && overlapY && overlapZ
  where overlapX = overlap (sx1, ex1) (sx2, ex2)
        overlapY = overlap (sy1, ey1) (sy2, ey2)
        overlapZ = overlap (sz1, ez1) (sz2, ez2)

moveDown :: Brick -> Brick
moveDown ((x1, y1, z1), (x2, y2, z2)) = ((x1, y1, z1 - 1), (x2, y2, z2 - 1))

sortBricks :: [Brick] -> [Brick]
sortBricks bricks = sortBy (comparing (\((_, _, z), _) -> z)) bricks

canFall :: Brick -> [Brick] -> Bool
canFall brick@((_, _, z), _) fallen
  | z <= 1 = False
  | all (not . occupy down) fallen = True
  | otherwise = False
  where down = moveDown brick

fallOne :: Brick -> [Brick] -> Brick
fallOne brick@((_, _, z), _) fallen
  | z <= 1 = brick
  | all (not . occupy down) fallen = fallOne down fallen
  | otherwise = brick
  where down = moveDown brick

fallDown :: [Brick] -> [Brick] -> [Brick]
fallDown [] fallen = fallen
fallDown (head : tail) fallen = fallDown tail (fallOne head fallen : fallen)

minorLists :: [a] -> [[a]]
minorLists [] = []
minorLists (head : tail) = tail : map (head :) (minorLists tail)

isStable :: [Brick] -> [Brick] -> Bool
isStable [] _ = True
isStable (head : tail) fallen = (not $ canFall head fallen) && isStable tail (head : fallen)

main = do
  bricks <- sortBricks <$> map parseBrick <$> lines <$> getContents
  fallen <- return $ sortBricks $ fallDown bricks []
  putStrLn $ show $ length $ filter (\b -> isStable b []) $ minorLists fallen
