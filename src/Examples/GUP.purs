module Examples.GUP
  ( generalUpdatePattern
  , twoSecondTransition
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

config :: Selection_ -> Array Char -> KeyFunction Char -> JoinConfig Char
config gupGroup letterdata keyFunction = {
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
            , Transition twoSecondTransition [ Y_ 200.0 ]
            ]
        , exit:
            [ Classed_ "exit"
            , Fill_ "brown"
            , TransitionThenRemove twoSecondTransition [ Y_ 400.0 ]
            ]
        , update:
            [ Classed_ "update"
            , Fill_ "gray"
            , Y_ 200.0
            ]
        }
    }

twoSecondTransition :: Transition_
twoSecondTransition = createTransition { duration: 2.0, delay: 2.0, easing: FFI.easeCubic_ }

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
  letters <- visualize $ config gupGroup letterdata identityKeyFunction
  -- TODO would definitely be nicer to use record update rather than function parameters here:
  -- _ <- revisualize $ config { using = NewData letterdata2 }
  _ <- revisualize $ config gupGroup letterdata2 identityKeyFunction
  pure unit
