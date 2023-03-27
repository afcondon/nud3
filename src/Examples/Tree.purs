module Examples.Tree
  ( FlareCookedModel
  , FlareLinkData
  , FlareLinkObj
  , FlareNodeData
  , FlareNodeRow
  , FlareRawModel
  , FlareSimNode
  , FlareSimRecord
  , FlareTreeNode
  , computeTextAnchor
  , computeX
  , drawTree
  , getTreeAndDrawIt
  , onRHS
  , positionXY
  , positionXYreflected
  , radialRotate
  , radialRotateCommon
  , rotateRadialLabels
  )
  where

import Nud3
import Nud3.Layouts.Hierarchical
import Prelude

import Data.Either as E
import Data.Number (abs, pi)
import Data.Tree (Tree)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff, launchAff_)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Nud3.Attributes (AlignAspectRatio_X(..), AlignAspectRatio_Y(..), AspectRatioPreserve(..), AspectRatioSpec(..), Attribute(..), AttributeSetter, foldAttributes, viewBoxFromNumbers)
import Nud3.Node (D3Link, D3TreeRow, D3_SimulationNode, D3_TreeNode, D3_VxyFxy, D3_XY, EmbeddedData, NodeID)
import Nud3.Scales (d3SchemeCategory10N_)
import Nud3.Tree.JSON (TreeJson_, TreeLayout(..), TreeModel, TreeType(..), getTreeViaAJAX)
import Nud3.Tree.JSON as VizTree
import Nud3.Types (KeyFunction(..))
import Type.Row (type (+))
import Unsafe.Coerce (unsafeCoerce)


-- Model data types specialized with inital data
type FlareNodeRow row = ( name :: String | row )
type FlareNodeData    = { | FlareNodeRow () }

type FlareTreeNode    = D3TreeRow       (EmbeddedData FlareNodeData + ())
-- type FlareSimNode     = D3SimulationRow (             FlareNodeRow  + ())
type FlareSimNode     = D3_SimulationNode (FlareNodeRow + D3_XY + D3_VxyFxy + ())

type FlareLinkData  = ( value :: Number )
type FlareSimRecord = Record (FlareNodeRow  + ()) 
type FlareLinkObj   =  { source :: FlareSimRecord, target :: FlareSimRecord | FlareLinkData }

type FlareRawModel = { 
    links :: Array (D3Link NodeID FlareLinkData)
  , nodes :: Array FlareNodeData
}

-- Pre-swizzling the link target/source are some kind of key to the source/target nodes
-- Post swizzling the link target/source are replaced by references to the actual records
type FlareCookedModel = { 
    links :: Array (D3Link FlareSimRecord FlareLinkData)
  , nodes :: Array FlareNodeData
}

-- | Tree
computeX :: VizTree.TreeLayout -> Boolean -> Number -> Number
computeX layoutStyle hasChildren x =
  case layoutStyle of
    VizTree.Radial ->
      if hasChildren == (x < pi) then 6.0
      else (-6.0)
    _ ->
      if hasChildren then 6.0
      else (-6.0)

computeTextAnchor :: VizTree.TreeLayout -> Boolean -> Number -> String
computeTextAnchor layoutStyle hasChildren x =
  case layoutStyle of
    VizTree.Radial ->
      if hasChildren == (x < pi) then "start"
      else "end"
    _ ->
      if hasChildren then "start"
      else "end"


type TreeDrawConfig d = { 
    layout        :: TreeLayout
  , selector      :: Selector
  , linkPath      :: Attribute d -- has to be a Path attribute
  , spacing       :: { interChild :: Number, interLevel :: Number }
  , viewbox       :: Array (Attribute d) -- has to be a ViewBox attribute and PreservesAspectRatio attribute
  , nodeTransform :: Array (Attribute d) -- has to be one or more Transform attributes
  , color         :: String
  , svg           :: { width :: Number, height :: Number }
  , laidOutRoot_  :: FlareTreeNode
}

