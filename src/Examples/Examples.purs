module Examples where

import Effect
import Nud3.Attributes
import Nud4
import Prelude

import Data.Array (singleton)
import Data.Int (toNumber)
import Data.String.CodeUnits (toCharArray)

-- | Matrix code ideal
matrix2table :: Effect Unit
matrix2table = do
  let matrix = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

  let root = select (SelectorString "body")
  table <- root |+| (HTML "table")
  rows <- visualize
    { what: Append (HTML "tr")
    , where: table
    , using: NewData matrix
    , key: identityKeyFunction
    , attributes:
        { enter: [ Classed_ "new" ]
        , exit: [ Classed_ "exit", Remove ]
        , update: [ Classed_ "updated" ]
        }
    }

  let oddrows = filter "nth-child(odd)"
  style oddrows [ Background_ "light-gray", Color_ "white" ]

  items <- visualize
    { what: Append (HTML "td")
    , using: NewData InheritData
    , where: rows
    , key: identityKeyFunction
    , attributes:
        { enter: [ Classed_ "cell" ]
        , exit: []
        , update: []
        }
    }
  pure unit

-- | three little circles
threeLittleCircles :: Effect Unit
threeLittleCircles = do
  let root = select (SelectorString "div#circles")

  svg <- root |+| (SVG "svg")
  style svg [ ViewBox_ (-100.0) (-100.0) 650.0 650.0
            , Classed_ "d3svg circles"]

  circleGroup <- svg |+| (SVG "g")
  circles <- visualize
    { what: Append (SVG "circle")
    , using: NewData [ 32, 57, 293 ]
    , where: circleGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ Fill_ "green"
            , CX \d i -> toNumber (i * 100)
            , CY_ 50.0
            , Radius_ 20.0
            ]
        , exit: []
        , update: []
        }
    }
  pure unit

-- | General Update Pattern
generalUpdatePattern :: Effect Unit
generalUpdatePattern = do
  let letterdata = toCharArray "abcdefghijklmnopqrstuvwxyz"
  let letterdata2 = toCharArray "acdefglmnostxz"

  let root = select (SelectorString "div#gup")

  svg <- root |+| (SVG "svg")
  style svg [ ViewBox_ 0 0 650.0 650.0
            , Classed_ "d3svg gup"
            ]

  gupGroup <- svg |+| (SVG "g")
  letters <- visualize
    { what: Append (SVG "text")
    , using: NewData letterdata
    , where: gupGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ Text \d i -> singleton d
            , Fill_ "green"
            , X \d i -> toNumber (i * 48 + 50)
            , Y_ 0.0
            , FontSize_ 96.0
            , TransitionTo [ Y_ 200.0 ]
            ]
        , exit:
            [ Classed_ "exit"
            , Fill_ "brown"
            , TransitionTo
                [ Y_ 400.0
                , Remove
                ]
            ]
        , update:
            [ Classed_ "update"
            , Fill_ "gray"
            , Y_ 200.0
            ]
        }
    }
  revisualize letters letterdata2 -- definitely a TODO here as to how this would work

-- | Tree
computeX layoutStyle hasChildren x =
  case layoutStyle of
    Radial ->
      if hasChildren == (x < Math.pi) then 6.0
      else (-6.0)
    _ ->
      if hasChildren then 6.0
      else (-6.0)

computeTextAnchor layoutStyle hasChildren x =
  case layoutStyle of
    Radial ->
      if hasChildren == (x < Math.pi) then "start"
      else "end"
    _ ->
      if hasChildren then "start"
      else "end"

drawTree :: Config -> Tree -> Effect Unit
drawTree config tree = do
  let layoutTreeData = layoutTreeVertical tree

  let root = select (SelectorString "div#tree")

  svg <- root |+| SVG.svg
    [ config.viewbox
    , Classed_ "tree"
    , Width' config.svg.width
    , Height' config.svg.height
    ]
  container <- svg |+| SVG.g [ FontFamily' "sans-serif", FontSize' 10.0 ]
  allLinks <- svg |+| SVG.g
  allNodes <- svg |+| SVG.g

  node <- visualize
    { what: Append (SVG "g")
    , using: NewData laidoutNodes layoutTreeData
    , where: nodesGroup
    , key: identityKeyFunction
    , attributes:
        { enter: [] -- group for each circle and its label 
        , exit: [ Remove ]
        , update: []
        }
    }
  circles <- node |+| SVG.circle
    [ Fill \d i -> if d.hasChildren then "#999" else "#555"
    , Radius_ 2.5
    , StrokeColor' "white"
    ]

  labels <- node |+| SVG.Text
    [ DY' 0.31
    , X' \d i -> computeX config.layoutStyle d.hasChildren d.x
    , Fill' config.color
    , Text \d i -> d.name
    , TextAnchor \d i -> computeTextAnchor config.layoutStyle d.hasChildren d.x
    ]

  individualLink <- visualize
    { what: Append (SVG "path")
    , using: NewData laidoutLinks layoutTreeData
    , where: linksGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ StrokeWidth' 1.5
            , StrokeColor' config.color
            , StrokeOpacity' 0.4
            , Fill' "none"
            ]
        , exit: [ Remove ]
        , update: []
        }
    }
  pure unit

-- | ForceLayout example
drawForceLayout config model simulator = do
  svg <- root |+| SVG.svg
    [ config.viewbox
    , Classed_ "force-layout"
    , Width' config.svg.width
    , Height' config.svg.height
    ]
  linksGroup <- svg |+| SVG.g [ Classed_ "link", StrokeColor' "#999", StrokeOpacity' 0.6 ]
  nodesGroup <- svg |+| SVG.g [ Classed_ "node", StrokeColor' "#fff", StrokeOpacity' 1.5 ]

  -- side-effects ahoy, the data in these selections will change as the simulator runs
  simNodes <- addNodes
    { simulator
    , nodes: model.nodes
    , key: \d i -> d.id
    , tick: [ CX \d i -> d.x, CY \d i -> d.y ]
    , drag: DefaultDragBehavior
    }

  simLinks <- addLinks
    { simulator
    , nodes: model.nodes
    , links: model.links
    , key: \d i -> d.id
    , tick:
        [ X1 \l i -> l.source.x
        , Y1 \l i -> l.source.y
        , X2 \l i -> l.target.x
        , Y2 \l i -> l.target.y
        ]
    , drag: NoDrag
    }

  nodes <- visualize
    { what: Append (SVG "circle")
    , using: NewData simNodes
    , where: nodesGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ Radius_ 5.0
            , Fill \d i -> d.colorByGroup
            ]
        , exit: [ Remove ]
        , update: []
        }
    }

  links <- visualize
    { what: Append (SVG "line")
    , using: NewData simLinks
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ StrokeWidth_ 1.5
            , StrokeColor_ config.color
            , StrokeOpacity_ 0.4
            , Fill_ "none"
            ]
        , exit: [ Remove ]
        , update: []
        }
    }

  pure unit

