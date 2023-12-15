import Data.Char
import qualified Data.Text as Text

data Entry = Entry { getHash :: Int, getLabel :: String, getOperation :: Char, getOpNumber :: Int } deriving Show
type Lens = (String, Int)
type Box = [Lens]
type Boxes = [Box]

splitAtComma :: String -> [String]
splitAtComma string = (map Text.unpack $ Text.splitOn (Text.pack ",") (Text.pack $ filter ('\n'/=) string))

readOpNumber :: String -> Int
readOpNumber string = case tail $ dropWhile (\c -> c /= '=' && c /= '-') string of
  "" -> 0
  num -> read num

parseEntry :: String -> Entry
parseEntry string = Entry (hash 0 label) label (head $ dropWhile (\c -> c /= '=' && c /= '-') string) (readOpNumber string) where label = takeWhile (\c -> c /= '=' && c /= '-') string

hash :: Int -> String -> Int
hash c "" = c
hash c string = hash ((((+) c $ ord $ head string) * 17) `mod` 256) (tail string)

setBox :: Boxes -> Int -> (Box -> Box) -> Boxes
setBox boxes at func = (take at boxes) ++ ((func $ boxes!!at):(drop (at+1) boxes))

insertInto :: Lens -> Box -> Box 
insertInto lens box = if rep then newboxes else lens:box where (newboxes, rep) = foldr (\l (nl, r) -> if (fst l) == (fst lens) then (lens:nl, True) else (l:nl, r)) ([], False) box

applyToDash :: Boxes -> Entry -> Boxes
applyToDash boxes entry = setBox boxes (getHash entry) $ filter (\lens -> (fst lens) /= label) where label = getLabel entry

applyToEq :: Boxes -> Entry -> Boxes
applyToEq boxes entry = setBox boxes (getHash entry) (insertInto (getLabel entry, getOpNumber entry))

applyTo :: Boxes -> Entry -> Boxes
applyTo boxes entry = case getOperation entry of
  '-' -> applyToDash boxes entry
  '=' -> applyToEq boxes entry


countFociBox :: Box -> Int
countFociBox box = sum $ map (\(a,b)->a*b) ([1..] `zip` (map snd $ reverse box))

countFoci :: Boxes -> Int
countFoci boxes = sum $ map (\(a,b)->a*b) ([1..] `zip` (map countFociBox boxes))

main = do
  entries <- map parseEntry <$> splitAtComma <$> getContents
  boxes <- return $ foldl applyTo (take 256 $ repeat []) entries
  putStrLn $ show $ countFoci boxes