module Nud3 where

import Nud3.Types
import Prelude

import Data.Array (head, last, tail)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Show.Generic (genericShow)
import Data.Traversable (traverse)
import Debug as Debug
import Effect (Effect)
import Effect.Class.Console as Console
import Nud3.Attributes (Attribute, addAttributes, getKeyFromAttribute, getValueFromAttribute)
import Nud3.FFI (selectManyWithString_)
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

showSelection :: Selection_ -> String
showSelection s = "Selection named: " <> FFI.getName_ s

type KeyFunction d = forall i. (Ord i) => (Ord d) => d -> Int -> NodeList -> i
-- NB this key function is curried whereas, used on the JS side it needs to be uncurried
-- optimise this later or maybe compiler optimisation will be enough

identityKeyFunction :: forall d. KeyFunction d
identityKeyFunction = \d _ _ -> unsafeCoerce d -- TODO something nicer here

type JoinConfig d = { 
    what :: AddElement
  , where :: Selection_
  , using :: DataSource d
  , key :: KeyFunction d
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

getElementName :: AddElement -> String
getElementName (Append (SVG tag)) = tag
getElementName (Insert (SVG tag) _) = tag
getElementName (Append (HTML tag)) = tag
getElementName (Insert (HTML tag) _) = tag

data Element = SVG String | HTML String

derive instance genericElement :: Generic Element _

instance showElement :: Show Element where
  show = genericShow

data AddElement = Append Element | Insert Element String -- TODO this String should be a "BeforeSelector"
derive instance genericAddElement :: Generic AddElement _
instance showAddElement :: Show AddElement where
  show = genericShow

-- | DSL functions below this line

select :: Selector -> Selection_
select (SelectorString s) = Debug.trace ("select with string: " <> s) \_ -> FFI.selectManyWithString_ s
select (SelectorFunction f) = Debug.trace "select with function" \_ -> unsafeCoerce $ FFI.selectManyWithFunction_ (unsafeCoerce f)

-- | TODO once tested remove the individual functions and just use this one
addElement :: Selection_ -> AddElement -> Effect Selection_
addElement s (Append element) = appendElement s element
-- TODO handle other "before selectors" (and function) instead of fixing it to ":first-child"
addElement s (Insert element selector) = insertElement s element ":first-child"

appendElement :: Selection_ -> Element -> Effect Selection_
appendElement s element = do
  Console.log ("appending " <> show element)
  pure $ case element of
    SVG tag -> FFI.appendElement_ tag s
    HTML tag -> FFI.appendElement_ tag s

insertElement :: Selection_ -> Element -> String -> Effect Selection_
insertElement s element selector = do
  Console.log $ "inserting " <> show element
  pure $ case element of
    SVG tag -> FFI.insertElement_ tag selector s 
    HTML tag -> FFI.insertElement_ tag selector s

infixr 5 appendElement as |+|
infixr 5 insertElement as |^|


appendStyledElement :: forall d. Selection_ -> Element -> Array (Attribute d) -> Effect Selection_
appendStyledElement s element attrs = 
  Debug.trace ("appending styled eleemnt: " <> show element <> show attrs) \_ -> 
  pure s -- TODO

insertStyledElement :: forall d. Selection_ -> Element -> Array (Attribute d) -> Effect Selection_
insertStyledElement s element attrs = 
  Debug.trace ("inserting styled element " <> show element <> show attrs) \_ -> 
  pure s -- TODO

-- | visualize replaces the (config.where).selectAll(config.what).data(config.using).append(config.what) 
-- | chain in d3 with a single function
-- | there are some major simplifications here vis-a-vis the D3 selection.join
-- | we are only supporting simple lists of attributes not an update function
-- | for the enter, exit and update selections. Not clear yet how much of an impact this
-- | actually will have, but we'll see when we try to add transitions and other things
-- | that are not simple attributes. It may be that there's a wholly different API approach
-- | available for those things anyway. 
visualize :: forall d. JoinConfig d -> Effect Selection_
visualize config = do
  let element = getElementName config.what
  let s' = FFI.beginJoin_ config.where element
  let s'' = case config.using of
              InheritData -> FFI.useInheritedData_ s' -- uses d => d
              NewData ds -> FFI.addData_ s' ds
  let { enter, update, exit } = FFI.getEnterUpdateExitSelections_ s''

  entered <- addElement enter config.what
  
  enterNodes <- addAttributes entered config.attributes.enter
  exitNodes <- addAttributes exit config.attributes.exit
  updateNodes <- addAttributes update config.attributes.update
  -- | TODO this should only do the merge if the enter selection is not null cf D3 implementation
  let merged = FFI.mergeSelections_ enterNodes updateNodes
  pure $ FFI.orderSelection_ merged
    
filter :: Selection_ -> String -> Selection_
filter s _ = s -- TODO  

style :: forall d. Selection_ -> Array (Attribute d) -> Effect Selection_
style = addAttributes


