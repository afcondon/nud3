
module Main  where

import Prelude

import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Examples.GUP (generalUpdatePatternDraw, generalUpdatePatternSetup)
import Examples.Matrix (matrix2table)
import Examples.ThreeLittleCircles (threeLittleCircles)

examplesInEffect :: Effect Unit
examplesInEffect = do
  matrix2table
  threeLittleCircles
  -- drawTree 
  -- drawForceLayout

examplesInAff :: Effect Unit
examplesInAff = launchAff_ do
  letters <- liftEffect $ generalUpdatePatternSetup
  _ <- liftEffect $ generalUpdatePatternDraw letters "acdefglmnostxz"
  delay $ Milliseconds 1800.0
  _ <- liftEffect $ generalUpdatePatternDraw letters "abcdejklmnopqrstuvwxyz" 
  delay $ Milliseconds 1800.0
  _ <- liftEffect $ generalUpdatePatternDraw letters "abdejklmnopwxz"
  pure unit

main :: Effect Unit
main = do
  examplesInEffect
  examplesInAff
  liftEffect $ log "🍝"

