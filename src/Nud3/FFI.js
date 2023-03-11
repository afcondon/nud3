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

export function appendElement_ (name) {
  return (selection) =>
    selection.append(name)
}

export function insertElement_ (name) {
  return (selector) => (selection) =>
    selection.insert(name, selector)
}

// Code below this comment is from D3.js

// ---------------------------------------------------------------------
// - from D3.selectAll.js
// import array from "./array.js";
// import {Selection, root} from "./selection/index.js";

// export default function(selector) {
//   return typeof selector === "string"
//       ? new Selection([document.querySelectorAll(selector)], [document.documentElement])
//       : new Selection([array(selector)], root);
// }

// ---------------------------------------------------------------------
// - from D3.index.js
export var root = [null];

export function Selection(groups, parents, name) {
  this._groups = groups;
  this._parents = parents;
  this._name = name;
}

// ---------------------------------------------------------------------
// - from D3.array.js

// Given something array like (or null), returns something that is strictly an
// array. This is used to ensure that array-like objects passed to d3.selectAll
// or selection.selectAll are converted into proper arrays when creating a
// selection; we don’t ever want to create a selection backed by a live
// HTMLCollection or NodeList. However, note that selection.selectAll will use a
// static NodeList as a group, since it safely derived from querySelectorAll.
export default function array(x) {
  return x == null ? [] : Array.isArray(x) ? x : Array.from(x);
}

// ---------------------------------------------------------------------
// - from D3.append.js
// import creator from "../creator.js";

function selection_append(name) {
  var create = typeof name === "function" ? name : creator(name);
  return this.select(function() {
    return this.appendChild(create.apply(this, arguments));
  });
}

// ---------------------------------------------------------------------
// - from D3.insert.js
function constantNull() { // review this, it's just Cmd-C Cmd-V from D3 at the moment
  return null;
}

function selection_insert(name, before) {
  var create = typeof name === "function" ? name : creator(name),
      select = before == null ? constantNull : typeof before === "function" ? before : selector(before);
  return this.select(function() {
    return this.insertBefore(create.apply(this, arguments), select.apply(this, arguments) || null);
  });
}


// ---------------------------------------------------------------------
// - from D3.creator.js -- TODO review this, it's just Cmd-C Cmd-V from D3 at the moment

// import namespace from "./namespace.js";
// import {xhtml} from "./namespaces.js";

function creatorInherit(name) {
  return function() {
    var document = this.ownerDocument,
        uri = this.namespaceURI;
    return uri === namespaces.xhtml && document.documentElement.namespaceURI === namespaces.xhtml
        ? document.createElement(name)
        : document.createElementNS(uri, name);
  };
}

function creatorFixed(fullname) {
  return function() {
    return this.ownerDocument.createElementNS(fullname.space, fullname.local);
  };
}

function creator(name) {
  var fullname = namespace(name);
  return (fullname.local
      ? creatorFixed
      : creatorInherit)(fullname);
}

// ---------------------------------------------------------------------
// - from D3.namespace.js -- TODO review this, it's just Cmd-C Cmd-V from D3 at the moment

function namespace(name) {
  var prefix = name += "", i = prefix.indexOf(":");
  if (i >= 0 && (prefix = name.slice(0, i)) !== "xmlns") name = name.slice(i + 1);
  return namespaces.hasOwnProperty(prefix) ? {space: namespaces[prefix], local: name} : name; // eslint-disable-line no-prototype-builtins
}

// ---------------------------------------------------------------------
// - from D3.namespaces.js -- TODO review this, it's just Cmd-C Cmd-V from D3 at the moment
var xhtml = "http://www.w3.org/1999/xhtml";

var namespaces = {
  svg: "http://www.w3.org/2000/svg",
  xhtml: xhtml,
  xlink: "http://www.w3.org/1999/xlink",
  xml: "http://www.w3.org/XML/1998/namespace",
  xmlns: "http://www.w3.org/2000/xmlns/"
};

// ---------------------------------------------------------------------
// - d3-selection/src/selectAll.js
// incorporated into FFI above

// export default function(selector) {
//   return typeof selector === "string"
//   ? new Selection([[document.querySelector(selector)]], [document.documentElement])
//   : new Selection([[selector]], root);
// }

// ---------------------------------------------------------------------
// - from selection/index.js

function selection() {
  return new Selection([[document.documentElement]], root);
}

function selection_selection() {
  return this;
}

// ---------------------------------------------------------------------
// - from selection/select.js
// import selector from "../selector.js";

function selection_select (select) {
  if (typeof select !== "function") select = selector(select);

  for (var groups = this._groups, m = groups.length, subgroups = new Array(m), j = 0; j < m; ++j) {
    for (var group = groups[j], n = group.length, subgroup = subgroups[j] = new Array(n), node, subnode, i = 0; i < n; ++i) {
      if ((node = group[i]) && (subnode = select.call(node, node.__data__, i, group))) {
        if ("__data__" in node) subnode.__data__ = node.__data__;
        subgroup[i] = subnode;
      }
    }
  }

  return new Selection(subgroups, this._parents);
}

// ---------------------------------------------------------------------
// - from selection/selector.js
function none() {}

function selector (selector) {
  return selector == null ? none : function() {
    return this.querySelector(selector);
  };
}
// there are many many functions on this prototype, uncomment as needed
Selection.prototype = selection.prototype = {
  constructor: Selection,
  select: selection_select,
  // selectAll: selection_selectAll,
  // selectChild: selection_selectChild,
  // selectChildren: selection_selectChildren,
  // filter: selection_filter,
  // data: selection_data,
  // enter: selection_enter,
  // exit: selection_exit,
  // join: selection_join,
  // merge: selection_merge,
  selection: selection_selection,
  // order: selection_order,
  // sort: selection_sort,
  // call: selection_call,
  // nodes: selection_nodes,
  // node: selection_node,
  // size: selection_size,
  // empty: selection_empty,
  // each: selection_each,
  // attr: selection_attr,
  // style: selection_style,
  // property: selection_property,
  // classed: selection_classed,
  // text: selection_text,
  // html: selection_html,
  // raise: selection_raise,
  // lower: selection_lower,
  append: selection_append,
  insert: selection_insert,
  // remove: selection_remove,
  // clone: selection_clone,
  // datum: selection_datum,
  // on: selection_on,
  // dispatch: selection_dispatch,
  // [Symbol.iterator]: selection_iterator
};
