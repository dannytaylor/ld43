-- ss.lua
-- slideshow

ssnum = 22
sscount = 0
ssrate  = 0.5
ssrun = 0
ssframe = 1

function ss_helper(scene)
	local diff = am.current_time() - sscount
	if win:key_released"space" then
		GAMESTATE = 'game'
		scene:remove("ssimg")
		ssrun = 1
		scene:cancel('sssfx')
		scene:action('music',am.play(music,true,1,0.5))
		cavesfxid = scene:action('cavesfx',am.play(cavesfx,true,1.0,0.08))
	elseif diff > ssrate then
		sscount = am.current_time()
		ssframe = ssframe + 1
		if ssframe == 22 then sscount = am.current_time() + 1 end
		if ssframe > ssnum then
			GAMESTATE = 'game'
			scene:remove("ssimg")
			ssrun = 1

			scene:action('cavesfx',am.play(cavesfx,true,1.0,0.08))
			scene:action('music',am.play(music,true,1,0.5))
		else
			scene"ssimg".source = "img/ss/ss"..ssframe..".png"
		end
	end
end
