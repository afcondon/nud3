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
import Nud3.Attributes (AlignAspectRatio_X(..), AlignAspectRatio_Y(..), AspectRatioPreserve(..), AspectRatioSpec(..), Attribute(..), foldAttributes, viewBoxFromNumbers)
import Nud3.Node (D3Link, D3TreeRow, D3_SimulationNode, D3_VxyFxy, D3_XY, EmbeddedData, NodeID)
import Nud3.Scales (d3SchemeCategory10N_)
import Nud3.Tree.JSON (TreeJson_, TreeLayout(..), TreeType(..), TreeModel, getTreeViaAJAX)
import Nud3.Tree.JSON as VizTree
import Nud3.Types (KeyFunction(..))
import Type.Row (type (+))


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

type FlareCookedModel = { 
    links :: Array (D3Link NodeID FlareLinkData)
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
    _ = foldAttributes svg
      [ ViewBox 0 0 650 650
      , Classed "tree"
      , Width 650.0
      , Height 650.0
      ]
  container <- addElement svg $ Append $ SVG "g"
  let _ = foldAttributes container [ FontFamily "sans-serif", FontSize 10.0 ]
  linksGroup <- addElement svg $ Append $ SVG "g"
  nodesGroup <- addElement svg $ Append $ SVG "g"

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
  circles <- addElement node $ Append $ SVG "circle"
  let
    _ = foldAttributes circles
      [ Fill_ \d _ -> if d.hasChildren then "#999" else "#555"
      , Radius 2.5
      , StrokeColor "white"
      ]

  labels <- addElement node $ Append $ SVG "text"
  let
    _ = foldAttributes labels
      [ DY 0.31
      , X_ \d _ -> computeX VizTree.Vertical d.hasChildren d.x
      , Fill "red"
      , Text_ \d _ -> d.name
      , TextAnchor_ \d _ -> computeTextAnchor VizTree.Vertical d.hasChildren d.x
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
      model <- liftAff $ makeModel TidyTree Vertical treeJSON

      tree <- liftEffect $ drawTree model
      -- tree <- liftAff $ Tree.drawTree model "div.svg-container"
      pure unit
  pure unit

-- | ------------------------ Configure function from TaglessII ------------------------
-- | all the configuration for different tree types and layouts
-- | ------------------------ Configure function from TaglessII ------------------------

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
