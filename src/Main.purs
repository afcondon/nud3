
module Main  where

import Prelude

import Control.Monad.Rec.Class (forever)
import Data.Array (catMaybes)
import Data.Maybe (Maybe(..))
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Data.Traversable (sequence)
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Random (random)
import Examples.GUP (generalUpdatePatternDraw, generalUpdatePatternSetup)
import Examples.Matrix (matrix2table)
import Examples.ThreeLittleCircles (threeLittleCircles)
import Nud3.Types (Selection_)

examplesInEffect :: Effect Unit
examplesInEffect = do
  matrix2table
  threeLittleCircles
  -- drawTree 
  -- drawForceLayout

examplesInAff :: Selection_ -> Effect Unit
examplesInAff letters = launchAff_ do
  _ <- liftEffect $ generalUpdatePatternDraw letters "abcdefglmnostxz"
  delay $ Milliseconds 1800.0
  _ <- liftEffect $ generalUpdatePatternDraw letters "abcdejklmnopqrstuvwxyz" 
  delay $ Milliseconds 1800.0
  _ <- liftEffect $ generalUpdatePatternDraw letters "lkjhgfdsa"
  pure unit

runUpdate :: Selection_ -> Effect Unit
runUpdate letters = launchAff_ $ forever do
  letterData <- liftEffect $ getLetters
  _ <- liftEffect $ generalUpdatePatternDraw letters (fromCharArray letterData)
  delay (Milliseconds 1800.0)
  where
    -- | choose a string of random letters (no duplicates), ordered alphabetically
    getLetters :: Effect (Array Char)
    getLetters = do
      let 
        letters = toCharArray "abcdefghijklmnopqrstuvwxyz"
        coinToss :: Char -> Effect (Maybe Char)
        coinToss c = do
          n <- random
          pure $ if n > 0.6 then Just c else Nothing
      
      choices <- sequence $ coinToss <$> letters -- make 40% of letters Nothing
      pure $ catMaybes choices -- remove the Nothings


main :: Effect Unit
main = do
  examplesInEffect
  letters <- generalUpdatePatternSetup
  -- examplesInAff letters
  runUpdate letters
  liftEffect $ log "🍝"

