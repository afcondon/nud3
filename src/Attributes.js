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

export function addTransitionToSelection_(selection) {
  return (t) => {
    console.log('addTransitionToSelection_ ', t._id);
    return selection.transition(t)
  }
}

export function retrieveSelection_(transition) {
  return transition.selection();
}

export function transitionDelay_(transition) {
  return (value) => transition.delay(value) // value can be a function (uncurried) or a number
}
export function transitionDuration_(transition) {
  return (value) => transition.duration(value) // value can be a function (uncurried) or a number
}
export function transitionEaseFunction(transition) {
  return (f) => transition
  // return (f) => transition.ease(f()) // TODO find out how to export the underlying function instead of wrapping it
}


// can be called with any selection, in practice called only
// as part of a list of transition attributes, ie for exit nodes
export function removeElement_(transition) {
  return transition.remove()
}

export function addText_(selection) {
  return (text) => selection.text(text)
}