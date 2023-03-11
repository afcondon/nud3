export function selectManyWithString_ (name)  
{ return (selector) =>
    new Selection([document.querySelectorAll(selector)], [document.documentElement], name)
}
export function selectManyWithFunction_ (name) {
  return (selectorFn) =>
    new Selection([array(selectorFn)], root)
}

export function getGroups_ (selection) { return selection._groups }
export function getParents_ (selection) { return selection._parents }
export function getName_ (selection) { return selection._name }


// Code below this comment is from D3.js

// D3.selectAll
// export default function(selector) {
//   return typeof selector === "string"
//       ? new Selection([document.querySelectorAll(selector)], [document.documentElement])
//       : new Selection([array(selector)], root);
// }
// Selection and root are imported by D3.selectAll
export var root = [null];

export function Selection(groups, parents, name) {
  this._groups = groups;
  this._parents = parents;
  this._name = name;
}

// Given something array like (or null), returns something that is strictly an
// array. This is used to ensure that array-like objects passed to d3.selectAll
// or selection.selectAll are converted into proper arrays when creating a
// selection; we don’t ever want to create a selection backed by a live
// HTMLCollection or NodeList. However, note that selection.selectAll will use a
// static NodeList as a group, since it safely derived from querySelectorAll.
export default function array(x) {
  return x == null ? [] : Array.isArray(x) ? x : Array.from(x);
}
