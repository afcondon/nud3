import { selectAll } from "d3-selection";
import { easeCubic } from "d3-ease";

export function easeCubic_ (d) { return easeCubic(d) } // is there an easier way to do this?

// ------------------ Selection ------------------
// The following two functions break out two of the many ways that d3.selectAll can be called
export function selectManyWithString_ (selector)  
{ 
  return selectAll(selector);
  // morally this function 
  // return new Selection([document.querySelectorAll(selector)], [document.documentElement])
}
export function selectManyWithFunction_ (selectorFn) {
  return selectAll(selectorFn);
  // morally this function
  // return new Selection([array(selectorFn)], root) // root = [null]
}

// TODO probably try to NOT expose these and keep them completely opaque
// or else find a way to expose this stuff in PureScript instead
export function getGroups_ (selection) { return selection._groups }
export function getParents_ (selection) { return selection._parents }
export function getName_ (selection) { return selection._name }

export function appendElement_ (name) {
  return (selection) =>
    selection.append(name)
}

export function insertElement_ (name) {
  return (selector) => (selection) =>
    selection.insert(name, selector)
}

// beginJoin_ :: Selection_ -> String -> Selection_
export function prepareJoin_ (selection) {
  return (element) => selection.selectAll(element)
}
// useInheritedData_ :: Selection_ -> Selection_
export function useInheritedData_ (selection) {
  return selection.data(d => d); // TODO use a key function if provided
}
// addData_ :: Selection_ -> Array d -> Selection_
export function addData_ (selection) {
  return (data) => selection.data(data, d => d) // TODO use key function if provided
}

// export function getEnterUpdateExitSelections_ (selection) {
//   return { enter: selection.enter(), update: selection, exit: selection.exit() }
// }

export function completeJoin_ (selection) { // NB the order of the functions arguments is important: enter, update, exit
  // update and exit are optional - but enter is not
  // also exit is more optional than update, which is just terrible
  return (gupFunctions) => selection.join(gupFunctions.enterFn, gupFunctions.updateFn, gupFunctions.exitFn)
}

// mergeSelections_ :: Selection_ -> Selection_ -> Selection_
export function mergeSelections_ (first) {
  return (second) => first.merge(second)
}

// orderSelection_ :: Selection_ -> Selection_
export function orderSelection_ (selection) {
  return selection.order()
}

// ------------------ Transition ------------------
import { transition } from "d3-transition";

export function createNewTransition_ () { 
  let t = transition();
  console.log("creating new transition ", t._id);
  t.end().then(() => console.log("transition ended for t: ", t._id));
  t.on("interrupt", () => console.log("transition interrupted for t: ", t._id));
  return t
}

export function transitionDelayFixed_ (transition) { 
  return (amount) => {
    console.log("adding a fixed delay of " + amount + " to transition " + transition._id + "");
    return transition.delay(amount)
  }
}
export function transitionDelayLambda_ (transition) {
  return (f) => transition.delay(f)
}
export function transitionDurationFixed_ (transition) { 
  return (amount) => {
    console.log("adding a fixed duration of " + amount + " to transition " + transition._id + "");
    return transition.duration(amount)
  }
}
export function transitionDurationLambda_ (transition) {
  return (f) => transition.duration(f)
}
export function transitionEaseFunction (transition) {
  return (f) => transition
  // return (f) => transition.ease(f()) // TODO find out how to export the underlying function instead of wrapping it
}

