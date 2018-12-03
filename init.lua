-- init.lua

-- globals
WIDTH = 960
HEIGHT = 720
GRID_SIZE = WIDTH/10
SCENE = 0 
NUMCRITTERS = 5
FLOOR = 1
OVERLAY = 1
ACTIVENODE = nil
BLACK = vec4(0.12,0.10,0.09,1)
SPEECH = 0
CRITTERSCALE = 0.3

-- 0 main menu, 1 overworld, 2 event, 3 cutscene?


-- obj
cam = {x=0,y=0}
player = {
	x=0,y=0,vx=0,vy=0,vmax=5,dir=1,
	anim=1,
}


-- init window
win = am.window{
	title = 'ld43', -- rename window
	width = WIDTH,
	height = HEIGHT,
	clear_color = black,
	msaa_samples = 4
}


-- init critters
critters = {}
for i = 1,NUMCRITTERS,1 do
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
end

