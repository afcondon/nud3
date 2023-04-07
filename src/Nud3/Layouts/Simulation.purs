module Nud3.Layouts.Simulation
  where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Nud3.Attributes (Attribute)

-- | this probably need to be an opaque type hidden behind FFI
type Node r = { id :: Int, x :: Number, y :: Number, vx :: Number, vy :: Number, group :: Int | r } 

-- | the Link id will be (show source <> "-" <> show target), this should be opaque too but maybe needs to be exposed for Attrs etc
type ReferenceLink = { id :: String, source :: Int, target :: Int, value :: Number } -- TODO does value need to be a record?
type SwizzledLink r = { id :: String, source :: Node r, target :: Node r, value :: Number }

type Model r = { nodes :: Array (Node r), links :: Array ReferenceLink }

foreign import data Engine_ :: Type
foreign import data Force_ :: Type
foreign import createEngine_ :: Params -> Engine_
foreign import addForce_ :: Engine_ -> String -> Force_ -> Unit
foreign import makeForceManyBody_ :: ForceManyBodyParams -> Force_
foreign import makeForceCenter_ :: ForceCenterParams -> Force_
foreign import addNodes_ :: forall r. Engine_ -> Array (Node r) -> (Node r -> Int) -> Array (Node r)
-- | add the links to the linkForce which was created at the same time as the simulation engine
foreign import setLinks_ :: forall r. Engine_ -> Array (Node r) -> Array ReferenceLink -> (ReferenceLink -> String) -> Array (SwizzledLink r)
data Engine = 
    Engine String Engine_
  | NamedEngine String

instance showEngine :: Show Engine where
  show (Engine name _) = "Simulation engine: " <> name
  show (NamedEngine name) = "Uninitialised Simulation engine: " <> name

data Force = Force String Force_ -- TODO don't export this

data DragBehavior = DefaultDragBehavior | CustomDragBehavior | NoDrag 

type NodesConfig r = {
    simulator :: Engine
  , nodes :: Array (Node r)
  , key :: (Node r) -> Int
}

type LinksConfig r = {
    simulator :: Engine
  , nodes :: Array (Node r)
  , links :: Array ReferenceLink
  , key :: ReferenceLink -> String
}

addNodes :: forall r. NodesConfig r -> Effect (Array (Node r))
addNodes config = do
  case config.simulator of
    Engine name engine -> do
      pure $ addNodes_ engine config.nodes config.key
    _ -> pure [] -- TODO simulator has not yet been initialised

addLinks :: forall r. LinksConfig r -> Effect (Array (SwizzledLink r)) -- NB reference link isn't parametrized with the type of the node
addLinks config = do
  case config.simulator of
    Engine name engine -> do
      pure $ setLinks_ engine config.nodes config.links config.key
    _ -> pure [] -- TODO simulator has not yet been initialised

addForce :: Engine -> Force -> Effect Unit
addForce (Engine _ engine) (Force name force_) = pure $ addForce_ engine name force_
addForce _ _ = pure unit -- TODO simulator has not yet been initialised

makeForceManyBody :: ForceManyBodyParams -> Effect Force
makeForceManyBody params = pure $ Force params.name $ makeForceManyBody_ params

makeForceCenter :: ForceCenterParams -> Effect Force
makeForceCenter params = pure $ Force params.name $ makeForceCenter_ params

newEngine :: Params -> Effect Engine
newEngine params = pure $ Engine "Foo" $ createEngine_ params

type Params = { 
    alpha :: Number
  , alphaMin :: Number
  , alphaDecay :: Number
  , alphaTarget :: Number
  , velocityDecay :: Number
  }

defaultParams :: Params
defaultParams = { 
      alpha: 0.1
    , alphaMin: 0.001
    , alphaDecay: 0.0228
    , alphaTarget: 0.0
    , velocityDecay: 0.4
    }
type ForceManyBodyParams = 
  { distanceMax :: Number
  , distanceMin :: Number
  , strength :: Number
  , theta :: Number
  , name :: String
  }
forceManyBodyParams :: ForceManyBodyParams 
forceManyBodyParams = { -- AKA forceCharge
      strength: -30.0
    , distanceMin: 1.0
    , distanceMax: 200.0
    , theta: 0.9
    , name: "manyBody"
    } 

type ForceCenterParams = 
  { strength :: Number
  , x :: Number
  , y :: Number
  , name :: String
  }
forceCenterParams :: ForceCenterParams
forceCenterParams = {
      x: 0.0
    , y: 0.0
    , strength: 1.0
    , name: "center"
    }

onTickNode :: forall d r. Engine -> Array (Node r) -> Array (Attribute d) -> Effect Unit
onTickNode engine nodes attrs = do
  log "TODO: onTickNode not yet implemented"
  pure unit

onTickLink :: forall d r. Engine -> Array (SwizzledLink r) -> Array (Attribute d) -> Effect Unit
onTickLink engine links attrs = do
  log "TODO: onTickLink not yet implemented"
  pure unit

onDrag :: forall r. Engine -> Array (Node r) -> DragBehavior -> Effect Unit
onDrag engine nodes dragBehavior = do
  log "TODO: onDrag not yet implemented"
  pure unit