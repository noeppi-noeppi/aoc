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

clamp :: Position -> Position
clamp (x, y) = (x `mod` 131, y `mod` 131)

isFree :: Area -> Position -> Bool
isFree area pos = case Map.lookup (clamp pos) area of
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
  s1 <- return $ composeN 65 (reach area) $ Map.singleton startingPoint ()
  s2 <- return $ composeN 131 (reach area) s1
  s3 <- return $ composeN 131 (reach area) s2
  r1 <- return $ Map.size s1
  r2 <- return $ Map.size s2
  r3 <- return $ Map.size s3
  a <- return $ r1 - 2 * r2 + 1 * r3
  b <- return $ -3 * r1 + 4 * r2 -1 * r3
  c <- return $ 2 * r1
  putStrLn $ show $ (a * (202300*202300) + b * 202300 + c) `div` 2
