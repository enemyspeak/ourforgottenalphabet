local Draw = Gamestate:addState('Draw')

local Particle = require 'obj.particle'
local Star = require 'obj.star'
local Constellation = require 'obj.constellation'
local Cluster = require 'obj.cluster'
local Ring = require 'obj.ring'
local Comet = require 'obj.comet'

local WIDTH = IRESX
local HEIGHT = IRESY
local CENTERX = WIDTH/2
local CENTERY = HEIGHT/2

local DEBUG = false

local MAXPARTICLES = 30
local MAXRINGS = 55
local HIGHLIGHTRANGE = (CENTERX*2)^2

local cornerDirection = math.atan2(WIDTH-120,HEIGHT-120)

local orbitBuffer = 1

local stars = {}
local constellations = {}
local particles = {}
local rings = {}

local cluster
local comet
local gameElement =	{
					gameClock,
					gameScore
					}

local drawScale
local drawCounter

local buttonPressed
local highlight

local particleAlpha

local constellationX
local constellationY
local constellationFinished

local constellationFlicker

local orbitDistance

local oribtCanvas = love.graphics.newCanvas( WIDTH, HEIGHT )

local scoreFinished
local drawFinished 		-- this is to control when all the tweens are done

local constellationErrorX1,constellationErrorY1
local constellationErrorX2,constellationErrorY2

local drawTween = {}

local constellationStencil

local debug_text = {}

local function debug(input,indent)
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

local function getClusterStars()  -- hm. think about this.
	local temp = {}

	local n = cluster:getNumStars()
	local radius = cluster:getRadius()-(cluster:getRadius()/4)
	local cx, cy = cluster:getPos()
	local distanceTest = (radius/(n/2))^2
	local interationCount = 0

	local value = true
	while value do
		temp = {}

		for i=1, n do
			local t = 2 * math.pi * math.random()
			local u = math.random(0,radius) + math.random(0,radius)

			local r
			if u > radius then
				r = (radius * 2) - u
			else
				r = u
			end

			if r > radius then
				r = 0
			end

			table.insert(temp, { x = cx + r*math.cos(t), y = cy + r*math.sin(t) })
		end

		value = false

		for k,s in ipairs(temp) do
			for i,v in ipairs(temp) do
				local distance = (s.x - v.x)^2 + (s.y - v.y)^2

				if distance == 0 then else
					if distance < distanceTest then
						value = true
					end
				end
			end
		end

		interationCount = interationCount + 1
		if interationCount > 500 then break end	 -- infinite loop failsafe
	end

--	debug("interationCount "..interationCount)
	return temp
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

