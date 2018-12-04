-- init.lua

-- globals
WIDTH = 960
HEIGHT = 720
GRID_SIZE = WIDTH/10
SCENE = 0 
NUMCRITTERS = 3
FLOOR = -3
OVERLAY = 1
ACTIVENODE = nil
BLACK = vec4(0.09,0.06,0.06,1)
WHITE = vec4(1,1,1,1)
SPEECH = 0
CRITTERSCALE = 0.3
GAMESTATE = 'menu'


wipestart=-1
wipedur=0.5


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
	clear_color = BLACK,
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

-- sfx and music
sssfx = am.load_audio("sfx/ss.ogg")
cavesfx = am.load_audio("sfx/cavesfx.ogg")
yessfx = am.load_audio("sfx/yes.ogg")
nosfx = am.load_audio("sfx/no.ogg")
music = am.load_audio("sfx/music.ogg")
whip = am.load_audio("sfx/whip.ogg")
chomp = am.load_audio("sfx/chomp.ogg")
yay = am.load_audio("sfx/yay.ogg")