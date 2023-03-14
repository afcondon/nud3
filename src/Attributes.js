export function uncurry_ (f) {
  return function (datum, index) {
    return f(datum)(index)
    }
}

export function addAttribute_ (selection) {
  return (name) => (value) =>
    selection.attr(name, value)
}

// TODO add support for named transition and all the transition configuration options too
export function addTransition_ (selection) {
  return (duration) => (delay) =>
    selection.transition().duration(duration).delay(delay)
}