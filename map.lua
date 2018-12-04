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
			if (N[i].s*1.3+N[j].s*1.3)>l then N[j].s = 0 end
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
		N[i].e = 'event'
		N[i].d = math.random(#dialog)
		N[i].dd = math.random(3)
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
options = {'event'}
options1 = {
	["killcritter"]="there's an object wedged between rocks\nsend a critter to grab it?",
	["spawncritter"]="a critter is scurrying towards you\nsay hi?",
	["end"]="climb upwards\n(space)"}
options2 = {
	["killcritter"]="you can't see, but you hear a loud crunch\nthe critter doesn't come back",
	["spawncritter"]="it seems happy to see you\nit joins you"}


dialog = {
	[1]={
		q="you see an object wedged between some narrow rocks\nsend a critter to grab it?",
		a={
			[1]="it was another critter!\nit joins your group",
			[2]="you can't see, but you hear a loud crunch\nthe critter doesn't come back",
			[3]="it was just a rock...\n",
			[4]="probably not worth anything\n"
		}
	},
	[2]={
		q="a critter is scurrying towards you\nsay hi?",
		a={
			[1]="it seems happy to see you\nit joins you",
			[2]="it looks rabid!\n it takes out one the the crew before\nyou can stop it",
			[3]="it seems indifferent to you\nand keeps moving",
			[4]="you keep moving to avoid trouble"
		}
	},
	[3]={
		q="you hear something large coming down the tunnel\n wait for whatever it is?",
		a={
			[1]="it's a fat critter\nit smells your snacks and joins you",
			[2]="it's a tunnel rat!\nit grabs a critter while you try to run",
			[3]="it's a loose boulder!\nyou step out of the way just in time",
			[4]="you don't wait to find out what's in these caves"
		}
	},
	[4]={
		q="you hear something large coming down the tunnel\n wait for whatever it is?",
		a={
			[1]="it's a fat critter\nit smells your snacks and joins you",
			[2]="it's a tunnel rat!\nit grabs a critter while you try to run",
			[3]="it's a loose boulder!\nit crushes one of your friends :(",
			[4]="it's a loose boulder!\nit crushes one of your friends :("
		}
	}

}

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
		-- if math.random(100) > 90 then table.append(randedges,{{triangle.p1.x,triangle.p1.y,triangle.p2.x,triangle.p2.y}}) end
		-- if math.random(100) > 90 then table.append(randedges,{{triangle.p1.x,triangle.p1.y,triangle.p3.x,triangle.p3.y}}) end
		-- if math.random(100) > 90 then table.append(randedges,{{triangle.p2.x,triangle.p2.y,triangle.p3.x,triangle.p3.y}}) end
	end
	local tree = mst.tree(points2,edges)

	local group = am.group()

	linewidth = 128
	linecolor = vec4(0.7,0.7,0.78,1)
	for i = 1, #tree do
		group:append(am.line(vec2(tree[i][1],tree[i][2]),vec2(tree[i][3],tree[i][4]),linewidth,linecolor))
	end
	for i = 1, #randedges do
		group:append(am.line(vec2(randedges[i][1],randedges[i][2]),vec2(randedges[i][3],randedges[i][4]),linewidth,linecolor))
	end
	local nodecolor = vec4(1,1,1,1)
	for i = 1,#nodes do
		if nodes[i].e == 'end' then 
			nodecolor = vec4(1,0.96,0.87,1) 
		else 
			nodecolor = vec4(1,1,1,1) 
		end
		group:append(am.circle(nodes[i].p,nodes[i].s,nodecolor))
	end
	return group
end