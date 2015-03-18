		
local Particle = class('Particle')

Particle.static.SAFEZONE = 16 --this is a class variable
Particle.static.KILLZONE = 32

Particle.static.COLOR1 = {182,184,195}

Particle.static.COLOR2 = {167,163,170}
Particle.static.COLOR3 = {142,142,155}
Particle.static.COLOR4 = {116,121,139}
Particle.static.COLOR5 = {91,100,124}

Particle.static.CENTERX = love.graphics.getWidth()/2
Particle.static.CENTERY = love.graphics.getHeight()/2

function Particle:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or Particle.CENTERX + Particle.SAFEZONE
	self.y = attributes.y or Particle.CENTERY + Particle.SAFEZONE
	self.speed = attributes.speed or 1	
	self.color = attributes.color or Particle.COLOR1
	self.finished = false
	self.onScreen = attributes.onScreen or true
end

function Particle:update(dt)	
	self.x = self.x + (-vel.x * self.speed) * dt
	self.y = self.y + (vel.y * self.speed) * dt
	
	local kill = (Particle.CENTERX + Particle.KILLZONE)
	if self.x < -kill or self.x  > kill then
		self.finished = true
	end
	kill = (Particle.CENTERY + Particle.KILLZONE)
	if self.y < -kill or self.y  > kill then
		self.finished = true
	end
end

function Particle:getKill()
	return self.finished
end

function Particle:isOnScreen()
	self.onScreen = false
	if self.x < Particle.CENTERX+4 and self.x > -Particle.CENTERX-4 then
		if self.y < Particle.CENTERY+4 and self.y > -Particle.CENTERY-4 then
			self.onScreen = true
		end
	end
	return self.onScreen
end

function Particle:getPos()
	return self.x,self.y
end

function Particle:getSpeed()
	return self.speed
end

function Particle:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Particle:draw(value)
	local r,g,b = unpack(Particle.COLOR1)
	if value ~= nil then
		love.graphics.setColor(r,g,b,value)
	else
		love.graphics.setColor(r,g,b,255)
	end
	love.graphics.point(0.5+math.floor(self.x),0.5+math.floor(self.y))
end

return Particle
