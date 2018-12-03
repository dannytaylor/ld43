-- inputs.lua


-- input keyboard stuff
function input_helper(scene)

	local moving = {0,0}	
	if OVERLAY == 0 then
		if win:key_released"escape" then	
			win:close()
		end

		if win:key_down"up" or win:key_down"w" then
			moving[2] = 1
		elseif win:key_down"down" or win:key_down"s"  then
			moving[2] = -1
		end

		if win:key_down"right" or win:key_down"d" then
			moving[1] = 1
		elseif win:key_down"left" or win:key_down"a" then
			moving[1] = -1
		end





		if win:key_released"space" and ACTIVENODE ~= 0 then	
			if  nodes[ACTIVENODE].e == 'end' then
				player.x,player.y = 0,0
				cam.x,cam.y = 0,0
				for i=1,#critters do
					critters[i].x = 3*critters[i].ox
					critters[i].y = -critters[i].oy
				end
				
				ACTIVENODE = 0
				nodes = mapGen(WIDTH*2,HEIGHT*2,16,WIDTH/6,WIDTH/3)
				local newmapgroup = mapDraw()
				scene:replace("map",newmapgroup:tag"map")
				scene:replace("decals",am.group():tag"decals")
				scene:update()
			elseif nodes[ACTIVENODE].e == 'spawncritter' then
				nodes[ACTIVENODE].e = 'empty'
				ACTIVENODE = 0
				SPEECH = 0
				scene:remove("yesimg")
				scene:remove("noimg")
				if player.dir~=1 then
					spawncritter()
					local cn = #critters
					critter_fg:append(am.translate(vec2(critters[cn].x,critters[cn].y)):tag("critter_"..cn)^am.scale(CRITTERSCALE)^am.sprite(critters[cn].a[1][1]):tag("crittera_"..cn))
				end
			elseif nodes[ACTIVENODE].e == 'killcritter' then
				nodes[ACTIVENODE].e = 'empty'
				ACTIVENODE = 0
				SPEECH = 0
				scene:remove("yesimg")
				scene:remove("noimg")		
				if player.dir~=1 then		
					critter_bg:remove("critter_"..#critters)
					critter_fg:remove("critter_"..#critters)
					killcritter()
				end
			end
		end




		
		cam.x = cam.x+tween(cam.x,player.x,22,1)
		cam.y = cam.y+tween(cam.y,player.y,22,1)
		scene"camt".position2d = vec2(-cam.x,-cam.y)
	end
	player_move(scene,moving)
	critter_move(scene)


	if OVERLAY == 1 then
		if win:key_released"escape" or win:key_released"space" then	
			scene"textoverlay".text = ""
			OVERLAY = 0
		end
	end

	if win:mouse_released('left') then
		log(win:mouse_pixel_position())
	end

end


function eventcheck(p)
	if player.x > (p.p.x-p.s/2) and player.x < (p.p.x+p.s/2) and player.y > (p.p.y-p.s/2) and player.y < (p.p.y+p.s/2) then
		return true
	end
	return false
end

function update_helper(scene)
	if OVERLAY == 0 then
		scene"textoverlay".text = ""
		ACTIVENODE = 0
		for i,n in ipairs(nodes) do
			if eventcheck(n) then 
				scene"textoverlay".text = nodes[i].e
				ACTIVENODE = i
				if (nodes[ACTIVENODE].e=='killcritter' or nodes[ACTIVENODE].e=='spawncritter') and SPEECH == 0 then 
					SPEECH = 1
					scene"yesscale":append(am.sprite(sprites.yes):tag"yesimg")
					scene"noscale":append(am.sprite(sprites.no):tag"noimg")
					if player.dir == 1 then scene"noscale".scale2d = vec2(0.5)
					else scene"yesscale".scale2d = vec2(0.5) end
				end
			end
		end
	end


end

function spawncritter()
	table.insert(critters,{
		x=player.x,
		y=player.y-1,
		vx=0,vy=0,
		ox=math.random(-50,50),
		oy=math.random(10,50),
		vmax=math.random(50,70)/10,
		fg=1,
		anim=1,
	    a={
	    	[1]={[1]=sprites.c_i1,[2]=sprites.c_i2,rate=0.25,num=2,frame=1,count=math.random(25)/100},
	    	[2]={[1]=sprites.c_w1,[2]=sprites.c_w2,rate=0.2 ,num=2,frame=1,count=math.random(20)/100}
	    }
	
	})
end

function killcritter()
	table.remove(critters,#critters)
end

function anim_helper(scene)
	local ct = am.current_time()
	local pc = player.a[player.anim].count
	local diff = ct-pc
	if diff > player.a[player.anim].rate then
		player.a[player.anim].count = ct
		local f = math.abs(player.a[player.anim].frame-player.a[player.anim].num-1)
		player.a[player.anim].frame = f
		scene"playerimg".source = player.a[player.anim][f]
	end
	for i,critter in ipairs(critters) do
		local pc = critter.a[critter.anim].count
		diff = ct-pc
		if diff > critter.a[critter.anim].rate then
			critter.a[critter.anim].count = ct
			local f = math.abs(critter.a[critter.anim].frame-critter.a[critter.anim].num-1)
			critter.a[critter.anim].frame = f
			scene("crittera_"..i).source = critter.a[critter.anim][f]
		end
	end
end