drawTree :: forall d. TreeModel -> Effect Unit
drawTree model = do

  let root = select (SelectorString "div#tree")
      config = generateConfig (Tuple 1000.0 1000.0) model

  svg <- addElement root $ Append $ SVG "svg"
  let
    _ = foldAttributes svg $
      config.viewbox <> [ -- TODO put all these attributes into config.viewbox
        Classed "tree"
      , Width 650.0
      , Height 650.0
      ]
  container <- addElement svg $ Append $ SVG "g"
  let _ = foldAttributes container [ FontFamily "sans-serif", FontSize 10.0 ]
  linksGroup <- addElement container $ Append $ SVG "g"
  let _ = foldAttributes linksGroup [ Classed "links" ]
  nodesGroup <- addElement container $ Append $ SVG "g"
  let _ = foldAttributes nodesGroup [ Classed "nodes" ]

  node <- visualize
    { what: Append (SVG "g")
    , "data": NewData $ descendants_ config.laidOutRoot_ -- could use newtype and unwrap here perhaps
    , parent: nodesGroup
    , key: IdentityKey
    , instructions: Compound
        { enter: [] -- group for each circle and its label 
        , exit: [] -- remove is the default
        , update: []
        }
    }
  let _ = foldAttributes node config.nodeTransform
  circles <- addElement node $ Append $ SVG "circle"
  let
    _ = foldAttributes circles
      [ Fill_ \d _ -> if d."data".hasChildren then "#999" else "#555"
      , Radius 2.5
      , StrokeColor "white"
      ]

  labels <- addElement node $ Append $ SVG "text"
  let
    _ = foldAttributes labels
      [ DY 0.31
      , X_ \d _ -> computeX VizTree.Vertical d."data".hasChildren d."data".x
      , Fill "red"
      , Text_ \d _ -> d."data".name
      , TextAnchor_ \d _ -> computeTextAnchor VizTree.Vertical d."data".hasChildren d.x
      ]

  individualLink <- visualize
    { what: Append (SVG "path")
    , "data": NewData $ links_ config.laidOutRoot_
    , parent: linksGroup
    , key: IdentityKey
    , instructions: Simple
        [ StrokeWidth 1.5
        , StrokeColor "orange"
        , StrokeOpacity 0.4
        , Fill "none"
        , Path_ $ unsafeCoerce config.linkPath -- TODO hide coerce in the DSL
        ]
    }
  pure unit

-- | ------------------------ Tree Data ------------------------
-- | get the data from a JSON file using AffJax
-- | ------------------------ Tree Data ------------------------

getTreeAndDrawIt :: Effect Unit
getTreeAndDrawIt = launchAff_ do
  treeJSON <- getTreeViaAJAX "./data/flare-2.json"

  case treeJSON of
    (E.Left err) -> pure unit
    (E.Right (treeJSON :: TreeJson_)) -> do
      model1 <- liftAff $ makeModel TidyTree Radial treeJSON
      model2 <- liftAff $ makeModel Dendrogram Radial treeJSON
      model3 <- liftAff $ makeModel TidyTree Vertical treeJSON
      model4 <- liftAff $ makeModel Dendrogram Vertical treeJSON
      model5 <- liftAff $ makeModel TidyTree Horizontal treeJSON
      model6 <- liftAff $ makeModel Dendrogram Horizontal treeJSON

      _ <- liftEffect $ drawTree model1
      _ <- liftEffect $ drawTree model2
      _ <- liftEffect $ drawTree model3
      _ <- liftEffect $ drawTree model4
      _ <- liftEffect $ drawTree model5
      _ <- liftEffect $ drawTree model6
      
      pure unit
  pure unit

-- | ------------------------ Configure function from TaglessII ------------------------
-- | a generic configuration function that works for vertical, horizontal and radial trees
-- | ------------------------ Configure function from TaglessII ------------------------

generateConfig :: forall t132 t195 t235 t253.
  Tuple Number Number
  -> { json :: TreeJson_
     , treeLayout :: TreeLayout
     , treeType :: TreeType
     | t132
     }
     -> { color :: String
        , laidOutRoot_ :: D3_TreeNode
                            ( data :: { name :: String
                                      }
                            , x :: Number
                            , y :: Number
                            )
        , layout :: TreeLayout
        , linkPath :: { x :: Number
                      , y :: Number
                      | t235
                      }
                      -> Int -> String
        , nodeTransform :: Array
                             (Attribute
                                { x :: Number
                                , y :: Number
                                | t195
                                }
                             )
        , spacing :: { interChild :: Number
                     , interLevel :: Number
                     }
        , svg :: { height :: Number
                 , width :: Number
                 }
        , viewbox :: Array (Attribute t253)
        }
