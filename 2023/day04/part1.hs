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

worth :: Scratchcard -> Int
worth card = case intersect (cardWinning card) (cardOwn card) of
  0 -> 0
  n -> 2 ^ (n-1)

act :: String -> Int
act content = sum $ map (worth . parseScratchcard) (lines content)

main = do
  content <- getContents
  putStrLn $ show $ act content
