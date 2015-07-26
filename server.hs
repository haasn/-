import Control.Exception;

import System.Directory;
import System.Environment;
import System.Exit;
import System.IO;
import System.IO.Temp;
import System.FilePath;
import System.Posix.User;
import System.Posix.Files;

import qualified Data.ByteString.Lazy as LB

-- Be sneaky
die :: IO ()
die = do
    putStrLn "Segmentation fault"
    exitFailure

putURL :: String -> IO ()
putURL name = do
    user <- getLoginName
    putStrLn $ "https://☃.valk.nand.wakku.to/~" ++ user ++ "/" ++ name

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
    | otherwise = withInput $ \f -> do
                    res <- trySave f name
                    case res of
                        Left e  -> print e >> die
                        Right _ -> putURL name
go _ _ = die

withInput :: (FilePath -> IO ()) -> IO ()
withInput callback = withTempFile ".." ".tmp" $ \f h -> do
    hSetBinaryMode h True
    LB.hGetContents stdin >>= LB.hPut h
    hClose h
    callback f

smallestHash :: FilePath -> IO ()
smallestHash _ = putStrLn "hash"

trySave :: FilePath -> FilePath -> IO (Either IOException ())
trySave f n = try $ do
    renameFile f n
    setFileMode n 0o444
