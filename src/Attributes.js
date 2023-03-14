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

export function createNewTransition_ () {
  // TODO we will need to bring in or rewrite the transition code here
  return d3.transition() 
}

// can be called with any selection, in practice called only
// as part of a list of transition attributes, ie for exit nodes
export function addRemoveAttribute_ (transition) {
  return transition.remove()
}

export function transitionDelayFixed_ (transition) { 
  return (amount) => transition.delay(amount)
}
export function transitionDelayLambda_ (transition) {
  return (f) => transition.delay(f)
}
export function transitionDurationFixed_ (transition) { 
  return (amount) => transition.duration(amount)
}
export function transitionDurationLambda_ (transition) {
  return (f) => transition.duration(f)
}