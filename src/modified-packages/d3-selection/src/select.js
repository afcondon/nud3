import {Selection, root} from "./selection/index.js";

export default function(selector) {
  console.log("I've hijacked the select function in d3-selection/selection/select.js!", selector);
  console.log("what is the root, you ask?", root);
  console.log("what is the Selection, you ask?", Selection);
  return null;
}
