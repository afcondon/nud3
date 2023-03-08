# Describe visualizations in plain English

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

## Matrix code ideal with GUP 
```
matrix2table :: Effect Unit
matrix2table = do
  let matrix = 
      [[1,2,3]
      ,[4,5,6]
      ,[7,8,9]]

  let root = select (SelectorString "body")
  table <- root `appendTo` HTML.Table
  rows  <- 
    using (NewData matrix)
          (Update { 
              enter : [Append HTML.TableRow, Classed "new"]
              exit  : [Classed "exit", Remove]
              update: [Classed "updated"]
          })
          table

  let oddrows = filter "nth-child(odd)"
  style oddrows [background "light-gray", color "white"]

  items <- 
    using (InheritedData rows) 
          (Enter [ Append HTML.TableData
                 , Classed "cell" ])
          rows
    
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
  table <- root `appendTo` HTML.table
  rows  <- visualize {
      what:   NewData matrix
    , where:  table
    , key:    Identity
    , enter:  [Append HTML.tr, Classed "new"]
    , exit:   [Classed "exit", Remove]
    , update: [Classed "updated"]
    } 

  let oddrows = filter "nth-child(odd)"
  style oddrows [background "light-gray", color "white"]

  items <- vizualize {
      what:  DataFromParent
    , where: rows
    , key: Identity
    , enter:  [Append HTML.td, Classed "cell" ]
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
    , new: [ Fill \d i -> "green"
           , CX \d i -> toFloat (i * 100)
           , CY \d i -> 50.0
           , Radius 20.0 ]
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
    , new: [ Fill \d i -> "green"
           , X \d i -> toFloat (i * 48 + 50)
           , Y \d i -> 0.0
           , Text \d i -> singleton d
           , FontSize \d i -> 96.0
           , TransitionTo [ Y \d i -> 200.0 ]
    ] 
    , exiting: [ Classed \d i -> "exit"
               , Fill \d i -> "brown"
               , TransitionTo [ Y \d i -> 400.0
                              , Remove 
                              ]
    ]
    , changing: [ Classed \d i -> "update"
                , Fill \d i -> "gray"
                , Y \d i -> 200.0
                ]
  }
  revisualize letters letterdata2
```