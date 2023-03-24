module Nud3
  ( AddElement(..)
  , DataSource(..)
  , Element(..)
  , Instructions(..)
  , JoinConfig
  , NodeList
  , Selector(..)
  , UpdateSelection
  , addElement
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
import Effect (Effect)
import Effect.Unsafe (unsafePerformEffect)
import Nud3.Attributes (Attribute, foldAttributes)
import Nud3.FFI 
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

showSelection :: Selection_ -> String
showSelection s = "Selection named: " <> FFI.getName_ s

type JoinConfig d i = { 
    what :: AddElement
  , parent :: Selection_
  , "data" :: DataSource d
  , key :: KeyFunction d i 
  , instructions :: Instructions d
  }
data Instructions d = 
    Simple (Array (Attribute d))
  | Compound {
      enter :: Array (Attribute d)
    , update :: Array (Attribute d)
    , exit :: Array (Attribute d)
  } 

instance showInstructions :: (Show d) => Show (Instructions d) where
  show (Simple attrs) = show attrs
  show (Compound attrs) = "enter: " <> show attrs.enter <> ", update: " <> show attrs.update <> ", exit: " <> show attrs.exit
  
showJoin :: forall d i. (Show d) => JoinConfig d i -> String
showJoin join = "Join details: { \n" <>
  "\twhat: " <> show join.what <>
  "\n\tparent: " <> showSelection join.parent <>
  "\n\tdata: " <> show join."data" <>
  "\n\tkey: (function)" <>
  "\n\tinstructcions: " <> show join.instructions

data DataSource d = 
   InheritData -- HER-12 NB this will fail if there is no data attached to the parent (TODO DSL should protect against this)
 | NewData (Array d)

instance showDataSource :: (Show d) => Show (DataSource d) where
  show InheritData = "data is inherited from parent"
  show (NewData ds) = "data is new" <> show ds
else
instance showDataSourceSimple :: Show (DataSource Unit) where
  show InheritData = "data is inherited from parent"
  show (NewData _) = "data is new, but no show instance exists to show it"

getElementName :: AddElement -> String
getElementName (Append (SVG tag)) = tag
getElementName (Insert (SVG tag) _) = tag
getElementName (Append (HTML tag)) = tag
getElementName (Insert (HTML tag) _) = tag

data Element = SVG String | HTML String

derive instance genericElement :: Generic Element _

instance showElement :: Show Element where
  show = genericShow

data AddElement = Append Element | Insert Element String -- HER-11 TODO this String should be a "BeforeSelector"
derive instance genericAddElement :: Generic AddElement _
instance showAddElement :: Show AddElement where
  show = genericShow

-- | DSL functions below this line

select :: Selector -> Selection_
select = case _ of
  (SelectorString s) -> FFI.selectManyWithString_ s
  (SelectorFunction f) -> unsafeCoerce $ FFI.selectManyWithFunction_ (unsafeCoerce f)

addElement :: Selection_ -> AddElement -> Effect Selection_
addElement s = case _ of
  Append (SVG tag) -> pure $ FFI.appendElement_ tag s
  Append (HTML tag) -> pure $ FFI.appendElement_ tag s
-- HER-11 TODO for insert handle other "before selectors" (and function) instead of fixing it to ":first-child"
  Insert (SVG tag) selector -> pure $ FFI.insertElement_ tag selector s
  Insert (HTML tag) selector -> pure $ FFI.insertElement_ tag selector s

-- | visualize replaces the (config.where).selectAll(config.what).data(config.using).append(config.what) 
-- | chain in d3 with a single function
-- | there are some major simplifications here vis-a-vis the D3 selection.join
visualize :: forall d i. JoinConfig d i -> Effect Selection_
visualize config = do
  -- FFI.prepareJoin uses underlying call to selection.selectAll(element) 
  let prepped = FFI.prepareJoin_ config.parent (getElementName config.what)
  -- we get a "javascript consumable" function from our keyFunction ADT
  -- if a lambda has been provided, then we have uncurried it already
  -- could add further "canned" key functions here if they are needed too, or custom FFI. 
  let keyFunction = 
        case config.key of
          IdentityKey -> FFI.identityKey_
          HasIdField -> FFI.idKey_
          (KeyFunction1 f) -> makeKeyFunction1_ f
          (KeyFunction2 f) -> makeKeyFunction2_ f
          (KeyFunction3 f) -> makeKeyFunction3_ f
          (KeyFunction4 f) -> makeKeyFunction4_ f
  -- both branches here use the same underlying call to selection.data(data, key)
  let hasData = case config."data" of
              InheritData -> FFI.useInheritedData_ prepped keyFunction
              NewData ds -> FFI.addData_ prepped ds keyFunction
  -- FFI.completeJoin_ provides functions for each of the three selections: enter, update and exit
  case config.instructions of
    Compound attrs -> pure $ FFI.completeJoin_ hasData {
      enterFn: \enter -> foldAttributes (addElementXXX enter config.what) attrs.enter
    , updateFn: \update -> foldAttributes update attrs.update
    , exitFn: \exit ->  foldAttributes exit attrs.exit
    }
    Simple attrs -> pure $ FFI.completeJoin_ hasData {
        enterFn: \enter -> foldAttributes (addElementXXX enter config.what) attrs
      , updateFn: \update -> update
      , exitFn: \exit ->  exit
    }

-- | ********* Tempororary unsafe code in this section  *********
-- This code is here just to keep the Effect Selection out of the completeJoin_ function
-- This is clearly wrong but it's a temporary hack to get things working
addElementXXX :: Selection_ -> AddElement -> Selection_
addElementXXX s e = unsafePerformEffect $ addElement s e
-- | ********* Tempororary unsafe code in this section  *********
    
filter :: Selection_ -> String -> Selection_
filter s _ = s -- HER-13 TODO  

