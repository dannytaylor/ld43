-- mst.lua
-- https://github.com/DarthEvandar/lua_minimum_spanning_tree
local mst = {}
function mst.tree(points,edges)
  vertices = {points[1]}
  tree = {}
  while #vertices ~= #points do
    ln = 10000
    temp1 = nil
    temp2 = nil
    for i = 1, #vertices do
      for p = 1, #points do
        if doesexist(vertices,points[p])==false then
            if dist(points[p][1],points[p][2],vertices[i][1],vertices[i][2])<ln and same(points[p][1],points[p][2],vertices[i][1],vertices[i][2],edges) then
              ln = dist(points[p][1],points[p][2],vertices[i][1],vertices[i][2])
              temp1 = points[p]
              temp2 = vertices[i]
            end
          end
        end
      end
      table.insert(vertices,temp1)
      table.insert(tree,{temp1[1],temp1[2],temp2[1],temp2[2]})
    end
    return tree
end

function dist(x1,y1,x2,y2)
  return math.sqrt(math.pow(math.abs(x2-x1),2)+math.pow(math.abs(y2-y1),2))
end

function same(x1,y1,x2,y2,edg)
  for i = 1,#edg do
    if (x1==edg[i][1] and y1 == edg[i][2] and x2 == edg[i][3] and y2 == edg[i][4]) or (x2 == edg[i][1] and y2 == edg[i][2] and x1 == edg[i][3] and y1 == edg[i][4]) then
      return true
    end
  end
  return false
end

function doesexist(v,p)
  for i=1,#v do
    if p[1] == v[i][1] and p[2] == v[i][2] then return true end
  end
  return false
end

return mst