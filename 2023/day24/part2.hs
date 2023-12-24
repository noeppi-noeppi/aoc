import Data.Char
import Data.List
import Data.Maybe

type Vector = (Int, Int, Int)
type Hailstone = (Vector, Vector)
data ModuloRule = ModuloRule { divisor :: Int, residue :: Int } deriving (Eq,Show)

instance Ord ModuloRule where
  compare ModuloRule { divisor=d1, residue=r1 } ModuloRule { divisor=d2, residue=r2 } = case d2 `compare` d1 of
    EQ -> r2 `compare` r1
    cmp -> cmp

isNumberChar :: Char -> Bool
isNumberChar ' ' = True
isNumberChar '-' = True
isNumberChar chr = isDigit chr

parseVector :: String -> Vector
parseVector string = (read x, read y, read z)
  where x = takeWhile isNumberChar string
        y = takeWhile isNumberChar $ dropWhile (not . isNumberChar) $ dropWhile isNumberChar string
        z = takeWhile isNumberChar $ dropWhile (not . isNumberChar) $ dropWhile isNumberChar $ dropWhile (not . isNumberChar) $ dropWhile isNumberChar string

parseHailstone :: String -> Hailstone
parseHailstone string = (parseVector pos, parseVector velocity)
  where pos = takeWhile (/='@') string
        velocity = tail $ dropWhile (/='@') string

compact :: Hailstone -> (Int, Int)
compact ((x1, x2, x3), (y1, y2, y3)) = (x1 + x2 + x3, y1 + y2 + y3)

rules :: [(Int, Int)] -> Int -> [ModuloRule]
rules compact dsum = map (\(v, dv) -> ModuloRule (abs $ dsum - dv) (if dsum == dv then 0 else v `mod` (abs $ dsum - dv))) compact

findModuloLcm :: Int -> Int -> Int -> Int -> Int
findModuloLcm a b r1 r2 = modulo r2
  where ndiv = lcm a b
        modulo :: Int -> Int
        modulo x
          | x `mod` a == r1 = x
          | x > ndiv = error $ "findModuloLcm with incompatible residues: " ++ (show (a, b, r1, r2))
          | otherwise = modulo $ x + b

combine :: [ModuloRule] -> Maybe ModuloRule
combine [] = Just $ ModuloRule 1 0
combine (ModuloRule { divisor=d1, residue=r1 } : xs) = if d1 == 0 then Nothing else case combine xs of
  Nothing -> Nothing
  Just (ModuloRule { divisor=d2, residue=r2 }) -> if (mod r1 $ gcd d1 d2) /= (mod r2 $ gcd d1 d2) then Nothing else Just $ ModuloRule (lcm d1 d2) (findModuloLcm d1 d2 r1 r2)

main = do
  hailstones <- map (compact . parseHailstone) <$> lines <$> getContents
  putStrLn $ show $ residue $ fromJust $ head $ filter isJust $ map (combine . sort . rules hailstones) [0..]
