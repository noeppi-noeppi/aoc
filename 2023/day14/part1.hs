import Data.List

data RockState = Empty | Cube | Round deriving (Eq,Show)

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

countLoad :: [RockState] -> Int
countLoad rocks = sum $ map (\(r,c)->if r == Round then c else 0) (reverse rocks `zip` [1..])

main = do
  states <- map moveNorth <$> parseRockStates <$> getContents
  putStrLn $ show $ sum $ map countLoad states