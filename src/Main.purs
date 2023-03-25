
module Main  where

import Prelude

import Control.Monad.Rec.Class (forever)
import Data.Array (catMaybes)
import Data.Maybe (Maybe(..))
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Data.Traversable (sequence)
import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Random (random)
import Examples.Anscombe2 (anscombeData, circlePlotInit, circlePlotUpdateCompound, circlePlotUpdateSimple, subset)
import Examples.GUP (generalUpdatePatternDraw)
import Nud3.Types (Selection_)

lettersUpdate :: Selection_ -> Effect Unit
lettersUpdate letters = launchAff_ $ forever do
  letterData <- liftEffect $ getLetters
  _ <- liftEffect $ generalUpdatePatternDraw letters (fromCharArray letterData)
  delay (Milliseconds 5000.0)
  where
    -- | choose a string of random letters (no duplicates), ordered alphabetically
    getLetters :: Effect (Array Char)
    getLetters = do
      let 
        alphabet = toCharArray "abcdefghijklmnopqrstuvwxyz"
        coinToss :: Char -> Effect (Maybe Char)
        coinToss c = do
          n <- random
          pure $ if n > 0.6 then Just c else Nothing
      
      choices <- sequence $ coinToss <$> alphabet -- make 40% of letters Nothing
      pure $ catMaybes choices -- remove the Nothings

anscombeUpdate :: Selection_ -> Effect Unit
anscombeUpdate selection = launchAff_ $ forever do
  liftEffect $ circlePlotUpdateCompound selection (subset "I" anscombeData)
  delay (Milliseconds 2000.0)
  liftEffect $ circlePlotUpdateCompound selection (subset "II" anscombeData)
  delay (Milliseconds 2000.0)
  liftEffect $ circlePlotUpdateCompound selection (subset "III" anscombeData)
  delay (Milliseconds 2000.0)
  liftEffect $ circlePlotUpdateCompound selection (subset "IV" anscombeData)
  delay (Milliseconds 2000.0)
  

main :: Effect Unit
main = do
  -- matrix2table
  -- threeLittleCircles
  -- circlePlot
  circles <- circlePlotInit
  anscombeUpdate circles
  -- drawTree 
  -- drawForceLayout
  
  -- get the initial selection for GUP example
  -- letters <- generalUpdatePatternSetup
  -- | the "General Update Pattern" runs in Aff, so it's tidier to run it in a separate function
  -- | we create the selection and then pass it to the update function which loops forever
  -- lettersUpdate letters

  log "🍝"

