export function uncurry_(f) {
  return function (datum, index) {
    return f(datum)(index)
  }
}

export function addAttribute_(selection) {
  return (name) => (value) =>
    selection.attr(name, value)
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

// can be called with any selection, in practice called only
// as part of a list of transition attributes, ie for exit nodes
export function removeElement_(transition) {
  return transition.remove()
}

export function addText_(selection) {
  return (text) => selection.text(text)
}