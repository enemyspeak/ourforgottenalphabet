
local Comet = class('Comet')
--	 I'M A SHOOTING STAR!

local OrbitManager = require('obj.orbitmanager')

Comet.static.WIDTH = IRESX
Comet.static.HEIGHT = IRESY
Comet.static.CENTERX = Comet.WIDTH/2
Comet.static.CENTERY = Comet.HEIGHT/2

Comet.static.SIZE = 2
Comet.static.scale = 1 -- dont use
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

Comet.static.createStencil = function ()
	love.graphics.rectangle("fill",0,-3/2,20,3)
end

Comet.static.magnitude_2d = function (x, y)
	return math.sqrt(x*x + y*y)
end

Comet.static.normalize_2d = function (x, y)
	local mag = Comet.magnitude_2d(x, y)
	if mag == 0 then return {0,0} end
	return {x/mag, y/mag}
end

Comet.static.magnitude_2d_sq = function (x, y)
	return x*x + y*y
end

function Comet:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or Comet.CENTERX
	self.y = attributes.y or Comet.CENTERY

	self.size = Comet.static.SIZE
	self.vel = {x = 30, y = 10}
	self.trail = {}

	self.accel = 0

	self.orbitingStar = false
	self.orbitPoint = {x = 0, y = 0}

	self.orbitManager = OrbitManager:new()
	table.insert(self.trail, #self.trail, {self.x, self.y} )
end

function Comet:update(dt)	-- Called only when drawing constellations
	self.x = self.x - (-self.vel.x * dt)
	self.y = self.y - (self.vel.y * dt)

	table.insert(self.trail, #self.trail, {self.x, self.y} )
	if (#self.trail > Comet.LONGERTRAIL_MAX) then
		table.remove(self.trail, 1)
	end

	if self.orbitingStar then
		self:doOrbit(dt)
	else
		self.accel = 0 -- reset?
	end
end

function Comet:doOrbit(dt)
	local interval = 0.2
	local orbitDirection = math.atan2(self.x - self.orbitPoint.x , self.y - self.orbitPoint.y)+math.pi/2		-- atan2 = math.atan() - math.pi/2
	local normal_acceleration = 18
	local temp_norm_accel = Comet.normalize_2d((math.cos(orbitDirection)),(math.sin(orbitDirection)))

	local temp_x_accel = temp_norm_accel[1] * normal_acceleration * self.accel
	local temp_y_accel = temp_norm_accel[2] * normal_acceleration * self.accel
	local max_accel = 1

	self.accel = self.accel + dt * 30
	if self.accel > max_accel then
		self.accel = max_accel
	end

	local temp_x_vel = self.vel.x
	local temp_y_vel = self.vel.y

	temp_x_vel = temp_x_vel + temp_x_accel
	temp_y_vel = temp_y_vel + temp_y_accel

	local temp_vel = Comet.magnitude_2d_sq(temp_x_vel, temp_y_vel)

	self.vel = {x = temp_x_vel, y = temp_y_vel}

	-- update rings
end

function Comet:draw()
	local r,g,b = unpack(Comet.COLOR3)
	local trailLength = #self.trail

	local velDirection = math.atan2(self.vel.x ,self.vel.y)+math.pi/2		-- atan2 = math.atan() - math.pi/2
	local mag2d = self.vel.x*self.vel.x+self.vel.y*self.vel.y
	local factor = common:mapValue(mag2d,0,400^2,0,2)

	local nextX, nextY

	lg.push()
	lg.scale(Comet.scale)

	love.graphics.push()
	love.graphics.translate(self.x,self.y)
	love.graphics.rotate(velDirection)
			love.graphics.setColor(Comet.COLOR2)
			love.graphics.ellipse("fill", 0, 0,self.size+3+factor,self.size+2)
	love.graphics.pop()

	for index,value in pairs(self.trail) do
		if (index == #self.trail) then
			value[1] = self.x
			value[2] = self.y
		end
		if (index == 1) then
			nextX = value[1]
			nextY = value[2]
		else
			love.graphics.setColor(r,g,b,(255/trailLength)*index)
			love.graphics.setLineWidth((self.size/trailLength)*index)
			love.graphics.line(value[1],value[2],nextX,nextY)

			if index > trailLength - Comet.LONGTRAIL_MAX then
				local i = index - (trailLength - Comet.LONGTRAIL_MAX)
				love.graphics.setColor(Comet.COLOR2)
				love.graphics.setLineWidth( ( (self.size + 2) * 2 / Comet.LONGTRAIL_MAX ) * i)
				love.graphics.line(value[1],value[2],nextX,nextY)
			end

			if (index > trailLength - Comet.TRAIL_MAX) then
				local i = index - (trailLength - Comet.TRAIL_MAX)
				love.graphics.setColor(Comet.COLOR1)
				love.graphics.setLineWidth(( (self.size + 1) / Comet.TRAIL_MAX) * i)
				love.graphics.line(value[1],value[2],nextX,nextY)
			end

			nextX = value[1]
			nextY = value[2]
		end
	end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(Comet.COLOR1)

	love.graphics.push()
	love.graphics.translate(self.x,self.y)
	love.graphics.rotate(velDirection)
		love.graphics.stencil(Comet.createStencil, "replace", 1)
		love.graphics.setStencilTest("less", 1)
			love.graphics.setColor(Comet.COLOR2)
			love.graphics.ellipse("fill", 0, 0,self.size+3+factor,self.size+2)
		love.graphics.setStencilTest()

		love.graphics.setColor(Comet.COLOR1)
		love.graphics.ellipse("fill", 0, 0,self.size+factor,self.size)

	love.graphics.pop()

	if self.orbitingStar then
		self:drawOrbit()
	end

	love.graphics.pop()
end

function Comet:drawOrbit()
	-- debug
	-- love.graphics.setColor(Comet.COLOR1)
	-- lg.line(self.orbitPoint.x, self.orbitPoint.y, self.x, self.y)
	self.orbitManager:draw({x = self.x, y = self.y }, self.orbitPoint)
end

function Comet:keypressed(orbitPoint)
	self.orbitPoint = orbitPoint
	self.orbitingStar = true
end

function Comet:keyreleased()
	self.orbitingStar = false
end

return Comet
