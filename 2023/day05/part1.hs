import Data.List

data Entry = Entry { entrySource :: Int, entryTarget :: Int, entryLen :: Int } deriving Show

isInSource :: Int -> Entry -> Bool
isInSource num entry = (num >= entrySource entry) && (num < (entrySource entry) + (entryLen entry))

findEntry :: [Entry] -> Int -> Int
findEntry entries num = case find (isInSource num) entries of
  Just(entry) -> num - (entrySource entry) + (entryTarget entry)
  Nothing -> num

parseSeeds :: () -> IO [Int]
parseSeeds () = map read <$> words <$> (drop 6) <$> getLine

parseEntry :: [String] -> Entry
parseEntry parts = Entry (read $ parts!!1) (read $ parts!!0) (read $ parts!!2)

parseTable :: () -> IO [Entry]
parseTable entries = do
  line <- getLine
  case line of
    "" -> return []
    line -> (:) (parseEntry $ words line) <$> parseTable ()

main = do
  seeds <- parseSeeds ()
  _ <- getLine
  _ <- getLine
  t1 <- fmap findEntry $ parseTable ()
  _ <- getLine
  t2 <- fmap findEntry $ parseTable ()
  _ <- getLine
  t3 <- fmap findEntry $ parseTable ()
  _ <- getLine
  t4 <- fmap findEntry $ parseTable ()
  _ <- getLine
  t5 <- fmap findEntry $ parseTable ()
  _ <- getLine
  t6 <- fmap findEntry $ parseTable ()
  _ <- getLine
  t7 <- fmap findEntry $ parseTable ()
  putStrLn $ show $ minimum $ map (t7 . t6 . t5 . t4 . t3 . t2 . t1) seeds
