module Examples where

import Effect
import Nud3.Attributes
import Nud4
import Prelude

import Data.Int (toNumber)
import Data.Number (pi)
import Data.String.CodeUnits (singleton, toCharArray)
import Data.Tree (Tree)
import Nud3.Tree as Tree
import Nud3.Tree as VizTree
import Simulation as Simulation
import Unsafe.Coerce (unsafeCoerce)

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

  let oddrows = rows `filter` "nth-child(odd)"
  _ <- style oddrows [ Background_ "light-gray", Color_ "white" ]

  items <- visualize
    { what: Append (HTML "td")
    , using: InheritData
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
  _ <- style svg
    [ ViewBox_ (-100.0) (-100.0) 650.0 650.0
    , Classed_ "d3svg circles"
    ]

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
  _ <- style svg
    [ ViewBox_ 0.0 0.0 650.0 650.0
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
            [ Text \d i -> singleton $ unsafeCoerce d -- TODO: this is a hack
            , Fill_ "green"
            , X \d i -> toNumber (i * 48 + 50)
            , Y_ 0.0
            , FontSize_ 96.0
            , TransitionTo [ Attr (Y_ 200.0) ]
            ]
        , exit:
            [ Classed_ "exit"
            , Fill_ "brown"
            , TransitionTo
                [ Attr (Y_ 400.0) -- we have to wrap TransitionAttributes for the time being
                , Attr Remove
                ]
            ]
        , update:
            [ Classed_ "update"
            , Fill_ "gray"
            , Y_ 200.0
            ]
        }
    }
  _ <- revisualize letters letterdata2 -- definitely a TODO here as to how this would work
  pure unit

-- | Tree
computeX layoutStyle hasChildren x =
  case layoutStyle of
    VizTree.Radial ->
      if hasChildren == (x < pi) then 6.0
      else (-6.0)
    _ ->
      if hasChildren then 6.0
      else (-6.0)

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
  circles <- node |+| (SVG "circle")
    [ Fill \d i -> if d.hasChildren then "#999" else "#555"
    , Radius_ 2.5
    , StrokeColor_ "white"
    ]

  labels <- node |+| (SVG "text")
    [ DY_ 0.31
    , X_ \d i -> computeX Tree.Vertical d.hasChildren d.x
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

-- | ForceLayout example
drawForceLayout :: Number -> Number -> Simulation.Model -> Effect Unit
drawForceLayout width height model = do
  let root = select (SelectorString "div#miserables")
  svg <- root |+| (SVG "svg")
  _ <- style svg
    [ ViewBox_ 0.0 0.0 650.0 650.0
    , Classed_ "force-layout"
    , Width_ width
    , Height_ height
    ]
  linksGroup <- appendStyledElement svg (SVG "g") [ Classed_ "link", StrokeColor_ "#999", StrokeOpacity_ 0.6 ]
  nodesGroup <- appendStyledElement svg (SVG "g") [ Classed_ "node", StrokeColor_ "#fff", StrokeOpacity_ 1.5 ]

  simulator <- Simulation.newEngine
    { width: width
    , height: height
    , alpha: 0.1
    , alphaMin: 0.001
    , alphaDecay: 0.0228
    , velocityDecay: 0.4
    }
  -- side-effects ahoy, the data in these selections will change as the simulator runs
  simNodes <- Simulation.addNodes
    { simulator
    , nodes: model.nodes
    , key: \d -> d.id
    }

  _ <- Simulation.onTickNode simulator simNodes [ CX \d i -> d.x, CY \d i -> d.y ]
  _ <- Simulation.onDrag simulator simNodes Simulation.DefaultDragBehavior

  simLinks <- Simulation.addLinks
    { simulator
    , nodes: model.nodes
    , links: model.links
    , key: \d -> d.id
    }

  _ <- Simulation.onTickLink simulator simLinks 
        [ X1 \l i -> l.source.x
        , Y1 \l i -> l.source.y
        , X2 \l i -> l.target.x
        , Y2 \l i -> l.target.y
        ]

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
    , where: linksGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ StrokeWidth_ 1.5
            , StrokeColor_ "#555"
            , StrokeOpacity_ 0.4
            , Fill_ "none"
            ]
        , exit: [ Remove ]
        , update: []
        }
    }

  pure unit

