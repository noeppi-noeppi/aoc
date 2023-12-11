import Data.Maybe

data Position = Position { getX :: Integer, getY :: Integer } deriving (Eq, Ord, Show)
data Pixel = Empty | Galaxy deriving (Eq, Show)
type Image = [Position]

parseImage :: String -> Image
parseImage input = concat $ concat $ map (\(y,s) -> map (\(x,c) -> if c == '#' then [Position x y] else []) ([0..] `zip` s)) ([0..] `zip` lines input)

moveRight :: Position -> Position
moveRight Position{getX = x, getY = y} = Position (x+999999) y
moveDown Position{getX = x, getY = y} = Position x (y+999999)

expandLine :: (Position -> Integer) -> (Position -> Position) -> Image -> Integer -> Image
expandLine coordinate move image lineIdx = map (\pos -> if (coordinate pos > lineIdx) then move pos else pos) image

maybeExpandLine :: (Position -> Integer) -> (Position -> Position) -> Image -> Integer -> Image
maybeExpandLine coordinate move image lineIdx = if (filter (lineIdx==) $ map coordinate image) == [] then expandLine coordinate move image lineIdx else image

expandImageBy :: (Position -> Integer) -> (Position -> Position) -> Image -> Image
expandImageBy coordinate move image = foldl (maybeExpandLine coordinate move) image $ reverse [0..(maximum $ map coordinate image)]

expandImage :: Image -> Image
expandImage image = expandImageBy getX moveRight $ expandImageBy getY moveDown image

distance :: Position -> Position -> Integer
distance Position{getX = x1, getY = y1} Position{getX = x2, getY = y2} = abs(x2 - x1) + abs(y2 - y1)

main = do
  telescopeImage <- parseImage <$> getContents
  realImage <- return $ expandImage telescopeImage
  putStrLn $ show $ (`div` 2) $ sum [distance a b | a <- realImage, b <- realImage]
