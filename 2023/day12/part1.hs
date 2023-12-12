import qualified Data.Text as Text

data SpringState = Broken | Functional | Unknown deriving (Eq,Show)
data SpringStates = SpringStates { getStateList :: [SpringState], getStateGroups :: [Int] } deriving Show

parseSpringState :: Char -> SpringState
parseSpringState '#' = Broken
parseSpringState '.' = Functional
parseSpringState '?' = Unknown

parseSpringStates :: String -> SpringStates
parseSpringStates line = SpringStates (map parseSpringState $ (words line)!!0) (map (read . Text.unpack) $ Text.splitOn (Text.pack ",") (Text.pack $ (words line)!!1))

checkState :: [SpringState] -> SpringState -> Int -> Bool
checkState states notState count = ((length states) >= count) && (null $ filter (notState==) $ take count states)

checkBrokenGroup :: [SpringState] -> Int -> Bool
checkBrokenGroup states count = (checkState states Functional count) && ((null $ drop count states) || (checkState (drop count states) Broken 1))

countCombinations :: [SpringState] -> [Int] -> Int
countCombinations states groups = if null states then fromEnum $ null groups else case head states of
  Functional -> countCombinations (tail states) groups
  Broken | null groups -> 0
  Broken | checkBrokenGroup states $ head groups -> countCombinations (drop (1 + head groups) states) (tail groups)
  Broken -> 0
  Unknown -> (countCombinations (Functional : tail states) groups) + (countCombinations (Broken : tail states) groups)
  
springCombinations :: SpringStates -> Int
springCombinations SpringStates{ getStateList=states, getStateGroups=groups } = countCombinations states groups

main = do
  states <- map parseSpringStates <$> lines <$> getContents
  putStrLn $ show $ sum $ map springCombinations states