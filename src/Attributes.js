export function uncurry_ (f) {
  return function (datum, index) {
    return f(datum)(index)
    }
}

export function addAttribute_ (selection) {
  return (name) => (value) =>
    selection.attr(name, value)
}

export function addTransitionToSelection_ (selection) {
    return (t) => selection.transition(t)
}

// can be called with any selection, in practice called only
// as part of a list of transition attributes, ie for exit nodes
export function addRemoveAttribute_ (transition) {
  return transition.remove()
}

export function addText_ (selection) {
  return (text) => selection.text(text)
}