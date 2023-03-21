module Examples.GUP
  ( generalUpdatePattern
  )
  where

import Nud3

import Data.Int (toNumber)
import Data.String.CodeUnits (singleton, toCharArray)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), createTransition)
import Nud3.FFI as FFI
import Nud3.Types (Selection_, Transition_)
import Prelude (Unit, bind, pure, unit, ($), (*), (+))

config :: Selection_ -> Array Char -> KeyFunction Char -> Transition_ -> JoinConfig Char
config gupGroup letters keyFunction transition_ = {
      what: Append (SVG "text")
    , using: NewData letters
    , where: gupGroup
    , key: keyFunction
    , attributes:
        { enter:
            [ Text \d _ -> singleton d
            , Fill_ "green"
            , X \_ i -> toNumber (i * 48 + 50)
            , Y_ 0.0
            , FontSize_ 96.0
            , FontFamily_ "monospace"
            , Transition { transition_
                         , name: "TODO"
                         , attrs: [ Y_ 200.0 ]}
            ]
        , exit:
            [ Classed_ "exit"
            , Fill_ "brown"
            , TransitionThenRemove { transition_
                                   , name: "TODO"
                                   , attrs: [ Y_ 400.0 ]}
            ]
        , update:
            [ Classed_ "update"
            , Fill_ "gray"
            , Y_ 200.0
            ]
        }
    }

newTransition :: Int -> Int -> Transition_
newTransition duration delay = createTransition { duration, delay, easing: FFI.easeCubic_ }

letterdata :: Array Char
letterdata = toCharArray "abcdefghijklmnopqrstuvwxyz"

letterdata2 :: Array Char
letterdata2 = toCharArray "acdefglmnostxz"

-- | General Update Pattern
generalUpdatePattern :: Effect Unit
generalUpdatePattern = do
  let root = select (SelectorString "div#gup")
  svg <- root |+| (SVG "svg")
  let styled = style svg -- TODO: return this to being effectful / <- style svg
                  [ ViewBox_ 0 0 650 650
                  , Classed_ "d3svg gup"
                  ]
  gupGroup <- styled |+| (SVG "g")
  gupGroup' <- visualize $ config gupGroup letterdata identityKeyFunction (newTransition 2000 0)
  _ <- visualize $ config gupGroup' letterdata2 identityKeyFunction (newTransition 2000 1000)
  -- TODO would definitely be nicer to use record update rather than function parameters here:
  -- _ <- revisualize $ config { using = NewData letterdata2 }
  pure unit
