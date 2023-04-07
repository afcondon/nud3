// import simulation from d3-force
import { forceSimulation } from 'd3-force';

// implement and export the FFI createEngine_ function
export function createEngine_ (params) {
  let engine = forceSimulation(); // there are no nodes at this point
  engine.alpha(params.alpha)
        .alphaDecay(params.alphaDecay)
        .alphaMin(params.alphaMin)
        .alphaTarget(params.alphaTarget)
        .velocityDecay(params.velocityDecay);
  return engine;
}

export function addNodes_ (engine) {
  return (nodes) => (keyFn) => {
    return engine.nodes(nodes, keyFn);
  }
}