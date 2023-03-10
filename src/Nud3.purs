module Nud3 where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Debug as Debug
import Effect (Effect)
import Nud3.Attributes (Attribute)
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

type JoinConfig d = { 
    what :: EnterElement
  , where :: Selection
  , using :: DataSource d
  , key :: KeyFunction
  , attributes :: {
      enter :: ElementConfig d
    , update :: ElementConfig d
    , exit :: ElementConfig d
  }
  }

data DataSource d = InheritData | NewData (Array d)

type ElementConfig d = Array (Attribute d)

data EnterElement = 
    Append Element 
  | Insert Element

data Element = SVG String | HTML String

derive instance genericElement :: Generic Element _

instance showElement :: Show Element where
  show = genericShow


-- | DSL functions below this line

emptySelection :: Selection
emptySelection = { groups: [], parents: [] }

select :: Selector -> Selection
select (SelectorString s) = Debug.trace ("select with string: " <> s) \_ -> emptySelection
select (SelectorFunction f) = Debug.trace "select with function" \_ -> emptySelection

appendElement :: Selection -> Element -> Effect Selection
appendElement s element = Debug.trace ("appending " <> show element) \_ -> pure s -- TODO

insertElement :: Selection -> Element -> Effect Selection
insertElement s element = pure s -- TODO
infixr 5 appendElement as |+|
infixr 5 insertElement as |^|

appendStyledElement :: forall d. Selection -> Element -> Array (Attribute d) -> Effect Selection
appendStyledElement s element attrs = pure s -- TODO

insertStyledElement :: forall d. Selection -> Element -> Array (Attribute d) -> Effect Selection
insertStyledElement s element attrs = pure s -- TODO

visualize :: forall d. JoinConfig d -> Effect Selection
visualize config = pure emptySelection

revisualize :: forall d. Selection -> Array d -> Effect Selection
revisualize s ds = pure s -- TODO

filter :: Selection -> String -> Selection
filter s _ = s -- TODO  

style :: forall d. Selection -> Array (Attribute d) -> Effect Selection
style s _ = pure s -- TODO


