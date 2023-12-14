import Data.List

data RockState = Empty | Cube | Round deriving (Eq,Ord,Show)

parseRockState :: Char -> RockState
parseRockState '.' = Empty
parseRockState '#' = Cube
parseRockState 'O' = Round

parseRockStates :: String -> [[RockState]]
parseRockStates contents = transpose $ map (\l -> map parseRockState l) $ lines contents

moveNorthOnce :: [RockState] -> [RockState]
moveNorthOnce [] = []
moveNorthOnce [a] = [a]
moveNorthOnce list = case (head list, head $ tail list) of
  (Empty, Round) -> Round : (moveNorth $ Empty : (tail $ tail list))
  (h, _) -> h : (moveNorth $ tail list)

moveNorth :: [RockState] -> [RockState]
moveNorth rocks = if rocks == once then rocks else moveNorth once where once = moveNorthOnce rocks

rotate :: [[RockState]] -> [[RockState]]
rotate list = transpose $ map reverse list

moveCycle :: [[RockState]] -> [[RockState]]
moveCycle rocks = rotate $ (map moveNorth) $ rotate $ (map moveNorth) $ rotate $ (map moveNorth) $ rotate $ (map moveNorth) rocks

moveCycles :: [[RockState]] -> Int -> [[RockState]]
moveCycles rocks 0 = rocks
moveCycles rocks n = moveCycle $ moveCycles rocks (n-1)

findDivisor :: [[RockState]] -> [[[RockState]]] -> (Int, Int)
findDivisor rocks allOld = case elemIndex rocks allOld of
  Just at -> ((length allOld) - at - 1, at + 1)
  Nothing -> findDivisor (moveCycle rocks) (rocks:allOld)

countLoad :: [RockState] -> Int
countLoad rocks = sum $ map (\(r,c)->if r == Round then c else 0) (reverse rocks `zip` [1..])

main = do
  states <- parseRockStates <$> getContents
  divisor <- return $ findDivisor states []
  result <- return $ moveCycles states ((fst divisor) + ((1000000000 - (fst divisor)) `mod` (snd divisor))) 
  putStrLn $ show $ sum $ map countLoad  result
