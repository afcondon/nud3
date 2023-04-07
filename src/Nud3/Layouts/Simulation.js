// import simulation from d3-force
import { forceSimulation, forceLink } from 'd3-force';

// implement and export the FFI createEngine_ function
export function createEngine_ (params) {
  let engine = forceSimulation(); // there are no nodes at this point
  engine.alpha(params.alpha)
        .alphaDecay(params.alphaDecay)
        .alphaMin(params.alphaMin)
        .alphaTarget(params.alphaTarget)
        .velocityDecay(params.velocityDecay);
  engine.force("links", forceLink()); // add a forceLink to the simulation with no links
  return engine;
}

export function addNodes_ (engine) {
  return (nodes) => (keyFn) => {
    console.log(`FFI: setting nodes in simulation, there are ${nodes.length} nodes`);
    engine.nodes(nodes, keyFn); // put the nodes into the simulation
    return engine.nodes(); // then return the nodes which should now contain the additional fields needed for the simulation
  }
}

// creates a forceLink and adds it to the engine, NB we actually don't want to do this, instead create the links at the same time as the engine and just update here
// TODO create linksforce on simulation intialization instead of here
export function setLinks_ (engine) {
  return (nodes) => (links) => (keyFn) => {
    console.log(`FFI: setting links in simulation, there are ${links.length} links`);
    let swizzledLinks = swizzleLinks_(links)(nodes)(keyFn);
    engine.force("links").links(swizzledLinks);
    return swizzledLinks; // previously was: engine.force("links").links();
  }
}

// returns array of links with ids replaced by object references, invalid links are discarded
// TODO this code came from TaglessII - if it isn't needed from the PureScript side then it can be uncurried
export function swizzleLinks_(links) {
  return simNodes => keyFn => {
    console.log(`FFI: swizzling links in simulation, there are ${links.length} links`);
    const nodeById = new Map(simNodes.map(d => [keyFn(d), d])); // creates a map from our chosen id to the old obj reference
    // we could use the copy approach from d3PreserveSimulationPositions here so that links animate
    const swizzledLinks = links.filter((link, index, arr) => {
      // look up both source and target (which could be id or obj reference)
      // if both source and target are found in nodeMap then we can swizzle and return true
      // else we just return false and this node will go in the bit bucket
      if (typeof link.source !== "object") {
        link.source = nodeById.get(link.source) // try to get object reference if we don't have it
      } else {
        link.source = nodeById.get(keyFn(link.source)) // try to replace object reference with new object reference
      }
      if (typeof link.target !== "object") {
        link.target = nodeById.get(link.target)
      } else {
        link.target = nodeById.get(keyFn(link.target))
      }
      // now let's see what we got from that and if we have a valid link or not
      if (typeof link.source === 'undefined' || link.target === 'undefined') {
        return false; // filter this node
      } else {
        link.id = keyFn(link.source) + "-" + keyFn(link.target)
        return true // we've updated the 
      }
    })
    return swizzledLinks
  }
}
