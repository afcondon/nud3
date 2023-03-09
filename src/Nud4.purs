module Nud4 where

import Prelude

import Effect (Effect)
import Nud3 (Action(..))
import Prim.Symbol (class Append)
import Web.DOM (Node) as DOM

data Selector = 
      SelectorString String 
    | SelectorFunction (forall d. d -> Int -> NodeList -> Boolean) -- in d3 "this" would be nodes[i] in this function

type NodeList = Array DOM.Node

type UpdateSelection = { 
    enter :: Array Unit -- unit is used as a placeholder for the enter nodes
  , exit :: NodeList -- these nodes will most likely be removed
  , update :: Array NodeList -- directly equivalent to the "groups" in a regular selection
  , parents :: Array DOM.Node
  }

type Selection = { 
    groups :: Array NodeList
  , parents :: Array DOM.Node
  }

type Element = String -- this is a placeholder for HTML and SVG elements
type JoinConfig d = { 
    what:: Array d
  , where:: Selection
  , key :: forall i. Ord i => d -> i
  , enter :: Element 
  , newElements :: ElementConfig
  , exitingElements :: ElementConfig
  , changedElements :: ElementConfig
  }

type ElementConfig = Array Attribute

type Lambda t = forall d. d -> Int -> t

data Attribute = 
    Append
  | Remove
  | Fill (Lambda String)
  | StrokeWidth (Lambda Number)
  | Fill' String
  | StrokeWidth' Number

-- | DSL functions below this line

emptySelection :: Selection
emptySelection = { groups: [], parents: [] }

select :: Selector -> Selection
select (SelectorString s) = emptySelection
select (SelectorFunction f) = emptySelection

appendSelection :: Selection -> Selector -> Selection
appendSelection s (SelectorString selector) = s
appendSelection s (SelectorFunction f) = s

infixr 5 appendSelection as |+|

visualize :: forall d. JoinConfig d -> Effect Selection
visualize config = pure emptySelection


