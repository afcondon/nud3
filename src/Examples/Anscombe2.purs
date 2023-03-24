module Examples.Anscombe2 where

import Nud3

import Data.Array as Array
import Effect (Effect)
import Nud3.Attributes (Attribute(..), TransitionAttribute(..), createTransition, foldAttributes)
import Nud3.Types (KeyFunction(..), Selection_, Transition_)
import Prelude (Unit, bind, negate, pure, unit, (-), ($), (*), (==), (/))

circlePlotInit :: Effect Selection_
circlePlotInit = do
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
  pure circleGroup

circlePlotUpdateSimple :: Selection_ -> Array Point -> Effect Unit
circlePlotUpdateSimple parent points = do
  circles <- visualize
    { what: Append (SVG "circle")
    , "data": NewData points
    , parent
    , key: IdentityKey
    , instructions: 
      Simple [ Fill_ \d i -> 
                case d.set of
                  "I" -> "red"
                  "II" -> "blue"
                  "III" -> "green"
                  "IV" -> "yellow"
                  _ -> "black"
            , StrokeColor "black"
            , StrokeWidth 1.0
            , CX_ \d i -> d.x * 10.0
            , CY_ \d i -> d.y * 10.0
            , Radius 2.0
            , Classed "enter"
            ]
    }
  pure unit

circlePlotUpdateCompound :: Selection_ -> Array Point -> Effect Unit
circlePlotUpdateCompound parent points = do
  circles <- visualize
    { what: Append (SVG "circle")
    , "data": NewData points
    , parent
    , key: KeyFunction customKeyFunction
    , instructions: 
      Compound {
          enter: [ Fill_ \d i -> 
                case d.set of
                  "I" -> "red"
                  "II" -> "blue"
                  "III" -> "green"
                  "IV" -> "yellow"
                  _ -> "black"
            , StrokeColor "black"
            , StrokeWidth 1.0
            , CX_ \d i -> d.x * 10.0
            , CY_ \d i -> d.y * 10.0
            , Radius 2.0
            , Classed "enter"
            ]
        , update: [ BeginTransition pointTransition [ CX_ \d i -> d.x * 10.0 , CY_ \d i -> d.y * 10.0 ] ]
        , exit: [ ]
      }
    }
  pure unit

pointTransition :: Transition_
pointTransition = createTransition [ TransitionName "foo", Duration 1000 ]

-- customKeyFunction :: KeyFunction Point Int
customKeyFunction ::  Point -> Int -> NodeList -> Int
customKeyFunction point index nodes =
  let offset = 
        case point.set of
          "II" -> 11
          "III" -> 22
          "IV" -> 33
          _ -> 0
  in point.id - offset -- just force the ids of each set to start at 0

type Point = { x :: Number, y :: Number, set :: String, id :: Int }

subset :: String -> Array Point -> Array Point
subset set points = Array.filter (\p -> p.set == set) points  

anscombeData :: Array Point
anscombeData = [ 
  { id: 0, set: "I", x: 10.0, y: 8.04 },
  { id: 1, set: "I", x: 8.0, y: 6.95 },
  { id: 2, set: "I", x: 13.0, y: 7.58 },
  { id: 3, set: "I", x: 9.0, y: 8.81 },
  { id: 4, set: "I", x: 11.0, y: 8.33 },
  { id: 5, set: "I", x: 14.0, y: 9.96 },
  { id: 6, set: "I", x: 6.0, y: 7.24 },
  { id: 7, set: "I", x: 4.0, y: 4.26 },
  { id: 8, set: "I", x: 12.0, y: 10.84 },
  { id: 9, set: "I", x: 7.0, y: 4.82 },
  { id: 10, set: "I", x: 5.0, y: 5.68 }
  ,
  { id: 11, set: "II", x: 10.0, y: 9.14 },
  { id: 12, set: "II", x: 8.0, y: 8.14 },
  { id: 13, set: "II", x: 13.0, y: 8.74 },
  { id: 14, set: "II", x: 9.0, y: 8.77 },
  { id: 15, set: "II", x: 11.0, y: 9.26 },
  { id: 16, set: "II", x: 14.0, y: 8.1 },
  { id: 17, set: "II", x: 6.0, y: 6.13 },
  { id: 18, set: "II", x: 4.0, y: 3.1 },
  { id: 19, set: "II", x: 12.0, y: 9.13 },
  { id: 20, set: "II", x: 7.0, y: 7.26 },
  { id: 21, set: "II", x: 5.0, y: 4.74 },

  { id: 22, set: "III", x: 10.0, y: 7.46 },
  { id: 23, set: "III", x: 8.0, y: 6.77 },
  { id: 24, set: "III", x: 13.0, y: 12.74 },
  { id: 25, set: "III", x: 9.0, y: 7.11 },
  { id: 26, set: "III", x: 11.0, y: 7.81 },
  { id: 27, set: "III", x: 14.0, y: 8.84 },
  { id: 28, set: "III", x: 6.0, y: 6.08 },
  { id: 29, set: "III", x: 4.0, y: 5.39 },
  { id: 30, set: "III", x: 12.0, y: 8.15 },
  { id: 31, set: "III", x: 7.0, y: 6.42 },
  { id: 32, set: "III", x: 5.0, y: 5.73 },

  { id: 33, set: "IV", x: 8.0, y: 6.58 },
  { id: 34, set: "IV", x: 8.0, y: 5.76 },
  { id: 35, set: "IV", x: 8.0, y: 7.71 },
  { id: 36, set: "IV", x: 8.0, y: 8.84 },
  { id: 37, set: "IV", x: 8.0, y: 8.47 },
  { id: 38, set: "IV", x: 8.0, y: 7.04 },
  { id: 39, set: "IV", x: 8.0, y: 5.25 },
  { id: 40, set: "IV", x: 19.0, y: 12.5 },
  { id: 41, set: "IV", x: 8.0, y: 5.56 },
  { id: 42, set: "IV", x: 8.0, y: 7.91 },
  { id: 43, set: "IV", x: 8.0, y: 6.89 }
  ]