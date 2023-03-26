import { tree, cluster } from "d3-hierarchy";
import { linkHorizontal, linkVertical, linkRadial } from "d3-shape";

export function getClusterLayoutFn_() { return cluster() }
export function getTreeLayoutFn_() { return tree() }

// taken from D3Tagless FFI TODO all needs to be reviewed / rewritten
export function find_(tree) { return filter => tree.find(filter) }
export function sharesParent_(a) { return b => a.parent == b.parent }

export const linkHorizontal_ = linkHorizontal()
  .x(d => d.y)
  .y(d => d.x)
export const linkHorizontal2_ = linkHorizontal()
  .x(d => d.x)
  .y(d => d.y)
export const linkVertical_ = linkVertical()
  .x(d => d.x)
  .y(d => d.y)
export function linkClusterHorizontal_(levelSpacing) {
  return d =>
    `M${d.target.y}, ${d.target.x}
   C${d.source.y + levelSpacing / 2},${d.target.x}
   ${d.source.y + levelSpacing / 2},${d.source.x}
   ${d.source.y},${d.source.x}`
}
export function linkClusterVertical_(levelSpacing) {
  return d =>
    `M${d.target.x}, ${d.target.y}
   C${d.target.x}, ${d.source.y + levelSpacing / 2}
   ${d.source.x},${d.source.y + levelSpacing / 2}
   ${d.source.x},${d.source.y}`
}
export function linkRadial_(angleFn) {
  return radiusFn =>
    linkRadial()
      .angle(angleFn)
      .radius(radiusFn)
}

export function hNodeDepth_(node) { return node.depth }
export function hNodeHeight_(node) { return node.height }
export function hNodeX_(node) { return node.x }
export function hNodeY_(node) { return node.y }
