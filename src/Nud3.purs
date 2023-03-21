module Nud3
  ( AddElement(..)
  , DataSource(..)
  , Element(..)
  , ElementConfig
  , JoinConfig
  , NodeList
  , Selector(..)
  , UpdateSelection
  , addElement
  , addElementXXX
  , filter
  , getElementName
  , select
  , showJoin
  , showSelection
  , visualize
  )
  where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Debug as Debug
import Effect (Effect)
import Nud3.Attributes (Attribute, foldAttributes)
import Nud3.FFI as FFI
import Nud3.Types (KeyFunction(..), Selection_)
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

type JoinConfig d i = { 
    what :: AddElement
  , where :: Selection_
  , using :: DataSource d
  , key :: KeyFunction d i 
  , attributes :: {
      enter :: ElementConfig d
    , update :: ElementConfig d
    , exit :: ElementConfig d
  }
  }

showJoin :: forall d i. (Show d) => JoinConfig d i -> String
showJoin join = "Join details: { \n" <>
  "\twhat: " <> show join.what <>
  "\n\twhere: " <> showSelection join.where <>
  "\n\tusing: " <> show join.using <>
  "\n\tkey: (function)" <>
  "\n\tenter attrs: " <> show join.attributes.enter <>
  "\n\tupdate attrs:" <> show join.attributes.update <>
  "\n\texit attrs: " <> show join.attributes.exit

data DataSource d = 
   InheritData -- NB this will fail if there is no data attached to the parent (TODO DSL should protect against this)
 | NewData (Array d)

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

addElement :: Selection_ -> AddElement -> Effect Selection_
addElement s = case _ of
  Append (SVG tag) -> pure $ FFI.appendElement_ tag s
  Append (HTML tag) -> pure $ FFI.appendElement_ tag s
-- TODO for insert handle other "before selectors" (and function) instead of fixing it to ":first-child"
  Insert (SVG tag) selector -> pure $ FFI.insertElement_ tag selector s
  Insert (HTML tag) selector -> pure $ FFI.insertElement_ tag selector s

-- | visualize replaces the (config.where).selectAll(config.what).data(config.using).append(config.what) 
-- | chain in d3 with a single function
-- | there are some major simplifications here vis-a-vis the D3 selection.join
-- | we are only supporting simple lists of attributes not an update function
-- | for the enter, exit and update selections. Not clear yet how much of an impact this
-- | actually will have, but we'll see when we try to add transitions and other things
-- | that are not simple attributes. It may be that there's a wholly different API approach
-- | available for those things anyway. 
visualize :: forall d i. JoinConfig d i -> Effect Selection_
visualize config = do
  -- FFI.prepareJoin uses underlying call to selection.selectAll(element) 
  let prepped = FFI.prepareJoin_ config.where (getElementName config.what) 
  -- both branches here use underlying call to selection.data(data, key)
  let keyFunction = FFI.uncurryKeyFunction config.key
  let hasData = case config.using of
              InheritData -> FFI.useInheritedData_ prepped keyFunction
              NewData ds -> FFI.addData_ prepped ds keyFunction
  -- FFI.completeJoin_ provides functions for each of the three selections: enter, update and exit
  pure $ FFI.completeJoin_ hasData {
      enterFn: \enter -> foldAttributes (addElementXXX enter config.what) config.attributes.enter
    , updateFn: \update -> foldAttributes update config.attributes.update
    , exitFn: \exit ->  foldAttributes exit config.attributes.exit
    }

-- | ********* Tempororary unsafe code in this section  *********
-- This code is here just to keep the Effect Selection out of the completeJoin_ function
-- It duplicates the DSL (exported) API for Append / Insert Elements but with the Effect removed
-- This is clearly wrong but it's a temporary hack to get things working
addElementXXX :: Selection_ -> AddElement -> Selection_
addElementXXX s = case _ of
  Append (SVG tag) -> FFI.appendElement_ tag s
  Append (HTML tag) -> FFI.appendElement_ tag s
-- TODO for insert handle other "before selectors" (and function) instead of fixing it to ":first-child"
  Insert (SVG tag) selector -> FFI.insertElement_ tag selector s
  Insert (HTML tag) selector -> FFI.insertElement_ tag selector s
-- | ********* Tempororary unsafe code in this section  *********
    
filter :: Selection_ -> String -> Selection_
filter s _ = s -- TODO  

