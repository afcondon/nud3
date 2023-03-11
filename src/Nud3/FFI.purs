module Nud3.FFI where

import Nud3.Types
import Prelude

import Control.Plus (empty)
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM as DOM

foreign import data Selection_ :: Type -- opaque and mutable data 
foreign import data D3SelectorFunction :: Type

foreign import getGroups_ :: Selection_ -> Array DOM.NodeList
foreign import getParents_ :: Selection_ -> Array DOM.Node
foreign import getName_ :: Selection_ -> String

-- foreign import selectFirstWithString_ :: String -> Selection_
foreign import selectManyWithString_ :: String -> String -> Selection_
-- foreign import selectGroupedWithString_ :: Selection -> String -> Selection_
-- foreign import selectFirstFromWithString_ :: Selection -> String -> Selection_

-- foreign import selectFirstWithFunction_ :: D3SelectorFunction -> Selection_
foreign import selectManyWithFunction_ :: String -> D3SelectorFunction -> Selection_
-- foreign import selectGroupedWithFunction_ :: Selection -> D3SelectorFunction -> Selection_
-- foreign import selectFirstFromWithFunction_ :: Selection -> D3SelectorFunction -> Selection_
