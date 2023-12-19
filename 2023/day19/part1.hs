import Data.Char
import Data.List
import Data.Maybe
import qualified Data.Text as Text
import qualified Data.Map as Map

splitLine :: String -> String -> [String]
splitLine splitStr line = map Text.unpack $ Text.splitOn (Text.pack splitStr) (Text.pack $ line)

type XMAS = (Int, Int, Int, Int)
data State = Accept | Reject | Defer (String) deriving Show
type RuleMap = Map.Map String (XMAS -> State)

parseState :: String -> State
parseState "A" = Accept
parseState "R" = Reject
parseState string = Defer string

parseStateFilter :: Char -> Char -> Int -> XMAS -> Bool
parseStateFilter 'x' '<' t (x, m, a, s) = x < t
parseStateFilter 'm' '<' t (x, m, a, s) = m < t
parseStateFilter 'a' '<' t (x, m, a, s) = a < t
parseStateFilter 's' '<' t (x, m, a, s) = s < t
parseStateFilter 'x' '>' t (x, m, a, s) = x > t
parseStateFilter 'm' '>' t (x, m, a, s) = m > t
parseStateFilter 'a' '>' t (x, m, a, s) = a > t
parseStateFilter 's' '>' t (x, m, a, s) = s > t

parseGuardedStateFunction :: String -> XMAS -> Maybe State
parseGuardedStateFunction line = (\xmas -> if filter xmas then result else Nothing)
  where filter = parseStateFilter (head line) (head $ tail line) (read $ takeWhile (/=':') $ tail $ tail line)
        result = Just $ parseState $ tail $ dropWhile (/=':') line

parseSimpleStateFunction :: String -> XMAS -> Maybe State
parseSimpleStateFunction line = (\xmas -> result)
  where result = Just $ parseState line

parsePartialStateFunction :: String -> XMAS -> Maybe State
parsePartialStateFunction line
  | ':' `elem` line = parseGuardedStateFunction line
  | otherwise = parseSimpleStateFunction line

join :: (XMAS -> Maybe State) -> (XMAS -> Maybe State) -> XMAS -> Maybe State
join fa fb xmas = case fa xmas of
  Just state -> Just state
  Nothing -> fb xmas

parseStateFunction :: String -> XMAS -> State
parseStateFunction line = \xmas -> case function xmas of
  Just result -> result
  Nothing -> Reject
  where partials = map parsePartialStateFunction $ splitLine "," line
        function = foldl join (\_ -> Nothing) partials

parseRule :: String -> (String, XMAS -> State)
parseRule line = (takeWhile (/='{') line, parseStateFunction $ takeWhile (/='}') $ tail $ dropWhile (/='{') line)

parseRuleMap :: [String] -> RuleMap
parseRuleMap lines = Map.fromList $ map parseRule lines

parseXMAS :: String -> XMAS 
parseXMAS line = (
  read $ takeWhile isDigit $ dropWhile (not . isDigit) line,
  read $ takeWhile isDigit $ dropWhile (not . isDigit) $ dropWhile isDigit $ dropWhile (not . isDigit) line,
  read $ takeWhile isDigit $ dropWhile (not . isDigit) $ dropWhile isDigit $ dropWhile (not . isDigit) $ dropWhile isDigit $ dropWhile (not . isDigit) line,
  read $ takeWhile isDigit $ dropWhile (not . isDigit) $ dropWhile isDigit $ dropWhile (not . isDigit) $ dropWhile isDigit $ dropWhile (not . isDigit) $ dropWhile isDigit $ dropWhile (not . isDigit) line)

acceptedBy :: RuleMap -> String -> XMAS -> Bool
acceptedBy ruleMap rule xmas = case (fromJust $ Map.lookup rule ruleMap) xmas of
  Accept -> True
  Reject -> False
  Defer newRule -> acceptedBy ruleMap newRule xmas

accepts :: RuleMap -> XMAS -> Bool
accepts ruleMap xmas = acceptedBy ruleMap "in" xmas

sumUp :: XMAS -> Int
sumUp (x, m, a, s) = x + m + a + s

main = do
  lines <- lines <$> getContents
  (ruleLines, xmasLines) <- return $ splitAt (fromJust $ elemIndex "" lines) lines
  ruleMap <- return $ parseRuleMap ruleLines
  xmas <- return $ map parseXMAS $ tail xmasLines
  accepted <- return $ filter (accepts ruleMap) xmas
  putStrLn $ show $ sum $ map sumUp accepted
