-- | This module is intended to present a slightly more PureScript-idiomatic interface the process of making
-- | data-driven documents and visualizations. However, it is NOT the API that end-users should
-- | program too, that would be the Nud3 module. This module is intended to just put some distance 
-- | between the 100% PureScript API and the FFI JavaScript API.

-- | At present almost all of the foreign functions are simply lifted from the D3/Selection.js file. They've been directly incorporated here
-- | so that the dependencies are all known and discovered incrementally as the functionality is added. 
-- | This might make it easier to re-write them in PureScript or a different JavaScript implementation later.
-- | The Git history should make the various stages of the process clear.

module Nud3.FFI
  ( addData_
  , appendElement_
  , completeJoin_
  , createNewTransition_
  , getGroups_
  , getName_
  , getParents_
  , idKey_
  , identityKey_
  , insertElement_
  , mergeSelections_
  , orderSelection_
  , prepareJoin_
  , selectManyWithFunction_
  , selectManyWithString_
  , uncurryKeyFunction
  , useInheritedData_
  )
  where

import Nud3.Types (D3SelectorFunction, KeyFunction(..), KeyFunctionType, KeyFunction_, Selection_, Transition_)
import Prelude (Unit)
import Web.DOM as DOM

foreign import getGroups_ :: Selection_ -> Array DOM.NodeList
foreign import getParents_ :: Selection_ -> Array DOM.Node
foreign import getName_ :: Selection_ -> String

-- foreign import selectFirstWithString_ :: String -> Selection_
foreign import selectManyWithString_ :: String -> Selection_
-- foreign import selectGroupedWithString_ :: Selection -> String -> Selection_
-- foreign import selectFirstFromWithString_ :: Selection -> String -> Selection_

-- foreign import selectFirstWithFunction_ :: D3SelectorFunction -> Selection_
foreign import selectManyWithFunction_ :: D3SelectorFunction -> Selection_
-- foreign import selectGroupedWithFunction_ :: Selection -> D3SelectorFunction -> Selection_
-- foreign import selectFirstFromWithFunction_ :: Selection -> D3SelectorFunction -> Selection_

foreign import appendElement_ :: String -> Selection_ -> Selection_
foreign import insertElement_ :: String -> String -> Selection_ -> Selection_

foreign import prepareJoin_ :: Selection_ -> String -> Selection_
foreign import identityKey_ :: KeyFunction_
foreign import idKey_ :: KeyFunction_
-- | uncurryKeyFunction_ is needed to convert key functions that are provided as PureScript lambdas in the FFI
-- | this might be a performance bottleneck for very large selections / data sets but most of the time it's
-- | likely that the following two built-in key functions will be used (identityKey_ and idKey_)
-- | could add further "canned" key functions here if they are needed too, or custom FFI. 
uncurryKeyFunction :: forall d i. KeyFunction d i -> KeyFunction_
uncurryKeyFunction (KeyFunction f) = uncurryKeyFunction_ f
uncurryKeyFunction IdentityKey = identityKey_
uncurryKeyFunction HasIdField = idKey_

foreign import uncurryKeyFunction_ :: forall d i. KeyFunctionType d i -> KeyFunction_
foreign import useInheritedData_ :: Selection_ -> KeyFunction_ -> Selection_
foreign import addData_ :: forall d. Selection_ -> Array d -> KeyFunction_ -> Selection_

foreign import completeJoin_
  :: -- | NB under the hood here in the FFI this is typed as if it were pure but obviously it isn't
     Selection_
  -> { enterFn :: Selection_ -> Selection_ -- | and neither are these enterFn, updateFn, exitFn functions
     , updateFn :: Selection_ -> Selection_
     , exitFn :: Selection_ -> Selection_
     }
  -> Selection_

foreign import mergeSelections_ :: Selection_ -> Selection_ -> Selection_
-- | only used by visualize after merging the enter and update selections
foreign import orderSelection_ :: Selection_ -> Selection_

-- | functions for transitions here
foreign import createNewTransition_ :: String -> Transition_
