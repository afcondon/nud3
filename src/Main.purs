
module Main
  ( Action(..)
  , AttrName
  , KeyFunction
  , NodeList
  , Selection
  , Selector(..)
  , UpdateActions
  , UpdateSelection
  , assignDataToSelection
  , identityKeyFunction
  , main
  , selectFirst
  , selectFirstFrom
  , selectGrouped
  , selectMany
  )
  where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM (Element, Node) as DOM

type NodeList = Array DOM.Node

-- corresponds to D3's d3.select
selectFirst :: Selector -> Selection
selectFirst selector = emptySelection -- TODO implement

-- corresponds to D3's d3.selectAll
selectMany :: Selector -> Selection
selectMany selector = emptySelection -- TODO implement

-- corresponds to D3's selection.selectAll
selectGrouped :: Selection -> Selector -> Selection
selectGrouped selection selector = emptySelection  -- TODO implement

-- corresponds to D3's selection.select
selectFirstFrom :: Selection -> Selector -> Selection 
selectFirstFrom selection selector = emptySelection  -- TODO implement

-- if the data is not simply ordered by index, then the key function is used to match the data to the nodes
assignDataToSelection :: forall d. Array d -> KeyFunction -> Selection -> UpdateSelection
assignDataToSelection ds keyFunction selection = emptyEnterSelection  -- TODO implement

-- now that the data has been assigned to the nodes, we can apply the actions to the nodes
-- the actions that are applied to the enter, exit, and update selections are different
-- we end up with a new selection which is the merge of the enter and update selections
applyDataToSelection :: UpdateActions -> UpdateSelection -> Selection
applyDataToSelection actions updateSelection = emptySelection  -- TODO implement

type UpdateActions = { 
    enter :: Array Action
  , exit :: Array Action
  , update :: Array Action
  }

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

emptySelection :: Selection
emptySelection = { groups: [], parents: [] } 

emptyEnterSelection :: UpdateSelection
emptyEnterSelection = { enter: [], exit: [], update: [], parents: [] }

-- the key function is used to order which element of the data array is assigned to which node in the selection
-- if the identity function is used, then the first element of the data array is assigned to the first node in the selection, etc.
-- if the key function is used, then the node with the key value that matches the key function is assigned the data element
-- note that the key function is therefore evaluated twice, once per datum and once per node
type KeyFunction = forall d i. (Ord i) => (Ord d) => d -> Int -> NodeList -> i

-- special case where the datum is used as the key and we just ignore the index and nodes
identityKeyFunction :: KeyFunction
identityKeyFunction d _ _ = unsafeCoerce d -- in the case of the identity function, the key is the datum itself

data Selector = 
      SelectorString String 
    | SelectorFunction (forall d. d -> Int -> NodeList -> Boolean) -- in d3 "this" would be nodes[i] in this function

type AttrName = String -- TODO tighten this up with an ADT and smart constructors later
data Action = 
    Attr AttrName String
  | AttrFunction AttrName (forall d. d -> Int -> NodeList -> d) -- no type checking of attr values at this time
  | Style
  | Remove
  | Append DOM.Element
  | Insert DOM.Element
  | Transition (Array Action) -- these are all function that chain on selections in the JavaScript universe

main :: Effect Unit
main = do
  log "🍝"

