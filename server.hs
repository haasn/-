import Control.Exception;

import System.Directory;
import System.Environment;
import System.Exit hiding (die);
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
    putStrLn $ "http://☃.valk.nand.wakku.to/~" ++ user ++ "/" ++ name

main :: IO ()
main = do
    setCurrentDirectory =<< fmap (</> "www") getHomeDirectory
    args <- getArgs
    case args of
        [hash, name] -> catch (go hash name) $ \e -> do
                            print (e :: IOException)
                            die
        _ -> die

go :: String -> String -> IO ()
go "true"  _ = withTempInput smallestHash
go "false" name
    | null name = die
    | otherwise = do LB.hGetContents stdin >>= LB.writeFile name
                     setFileMode name 0o444
                     putURL name
go _ _ = die

withTempInput :: (FilePath -> IO ()) -> IO ()
withTempInput callback = withTempFile "." ".tmp" $ \f h -> do
    hSetBinaryMode h True
    LB.hGetContents stdin >>= LB.hPut h
    hClose h
    callback f

smallestHash :: FilePath -> IO ()
smallestHash _ = putStrLn "hash"
