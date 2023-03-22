import { selectAll } from "d3-selection";
import { easeCubic } from "d3-ease";

export function easeCubic_(d) { return easeCubic(d) } // is there an easier way to do this?

// ------------------ Selection ------------------
// The following two functions break out two of the many ways that d3.selectAll can be called
export function selectManyWithString_(selector) {
  return selectAll(selector);
  // morally this function 
  // return new Selection([document.querySelectorAll(selector)], [document.documentElement])
}
export function selectManyWithFunction_(selectorFn) {
  return selectAll(selectorFn);
  // morally this function
  // return new Selection([array(selectorFn)], root) // root = [null]
}

// TODO probably try to NOT expose these and keep them completely opaque
// or else find a way to expose this stuff in PureScript instead
export function getGroups_(selection) { return selection._groups }
export function getParents_(selection) { return selection._parents }
export function getName_(selection) { return selection._name }

export function appendElement_(name) {
  return (selection) =>
    selection.append(name)
}

export function insertElement_(name) {
  return (selector) => (selection) =>
    selection.insert(name, selector)
}

// beginJoin_ :: Selection_ -> String -> Selection_
export function prepareJoin_(selection) {
  return (element) => {
    console.log("selection.selectAll: " + element);
    let openSelection = selection.selectAll(element);
    return openSelection // selection.selectAll(element)
  }
}

// uncurryKeyFunction_ :: KeyFunction -> KeyFunction
// NB we're ignoring the 'this' argument for now, could add it later
// NB also, we're ignoring the performance implications of this for really large selections
// (but key functions could easily be added in FFI files to optimize for specific use cases)
export function uncurryKeyFunction_ (f) {
  return (d,i,nodes) => f(d)(i)(nodes)
}
export function identityKey_ (d) { return d}
export function idKey_ (d) { return d.id }

// useInheritedData_ :: Selection_ -> KeyFn -> Selection_
export function useInheritedData_(selection) {
  return (keyFn) => selection.data(d => d, keyFn)
}
// addData_ :: Selection_ -> Array d -> KeyFn -> Selection_
export function addData_(selection) {
  return (data) => (keyFn) => selection.data(data, keyFn)
}

export function completeJoin_(selection) { // NB the order of the functions arguments is important: enter, update, exit
  // update and exit are optional - but enter is not
  // also exit is more optional than update, which is just terrible
  return (fns) => selection.join(fns.enterFn, fns.updateFn, fns.exitFn)
}

// mergeSelections_ :: Selection_ -> Selection_ -> Selection_
export function mergeSelections_(first) {
  return (second) => first.merge(second)
}

// orderSelection_ :: Selection_ -> Selection_
export function orderSelection_(selection) {
  return selection.order()
}

// ------------------ Transition ------------------
import { transition } from "d3-transition";

export function createNewTransition_(name) {
  let t = transition(name);
  console.log("creating new transition ", t._id, " with name ", name);
  t.end().then(() => console.log("transition ended for t: ", t._id));
  t.on("interrupt", () => console.log("transition interrupted for t: ", t._id));
  return t
}

export function transitionDelayFixed_(transition) {
  return (amount) => {
    console.log("adding a fixed delay of " + amount + " to transition " + transition._id + "");
    return transition.delay(amount)
  }
}
export function transitionDelayLambda_(transition) {
  // return (f) => transition.delay(f)
  return (f) => {
    console.log("adding a lambda delay to transition " + transition._id + "");
    return transition.delay(stagger)
  }
}
function stagger(d,i,nodes) {
  console.log("staggering transition for d: ", d, " i: ", i, " nodes: ", nodes);
  return i * 100
}
export function transitionDurationFixed_(transition) {
  return (amount) => {
    console.log("adding a fixed duration of " + amount + " to transition " + transition._id + "");
    return transition.duration(amount)
  }
}
export function transitionDurationLambda_(transition) {
  return (f) => {
    console.log("adding a lambda duration to transition " + transition._id + "");
    return transition.duration(f)
  }
}
export function transitionEaseFunction(transition) {
  return (f) => transition
  // return (f) => transition.ease(f()) // TODO find out how to export the underlying function instead of wrapping it
}

