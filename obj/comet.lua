
local Comet = class('Comet')
--	 I'M A SHOOTING STAR!

Comet.static.WIDTH = IRESX
Comet.static.HEIGHT = IRESY
Comet.static.CENTERX = Comet.WIDTH/2
Comet.static.CENTERY = Comet.HEIGHT/2

Comet.static.COLOR1 = {255,255,255,255}
Comet.static.COLOR2 = {235,165,118}
Comet.static.COLOR3 = {86,73,109}

--[[
Comet.static.COLOR2 = {100,212,255}		-- Alternate color2
Comet.static.COLOR3 = {3,0,69}		-- Alternate color3
--]]

Comet.static.TRAIL_MAX = 10
Comet.static.LONGTRAIL_MAX = 20
Comet.static.LONGERTRAIL_MAX = 200

function Comet:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or Comet.CENTERX
	self.y = attributes.y or Comet.CENTERY
	self.health = attributes.health or 1
	self.rotation = 0
	self.alpha = attributes.alpha or 255
	self.size = 2
	self.scale = 0.25
	self.trail = {}
	self.longTrail = {}
	self.longerTrail = {}
end

function Comet:setAlpha(value)
	self.alpha = value
end

function Comet:update(dt)	-- Called only when drawing constellations
	table.insert(self.trail, 1, {self.x, self.y} )	
	table.insert(self.longTrail, 1, {self.x, self.y} )	
	table.insert(self.longerTrail, 1, {self.x, self.y} )	
	
	if (#self.trail > Comet.TRAIL_MAX) then
		table.remove(self.trail, #self.trail)
	end
	if (#self.longTrail > Comet.LONGTRAIL_MAX) then
		table.remove(self.longTrail, #self.longTrail)
	end
	if (#self.longerTrail > Comet.LONGERTRAIL_MAX) then
		table.remove(self.longerTrail, #self.longerTrail)
	end
	
	self.x = self.x - (-vel.x * dt)
	self.y = self.y - (vel.y * dt)
end

function Comet:updateTrail(dt)
	if (#self.trail > Comet.TRAIL_MAX) then
		table.remove(self.trail, #self.trail)
	end
	
	if (#self.longTrail > Comet.LONGTRAIL_MAX) then
		table.remove(self.longTrail, #self.longTrail)
	end
	
	if (#self.longerTrail > Comet.LONGERTRAIL_MAX) then
		table.remove(self.longerTrail, #self.longerTrail)
	end
	
	local magnitudeX = (vel.x * dt)
	local magnitudeY = (-vel.y * dt)
	
	for i,v in ipairs(self.trail) do
		v[1] = v[1] - magnitudeX
		v[2] = v[2] - magnitudeY
	end
	
	for i,v in ipairs(self.longTrail) do
		v[1] = v[1] - magnitudeX
		v[2] = v[2] - magnitudeY
	end
	
	for i,v in ipairs(self.longerTrail) do
		v[1] = v[1] - magnitudeX
		v[2] = v[2] - magnitudeY
	end
	
		
	table.insert(self.trail, 1, {self.x, self.y} )
	table.insert(self.longTrail, 1, {self.x, self.y} )
	table.insert(self.longerTrail, 1, {self.x, self.y} )	
end

function Comet:getPos()
	return self.x,self.y
end

function Comet:setPos(xpos,ypos)
	local deltaX = self.x - xpos
	local deltaY = self.y - ypos
	self.x = xpos
	self.y = ypos
	for i,v in ipairs(self.longTrail) do
		v[1] = v[1] - deltaX
		v[2] = v[2] - deltaY
	end
	for i,v in ipairs(self.longerTrail) do
		v[1] = v[1] - deltaX
		v[2] = v[2] - deltaY
	end
	for i,v in ipairs(self.trail) do
		v[1] = v[1] - deltaX
		v[2] = v[2] - deltaY
	end
end

function Comet:setScale(value)
	self.scale = value
end

function Comet:draw()		
	local lastx = self.x
	local lasty = self.y
	
	local r,g,b = unpack(Comet.COLOR3)

	local size = (self.size)
	local trailLength = #self.longerTrail
	love.graphics.setLineStyle("rough")
	for index,value in pairs(self.longerTrail) do
		local i = (trailLength-index)		
		local trailSize = (size/trailLength)*i
		
		love.graphics.setColor(r,g,b,(255/trailLength)*i)
		love.graphics.setLineWidth(trailSize)

		love.graphics.line(value[1],value[2],lastx,lasty)
		lastx = value[1]
		lasty = value[2]
	end
	
	lastx = self.x
	lasty = self.y
	
	love.graphics.setColor(Comet.COLOR2)
	
	local size = (self.size + 2)* 2
	local trailLength = #self.longTrail
	love.graphics.setLineStyle("rough")
	for index,value in pairs(self.longTrail) do
		local i = (trailLength-index)		
		local trailSize = (size/trailLength)*i
		
		love.graphics.setLineWidth(trailSize)
		love.graphics.line(value[1],value[2],lastx,lasty)
		lastx = value[1]
		lasty = value[2]
	end
	
	local velDirection = math.atan2(vel.x ,vel.y)+math.pi/2		-- atan2 = math.atan() - math.pi/2
	local mag2d = vel.x*vel.x+vel.y*vel.y
	local factor = common:mapValue(mag2d,0,400^2,0,2)  

	love.graphics.push()
	love.graphics.translate(self.x,self.y)
	love.graphics.rotate(velDirection)
	love.graphics.ellipse("fill", 0, 0,self.size+3+factor,self.size+2)
	love.graphics.setColor(Comet.COLOR1)	
	love.graphics.ellipse("fill", 0, 0,self.size+factor,self.size)
	love.graphics.pop()
	
	lastx = self.x
	lasty = self.y
	
	size = self.size+1
	trailLength = #self.trail
	for index,value in pairs(self.trail) do
		local i = (trailLength-index)		
		local trailSize = (size/trailLength)*i

		love.graphics.setLineWidth(trailSize)
		love.graphics.line(value[1],value[2],lastx,lasty)
	
		lastx = value[1]
		lasty = value[2]	
	end
	love.graphics.setLineWidth(1)
end

return Comet
