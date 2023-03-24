import { easeCubic } from "d3-ease";
import { Transition } from "d3-transition";

export function easeCubic_(d) { return easeCubic(d) } // is there an easier way to do this?

export function uncurry_(f) {
  return function (datum, index) {
    return f(datum)(index)
  }
}

let referenceTransition = null;

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
    referenceTransition = st;
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
  let foo = Object.getPrototypeOf(selection);
  let bar = Transition.prototype; // TODO this is not workable longterm because Transaction is not exported in the unmodified d3
  if (foo !== bar) {
    throw new Error("transition is not active")
  }
}
export function retrieveSelection_(transition) {
  // we don't have to assert that the transition is active here because
  // selection.selection() will work on a selection as well
  let s = transition.selection();
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
  let tt = transition.transition();
  return tt
}
// remove() can be called with any selection, in practice called only
// as part of a list of transition attributes, ie for exit nodes
export function removeElements_(transition) {
  assertTransitionIsActive(transition);
  return transition.remove()
}