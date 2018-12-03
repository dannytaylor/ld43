-- map.lua

function mapGen(w,h,n,min,max)

	math.randomseed(os.time())
	local N={}
	local E={}
	N[1] = {p=vec2(0,0),s=math.random(min,max),e='start'}
	for i=2,n do
		N[i] = {p=vec2(max+math.random(w),max+math.random(h)),s=math.random(min,max),e=nil}
	end

	-- if too close de-size second
	for i=2,n do
		for j=i+1,n do
			local l = math.distance(N[i].p,N[j].p)
			if (N[i].s*1.1+N[j].s*1.1)>l then N[j].s = 0 end
		end
	end


	local nn=n
	-- remove desized
	for i=n,2,-1 do
		if N[i].s == 0 then	
			table.remove(N,i)
			nn = nn - 1 
		end
	end
	n = nn

	local maxx = 0
	local maxy = 0
	local maxi = 2
	for i=2,#N do
		N[i].e = chooseevent()
		if N[i].p.x > maxx or N[i].p.y > maxy then
			maxx = N[i].p.x
			maxy = N[i].p.y
			maxi = i
		end 
	end

	N[maxi].e = 'end'

	return N
end

-- local options = {'fight','empty','spawncritter', 'killcritter'}
local options = {'killcritter','spawncritter'}
function chooseevent()
	return options[math.random(#options)]
end

function mapDraw()

	math.randomseed(os.time())
	
	local points = {}
	local points2 = {}
	for i = 1, #nodes do
	  points[i] = Point(nodes[i].p.x, nodes[i].p.y)
	  points2[i] = {nodes[i].p.x, nodes[i].p.y}
	end
	-- Triangulating de convex polygon made by those points
	local triangles = Delaunay.triangulate(unpack(points))


	local edges = {}
	local randedges = {}
	local j = 1
	for i, triangle in ipairs(triangles) do
		edges[j] = {triangle.p1.x,triangle.p1.y,triangle.p2.x,triangle.p2.y}
		edges[j+1] = {triangle.p1.x,triangle.p1.y,triangle.p3.x,triangle.p3.y}
		edges[j+2] = {triangle.p2.x,triangle.p2.y,triangle.p3.x,triangle.p3.y}
		j=j+3
		if math.random(100) > 90 then table.append(randedges,{{triangle.p1.x,triangle.p1.y,triangle.p2.x,triangle.p2.y}}) end
		if math.random(100) > 90 then table.append(randedges,{{triangle.p1.x,triangle.p1.y,triangle.p3.x,triangle.p3.y}}) end
		if math.random(100) > 90 then table.append(randedges,{{triangle.p2.x,triangle.p2.y,triangle.p3.x,triangle.p3.y}}) end
	end
	local tree = mst.tree(points2,edges)

	local group = am.group()

	linewidth = 128
	linecolor = vec4(0.6,0.6,0.7,1)
	for i = 1, #tree do
		group:append(am.line(vec2(tree[i][1],tree[i][2]),vec2(tree[i][3],tree[i][4]),linewidth,linecolor))
	end
	for i = 1, #randedges do
		group:append(am.line(vec2(randedges[i][1],randedges[i][2]),vec2(randedges[i][3],randedges[i][4]),linewidth,linecolor))
	end
	local nodecolor = vec4(1,1,1,1)
	for i = 1,#nodes do
		if nodes[i].e == 'end' then 
			nodecolor = vec4(1,0.5,0.5,1) 
		else 
			nodecolor = vec4(1,1,1,1) 
		end
		group:append(am.circle(nodes[i].p,nodes[i].s,nodecolor))
	end
	return group
end