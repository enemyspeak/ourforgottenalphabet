
Constellation = class('Constellation') 

function Constellation:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or love.graphics.getWidth() + Constellation.SAFEZONE
	self.y = attributes.y or love.graphics.getHeight() + Constellation.SAFEZONE
	self.l = false
	self.f = false
end

function Constellation:update(dt)	
	self.x = self.x + -vel.x * dt
	self.y = self.y + vel.y * dt
end

function Constellation:getPos()
	return self.x, self.y
end

function Constellation:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Constellation:setL(value)
	self.l = value
end

function Constellation:setF(value)
	self.f = value
end

function Constellation:getL()
	return self.l
end

function Constellation:getF()
	return self.f
end

return Constellation
