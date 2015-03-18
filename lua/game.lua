
local Game = Gamestate:addState('Game')

local Particle = require 'obj.particle'
local Star = require 'obj.star'
local Constellation = require 'obj.constellation'
local Cluster = require 'obj.cluster'
local Comet = require 'obj.comet'
local Ring = require 'obj.ring'

local vel = require 'lua.velocity'

local NEXTSTATE = 'Title'

local DEBUG = true

local WIDTH = IRESX
local HEIGHT = IRESY
local CENTERX = WIDTH/2
local CENTERY = HEIGHT/2

local HIGHLIGHTRANGE = CENTERX^2 

local ARROWINSET = 30
local CDIRECTION = math.atan2(WIDTH-(2*ARROWINSET),HEIGHT-(2*ARROWINSET))

local MAXPARTICLES = 30
local MAXSTARS = 5
local MAXRINGS = 55
local NUMRINGS = 22

local orbitBuffer = 1
local starBufferX = 0
local starBufferY = 0
local decayBuffer = 0

local orbitDistance = 0
local arrowAlpha = 255
local particles = {}
local stars = {}
local rings = {}
local clusters = {}
local constellations = {}
local decay = {}

local clusterNumber

local oribtCanvas = love.graphics.newCanvas( WIDTH, HEIGHT )

local buttonPressed
local highlight

local gameTween = {} -- 

local orbitDistance

local gameAlpha
local gameElement = {
					gameClock,
					gameScore,
					tweenToggle	
					}

local ringLowCounter = true
local ringHighCounter = true

local constellationFlicker
	
local debug_text = {}

local function debug(input, indent)
	if (input == nil) then
		input = "--------"
	end

	if (indent == nil) then
		indent = 0
	end

	local temp_string = tostring(input)

	for i = 1, indent, 1 do
		temp_string = "   " .. temp_string
	end

	table.insert(debug_text, temp_string);
end

local function magnitude_2d(x, y)
	return math.sqrt(x*x + y*y)
end
	
local function normalize_2d(x, y)
	local mag = magnitude_2d(x, y)
	if mag == 0 then return {0,0} end
	return {x/mag, y/mag}
end

local function createRings()
	local factor = 1/NUMRINGS
	for i = 0, NUMRINGS do		
		local flag = getOrbitHide()
		if factor * i < 0.50 then
			rings[i] = Ring:new({ X1 = cometX, Y1 = cometY, X2 = starX, Y2 = starY, pos = factor * i, alpha = alpha, distance = distance, hide = flag}) 
		else
			rings[i] = Ring:new({ X1 = starX, Y1 = starY, X2 = starX, Y2 = starY, pos = (factor * i) -0.50, alpha = alpha, open = false, close = true, hide = flag}) 
		end
	end
end

function getOrbitHide()			-- Doesn't work as local function?
	local temp = 0
	ringLowCounter = not ringLowCounter
		
	if ringLowCounter then
		ringHighCounter = not ringHighCounter
	end
	
	if ringLowCounter then
		temp = temp + 1
	end
	if ringHighCounter and ringLowCounter then
		temp = temp + 1
	end

	return temp
end
 
local function getNearestStar()
	local distance = HIGHLIGHTRANGE
	local starNum, tempDistance
	
	for i,v in ipairs(stars) do
		tempDistance = stars[i]:getDistance()
		
		if tempDistance < distance and stars[i]:isOnScreen() then
			if clusters[clusterNumber]:getFastState(stars[i]:getPos()) then
				if clusters[clusterNumber]:getState(stars[i]:getPos()) then else		
					distance = tempDistance
					starNum = i
				end
			else
				distance = tempDistance
				starNum = i
			end
		end
	end
	
	return starNum
end

local function getObjectXY(kind,value)
	local safeX = (IRESX/2 + kind.SAFEZONE)
	local safeY = (IRESY/2 + kind.SAFEZONE)
	local x,y
	if value == nil then
		if math.random(1,2) == 1 then
			if vel.x < 0  then 						-- Star direction logic
				x = -safeX
				y = math.random(-safeY, safeY)
			else
				x = safeX
				y = math.random(-safeY, safeY)
			end
		else
			if vel.y < 0 then
				x = math.random(-safeX, safeX)
				y = safeY
			else
				x = math.random(-safeX, safeX)
				y = -safeY
			end
		end	
	else
		if value == 'x' then
			if vel.x < 0  then 						-- Star direction logic
				x = -safeX
				y = math.random(-safeY, safeY)
			else
				x = safeX
				y = math.random(-safeY, safeY)
			end
		elseif value == 'y' then
			if vel.y < 0 then
				x = math.random(-safeX, safeX)
				y = safeY
			else
				x = math.random(-safeX, safeX)
				y = -safeY
			end
		end
	end
	
	return x,y
