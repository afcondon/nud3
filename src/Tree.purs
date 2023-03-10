module Nud3.Tree where

import Prelude
import Data.Tree as Tree

import Effect (Effect)
  
-- temporary definition, revisit taglessD3 for the correct solution later
-- the Tree will necessarily be a mutable structure, should be hidden behind the FFI
type LaidOutTree a = {
    nodes :: Array { id :: Int, nodedata :: a, x :: Number, y :: Number }
  , links :: Array { source :: Int, target :: Int } -- later probably actual mutable object references FFI
  , layout :: TreeLayout
}

data TreeLayout = Vertical | Horizontal | Radial

verticalLayout :: forall a. Tree.Tree a -> Effect (LaidOutTree a)
verticalLayout tree = 
  pure {
    nodes: []
  , links: []
  , layout: Vertical
  }
horizontalLayout :: forall a. Tree.Tree a -> Effect (LaidOutTree a)
horizontalLayout tree = 
  pure {
    nodes: []
  , links: []
  , layout: Horizontal
  }
radialLayout :: forall a. Tree.Tree a -> Effect (LaidOutTree a)
radialLayout tree = 
  pure {
    nodes: []
  , links: []
  , layout: Radial
  }
