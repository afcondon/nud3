
module Main  where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Examples.GUP (generalUpdatePattern)
import Examples.Matrix (matrix2table)
import Examples.Miserables (drawForceLayout)
import Examples.ThreeLittleCircles (threeLittleCircles)
import Examples.Tree (drawTree)

main :: Effect Unit
main = do
  matrix2table
  -- threeLittleCircles
  -- generalUpdatePattern
  -- drawTree 
  -- drawForceLayout
  log "🍝"

