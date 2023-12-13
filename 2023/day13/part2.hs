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

findSymmetryTop :: Table -> Int -> Int
findSymmetryTop table butNot = last $ 0:(filter (/=0) $ filter (/=butNot) $ map (isSymmetricAt table) [1..(length table) - 1])

findSymmetryBot :: Table -> Int -> Int
findSymmetryBot table butNot = findSymmetryTop (reverse table) butNot

findSymmetry :: Table -> Int -> Int
findSymmetry table butNot = if a == b + 1 then a else a
  where a = findSymmetryTop table butNot
        b = findSymmetryBot table butNot

findSymmetries :: Table -> (Int,Int) -> (Int, Int)
findSymmetries table (butNotA, butNotB) = (findSymmetry (transpose table) butNotA, findSymmetry table butNotB)

noOldSymmetries :: (Int, Int) -> (Int, Int) -> (Int, Int)
noOldSymmetries (old1, old2) (new1, new2) = (if old1 == new1 then 0 else new1, if old2 == new2 then 0 else new2)

mergeSymmetries :: (Int,Int) -> Int
mergeSymmetries symmetries = case symmetries of
  (0, a) -> 100 * a
  (a, 0) -> a
  (a, b) -> 0

findSmudgedSymmetries :: Table -> Int
findSmudgedSymmetries table = last $ 0:(filter (/=0) $ map mergeSymmetries $ map (noOldSymmetries old) $ map (\t->findSymmetries t old) $ smudges table) where old = findSymmetries table (-1,-1)

lineSmudges :: (a -> [a]) -> [a] -> [[a]]
lineSmudges flip list = concat $ map (\chi->map (\new->(take chi list) ++ [new] ++ (drop (chi+1) list)) (flip $ list!!chi)) [0..(length list) - 1]

smudges :: Table -> [Table]
smudges table = lineSmudges (\line -> lineSmudges ((:[]) . not) line) table

main = do
  tables <- readTables
  putStrLn $ show $ sum $ map findSmudgedSymmetries tables