end

local function getEdgeXY(glowX,glowY,tempInset)
	local angle = math.atan2(WIDTH,HEIGHT)
	local x,y
	
	local C = 	{
				x = 0,
				y = 0
				}
	local P =	{
				x = glowX,
				y = glowY
				}
				
	local tempX = P.x - C.x
	local tempY = P.y - C.y
	local rad = math.atan2(tempY,tempX)+math.pi/2

	if rad > -angle and rad < angle then
		t = (CENTERX-tempInset - C.x)/(P.x - C.x) 
	elseif rad > angle and rad < angle+math.rad(180) then
		t = (-CENTERY+tempInset - C.y)/(P.y - C.y)
	elseif rad > -angle + math.rad(180)  and rad < angle + math.rad(180)  then	
		t = (CENTERY-tempInset - C.y)/(P.y - C.y)
	else
		t = (-CENTERX+tempInset - C.x)/(P.x - C.x)
	end
	
	x = (P.x - C.x)*t + C.x
	y = (P.y - C.y)*t + C.y
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

local function updateFade(dt)
	if gameAlpha == 0 then else	
		gameAlpha = gameAlpha - math.ceil(dt)*5
		if gameAlpha <= 255/2 then
			gameAlpha = 0
		end
	end
end

local function updateParticles(dt)
	for i,v in ipairs(particles) do
		particles[i]:update(dt)
		if particles[i]:getKill() == true then
			table.remove(particles,i)
		end
		if #particles < MAXPARTICLES then
			local speed, color = getParticleAttributes()
			local x,y = getObjectXY(Particle)
			particles[#particles + 1] = Particle:new({x = x, y = y, speed = speed, color = color}) 
		end
	end
end

local function updateStars(dt)
	local value = false
	
	if buttonPressed and highlight ~= nil then
		value = true
	end
	
	for i,v in ipairs(stars) do
		stars[i]:update(dt, value)
		if stars[i]:getConstellation() then else
			if stars[i]:getKill() == true then
				if highlight ~= nil then
					if i < highlight then
						highlight = highlight - 1
					end
				end
				table.remove(stars,i)
				i = i - 1
			end
		end
	end
	
	local interval = 45
	local rate = 2

	if value then else	
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
end

local function updateHighlight(dt)
	if buttonPressed and highlight ~= nil then		
		--Lock focus
	else
		--Get nearest star
		highlight = getNearestStar()		
	end
end

local function updateComet(dt)
	comet:updateTrail(dt)	
end

local function updateOrbit(dt)
	local function magnitude_2d_sq(x, y)
		return x*x + y*y
	end
	
	if buttonPressed and highlight ~= nil then
		local starX, starY = stars[highlight]:getPos()
		local cometX, cometY =  comet:getPos()		
		local interval = 0.2
		
		local orbitDirection = math.atan2(cometX - starX , cometY - starY)+math.pi/2		-- atan2 = math.atan() - math.pi/2
		local normal_acceleration = 18 --16
		local temp_norm_accel = normalize_2d((math.cos(orbitDirection)),(math.sin(orbitDirection)))

		local temp_x_accel = temp_norm_accel[1]*normal_acceleration*accel
		local temp_y_accel = temp_norm_accel[2]*normal_acceleration*accel
		
		max_accel = 1
		accel = accel + dt*30
		if accel > max_accel then
			accel = max_accel
		end

		
		local temp_x_vel = vel.x
		local temp_y_vel = vel.y
		
		temp_x_vel = temp_x_vel + temp_x_accel
		temp_y_vel = temp_y_vel + temp_y_accel
		
		local temp_vel = magnitude_2d_sq(temp_x_vel, temp_y_vel)
		
		vel.x = temp_x_vel
		vel.y = temp_y_vel

		orbitBuffer = orbitBuffer + dt		
		if orbitBuffer > interval and #rings < MAXRINGS then
			orbitBuffer = 0
			local flag = getOrbitHide()
			rings[#rings+1] = Ring:new({ X1 = cometX, Y1 = cometY, X2 = starX, Y2 = starY, r = 0, alpha = alpha, distance = orbitDistance, hide = flag })
		end
		
		orbitDistance = math.sqrt((cometX - starX )^2  + ( cometY - starY)^2 )
		
		for i,v in ipairs(rings) do
			if rings[i]:getKill() then
				table.remove(rings,i)
			else
				rings[i]:setDistance(orbitDistance)
				rings[i]:setCometPos(cometX,cometY)
				rings[i]:setStarPos(starX,starY)
				rings[i]:update(dt)	
				if orbitDistance < 10 then
					rings[i]:setHidden(-1)	--HARD ON (on = hidden)
				elseif orbitDistance < 60 then
					rings[i]:setHidden(2)	--High
				elseif orbitDistance < 120 then
					rings[i]:setHidden(1)	--Low
				else
					rings[i]:setHidden(0)	--Off
				end
			end
		end
	else
		accel = 0
	end	
end

local function updateClock(dt)
	if gameElement.tweenToggle == 1 then   -- waits until the clock tween is finished before running
		if gameElement.gameClock < 1 then
			 stateCarrier =	{
			 				stars = stars,
			 				particles = particles,
							clusters = clusters,
		 					constellations = constellations,
		 					comet = comet,
			 				gameScore = gameElement.gameScore,
							}
			stateCarrier["gameover"] = true

			hs:add("a", gameElement.gameScore)
			hs:save()								-- Save the highscores! Then,		
			gamestate:gotoState(NEXTSTATE)
		elseif gameElement.gameClock > 100 then
			gameElement.gameClock = 100
		else
			gameElement.gameClock = gameElement.gameClock - dt
		end
	end
end

local function updateArrow(dt)
	local px,py = clusters[clusterNumber]:getPos()
	local P = 	{
				x = px,
				y = py
				}
	local C = 	{
				x = 0,
				y = 0
				}
	local tempX = P.x - C.x
	local tempY = P.y - C.y
	local t
	
	arrowDirection = math.atan2(tempY,tempX)+math.pi/2
		
	if arrowDirection > CDIRECTION and arrowDirection < -CDIRECTION+math.rad(180)  then		-- This only works if it's square NOPE FIXED
		t = (CENTERX-ARROWINSET - C.x)/(P.x - C.x) 
	elseif arrowDirection > -CDIRECTION and arrowDirection < CDIRECTION then	--	if tempY > 0 then
		t = (-CENTERY+ARROWINSET - C.y)/(P.y - C.y)
	elseif arrowDirection > -CDIRECTION + math.rad(180) and arrowDirection < CDIRECTION + math.rad(180) then	--	if tempY > 0 then
		t = (CENTERY-ARROWINSET - C.y)/(P.y - C.y)
	else
		t = (-CENTERX+ARROWINSET - C.x)/(P.x - C.x)
	end
	
	arrowX = (P.x - C.x)*t + C.x
	arrowY = (P.y - C.y)*t + C.y
	
	local cx,cy = clusters[clusterNumber]:getPos()
	local cr = clusters[clusterNumber]:getRadius()
	local sqdist = ((cx+CENTERX)-arrowX) ^ 2 + ((cy+CENTERY)-arrowY) ^ 2 -- Within Circle (x-a)^2 + (y-b)^2 = r ^2

	if sqdist < (cr+220) ^ 2 then		
		arrowAlpha = arrowAlpha - dt*120
		if arrowAlpha < 0 then
			arrowAlpha = 0
		end
	else
		arrowAlpha = arrowAlpha + dt*220
		if arrowAlpha > 255 then
			arrowAlpha = 255
		end
	end
end

local function updateCluster(dt)
	for i=1, #clusters do
		clusters[i]:update(dt)
	end
--	clusters[clusterNumber]:update(dt)
end

local function updateState()
 	if clusters[clusterNumber]:getState(comet:getPos()) then -- 30
	 	stateCarrier =	{
	 					stars = stars,
	 					rings = rings,
	 					cluster = clusters[clusterNumber],
	 					comet = comet,
	 					
	 					gameClock = gameElement.gameClock,
	 					gameScore = gameElement.gameScore
						}
	
		stateCarrier["fromGame"] = true	 					
 		gamestate:pushState("Draw")
 	end
end

function updateConstellations(dt)						-- Update constellations
	for i=1, #constellations do 
		for k, s in ipairs(constellations[i]) do			
			constellations[i][k]:update(dt)
		end
	end
end

local function drawTestOrbit()
	if buttonPressed and highlight ~= nil then
		for i,v in ipairs(rings) do
	--		local x,y = rings[i]:getPos()
	--		local o,c,h = rings[i]:getTest()
	--		love.graphics.print(x..", "..y..", "..tostring(o)..", "..tostring(c)..", "..tostring(h),-200,15*i)
			rings[i]:draw()
		end
	--	love.graphics.print("# rings: " .. #rings, 200, 10)
	--	love.graphics.print(tostring(love.timer.getFPS( )), 200, 30)
	--	love.graphics.print("distance: " .. tostring(orbitDistance), 200, 20)		
	end
end

local function drawOrbit()
	if buttonPressed and highlight ~= nil then	
		love.graphics.pop()
		local drawScale = gameTween.drawScale

		local c = love.graphics.getCanvas()
		oribtCanvas:clear( )
		love.graphics.setCanvas(oribtCanvas)
		
		local StarX,StarY = stars[highlight]:getPos()		-- There should be a way of passing update variables here
		local CometX, CometY =  comet:getPos()			
	
		local orbitDirection = math.atan2(CometX - StarX , CometY-StarY)
		local translate = 	{
							CometX -((CometX - StarX)/2),
							CometY -((CometY - StarY)/2)
							}
	
		local createInvertedStencil = function()
			local maskScale = 0.8
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(gameTween.drawScale)
			love.graphics.translate(gameTween.translateX,gameTween.translateY)
			love.graphics.translate(unpack(translate))
			love.graphics.scale(maskScale)
			love.graphics.rotate(-orbitDirection)
				love.graphics.ellipse("fill",(-orbitDistance/8),0,orbitDistance/9,orbitDistance/6,0,30) --top
				love.graphics.ellipse("fill",(orbitDistance/8),0,orbitDistance/9,orbitDistance/6,0,30) --bottom
			love.graphics.pop()
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(gameTween.drawScale)
			love.graphics.translate(gameTween.translateX,gameTween.translateY)	
			love.graphics.translate(unpack(translate))
			love.graphics.scale(maskScale)
			love.graphics.rotate(-orbitDirection-math.pi/4)
				love.graphics.ellipse("fill",(-orbitDistance/8+orbitDistance/12),(-orbitDistance/3-orbitDistance/48),orbitDistance/6,orbitDistance/3,0,30) --bottom
			love.graphics.pop()
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(gameTween.drawScale)
			love.graphics.translate(gameTween.translateX,gameTween.translateY)	
			love.graphics.translate(unpack(translate))
			love.graphics.scale(maskScale)
			love.graphics.rotate(-orbitDirection+math.pi/4)
				love.graphics.ellipse("fill",(orbitDistance/8-orbitDistance/12),(-orbitDistance/3-orbitDistance/48),orbitDistance/6,orbitDistance/3,0,30)	 --top
			love.graphics.pop()
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(gameTween.drawScale)
			love.graphics.translate(gameTween.translateX,gameTween.translateY)
				love.graphics.circle("fill",CometX,CometY,7)	
				love.graphics.circle("fill",StarX,StarY,8)
			love.graphics.pop()
		end
		
		local createStencil = function()
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(gameTween.drawScale)
			love.graphics.translate(gameTween.translateX,gameTween.translateY)
			love.graphics.translate(unpack(translate))
			love.graphics.rotate(-orbitDirection)
				love.graphics.circle("fill",0,0,orbitDistance/8)	-- overall
				love.graphics.ellipse("fill",0,orbitDistance/4,orbitDistance/12,(orbitDistance/4),0,20) -- mouse
				love.graphics.circle("fill",0,(-orbitDistance/4) - ((orbitDistance/5.75)),orbitDistance/5)	-- star
				love.graphics.circle("fill",0,(-orbitDistance/4),orbitDistance/7)	-- star between orverall
			love.graphics.pop()	
		end
		
		love.graphics.setInvertedStencil(createInvertedStencil)
		love.graphics.push()
		love.graphics.translate(CENTERX,CENTERY)		
		love.graphics.scale(gameTween.drawScale)
		love.graphics.translate(gameTween.translateX,gameTween.translateY)
			love.graphics.setColor(unpack(colors["blue"],orbitFade))	
			for i,v in ipairs(rings) do
				rings[i]:draw()
			end
		love.graphics.pop()
		love.graphics.setInvertedStencil()
		love.graphics.setCanvas(c)	
			love.graphics.setStencil(createStencil)
			love.graphics.setColor(255,255,255)
			love.graphics.draw(oribtCanvas, 0,0, 0, 1,1)
		love.graphics.setStencil()
		love.graphics.setColor(255,255,255)
		love.graphics.push()
		love.graphics.translate(CENTERX,CENTERY)
		love.graphics.scale(gameTween.drawScale)
		love.graphics.translate(gameTween.translateX,gameTween.translateY)
			stars[highlight]:draw(true)		-- draw the star you're obiting on top of the orbit effect
	end
end

local function drawParticles()
	for i,v in ipairs(particles) do
		particles[i]:draw()
	end
end

local function drawDecay()
	for i,v in ipairs(decay) do
		decay[i]:draw()
	end
end

local function drawStars()
	for i,v in ipairs(stars) do
		if i == highlight then
			stars[i]:draw(true)
		else
			stars[i]:draw()
		end
	end
end

local function drawConstellations()
--	constellationFlicker = not constellationFlicker
--	if constellationFlicker then
		local function checkCorners(xpos,ypos)
			local value = false
			if (xpos <= WIDTH and xpos >= -WIDTH) and (ypos <= HEIGHT and ypos >= -HEIGHT) then
				value = true
			end
			return value
		end
		
		local temp = {}
		for i=1, #clusters-1 do 			-- finds out if the constellation is on screen
			if i == clusterNumber then else
				local r = clusters[i]:getRadius()*4
				if clusters[i]:getState(CENTERX,CENTERY,-r) or clusters[i]:getState(-CENTERX,CENTERY,-r) or clusters[i]:getState(CENTERX,-CENTERY,-r) or clusters[i]:getState(-CENTERX,-CENTERY,-r) then
					table.insert(temp,i)
				end
			end	
		end	

		local createConstellationStencil = function()
			for i,v in ipairs(temp) do
				for j,k in ipairs(constellations[v]) do
					local x,y = constellations[v][j]:getPos()
					love.graphics.circle("fill",x,y,10)		-- Constellation mask
				end
			end
		end

		for i,v in ipairs(temp) do
			local lastX = false
			local lastY = false
			
			for j,k in ipairs(constellations[v]) do
				love.graphics.setInvertedStencil(createConstellationStencil)		
				if lastX == false and lastY == false then else 	
					love.graphics.setColor(unpack(colors["blue2"]))	
					love.graphics.setLineWidth(1)
					love.graphics.line(lastX,lastY,constellations[v][j]:getPos())
				end
				local sx,sy = constellations[v][j]:getPos()
				lastX = sx
				lastY = sy
				love.graphics.setInvertedStencil()	
			end
		end
--	end
end

local function drawComet()
	comet:draw()
end

local function drawFade()			-- Tweens screen flash using a fade value, updated each frame
	if gameAlpha == 0 then else
		love.graphics.setColor( 255, 255, 255, gameAlpha )
		love.graphics.polygon( "fill", 0, 0, WIDTH, 0, WIDTH, HEIGHT, 0, HEIGHT)
	end
end

local function drawHud()
	local gameClock = gameElement.gameClock
	local gameScore = gameElement.gameScore
	local digits = ""
	if math.floor(gameClock) < 10 then
		digits = "0000"
		if math.floor(gameClock) % 2 == 1 then
			love.graphics.setColor(unpack(colors["highlight"]))	
			love.graphics.rectangle("fill",10,8,40,12)
		else				
			love.graphics.setColor(unpack(colors["background"]))		
			love.graphics.rectangle("fill",10,8,40,12)
		end
	elseif math.floor(gameClock) < 100 then
		digits = "000"			
		love.graphics.setColor(unpack(colors["background"]))		
		love.graphics.rectangle("fill",10,8,40,12)
	end
	
	love.graphics.setColor(unpack(colors["white"]))	
	love.graphics.setFont(fonts["clock"])	
	love.graphics.print(digits..math.floor(gameClock), 10, 5)
	
	if math.floor(gameScore) < 10 then
		digits = "0000"
	elseif math.floor(gameScore) < 100 then
		digits = "000"	
	elseif math.floor(gameScore) < 1000 then	
		digits = "00"	
	elseif math.floor(gameScore) < 10000 then	
		digits = "0"
	else 		
		digits = ""
	end
	
	love.graphics.setColor(unpack(colors["background"]))		
	love.graphics.rectangle("fill",WIDTH - 50,8,40,12)
	love.graphics.setColor(unpack(colors["white"]))	
	love.graphics.setFont(fonts["clock"])	
	love.graphics.print(digits..math.floor(gameScore), WIDTH - 50, 5)
end

local function drawArrow()
	love.graphics.setColor(255,255,255,arrowAlpha)
	love.graphics.draw(graphics["arrow"],arrowX,arrowY,arrowDirection,0.5,0.5,32*.75,32*.75)
end

local function drawCluster()
	clusters[clusterNumber]:draw()
end

------------------------------------------------------------------------------------------









function Game:enteredState()
	if stateCarrier["fromDraw"] == true then else
		clusters = {}
		stars = {}
		particles = {}
		constellations = {}
		
		clusterNumber = 1
		constellations[clusterNumber] = {}

		decay = {}
			
		arrowAlpha = 255		
		gameAlpha = 255
		
		constellationFlicker = false
		buttonPressed = false
		highlight = nil
		
		gameElement.gameScore = 0
		gameElement.gameClock = 100
		gameElement.tweenToggle = 1
		
		vel.x = common:getRandomSigned(100,200)
		vel.y = common:getRandomSigned(100,200)
		
		arrowX = 0 --Hack!
		arrowY = 0
		
		gameTween = {
					translateX = 0,
					translateY = 0,
					drawScale = 1
					}

		createRings()
		
		comet = Comet:new({x = 0, y = 0})
		comet:setScale(0.25)

		clusters[1] = Cluster:new({x = common:getRandomSigned(1000,2000), y = common:getRandomSigned(1000,2000), radius = 200 + 4 * 9, numStars = 9}) --* (math.random(1,2) ^ cluster_number)	-- Difficulty scale
		--clusters[1] = Cluster:new({x = 0, y = 0,radius = 200}) --* (math.random(1,2) ^ cluster_number)	-- Difficulty scale
		--clusters[1] = Cluster:new({x = 100, y = 300,radius = 200}) --* (math.random(1,2) ^ cluster_number)	-- Difficulty scale
		
		for i = 1, MAXPARTICLES/2 do
			local speed, color = getParticleAttributes()
			particles[i] =  Particle:new({ x = math.random(-CENTERX,CENTERX), y = math.random(-CENTERY,CENTERY), speed = speed, color = color}) 
		end
		for i = 1, MAXSTARS do
			stars[i] =  Star:new({ x = math.random(-(CENTERX+Star.SAFEZONE),(CENTERX+Star.SAFEZONE)), y = math.random(-CENTERY,CENTERY), typ = getStarType()}) 
		end

		love.graphics.setBackgroundColor(unpack(colors.background))
	end
end

function Game:exitedState()
	tween.stopAll() --stops all animations, without resetting any values
end

function Game:update(dt)	
	tween.update(dt)
	debug_text = {}

	updateState()		-- State changer
	updateFade(dt)
	updateParticles(dt)
	updateStars(dt)
	updateConstellations(dt)
	updateHighlight(dt)
	updateOrbit(dt)
	updateCluster(dt)
	updateArrow(dt)
	updateClock(dt)
	updateComet(dt)
end

function Game:draw()
	love.graphics.setBackgroundColor(unpack(colors.background))
	love.graphics.push()
		love.graphics.setColor(unpack(colors.background))
		love.graphics.rectangle("fill",0,0,WIDTH,HEIGHT)
	love.graphics.translate(CENTERX,CENTERY)	
	love.graphics.scale(gameTween.drawScale)
	love.graphics.translate(gameTween.translateX,gameTween.translateY)
	love.graphics.setDefaultFilter("nearest","nearest")
	love.graphics.setPointStyle("rough")
    love.graphics.setLineStyle("rough")
   	love.graphics.setPointSize(1)
	love.graphics.setLineWidth(1)

		drawParticles()
		drawStars()	
		drawConstellations()
		drawOrbit()
		drawComet()
		drawCluster()
		drawArrow()

	
	love.graphics.pop()

	drawHud()
	drawFade()

	if DEBUG then
		love.graphics.setColor(unpack(colors.white))
		love.graphics.setFont(fonts["clock"])	
		for index,value in pairs(debug_text) do
			love.graphics.print(tostring(value), 10, 100 + 12*index)
		end
	end
end


function Game:continuedState()
 	if stateCarrier["fromDraw"] == true then
		stars = stateCarrier["stars"]
		particles = stateCarrier["particles"]
		rings = stateCarrier["rings"]
		comet = stateCarrier["comet"]
		gameElement.gameScore = stateCarrier["gameScore"]
		gameElement.gameClock = stateCarrier["gameClock"]
		constellations[clusterNumber] = stateCarrier["constellations"]
		clusters[clusterNumber] = stateCarrier["cluster"]
		gameTween = stateCarrier["drawTween"]
		
		local px, py = clusters[clusterNumber]:getPos()
		
		buttonPressed = false
		highlight = nil		
		
		if (#constellations[clusterNumber]-1) >= clusters[clusterNumber].numStars then
			n = clusters[clusterNumber].numStars + 2
		elseif (#constellations[clusterNumber]-1)/clusters[clusterNumber].numStars > 0.50 then
			n = clusters[clusterNumber].numStars + 1
		else 
			n = clusters[clusterNumber].numStars
		end

		clusterNumber = clusterNumber + 1
				
		if n > 13 then n = 13 end		-- MAX STARS PER CLUSTER
		local r = 200 + 4 * n
		local value = true
		local iterationCount = 0
		while value do
			if iterationCount > 100 then break end

			clusters[clusterNumber] = Cluster:new(	{	
													x = common:getRandomSigned(3000,4500)*(clusterNumber/3+gameElement.gameScore/600), 
													y = common:getRandomSigned(3000,4500)*(clusterNumber/3+gameElement.gameScore/600), 
													numStars = n,
													radius = r
													})		

			local x1,y1 = clusters[clusterNumber]:getPos()
			value = false

			for i=1, #clusters-1 do
				local x2,y2 = clusters[i]:getPos()
				if (x2-x1)^2+(y2-y1)^2 < 1000^2 then
					value = true
				end
			end

			iterationCount = iterationCount + 1
		end
		
		arrowAlpha = 0

		local cx,cy = comet:getPos()				
		gameTween.translateX = -px
		gameTween.translateY = -py
		comet:setPos(0,0)
		tween(1, gameTween, { translateX = 0, translateY = 0, drawScale = 1 }, 'outQuad')

		
		gameElement.tweenToggle = 0
		local temp1 = stateCarrier["tweenClock"]
		local temp2 = stateCarrier["tweenScore"]   -- YOU SCORED A POINT
		tween(1,gameElement,{ gameClock = temp1, gameScore = temp2 },"outQuad",		
			tween,0.5,gameElement,{tweenToggle = 1},"linear") 		-- this is a hack

		--gameTween.drawScale = 1
		--stateCarrier["fromDraw"] = false
	end
end

function Game:resize(w,h)
	WIDTH = IRESX
	HEIGHT = IRESY
	CENTERX = WIDTH/2
	CENTERY = HEIGHT/2
end

function Game:keypressed(key, unicode)
	if key == 'escape' then
		hs:save()								-- Save the highscores! Then,
		love.event.push('quit')
	elseif key == 'd' then
		gameElement.gameClock = 1
	elseif key == 'f' or key == 's' or key == 'a' then
	else
		buttonPressed = true
	end
end

function Game:keyreleased(key)					-- Toggle button off
	buttonPressed = false
end
 
function Game:joystickpressed(joystick, button)
	buttonPressed = true
end

function Game:joystickreleased(joystick, button)
	buttonPressed = false
end

function Game:mousepressed(x, y, button)
	--gamestate:gotoState(BUTTONSTATE)
end
