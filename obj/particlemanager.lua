
local ParticleManager = class('ParticleManager')

local Particle = require 'obj/particle'

ParticleManager.static.COLOR1 = {255,255,255}
ParticleManager.static.MAX_PARTICLES = 90

ParticleManager.static.getParticleAttributes = function()
	local n = math.random(1,8)
	if  n == 1 or  n == 2 then
		return 0.75, Particle.COLOR4
	elseif  n == 3 or  n == 4 then
		return 1.5, Particle.COLOR1
	elseif  n == 5 or  n == 8 then
		return 0.5, Particle.COLOR5
	elseif  n == 6 then
		return 1.25,Particle.COLOR2
	end
	return 1, Particle.COLOR3
end

function ParticleManager:initialize(attributes)
	local attributes = attributes or {}
	self.x = 0 or attributes.x
	self.y = 0 or attributes.y
	self.particles = {}
	for i = 1, ParticleManager.MAX_PARTICLES do
		local speed, color = ParticleManager.getParticleAttributes()
		self.particles[i] = Particle:new({
			x = math.random(self.x - CENTERX * 3, self.x + CENTERX * 1),
			y = math.random(self.y - CENTERY * 3, self.y + CENTERY * 1),
			speed = speed,
			color = color
		})
	end
end

function ParticleManager:update(dt, vel, camera, scale)
	for i,v in ipairs(self.particles) do
		self.particles[i]:update(dt,vel, camera, scale)
	end
end

function ParticleManager:draw()
	for i,v in ipairs(self.particles) do
		self.particles[i]:draw()
	end
end

return ParticleManager
