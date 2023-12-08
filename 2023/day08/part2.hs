import Data.List
import qualified Data.Map as Map

type RLMap = Map.Map String (String, String)
data Cycle = Cycle { cycleStart :: Int, cycleLength :: Int } deriving Show

readMap :: RLMap -> IO RLMap
readMap rlmap = do
  line <- getLine
  if line == "" then return rlmap else readMap $ Map.insert (reverse $ take 3 line) (reverse $ take 3 $ drop 7 line, reverse $ take 3 $ drop 12 line) rlmap

incrCycle :: Cycle -> Cycle
incrCycle cycle = Cycle ((1+) $ cycleStart cycle) (cycleLength cycle)

getDir :: Char -> (String, String) -> String
getDir dir entry
  | dir == 'L' = fst entry
  | otherwise  = snd entry

stepPath :: RLMap -> Char -> String -> String 
stepPath rlmap dir path = getDir dir $ Map.findWithDefault ("ZZZ", "ZZZ") path rlmap

minimalCycle :: RLMap -> String -> String -> Int
minimalCycle rlmap dirs pos
  | (head pos) == 'Z' = 1
  | otherwise = (1+) $ minimalCycle rlmap (tail dirs) (stepPath rlmap (head dirs) pos)

findCycle :: RLMap -> String -> String -> Cycle
findCycle rlmap dirs pos
  | (head pos) == 'Z' = Cycle 0 (minimalCycle rlmap (tail dirs) (stepPath rlmap (head dirs) pos))
  | otherwise = incrCycle $ findCycle rlmap (tail dirs) (stepPath rlmap (head dirs) pos)

main = do
  dirs <- cycle <$> getLine
  _ <- getLine
  rlmap <- readMap Map.empty
  putStrLn $ show $ foldl lcm 1 $ map (cycleLength) $ map (findCycle rlmap dirs) $ filter (\p -> (head p) == 'A') (Map.keys rlmap)
