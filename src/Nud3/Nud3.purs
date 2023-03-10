module Nud3 where

import Nud3.Types
import Prelude

import Effect (Effect)
import Effect.Console (log)
import Nud3.FFI as FFI
import Unsafe.Coerce (unsafeCoerce)

-- corresponds to D3's d3.select
selectOne :: Selector -> Selection
selectOne = FFI.selectFirst

-- corresponds to D3's d3.selectAll
selectMultiple :: Selector -> Selection
selectMultiple = FFI.selectMany

-- corresponds to D3's selection.selectAll
selectGrouped :: Selection -> Selector -> Selection
selectGrouped = FFI.selectGrouped

-- corresponds to D3's selection.select
selectFirstFrom :: Selection -> Selector -> Selection
selectFirstFrom = FFI.selectFirstFrom

-- if the data is not simply ordered by index, then the key function is used to match the data to the nodes
assignDataArray :: forall d. Selection -> Array d -> KeyFunction -> UpdateSelection
assignDataArray = FFI.dataBind

subdivideData :: Selection -> KeyFunction -> UpdateSelection
subdivideData selection keyFunction = emptyEnterSelection -- TODO implement

-- now that the data has been assigned to the nodes, we can apply the actions to the nodes
-- the actions that are applied to the enter, exit, and update selections are different
-- we end up with a new selection which is the merge of the enter and update selections
applyDataToSelection :: UpdateSelection -> UpdateActions -> Selection
applyDataToSelection updateSelection actions = emptySelection -- TODO implement

type UpdateActions =
  { enter :: Array Action
  , exit :: Array Action
  , update :: Array Action
  }

emptySelection :: Selection
emptySelection = { groups: [], parents: [] }

emptyEnterSelection :: UpdateSelection
emptyEnterSelection = { enter: [], exit: [], update: [], parents: [] }

-- appendTo :: Selection -> DOM.Element -> Selection
appendTo :: Selection -> String -> Selection
appendTo selection element = emptySelection -- TODO implement

-- insertBeforeSelection :: Selection -> DOM.Element -> Selection
insertBeforeSelection :: Selection -> String -> Selection
insertBeforeSelection selection element = emptySelection -- TODO implement

type AttrName = String -- TODO tighten this up with an ADT and smart constructors later
type ElementName = String -- TODO tighten this up with an ADT and smart constructors later

data Action
  = -- TODO check out that these actions are legit for all Selections
    Attr AttrName String
  | AttrFunction AttrName (forall d. d -> Int -> NodeList -> d) -- no type checking of attr values at this time
  | Style
  | Remove
  | Append ElementName
  | Insert ElementName
  | Transition (Array Action) -- these are all function that chain on selections in the JavaScript universe

matrix2Table :: Effect Unit
matrix2Table = do
  let
    one = selectOne (SelectorString "body") -- this is a single group with a single node (the body), parent is <html>
    two = appendTo one "table" -- this is a single group with a single node (the table), parent is still <html>
    three = selectGrouped two (SelectorString "tr") -- 
    four = assignDataArray three [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ] identityKeyFunction
    five = applyDataToSelection four
      { enter: [ Append "tr" ]
      , exit: [ Remove ]
      , update: []
      }
    six = selectGrouped five (SelectorString "td")
    seven = subdivideData six identityKeyFunction
    eight = applyDataToSelection seven
      { enter: [ Append "td" ]
      , exit: [ Remove ]
      , update: [ Attr "class" "cell" ]
      }
  log "🍝"