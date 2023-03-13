module Examples.Matrix where

import Nud3

import Effect (Effect)
import Nud3.Attributes (Attribute(..))
import Prelude (Unit, bind, pure, unit)


-- | Matrix code ideal
matrix2table :: Effect Unit
matrix2table = do
  let matrix = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

  let root = select "root" (SelectorString "div#matrix")
  -- | TODO selection name is not passed thru when appending, should it be? 
  table <- root |+| (HTML "table") 
  _ <- addAttributes table [ Classed_ "matrix", Width_ 1000.0, Height_ 1000.0 ] -- just to test the addAttributes function
  -- beforeTable <- root |^| (HTML "p")
  rows <- visualize
    { what: HTML "tr"
    , where: table
    , using: NewData matrix
    , key: identityKeyFunction
    , attributes:
        { enter: [ Classed_ "new" ]
        , exit: [ Classed_ "exit" ] -- removed the "Remove" attribute here in case that was source of parse error
        , update: [ Classed_ "updated" ]
        }
    }

  let oddrows = rows `filter` "nth-child(odd)"
  _ <- style oddrows [ Background_ "light-gray", Color_ "white" ]

  items <- visualize
    { what: HTML "td"
    , using: InheritData :: DataSource (Array Int) -- need to give the type to ensure Show instance for debugging, no other reason
    , where: rows
    , key: identityKeyFunction
    , attributes:
        { enter: [ Classed_ "cell" ]
        , exit: []
        , update: []
        }
    }
  pure unit

