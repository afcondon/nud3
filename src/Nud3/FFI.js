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

export function addAttribute_ (selection) {
  return (name) => (value) =>
    selection.attr(name, value)
}

// Code below this comment is from D3.js, introduced in the order that the dependencies played out

// ---------------------------------------------------------------------
// - from D3/selection/each.js
function selection_each(callback) {

  for (var groups = this._groups, j = 0, m = groups.length; j < m; ++j) {
    for (var group = groups[j], i = 0, n = group.length, node; i < n; ++i) {
      if (node = group[i]) callback.call(node, node.__data__, i, group);
    }
  }

  return this;
}


// ---------------------------------------------------------------------
// - from D3/selection/node.j

function selection_node() {

  for (var groups = this._groups, j = 0, m = groups.length; j < m; ++j) {
    for (var group = groups[j], i = 0, n = group.length; i < n; ++i) {
      var node = group[i];
      if (node) return node;
    }
  }

  return null;
}

// ---------------------------------------------------------------------
// - from D3/selection/attr.js

// all this stuff from D3.js is just Cmd-C Cmd-V at the moment, 
// looks over-complicated too, should simplify and de-multiplex the polymorphic parameters

function attrRemove(name) {
  return function() {
    this.removeAttribute(name);
  };
}

function attrRemoveNS(fullname) {
  return function() {
    this.removeAttributeNS(fullname.space, fullname.local);
  };
}

function attrConstant(name, value) {
  return function() {
    this.setAttribute(name, value);
  };
}

function attrConstantNS(fullname, value) {
  return function() {
    this.setAttributeNS(fullname.space, fullname.local, value);
  };
}

function attrFunction(name, value) {
  return function() {
    var v = value.apply(this, arguments);
    if (v == null) this.removeAttribute(name);
    else this.setAttribute(name, v);
  };
}

function attrFunctionNS(fullname, value) {
  return function() {
    var v = value.apply(this, arguments);
    if (v == null) this.removeAttributeNS(fullname.space, fullname.local);
    else this.setAttributeNS(fullname.space, fullname.local, v);
  };
}

function selection_attr(name, value) {
  var fullname = namespace(name);

  if (arguments.length < 2) {
    var node = this.node();  // this introduces a dependency on D3/selection/node.js
    return fullname.local
        ? node.getAttributeNS(fullname.space, fullname.local)
        : node.getAttribute(fullname);
  }

  return this.each((value == null // this introduces a dependency on D3/selection/each.js
      ? (fullname.local ? attrRemoveNS : attrRemove) : (typeof value === "function"
      ? (fullname.local ? attrFunctionNS : attrFunction)
      : (fullname.local ? attrConstantNS : attrConstant)))(fullname, value));
}

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
  // [Symbol.iterator]: selection_iterator
  // call: selection_call,
  // classed: selection_classed,
  // clone: selection_clone,
  // data: selection_data,
  // datum: selection_datum,
  // dispatch: selection_dispatch,
  // empty: selection_empty,
  // enter: selection_enter,
  // exit: selection_exit,
  // filter: selection_filter,
  // html: selection_html,
  // join: selection_join,
  // lower: selection_lower,
  // merge: selection_merge,
  // nodes: selection_nodes,
  // on: selection_on,
  // order: selection_order,
  // property: selection_property,
  // raise: selection_raise,
  // remove: selection_remove,
  // selectAll: selection_selectAll,
  // selectChild: selection_selectChild,
  // selectChildren: selection_selectChildren,
  // size: selection_size,
  // sort: selection_sort,
  // style: selection_style,
  // text: selection_text,
  append: selection_append,
  attr: selection_attr,
  each: selection_each,
  insert: selection_insert,
  node: selection_node,
  select: selection_select,
  selection: selection_selection,
};
