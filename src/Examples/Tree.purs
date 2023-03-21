module Examples.Tree where

import Nud3

import Data.Number (pi)
import Data.Tree (Tree)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), foldAttributes)
import Nud3.Tree as VizTree
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
  let _ = foldAttributes svg
            [ ViewBox_ 0 0 650 650
            , Classed_ "tree"
            , Width_ 650.0
            , Height_ 650.0
            ]
  container <- addElement svg $ Append $ SVG "g"
  let _ = foldAttributes container [ FontFamily_ "sans-serif", FontSize_ 10.0 ]
  linksGroup <- addElement svg $ Append $ SVG "g"
  nodesGroup <- addElement svg $ Append $ SVG "g"

  node <- visualize
    { what: Append (SVG "g")
    , using: NewData $ VizTree.getNodes layoutTreeData -- could use newtype and unwrap here perhaps
    , where: nodesGroup
    , key: identityKeyFunction
    , attributes:
        { enter: [] -- group for each circle and its label 
        , exit: [] -- remove is the default
        , update: []
        }
    }
  circles <- addElement node $ Append $ SVG "circle"
  let _ = foldAttributes circles
            [ Fill \d _ -> if d.hasChildren then "#999" else "#555"
            , Radius_ 2.5
            , StrokeColor_ "white"
            ]

  labels <- addElement node $ Append $ SVG "text"
  let _ = foldAttributes labels
              [ DY_ 0.31
              , X \d _ -> computeX VizTree.Vertical d.hasChildren d.x
              , Fill_ "red"
              , Text \d _ -> d.name
              , TextAnchor \d _ -> computeTextAnchor VizTree.Vertical d.hasChildren d.x
              ]

  individualLink <- visualize
    { what: Append (SVG "path")
    , using: NewData $ VizTree.getNodes layoutTreeData
    , where: linksGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ StrokeWidth_ 1.5
            , StrokeColor_ "orange"
            , StrokeOpacity_ 0.4
            , Fill_ "none"
            ]
        , exit: [] -- remove is the default
        , update: []
        }
    }
  pure unit

