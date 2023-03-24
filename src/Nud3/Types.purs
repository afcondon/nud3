module Nud3.Types
  ( D3SelectorFunction
  , KeyFunction(..)
  , KeyFunctionType1
  , KeyFunctionType2
  , KeyFunctionType3
  , KeyFunctionType4
  , KeyFunction_
  , NodeList
  , Selection_
  , Selector(..)
  , ThisPtr_
  , Transition_
  , UpdateSelection
  )
  where

import Prelude

import Unsafe.Coerce (unsafeCoerce)
import Web.DOM (Node) as DOM

foreign import data Selection_ :: Type -- opaque and mutable data 
foreign import data Transition_ :: Type -- opaque and mutable data 
foreign import data KeyFunction_ :: Type -- opaque type for key functions in JavaScript
foreign import data ThisPtr_ :: Type -- opaque type for "this" in JavaScript, hopefully we never need this one!
foreign import data D3SelectorFunction :: Type

data Selector
  = SelectorString String
  | SelectorFunction (forall d. d -> Int -> NodeList -> Boolean) -- in d3 "this" would be nodes[i] in this function

type NodeList = Array DOM.Node

type UpdateSelection =
  { enter :: Array Unit -- unit is used as a placeholder for the enter nodes
  , exit :: NodeList -- these nodes will most likely be removed
  , update :: Array NodeList -- directly equivalent to the "groups" in a regular selection
  , parents :: Array DOM.Node
  }

-- type Selection =
--   { groups :: Array NodeList
--   , parents :: Array DOM.Node
--   }

-- the key function is used to order which element of the data array is assigned to which node in the selection
-- if the identity function is used, then the first element of the data array is assigned to the first node in the selection, etc.
-- if the key function is used, then the node with the key value that matches the key function is assigned the data element
-- note that the key function is therefore evaluated twice, once per datum and once per node

-- the key function in D3 returns a STRING always, but that seems unnecessarily restrictive in PureScript
-- so we'll maintain a type parameter for the key function type
-- data KeyFunction :: forall k1 k2. k1 -> k2 -> Type
data KeyFunction d i
  = IdentityKey
  | HasIdField -- if there's a way to constrain this, ie forall r. (HasIdField r) => r -> i, that would be great
  | KeyFunction1 (KeyFunctionType1 d i)
  | KeyFunction2 (KeyFunctionType2 d i)
  | KeyFunction3 (KeyFunctionType3 d i)
  | KeyFunction4 (KeyFunctionType4 d i)

-- | two constraints, two dictionaries to be removed to make it work as a javascript function 
type KeyFunctionType1 d i = ((Ord i) => (Ord d) => d -> i) 
type KeyFunctionType2 d i = ((Ord i) => (Ord d) => d -> Int -> i)
type KeyFunctionType3 d i = ((Ord i) => (Ord d) => d -> Int -> NodeList -> i)
type KeyFunctionType4 d i = ((Ord i) => (Ord d) => d -> Int -> NodeList -> ThisPtr_ -> i)

