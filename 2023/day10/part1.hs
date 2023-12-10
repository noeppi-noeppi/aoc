import Data.Maybe
import qualified Data.Map as Map

data Position = Position { getX :: Int, getY :: Int } deriving (Eq, Ord, Show)
data Direction = North | East | South | West deriving (Eq, Show)
data Walk = Walk { getPosition :: Position, getDirection :: Direction, getDistance :: Int } deriving Show
data Surface = Ground | StartingPoint | Pipe Direction Direction deriving (Eq, Show)
type Area = Map.Map Position Surface

parseSurface :: Char -> Surface
parseSurface '.' = Ground
parseSurface 'S' = StartingPoint
parseSurface '|' = Pipe North South
parseSurface '-' = Pipe East West
parseSurface 'L' = Pipe North East
parseSurface 'J' = Pipe North West
parseSurface '7' = Pipe South West
parseSurface 'F' = Pipe South East

parsePipes :: String -> Area
parsePipes input = foldl (\area (p,s) -> Map.insert p s area) Map.empty $ concat $ map (\(y,s) -> map (\(x,c) -> (Position x y, parseSurface c)) ([0..] `zip` s)) ([0..] `zip` lines input)

getStartingPoint :: Area -> Position
getStartingPoint area = Map.foldrWithKey (\pos surface old -> if surface == StartingPoint then pos else old) (Position 0 0) area

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

connectingEdge :: Surface -> Direction -> Maybe Direction
connectingEdge Ground _ = Nothing
connectingEdge StartingPoint dir = Just dir
connectingEdge (Pipe a b) from = if a == from then Just b else if b == from then Just a else Nothing 

walkOnce :: Area -> Walk -> Maybe Walk
walkOnce area Walk{getPosition = pos, getDirection = dir, getDistance = dist} = do
  surface <- Map.lookup (move pos dir) area
  newDirection <- connectingEdge surface (opposite dir)
  Just $ Walk (move pos dir) newDirection (dist + 1)

walkUntil :: Area -> Position -> Walk -> Maybe Walk
walkUntil area target walk = do
  next <- walkOnce area walk
  if getPosition next == target then Just next else walkUntil area target next

main = do
  area <- parsePipes <$> getContents
  startingPosition <- return $ getStartingPoint area  
  walks <- return $ map (walkUntil area startingPosition) $ map (\dir -> Walk startingPosition dir 0) [North, East, South, West]
  distance <- return $ head $ map getDistance (walks >>= maybeToList)
  putStrLn $ show $ distance `div` 2
