import Data.List

type Table = [[Bool]]

readTable :: IO Table
readTable = do
  line <- map ('#'==) <$> getLine
  if null line then return [] else readTable >>= return . (line:)

readTables :: IO [Table]
readTables = do
  table <- readTable
  if null table then return [] else readTables >>= return . (table:)

isSymmetricAt :: Table -> Int -> Int
isSymmetricAt table at = if all (\(a,b)->a==b) (drop at table `zip` (reverse $ take at table)) then at else 0

findSymmetry :: Table -> Int
findSymmetry table = last $ 0:(filter (/=0) $ map (isSymmetricAt table) [1..(length table) - 1])

findSymmetries :: Table -> Int
findSymmetries table = (findSymmetry $ transpose table) + 100 * (findSymmetry table)

main = do
  tables <- readTables
  putStrLn $ show $ sum $ map findSymmetries tables
