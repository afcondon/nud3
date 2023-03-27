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
import Nud3.Attributes (Attribute(..), AttributeSetter_, AttributeSetter)
import Nud3.Tree.JSON (TreeJson_, TreeLayout, TreeLayoutFn_, TreeModel, TreeType(..))
import Prelude (Unit, bind, pure, unit, ($), (/))

find :: forall d r. D3_TreeNode r -> (d -> Boolean) -> Maybe (D3_TreeNode r)
find tree filter = toMaybe $ find_ tree filter

makeModel
  :: TreeType
  -> TreeLayout
  -> TreeJson_
  -> Aff TreeModel
makeModel treeType treeLayout json = do
  let
    -- svgConfig  = { width: fst widthHeight, height: snd widthHeight }
    treeLayoutFn = getLayout treeType -- REVIEW why not run this here and fill in root_ ?
    svgConfig = { width: 650.0, height: 650.0 }
  pure $ { json, treeType, treeLayout, treeLayoutFn, svgConfig }

-- not clear if we really want to write all these in PureScript, there is no Eq instance for parents etc
-- but it will at least serve as documentation
-- OTOH if it can be nicely written here, so much the better as custom separation and all _is_ necessary
defaultSeparation :: forall d. Fn2 (D3_TreeNode d) (D3_TreeNode d) Number
defaultSeparation = mkFn2
  ( \a b ->
      if (sharesParent_ a b) then 1.0
      else 2.0
  )

radialSeparation :: forall r. Fn2 (D3_TreeNode r) (D3_TreeNode r) Number
radialSeparation = mkFn2
  ( \a b ->
      if (sharesParent_ a b) then 1.0
      else 2.0 / (hNodeDepth_ a)
  )

horizontalLink :: forall d. AttributeSetter d String
horizontalLink d _ = linkHorizontal_ d

-- version for when the x and y point are already swapped
-- should be default someday
horizontalLink' :: forall d. AttributeSetter d String
horizontalLink' d _ = linkHorizontal2_ d

verticalLink :: forall d. AttributeSetter d String
verticalLink d _ = linkVertical_ d

horizontalClusterLink :: forall d. Number -> AttributeSetter d String
horizontalClusterLink yOffset = \d _ -> (linkClusterHorizontal_ yOffset d)

verticalClusterLink :: forall d. Number -> AttributeSetter d String
verticalClusterLink xOffset = \d _ -> (linkClusterVertical_ xOffset d)

radialLink :: forall d. (d -> Number) -> (d -> Number) -> AttributeSetter d String
radialLink angleFn radius_Fn = \d _ -> linkRadial_ angleFn radius_Fn d

-- | stuff taken from D3.Tagless FFI
-- the full API for hierarchical nodes:
-- TODO these should all be operating on cooked tree type, however that is to be done
foreign import descendants_ :: forall r. D3_TreeNode r -> Array (D3_TreeNode r)
foreign import links_ :: forall d r1 r2. D3_TreeNode r1 -> Array (D3Link d r2)
foreign import ancestors_ :: forall r. D3_TreeNode r -> Array (D3_TreeNode r)
foreign import leaves_ :: forall r. D3_TreeNode r -> Array (D3_TreeNode r)
foreign import path_ :: forall r. D3_TreeNode r -> D3_TreeNode r -> Array (D3_TreeNode r)
foreign import find_ :: forall d r. D3_TreeNode r -> (d -> Boolean) -> Nullable (D3_TreeNode r)
foreign import sharesParent_ :: forall r. (D3_TreeNode r) -> (D3_TreeNode r) -> Boolean

foreign import linkHorizontal_ :: forall d. (d -> String)
foreign import linkHorizontal2_ :: forall d. (d -> String)
foreign import linkVertical_ :: forall d. (d -> String)
foreign import linkClusterHorizontal_ :: forall d. Number -> (d -> String)
foreign import linkClusterVertical_ :: forall d. Number -> (d -> String)
foreign import linkRadial_ :: forall d. (d -> Number) -> (d -> Number) -> (d -> String)

-- accessors for fields of D3HierarchicalNode, only valid if layout has been done, hence the _XY version of node
-- REVIEW maybe accessors aren't needed if you can ensure type safety
foreign import hNodeDepth_ :: forall r. D3_TreeNode r -> Number
foreign import hNodeHeight_ :: forall r. D3_TreeNode r -> Number
foreign import hNodeX_ :: forall r. D3_TreeNode r -> Number
foreign import hNodeY_ :: forall r. D3_TreeNode r -> Number

getLayout :: TreeType -> TreeLayoutFn_
getLayout layout = do
  case layout of
    TidyTree -> getTreeLayoutFn_ unit
    Dendrogram -> getClusterLayoutFn_ unit

foreign import getTreeLayoutFn_ :: Unit -> TreeLayoutFn_
foreign import getClusterLayoutFn_ :: Unit -> TreeLayoutFn_

foreign import hierarchyFromJSON_ :: forall d. TreeJson_ -> D3_TreeNode d

foreign import treeSetSeparation_ :: forall d. TreeLayoutFn_ -> (Fn2 (D3_TreeNode d) (D3_TreeNode d) Number) -> TreeLayoutFn_
foreign import treeSetSize_ :: TreeLayoutFn_ -> Array Number -> TreeLayoutFn_
foreign import treeSetNodeSize_ :: TreeLayoutFn_ -> Array Number -> TreeLayoutFn_
foreign import runLayoutFn_ :: forall r. TreeLayoutFn_ -> D3_TreeNode r -> D3_TreeNode r
foreign import treeMinMax_ :: forall d. D3_TreeNode d -> { xMin :: Number, xMax :: Number, yMin :: Number, yMax :: Number }
