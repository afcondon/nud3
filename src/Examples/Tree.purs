module Examples.Tree where

import Nud3

import Data.Number (pi)
import Data.Tree (Tree)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), foldAttributes)
import Nud3.Tree as VizTree
import Nud3.Types (KeyFunction(..))
import Prelude (class Show, Unit, bind, negate, pure, unit, ($), (<), (==))

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

drawTree :: forall d. (Show d) => Tree d -> Effect Unit
drawTree tree = do

  let root = select (SelectorString "div#tree")

  layoutTreeData <- VizTree.verticalLayout tree
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
    , using: NewData $ VizTree.getNodes layoutTreeData -- could use newtype and unwrap here perhaps
    , where: nodesGroup
    , key: IdentityKey
    , attributes:
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
    , using: NewData $ VizTree.getNodes layoutTreeData
    , where: linksGroup
    , key: IdentityKey
    , attributes:
        { enter:
            [ StrokeWidth 1.5
            , StrokeColor "orange"
            , StrokeOpacity 0.4
            , Fill "none"
            ]
        , exit: [] -- remove is the default
        , update: []
        }
    }
  pure unit

