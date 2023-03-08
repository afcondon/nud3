module Nud3.Types where

import Prelude

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

-- the key function is used to order which element of the data array is assigned to which node in the selection
-- if the identity function is used, then the first element of the data array is assigned to the first node in the selection, etc.
-- if the key function is used, then the node with the key value that matches the key function is assigned the data element
-- note that the key function is therefore evaluated twice, once per datum and once per node
type KeyFunction = forall d i. (Ord i) => (Ord d) => d -> Int -> NodeList -> i

-- special case where the datum is used as the key and we just ignore the index and nodes
identityKeyFunction :: KeyFunction
identityKeyFunction d _ _ = unsafeCoerce d -- in the case of the identity function, the key is the datum itself

