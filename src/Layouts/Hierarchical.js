import { tree, cluster, hierarchy } from "d3-hierarchy";
import { linkHorizontal, linkVertical, linkRadial } from "d3-shape";

export function getClusterLayoutFn_() { return cluster() }
export function getTreeLayoutFn_() { return tree() }

// taken from D3Tagless FFI TODO all needs to be reviewed / rewritten
export function find_(tree) { return filter => tree.find(filter) }
export function sharesParent_(a) { return b => a.parent == b.parent }
export function ancestors_(tree) { return tree.ancestors() }
export function descendants_(tree) { return tree.descendants() }
export function leaves_(tree) { return tree.leaves() }
export function links_(tree) { return tree.links() }
export function path_(from) { return to => tree.path(from, to) }
export function hierarchyFromJSON_(json) { return hierarchy(json) }

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

export function treeSetSeparation_(tree) { return separationFn => tree.separation(separationFn) }
export function treeSetSize_(tree) { return widthHeight => tree.size(widthHeight) }
export function treeSetNodeSize_(tree) { return widthHeight => tree.nodeSize(widthHeight) }
export function runLayoutFn_(layout) { return root => layout(root) }

export function treeMinMax_(root) {
  let max_x = -(Infinity) // start max with smallest possible number
  let min_x = Infinity    // start min with the largest possible number
  let max_y = -(Infinity)
  let min_y = Infinity
  root.each(d => {
    if (d.x > max_x) max_x = d.x // if we find a value greater than current max, that's our new maximum
    if (d.y > max_y) max_y = d.y

    if (d.x < min_x) min_x = d.x // if we find a value less than current min, that's our new minimum
    if (d.y < min_y) min_y = d.y
    // console.log(`FFI: node ${d} (${min_x}, ${min_y}) (${max_x}, ${max_y})`);
  })
  return { xMin: min_x, xMax: max_x, yMin: min_y, yMax: max_y }
}
