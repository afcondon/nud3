// The following two functions break out two of the many ways that d3.selectAll can be called
// with a string 

// export default function(selector) {
//   return typeof selector === "string"
//       ? new Selection([document.querySelectorAll(selector)], [document.documentElement])
//       : new Selection([array(selector)], root);
// }

export function selectManyWithString_ (selector)  
{ return new Selection([document.querySelectorAll(selector)], [document.documentElement])
}
export function selectManyWithFunction_ (selectorFn) {
  return new Selection([array(selectorFn)], root) // root = [null]
}

// TODO probably try to NOT expose these and keep them completely opaque
// or else find a way to expose this stuff in PureScript instead
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

// beginJoin_ :: Selection_ -> String -> Selection_
export function beginJoin_ (selection) {
  return (element) => selection.selectAll(element)
}
// useInheritedData_ :: Selection_ -> Selection_
export function useInheritedData_ (selection) {
  return selection.data(d => d);
}
// addData_ :: Selection_ -> Array d -> Selection_
export function addData_ (selection) {
  return (data) => selection.data(data)
}

export function getEnterUpdateExitSelections_ (selection) {
  return { enter: selection.enter(), update: selection, exit: selection.exit() }
}

// mergeSelections_ :: Selection_ -> Selection_ -> Selection_
export function mergeSelections_ (first) {
  return (second) => first.merge(second)
}

// orderSelection_ :: Selection_ -> Selection_
export function orderSelection_ (selection) {
  return selection.order()
}

// Stuff from Transition modules - need to bite the bullet and figure out the modules for this later, but for now don't want to just import the whole thing

// in D3 this is d3.transition() which delegates to d3.selection/selection.js 
// we'll spell out exactly what gets done here to make it easier to replace later
// (and easier to understand)
export function createNewTransition_ () { // WIP
  let s = new Selection([[document.documentElement]], root);
  // TODO setup all the transition stuff here if necessary - may not be
  return s;
}



// ---------------------------------------------------------------------
// Code below this comment is from D3.js, introduced in the order that the dependencies played out
// First up are the prototype definitions for Selection_ and Transition_
// ---------------------------------------------------------------------

// ---------------------------------------------------------------------
// - add the functions to the constructor / prototype. 
// we'll be adding these as needed in order to fully understand the dependencies
Selection.prototype = selection.prototype = {
  constructor: Selection,
  // [Symbol.iterator]: selection_iterator
  // call: selection_call,
  // classed: selection_classed,
  // clone: selection_clone,
  // datum: selection_datum,
  // dispatch: selection_dispatch,
  // empty: selection_empty,
  // filter: selection_filter,
  // html: selection_html,
  // lower: selection_lower,
  // nodes: selection_nodes,
  // on: selection_on,
  // property: selection_property,
  // raise: selection_raise,
  // selectChild: selection_selectChild,
  // selectChildren: selection_selectChildren,
  // size: selection_size,
  // sort: selection_sort,
  // style: selection_style,
  // text: selection_text,
  append: selection_append,
  attr: selection_attr,
  data: selection_data,
  each: selection_each,
  enter: selection_enter,
  exit: selection_exit,
  insert: selection_insert,
  // join: selection_join,
  node: selection_node,
  merge: selection_merge,
  order: selection_order,
  remove: selection_remove,
  select: selection_select,
  selectAll: selection_selectAll,
  selection: selection_selection,
};

// Transition.prototype = transition.prototype = {
//   constructor: Transition,
//   // first things that are simply inherited from selection commented out if they are
//   // also commented out in the selection at present
//   // [Symbol.iterator]: selection_prototype[Symbol.iterator],
//   // selectChild: selection_selectChild,
//   // selectChildren: selection_selectChildren,
//   // call: selection_call,
//   // nodes: selection_nodes,
//   node: selection_node,
//   // size: selection_size,
//   // empty: selection_empty,
//   each: selection_each,

