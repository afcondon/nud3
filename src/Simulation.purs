module Simulation where

import Prelude
import Effect (Effect)
import Nud3.Attributes (Attribute)
import Nud3.Types (KeyFunction)

-- | this probably need to be an opaque type hidden behind FFI
type SimulationNode = { id :: Int, x :: Number, y :: Number, vx :: Number, vy :: Number, mass :: Number } 
type SimulationLink = { source :: Int, target :: Int, value :: Number }
data SimulationEngine = SimulationEngine

data DragBehavior = DefaultDragBehavior | CustomDragBehavior | NoDrag 

type Config = {
    simulation :: SimulationEngine
  , nodes :: Array SimulationNode
  , links :: Array SimulationLink
  , key :: KeyFunction
  , drag :: DragBehavior 
  , tick :: Array Attribute
}

addNodes :: Config -> Effect (Array SimulationNode)
addNodes config = do
  pure []

addLinks :: Config -> Effect (Array SimulationLink)
addLinks config = do
  pure [] 