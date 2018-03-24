
local Comet = class('Comet')
--	 I'M A SHOOTING STAR!

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

function Comet:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or Comet.CENTERX
	self.y = attributes.y or Comet.CENTERY

	self.size = Comet.static.SIZE

	self.vel = {x = 300, y = 10}

	self.trail = {}
	table.insert(self.trail, #self.trail, {self.x, self.y} )
end

function Comet:setAlpha(value)
	self.alpha = value
end

function Comet:update(dt)	-- Called only when drawing constellations
	self.x = self.x - (-self.vel.x * dt)
	self.y = self.y - (self.vel.y * dt)

	table.insert(self.trail, #self.trail, {self.x, self.y} )
	if (#self.trail > Comet.LONGERTRAIL_MAX) then
		table.remove(self.trail, 1)
	end
end

function Comet:getPos()
	return self.x,self.y
end

function Comet:setPos(xpos,ypos) -- slow af
	self.x = xpos
	self.y = ypos
	self.vel = {
		x = self.x - xpos,
		y = self.y - ypos
	}
end

function Comet:setScale(value)
	self.scale = value
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
	love.graphics.pop()
end

return Comet