//   // now the methods that are unique to transition, to be uncommented as needed for MVP
//   // select: transition_select,
//   // selectAll: transition_selectAll,
//   // filter: transition_filter,
//   // merge: transition_merge,
//   // selection: transition_selection,
//   // transition: transition_transition,
//   // on: transition_on,
//   // attr: transition_attr,
//   // attrTween: transition_attrTween,
//   // style: transition_style,
//   // styleTween: transition_styleTween,
//   // text: transition_text,
//   // textTween: transition_textTween,
//   // remove: transition_remove,
//   // tween: transition_tween,
//   delay: transition_delay,
//   duration: transition_duration,
//   ease: transition_ease,
//   // easeVarying: transition_easeVarying,
//   // end: transition_end
// };

// ---------------------------------------------------------------------
// -- REFERENCE from D3/selection/join.js NOT USED IN THIS IMPLEMENTATION
// ---------------------------------------------------------------------
// join.js is a key module as it manages the General Update Patter by running the enter and exit functions on those selections.
// the enter and update selections are merged and returned, but can be treated differently, ie wrt attributes and transitions
function selection_join(onenter, onupdate, onexit) {
  var enter = this.enter(), update = this, exit = this.exit();
  if (typeof onenter === "function") { // onenter simple (element name) or complex (function)
    enter = onenter(enter); // if it's a function then call that function with the enter selection
    if (enter) enter = enter.selection(); // if that didn't return a null, update enter selection with the result of the function
  } else {
    enter = enter.append(onenter + ""); // if it's simply a string, append the element named by that string
  }
  if (onupdate != null) { // on update can be null or a function
    update = onupdate(update); // if it's a function, call it with the update selection
    if (update) update = update.selection(); // if that didn't return a null, update the update selection with the result of the function
  }
  //onexit can be null or a function
  // if it's null we go ahead an remove the exit selection, otherwise we call the function with the exit selection
  // this could lead to a transition running and then the exit selection being removed at the end of the transition
  if (onexit == null) exit.remove(); else onexit(exit); 
  // if the enter and update selections are both defined, merge them and return them, otherwise just return the update selection
  return enter && update ? enter.merge(update).order() : update;
}

// ---------------------------------------------------------------------
// - from D3/selection/each.js
// ---------------------------------------------------------------------
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
// ---------------------------------------------------------------------

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
// ---------------------------------------------------------------------

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
// ---------------------------------------------------------------------
// the relevant line is included in the implementation of selectManyWithString_ above
// the alternate path will be used for selectManyWithFunction_ when implemented

// import array from "./array.js";
// import {Selection, root} from "./selection/index.js";

// export default function(selector) {
//   return typeof selector === "string"
//       ? new Selection([document.querySelectorAll(selector)], [document.documentElement])
//       : new Selection([array(selector)], root);
// }

// ---------------------------------------------------------------------
// - from D3.index.js
// ---------------------------------------------------------------------
export var root = [null]; // root is used in selection(), d3.select() and d3. selectAll(), and via selection also in d3.transition()

export function Selection(groups, parents, name) {
  this._groups = groups;
  this._parents = parents;
  this._name = name;
}

// ---------------------------------------------------------------------
// - from D3/selectorAll.js
// ---------------------------------------------------------------------

function empty() { // TODO check that this doesn't clash with the empty function in D3/selection/empty.js now that it's all in one file
  return [];
}

function selectorAll(selector) {
  return selector == null ? empty : function() {
    return this.querySelectorAll(selector);
  };
}

// ---------------------------------------------------------------------
// - from D3/selection/selectAll.js (not to be confused with D3/selectAll.js)
// ---------------------------------------------------------------------

function arrayAll(select) {
  return function() {
    return array(select.apply(this, arguments));
  };
}

function selection_selectAll (select) {
  if (typeof select === "function") select = arrayAll(select);
  else select = selectorAll(select);

  for (var groups = this._groups, m = groups.length, subgroups = [], parents = [], j = 0; j < m; ++j) {
    for (var group = groups[j], n = group.length, node, i = 0; i < n; ++i) {
      if (node = group[i]) {
        subgroups.push(select.call(node, node.__data__, i, group));
        parents.push(node);
      }
    }
  }

  return new Selection(subgroups, parents);
}

// ---------------------------------------------------------------------
// - from D3.array.js
// ---------------------------------------------------------------------

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
// ---------------------------------------------------------------------
// import creator from "../creator.js";