local function createClusterStars()
	local index = 1
	while index < #stars do
		if cluster:getFastState(stars[index]:getPos(-100)) then
			if cluster:getState(stars[index]:getPos(-100)) and stars[index]:getConstellation() == false then
				if highlight ~= nil then
					if index < highlight then
						highlight = highlight - 1
					end
				end
				table.remove(stars,index)
			else
				index = index + 1
			end
		else
			index = index + 1
		end
	end

	local temp = getClusterStars()

	for i,v in ipairs(temp) do
		local flag = false
		if i < #temp/2 then
			flag  = true
		end
		stars[#stars + 1] = Star:new({x = v.x, y = v.y, typ = getStarType(), alt = flag, constellation = true})
	end
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

local function finishConstellation()
	constellationFinished = true

	local function setHideCluster()
		hideCluster = true
		drawFinished = true
	end
end

local function drawScore()
	drawCounter = drawCounter + 0.05
	local drawScale = drawTween.drawScale
	local fwidth = fonts["clock"]:getWidth( "+10" )
	local fheight = fonts["clock"]:getHeight( "+10" )
	if drawCounter > #constellations then
		for i = 1, #constellations do
			local x,y = constellations[i]:getPos()

			love.graphics.setColor(unpack(colors["white"]))
			love.graphics.setFont(fonts["clock"])
			love.graphics.print("+10",x,y-20,0,1/drawScale,1/drawScale,fwidth/2,fheight/2)
		end

		if drawCounter > #constellations + 6 then
			scoreFinished = true
		elseif drawCounter > #constellations + 3 then
			love.graphics.setColor(unpack(colors["blue"]))
			love.graphics.setFont(fonts["clock"])
			love.graphics.printf("SCORE", (-CENTERX/drawScale)-drawTween.translateX, ((-CENTERY/drawScale)-drawTween.translateY+5), WIDTH, "center",0,1/drawScale,1/drawScale)
		end
		if drawCounter > #constellations + 4 then
			local temp = 10 * #constellations

			love.graphics.setColor(unpack(colors["white"]))
			love.graphics.setFont(fonts["score"])
			love.graphics.printf(temp, (-CENTERX/drawScale)-drawTween.translateX, ((-CENTERY/drawScale)-drawTween.translateY+7.5), WIDTH, "center",0,1/drawScale,1/drawScale)
		end
	else
		for i = 1, math.ceil(drawCounter) do
			local x,y = constellations[i]:getPos()

			love.graphics.setColor(unpack(colors["white"]))
			love.graphics.setFont(fonts["clock"])
			love.graphics.print("+10",x,y-20,0,1/drawScale,1/drawScale,fwidth/2,fheight/2)
		end
	end
end

local function getNearestStar()
	local distance = HIGHLIGHTRANGE
	local starNum, tempDistance

	for i,v in ipairs(stars) do
		tempDistance = stars[i]:getDistance(comet:getPos())
		if tempDistance < distance and stars[i]:getConstellation() then
			distance = tempDistance
			starNum = i
		end
	end

	return starNum
end

local function updateStars()
	if buttonPressed and highlight~= nil and #constellations == 0 and stars[highlight]:getConstellation() then -- Makes the first point orbited the first star in the contellation
		constellationX, constellationY = stars[highlight]:getPos()
		constellations[1] = Constellation:new({ x = constellationX,y = constellationY })
	end

	if #constellations > 0 then
		local cx,cy = comet:getPos()
		for i,v in ipairs(stars) do
			if stars[i]:getConstellation() then
				local sx,sy = stars[i]:getPos()
				local temp = (cx - constellationX) * (sy - constellationY) - (cy-constellationY) * (sx-constellationX)

				if temp < 0 then
					stars[i]:setL(stars[i]:getF())
					stars[i]:setF("positive")
				elseif temp > 0 then
					stars[i]:setL(stars[i]:getF())
					stars[i]:setF("negative")
				elseif temp == 0 then
					stars[i]:setL(stars[i]:getF())
					stars[i]:setF("equal")
				end

				temp = false
				local greaterX,greaterY,lesserX,lesserY = common:compareValues(cx,cy,constellationX,constellationY)

				if sx >= lesserX and sx <= greaterX then
					if sy >= lesserY and sy <= greaterY then
						if (stars[i]:getL() == "positive") and (stars[i]:getF() == "negative") then
							temp = true
						elseif (stars[i]:getL() == "negative") and (stars[i]:getF() == "positive") then
							temp = true
						elseif (stars[i]:getL() == "equal") and ((stars[i]:getF() == "positive") or (stars[i]:getF() == "negative")) then
							temp = true
						elseif ((stars[i]:getL() == "positive" or stars[i]:getL() == "negative") and stars[i]:getF() == "equal")  then
							temp = true
						end
					end
				end

				if temp then
					constellations[#constellations+1] = Constellation:new({ x = sx, y = sy})

					for i,v in ipairs(stars) do
						stars[i]:setL(false)
						stars[i]:setF(false)
					end

					constellationX, constellationY = constellations[#constellations]:getPos()
				end
			end
		end -- For end
	end
end

local function updateConstellations()
	local lastX = false
	local lastY = false
	local cx,cy = comet:getPos()	-- this stuff has to be outside of the for loops

	for i,v in ipairs(constellations) do 	-- Error detection
		local sx,sy = constellations[i]:getPos()

		if lastX == false and lastY == false then else
			local temp = (cx-lastX) * (sy - lastY) - (cy-lastY) * (sx-lastX)
			if temp < 0 then
				constellations[i]:setL(constellations[i]:getF())
				constellations[i]:setF("positive")
			elseif temp > 0 then
				constellations[i]:setL(constellations[i]:getF())
				constellations[i]:setF("negative")
			elseif temp == 0 then
				constellations[i]:setL(constellations[i]:getF())
				constellations[i]:setF("equal")
			end

			temp = false
			local greaterX,greaterY,lesserX,lesserY = common:compareValues(lastX,lastY,sx,sy)

			if cx >= lesserX and cx <= greaterX then
				if cy >= lesserY and cy <= greaterY then
					if constellations[i]:getL() == "positive" and constellations[i]:getF() == "negative" then
						temp = true
					elseif constellations[i]:getL() == "negative" and constellations[i]:getF() == "positive" then
						temp = true
					elseif (constellations[i]:getL() == "equal") and ((constellations[i]:getF() == "positive") or (constellations[i]:getF() == "negative")) then
						temp = true
					end
				end
			end

			if temp then 		-- You fucked up the mission, son!
				constellationErrorX1,constellationErrorY1 =	lesserX, lesserY
				constellationErrorX2,constellationErrorY2 = greaterX, greaterY
				finishConstellation()
				break
			end
		end
		lastX = sx
		lastY = sy
	end

	for i,v in ipairs(constellations) do
		for k,s in ipairs(constellations) do
			if i == k then
			elseif k > (#constellations/2)+2 then break
			else
				local temp = false
				if constellations[i]:getPos() == constellations[k]:getPos() then
					if constellations[i-1] ~= nil and constellations[k-1] ~= nil then
						if constellations[i-1]:getPos() == constellations[k-1]:getPos() then
							temp = true
							constellationErrorX1,constellationErrorY1 =	constellations[k]:getPos()
							constellationErrorX2,constellationErrorY2 = constellations[k-1]:getPos()
						end
					end
					if constellations[i+1] ~= nil and constellations[k+1] ~= nil then
						if constellations[i+1]:getPos() == constellations[k+1]:getPos() then
							temp = true
							constellationErrorX1,constellationErrorY1 =	constellations[k]:getPos()
							constellationErrorX2,constellationErrorY2 = constellations[k+1]:getPos()
						end
					end
					if constellations[i-1] ~= nil and constellations[k+1] ~= nil then
						if constellations[i-1]:getPos() == constellations[k+1]:getPos() then
							temp = true
							constellationErrorX1,constellationErrorY1 =	constellations[k]:getPos()
							constellationErrorX2,constellationErrorY2 = constellations[k+1]:getPos()
						end
					end
					if constellations[i+1] ~= nil and constellations[k-1] ~= nil then
						if constellations[i+1]:getPos() == constellations[k-1]:getPos() then
							temp = true
							constellationErrorX1,constellationErrorY1 =	constellations[k]:getPos()
							constellationErrorX2,constellationErrorY2 = constellations[k-1]:getPos()
						end
					end

					if temp then
						constellations[#constellations] = nil 	-- Removes the stacked point
						finishConstellation()
						break
					end
				end
			end
		end --Nested for end
	end -- For end
end

local function updateClock(dt)
	gameClock.update(dt)
end

local function updateHighlight()
	if buttonPressed and highlight ~= nil then
		--Lock focus
	else
		--Get nearest star
		highlight = getNearestStar()
	end
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
		local normal_acceleration = 18
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
	--
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

local function updateCluster(dt)
	-- // TODO
			-- constellationErrorX1,constellationErrorY1 = x-30,y-30
			-- constellationErrorX2,constellationErrorY2 = x+30,y+30
			-- finishConstellation()
end

local function updateComet(dt)
	comet:update(dt)
end

local function updateState()
	if scoreFinished and drawFinished then
		cx,cy = comet:getPos()
		for i,v in ipairs(stars) do
			local x,y = stars[i]:getPos()
			stars[i]:setPos(x-cx,y-cy)
		end
		for i,v in ipairs(particles) do
			local x,y = particles[i]:getPos()
			particles[i]:setPos(x-cx,y-cy)
		end
		for i,v in ipairs(constellations) do
			local x,y = constellations[i]:getPos()
			constellations[i]:setPos(x-cx,y-cy)
		end
		local x,y = cluster:getPos()
		cluster:setPos(x-cx,y-cy)

		gameClock.addTime(3 * #constellations)

		local temp2 = gameElement.gameScore + 10 * #constellations
		stateCarrier =	{
						stars = stars,
						particles = particles,
						rings = rings,
						comet = comet,
						gameClock = gameElement.gameClock,
						gameScore = gameElement.gameScore,
						tweenClock = temp1,
						tweenScore = temp2,
						constellations = constellations,
						cluster = cluster,
						drawTween = drawTween
						}

		stateCarrier["fromDraw"] = true
		gamestate:popState()  				-- POOP state
	end
end

local function drawStars()
	local cx,cy = cluster:getPos()
	for i,v in ipairs(stars) do
		if i == highlight then
			stars[i]:draw(true,drawTween.drawScale)
		else
			if stars[i]:getConstellation() then
				stars[i]:draw(nil,drawTween.drawScale)
			else
				if constellationFinished then -- this is where when tweening out you need to see if the star's color is flipped yet.
					local xpos, ypos = stars[i]:getPos()
					if ( xpos - 0 ) ^ 2 + ( ypos - 0 ) ^ 2 < (clusterTween.innerRadius) ^ 2 then		-- Within Circle (x-a)^2 + (y-b)^2 = r ^2
						stars[i]:draw(nil,drawTween.drawScale)
					else
						stars[i]:draw(false,drawTween.drawScale)
					end
				else
					stars[i]:draw(false,drawTween.drawScale)
				end
			end
		end
	end
end

local function drawParticles()
	for i,v in ipairs(particles) do
		particles[i]:draw(particleAlpha)
	end
end

local function drawCluster()
	if hideCluster then else
		local cx,cy = cluster:getPos()
		local ClusterStencil = function()
			love.graphics.circle("fill",cx,cy,clusterTween.innerRadius)
		end

		-- love.graphics.setInvertedStencil(ClusterStencil)
		love.graphics.stencil(ClusterStencil, "replace", 1)
	    love.graphics.setStencilTest("less", 1)

		love.graphics.setColor(colors["cluster"])
		love.graphics.circle("fill",cx,cy,cluster:getRadius()+clusterTween.outerRadius)
		-- love.graphics.setInvertedStencil()
	    love.graphics.setStencilTest()
	end
end

local function drawConstellations()
--	constellationFlicker = not constellationFlicker

--	if constellationFlicker then
		local scale = drawTween.drawScale
		local constellationStencil = function()
			for i,v in ipairs(constellations) do
				local x,y = constellations[i]:getPos()
				love.graphics.circle("fill",x*scale,y*scale,10*scale)
			end
			local x,y = comet:getPos()
			love.graphics.circle("fill",x*scale,y*scale,10*scale)
		end

		local lastX,lastY = CENTERX, CENTERY
		-- love.graphics.setInvertedStencil(constellationStencil)
		love.graphics.stencil(constellationStencil, "replace", 1)
	    love.graphics.setStencilTest("less", 1)
		for i,v in ipairs(constellations) do			-- iterate through each point in each cluster
			local sx,sy = constellations[i]:getPos()
			if lastX == CENTERX and lastY == CENTERY then			-- First loop catch
				if constellationFinished then else
					love.graphics.setColor(unpack(colors["blue2"]))
					local cx,cy = comet:getPos()
					love.graphics.line(constellationX*scale,constellationY*scale,cx*scale,cy*scale )	-- this works, I guess
				end
			else
				love.graphics.setColor(unpack(colors["blue2"]))
				love.graphics.line(lastX*scale,lastY*scale,sx*scale,sy*scale)
			end
			lastX = sx
			lastY = sy
		end
		-- love.graphics.setInvertedStencil()
			    love.graphics.setStencilTest()

--	end
end

local function drawHud()
	local digits = ""
	local gameClock = gameElement.gameClock
	local gameScore = gameElement.gameScore
	if math.floor(gameClock) < 10 then
		digits = "0000"
	elseif math.floor(gameClock) < 100 then
		digits = "000"
	end

	love.graphics.setColor(unpack(colors["background"]))
	love.graphics.rectangle("fill",10,8,40,12)
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


local function drawOrbit()
	if buttonPressed and highlight ~= nil then
		love.graphics.pop()
		local drawScale = drawTween.drawScale

		local c = love.graphics.getCanvas()
		-- oribtCanvas:clear( )
		love.graphics.setCanvas(oribtCanvas)
		-- lg.clear(0,0,0)
		lg.clear(unpack(colors["background"]))

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
			love.graphics.scale(drawTween.drawScale)
			love.graphics.translate(drawTween.translateX,drawTween.translateY)
			love.graphics.translate(unpack(translate))
			love.graphics.scale(maskScale)
			love.graphics.rotate(-orbitDirection)
				love.graphics.ellipse("fill",(-orbitDistance/8),0,orbitDistance/9,orbitDistance/6,0,30) --top
				love.graphics.ellipse("fill",(orbitDistance/8),0,orbitDistance/9,orbitDistance/6,0,30) --bottom
			love.graphics.pop()
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(drawTween.drawScale)
			love.graphics.translate(drawTween.translateX,drawTween.translateY)
			love.graphics.translate(unpack(translate))
			love.graphics.scale(maskScale)
			love.graphics.rotate(-orbitDirection-math.pi/4)
				love.graphics.ellipse("fill",(-orbitDistance/8+orbitDistance/12),(-orbitDistance/3-orbitDistance/48),orbitDistance/6,orbitDistance/3,0,30) --bottom
			love.graphics.pop()
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(drawTween.drawScale)
			love.graphics.translate(drawTween.translateX,drawTween.translateY)
			love.graphics.translate(unpack(translate))
			love.graphics.scale(maskScale)
			love.graphics.rotate(-orbitDirection+math.pi/4)
				love.graphics.ellipse("fill",(orbitDistance/8-orbitDistance/12),(-orbitDistance/3-orbitDistance/48),orbitDistance/6,orbitDistance/3,0,30)	 --top
			love.graphics.pop()
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(drawTween.drawScale)
			love.graphics.translate(drawTween.translateX,drawTween.translateY)
				love.graphics.circle("fill",CometX,CometY,7)
				love.graphics.circle("fill",StarX,StarY,8)
			love.graphics.pop()
		end

		local createStencil = function()
			love.graphics.push()
			love.graphics.translate(CENTERX,CENTERY)
			love.graphics.scale(drawTween.drawScale)
			love.graphics.translate(drawTween.translateX,drawTween.translateY)
			love.graphics.translate(unpack(translate))
			love.graphics.rotate(-orbitDirection)
				love.graphics.circle("fill",0,0,orbitDistance/8)	-- overall
				love.graphics.ellipse("fill",0,orbitDistance/4,orbitDistance/12,(orbitDistance/4),0,20) -- mouse
				love.graphics.circle("fill",0,(-orbitDistance/4) - ((orbitDistance/5.75)),orbitDistance/5)	-- star
				love.graphics.circle("fill",0,(-orbitDistance/4),orbitDistance/7)	-- star between orverall
			love.graphics.pop()
		end

		-- love.graphics.setInvertedStencil(createInvertedStencil)
	    love.graphics.stencil(createInvertedStencil, "replace", 1)
	    love.graphics.setStencilTest("less", 1)

		love.graphics.push()
		love.graphics.translate(CENTERX,CENTERY)
		love.graphics.scale(drawTween.drawScale)
		love.graphics.translate(drawTween.translateX,drawTween.translateY)
			love.graphics.setColor(unpack(colors["blue"],orbitFade))
			for i,v in ipairs(rings) do
				rings[i]:draw()
			end
		love.graphics.pop()
		-- love.graphics.setInvertedStencil()
	    love.graphics.setStencilTest()

		love.graphics.setCanvas(c)
			-- love.graphics.setStencil(createStencil)
		    love.graphics.stencil(createStencil, "replace", 1)
		    love.graphics.setStencilTest("greater", 0)

			love.graphics.setColor(255,255,255)
			love.graphics.draw(oribtCanvas, 0,0, 0, 1,1)

	    love.graphics.setStencilTest()
		-- love.graphics.setStencil()
		love.graphics.setColor(255,255,255)
		love.graphics.push()
		love.graphics.translate(CENTERX,CENTERY)
		love.graphics.scale(drawTween.drawScale)
		love.graphics.translate(drawTween.translateX,drawTween.translateY)
	end
end

local function drawError()
	if drawCounter < 1.5 then
		love.graphics.setColor(unpack(colors["highlight"]))
		local x = constellationErrorX1 - ((constellationErrorX1 - constellationErrorX2)/2)
		local y = constellationErrorY1 - ((constellationErrorY1 - constellationErrorY2)/2)
		local distance = math.sqrt((constellationErrorX1 - constellationErrorX2)^2  + (constellationErrorY1 - constellationErrorY2)^2)
		love.graphics.setLineWidth(1)
		love.graphics.circle("line",x,y,distance/2)
	end
end

------------------------------------------------------------------------------------------









function Draw:enteredState()
	if stateCarrier["fromGame"] == true then
		constellations = {}

		stars = stateCarrier["stars"]
		rings = stateCarrier["rings"]
		cluster = stateCarrier["cluster"]
		comet = stateCarrier["comet"]

		gameElement.gameScore = stateCarrier["gameScore"]
		gameElement.gameClock = stateCarrier["gameClock"]

		local r = cluster:getRadius()
		local x,y = cluster:getPos()
		local n = MAXPARTICLES
		for i = 1, n do
			local speed, color = getParticleAttributes()
			particles[i] =  Particle:new({ x = x+math.random(-r,r), y = y+math.random(-r,r), speed = speed, color = color})
		end
		createClusterStars()

		particleAlpha = 150  	-- dims particles

		buttonPressed = false 	-- so this shit doesn't crash
		highlight = nil  		-- this too

		local factor = 0.50 		-- Slows the comet so you don't just blast through a cluster
		vel.x = vel.x * factor
		vel.y = vel.y * factor
		clusterClock = 0  			-- Disables the cluster bounds check so you don't instantly fail
		hideCluster = false

		drawCounter = 0 			-- Tracks the score #

		--	New tween stuff

		local radius = cluster:getRadius()
		local clusterStartX,clusterStartY = cluster:getPos()
		--	local x,y = comet:getPos()		-- the comet should be at 0,0
		drawTween = {
					translateX = 0,
					translateY = 0,
					drawScale = 1
					}
		tween( 1, drawTween, { translateX = -clusterStartX, translateY = -clusterStartY, drawScale = (HEIGHT-10)/(radius*2) }, 'outQuad')

		clusterTween = 	{
						outerRadius = 0,
						innerRadius = 0
						}
		tween(0.45,clusterTween, { innerRadius = radius-5 },"outQuad",
				tween,1,clusterTween, { outerRadius = WIDTH }, "inQuad")
--
		scoreFinished = false
		drawFinished = false
		constellationFinished = false
		constellationFlicker = false

		stateCarrier["fromGame"] = false
	end
end

function Draw:exitedState()
	tween.stopAll() --stops all animations, without resetting any values
end

function Draw:update(dt)
	tween.update(dt)

	if constellationFinished then
		updateState()
	else
		updateClock(dt)
		updateHighlight()
		updateOrbit(dt)
		updateComet(dt)
		updateCluster(dt)
		updateStars()
		updateConstellations()
	end
end

function Draw:draw()
	love.graphics.setBackgroundColor(unpack(colors.background))
	love.graphics.push()
		love.graphics.setColor(unpack(colors.background))
		love.graphics.rectangle("fill",0,0,IRESX,IRESY)
	love.graphics.translate(CENTERX,CENTERY)
	love.graphics.scale(drawTween.drawScale)
	love.graphics.translate(drawTween.translateX,drawTween.translateY)
	love.graphics.setDefaultFilter("nearest","nearest")
	-- love.graphics.setPointStyle("rough")
    -- love.graphics.setLineStyle("rough")
   	love.graphics.setPointSize(1)
	love.graphics.setLineWidth(1)
		drawParticles()
		if constellationFinished then
			drawError()
		else
			drawOrbit()
		end
		comet:draw(drawTween.drawScale)
		drawCluster()

		if constellationFinished and scoreFinished == false then
	 		drawScore()
		end
	love.graphics.pop()
	love.graphics.push()
	love.graphics.translate(CENTERX,CENTERY)
	love.graphics.translate(drawTween.translateX*drawTween.drawScale,drawTween.translateY*drawTween.drawScale)
		drawStars()
		drawConstellations()
	love.graphics.pop()
	drawHud()
end

function Draw:keypressed(key, unicode)
	if key == 'd' then 		-- debug
		stateCarrier["fromGame"] = true
		Draw:enteredState()
	elseif key == 'f' or key == 's' or key == 'a' then
	elseif key == 'escape' then
		hs:save()								-- Save the highscores! Then,
		love.event.push('quit')					-- Send 'quit' even to event queue
	else
		buttonPressed = true
	end
end

function Draw:keyreleased(key)					-- Toggle button off
	buttonPressed = false
end

function Draw:mousepressed(x, y, button)
	--gamestate:gotoState(BUTTONSTATE)
end

function Draw:joystickpressed(joystick, button)
	buttonPressed = true
end

function Draw:joystickreleased(joystick, button)
	buttonPressed = false
end
