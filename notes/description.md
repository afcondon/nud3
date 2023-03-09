# Describe visualizations in plain English

## Problems anticipated or found with new syntax

  * check that attributes can be applied at the appropriate place in the DOM (should be fine)
  * check how to add, for example a group with a label and a symbol  and a shape all at one "visualize" / data-join kind of place
  * show example with non-Identity key formation
  * use records for elements like Circles etc, so that cx, cy can all be unambiguous

## A simple matrix to HTML table example

Start with the `<div>` called "chart".

Add a `<table>` inside it and attach this array of data to it.

Now, for every element in the data make a `<tr>`

And for every `<tr>` that you've just made, make a `<td>`

Now, put a `<span>` inside each <td> and style it like this: (...)

## Multiple entry points

Start by selecting all the `<div>` called "chart"

Add an `<svg>` to each one, with a `<g>` inside that.


## Matrix code as currently implemented
```
matrix2Table :: Effect Unit
matrix2Table = do
  let one = selectOne (SelectorString "body")
      two = appendTo one "table"
      three = selectGrouped (SelectorString "tr")
      four = assignDataArray three [[1,2,3],[4,5,6],[7,8,9]] identityKeyFunction
      five = applyDataToSelection four
              { enter: [Append "tr"]
              , exit: [Remove]
              , update: [] 
              }
      six = selectGrouped five (SelectorString "td")
      seven = subdivideData six identityKeyFunction
      eight = applyDataToSelection seven
              { enter: [Append "td"]
              , exit: [Remove]
              , update: [Attr "class" "cell"] 
              }
  log "🍝"
```

## Matrix code ideal

```
matrix2table :: Effect Unit
matrix2table = do
    let matrix = [[1,2,3],[4,5,6],[7,8,9]]
    root <- select (SelectorString "body")
    table <- appendTo HTML.Table
    rows <- foreachDatumIn matrix (append HTML.TableRow)
    items <- foreachDatum (append HTML.TableData)
    class items "cell"
```

## Matrix code ideal but a bit more complicated

```
matrix2table :: Effect Unit
matrix2table = do
    let matrix = [[1,2,3],[4,5,6],[7,8,9]]
    root <- select (SelectorString "body")
    table <- appendTo HTML.Table
    rows <- foreachDatumIn matrix (append HTML.TableRow)
    oddrows <- filter "nth-child(odd)"
    style oddrows [background "light-gray", color "white"]
    items <- foreachDatum (append HTML.TableData)
    class items "cell"
```

## iterating ... 
```
matrix2table :: Effect Unit
matrix2table = do
  let matrix = 
      [[1,2,3]
      ,[4,5,6]
      ,[7,8,9]]

  let root = select (SelectorString "body")
  table <- root |+| HTML.table
  rows  <- visualize {
      what:   NewData matrix
    , where:  table
    , key:    Identity
    , enter:  [Append HTML.tr, Classed' "new"]
    , exit:   [Classed' "exit", Remove]
    , update: [Classed' "updated"]
    } 

  let oddrows = filter "nth-child(odd)"
  style oddrows [background "light-gray", color "white"]

  items <- vizualize {
      what:  DataFromParent
    , where: rows
    , key: Identity
    , enter:  [Append HTML.td, Classed' "cell" ]
    , exit: []
    , update: []
  }    
```

## three little circles
```
threeLittleCircles :: Effect Unit
threeLittleCircles = do
  let svgDef = (SVG.svg [viewBox (-100.0) (-100.0) 650.0 650.0
                        , Classed "d3svg circles"])

  let root = select (SelectorString "div#circles")

  svg <- root |+| svgDef
  circleGroup <- svg |+|  SVG.g'
  circles <- visualize {
      what: [32, 57, 293]
    , where: circleGroup
    , key: Identity
    , new: [ Fill' "green"
           , CX \d i -> toFloat (i * 100)
           , CY' 50.0
           , Radius' 20.0 ]
    , exiting: []
    , changing: []
  }
```

