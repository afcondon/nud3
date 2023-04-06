module Examples.Simulations.File where

import Prelude

import Affjax (Error)
import Data.Either (Either(..))
import Nud3.Layouts.Simulation (Model)

-- TODO no error handling at all here RN (OTOH - performant!!)
foreign import readJSONJS_ :: forall r. String -> Model r

readGraphFromFileContents :: forall r r2. Either Error { body ∷ String | r } -> Either Error (Model r2)
readGraphFromFileContents (Right { body } ) = Right $ readJSONJS_ body
-- TODO exceptions dodged using empty Model, fix with Maybe
readGraphFromFileContents (Left err)        = Left err
