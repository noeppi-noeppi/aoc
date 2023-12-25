import Data.List
import Data.Char
import qualified Data.Text as Text
import qualified System.Random as Rnd

type Vertex = (String, Int)
type Edge = (Vertex, Vertex)

splitLine :: String -> String -> [String]
splitLine splitStr line = map Text.unpack $ Text.splitOn (Text.pack splitStr) (Text.pack $ line)

parseEdges :: String -> [Edge]
parseEdges line = map (\second -> ((first, 1), (second, 1))) others
  where first = takeWhile (/=':') line
        others = splitLine " " $ tail $ tail $ dropWhile (/=':') line

contract :: [Edge] -> Vertex -> Vertex -> [Edge]
contract edges a b = map newEdge $ filter keepEdge edges
  where keepEdge :: Edge -> Bool
        keepEdge (x, y) = (x /= a || y /= b) && (x /= b || y /= a)
        newEdge :: Edge -> Edge
        newEdge e@(x, y)
          | x == a || x == b = (newVertex, y)
          | y == a || y == b = (x, newVertex)
          | otherwise = e
          where newVertex = (fst a, (snd a) + (snd b))

contractAll :: [Edge] -> Rnd.StdGen -> [Edge]
contractAll edges random = case edges of
  [] -> []
  [_] -> edges
  [_, _] -> edges
  [_, _, _] -> edges
  _ -> contractAll (contract edges start end) next
  where edgeLen = length edges
        (ce, next) = Rnd.randomR (0, edgeLen - 1) random
        (start, end) = edges!!ce

validContraction :: [Edge] -> Bool
validContraction [(a1, b1), (a2, b2), (a3, b3)] | a1 == a2 && a2 == a3 && b1 == b2 && b2 == b3 = True
validContraction [(a1, b1), (a2, b2), (a3, b3)] | b1 == a2 && a2 == a3 && a1 == b2 && b2 == b3 = True
validContraction [(a1, b1), (a2, b2), (a3, b3)] | a1 == b2 && b2 == a3 && b1 == a2 && a2 == b3 = True
validContraction [(a1, b1), (a2, b2), (a3, b3)] | a1 == a2 && a2 == b3 && b1 == b2 && b2 == a3 = True
validContraction _ = False

main = do
  edges <- concat <$> map parseEdges <$> lines <$> getContents
  contraction <- return $ head $ filter validContraction $ map (contractAll edges) $ map Rnd.mkStdGen [13370..]
  putStrLn $ show $ (snd $ fst $ head $ contraction) * (snd $ snd $ head $ contraction)
