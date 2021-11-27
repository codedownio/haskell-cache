-- |
-- Module:      Data.Cache.Internal
-- Copyright:   (c) 2018 Henri Verroken
-- License:     BSD3
-- Maintainer:  Henri Verroken <henriverroken@gmail.com>
-- Stability:   stable
--
-- This modules exposes some of the internals of 'Data.Cache' as well as some
-- auxiliary functions for expert users.

module Data.Cache.Internal (
    -- * Cache constructor
    Cache(..)
  , CacheItem(..)

    -- * Unsafe auxiliary functions
  , nowSTM
) where

import Control.Concurrent.Async
import Control.Concurrent.STM
import qualified Data.HashMap.Strict as HM
import GHC.Conc (unsafeIOToSTM)
import System.Clock

-- | The cache with keys of type @k@ and values of type @v@.
--
-- Create caches with the 'newCache' and 'copyCache' functions.
data Cache k v = Cache {
    container :: TVar (HM.HashMap k (CacheItem v))
    -- | The default expiration value of newly added cache items.
    --
    -- See 'newCache' for more information on the default expiration value.
  , defaultExpiration :: Maybe TimeSpec
    -- | Optional thread to purge cache entries periodically
  , purgeThread :: Maybe (Async ())
}

-- | A container data type holding a cache item.
data CacheItem v = CacheItem {
    item :: v
  , itemExpiration :: Maybe TimeSpec
}

-- | Get the current time in the 'STM' monad using 'unsafeIOToSTM'.
nowSTM :: STM TimeSpec
nowSTM = unsafeIOToSTM $ getTime Monotonic
