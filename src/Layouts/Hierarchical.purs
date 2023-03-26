module Nud3.Layouts.Hierarchical where

import Nud3.Node

import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web (Error, URL)
import Affjax.Web as AJAX
import Data.Bifunctor (rmap)
import Data.Either (Either)
import Data.Function.Uncurried (Fn2, mkFn2)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect.Aff (Aff)
import Nud3.Attributes (Attribute(..))
import Nud3.Tree.JSON (TreeJson_, TreeLayout, TreeLayoutFn_, TreeModel, TreeType(..))
import Prelude (Unit, bind, pure, unit, ($), (/))

find :: forall d r. D3_TreeNode r -> (d -> Boolean) -> Maybe (D3_TreeNode r)
find tree filter = toMaybe $ find_ tree filter

makeModel :: TreeType -> 
  TreeLayout ->
  TreeJson_ -> 
  Aff TreeModel
makeModel treeType treeLayout json = do
  let 
    -- svgConfig  = { width: fst widthHeight, height: snd widthHeight }
    treeLayoutFn = getLayout treeType -- REVIEW why not run this here and fill in root_ ?
    svgConfig    = { width: 650.0, height: 650.0 }
  pure $ { json, treeType, treeLayout, treeLayoutFn, svgConfig }


-- not clear if we really want to write all these in PureScript, there is no Eq instance for parents etc
-- but it will at least serve as documentation
-- OTOH if it can be nicely written here, so much the better as custom separation and all _is_ necessary
defaultSeparation :: forall d. Fn2 (D3_TreeNode d) (D3_TreeNode d) Number
defaultSeparation = mkFn2 (\a b -> if (sharesParent_ a b) 
                                   then 1.0
                                   else 2.0)

radialSeparation :: forall r. Fn2 (D3_TreeNode r) (D3_TreeNode r) Number 
radialSeparation  = mkFn2 (\a b -> if (sharesParent_ a b) 
                                   then 1.0 
                                   else 2.0 / (hNodeDepth_ a))

horizontalLink :: forall d. Attribute d
horizontalLink = Path "TODO" -- AttrT $ AttributeSetter "d" $ toAttr linkHorizontal_

-- version for when the x and y point are already swapped
-- should be default someday
horizontalLink' :: forall d. Attribute d
horizontalLink' = Path "TODO" -- AttrT $ AttributeSetter "d" $ toAttr linkHorizontal2_

verticalLink :: forall d. Attribute d
verticalLink = Path "TODO" -- AttrT $ AttributeSetter "d" $ toAttr linkVertical_

horizontalClusterLink :: forall d. Number -> Attribute d
horizontalClusterLink yOffset = Path "TODO" -- AttrT $ AttributeSetter "d" $ toAttr (linkClusterHorizontal_ yOffset)

verticalClusterLink :: forall d. Number -> Attribute d
verticalClusterLink xOffset = Path "TODO" -- AttrT $ AttributeSetter "d" $ toAttr (linkClusterVertical_ xOffset)

radialLink :: forall d. (d -> Number) -> (d -> Number) -> Attribute d
radialLink angleFn radius_Fn = do
  let radialFn = linkRadial_ angleFn radius_Fn
  Path "TODO" -- AttrT $ AttributeSetter "d" $ toAttr radialFn


-- | stuff taken from D3.Tagless FFI
foreign import find_            :: forall d r. D3_TreeNode r -> (d -> Boolean) -> Nullable (D3_TreeNode r)
foreign import sharesParent_          :: forall r. (D3_TreeNode r) -> (D3_TreeNode r) -> Boolean

foreign import linkHorizontal_        :: forall d. (d -> String) 
foreign import linkHorizontal2_       :: forall d. (d -> String) 
foreign import linkVertical_          :: forall d. (d -> String) 
foreign import linkClusterHorizontal_ :: forall d. Number -> (d -> String) 
foreign import linkClusterVertical_   :: forall d. Number -> (d -> String) 
foreign import linkRadial_            :: forall d. (d -> Number) -> (d -> Number) -> (d -> String)

-- accessors for fields of D3HierarchicalNode, only valid if layout has been done, hence the _XY version of node
-- REVIEW maybe accessors aren't needed if you can ensure type safety
foreign import hNodeDepth_  :: forall r. D3_TreeNode r -> Number
foreign import hNodeHeight_ :: forall r. D3_TreeNode r -> Number
foreign import hNodeX_      :: forall r. D3_TreeNode r -> Number
foreign import hNodeY_      :: forall r. D3_TreeNode r -> Number



getLayout :: TreeType -> TreeLayoutFn_
getLayout layout = do
  case layout of
    TidyTree   -> getTreeLayoutFn_ unit
    Dendrogram -> getClusterLayoutFn_ unit

foreign import getTreeLayoutFn_       :: Unit -> TreeLayoutFn_
foreign import getClusterLayoutFn_    :: Unit -> TreeLayoutFn_
