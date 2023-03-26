module Examples.Tree where

import Nud3
import Nud3.Layouts.Hierarchical

import Data.Either as E
import Data.Number (pi)
import Data.Tree (Tree)
import Effect (Effect)
import Effect.Aff (Aff, launchAff, launchAff_)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Nud3.Attributes (Attribute(..), foldAttributes)
import Nud3.Tree.JSON (TreeJson_, TreeLayout(..), TreeType(..), TreeModel, getTreeViaAJAX)
import Nud3.Tree.JSON as VizTree
import Nud3.Types (KeyFunction(..))
import Prelude (class Show, Unit, bind, discard, negate, pure, unit, ($), (<), (==))

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

drawTree :: TreeModel -> Effect Unit
drawTree tree = do

  let root = select (SelectorString "div#tree")

  -- layoutTreeData <- VizTree.verticalLayout tree
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
    , "data": NewData [] -- $ VizTree.getNodes layoutTreeData -- could use newtype and unwrap here perhaps
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
    , "data": NewData [] -- $ VizTree.getNodes layoutTreeData
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
