module Examples.GUP
  ( generalUpdatePatternDraw
  , generalUpdatePatternSetup
  ) where

import Nud3

import Data.Char (toCharCode)
import Data.Int (toNumber)
import Data.String.CodeUnits (singleton, toCharArray)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), createTransition, foldAttributes)
import Nud3.FFI as FFI
import Nud3.Types (KeyFunction(..), Selection_, Transition_)
import Prelude (bind, ($), (*), (+))

config :: forall i. Selection_ -> Array Char -> KeyFunction Char i -> Transition_ -> JoinConfig Char i
config gupGroup letters keyFunction transition_ =
  { what: Append (SVG "text")
  , using: NewData letters
  , where: gupGroup
  , key: keyFunction
  , attributes:
      { enter:
          [ Text \d _ -> singleton d
          , Fill_ "green"
          , X \_ i -> toNumber (i * 48 + 50)
          , Y_ 0.0
          , FontSize_ 48.0
          , FontFamily_ "monospace"
          , Transition
              { transition_
              , name: "TODO" -- get the name from the transition_
              , attrs: [ Y_ 200.0 ]
              }
          ]
      , exit:
          [ Classed_ "exit"
          , Fill_ "brown"
          , TransitionThenRemove
              { transition_
              , name: "TODO" -- get the name from the transition_
              , attrs: [ Y_ 400.0 ]
              }
          ]
      , update:
          [ Classed_ "update"
          , Fill_ "gray"
          , Y_ 200.0
          , Transition
              { transition_
              , name: "TODO" -- get the name from the transition_
              , attrs: [ X \_ i -> toNumber (i * 48 + 50) ]
              }
          ]
      }
  }

newTransition :: String -> Int -> Int -> Transition_
newTransition name duration delay = createTransition { name, duration, delay, easing: FFI.easeCubic_ }

-- | General Update Pattern
generalUpdatePatternSetup :: Effect Selection_
generalUpdatePatternSetup = do
  let root = select (SelectorString "div#gup")
  svg <- addElement root $ Append $ SVG "svg"
  let
    styled = foldAttributes svg
      [ ViewBox_ 0 0 650 650
      , Classed_ "d3svg gup"
      ]
  addElement styled $ Append $ SVG "g"

crazyKeyFunction :: KeyFunction Char Char
crazyKeyFunction = 
  let keyFn :: Char -> Int -> NodeList -> Char
      keyFn 'a' _ _ = 'b'
      keyFn 'b' _ _ = 'a'
      keyFn d _ _ = d
  in KeyFunction keyFn
  

otherKeyFunction :: KeyFunction Char Int
otherKeyFunction = 
  let keyFn :: Char -> Int -> NodeList -> Int
      keyFn d _ _ = toCharCode d
  in KeyFunction keyFn

generalUpdatePatternDraw :: Selection_ -> String -> Effect Selection_
generalUpdatePatternDraw selection letterdata = do
  let letters = toCharArray letterdata
  visualize $ config selection letters crazyKeyFunction (newTransition "foo" 1000 500)
-- visualize $ config selection letters identityKeyFunction (newTransition "foo" 1000 500)
-- TODO would definitely be nicer to use record update rather than function parameters here:
-- _ <- revisualize $ config { using = NewData letterdata2 }
