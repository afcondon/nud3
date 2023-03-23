import { easeCubic } from "d3-ease";

export function easeCubic_(d) { return easeCubic(d) } // is there an easier way to do this?

export function uncurry_(f) {
  return function (datum, index) {
    return f(datum)(index)
  }
}

export function addAttribute_(selection) {
  return (name) => (value) =>
    selection.attr(name, value)
}
export function addStyle_(selection) {
  return (name) => (value) =>
    selection.style(name, value)
}
export function addText_(selection) {
  return (text) => selection.text(text)
}
export function addTransitionToSelection_(selection) {
  return (t) => {
    console.log('addTransitionToSelection_ ', t._id);
    let st = selection.transition(t);
    st._mode = "transition";
    return st
  }
}

// No assertion on the init functions because they can be called before the transition has been added to a selection
export function transitionInitDelay_(transition) {
  return (value) => transition.delay(value) // value can be a function (uncurried) or a number
}
export function transitionInitDuration_(transition) {
  return (value) => transition.duration(value) // value can be a function (uncurried) or a number
}
export function transitionInitEaseFunction(transition) {
  return (f) => transition
  // return (f) => transition.ease(f()) // HER-17 TODO find out how to export the underlying function instead of wrapping it
}

// assert to prevent calling transition functions on a selection
function assertTransitionIsActive(selection) {
  if (selection._mode !== "transition") {
    throw new Error("transition is not active")
  }
}
export function retrieveSelection_(transition) {
  assertTransitionIsActive(transition);
  let s = transition.selection();
  s._mode = "selection"; // REVIEW possibly better to just delete the _mode property?
  return s;
}
export function transitionDelay_(transition) {
  assertTransitionIsActive(transition);
  return (value) => transition.delay(value) // value can be a function (uncurried) or a number
}
export function transitionDuration_(transition) {
  assertTransitionIsActive(transition);
  return (value) => transition.duration(value) // value can be a function (uncurried) or a number
}
export function followOnTransition_(transition) {
  assertTransitionIsActive
  console.log('followOnTransition ', t._id);
  let tt = transition.transition();
  tt._mode = "transition";
  return transition.transition()
}
// remove() can be called with any selection, in practice called only
// as part of a list of transition attributes, ie for exit nodes
export function removeElement_(transition) {
  assertTransitionIsActive(transition);
  return transition.remove()
}