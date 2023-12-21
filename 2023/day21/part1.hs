import qualified Data.Map as Map

type Position = (Int, Int)
data Direction = North | East | South | West deriving (Eq, Show)
data Surface = Garden | Rock | StartingPoint deriving (Eq, Show)
type Area = Map.Map Position Surface
type Reach = Map.Map Position ()

parseSurface :: Char -> Surface
parseSurface '.' = Garden
parseSurface '#' = Rock
parseSurface 'S' = StartingPoint

parseArea :: String -> Area
parseArea input = foldl (\area (p,s) -> Map.insert p s area) Map.empty $ concat $ map (\(y,s) -> map (\(x,c) -> ((x, y), parseSurface c)) ([0..] `zip` s)) ([0..] `zip` lines input)

getStartingPoint :: Area -> Position
getStartingPoint area = Map.foldrWithKey (\pos surface old -> if surface == StartingPoint then pos else old) (0, 0) area

opposite :: Direction -> Direction
opposite North = South
opposite East = West
opposite South = North
opposite West = East

move :: Position -> Direction -> Position
move (x, y) North = (x, y-1)
move (x, y) East = (x+1, y)
move (x, y) South = (x, y+1)
move (x, y) West = (x-1, y)

isFree :: Area -> Position -> Bool
isFree area pos = case Map.lookup pos area of
  Just Rock -> False
  _ -> True

reachFrom :: Area -> Position -> [Position]
reachFrom area at = filter (isFree area) [move at North, move at East, move at South, move at West]

reach :: Area -> Reach -> Reach
reach area reach = foldl (\r p -> Map.insert p () r) Map.empty (concat $ map (reachFrom area) $ Map.keys reach)

composeN :: Int -> (a -> a) -> a -> a
composeN 1 f a = f a
composeN n f a = f $ composeN (n-1) f a

main = do
  area <- parseArea <$> getContents
  startingPoint <- return $ getStartingPoint area
  putStrLn $ show $ Map.size $ composeN 64 (reach area) $ Map.singleton startingPoint ()
