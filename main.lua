--main.lua
sprites = require 'sprites'

require 'init'
require 'inputs'
require 'map'
require 'ss'

Delaunay = require 'delaunay'
Point    = Delaunay.Point
mst = require 'mst'


nodes = mapGen(WIDTH*2,HEIGHT*2,16,WIDTH/6,WIDTH/3)
-- nodes = mapGen(WIDTH,HEIGHT,16,WIDTH/24,WIDTH/8)
-- nodes = mapGen(WIDTH,HEIGHT,16,5,10)

-- ANIMATIONS
player.a={}
player.a[1]={[1]=sprites.p_i1,[2]=sprites.p_i2,rate=0.3,num=2,frame=1,count=0}
player.a[2]={[1]=sprites.p_w1,[2]=sprites.p_w2,[3]=sprites.p_w3,[4]=sprites.p_w4,rate=0.3,num=4,frame=1,count=0}

critter_fg = am.group()
critter_bg = am.group()
for i = 1,NUMCRITTERS,1 do
	critters[i].a = {}
	critters[i].a[1]={[1]=sprites.c_i1,[2]=sprites.c_i2,rate=0.25,num=2,frame=1,count=math.random(25)/100}
	critters[i].a[2]={[1]=sprites.c_w1,[2]=sprites.c_w2,rate=0.15 ,num=2,frame=1,count=math.random(20)/100}
	critter_fg:append(am.translate(vec2(critters[i].x,critters[i].y)):tag("critter_"..i)^am.scale(CRITTERSCALE)^am.sprite(critters[i].a[1][1]):tag("crittera_"..i))
end

map_group = mapDraw()

-- MAIN
win.scene = am.group{
	am.translate(cam.x,cam.y):tag"camt"
	^{
		am.group{
			map_group:tag"map",
			am.circle(vec2(0,0),0,WHITE):tag"wipe2",
			am.circle(vec2(0,0),0,BLACK):tag"wipe",
			am.translate(0,0):tag"decals",
			critter_bg:tag"crbg",

			am.translate(player.x,player.y):tag"playert"
			^ am.scale(0.5,0.5):tag"playerdir"
			^ am.sprite(player.a[1][1]):tag"playerimg",
			
			critter_fg:tag"crfg",

			am.group{
				am.translate(player.x,player.y):tag"yest"
				^am.translate(-110,130)
				^ am.scale(.4,.4):tag"yesscale",
				-- ^ am.sprite(sprites.yes):tag"yesimg",
				am.translate(player.x,player.y):tag"not"
				^ am.translate(110,130)
				^ am.scale(.4,.4):tag"noscale",
				-- ^ am.sprite(sprites.no):tag"noimg",
			}
		}:tag"base",
	},

	am.translate(0,HEIGHT/3)
	^ am.scale(2)
	^ am.text("hey I didn't add wall collisions so stay\n on the paths, honour system :)\n \n (space to close)",vec4(1,0.5,0.5,1)):tag"textoverlay",
	
	am.group{
		am.translate(0,-HEIGHT/2):tag"ui"
		^ am.translate(0,80)
		^ am.scale(2)
		^ am.text("",BLACK):tag"uitext"
	},
	am.group():tag"ssgroup"^am.sprite("img/ss/mm.png"):tag"ssimg"
}
mapDraw(scene)

-- handle player movement
function player_move(scene,m)
	local v = 1
	if m[1] ~= 0 and m[2] ~= 0 then 
		v = 0.707
	elseif m[1] == 0 and m[2] == 0 then 
		v = 0
	end

	if player.dir ~= m[1] and m[1]~= 0 then
		scene"playerdir".x = -scene"playerdir".x
		player.dir = -player.dir
		if player.dir == 1 then 
			scene"yesscale".scale2d = vec2(0.4)
			scene"noscale".scale2d = vec2(0.55) 
		else 
			scene"noscale".scale2d = vec2(0.4) 
			scene"yesscale".scale2d = vec2(0.55)
		end
	end

	player.vx = player.vx+tween(player.vx,player.vmax*v*m[1],8,.001)
	player.vy = player.vy+tween(player.vy,player.vmax*v*m[2],8,.001)
	local tempx,tempy = player.x,player.y
	player.x = player.x + player.vx
	player.y = player.y + player.vy
	
	-- bind player to event box
	if ACTIVENODE and ACTIVENODE ~= 0 and nodes[ACTIVENODE].e == 'event' then
		if eventcheck(nodes[ACTIVENODE]) == false then
			-- log(ACTIVENODE)
			player.x,player.y = tempx,tempy
		end
	end

	local pt = vec2(player.x,player.y)
	scene"playert".position2d,scene"yest".position2d,scene"not".position2d= pt,pt,pt

	if math.abs(player.vx) > 1 or math.abs(player.vy) > 1 then
		if player.anim == 1 then
			player.anim = 2
			player.a[player.anim].count = am.current_time()
			player.a[player.anim].frame = 1
			scene"playerimg".source = player.a[player.anim][1]
		end
	elseif m[1] == 0 and m[2] == 0 and player.anim == 2 then
		-- player.f2 = player.f2 + am.delta_time
		-- if player.f2 > 0.4 then -- frame rate
		-- 	player.f2 = 0
		-- 	player.f1 = math.abs(player.f1-5)
		-- 	scene"playerimg".source = player.a[2][player.f1]
		-- end
		player.anim = 1
		player.a[player.anim].count = am.current_time() 
		scene"playerimg".source = player.a[player.anim][1]
	end


