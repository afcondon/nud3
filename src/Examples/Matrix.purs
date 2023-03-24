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
  let tableWithAttrs = foldAttributes table [ Classed "matrix", Width 300.0, Height 300.0, BackgroundColor "#AAA" ] -- HER-15 TODO: return this to being effectful here
  -- | Insert the rows
  rows <- visualize
    { what: Append (HTML "tr")
    , parent: tableWithAttrs
    , "data": NewData matrix
    , key: IdentityKey
    , instructions: Compound
        { enter: [ Classed "new" ]
        , exit: [ Classed "exit" ]
        , update: [ Classed "updated" ]
        }
    }

  -- | Just for yuks, style like a spreadsheet with alternating colors
  let
    oddrows = rows `filter` "nth-child(odd)"
    _ = foldAttributes oddrows [ BackgroundColor "light-gray", Color "white" ]

  -- | Insert the cells
  items <- visualize
    { what: Append (HTML "td")
    , "data": InheritData :: DataSource (Array Int) -- need to give the type to ensure Show instance for debugging, no other reason
    , parent: rows
    , key: IdentityKey
    , instructions: Simple [ Classed "cell" ]
    }

  let _ = foldAttributes items [ Text_ \d _ -> d ]

  pure unit

