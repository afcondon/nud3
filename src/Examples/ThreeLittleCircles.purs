module Examples.ThreeLittleCircles where

import Nud3

import Data.Int (toNumber)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), foldAttributes)
import Prelude (Unit, bind, negate, pure, unit, (*), ($))


-- | three little circles
threeLittleCircles :: Effect Unit
threeLittleCircles = do
  let root = select (SelectorString "div#circles")

  svg <- addElement root $ Append $ SVG "svg"
  let _ = foldAttributes svg 
          [ Width_ 650.0
          , Height_ 650.0
          , ViewBox_ (-100) (-100) 300 300
          , Classed_ "d3svg circles"
          ]

  circleGroup <- addElement svg $ Append $ SVG "g"
  circles <- visualize
    { what: Append (SVG "circle")
    , using: NewData [ 32, 57, 293 ]
    , where: circleGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ Fill_ "green"
            , CX \_ i -> toNumber (i * 30)
            , CY_ 30.0
            , Radius_ 10.0
            , Classed_ "enter"
            ]
        , exit: [Classed_ "exit"]
        , update: [Classed_ "update"]
        }
    }
  pure unit
