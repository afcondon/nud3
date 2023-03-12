module Nud3 where

import Prelude

import Data.Array (head)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (traverse)
import Data.Show.Generic (genericShow)
import Debug as Debug
import Effect (Effect)
import Effect.Class.Console as Console
import Nud3.Attributes (Attribute, getKeyFromAttribute, getValueFromAttribute)
import Nud3.FFI as FFI
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

-- | morally equivalent to a d3 selection, use Selection_ instead
-- type Selection = { 
--     groups :: Array NodeList
--   , name :: String -- all selections will have a name in this implementation
--   , parents :: Array DOM.Node
--   }

showSelection :: FFI.Selection_ -> String
showSelection s = "Selection named: " <> FFI.getName_ s

type KeyFunction = forall d i. (Ord i) => (Ord d) => d -> Int -> NodeList -> i
-- NB this key function is curried whereas, used on the JS side it needs to be uncurried
-- optimise this later or maybe compiler optimisation will be enough

identityKeyFunction :: KeyFunction
identityKeyFunction = \d _ _ -> unsafeCoerce d -- TODO something nicer here

type JoinConfig d = { 
    what :: EnterElement
  , where :: FFI.Selection_
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
  "\twhat: " <> show join.what <>
  "\n\twhere: " <> showSelection join.where <>
  "\n\tusing: " <> show join.using <>
  "\n\tkey: (function)" <>
  "\n\tenter attrs: " <> show join.attributes.enter <>
  "\n\tupdate attrs:" <> show join.attributes.update <>
  "\n\texit attrs: " <> show join.attributes.exit

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

select :: String -> Selector -> FFI.Selection_
select name (SelectorString s) = Debug.trace ("select with string: " <> s) \_ -> unsafeCoerce $ FFI.selectManyWithString_ name s
select name (SelectorFunction f) = Debug.trace "select with function" \_ -> unsafeCoerce $ FFI.selectManyWithFunction_ name (unsafeCoerce f)

appendElement :: FFI.Selection_ -> Element -> Effect FFI.Selection_
appendElement s element = do
  Console.log ("appending " <> show element)
  pure $ case element of
    SVG tag -> FFI.appendElement_ tag s
    HTML tag -> FFI.appendElement_ tag s

insertElement :: FFI.Selection_ -> Element -> Effect FFI.Selection_
insertElement s element = do
  Console.log $ "inserting " <> show element
  pure $ case element of
    SVG tag -> FFI.insertElement_ tag ":first-child" s -- TODO handle other selectors and function instead of string too
    HTML tag -> FFI.insertElement_ tag ":first-child" s


infixr 5 appendElement as |+|
infixr 5 insertElement as |^|

addAttributes :: forall d. FFI.Selection_ -> Array (Attribute d) -> Effect FFI.Selection_
addAttributes s attrs = 
  case head attrs of
    Nothing -> pure s
    Just attr -> do
       pure $ FFI.addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)

appendStyledElement :: forall d. FFI.Selection_ -> Element -> Array (Attribute d) -> Effect FFI.Selection_
appendStyledElement s element attrs = Debug.trace ("appending styled eleemnt: " <> show element <> show attrs) \_ -> pure s -- TODO

insertStyledElement :: forall d. FFI.Selection_ -> Element -> Array (Attribute d) -> Effect FFI.Selection_
insertStyledElement s element attrs = Debug.trace ("inserting styled element " <> show element <> show attrs) \_ -> pure s -- TODO

-- | visualize replaces the .enter().data().append() chain in d3 with a single function
visualize :: forall d. (Show d) => JoinConfig d -> Effect FFI.Selection_
visualize config = do
  Console.log (showJoin config)
  pure config.where -- TODO implement this

--| here the data is already in the DOM, we just need to update the visualisation with some new data
revisualize :: forall d. FFI.Selection_ -> Array d -> Effect FFI.Selection_
revisualize s ds = Debug.trace "joining new data to the DOM and updating visualiztion with it" \_ -> pure s -- TODO

filter :: FFI.Selection_ -> String -> FFI.Selection_
filter s _ = s -- TODO  

style :: forall d. FFI.Selection_ -> Array (Attribute d) -> Effect FFI.Selection_
style s _ = pure s -- TODO


