import Data.Char
import Data.List
import Data.Maybe
import qualified Data.Text as Text
import qualified Data.Map as Map

splitLine :: String -> String -> [String]
splitLine splitStr line = map Text.unpack $ Text.splitOn (Text.pack splitStr) (Text.pack $ line)

type Bound = (Int, Int)
type Bounds = (Bound, Bound, Bound, Bound)
data XMAS = Never | Bounded Bounds | Split XMAS XMAS deriving Show
data State = Accept | Reject | Defer String deriving Show
type LineMap = Map.Map String String

empty :: Bounds
empty = ((0, -1), (0, -1), (0, -1), (0, -1))

full :: Bounds
full = ((1, 4000), (1, 4000), (1, 4000), (1, 4000))

parseState :: String -> State
parseState "A" = Accept
parseState "R" = Reject
parseState string = Defer string

parseStateFilter :: Char -> Char -> Int -> Bounds -> (Bounds, Bounds)
parseStateFilter 'x' '<' t ((lo, hi), m, a, s) = (((lo, t - 1), m ,a, s), ((t, hi), m, a, s))
parseStateFilter 'm' '<' t (x, (lo, hi), a, s) = ((x, (lo, t - 1) ,a, s), (x, (t, hi), a, s))
parseStateFilter 'a' '<' t (x, m, (lo, hi), s) = ((x, m, (lo, t - 1), s), (x, m, (t, hi), s))
parseStateFilter 's' '<' t (x, m, a, (lo, hi)) = ((x, m, a, (lo, t - 1)), (x, m, a, (t, hi)))
parseStateFilter 'x' '>' t ((lo, hi), m, a, s) = (((t + 1, hi), m ,a, s), ((lo, t), m, a, s))
parseStateFilter 'm' '>' t (x, (lo, hi), a, s) = ((x, (t + 1, hi), a, s), (x, (lo, t), a, s))
parseStateFilter 'a' '>' t (x, m, (lo, hi), s) = ((x, m, (t + 1, hi), s), (x, m, (lo, t), s))
parseStateFilter 's' '>' t (x, m, a, (lo, hi)) = ((x, m, a, (t + 1, hi)), (x, m, a, (lo, t)))

parseGuardedStateFunction :: LineMap -> String -> Bounds -> (XMAS, Bounds)
parseGuardedStateFunction lineMap line bounds = case result of
  Accept -> (Bounded inside, outside)
  Reject -> (Never, outside)
  Defer next -> (query lineMap next inside, outside)
  where (inside, outside) = parseStateFilter (head line) (head $ tail line) (read $ takeWhile (/=':') $ tail $ tail line) bounds
        result = parseState $ tail $ dropWhile (/=':') line

parseSimpleStateFunction :: LineMap -> String -> Bounds -> (XMAS, Bounds)
parseSimpleStateFunction lineMap line bounds = case parseState line of
  Accept -> (Bounded bounds, empty)
  Reject -> (Never, empty)
  Defer next -> (query lineMap next bounds, empty)

parsePartialStateFunction :: LineMap -> String -> Bounds -> (XMAS, Bounds)
parsePartialStateFunction lineMap line
  | ':' `elem` line = parseGuardedStateFunction lineMap line
  | otherwise = parseSimpleStateFunction lineMap line

join :: (Bounds -> (XMAS, Bounds)) -> (Bounds -> (XMAS, Bounds)) -> Bounds -> (XMAS, Bounds)
join fa fb bounds = (Split xmasA xmasB, outsideB)
  where (xmasA, outsideA) = fa bounds
        (xmasB, outsideB) = fb outsideA

parseStateFunction :: LineMap -> String -> Bounds -> XMAS
parseStateFunction lineMap line bounds = xmas
  where partials = map (parsePartialStateFunction lineMap) $ splitLine "," line
        (xmas, _) = (foldl1 join partials) bounds

query :: LineMap -> String -> Bounds -> XMAS
query lineMap rule bounds = parseStateFunction lineMap (fromJust $ Map.lookup rule lineMap) bounds

parseLine :: String -> (String, String)
parseLine line = (takeWhile (/='{') line, takeWhile (/='}') $ tail $ dropWhile (/='{') line)

parseLineMap :: [String] -> LineMap
parseLineMap lines = Map.fromList $ map parseLine lines

count :: XMAS -> Int
count Never = 0
count (Split xmas1 xmas2) = (count xmas1) + (count xmas2)
count (Bounded ((xl, xh), (ml, mh), (al, ah), (sl, sh))) = x * m * a * s
  where x = max 0 $ xh - xl + 1
        m = max 0 $ mh - ml + 1
        a = max 0 $ ah - al + 1
        s = max 0 $ sh - sl + 1

main = do
  lines <- lines <$> getContents
  (ruleLines, _) <- return $ splitAt (fromJust $ elemIndex "" lines) lines
  lineMap <- return $ parseLineMap ruleLines
  putStrLn $ show $ count $ query lineMap "in" full
