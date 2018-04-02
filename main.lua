--	A star twinkled, and then I existed.

function love.load()
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))	-- OSX randomseed
	for i=1, 4 do math.random() end	-- For good measure

	love.graphics.setDefaultFilter("nearest","nearest")
		-- love.graphics.setPointStyle("rough")
    love.graphics.setLineStyle("rough")
   	love.graphics.setPointSize(1)
	love.graphics.setLineWidth(1)
	love.graphics.setLineJoin( 'bevel' )

	love.mouse.setVisible(false)
	-- love.mouse.setGrabbed(true)

	TOGGLEBIG = true
	-- IRESX = 568 -- 5
	IRESX = 640
	IRESY = 360	--	4
	WIDTH = IRESX
	HEIGHT = IRESY
	CENTERX = WIDTH/2
	CENTERY = HEIGHT/2

	if love.graphics.getHeight() == IRESY and love.graphics.getWidth() == IRESX then
		ISCALE = 1
	else
		if love.graphics.getWidth()/IRESX >= love.graphics.getHeight()/IRESY then
			ISCALE = love.graphics.getHeight()/IRESY
		else
			ISCALE = love.graphics.getHeight()/IRESX
		end
	end
	HASFOCUS = true

	-- 	External Files
							require 'lib.middleclass'
	Stateful = 	require 'lib.stateful.stateful'
	hs2 = 			require 'lib.hs2.hs2'
	tween =			require 'lib.tween.tween'
							require 'lib.ellipse.ellipse'
	common = 		require 'lib.common.common'

	love.filesystem.setIdentity("OurForgottenAlphabetBeta")
	hs = hs2.load("highscores.txt", 1, "a", 0)

	require 'obj.gamestate'  	-- Go go gadget gamestate

	scaleCanvas = love.graphics.newCanvas(IRESX,IRESY)
	colors = 		{
					background = {13,44,64},
					white = {255,255,255,255},
					cluster = {230,230,254},
					blue = {182,184,195},
					blue2 = {136,142,179},
					highlight = {255,152,35},
					alt = {100,212,255}
					}
	fonts = 		{
					title2 = love.graphics.newFont("res/hyperspace.ttf",64),
					subtitle = love.graphics.newFont("res/FreePixel.ttf",14.8),
					debug = love.graphics.newFont("res/visitor1.ttf",15),
					clock = love.graphics.newFont("res/FreePixel.ttf",15),
					score = love.graphics.newFont("res/FreePixel.ttf",30)
					}
	graphics =		{
					arrow = love.graphics.newImage("res/arrow2.png")
					}
	audio =			{
					OFU = love.audio.newSource("res/OFU.ogg","stream")
					}
-- if "static" is omitted, LÖVE will stream the file from disk --.mp3 playback buggy, .ogg recommended
	--[[
	colors = 		{		-- Alternate colors.
					background = {0,0,38},
					blue = {64,64,92},
					white = {255,255,255},
					cluster = {230,230,254},
					highlight = {255,0,0},
					alt = {100,212,255}
					}
	--]]

	love.audio.setVolume( 1 )
	audio["OFU"]:setVolume(0.75) -- 50% of ordinary volume
	audio["OFU"]:setLooping( true )

	stateCarrier = 	{}

	-- require 'lua.title'
	-- require 'lua.game'
	-- require 'lua.draw'
	require 'lua.comettest'
	require 'lua.particletest'
	require 'lua.newdraw'
	require 'lua.clustertest'

	gamestate = Gamestate:new()
	gamestate:gotoState('ClusterTest')

	lg = love.graphics
end

function love.update(dt)
	if HASFOCUS then		-- pause when the game loses focus
		tween.update(dt)
		gamestate:update(dt)
	end
end

function love.draw()
	love.graphics.setCanvas(scaleCanvas)
	-- love.graphics.clear(0,0,0)
		lg.clear(unpack(colors["background"]))

		gamestate:draw()

	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(0,0,0)

	love.graphics.draw(scaleCanvas,love.graphics.getWidth()/2,love.graphics.getHeight()/2,0,ISCALE,ISCALE,IRESX/2,IRESY/2)
end

function love.resize( w, h )
	local w = w
	local h = h
	if w/IRESX >= h/IRESY then
		ISCALE = h/IRESY
	else
		ISCALE = w/IRESX
	end
	WIDTH = IRESX
	HEIGHT = IRESY
	CENTERX = WIDTH/2
	CENTERY = HEIGHT/2
	--gamestate:resize(w,h)
end

function love.focus(f)
	HASFOCUS = f
end

function love.joystickpressed(joystick, button)
	gamestate:joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	gamestate:joystickreleased(joystick, button)
end

function love.keypressed(key, unicode)
	if key == "f" then
		local fullscreen = not love.window.getFullscreen()
		if fullscreen then
			local width, height = love.window.getDesktopDimensions( display )
			love.window.setMode( width, height,{fullscreen=true})
			love.resize( width, height )
		else
			local w,h
			if TOGGLEBIG then
				w = 1136
				h = 640
			else
				w = IRESX
				h = IRESY
				WIDTH = IRESX
				HEIGHT = IRESY
				CENTERX = WIDTH/2
				CENTERY = HEIGHT/2
			end
			love.window.setMode( w, h,{fullscreen=false})
			love.resize( w, h )
		end
	elseif key == 'a' then
		TOGGLEBIG = not TOGGLEBIG
		local w
		local h
		if TOGGLEBIG then
			w = 1136
			h = 640
		else
			w = IRESX
			h = IRESY
			WIDTH = IRESX
			HEIGHT = IRESY
			CENTERX = WIDTH/2
			CENTERY = HEIGHT/2
		end
		love.window.setMode( w, h)
		love.resize( w, h )
	elseif key == "s" then
		local s = love.graphics.newScreenshot()
		s:encode("OurForgottenAlphabet"..os.time()..".png")
	elseif key == 'escape' then
		hs:save()								-- Save the highscores! Then,
		love.event.push('quit')
	end
	gamestate:keypressed(key, unicode)
end

function love.keyreleased(key)
	gamestate:keyreleased(key)
end

function love.touchpressed()
	gamestate:keypressed()
end

function love.touchreleased()
	gamestate:keyreleased()
end

function love.mousepressed(x, y, button)
	gamestate:keyreleased(key)
end

function love.mousereleased(x, y, button)
	gamestate:keypressed()
end

function love.quit()
	gamestate:quit()
end
