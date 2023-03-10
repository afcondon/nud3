module Nud3.Tree
  ( LaidOutTree(..)
  , TreeLayout(..)
  , TreeLink(..)
  , TreeNode(..)
  , getNodes
  , horizontalLayout
  , radialLayout
  , verticalLayout
  )
  where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Tree as Tree
import Effect (Effect)
  
-- temporary definition, revisit taglessD3 for the correct solution later
-- the Tree will necessarily be a mutable structure, should be hidden behind the FFI
newtype LaidOutTree a = LaidOutTree {
    nodes :: Array (TreeNode a)
  , links :: Array TreeLink -- later probably necessarily mutable object references 
  , layout :: TreeLayout
}
derive instance genericLaidOutTree :: (Show a) => Generic (LaidOutTree a) _
instance showLaidOutTree :: (Show a) => Show (LaidOutTree a) where
  show = genericShow

newtype TreeNode a = TreeNodes {
    nodes :: { id :: Int, nodedata :: a, x :: Number, y :: Number, hasChildren :: Boolean  }
  }
derive instance genericTreeNode :: (Show a) => Generic (TreeNode a) _
instance showTreeNode :: (Show a) => Show (TreeNode a) where
  show = genericShow

newtype TreeLink = TreeLink { id :: String, source :: Int, target :: Int} -- we'll use "show 'src id' + 'target id'" as the id
derive instance genericTreeLink :: Generic TreeLink _
instance showTreeLink :: Show TreeLink where
  show = genericShow



getNodes :: forall a. LaidOutTree a -> Array (TreeNode a)
getNodes (LaidOutTree tree)= tree.nodes

data TreeLayout = Vertical | Horizontal | Radial
derive instance genericTreeLayout :: Generic TreeLayout _

instance showTreeLayout :: Show TreeLayout where
  show = genericShow

verticalLayout :: forall a. Tree.Tree a -> Effect (LaidOutTree a)
verticalLayout tree = 
  pure $ LaidOutTree {
    nodes: []
  , links: []
  , layout: Vertical
  }
horizontalLayout :: forall a. Tree.Tree a -> Effect (LaidOutTree a)
horizontalLayout tree = 
  pure $ LaidOutTree {
    nodes: []
  , links: []
  , layout: Horizontal
  }
radialLayout :: forall a. Tree.Tree a -> Effect (LaidOutTree a)
radialLayout tree = 
  pure $ LaidOutTree {
    nodes: []
  , links: []
  , layout: Radial
  }
