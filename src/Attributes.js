export function uncurry_ (f) {
  return function (datum, index) {
    return f(datum)(index)
    }
}

export function addAttribute_ (selection) {
  return (name) => (value) =>
    selection.attr(name, value)
}
