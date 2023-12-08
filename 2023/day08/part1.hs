import qualified Data.Map as Map

type RLMap = Map.Map String (String, String)

readMap :: RLMap -> IO RLMap
readMap rlmap = do
  line <- getLine
  if line == "" then return rlmap else readMap $ Map.insert (take 3 line) (take 3 $ drop 7 line, take 3 $ drop 12 line) rlmap

getDir :: Char -> (String, String) -> String
getDir dir entry
  | dir == 'L' = fst entry
  | otherwise  = snd entry

countPath :: RLMap -> String -> String -> Int
countPath rlmap dirs pos
  | pos == "ZZZ" = 0
  | otherwise    = (1+) $ countPath rlmap (tail dirs) (getDir (head dirs) $ Map.findWithDefault ("ZZZ", "ZZZ") pos rlmap)

main = do
  dirs <- cycle <$> getLine
  _ <- getLine
  rlmap <- readMap Map.empty
  putStrLn $ show $ countPath rlmap dirs "AAA"
