import qualified Data.Text as Text
import qualified Data.Map as Map

data SpringState = Broken | Functional | Unknown deriving (Eq,Ord,Show)
data SpringStates = SpringStates { getStateList :: [SpringState], getStateGroups :: [Int] } deriving Show
type CountMap = Map.Map ([SpringState], [Int]) Int

parseSpringState :: Char -> SpringState
parseSpringState '#' = Broken
parseSpringState '.' = Functional
parseSpringState '?' = Unknown

parseSpringStates :: String -> SpringStates
parseSpringStates line = SpringStates (map parseSpringState $ (words line)!!0) (map (read . Text.unpack) $ Text.splitOn (Text.pack ",") (Text.pack $ (words line)!!1))

unfold :: SpringStates -> SpringStates
unfold SpringStates{ getStateList=states, getStateGroups=groups } = SpringStates (states ++ (Unknown : states) ++ (Unknown : states) ++ (Unknown : states) ++ (Unknown : states)) (groups ++ groups ++ groups ++ groups ++ groups)

checkState :: [SpringState] -> SpringState -> Int -> Bool
checkState states notState count = ((length states) >= count) && (null $ filter (notState==) $ take count states)

checkBrokenGroup :: [SpringState] -> Int -> Bool
checkBrokenGroup states count = (checkState states Functional count) && ((null $ drop count states) || (checkState (drop count states) Broken 1))

countCombinations :: CountMap -> [SpringState] -> [Int] -> (CountMap, Int)
countCombinations map states groups = case Map.lookup (states, groups) map of
  Just result -> (map, result)
  Nothing ->  insertInto (states, groups) $ doCountCombinations map states groups

insertInto :: ([SpringState], [Int]) -> (CountMap, Int) -> (CountMap, Int)
insertInto key (map, value) = (Map.insert key value map, value)

doCountCombinations :: CountMap -> [SpringState] -> [Int] -> (CountMap, Int)
doCountCombinations map states groups = if null states then (map, fromEnum $ null groups) else case head states of
  Functional -> countCombinations map (tail states) groups
  Broken | null groups -> (map, 0)
  Broken | checkBrokenGroup states $ head groups -> countCombinations map (drop (1 + head groups) states) (tail groups)
  Broken -> (map, 0)
  Unknown -> (map2, count1 + count2)
    where (map1, count1) = countCombinations map (Functional : tail states) groups
          (map2, count2) = countCombinations map1 (Broken : tail states) groups

springCombinations :: CountMap -> SpringStates -> (CountMap, Int)
springCombinations map SpringStates{ getStateList=states, getStateGroups=groups } = countCombinations map states groups

foldCombinations :: (CountMap, Int) -> SpringStates -> (CountMap, Int)
foldCombinations (map, sum) states = case springCombinations map states of
  (newmap, result) -> (newmap, sum + result)

main = do
  states <- map (unfold . parseSpringStates) <$> lines <$> getContents
  allCombinations <- return $ foldl foldCombinations (Map.empty, 0) states
  putStrLn $ show $ snd allCombinations