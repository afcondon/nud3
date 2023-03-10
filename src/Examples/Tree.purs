module Examples.Tree where

import Nud3
import Effect (Effect)
import Nud3.Attributes (Attribute(..))
import Prelude (Unit, bind, negate, pure, unit, ($), (<), (==))

import Data.Number (pi)
import Data.Tree (Tree)
import Nud3.Tree as Tree
import Nud3.Tree as VizTree


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

drawTree :: forall d. Tree d -> Effect Unit
drawTree tree = do

  let root = select (SelectorString "div#tree")

  layoutTreeData <- VizTree.verticalLayout tree
  svg <- appendStyledElement root (SVG "svg")
    [ ViewBox_ 0.0 0.0 650.0 650.0
    , Classed_ "tree"
    , Width_ 650.0
    , Height_ 650.0
    ]
  container <- appendStyledElement svg (SVG "g") [ FontFamily_ "sans-serif", FontSize_ 10.0 ]
  linksGroup <- svg |+| (SVG "g")
  nodesGroup <- svg |+| (SVG "g")

  node <- visualize
    { what: Append (SVG "g")
    , using: NewData $ _.nodes layoutTreeData
    , where: nodesGroup
    , key: identityKeyFunction
    , attributes:
        { enter: [] -- group for each circle and its label 
        , exit: [ Remove ]
        , update: []
        }
    }
  circles <- appendStyledElement node (SVG "circle")
    [ Fill \d i -> if d.hasChildren then "#999" else "#555"
    , Radius_ 2.5
    , StrokeColor_ "white"
    ]

  labels <- appendStyledElement node (SVG "text")
    [ DY_ 0.31
    , X \d i -> computeX Tree.Vertical d.hasChildren d.x
    , Fill_ "red"
    , Text \d i -> d.name
    , TextAnchor \d i -> computeTextAnchor Tree.Vertical d.hasChildren d.x
    ]

  individualLink <- visualize
    { what: Append (SVG "path")
    , using: NewData $ _.nodes layoutTreeData
    , where: linksGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ StrokeWidth_ 1.5
            , StrokeColor_ "orange"
            , StrokeOpacity_ 0.4
            , Fill_ "none"
            ]
        , exit: [ Remove ]
        , update: []
        }
    }
  pure unit

