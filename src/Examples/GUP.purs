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

config :: forall i. Selection_ -> Array Char -> KeyFunction Char i -> Transition_ -> JoinConfig Char i
config gupGroup letters keyFunction t_ =
  { what: Append (SVG "text")
  , using: NewData letters
  , where: gupGroup
  , key: keyFunction
  , attributes:
      { enter:
          [ Text_ \d _ -> singleton d
          , Fill "green"
          , X_ \_ i -> toNumber (i * 48 + 50)
          , Y 0.0
          , FontSize 24.0
          , FontFamily "monospace"
          , Transition t_ [ Delay_ \_ i -> i * 20 ] [ Y 200.0, X_ \_ i -> toNumber (i * 24 + 50) ]
          ]
      , exit:
          [ Classed "exit"
          , Fill "brown"
          , Transition t_ 
              [ Delay_ \_ i -> i * 20, Remove ]
              [ Y 400.0
              , Opacity 0.000001
              , FontSize 96.0
              , TransitionAttr (Delay_ \_ i -> i * 20)
              , X_ \_ i -> toNumber (i * 48 + 50)
              ]
          ]
      , update:
          [ Classed "update"
          , Fill "gray"
          , Y 200.0
          , Transition t_ [ ] [ X_ \_ i -> toNumber (i * 24 + 50) ]
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

crazyKeyFunction :: KeyFunction Char String
crazyKeyFunction = 
  let keyFn :: Char -> Int -> NodeList -> String
      keyFn 'a' _ _ = "b"
      keyFn 'b' _ _ = "a"
      keyFn d _ _ = singleton d
  in KeyFunction keyFn
  

otherKeyFunction :: KeyFunction Char Int
otherKeyFunction = 
  let keyFn :: Char -> Int -> NodeList -> Int
      keyFn d _ _ = toCharCode d
  in KeyFunction keyFn

generalUpdatePatternDraw :: Selection_ -> String -> Effect Selection_
generalUpdatePatternDraw selection letterdata = do
  let letters = toCharArray letterdata
  visualize $ config selection letters IdentityKey $
    createTransition [ TransitionName "foo", Duration 1000 ]
    -- createTransition [ TransitionName "foo", Duration 1000, Delay_ \_ i -> i * 20 ]
    -- (newTransition "foo" 1000 500)
-- visualize $ config selection letters identityKeyFunction (newTransition "foo" 1000 500)
-- HER-14 TODO would definitely be nicer to use record update rather than function parameters here:
-- _ <- revisualize $ config { using = NewData letterdata2 }
