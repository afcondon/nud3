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
  , insertElement_
  , createNewTransition_
  , completeJoin_
  , easeCubic_
  , getEnterUpdateExitSelections_
  , getGroups_
  , getName_
  , getParents_
  , mergeSelections_
  , orderSelection_
  , prepareJoin_
  , selectManyWithFunction_
  , selectManyWithString_
  , transitionDelayFixed_
  , transitionDelayLambda_
  , transitionDurationFixed_
  , transitionDurationLambda_
  , transitionEaseFunction
  , useInheritedData_
  )
  where

import Effect (Effect)
import Nud3.Types (D3SelectorFunction, Selection_, Transition_)
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
foreign import useInheritedData_ :: Selection_ -> Selection_
foreign import addData_ :: forall d. Selection_ -> Array d -> Selection_
foreign import getEnterUpdateExitSelections_ :: Selection_ -> { enter :: Selection_, update :: Selection_, exit :: Selection_ }
foreign import completeJoin_ :: 
  Selection_ -> 
  { enterFn :: Selection_ -> Selection_
  , updateFn :: Selection_ -> Selection_
  , exitFn :: Selection_ -> Selection_ } -> 
  Selection_
foreign import mergeSelections_ :: Selection_ -> Selection_ -> Selection_
-- | only used by visualize after merging the enter and update selections
foreign import orderSelection_ :: Selection_ -> Selection_


-- | functions for transitions here
foreign import createNewTransition_ :: Unit -> Transition_

foreign import transitionDelayFixed_ :: Transition_ -> Int -> Transition_
foreign import transitionDelayLambda_ :: forall d. Transition_ -> (d -> Int -> Int) -> Transition_
foreign import transitionDurationFixed_ :: Transition_ -> Int -> Transition_
foreign import transitionDurationLambda_ :: forall d t. Transition_ -> (d -> Int -> Int) -> Transition_
foreign import transitionEaseFunction :: Transition_ -> (Number -> Number) -> Transition_

foreign import easeCubic_ :: Number -> Number
