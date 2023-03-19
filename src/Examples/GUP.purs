module Examples.GUP
  ( generalUpdatePattern
  , shortDelayedTransition
  )
  where

import Nud3

import Data.Int (toNumber)
import Data.String.CodeUnits (singleton, toCharArray)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), createTransition)
import Nud3.FFI as FFI
import Nud3.Types (Selection_, Transition_)
import Prelude (Unit, bind, identity, pure, unit, ($), (*), (+))

config :: Selection_ -> Array Char -> KeyFunction Char -> Transition_ -> JoinConfig Char
config gupGroup letterdata keyFunction transition_ = {
      what: Append (SVG "text")
    , using: NewData letterdata
    , where: gupGroup
    , key: keyFunction
    , attributes:
        { enter:
            [ Text \d i -> singleton d
            , Fill_ "green"
            , X \d i -> toNumber (i * 48 + 50)
            , Y_ 0.0
            , FontSize_ 96.0
            , FontFamily_ "monospace"
            , Transition transition_ [ Y_ 200.0 ]
            ]
        , exit:
            [ Classed_ "exit"
            , Fill_ "brown"
            , TransitionThenRemove transition_ [ Y_ 400.0 ]
            ]
        , update:
            [ Classed_ "update"
            , Fill_ "gray"
            , Y_ 200.0
            ]
        }
    }

shortDelayedTransition :: Unit -> Transition_
shortDelayedTransition _ = createTransition { duration: 2000, delay: 750, easing: FFI.easeCubic_ }

letterdata :: Array Char
letterdata = toCharArray "abcdefghijklmnopqrstuvwxyz"

letterdata2 :: Array Char
letterdata2 = toCharArray "acdefglmnostxz"

-- | General Update Pattern
generalUpdatePattern :: Effect Unit
generalUpdatePattern = do
  let root = select (SelectorString "div#gup")
  svg <- root |+| (SVG "svg")
  _ <- style svg
    [ ViewBox_ 0.0 0.0 650.0 650.0
    , Classed_ "d3svg gup"
    ]
  gupGroup <- svg |+| (SVG "g")
  _ <- visualize $ config gupGroup letterdata identityKeyFunction (shortDelayedTransition unit)
  _ <- visualize $ config gupGroup letterdata2 identityKeyFunction (shortDelayedTransition unit)
  -- TODO would definitely be nicer to use record update rather than function parameters here:
  -- _ <- revisualize $ config { using = NewData letterdata2 }
  pure unit
