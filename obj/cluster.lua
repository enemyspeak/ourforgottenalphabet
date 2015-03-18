		
local Cluster = class('Cluster')

Cluster.static.CENTERX = love.graphics.getWidth()/2
Cluster.static.CENTERY = love.graphics.getHeight()/2
Cluster.static.COLOR1 = {255,255,255}

function Cluster:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x
	self.y = attributes.y
	self.numStars = attributes.numStars or 7
	self.radius = attributes.radius or 620
	self.n = attributes.number or 1
end

function Cluster:update(dt)	
	self.x = self.x + -vel.x * dt
	self.y = self.y + vel.y * dt
end

function Cluster:getState(xpos,ypos, value) 
	local value = value or 0
	local temp = false
	if ( self.x - xpos ) ^ 2 + ( self.y - ypos ) ^ 2 < (self.radius - value) ^ 2 then		-- Within Circle (x-a)^2 + (y-b)^2 = r ^2
		temp = true
	end
	return temp
end

function Cluster:getFastState(xpos,ypos, v) 
	if v == nil then
		value = 0
	else
		value = v
	end
	local temp = false
	if ( self.x + self.radius - value > xpos) and ( self.x - self.radius - value < xpos) and  ( self.y + self.radius - value > ypos) and ( self.y - self.radius - value < ypos) then
		temp = true
	end
	return temp
end

function Cluster:getNumStars()
	return self.numStars
end

function Cluster:getNumber()
	return self.n
end

function Cluster:getPos()
	return self.x,self.y
end

function Cluster:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Cluster:getRadius()
	return self.radius
end

function Cluster:setRadius(value)
	self.radius = value
end

function Cluster:debugDraw()
	love.graphics.setColor(unpack(Cluster.COLOR1))
	love.graphics.circle("line",0.5+math.floor(self.x),0.5+math.floor(self.y),self.radius)
end

function Cluster:draw()
	love.graphics.setColor(unpack(Cluster.COLOR1))
	love.graphics.circle("fill",0.5+math.floor(self.x),0.5+math.floor(self.y),self.radius)
end

return Cluster
