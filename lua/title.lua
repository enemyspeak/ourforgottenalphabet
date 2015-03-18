
local Title = Gamestate:addState('Title')

local Particle = require 'obj.particle'
local Star = require 'obj.star'
local Comet = require 'obj.comet'
local Cluster = require 'obj.cluster'
local Constellation = require 'obj.constellation'

local vel = require 'lua.velocity'

local NEXTSTATE = 'Title'
local BUTTONSTATE = 'Game'

local WIDTH = IRESX
local HEIGHT = IRESY
local CENTERX = WIDTH/2
local CENTERY = HEIGHT/2

local MAXPARTICLES = 50
local MAXSTARS = 10

local starBufferX = 50
local starBufferY = 50

local particles = {}
local stars = {}

local constellations = {}
local clusters = {}

local comet

local gameScore
local bestScore = 0

local constellationFlicker 

local titleTween = {}
local titleTimer
local titleAlpha
local outFade = false
local inFade = false
local newRecord = false

local clusterNumber = 0

local function getObjectXY(kind)
	local kind = kind
	local safex = (IRESX/2 + kind.SAFEZONE)
	local safey = (IRESY/2 + kind.SAFEZONE)
	local x,y
	
	if math.random(1,2) == 1 then
		if vel.x < 0  then 						-- Star direction logic
			x = -safex
			y = math.random(-safey, safey)
		else
			x = safex
			y = math.random(-safey, safey)
		end
	else
		if vel.y < 0 then
			x = math.random(-safex, safex)
			y = safey
		else
			x = math.random(-safex, safex)
			y = -safey
		end
	end	
	return x,y
end

local function getParticleAttributes()
	local n = math.random(1,8)
	local temp
	if  n == 1 or  n == 2 then				-- Particle speed
		temp = 0.75
		temp2 = Particle.COLOR4
	elseif  n == 3 or  n == 4 then
		temp = 1.5	
		temp2 = Particle.COLOR1
	elseif  n == 5 or  n == 8 then
		temp = 0.5
		temp2 = Particle.COLOR5
	elseif  n == 6 then
		temp = 1.25
		temp2 = Particle.COLOR2
	else 
		temp = 1
		temp2 = Particle.COLOR3
	end
	return temp, temp2
end

local function getStarType()
	local n = math.random(1,6)
	local temp
	if n == 1 then
		temp = Star.STAR1
	elseif n == 2 then
		temp = Star.STAR2
	elseif n == 3 then
		temp = Star.STAR3
	elseif n == 4 then
		temp = Star.STAR4
	elseif n == 5 then
		temp = Star.STAR5
	elseif n == 6 then
		temp = Star.STAR6
	end
	return temp
end

local showClusters
showClusters = function()
	clusterNumber = clusterNumber - 1

	zoomInCluster = function()
		local radius = clusters[clusterNumber]:getRadius()
		tween(3, titleTween,{ drawScale = (HEIGHT+125)/(radius*2) }, "inOutQuad", clusterViewDelay)
	end

	clusterViewDelay = function()
		titleTween.clusterViewTimer = 0
		tween(8,titleTween, {clusterViewTimer = 1},"linear", zoomOutCluster)
	end

	zoomOutCluster = function()
		tween(3, titleTween,{drawScale = 0.55}, "inOutQuad", recursiveHolder)
	end

	recursiveHolder = function()
		showClusters()
	end

	if clusterNumber == 0 then 
		clusterNumber = #constellations -- Restart loop
	end

	local x,y = clusters[clusterNumber]:getPos()
	tween(8,titleTween,{ translateX = -x, translateY = -y }, "inOutExpo", zoomInCluster)
end

