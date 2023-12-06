parseLine :: String -> Int
parseLine line = read $ filter (' '/=) $ drop 9 line

distance :: Int -> Int -> Int
distance time press = (time - press) * press

waysToBeatRecord :: Int -> Int -> Int
waysToBeatRecord time record = length $ filter (>record) $ map (distance time) [0..time]

main = do
  time <- fmap parseLine getLine
  distance <- fmap parseLine getLine
  putStrLn $ show $ waysToBeatRecord time distance
