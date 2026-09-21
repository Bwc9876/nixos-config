{-# LANGUAGE GHC2024 #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Weverything #-}
{-# OPTIONS_GHC -Wno-implicit-prelude #-}
{-# OPTIONS_GHC -Wno-missing-safe-haskell-mode #-}
{-# OPTIONS_GHC -Wno-unsafe #-}

import Control.Category ((>>>))
import Control.Monad (unless)
import Data.Functor ((<&>))
import Data.String (IsString)
import Data.Time (getCurrentTime)
import Data.Time.Format.ISO8601 (iso8601Show)
import System.Directory (createDirectoryIfMissing, getCurrentDirectory, makeAbsolute)
import System.Environment (lookupEnv, setEnv)
import System.Exit (exitSuccess)
import System.FilePath (splitFileName, (</>))
import System.Posix (getEffectiveUserID)
import System.Process (callProcess)

-- TODO: FilePath -> OsString?

branch :: (IsString a) => a
branch = "deploy"

parseRef :: [String] -> (String, String, String)
parseRef [a, b, c] = (a, b, c)
parseRef _ = error "parseRef: bad line"

parseRefs :: String -> [(String, String, String)]
parseRefs = lines >>> map (words >>> parseRef)

main :: IO ()
main = do
  -- Ensure we use absolute paths everywhere, esp. Podman volumes
  workdir <- makeAbsolute "workdir"
  backupDir <- makeAbsolute "backups"

  isRoot <- getEffectiveUserID <&> (== 0)
  let maybeUser = if isRoot then id else ("--user" :)

  pwd <- getCurrentDirectory
  let (_, dirname) = splitFileName pwd
      service = "podman-" <> dirname <> ".service"

  updates <- getContents <&> parseRefs
  let doUpdate = any (\(_, _, name) -> name == "refs/heads/" <> branch) updates
  -- FIXME: what if the ref is deleted?

  unless doUpdate $ do
    putStrLn $ "`" <> branch <> "` branch wasn't update, doing nothing"
    exitSuccess

  createDirectoryIfMissing False workdir
  createDirectoryIfMissing False backupDir

  setEnv "GIT_WORK_TREE" workdir

  callProcess "systemctl" $ maybeUser ["stop", "-v", service]

  date <- getCurrentTime <&> iso8601Show
  -- TODO: compress?
  -- TODO: remove old?
  callProcess "podman" ["volume", "export", dirname, "-o", backupDir </> date <> ".tar"]

  -- FIXME: per `git-checkout(1)`, this
  callProcess "git" ["checkout", "-f"]

  lookupEnv "UPDATE_CONTAINER_PATH" >>= \case
    Nothing -> putStrLn "No $UPDATE_CONTAINER_PATH, skipping"
    Just path ->
      callProcess
        "podman"
        [ "run",
          "--rm",
          "-v",
          workdir <> ":/pack:ro", -- FIXME: assumes path doesn't have :
          "-v",
          dirname <> ":/srv",
          "docker-archive:" <> path -- TODO: can I use `dir:/path`? can I use a sandboxing system that doesn't involve copying the whole root directory?
        ]

  -- TODO: only if it wasn't stopped before?
  -- TODO: reset-failed?
  callProcess "systemctl" $ maybeUser ["start", "-v", service]
