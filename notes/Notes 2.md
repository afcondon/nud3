Notes

let matrix = [ [1,2,3], [4,5,6], [7,8,9] ]

d3.select("body")    -- { _groups: [[<body>]]
                     -- , _parents: [<html>] }

  .append("table")   -- { _groups: [[<table>]]
                     -- , _parents: [<html>] }

  .selectAll("tr")   -- { _groups: [ NodeList[] ]
                     -- , _parents: [<table>] }

  .data(matrix)      -- { _enter: [[ EnterNode, EnterNode, EnterNode ]]
                     -- , _exit: [[]]
                     -- , _groups: [[]] -- this is the update selection
                     -- , _parents: [<table>] }

  .join("tr")        -- { _groups: [[<tr>, <tr>, <tr>]]
                     -- , _parents: [<table>] }

  .selectAll("td")   -- { _groups: [ NodeList [], NodeList [], NodeList [] ]
                     -- , _parents: [<tr>,<tr>,<tr>] }

  .data(d=>d)        -- { _enter: [ [ EnterNode, EnterNode, EnterNode ]
                     --           , [ EnterNode, EnterNode, EnterNode ]
                     --           , [ EnterNode, EnterNode, EnterNode ] ]
                     -- , _exit: [[],[],[]]
                     -- , _groups: [[],[],[]]
                     -- , _parents: [<table>] }
  .join("td")        -- { groups [ [<td>,<td>,<td>]
                     --          , [<td>,<td>,<td>]
                     --          , [<td>,<td>,<td>] ]
                     -- , parents: [<tr>,<tr>,<tr>] }