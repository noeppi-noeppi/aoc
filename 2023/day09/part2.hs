import Data.List

parseLine :: String -> [Int]
parseLine line = map read $ words line

predict :: [Int] -> Int
predict list
  | all (0==) list = 0
  | otherwise = (head list) + (predict $ map (\(a,b)->a-b) (list `zip` (tail list)))

main = do
  lines <- map parseLine <$> lines <$> getContents
  putStrLn $ show $ sum $ map predict lines