function selection_append(name) {
  var create = typeof name === "function" ? name : creator(name);
  return this.select(function() {
    return this.appendChild(create.apply(this, arguments));
  });
}

// ---------------------------------------------------------------------
// - from D3.insert.js
// ---------------------------------------------------------------------
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
// ---------------------------------------------------------------------

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
// ---------------------------------------------------------------------

function namespace(name) {
  var prefix = name += "", i = prefix.indexOf(":");
  if (i >= 0 && (prefix = name.slice(0, i)) !== "xmlns") name = name.slice(i + 1);
  return namespaces.hasOwnProperty(prefix) ? {space: namespaces[prefix], local: name} : name; // eslint-disable-line no-prototype-builtins
}

// ---------------------------------------------------------------------
// - from D3.namespaces.js -- TODO review this, it's just Cmd-C Cmd-V from D3 at the moment
// ---------------------------------------------------------------------
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
// ---------------------------------------------------------------------

function selection() {
  return new Selection([[document.documentElement]], root);
}

function selection_selection() {
  return this;
}

// ---------------------------------------------------------------------
// - from selection/select.js
// ---------------------------------------------------------------------

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
// ---------------------------------------------------------------------
function none() {}

function selector (selector) {
  return selector == null ? none : function() {
    return this.querySelector(selector);
  };
}

// ---------------------------------------------------------------------
// - from selection/sparse.js
// ---------------------------------------------------------------------
function sparse(update) {
  return new Array(update.length);
}

// ---------------------------------------------------------------------
// - from d3/selection/exit.js
// ---------------------------------------------------------------------

function selection_exit() {
  return new Selection(this._exit || this._groups.map(sparse), this._parents);
}
// ---------------------------------------------------------------------
// - from d3/selection/enter.js
// ---------------------------------------------------------------------

function selection_enter() {
  return new Selection(this._enter || this._groups.map(sparse), this._parents);
}

function EnterNode(parent, datum) {
  this.ownerDocument = parent.ownerDocument;
  this.namespaceURI = parent.namespaceURI;
  this._next = null;
  this._parent = parent;
  this.__data__ = datum;
}

EnterNode.prototype = {
  constructor: EnterNode,
  appendChild: function(child) { return this._parent.insertBefore(child, this._next); },
  insertBefore: function(child, next) { return this._parent.insertBefore(child, next); },
  querySelector: function(selector) { return this._parent.querySelector(selector); },
  querySelectorAll: function(selector) { return this._parent.querySelectorAll(selector); }
};

// ---------------------------------------------------------------------
// - from d3/src/constant.js
// ---------------------------------------------------------------------

function constant (x) {
  return function() {
    return x;
  };
}

// ---------------------------------------------------------------------
// - from selection/data.js
// ---------------------------------------------------------------------

function bindIndex(parent, group, enter, update, exit, data) {
  var i = 0,
      node,
      groupLength = group.length,
      dataLength = data.length;

  // Put any non-null nodes that fit into update.
  // Put any null nodes into enter.
  // Put any remaining data into enter.
  for (; i < dataLength; ++i) {
    if (node = group[i]) {
      node.__data__ = data[i];
      update[i] = node;
    } else {
      enter[i] = new EnterNode(parent, data[i]);
    }
  }

  // Put any non-null nodes that don’t fit into exit.
  for (; i < groupLength; ++i) {
    if (node = group[i]) {
      exit[i] = node;
    }
  }
}

function bindKey(parent, group, enter, update, exit, data, key) {
  var i,
      node,
      nodeByKeyValue = new Map,
      groupLength = group.length,
      dataLength = data.length,
      keyValues = new Array(groupLength),
      keyValue;

  // Compute the key for each node.
  // If multiple nodes have the same key, the duplicates are added to exit.
  for (i = 0; i < groupLength; ++i) {
    if (node = group[i]) {
      keyValues[i] = keyValue = key.call(node, node.__data__, i, group) + "";
      if (nodeByKeyValue.has(keyValue)) {
        exit[i] = node;
      } else {
        nodeByKeyValue.set(keyValue, node);
      }
    }
  }

  // Compute the key for each datum.
  // If there a node associated with this key, join and add it to update.
  // If there is not (or the key is a duplicate), add it to enter.
  for (i = 0; i < dataLength; ++i) {
    keyValue = key.call(parent, data[i], i, data) + "";
    if (node = nodeByKeyValue.get(keyValue)) {
      update[i] = node;
      node.__data__ = data[i];
      nodeByKeyValue.delete(keyValue);
    } else {
      enter[i] = new EnterNode(parent, data[i]);
    }
  }

  // Add any remaining nodes that were not bound to data to exit.
  for (i = 0; i < groupLength; ++i) {
    if ((node = group[i]) && (nodeByKeyValue.get(keyValues[i]) === node)) {
      exit[i] = node;
    }
  }
}

