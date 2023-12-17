import Data.Ord
import Data.List
import qualified Data.Map as Map

data Direction = North | East | South | West | Directionless deriving (Eq, Ord, Show)
type Coords = (Int, Int, Int, Direction)
data Node = Node { gcost :: Int, hcost :: Int } deriving Show
type HeatLossFunction = Coords -> Int
type NodeMap = Map.Map Coords Node
data PathFindState = PathFindState { target :: Coords, targetLookup :: [Coords], closed :: NodeMap, open :: NodeMap, heatLoss :: HeatLossFunction }

instance Show PathFindState where
  show state = show $ (target state, closed state, open state)

move :: Coords -> Direction -> Coords
move (x, y, s, d) North = (x, y-1, if d == North then s + 1 else 0, North)
move (x, y, s, d) East = (x+1, y, if d == East then s + 1 else 0, East)
move (x, y, s, d) South = (x, y+1, if d == South then s + 1 else 0, South)
move (x, y, s, d) West = (x-1, y, if d == West then s + 1 else 0, West)

right :: Direction -> Direction
right North = East
right East = South
right South = West
right West = North

left :: Direction -> Direction
left North = West
left East = North
left South = East
left West = South

fcost :: Node -> Int
fcost node = (gcost node) + (hcost node)

manhattan :: Coords -> Coords -> Int
manhattan (x1, y1, _, _) (x2, y2, _, _) = (abs $ x2 - x1) + (abs $ y2 - y1)

neighbours :: Coords -> [Coords]
neighbours coords@(x, y, s, d) = case d of
  Directionless -> [move coords North, move coords South, move coords East, move coords West]
  _ -> if s < 2 then [move coords d, move coords (left d), move coords (right d)] else [move coords (left d), move coords (right d)]

deriveNode :: PathFindState -> (Coords, Node) -> Coords -> [(Coords, Node)]
deriveNode state (coords, node) newCoords = case heatLoss state newCoords of
  0 -> []
  loss -> [(newCoords, newNode)] 
    where newNode = Node (gcost node + loss) (manhattan newCoords $ target state)

insertOpenNode :: PathFindState -> (Coords, Node) -> PathFindState
insertOpenNode state (coords, node) = case Map.lookup coords (closed state) of
  Just _ -> state
  Nothing -> case Map.lookup coords (open state) of
    Just oldNode | (gcost oldNode) <= (gcost node) -> state
    _ -> PathFindState (target state) (targetLookup state) (closed state) (Map.insert coords node $ open state) (heatLoss state)

closeNode :: PathFindState -> (Coords, Node) -> PathFindState
closeNode state (coords, node) = foldl insertOpenNode stateWithClosedNode $ concat $ map (deriveNode stateWithClosedNode (coords, node)) $ neighbours coords
  where stateWithClosedNode =  PathFindState (target state) (targetLookup state) (Map.insert coords node $ closed state) (Map.delete coords $ open state) (heatLoss state)

pathfindStep :: PathFindState -> PathFindState
pathfindStep state = closeNode state (coords, node)
  where (coords, node) = minimumBy (comparing (fcost . snd)) (Map.toList $ open state)

lookupOne :: Ord k => Map.Map k a -> k -> [a]
lookupOne map key = case Map.lookup key map of
  Just value -> [value]
  Nothing -> []

pathfindUntil :: PathFindState -> Node
pathfindUntil state = case concat $ map (lookupOne $ closed state) (targetLookup state) of
  [] -> pathfindUntil $ pathfindStep state
  list -> head list

newPathFindState :: HeatLossFunction -> (Int, Int) -> (Int, Int) -> PathFindState
newPathFindState heatLoss (fromX, fromY) (toX, toY) = PathFindState targetCoords lookupCoordinates Map.empty openNodes heatLoss
  where targetCoords = (toX, toY, 0, Directionless)
        lookupCoordinates = [(toX, toY, s, d) | s <- [0..2], d <- [North, East, South, West]]
        openNodes = Map.singleton (fromX, fromY, 0, Directionless) $ Node 0 (manhattan (fromX, fromY, 0, Directionless) targetCoords)

pathfind :: HeatLossFunction -> (Int, Int) -> (Int, Int) -> Node
pathfind heatLoss from to = pathfindUntil $ newPathFindState heatLoss from to



parseHeatLoss :: String -> Map.Map (Int, Int) Int
parseHeatLoss input = foldl (\m (c,l) -> Map.insert c l m) Map.empty $ concat $ map (\(y,s) -> map (\(x,l) -> ((x, y), read [l])) ([0..] `zip` s)) ([0..] `zip` lines input)

getMaxCoords :: Map.Map (Int, Int) a -> (Int, Int)
getMaxCoords coordMap = (maximum $ map fst $ Map.keys coordMap, maximum $ map snd $ Map.keys coordMap)

getHeatLoss :: Map.Map (Int, Int) Int -> Coords -> Int
getHeatLoss map (x, y, _, _) = Map.findWithDefault 0 (x, y) map

main = do
  heatLossMap <- parseHeatLoss <$> getContents
  target <- return $ getMaxCoords heatLossMap
  putStrLn $ show $ gcost $ pathfind (getHeatLoss heatLossMap) (0, 0) target