local function updateParticles(dt)
	for i,v in ipairs(particles) do
		particles[i]:update(dt)
		if particles[i]:getKill() == true then
			table.remove(particles,i)
		end
	end
	if #particles < MAXPARTICLES then
		local speed, color = getParticleAttributes()
		local x,y = getObjectXY(Particle)
		particles[#particles + 1] = Particle:new({x = x, y = y, speed = speed, color = color}) 
	end
end

function updateConstellations(dt)						-- Update constellations
	for i=1, #constellations do 
		for k, s in ipairs(constellations[i]) do			
			constellations[i][k]:update(dt)
		end
	end
end

local function updateStars(dt)
	for i,v in ipairs(stars) do
		stars[i]:update(dt)
		if stars[i]:getKill() == true then
			table.remove(stars,i)
		end
	end
	
	local interval = 50
	local rate = 2

	starBufferX = starBufferX + (math.abs(vel.x)/rate) * dt
	starBufferY = starBufferY + (math.abs(vel.y)/rate) * dt

	if starBufferX > interval then
		starBufferX = 0
		local x,y = getObjectXY(Star,'x')
		stars[#stars + 1] = Star:new({x = x, y = y, typ = getStarType()}) 
	end
	if starBufferY > interval then
		starBufferY = 0
		local x,y = getObjectXY(Star,'y')
		stars[#stars + 1] = Star:new({x = x, y = y, typ = getStarType()}) 
	end
end

local function updateFade(dt)
	if inFade and titleTimer > 3 then
		titleAlpha = titleAlpha - math.ceil(dt)*5
		if titleAlpha < 0 then
			titleAlpha = 0
			inFade = false
			showClusters()
		end
	end
	if outFade then
		titleAlpha = titleAlpha + math.ceil(dt)*30
		if titleAlpha > 255 then
			outFade = false
			titleAlpha = 255
			gamestate:gotoState(BUTTONSTATE)
		end
	end
end

local function drawClusters()
	if #clusters > 0 then
		clusters[#clusters]:draw(titleTween.drawScale)
	end
end

local function drawParticles()
	for i,v in ipairs(particles) do
		--if particles[i]:isOnScreen() then
			particles[i]:draw()
		--end
	end
end

local function drawStars()
	for i,v in ipairs(stars) do
		--if stars[i]:isOnScreen() then -- this doesn't work because the camera isn't moving
--[[
		local xpos,ypos = stars[i]:getPos()	
		local x = titleTween.translateX*titleTween.drawScale
		local y = titleTween.translateY*titleTween.drawScale
		if ( x+CENTERX  > xpos) and ( x-CENTERX  < xpos) and  ( y+CENTERY > ypos) and ( y-CENTERY < ypos) then
			]]
			stars[i]:draw(nil,titleTween.drawScale)
		
		--end

	end
end

local function drawTitle()
	love.graphics.setColor(unpack(colors["white"]))	
	love.graphics.setFont(fonts["title2"])
	local top = -102
	local offset = 55
	love.graphics.printf("OUR", -CENTERX, top, WIDTH, "center" )
	love.graphics.printf("FORGOTTEN", -CENTERX, top + offset, WIDTH, "center" )	

	local fwidth = fonts["title2"]:getWidth( "_ALPHABET" )
	local dwidth = fonts["title2"]:getWidth( "_" )
	love.graphics.print("ALPHABET", -fwidth/2+dwidth, top + offset*2,0,1,1 )
end

local function drawConstellations()
	if stateCarrier["gameover"] then
	--	constellationFlicker = not constellationFlicker
	--	if constellationFlicker then
			local scale = titleTween.drawScale
			for i,v in ipairs(constellations) do
				local lastX = false
				local lastY = false
				for j,k in ipairs(constellations[i]) do	
					love.graphics.setInvertedStencil(constellationStencil)
					local sx,sy = constellations[i][j]:getPos()
					if lastX == false and lastY == false then else 	
						love.graphics.setColor(unpack(colors["blue2"]))	
						love.graphics.setLineWidth(1)
						love.graphics.line(math.floor(lastX)*scale,math.floor(lastY)*scale,math.floor(sx)*scale,math.floor(sy)*scale)
					end
					lastX = sx
					lastY = sy
					love.graphics.setInvertedStencil()	
				end
			end
	--	end
	end
end

local function drawBestscore()
	love.graphics.setFont(fonts["subtitle"])

	if newRecord then
		love.graphics.setColor(unpack(colors["highlight"]))	
		love.graphics.printf("NEW RECORD", -CENTERX, 90, WIDTH, "center" )
	end
	love.graphics.setColor(unpack(colors["blue"]))	
	love.graphics.printf("BEST SCORE: ".. bestScore, -CENTERX, 110, WIDTH, "center" )
end

local function drawCredits()
	--	credit
	love.graphics.setColor(unpack(colors["highlight"]))	
	love.graphics.printf("INSPIRED BY STEPH THIRION", -CENTERX, -120, WIDTH, "center" )	-- www.playfaraway.com
end

local function drawComet()
	if stateCarrier["gameover"] then
		comet:draw()
	end
end

local function drawHud( )
	love.graphics.setFont(fonts["clock"])
	local gameScore = stateCarrier.gameScore or 0
	if gameScore < 10 then
		digits = "0000"
	elseif gameScore < 100 then
		digits = "000"	
	elseif gameScore < 1000 then	
		digits = "00"	
	elseif gameScore < 10000 then	
		digits = "0"
	else 		
		digits = ""
	end
	
	love.graphics.setColor(unpack(colors["background"]))		
	love.graphics.rectangle("fill",WIDTH - 50,8,40,12)
	love.graphics.setColor(unpack(colors["white"]))	
	love.graphics.setFont(fonts["clock"])	
	love.graphics.print(digits..gameScore, WIDTH - 50, 5)
end

local function drawFade()			-- Tweens screen flash using a fade value, updated each frame
	if inFade and titleTimer > 3 then
		love.graphics.setColor( 255, 255, 255, titleAlpha )
		love.graphics.polygon( "fill", -CENTERX, -CENTERY, CENTERX, -CENTERY, CENTERX, CENTERY, -CENTERX, CENTERY)
	end
	if outFade then
		love.graphics.setColor( 255, 255, 255, titleAlpha )
		love.graphics.polygon( "fill", -CENTERX, -CENTERY, CENTERX, -CENTERY, CENTERX, CENTERY, -CENTERX, CENTERY)
	end
end

------------------------------------------------------------------------------------------









function Title:enteredState()	
	if stateCarrier["gameover"] then
		stars = stateCarrier["stars"]
		constellations = stateCarrier["constellations"]
		clusters = stateCarrier["clusters"]
		comet = stateCarrier["comet"]
		gameScore = stateCarrier["gameScore"]

		vel.x = 0
		vel.y = 0

		local temp = {}
		for i,v in ipairs(stars) do
			if stars[i]:getConstellation() then else
				table.insert(temp,stars[i])
			end
		end 		
	
		local mapX = 0
		local mapY = 0
		local lowX = 0
		local lowY = 0
		for i=1, #clusters - 1 do
			local x,y = clusters[i]:getPos()
			if x > mapX then
				mapX = x
			end
			if y > mapY then
				mapY = y
			end
			if x < lowX then
				lowX = x
			end
			if y < lowY then
				lowY = y
			end
		end
		---[[
		mapX = mapX + 1000
		mapY = mapY + 1000
		lowX = lowX - 1000
		lowY = lowY - 1000
		--]]

		local temp2 = math.abs(mapX + mapY) + math.abs(lowX + lowY)
		for i = 0, temp2/30 do
			local x 
			local y 
			local n = true

			while n do
				n = false
				x = math.random(lowX,mapX)
				y = math.random(lowY,mapY)
				for i,v in ipairs(clusters) do 
					local t = clusters[i]:getFastState(x,y)
					if ( CENTERX + WIDTH > x) and ( CENTERX - WIDTH < x) and  ( CENTERY + HEIGHT > y) and ( CENTERY - HEIGHT < y) then
						t = true
					end
					if t == true then
						n = true
					end
				end
				if x < CENTERX+4 and x > CENTERX-4 then
					if y < CENTERY+4 and y > CENTERY-4 then
						n = true
					end
				end
			end

			table.insert(temp, Star:new({ x = x, y = y, typ = getStarType()})) 
		end
		for i,v in ipairs(constellations) do
			for j,k in ipairs(constellations[i]) do
				local x,y = constellations[i][j]:getPos()
 				table.insert(temp, Star:new({ x = x, y = y, typ = getStarType()})) 
 			end
		end

		stars = temp

		for i = 0, temp2/20 do
			local speed, color = getParticleAttributes()
			local x = math.random(lowX,mapX)
			local y = math.random(lowY,mapY)
			table.insert(particles, Particle:new({ x = x, y = y, speed = 1, color = color}))
		end


		titleTween = 	{
						translateX = 0,
						translateY = 0,
						drawScale = 1,
						buttonDelay = 0,
						clusterViewTimer = 0
						}

		tween(4,titleTween,{drawScale = 0.5,buttonDelay = 1},"outCubic")
		
		inFade = true
		outFade = false
		titleAlpha = 255
		clusterNumber = #constellations

		constellationStencil = function()
			for i,v in ipairs(constellations) do
				for j,k in ipairs(constellations[i]) do
					local x,y = constellations[i][j]:getPos()
					love.graphics.circle("fill",x*titleTween.drawScale,y*titleTween.drawScale,10*titleTween.drawScale)
				end
			end	
		end
	else

		titleTween = 	{
						translateX = 0,
						translateY = 0,
						drawScale = 1,
						buttonDelay = 1,
						clusterViewTimer = 0
						}

		vel.x = common:getRandomSigned(100,200)
		vel.y = common:getRandomSigned(100,200)

		for i = 1, MAXPARTICLES/2 do
			local speed, color = getParticleAttributes()
			particles[i] =  Particle:new({ x = math.random(-CENTERX,CENTERX), y = math.random(-CENTERY,CENTERY), speed = speed, color = color}) 
		end
		for i = 1, MAXSTARS do
			stars[i] =  Star:new({ x = math.random(-(CENTERX+Star.SAFEZONE),(CENTERX+Star.SAFEZONE)), y = math.random(-CENTERY,CENTERY), typ = getStarType()}) 
		end
		outFade = false
		constellationFlicker = false
		titleAlpha = 0
	end

	titleTimer = 0

	newRecord = false
	local x, y = hs:get(1)				-- Get the top entry from the highscore table, with best_name a dummy variable to fill that argument
	if bestScore ~= y and stateCarrier.gameScore ~= nil then
		newRecord = true	
	end
	bestScore = y
end

function Title:exitedState()
	newRecord = false
	stateCarrier["gameover"] = false
	tween.stopAll() --stops all animations, without resetting any values
end

function Title:update(dt)
	tween.update(dt)
	titleTimer = titleTimer + dt
	
	if stateCarrier["gameover"] then else
		updateParticles(dt)
		updateStars(dt)
	end
	updateConstellations(dt)
	updateFade(dt)
end

function Title:draw()
	love.graphics.setBackgroundColor(unpack(colors.background))
	love.graphics.push()
		love.graphics.setColor(unpack(colors.background))
		love.graphics.rectangle("fill",0,0,WIDTH,HEIGHT)
	love.graphics.translate(CENTERX,CENTERY)
	love.graphics.scale(titleTween.drawScale)
	love.graphics.translate(titleTween.translateX,titleTween.translateY)
	love.graphics.setDefaultFilter("nearest","nearest")
	love.graphics.setPointStyle("rough")
    love.graphics.setLineStyle("rough")
   	love.graphics.setPointSize(1)
	love.graphics.setLineWidth(1)

		drawParticles()
		drawComet()
		drawClusters()  		-- debug
	
	love.graphics.pop()
	love.graphics.push()
	love.graphics.translate(CENTERX,CENTERY)	
	love.graphics.translate(titleTween.translateX*titleTween.drawScale,titleTween.translateY*titleTween.drawScale)
		drawConstellations()
		drawStars()
	love.graphics.pop()
	love.graphics.push()
	love.graphics.translate(CENTERX,CENTERY)

	if stateCarrier["gameover"] then
		if titleTimer > 3 then 
			drawTitle()
			drawBestscore()
			drawCredits()
			drawFade()
		end
	else
		drawTitle()
		drawBestscore()
		drawCredits()
		drawFade()
	end
	love.graphics.pop()
	drawHud()
end

function Title:resize(w,h)
	WIDTH = IRESX
	HEIGHT = IRESY
	CENTERX = WIDTH/2
	CENTERY = HEIGHT/2
end

function Title:keypressed(key, unicode)
	if key == 'escape' then
		hs:save()								-- Save the highscores! Then,
		love.event.push('quit')					-- Send 'quit' even to event queue	
	elseif key == 'd' then
	elseif key == 'a' or key == 'f' or key == 's' or key == 'd' then
	else
		if titleTween.buttonDelay == 1 then
			outFade = true
		end
	end
end

function Title:mousepressed(x, y, button)
	--gamestate:gotoState(BUTTONSTATE)
end

function Title:joystickpressed(joystick, button)
	if titleTween.buttonDelay == 1 then
		outFade = true
	end
end
