module Nud3 where

import Prelude

import Data.Array (head, last, tail)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Show.Generic (genericShow)
import Data.Traversable (traverse)
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
    what :: AddElement
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

select :: String -> Selector -> FFI.Selection_
select name (SelectorString s) = Debug.trace ("select with string: " <> s) \_ -> unsafeCoerce $ FFI.selectManyWithString_ name s
select name (SelectorFunction f) = Debug.trace "select with function" \_ -> unsafeCoerce $ FFI.selectManyWithFunction_ name (unsafeCoerce f)

-- | TODO once tested remove the individual functions and just use this one
addElement :: FFI.Selection_ -> AddElement -> Effect FFI.Selection_
addElement s (Append element) = appendElement s element
-- TODO handle other "before selectors" (and function) instead of fixing it to ":first-child"
addElement s (Insert element selector) = insertElement s element ":first-child"

appendElement :: FFI.Selection_ -> Element -> Effect FFI.Selection_
appendElement s element = do
  Console.log ("appending " <> show element)
  pure $ case element of
    SVG tag -> FFI.appendElement_ tag s
    HTML tag -> FFI.appendElement_ tag s

insertElement :: FFI.Selection_ -> Element -> String -> Effect FFI.Selection_
insertElement s element selector = do
  Console.log $ "inserting " <> show element
  pure $ case element of
    SVG tag -> FFI.insertElement_ tag selector s 
    HTML tag -> FFI.insertElement_ tag selector s


infixr 5 appendElement as |+|
infixr 5 insertElement as |^|

-- NB the semantics of D3 are not spelt out and a selection is returned from every attr 
-- to facilitate function chaining. In PureScript we're going to say that the Attribute Setter
-- effects the DOM and returns only Unit.
addAttributes :: forall d. FFI.Selection_ -> Array (Attribute d) -> Effect FFI.Selection_
addAttributes s attrs = do
  let _ = (addAttribute s) <$> attrs -- relies on the fact that addAttribute returns the same selection each time
  pure s

-- | TODO modulo compile cycles and other issues, this should be in the Attributes module
addAttribute :: forall d. FFI.Selection_ -> Attribute d -> Unit
addAttribute s attr = FFI.addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)


appendStyledElement :: forall d. FFI.Selection_ -> Element -> Array (Attribute d) -> Effect FFI.Selection_
appendStyledElement s element attrs = 
  Debug.trace ("appending styled eleemnt: " <> show element <> show attrs) \_ -> 
  pure s -- TODO

insertStyledElement :: forall d. FFI.Selection_ -> Element -> Array (Attribute d) -> Effect FFI.Selection_
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
visualize :: forall d. (Show d) => JoinConfig d -> Effect FFI.Selection_
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
    
--| here the data is already in the DOM, we just need to update the visualisation with some new data
revisualize :: forall d. FFI.Selection_ -> Array d -> Effect FFI.Selection_
revisualize s ds = 
  Debug.trace "joining new data to the DOM and updating visualiztion with it" \_ -> 
  pure s -- TODO

filter :: FFI.Selection_ -> String -> FFI.Selection_
filter s _ = s -- TODO  

style :: forall d. FFI.Selection_ -> Array (Attribute d) -> Effect FFI.Selection_
style = addAttributes


