module Examples.ThreeLittleCircles where

import Nud3

import Data.Int (toNumber)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), foldAttributes)
import Nud3.Types (KeyFunction(..))
import Prelude (Unit, bind, negate, pure, unit, (*), ($))

-- | three little circles
threeLittleCircles :: Effect Unit
threeLittleCircles = do
  let root = select (SelectorString "div#circles")

  svg <- addElement root $ Append $ SVG "svg"
  let
    _ = foldAttributes svg
      [ Width 650.0
      , Height 650.0
      , ViewBox (-100) (-100) 300 300
      , Classed "d3svg circles"
      ]

  circleGroup <- addElement svg $ Append $ SVG "g"
  circles <- visualize
    { what: Append (SVG "circle")
    , using: NewData [ 32, 57, 293 ]
    , where: circleGroup
    , key: IdentityKey
    , attributes:
        { enter:
            [ Fill "green"
            , CX_ \_ i -> toNumber (i * 30)
            , CY 30.0
            , Radius 10.0
            , Classed "enter"
            ]
        , exit: [ Classed "exit" ]
        , update: [ Classed "update" ]
        }
    }
  pure unit
