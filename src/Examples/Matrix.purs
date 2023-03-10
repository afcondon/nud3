module Examples.Matrix where

import Nud3
import Effect (Effect)
import Nud3.Attributes (Attribute(..))
import Prelude (Unit, bind, pure, unit)


-- | Matrix code ideal
matrix2table :: Effect Unit
matrix2table = do
  let matrix = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

  let root = select (SelectorString "body")
  table <- root |+| (HTML "table")
  rows <- visualize
    { what: Append (HTML "tr")
    , where: table
    , using: NewData matrix
    , key: identityKeyFunction
    , attributes:
        { enter: [ Classed_ "new" ]
        , exit: [ Classed_ "exit", Remove ]
        , update: [ Classed_ "updated" ]
        }
    }

  let oddrows = rows `filter` "nth-child(odd)"
  _ <- style oddrows [ Background_ "light-gray", Color_ "white" ]

  items <- visualize
    { what: Append (HTML "td")
    , using: InheritData
    , where: rows
    , key: identityKeyFunction
    , attributes:
        { enter: [ Classed_ "cell" ]
        , exit: []
        , update: []
        }
    }
  pure unit