end

function critter_move(scene)
	for i=1,#critters,1 do
		local delta = {x=critters[i].x-player.x+critters[i].ox,y=critters[i].y-player.y+critters[i].oy}
		local hyp = math.sqrt(delta.x*delta.x+delta.y*delta.y)
		local v = {x=-delta.x/hyp,y=-delta.y/hyp}

		if math.abs(delta.x) > (50+critters[i].ox) then
			critters[i].vx = critters[i].vx+tween(critters[i].vx,critters[i].vmax*v.x,32,.001)
		else
			critters[i].vx = critters[i].vx+tween(critters[i].vx,0,32,.001)
		end
		if math.abs(delta.y) > (50+critters[i].oy) then
			critters[i].vy = critters[i].vy+tween(critters[i].vy,critters[i].vmax*v.y,32,.001)
		else
			critters[i].vy = critters[i].vy+tween(critters[i].vy,0,32,.001)
		end


		critters[i].x = critters[i].x + critters[i].vx
		critters[i].y = critters[i].y + critters[i].vy

		-- depth check
		if critters[i].y >= (player.y-60) and critters[i].fg == 1 then
			critters[i].fg = 0
			critter_fg:remove("critter_"..i)
			critter_bg:append(am.translate(vec2(critters[i].x,critters[i].y)):tag("critter_"..i)^am.scale(CRITTERSCALE)^am.sprite(critters[i].a[1][1]):tag("crittera_"..i))
		elseif critters[i].y < (player.y-60) and critters[i].fg == 0 then
			critters[i].fg = 1
			critter_bg:remove("critter_"..i)
			critter_fg:append(am.translate(vec2(critters[i].x,critters[i].y)):tag("critter_"..i)^am.scale(CRITTERSCALE)^am.sprite(critters[i].a[1][1]):tag("crittera_"..i))
		end
		
		-- anim run
		if math.abs(critters[i].vx) > 1.5 or math.abs(critters[i].vy) > 1.5 then
			if critters[i].anim == 1 then critters[i].a[2].frame = 1 end
			critters[i].anim = 2
			
		else
			if critters[i].anim == 2 then critters[i].a[1].frame = 1 end
			critters[i].anim = 1
		end

		scene("critter_"..i).position2d = vec2(critters[i].x,critters[i].y)

	end
end

-- simple tween
function tween(a,b,t,min)
	if math.abs(b-a) < min then
		return 0
	else
		return (b-a)/t
	end
end


win.scene:action(function(scene)
	if musicid == nil then
		musicid = 1
		scene:action('music',am.play(music,true,1,0.5))
	end
	if win:key_released"escape" then	
		win:close()
	end
	if GAMESTATE == 'game' then
		input_helper(scene)
		update_helper(scene)
		anim_helper(scene)
	elseif GAMESTATE == 'winlose' then
		while #critters > 0 do
			critter_bg:remove("critter_"..#critters)
			critter_fg:remove("critter_"..#critters)
			table.remove(critters,#critters)
		end
		if win:key_released"space" then	
			scene:cancel('cavesfx')
			scene:remove('uitext2')
			scene:remove('uirect2')
			-- scene:remove_all('crbg')
			-- scene:remove_all('crfg')

			GAMESTATE = 'menu'
			scene:action('music',am.play(music,true,1,0.5))
			scene"ssimg".source = "img/ss/mm.png"
		end
	elseif GAMESTATE == 'menu' then
		if win:key_released"space" then	
			if ssrun == 1 then
				GAMESTATE = 'game'
				-- scene:action(am.play('cavesfx',"sfx/cavesfx.ogg",true,1.0,0.08))
				remakemap(scene)
				scene:remove("ssimg")

			else 
				GAMESTATE = 'slideshow'
				scene"ssimg".source = "img/ss/ss1.png"
				scene:cancel('music')
				sssfxid = scene:action('sssfx',am.play(sssfx,false,1.0,1.0))
				sscount = am.current_time()
			end
		end	
	elseif GAMESTATE == 'slideshow' then 
		ss_helper(scene)
	end
end)	

function remakemap(scene)
	player.x,player.y = 0,0
	cam.x,cam.y = 0,0

	FLOOR = -3

	critters = {}
	for i = 1,NUMCRITTERS do
		critters[i] = {
			x=math.random(-100,100),
			y=math.random(-100,100),
			vx=0,vy=0,
			ox=math.random(-50,50),
			oy=math.random(10,50),
			vmax=math.random(50,70)/10,
			anim=1,
			fg=1
		}
		critters[i].a = {}
		critters[i].a[1]={[1]=sprites.c_i1,[2]=sprites.c_i2,rate=0.25,num=2,frame=1,count=math.random(25)/100}
		critters[i].a[2]={[1]=sprites.c_w1,[2]=sprites.c_w2,rate=0.15 ,num=2,frame=1,count=math.random(20)/100}
		critter_fg:append(am.translate(vec2(critters[i].x,critters[i].y)):tag("critter_"..i)^am.scale(CRITTERSCALE)^am.sprite(critters[i].a[1][1]):tag("crittera_"..i))

	end
	
	ACTIVENODE = 0
	nodes = mapGen(WIDTH*2,HEIGHT*2,16,WIDTH/6,WIDTH/3)
	local newmapgroup = mapDraw()
	scene:replace("map",newmapgroup:tag"map")
	scene"decals":remove_all()
	scene:update()
end
