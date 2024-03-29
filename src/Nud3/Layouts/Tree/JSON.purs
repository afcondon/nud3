module Nud3.Hierarchical.Tree.JSON -- TODO separate the Tree defs from the JSON reading?
  ( TreeJson_
  , TreeLayout(..)
  , TreeLayoutFn_
  , TreeModel
  , TreeType(..)
  , getTreeViaAJAX
  , makeD3TreeJSONFromTreeID
  )
  where

import Prelude

import Affjax (Error, URL)
import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web as AJAX
import Data.Array as A
import Data.Bifunctor (rmap)
import Data.Either (Either)
import Data.List (List(..))
import Data.Map as M
import Data.Maybe (Maybe(..))
import Data.Tree (Tree(..))
import Effect.Aff (Aff)
import Nud3.Graph.Node (NodeID)

foreign import data TreeJson_ :: Type
foreign import emptyTreeJson_ :: TreeJson_

data TreeType   = TidyTree | Dendrogram
derive instance eqTreeType :: Eq TreeType
instance showTreeType :: Show TreeType where
  show TidyTree = "Tidy Tree"
  show Dendrogram = "Dendrogram"

data TreeLayout = Radial | Horizontal | Vertical
derive instance eqTreeLayout :: Eq TreeLayout
instance showTreeLayout :: Show TreeLayout where
  show Radial = "Radial"
  show Horizontal = "Horizontal"
  show Vertical = "Vertical"

type TreeModel = {
      json         :: TreeJson_                      -- data from file
    , treeType     :: TreeType
    , treeLayout   :: TreeLayout
    , treeLayoutFn :: TreeLayoutFn_
    , svgConfig    :: { width :: Number, height :: Number }
}

foreign import data TreeLayoutFn_ :: Type

-- | this function is to be used when you have a Tree ID, ie the id is already present for D3
-- | so you likely just want a tree that can be laid out
-- | in order to get the (x,y), height, depth etc that are initialized by a D3 tree layout
-- | it does copy the name over because actually that is going to be needed for sorting in order
-- | to make a tidy tree (radial in our spago example)
makeD3TreeJSONFromTreeID :: forall d. Tree NodeID -> M.Map NodeID d -> TreeJson_
makeD3TreeJSONFromTreeID root nodesMap = go root
  where 
    go (Node id children)      = 
      case M.lookup id nodesMap of
        Nothing    -> emptyTreeJson_ -- TODO think of a more principled way to handle this
        (Just obj) -> case children of
                        Nil -> idTreeLeaf_ obj
                        _   -> idTreeParent_ obj (go <$> (A.fromFoldable children))

foreign import idTreeLeaf_   :: forall d. d -> TreeJson_
foreign import idTreeParent_ :: forall d. d -> Array TreeJson_ -> TreeJson_

getTreeViaAJAX :: URL -> Aff (Either Error TreeJson_)
getTreeViaAJAX url = do
  result <- AJAX.get ResponseFormat.string url
  pure $ rmap (\{body} -> readJSON_ body) result  

foreign import readJSON_                :: String -> TreeJson_ -- TODO no error handling at all here RN