function datum(node) {
  return node.__data__;
}

function selection_data(value, key) {
  if (!arguments.length) return Array.from(this, datum);

  var bind = key ? bindKey : bindIndex,
      parents = this._parents,
      groups = this._groups;

  if (typeof value !== "function") value = constant(value);

  for (var m = groups.length, update = new Array(m), enter = new Array(m), exit = new Array(m), j = 0; j < m; ++j) {
    var parent = parents[j],
        group = groups[j],
        groupLength = group.length,
        data = arraylike(value.call(parent, parent && parent.__data__, j, parents)),
        dataLength = data.length,
        enterGroup = enter[j] = new Array(dataLength),
        updateGroup = update[j] = new Array(dataLength),
        exitGroup = exit[j] = new Array(groupLength);

    bind(parent, group, enterGroup, updateGroup, exitGroup, data, key);

    // Now connect the enter nodes to their following update node, such that
    // appendChild can insert the materialized enter node before this node,
    // rather than at the end of the parent node.
    for (var i0 = 0, i1 = 0, previous, next; i0 < dataLength; ++i0) {
      if (previous = enterGroup[i0]) {
        if (i0 >= i1) i1 = i0 + 1;
        while (!(next = updateGroup[i1]) && ++i1 < dataLength);
        previous._next = next || null;
      }
    }
  }

  update = new Selection(update, parents);
  update._enter = enter;
  update._exit = exit;
  return update;
}

// Given some data, this returns an array-like view of it: an object that
// exposes a length property and allows numeric indexing. Note that unlike
// selectAll, this isn’t worried about “live” collections because the resulting
// array will only be used briefly while data is being bound. (It is possible to
// cause the data to change while iterating by using a key function, but please
// don’t; we’d rather avoid a gratuitous copy.)
function arraylike(data) {
  return typeof data === "object" && "length" in data
    ? data // Array, TypedArray, NodeList, array-like
    : Array.from(data); // Map, Set, iterable, string, or anything else
}

// ---------------------------------------------------------------------
// - from d3/src/selection/merge.js
// ---------------------------------------------------------------------

function selection_merge (context) {
  var selection = context.selection ? context.selection() : context;

  for (var groups0 = this._groups, groups1 = selection._groups, m0 = groups0.length, m1 = groups1.length, m = Math.min(m0, m1), merges = new Array(m0), j = 0; j < m; ++j) {
    for (var group0 = groups0[j], group1 = groups1[j], n = group0.length, merge = merges[j] = new Array(n), node, i = 0; i < n; ++i) {
      if (node = group0[i] || group1[i]) {
        merge[i] = node;
      }
    }
  }

  for (; j < m0; ++j) {
    merges[j] = groups0[j];
  }

  return new Selection(merges, this._parents);
}

// ---------------------------------------------------------------------
// - from d3/src/selection/remove.js
// ---------------------------------------------------------------------

function remove() {
  var parent = this.parentNode;
  if (parent) parent.removeChild(this);
}

function selection_remove() {
  return this.each(remove);
}

//----------------------------------------------------------------------
// - from d3/src/selection/order.js
function selection_order () {

  for (var groups = this._groups, j = -1, m = groups.length; ++j < m;) {
    for (var group = groups[j], i = group.length - 1, next = group[i], node; --i >= 0;) {
      if (node = group[i]) {
        if (next && node.compareDocumentPosition(next) ^ 4) next.parentNode.insertBefore(node, next);
        next = node;
      }
    }
  }

  return this;
}

