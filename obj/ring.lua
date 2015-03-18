		
local Ring = class('Ring')

Ring.static.COLOR = {182,184,195}
Ring.static.COLOR1 = {136,142,179}

function Ring:initialize(attributes)
	local attributes = attributes or {}
	self.x =  attributes.X1 or 0
	self.y =  attributes.Y1 or 0
	self.x1 = attributes.X1 or 0
	self.y1 = attributes.Y1 or 0
	self.x2 = attributes.X2 or 0
	self.y2 = attributes.Y2 or 0
	self.distance = attributes.distance or 1
	self.r = attributes.r or 0
	self.pos = attributes.pos or 0
	self.alpha = attributes.alpha or 255
	self.finished = false
	self.isOpening = attributes.open or true
	self.isClosing = attributes.close or false
	self.canHide = attributes.hide or 0
	self.hidden = false
end

function Ring:getPos()
	return self.x,self.y
end

function Ring:setDistance(value)
	self.distance = value
end

function Ring:setHidden(value)
	local v = value or 0
	if self.canHide < v then
		self.hidden = true
	else
		self.hidden = false
	end
	
	if v == -1 then
		self.hidden = true
	end
end

function Ring:setCometPos(X,Y)
	self.x1 = X
	self.y1 = Y
end

function Ring:setStarPos(X,Y)
	self.x2 = X
	self.y2 = Y
end

function Ring:update(dt)
	local speed = dt/5

	if self.hidden then
		self.alpha = self.alpha - 30
		if self.alpha < 0 then
			self.alpha = 0
		end
	else
--		self.alpha = self.alpha + 17
		self.alpha = self.alpha + 30
		if self.alpha > 255 then
			self.alpha = 255
		end
	end
	
	if self.isOpening then
		self.x = self.x1
		self.y = self.y1
		self.pos = self.pos + speed --0.004
		self.r = self.distance * self.pos
		if self.pos > 0.50 then
			self.isOpening = false
			self.isClosing = true
		end
	end
	
	if self.isClosing then
		self.isOpening = false --Hack! Yaaay!
		self.x = self.x2
		self.y = self.y2
		self.pos = self.pos - speed
		self.r = self.distance * self.pos
		if self.r < 0 or self.r == 0 then 			--	self.r < 64
			self.finished = true
		end
	end
end

function Ring:getKill()
	return self.finished
end

function Ring:draw()
	if self.alpha == 0 then else
		r,g,b = unpack(Ring.COLOR1)
		love.graphics.setColor(r,g,b,self.alpha)
		love.graphics.setLineStyle("rough")
		love.graphics.setLineWidth(1)
		love.graphics.circle("line",self.x,self.y,self.r)
	end
end

return Ring



--[[




]]