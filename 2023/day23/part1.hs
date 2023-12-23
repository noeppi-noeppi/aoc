import Data.List
import Data.Maybe
import qualified Data.Map as Map

type Position = (Int, Int)
data Direction = North | East | South | West deriving (Eq, Show)
data Surface = FreeSpace | Forest | Slope Direction deriving (Eq, Show)
type Area = Map.Map Position Surface

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

parseSurface :: Char -> Surface
parseSurface '#' = Forest
parseSurface '^' = Slope North
parseSurface '>' = Slope East
parseSurface 'v' = Slope South
parseSurface '<' = Slope West

parseArea :: String -> Area
parseArea input = foldl (\area (p,s) -> Map.insert p s area) Map.empty $ concat $ map (\(y,s) -> map (\(x,c) -> ((x, y), parseSurface c)) ([0..] `zip` s)) ([0..] `zip` lines input)

type Node = (Int, Int)
type Edge = (Node, (Node, Int))
type Graph = Map.Map Node [(Node, Int)]
type Path = [Node]

graphFromList :: [Edge] -> Graph
graphFromList edges = Map.fromListWith (\a b -> nub $ a ++ b) $ map (\(k,v)->(k,[v])) edges

convertToGraph :: Area -> Graph
convertToGraph area = graphFromList $ concat $ map makeEdges $ Map.keys area
  where makeEdges :: Position -> [Edge]
        makeEdges pos = case fromJust $ Map.lookup pos area of
          Forest -> []
          FreeSpace -> map (\p -> (pos, (p, 1))) $ filter (\p -> (Map.lookup p area) == (Just FreeSpace)) [move pos dir | dir <- [North, East, South, West]]
          Slope dir -> [(move pos $ opposite dir, (move pos dir, 2))]

simplifyGraph :: Graph -> Graph
simplifyGraph graph = graphFromList edgeList
  where connects :: Node -> Node -> Bool
        connects src dst = case Map.lookup src graph of
          Just dsts | any (\(d, _) -> dst == d) dsts -> True
          _ -> False
        addCost :: Int -> (Node, Int) -> (Node, Int)
        addCost num (node, cost) = (node, cost + num)
        findEndNode :: Edge -> (Node, Int)
        findEndNode (src, (dst, cost)) = case fromJust $ Map.lookup dst graph of
          [ e1@(dst1, weight1), e2@(dst2, weight2) ] | dst1 == src && connects dst2 dst -> addCost weight1 $ findEndNode (dst, e2)
          [ e1@(dst1, weight1), e2@(dst2, weight2) ] | dst2 == src && connects dst1 dst -> addCost weight2 $ findEndNode (dst, e1)
          _ -> (dst, cost)
        fillNodePath :: Edge -> Edge -> [Edge]
        fillNodePath e1 e2 = [(end1, (end2, cost1 + cost2)), (end2, (end1, cost1 + cost2))]
          where (end1, cost1) = findEndNode e1
                (end2, cost2) = findEndNode e2
        newEdges :: Node -> [Edge]
        newEdges node = case fromJust $ Map.lookup node graph of
          [ e1@(dst1, weight1), e2@(dst2, weight2) ] | connects dst1 node && connects dst2 node -> fillNodePath (node, e1) (node, e2)
          dsts -> map (\dst -> (node, dst)) dsts
        edgeList :: [Edge]
        edgeList = concat $ map newEdges $ Map.keys graph

findPaths :: Graph -> Path -> Node -> [Path]
findPaths graph path dst = case head path of
  last | last == dst -> [path]
  _ -> paths
  where connecting = maybe [] id $ Map.lookup (head path) graph
        valid = concat $ map (\(next, _) -> if next `elem` path then [] else [next]) connecting
        paths = concat $ map (\next -> findPaths graph (next : path) dst) valid

pathWeight :: Graph -> Path -> Int
pathWeight graph [] = 0
pathWeight graph [_] = 0
pathWeight graph (n1 : sp@(n2 : _)) = weight + pathWeight graph sp
  where weight = case Map.lookup n2 graph of
          Nothing -> 0
          Just connects -> case filter (\(dst, _) -> n1 == dst) connects of
            ((_, weight) : _) -> weight
            _ -> 0

main = do
  graph <- (simplifyGraph . convertToGraph . parseArea) <$> getContents
  start <- return (1, 0)
  end <- return (maximum $ map fst $ Map.keys graph, maximum $ map snd $ Map.keys graph)
  putStrLn $ show $ maximum $ map (pathWeight graph) $ findPaths graph [start] end
