import { scaleOrdinal, scaleDiverging, scaleSequential } from "d3-scale";
import { schemeCategory10, schemePaired, interpolateBrBG, interpolateYlOrRd } from "d3-scale-chromatic";

// REVIEW big TODO here is to expose the domain setting of the scales so that this is usable in multiple contexts

export function d3SchemeDiverging10N_(number) { return d3SchemeDiverging10(number) }
export function d3SchemePairedN_(number) { return d3SchemePaired(number) }
export function d3SchemeCategory10N_(number) { return d3SchemeCategory10(number) }
export function d3SchemeSequential10N_(number) { return d3SchemeSequential10(number) }

const d3SchemeCategory10 = scaleOrdinal(schemeCategory10)
export function d3SchemeCategory10S_(string) { return d3SchemeCategory10(string) }

const d3SchemePaired = scaleOrdinal(schemePaired)
export function d3SchemePairedS_(string) { return d3SchemePaired(string) }

const d3SchemeDiverging10 = scaleDiverging(interpolateBrBG)
    .domain([0, 250, 500]); // TODO this should be determined by number of nodes in sim

const d3SchemeSequential10 = scaleSequential()
    .interpolator(interpolateYlOrRd)
    .domain([0, 5, 10]); // TODO this should be determined by number of nodes in sim


// diverging example for reference
// colorScale = d3.scaleSequential()
//     .interpolator(d3.interpolateBrBG)
//     .domain([0,99]);

// sequential example for reference
// colorScale = d3.scaleSequential()
//     .interpolator(d3.interpolateRgb("purple", "orange"))
//     .domain([0,99]);
