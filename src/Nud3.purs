module Nud3 where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Debug as Debug
import Effect (Effect)
import Effect.Class.Console as Console
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
  , name :: String -- all selections will have a name in this implementation
  , parents :: Array DOM.Node
  }

showSelection :: Selection -> String
showSelection s = "Selection named: s.name"

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

showJoin :: forall d. (Show d) => JoinConfig d -> String
showJoin join = "Join details: { \n" <>
  "what: " <> show join.what <>
  "where: " <> showSelection join.where <>
  "using: " <> -- show join.using <>
  "key: (function)" <>
  "enter attrs: " <> show join.attributes.enter <>
  "update attrs:" <> show join.attributes.update <>
  "exit attrs: " <> show join.attributes.exit

data DataSource d = InheritData | NewData (Array d)

instance showDataSource :: (Show d) => Show (DataSource d) where
  show InheritData = "data is inherited from parent"
  show (NewData ds) = "data is new" <> show ds
else
instance showDataSourceSimple :: Show (DataSource Unit) where
  show InheritData = "data is inherited from parent"
  show (NewData _) = "data is new, but no show instance exists to show it"

type ElementConfig d = Array (Attribute d)

data EnterElement = 
    Append Element 
  | Insert Element

derive instance genericEnterElement :: Generic EnterElement _

instance showEnterElement :: Show EnterElement where
  show = genericShow

data Element = SVG String | HTML String

derive instance genericElement :: Generic Element _

instance showElement :: Show Element where
  show = genericShow

-- | DSL functions below this line

emptySelection :: Selection
emptySelection = { groups: [], parents: [], name: "empty" }

namedSelection :: String -> Selection
namedSelection name = { groups: [], parents: [], name: name }

select :: String -> Selector -> Selection
select name (SelectorString s) = Debug.trace ("select with string: " <> s) \_ -> namedSelection name
select name (SelectorFunction f) = Debug.trace "select with function" \_ -> namedSelection name

appendElement :: Selection -> Element -> Effect Selection
appendElement s element = Debug.trace ("appending " <> show element) \_ -> pure s -- TODO

insertElement :: Selection -> Element -> Effect Selection
insertElement s element = Debug.trace ("inserting " <> show element) \_ -> pure s -- TODO


infixr 5 appendElement as |+|
infixr 5 insertElement as |^|

appendStyledElement :: forall d. Selection -> Element -> Array (Attribute d) -> Effect Selection
appendStyledElement s element attrs = Debug.trace ("appending styled eleemnt: " <> show element <> show attrs) \_ -> pure s -- TODO

insertStyledElement :: forall d. Selection -> Element -> Array (Attribute d) -> Effect Selection
insertStyledElement s element attrs = Debug.trace ("inserting styled element " <> show element <> show attrs) \_ -> pure s -- TODO

-- | visualize replaces the .enter().data().append() chain in d3 with a single function
visualize :: forall d. (Show d) => JoinConfig d -> Effect Selection
visualize config = do
  Console.log (showJoin config)
  pure emptySelection

--| here the data is already in the DOM, we just need to update the visualisation with some new data
revisualize :: forall d. Selection -> Array d -> Effect Selection
revisualize s ds = Debug.trace "joining new data to the DOM and updating visualiztion with it" \_ -> pure s -- TODO

filter :: Selection -> String -> Selection
filter s _ = s -- TODO  

style :: forall d. Selection -> Array (Attribute d) -> Effect Selection
style s _ = pure s -- TODO