## General Update Pattern
```
generalUpdatePattern :: Effect Unit
generalUpdatePattern = do
  let svgDef = (SVG.svg [viewBox 0 0 650.0 650.0
                        , Classed "d3svg gup"])

  let letterdata = toCharArray "abcdefghijklmnopqrstuvwxyz"
  let letterdata2 = toCharArray "acdefglmnostxz"

  let root = select (SelectorString "div#gup")

  svg <- root |+| svgDef
  gupGroup <- svg |+|  SVG.g'
  letters <- visualize {
      what: letterdata
    , where: gupGroup
    , key: Identity
    , new: [ Append SVG.Text
           , Text \d i -> singleton d
           , Fill' "green"
           , X \d i -> toFloat (i * 48 + 50)
           , Y' 0.0
           , FontSize' 96.0
           , TransitionTo [ Y' 200.0 ]
    ] 
    , exiting: [ Classed' "exit"
               , Fill' "brown"
               , TransitionTo [ Y' 400.0
                              , Remove 
                              ]
    ]
    , changing: [ Classed' "update"
                , Fill' "gray"
                , Y' 200.0
                ]
  }
  revisualize letters letterdata2 -- definitely a TODO here as to how this would work
```

## Tree
```
computeX layoutStyle hasChildren x = 
  case layoutStyle of
    Radial -> if hasChildren == (x < Math.pi)
              then 6.0
              else (-6.0)
    _      -> if hasChildren
              then 6.0
              else (-6.0)
computeTextAnchor layoutStyle hasChildren x = 
  case layoutStyle of
    Radial -> if hasChildren == (x < Math.pi)
              then "start"
              else "end"
    _      -> if hasChildren
              then "start"
              else "end"

draw :: Config -> Tree -> Effect Unit
draw config tree =
  let layoutTreeData = layoutTreeVertical tree
  
  let root = select (SelectorString "div#tree")

  svg <- root |+| 
  container <- svg |+| SVG.svg  [ config.viewbox
                                , Classed' "tree"
                                , Width' config.svg.width
                                , Height' config.svg.height ]
  allLinks <- svg |+| SVG.g
  allNodes <- svg |+| SVG.g

  node <- visualize {
      what: laidoutNodes layoutTreeData
    , where: nodesGroup
    , key: Identity
    , newElements: [ Append SVG.g -- group for each circle and its label
                  , FontFamily' "sans-serif"
                  , FontSize' 10.0
                  ]
    , exitingElements: [Remove]
    , changedElements: []
  }
  circles <- node |+| SVG.circle 
    [ Fill \d i -> if d.hasChildren then "#999" else "#555"
    , Radius' 2.5
    , StrokeColor' "white"
    ]
  
  labels <- node |+| SVG.Text
    [ DY' 0.31
    , X' \d i -> computeX config.layoutStyle d.hasChildren d.x
    , Fill' config.color
    , Text \d i -> d.name
    , TextAnchor \d i -> computeTextAnchor config.layoutStyle d.hasChildren d.x
    ]

  individualLink <- visualize {
      what: laidoutLinks layoutTreeData
    , where: linksGroup
    , key: Identity
    , newElements [ Append SVG.path -- path spec??
                  , StrokeWidth' 1.5
                  , StrokeColor' config.color
                  , StrokeOpacity' 0.4
                  , Fill' "none"
                  ]
    , exitingElements: [Remove]
    , changedElements: []
  }

## ForceLayout example
```
draw config model simulator = do
  svg <- root |+| 
  container <- svg |+| SVG.svg  [ config.viewbox
                                , Classed' "force-layout"
                                , Width' config.svg.width
                                , Height' config.svg.height ]
  linksGroup <- svg |+| SVG.g [ Classed' "link", StrokeColor' "#999", StrokeOpacity' 0.6]
  nodesGroup <- svg |+| SVG.g [ Classed' "node", StrokeColor' "#fff", StrokeOpacity' 1.5]

  -- side-effects ahoy, the data in these selections will change as the simulator runs
  simNodes <- addNodes {
      simulator
    , nodes: model.nodes
    , key: \d i -> d.id
    , tick: [CX \d i -> d.x, CY  \d i -> d.y]
    , drag: 
  }
                
  simLinks <- addLinks {
      simulator
    , nodes: model.nodes
    , links: model.links
    , key: \d i -> d.id
    , tick: [ X1 \l i -> l.source.x
            , Y1 \l i -> l.source.y
            , X2 \l i -> l.target.x
            , Y2 \l i -> l.target.y
            ]
    , drag: NoDrag
  }                

  nodes <- visualize {
      what: simNodes
    , where: nodesGroup
    , key: Identity
    , newElements [ Append SVG.circle
                  , Radius' 5.0
                  , Fill \d i -> d.colorByGroup
                  ]
    , exitingElements: [ Remove ]
    , changedElements: []
  }

  links <- visualize {
      what: simLinks
    , key: Identity
    , 
  }

```
  