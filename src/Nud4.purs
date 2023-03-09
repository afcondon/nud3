module Nud4 where

import Nud3.Attributes
import Prelude

import Effect (Effect)
import Unsafe.Coerce (unsafeCoerce)
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

type KeyFunction = forall d i. (Ord i) => (Ord d) => d -> Int -> NodeList -> i
-- NB this key function is curried whereas, used on the JS side it needs to be uncurried
-- optimise this later or maybe compiler optimisation will be enough

identityKeyFunction :: KeyFunction
identityKeyFunction = \d _ _ -> unsafeCoerce d -- TODO something nicer here

type Element = String -- this is a placeholder for HTML and SVG elements
type JoinConfig d = { 
    what :: EnterElement
  , where :: Selection
  , using :: DataSource d
  , key :: KeyFunction
  , attributes :: {
      enter :: ElementConfig
    , update :: ElementConfig
    , exit :: ElementConfig
  }
  }

data DataSource d = InheritData | NewData (Array d)

type ElementConfig = Array Attribute


-- | DSL functions below this line

emptySelection :: Selection
emptySelection = { groups: [], parents: [] }

select :: Selector -> Selection
select (SelectorString s) = emptySelection
select (SelectorFunction f) = emptySelection

appendElement :: Selection -> Element -> Selection
appendElement s element = s -- TODO

insertElement :: Selection -> Element -> Selection
insertElement s element = s -- TODO

infixr 5 appendElement as |+|
infixr 5 insertElement as |^|

visualize :: forall d. JoinConfig d -> Effect Selection
visualize config = pure emptySelection

filter :: Selection -> String -> Selection
filter s _ = s -- TODO  

style :: Selection -> Array Attribute -> Effect Selection
style s _ = pure s -- TODO