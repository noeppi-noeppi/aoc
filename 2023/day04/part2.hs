import Data.Char

data Scratchcard = Scratchcard { cardNumber :: Int, cardWinning :: [Int], cardOwn :: [Int] } deriving Show

parseScratchcardNumber :: String -> Int
parseScratchcardNumber line = read $ takeWhile isDigit (drop 5 line)

parseScratchcardWinning :: String -> [Int]
parseScratchcardWinning line = map read $ words $ takeWhile ('|' /=) $ tail $ dropWhile (':' /=) line

parseScratchcardOwn :: String -> [Int]
parseScratchcardOwn line = map read $ words $ tail $ dropWhile ('|' /=) line

parseScratchcard :: String -> Scratchcard
parseScratchcard line = Scratchcard (parseScratchcardNumber line) (parseScratchcardWinning line) (parseScratchcardOwn line)

intersect :: Eq a => [a] -> [a] -> Int
intersect l1 l2 = foldr (\n s -> s + (fromEnum $ n `elem` l2)) 0 l1

worth :: [Scratchcard] -> Int -> Int
worth cards card = (1+) $ sum $ map (\i -> worth cards (card + i)) [1..intersect (cardWinning $ cards!!card) (cardOwn $ cards!!card)]

allWorth :: [Scratchcard] -> Int
allWorth cards = sum $ map (worth cards) $ take (length cards) [0..]

act :: String -> Int
act content = allWorth $ map parseScratchcard (lines content)

main = do
  content <- getContents
  putStrLn $ show $ act content
