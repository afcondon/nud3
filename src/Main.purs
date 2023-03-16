
module Main  where

import Prelude

import Effect (Effect)
import Effect.Class.Console (logShow)
import Effect.Console (log)
import Examples.GUP (generalUpdatePattern)
import Examples.Matrix (matrix2table)
import Examples.Miserables (drawForceLayout)
import Examples.ThreeLittleCircles (threeLittleCircles)
import Examples.Tree (drawTree)
import Nud3.FFI (foo)

main :: Effect Unit
main = do
  logShow $ foo 10
  matrix2table
  -- threeLittleCircles
  -- generalUpdatePattern
  -- drawTree 
  -- drawForceLayout
  log "🍝"

