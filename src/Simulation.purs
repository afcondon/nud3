module Simulation where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Effect (Effect)
import Effect.Console (log)
import Nud3.Attributes (Attribute)

-- | this probably need to be an opaque type hidden behind FFI
type Node = { id :: Int, x :: Number, y :: Number, vx :: Number, vy :: Number, group :: Int } 

-- | the Link id will be (show source <> "-" <> show target), this should be opaque too but maybe needs to be exposed for Attrs etc
type Link = { id :: String, source :: Int, target :: Int, value :: Number }
data Engine = Engine
derive instance genericEngine :: Generic Engine _

instance showEngine :: Show Engine where
  show = genericShow

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
  log $ "TODO: addNodes not yet implemented " <> show config.simulator
  pure []

addLinks :: LinksConfig -> Effect (Array Link)
addLinks config = do
  log $ "TODO: addLinks not yet implemented" <> show config.simulator
  pure [] 

newEngine :: Params -> Effect Engine
newEngine params = do
  log $ "TODO: newEngine not yet implemented" <> show params.alpha
  pure $ Engine 

type Params = { 
    alpha :: Number
  , alphaMin :: Number
  , alphaDecay :: Number
  , alphaTarget :: Number
  , velocityDecay :: Number
  }

onTickNode :: forall d. Engine -> Array Node -> Array (Attribute d) -> Effect Unit
onTickNode engine nodes attrs = do
  log "TODO: onTickNode not yet implemented"
  pure unit

onTickLink :: forall d. Engine -> Array Link -> Array (Attribute d) -> Effect Unit
onTickLink engine links attrs = do
  log "TODO: onTickLink not yet implemented"
  pure unit

onDrag :: Engine -> Array Node -> DragBehavior -> Effect Unit
onDrag engine nodes dragBehavior = do
  log "TODO: onDrag not yet implemented"
  pure unit