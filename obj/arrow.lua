local Arrow = class('Arrow') -- star manager 2017

Arrow.static.ARROW_INSET = 30
Arrow.static.C_DIRECTION = math.atan2(WIDTH-(2*Arrow.ARROW_INSET),HEIGHT-(2*Arrow.ARROW_INSET))
Arrow.static.ARROW = love.graphics.newImage("res/arrow2.png")
Arrow.static.FADE_DISTANCE = 220
Arrow.static.FADE_TIME = 120

function Arrow:initialize(attributes)
    local attributes = attributes or {}
    self.x = 0
    self.y = 0
    self.direction = 0
	self.alpha = 255
	self.targetPosition = { x = 0, y = 0 }
	self.targetRadius = 2000
	self.fade = false
end

function Arrow:setTarget(x,y)
	self.targetPosition = { x = x, y = y }
end

function Arrow:update(dt)
	local t
	self.direction = math.atan2(
		self.targetPosition.y - cometPosition.y,
		self.targetPosition.x - cometPosition.x
	)+math.pi/2
		
	if self.direction > Arrow.C_DIRECTION and self.direction < -Arrow.C_DIRECTION+math.rad(180)  then		-- This only works if it's square NOPE FIXED
		t = (CENTERX-Arrow.ARROW_INSET - cometPosition.x)/(self.targetPosition.x - cometPosition.x) 
	elseif self.direction > -Arrow.C_DIRECTION and self.direction < Arrow.C_DIRECTION then	--	if tempY > 0 then
		t = (-CENTERY+Arrow.ARROW_INSET - cometPosition.y)/(self.targetPosition.y - cometPosition.y)
	elseif self.direction > -Arrow.C_DIRECTION + math.rad(180) and self.direction < Arrow.C_DIRECTION + math.rad(180) then	--	if tempY > 0 then
		t = (CENTERY-Arrow.ARROW_INSET - cometPosition.y)/(self.targetPosition.y - cometPosition.y)
	else
		t = (-CENTERX+Arrow.ARROW_INSET - cometPosition.x)/(self.targetPosition.x - cometPosition.x)
	end
	
	self.x = (self.targetPosition.x - cometPosition.x) * t + cometPosition.x
	self.y = (self.targetPosition.y - cometPosition.y) * t + cometPosition.y
	
	local sqdist = ((self.targetPosition.x+CENTERX)-self.x) ^ 2 + ((self.targetPosition.y+CENTERY)-self.y) ^ 2 -- Within Circle (x-a)^2 + (y-b)^2 = r ^2

	if sqdist < (self.targetRadius + Arrow.FADE_DISTANCE) ^ 2 then	
			
	else

	end
end

function Arrow:draw()
    love.graphics.setColor(255,255,255,self.alpha)
    love.graphics.draw(graphics["arrow"],self.x,self.y,self.direction,0.5,0.5,32*.75,32*.75)
end

return Arrow