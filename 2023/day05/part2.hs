import Data.List

data Range = Range { rangeStart :: Int, rangeEnd :: Int } deriving Show
data Entry = Entry { entrySource :: Int, entryTarget :: Int, entryLen :: Int } deriving Show

isInRange :: Range -> Int -> Bool
isInRange range num = (num >= rangeStart range) && (num < rangeEnd range)

isInSource :: Int -> Entry -> Bool
isInSource num entry = (num >= entrySource entry) && (num < (entrySource entry) + (entryLen entry))

isNonEmptyRange :: Range -> Bool
isNonEmptyRange range = rangeStart range < rangeEnd range

findEntry :: [Entry] -> Int -> Int
findEntry entries num = case find (isInSource num) entries of
  Just(entry) -> num - (entrySource entry) + (entryTarget entry)
  Nothing -> num

findRange :: [Entry] -> Range -> Range
findRange entries range = Range (findEntry entries $ rangeStart range) (1 + (findEntry entries $ (rangeEnd range - 1)))

findBorders :: [Entry] -> Range -> [Int]
findBorders entries range = sort $ filter (isInRange range) $ concat $ map (\entry -> [entrySource entry, entrySource entry + entryLen entry]) entries

data SubRange = SubRange { allRanges :: [Range], currentIndex :: Int }
mergeSubRange :: SubRange -> Int -> SubRange
mergeSubRange sr num = SubRange ((Range (currentIndex sr) num) : allRanges sr) num

findSubRanges :: [Entry] -> Range -> [Range]
findSubRanges entries range = allRanges $ foldl mergeSubRange (SubRange [] (rangeStart range)) ((findBorders entries range) ++ [rangeEnd range])

findEntries :: [Entry] -> [Range] -> [Range]
findEntries entries ranges = map (findRange entries) $ filter isNonEmptyRange $ concat $ map (findSubRanges entries) ranges

parseSeedList :: () -> IO [Int]
parseSeedList () = map read <$> words <$> (drop 6) <$> getLine

parseSeeds :: [Int] -> [Range]
parseSeeds seedList = map (\i -> Range (seedList!!(2*i)) ((seedList!!(2*i)) + (seedList!!((2*i)+1)))) [0..(length seedList) `div` 2 - 1]

parseEntry :: [String] -> Entry
parseEntry parts = Entry (read $ parts!!1) (read $ parts!!0) (read $ parts!!2)

parseTable :: () -> IO [Entry]
parseTable entries = do
  line <- getLine
  case line of
    "" -> return []
    line -> (:) (parseEntry $ words line) <$> parseTable ()

main = do
  seeds <- fmap parseSeeds $ parseSeedList ()
  _ <- getLine
  _ <- getLine
  t1 <- fmap findEntries $ parseTable ()
  _ <- getLine
  t2 <- fmap findEntries $ parseTable ()
  _ <- getLine
  x3 <- parseTable ()
  t3 <- fmap findEntries $ return x3
  _ <- getLine
  t4 <- fmap findEntries $ parseTable ()
  _ <- getLine
  t5 <- fmap findEntries $ parseTable ()
  _ <- getLine
  t6 <- fmap findEntries $ parseTable ()
  _ <- getLine
  t7 <- fmap findEntries $ parseTable ()
  putStrLn $ show $ minimum $ concat $ map (\r -> [rangeStart r, rangeEnd r]) $ (t7 . t6 . t5 . t4 . t3 . t2 . t1) seeds
