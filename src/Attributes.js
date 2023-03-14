export function uncurry_ (f) {
  return function (datum, index) {
    return f(datum)(index)
    }
}