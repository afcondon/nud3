module Examples.Matrix where

import Nud3

import Effect (Effect)
import Nud3.Attributes (Attribute(..), foldAttributes)
import Nud3.Types (KeyFunction(..))
import Prelude (Unit, bind, pure, unit, ($))

-- | Matrix code ideal
matrix2table :: Effect Unit
matrix2table = do
  let matrix = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

  let root = select (SelectorString "div#matrix")
  -- | Insert the table
  table <- addElement root $ Append $ HTML "table"
  let tableWithAttrs = foldAttributes table [ Classed_ "matrix", Width_ 300.0, Height_ 300.0, BackgroundColor_ "#AAA" ] -- TODO: return this to being effectful here
  -- | Insert the rows
  rows <- visualize
    { what: Append (HTML "tr")
    , where: tableWithAttrs
    , using: NewData matrix
    , key: IdentityKey
    , attributes:
        { enter: [ Classed_ "new" ]
        , exit: [ Classed_ "exit" ] -- NB remove is implicit, only needed on custom exit
        , update: [ Classed_ "updated" ]
        }
    }

  -- | Just for yuks, style like a spreadsheet with alternating colors
  let
    oddrows = rows `filter` "nth-child(odd)"
    _ = foldAttributes oddrows [ BackgroundColor_ "light-gray", Color_ "white" ]

  -- | Insert the cells
  items <- visualize
    { what: Append (HTML "td")
    , using: InheritData :: DataSource (Array Int) -- need to give the type to ensure Show instance for debugging, no other reason
    , where: rows
    , key: IdentityKey
    , attributes:
        { enter: [ Classed_ "cell" ]
        , exit: []
        , update: []
        }
    }

  let _ = foldAttributes items [ Text \d _ -> d ]

  pure unit

