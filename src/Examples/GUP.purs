module Examples.GUP
  ( generalUpdatePatternDraw
  , generalUpdatePatternSetup
  ) where

import Nud3

import Data.Char (toCharCode)
import Data.Int (toNumber)
import Data.String.CodeUnits (singleton, toCharArray)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), TransitionAttribute(..), createTransition, foldAttributes)
import Nud3.FFI as FFI
import Nud3.Types (KeyFunction(..), Selection_, Transition_)
import Prelude (bind, ($), (*), (+))

datajoin :: forall i. Selection_ -> Array Char -> KeyFunction Char i -> Transition_ -> JoinConfig Char i
datajoin parent letters keyFunction t_ =
  { what: Append (SVG "text")
  , "data": NewData letters
  , parent
  , key: keyFunction
  , instructions: Compound
      { enter:
          [ Text_ \d _ -> singleton d
          , Fill "green"
          , X_ \_ i -> toNumber (i * 48 + 50)
          , Y 0.0
          , FontSize 24.0
          , FontFamily "monospace"
          , BeginTransition t_
              [ Delay_ \_ i -> i * 20
              , Y 200.0
              , X_ \_ i -> toNumber (i * 24 + 50)
              ]
          ]
      , exit:
          [ Classed "exit"
          , Fill "brown"
          , BeginTransition t_
              [ Delay_ \_ i -> i * 20
              , Y 400.0
              , Opacity 0.000001
              , FontSize 96.0
              , Delay_ \_ i -> i * 20
              , X_ \_ i -> toNumber (i * 48 + 50)
              , RemoveElements
              ]
          ]
      , update:
          [ Classed "update"
          , Fill "gray"
          , Y 200.0
          , BeginTransition t_
              [ X_ \_ i -> toNumber (i * 24 + 50)
              , FollowOnTransition [ Fill "blue" ]
              , FollowOnTransition [ Fill "red" ]
              ]
          ]
      }
  }

-- | General Update Pattern
generalUpdatePatternSetup :: Effect Selection_
generalUpdatePatternSetup = do
  let root = select (SelectorString "div#gup")
  svg <- addElement root $ Append $ SVG "svg"
  let
    styled = foldAttributes svg
      [ ViewBox 0 0 650 650
      , Classed "d3svg gup"
      ]
  addElement styled $ Append $ SVG "g"

generalUpdatePatternDraw :: Selection_ -> String -> Effect Selection_
generalUpdatePatternDraw selection letterdata = do
  let letters = toCharArray letterdata
  visualize $ datajoin selection letters IdentityKey $
    createTransition [ TransitionName "foo", Duration 1000 ]

-- | Key functions (unused)
crazyKeyFunction :: KeyFunction Char String
crazyKeyFunction = KeyFunction1 \c -> 
  case c of
    'a' -> "b"
    'b' -> "a"
    d -> singleton d
      

otherKeyFunction :: KeyFunction Char Int
otherKeyFunction = KeyFunction1 toCharCode

