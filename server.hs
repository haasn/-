import System.Directory;
import System.Environment;
import System.Exit;
import System.IO;
import System.IO.Temp;
import System.FilePath;

import qualified Data.ByteString.Lazy as LB

-- Be sneaky
die :: IO ()
die = do
    putStrLn "Segmentation fault"
    exitFailure

main :: IO ()
main = do
    setCurrentDirectory =<< fmap (</> "www") getHomeDirectory
    args <- getArgs
    case args of
        [hash, name] -> go hash name
        _ -> die

go :: String -> String -> IO ()
go "true"  _ = withInput smallestHash
go "false" name
    | null name = die
    | otherwise = withInput (tryRename name)
go _ _ = die

withInput :: (FilePath -> IO ()) -> IO ()
withInput callback = withTempFile ".." ".tmp" $ \f h -> do
    LB.hGetContents stdin >>= LB.hPut h
    callback f

smallestHash :: FilePath -> IO ()
smallestHash _ = putStrLn "hash"

tryRename :: String -> FilePath -> IO ()
tryRename n f = putStrLn $ "renaming from " ++ f ++ " to " ++ n
