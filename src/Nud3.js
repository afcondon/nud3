export function selectFirstWithStringSelector (selector) { return d3.select(selector) }
export function selectManyWithStringSelector (selector) { return d3.selectAll(selector) }
export function selectFirstFromWithStringSelector (selection) { return (selector) => selection.select(selector) } 
export function selectGroupedWithStringSelector (selection) { return (selector) => selection.selectAll(selector) }

export function selectFirstWithFunctionSelector (selector) { return d3.select(selector) }
export function selectManyWithFunctionSelector (selector) { return d3.selectAll(selector) }
export function selectFirstFromWithFunctionSelector (selection) { return (selector) => selection.select(selector) }
export function selectGroupedWithFunctionSelector (selection) { return (selector) => selection.selectAll(selector) }
