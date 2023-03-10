module Simulation where

import Prelude

import Effect (Effect)
import Nud3.Attributes (Attribute)
import Nud3.Types (KeyFunction)
import Unsafe.Coerce (unsafeCoerce)

-- | this probably need to be an opaque type hidden behind FFI
type Node = { id :: Int, x :: Number, y :: Number, vx :: Number, vy :: Number, group :: Int } 

-- | the Link id will be (show source <> "-" <> show target), this should be opaque too but maybe needs to be exposed for Attrs etc
type Link = { id :: String, source :: Int, target :: Int, value :: Number }
data Engine = Engine

type Model = { 
    nodes :: Array Node
  , links :: Array Link
  }

data DragBehavior = DefaultDragBehavior | CustomDragBehavior | NoDrag 

type NodesConfig = {
    simulator :: Engine
  , nodes :: Array Node
  , key :: Node -> Int
}

type LinksConfig = {
    simulator :: Engine
  , nodes :: Array Node
  , links :: Array Link
  , key :: Link -> String
}

addNodes :: NodesConfig -> Effect (Array Node)
addNodes config = do
  pure []

addLinks :: LinksConfig -> Effect (Array Link)
addLinks config = do
  pure [] 

newEngine :: Params -> Effect Engine
newEngine params = do
  pure $ Engine 

type Params = { 
    width :: Number
  , height :: Number
  , alpha :: Number
  , alphaMin :: Number
  , alphaDecay :: Number
  , velocityDecay :: Number
  }

onTickNode :: forall d. Engine -> Array Node -> Array (Attribute d) -> Effect Unit
onTickNode engine nodes attrs = do
  pure unit

onTickLink :: forall d. Engine -> Array Link -> Array (Attribute d) -> Effect Unit
onTickLink engine links attrs = do
  pure unit

onDrag :: Engine -> Array Node -> DragBehavior -> Effect Unit
onDrag engine nodes dragBehavior = do
  pure unit