import { select } from "d3-selection";

export function foo (i) {
  const svg = select("#map");
  return 1 + 3;
}

// The following two functions break out two of the many ways that d3.selectAll can be called

export function selectManyWithString_ (selector)  
{ 
  console.log("selectManyWithString_");
  foo(3);
  //return new Selection([document.querySelectorAll(selector)], [document.documentElement])
}
export function selectManyWithFunction_ (selectorFn) {
  //return new Selection([array(selectorFn)], root) // root = [null]
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
export function beginJoin_ (selection) {
  return (element) => selection.selectAll(element)
}
// useInheritedData_ :: Selection_ -> Selection_
export function useInheritedData_ (selection) {
  return selection.data(d => d);
}
// addData_ :: Selection_ -> Array d -> Selection_
export function addData_ (selection) {
  return (data) => selection.data(data)
}

export function getEnterUpdateExitSelections_ (selection) {
  return { enter: selection.enter(), update: selection, exit: selection.exit() }
}

// mergeSelections_ :: Selection_ -> Selection_ -> Selection_
export function mergeSelections_ (first) {
  return (second) => first.merge(second)
}

// orderSelection_ :: Selection_ -> Selection_
export function orderSelection_ (selection) {
  return selection.order()
}

// in D3 this is d3.transition() which delegates to d3.selection/selection.js 
// d3-transition/src/transition/index.js imports the following things:

// import {selection} from "d3-selection";
// import selection_interrupt from "./interrupt.js";
// import selection_transition from "./transition.js";

// selection.prototype.interrupt = selection_interrupt;
// selection.prototype.transition = selection_transition;

// we'll spell out exactly what gets done here to make it easier to replace later
// (and easier to understand)
export function createNewTransition_ () { // WIP
  let s = new Selection([[document.documentElement]], root); // first thing that happens in d3.transition() is creation of a new Selection object
  // TODO setup all the transition stuff here if necessary - may not be
  // second thing that happens is initialisation of a new Transition object using the selection object function transition()
  let t = s.transition(); 
  // d3-transition/src/selection/index.js imports the following things:
// import {Transition, newId} from "../transition/index.js";
// import schedule from "../transition/schedule.js";
// import {easeCubicInOut} from "d3-ease";
// import {now} from "d3-timer";

  return s;
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
export function transitionEaseFunction (transition) {
  return (f) => transition.ease(f)
}

