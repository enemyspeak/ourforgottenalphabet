
local Particle = class('Particle')

Particle.static.KILLZONEX = CENTERX * 2
Particle.static.KILLZONEY = CENTERY * 2
Particle.static.SAFEZONE = 50

Particle.static.COLOR1 = {182,184,195}
Particle.static.COLOR2 = {167,163,170}
Particle.static.COLOR3 = {142,142,155}
Particle.static.COLOR4 = {116,121,139}
Particle.static.COLOR5 = {91,100,124}

Particle.static.CENTERX = love.graphics.getWidth()/2 -- if you resize this, this value wont update.
Particle.static.CENTERY = love.graphics.getHeight()/2

Particle.static.PARALLAX = 20

function Particle:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x
	self.y = attributes.y
	self.speed = attributes.speed or 1
	self.color = attributes.color or Particle.COLOR1
	self.onScreen = true
end

function Particle:update(dt,vel,camera)
	if (self.speed == 1) then else
		self.x = self.x + (vel.x * self.speed * Particle.PARALLAX) * dt
		self.y = self.y + (vel.y * self.speed * Particle.PARALLAX) * dt
	end
	if self.x <  ((-camera.x) - Particle.KILLZONEX) then
		self.x = ((-camera.x) + (Particle.KILLZONEX - Particle.SAFEZONE))
	end
	if self.x  > ((-camera.x) + Particle.KILLZONEX) then
		self.x = ((-camera.x) - (Particle.KILLZONEX - Particle.SAFEZONE))
	end
	if self.y <  ((-camera.y) - Particle.KILLZONEY) then
		self.y = ((-camera.y) + (Particle.KILLZONEY - Particle.SAFEZONE))
	end
	if self.y  > ((-camera.y) + Particle.KILLZONEY) then
		self.y = ((-camera.y) - (Particle.KILLZONEY - Particle.SAFEZONE))
	end
end

function Particle:draw(value)
	local r,g,b = unpack(Particle.COLOR1)
	if (not self.onScreen) then return end
	if value ~= nil then
		love.graphics.setColor(r,g,b,value)
	else
		love.graphics.setColor(r,g,b,255)
	end
	love.graphics.points(math.floor(self.x),math.floor(self.y))
end

return Particle
