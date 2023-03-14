module Examples.Miserables where

import Nud3
import Effect (Effect)
import Nud3.Attributes (Attribute(..))
import Prelude (Unit, bind, pure, unit)

import Simulation as Simulation


-- | ForceLayout example

colorByGroup :: Int ->  String -- placeholder generated by copilot 
colorByGroup group =
  case group of
    0 -> "#1f77b4"
    1 -> "#ff7f0e"
    2 -> "#2ca02c"
    3 -> "#d62728"
    4 -> "#9467bd"
    5 -> "#8c564b"
    6 -> "#e377c2"
    7 -> "#7f7f7f"
    8 -> "#bcbd22"
    9 -> "#17becf"
    _ -> "#000000"

drawForceLayout :: Number -> Number -> Simulation.Model -> Effect Unit
drawForceLayout width height model = do
  let root = select "root" (SelectorString "div#miserables")
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
            , Fill \d i -> colorByGroup d.group
            ]
        , exit: [] -- Remove is the default, no need for other attrs here
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
        , exit: [] -- Remove is the default, no need for other attrs here
        , update: []
        }
    }

  pure unit
