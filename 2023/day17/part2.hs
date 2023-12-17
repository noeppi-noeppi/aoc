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
move coords dir = moveBy coords 1 dir

moveBy :: Coords -> Int -> Direction -> Coords
moveBy (x, y, s, d) by North = (x, y-by, if d == North then s + by else by - 1, North)
moveBy (x, y, s, d) by East = (x+by, y, if d == East then s + by else by - 1, East)
moveBy (x, y, s, d) by South = (x, y+by, if d == South then s + by else by - 1, South)
moveBy (x, y, s, d) by West = (x-by, y, if d == West then s + by else by - 1, West)

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
  Directionless -> [moveBy coords 4 North, moveBy coords 4 South, moveBy coords 4 East, moveBy coords 4 West]
  _ -> if s < 9 then [move coords d, moveBy coords 4 (left d), moveBy coords 4 (right d)] else [moveBy coords 4 (left d), moveBy coords 4 (right d)]

jumpCost :: PathFindState -> Coords -> Coords -> Int
jumpCost state (x1, y1, _, _) (x2, y2, _, _)
  | x1 == x2 && y1 == y2 = 0
  | x1 == x2 && y2 > y1 = sum $ map (heatLoss state) [(x1,y,0,Directionless) | y <- [y1+1..y2]]
  | x1 == x2 && y2 < y1 = sum $ map (heatLoss state) [(x1,y,0,Directionless) | y <- [y2..y1-1]]
  | x2 > x1 && y1 == y2 = sum $ map (heatLoss state) [(x,y1,0,Directionless) | x <- [x1+1..x2]]
  | x2 < x1 && y1 == y2 = sum $ map (heatLoss state) [(x,y1,0,Directionless) | x <- [x2..x1-1]]

deriveNode :: PathFindState -> (Coords, Node) -> Coords -> [(Coords, Node)]
deriveNode state (coords, node) newCoords = case jumpCost state coords newCoords of
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
        lookupCoordinates = [(toX, toY, s, d) | s <- [3..9], d <- [North, East, South, West]]
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
