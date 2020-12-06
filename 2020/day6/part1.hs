import Data.List

main = do
    input <- getContents
    putStrLn (show (act input))

nonEmpty a b = not (null a) && not (null b)
join list = foldr (\a b -> a ++ b) "" list

act :: String -> Int
act input = sum (map (length . nub . join) (filter (not . any null) (groupBy nonEmpty (lines input))))