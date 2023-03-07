
module Main  where

import Nud3.Types
import Prelude

import Effect (Effect)
import Effect.Console (log)
import Nud3.FFI as FFI
import Unsafe.Coerce (unsafeCoerce)


-- corresponds to D3's d3.select
selectFirst :: Selector -> Selection
selectFirst = FFI.selectFirst

-- corresponds to D3's d3.selectAll
selectMany :: Selector -> Selection
selectMany = FFI.selectMany

-- corresponds to D3's selection.selectAll
selectGrouped :: Selection -> Selector -> Selection
selectGrouped = FFI.selectGrouped

-- corresponds to D3's selection.select
selectFirstFrom :: Selection -> Selector -> Selection 
selectFirstFrom = FFI.selectFirstFrom

-- if the data is not simply ordered by index, then the key function is used to match the data to the nodes
assignDataToSelection :: forall d. Selection -> Array d -> KeyFunction -> UpdateSelection
assignDataToSelection selection ds keyFunction = emptyEnterSelection  -- TODO implement

subdivideData :: Selection -> KeyFunction -> UpdateSelection
subdivideData selection keyFunction = emptyEnterSelection  -- TODO implement

-- now that the data has been assigned to the nodes, we can apply the actions to the nodes
-- the actions that are applied to the enter, exit, and update selections are different
-- we end up with a new selection which is the merge of the enter and update selections
applyDataToSelection :: UpdateSelection -> UpdateActions -> Selection
applyDataToSelection updateSelection actions = emptySelection  -- TODO implement

type UpdateActions = { 
    enter :: Array Action
  , exit :: Array Action
  , update :: Array Action
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

-- appendToSelection :: Selection -> DOM.Element -> Selection
appendToSelection :: Selection -> String -> Selection
appendToSelection selection element = emptySelection -- TODO implement

-- insertBeforeSelection :: Selection -> DOM.Element -> Selection
insertBeforeSelection :: Selection -> String -> Selection
insertBeforeSelection selection element = emptySelection -- TODO implement

type AttrName = String -- TODO tighten this up with an ADT and smart constructors later
type ElementName = String -- TODO tighten this up with an ADT and smart constructors later

data Action = -- TODO check out that these actions are legit for all Selections
    Attr AttrName String
  | AttrFunction AttrName (forall d. d -> Int -> NodeList -> d) -- no type checking of attr values at this time
  | Style
  | Remove
  | Append ElementName
  | Insert ElementName
  | Transition (Array Action) -- these are all function that chain on selections in the JavaScript universe

matrix2Table :: Effect Unit
matrix2Table = do
  let one = selectFirst (SelectorString "body")
      two = appendToSelection one "table"
      three = selectMany (SelectorString "tr")
      four = assignDataToSelection three [[1,2,3],[4,5,6],[7,8,9]] identityKeyFunction
      five = applyDataToSelection four
              { enter: [Append "tr"]
              , exit: [Remove]
              , update: [] 
              }
      six = selectGrouped five (SelectorString "td")
      seven = subdivideData six identityKeyFunction
      eight = applyDataToSelection seven
              { enter: [Append "td"]
              , exit: [Remove]
              , update: [Attr "class" "cell"] 
              }
  log "🍝"

main :: Effect Unit
main = do
  log "🍝"

