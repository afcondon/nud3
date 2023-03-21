
module Main  where

import Prelude

import Data.String.CodeUnits (toCharArray)
import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Examples.GUP (generalUpdatePatternDraw, generalUpdatePatternSetup)


letterdata :: Array Char
letterdata = toCharArray "abcdefghijklmnopqrstuvwxyz"

letterdata2 :: Array Char
letterdata2 = toCharArray "acdefglmnostxz"


main :: Effect Unit
main = launchAff_ do
  -- matrix2table
  -- threeLittleCircles
  letters <- liftEffect $ generalUpdatePatternSetup
  _ <- liftEffect $ generalUpdatePatternDraw letters "acdefglmnostxz"
  delay $ Milliseconds 1800.0
  _ <- liftEffect $ generalUpdatePatternDraw letters "abcdejklmnopqrstuvwxyz" 
  delay $ Milliseconds 1800.0
  _ <- liftEffect $ generalUpdatePatternDraw letters "abdejklmnopwxz" 
  -- drawTree 
  -- drawForceLayout
  liftEffect $ log "🍝"

