import Data.List
import Data.Char

type Vector = (Float, Float, Float)
type Hailstone = (Vector, Vector)

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

intersectHail :: (Hailstone, Hailstone) -> Bool
intersectHail (((cx1, cy1, _), (x1, y1, _)), ((cx2, cy2, _), (x2, y2, _))) = det /= 0 && future && bounded 
  where det = x2 * y1 - x1 * y2
        cx = cx2 - cx1
        cy = cy2 - cy1
        s1 = (cy * x2 - cx * y2) / det
        s2 = (cy * x1 - cx * y1) / det
        at1 = cx1 + s1 * x1
        at2 = cy1 + s1 * y1
        future = s1 > 0 && s2 > 0
        bounded = at1 >= 200000000000000 && at2 >= 200000000000000 && at1 <= 400000000000000 && at2 <= 400000000000000

main = do
  hailstones <- map parseHailstone <$> lines <$> getContents
  putStrLn $ show $ (length $ filter intersectHail [(h1, h2) | h1 <- hailstones, h2 <- hailstones]) `div` 2