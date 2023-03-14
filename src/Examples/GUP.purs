module Examples.GUP where

import Nud3

import Data.Int (toNumber)
import Data.String.CodeUnits (singleton, toCharArray)
import Effect (Effect)
import Nud3.Attributes (Attribute(..), createTransition, easeCubic)
import Prelude (Unit, bind, pure, unit, (*), (+))

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
  let twoSecondTransition = createTransition { duration: 2.0, delay: 0.0, easing: easeCubic }
  letters <- visualize
    { what: Append (SVG "text")
    , using: NewData letterdata
    , where: gupGroup
    , key: identityKeyFunction
    , attributes:
        { enter:
            [ Text \d i -> singleton d
            , Fill_ "green"
            , X \d i -> toNumber (i * 48 + 50)
            , Y_ 0.0
            , FontSize_ 96.0
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
  _ <- revisualize letters letterdata2 -- definitely a TODO here as to how this would work
  pure unit