generateConfig (Tuple width height ) model =
  { spacing, viewbox, linkPath, nodeTransform, color, layout: model.treeLayout, svg, laidOutRoot_ }
  where
    svg     = { width, height }

    root    = hierarchyFromJSON_ model.json
    numberOfLevels = (hNodeHeight_ root) + 1.0
    spacing =
      case model.treeType, model.treeLayout of
        Dendrogram, Horizontal -> { interChild: 10.0, interLevel: svg.width / numberOfLevels }
        Dendrogram, Vertical   -> { interChild: 10.0, interLevel: svg.height / numberOfLevels }
        Dendrogram, Radial     -> { interChild: 0.0,  interLevel: 0.0} -- not sure this is used in radial case

        TidyTree, Horizontal   -> { interChild: 10.0, interLevel: svg.width / numberOfLevels }
        TidyTree, Vertical     -> { interChild: 10.0, interLevel: svg.height / numberOfLevels}
        TidyTree, Radial       -> { interChild: 0.0,  interLevel: 0.0} -- not sure this is used in radial case

    layout = 
      if model.treeLayout == Radial
      then ((getLayout model.treeType)  `treeSetSize_`       [ 2.0 * pi, (svg.width / 2.0) - 100.0 ]) 
                                        `treeSetSeparation_` radialSeparation
      else
        (getLayout model.treeType)   `treeSetNodeSize_`   [ spacing.interChild, spacing.interLevel ]

    laidOutRoot_ :: FlareTreeNode
    laidOutRoot_ = layout `runLayoutFn_` root

    { xMin, xMax, yMin, yMax } = treeMinMax_ laidOutRoot_
    xExtent = abs $ xMax - xMin -- ie if tree spans from -50 to 200, it's extent is 250
    yExtent = abs $ yMax - yMin -- ie if tree spans from -50 to 200, it's extent is 250
    radialRadius = yMax  -- on the radial tree the y is the distance from origin, ie yMax == radius
    radialExtent       = 2.0 * radialRadius
    pad n = n * 1.2
    vtreeYOffset = (abs (height - yExtent)) / 2.0
    vtreeXOffset = xMin -- the left and right sides might be different so (xExtent / 2) would not necessarily be right
    htreeYOffset = xMin

    viewbox =
      case model.treeType, model.treeLayout of
        _, Vertical   -> [ viewBoxFromNumbers vtreeXOffset (-vtreeYOffset) (pad xExtent) (pad yExtent) -- 
                         , PreserveAspectRatio $ show $ AspectRatio XMid YMid Meet ]
        _, Horizontal -> [ viewBoxFromNumbers (-xExtent * 0.1) (pad htreeYOffset) (pad yExtent) (pad xExtent)
                         , PreserveAspectRatio $ show $ AspectRatio XMin YMid Meet ] -- x and y are reversed in horizontal layouts
        _, Radial     -> [ viewBoxFromNumbers (-radialRadius * 1.2) (-radialRadius * 1.2)  (radialExtent * 1.2)    (radialExtent * 1.2)
                         , PreserveAspectRatio $ show $ AspectRatio XMin YMin Meet ]
      
    linkPath =
      case model.treeType, model.treeLayout of
        Dendrogram, Horizontal -> horizontalClusterLink spacing.interLevel
        Dendrogram, Vertical   -> verticalClusterLink   spacing.interLevel 
        Dendrogram, Radial     -> radialLink _.x _.y

        TidyTree, Horizontal   -> horizontalLink
        TidyTree, Vertical     -> verticalLink
        TidyTree, Radial       -> radialLink _.x _.y

    nodeTransform =
      case model.treeType, model.treeLayout of
        Dendrogram, Horizontal -> [ Transform_ positionXYreflected ]
        Dendrogram, Vertical   -> [ Transform_ positionXY ]
        Dendrogram, Radial     -> [ Transform_ radialRotateCommon
                                  , Transform_ radialTranslate
                                  , Transform_ rotateRadialLabels ]

        TidyTree, Horizontal   -> [ Transform_ positionXYreflected ]
        TidyTree, Vertical     -> [ Transform_ positionXY ]
        TidyTree, Radial       -> [ Transform_ radialRotateCommon
                                  , Transform_ radialTranslate
                                  , Transform_ rotateRadialLabels ]

    color = d3SchemeCategory10N_ $
      case model.treeType, model.treeLayout of
        Dendrogram, Horizontal -> 1.0
        Dendrogram, Vertical   -> 2.0
        Dendrogram, Radial     -> 3.0

        TidyTree, Horizontal   -> 4.0
        TidyTree, Vertical     -> 5.0
        TidyTree, Radial       -> 6.0

radialRotate :: Number -> String
radialRotate x = show $ (x * 180.0 / pi - 90.0)

radialRotateCommon :: forall r. { x :: Number | r } -> Int -> String
radialRotateCommon d _ = "rotate(" <> radialRotate d.x <> ")"

radialTranslate :: forall r. { y :: Number | r } -> Int -> String
radialTranslate d _ = "translate(" <> show d.y <> ",0)"

rotateRadialLabels :: forall r. { x :: Number | r } -> Int -> String
rotateRadialLabels d _ = -- TODO replace with nodeIsOnRHS 
  "rotate(" <> 
    (if (onRHS Radial d) 
    then "180"
    else "0")
    <> ")"

-- onRHS :: TreeLayout -> TreeDatum_ -> Boolean
onRHS l d = l == Radial && (d.x >= pi)

positionXYreflected :: forall r. { x :: Number, y :: Number | r } -> Int -> String  
positionXYreflected d _ = "translate("  <> show d.y <> "," <> show d.x <>")"

positionXY :: forall r. { x :: Number, y :: Number | r } -> Int -> String  
positionXY d _ = "translate(" <> show d.x <> "," <> show d.y <>")"
