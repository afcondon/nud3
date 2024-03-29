module Examples.Simulations.Model where

import Nud3.Graph.Node (D3TreeRow, D3Link, D3_SimulationNode, D3_VxyFxy, D3_XY, EmbeddedData)
import Type.Row (type (+))

-- | ==========================================================================================
-- |                  Model data types specialized with inital data
-- | ==========================================================================================

-- the "extra / model-specific" data above and beyond what any D3 Tree Node is going to have:
type LesMisNodeData row = ( id :: String, group :: Int | row ) 
-- this extra data inside a D3SimNode as used in PureScript:
type LesMisSimNode     = D3_SimulationNode ( LesMisNodeData  + D3_XY + D3_VxyFxy + ()) 

-- first the "extra / model-specific" data in the links
type LesMisLinkData     = ( value :: Number )
type LesMisGraphLinkObj = { source :: LesMisSimRecord, target :: LesMisSimRecord | LesMisLinkData }


-- we make the model like so, but D3 then swizzles it to the "cooked" model below
-- the source and target in the links are given as "String" to match id in the node data
type LesMisRawModel    = { links :: Array (D3Link String LesMisLinkData), nodes :: Array LesMisSimNode  }

-- same as above but as a bare record, this is the "datum" that D3 sees and which it returns to you for attr setting:
type LesMisSimRecord   = Record (D3_XY + D3_VxyFxy + LesMisNodeData  + ()) 



-- now a definition for that same row if it is embedded instead in a D3 Hierarchical structure, in which case
-- our extra data is available in the "datum" as an embedded object at the field "data"
type LesMisTreeNode    = D3TreeRow (EmbeddedData { | LesMisNodeData () } + ())
-- type LesMisTreeRecord  = Record    (D3_ID + D3_TreeRow + D3_XY   + D3_Leaf + EmbeddedData { | LesMisNodeData () } + ())

