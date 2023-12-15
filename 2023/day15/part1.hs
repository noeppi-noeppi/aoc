import Data.Char
import qualified Data.Text as Text

splitAtComma :: String -> [String]
splitAtComma string = (map Text.unpack $ Text.splitOn (Text.pack ",") (Text.pack $ filter ('\n'/=) string))

hash :: Int -> String -> Int
hash c "" = c
hash c string = hash ((((+) c $ ord $ head string) * 17) `mod` 256) (tail string)


main = do
  parts <- splitAtComma <$> getContents
  putStrLn $ show $ sum $ map (hash 0) parts