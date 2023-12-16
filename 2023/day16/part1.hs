import qualified Data.Map as Map

data Position = Position { getX :: Int, getY :: Int } deriving (Eq, Ord, Show)
data Direction = North | East | South | West deriving (Eq, Show)
data Surface = ForwardMirror | BackwardMirror | HorizontalSplit | VerticalSplit deriving (Eq, Show)
type Area = Map.Map Position Surface
type LightMap = Map.Map Position [Direction]

parseSurface :: Char -> Maybe Surface
parseSurface '.' = Nothing
parseSurface '/' = Just ForwardMirror
parseSurface '\\' = Just BackwardMirror
parseSurface '-' = Just HorizontalSplit
parseSurface '|' = Just VerticalSplit

insertArea :: Position -> Maybe Surface -> Area -> Area
insertArea _ Nothing area = area
insertArea pos (Just surface) area = Map.insert pos surface area

parseArea :: String -> Area
parseArea input = foldl (\area (p,s) -> insertArea p s area) Map.empty $ concat $ map (\(y,s) -> map (\(x,c) -> (Position x y, parseSurface c)) ([0..] `zip` s)) ([0..] `zip` lines input)

opposite :: Direction -> Direction
opposite North = South
opposite East = West
opposite South = North
opposite West = East

move :: Position -> Direction -> Position
move Position{getX = x, getY = y} North = Position x (y-1)
move Position{getX = x, getY = y} East = Position (x+1) y
move Position{getX = x, getY = y} South = Position x (y+1)
move Position{getX = x, getY = y} West = Position (x-1) y

turn :: Area -> Position -> Direction -> [Direction]
turn area pos dir = case Map.lookup pos area of
  Just ForwardMirror | dir == East -> [North]
  Just ForwardMirror | dir == North -> [East]
  Just ForwardMirror | dir == West -> [South]
  Just ForwardMirror | dir == South -> [West]
  Just BackwardMirror | dir == East -> [South]
  Just BackwardMirror | dir == South -> [East]
  Just BackwardMirror | dir == West -> [North]
  Just BackwardMirror | dir == North -> [West]
  Just HorizontalSplit | dir == North || dir == South -> [East, West]
  Just VerticalSplit | dir == East || dir == West -> [North, South]
  _ -> [dir]

traceMove :: Area -> Position -> (Int, Int) -> LightMap -> Direction -> LightMap
traceMove area pos dim light dir = trace area light dim (move pos dir) dir

insertIntoLightMap :: Position -> Direction -> LightMap -> LightMap
insertIntoLightMap pos dir light = case Map.lookup pos light of
  Just old -> Map.insert pos (dir:old) light
  Nothing -> Map.insert pos [dir] light

trace :: Area -> LightMap -> (Int, Int) -> Position -> Direction -> LightMap
trace area light (w, h) pos dir = if (getX pos) < 0 || (getX pos) >= w || (getY pos) < 0 || (getY pos) >= h then light else case Map.lookup pos light of
  Just odirs | dir `elem` odirs -> light
  _ -> foldl (traceMove area pos (w, h)) (insertIntoLightMap pos dir light) (turn area pos dir)

main = do
  contents <- getContents
  width <- return $ length $ head $ lines contents
  height <- return $ length $ lines contents
  area <- return $ parseArea contents
  lightMap <- return $ trace area Map.empty (width, height) (Position 0 0) East
  putStrLn $ show $ length $ Map.keys lightMap
