local Arrow = class('Arrow') -- star manager 2017

Arrow.static.ARROW_INSET = 30
Arrow.static.C_DIRECTION = math.atan2(WIDTH-(2*Arrow.ARROW_INSET),HEIGHT-(2*Arrow.ARROW_INSET))
Arrow.static.ARROW = love.graphics.newImage("res/arrow2.png")

function Arrow:initialize(attributes)
    local attributes = attributes or {}
    self.x = 0
    self.y = 0
    self.direction = 0
	self.alpha = 0
	self.targetPosition = { x = 0, y = 0 }
end

function Arrow:setTarget(x,y)
	self.targetPosition = { x = x, y = y }
end

function Arrow:update(dt)
	local C = 	{
				x = 0,
				y = 0
				}
	local tempX = self.targetPosition.x - C.x
	local tempY = self.targetPosition.y - C.y
	local t
	
	self.direction = math.atan2(tempY,tempX)+math.pi/2
		
	if self.direction > Arrow.C_DIRECTION and self.direction < -Arrow.C_DIRECTION+math.rad(180)  then		-- This only works if it's square NOPE FIXED
		t = (CENTERX-Arrow.ARROW_INSET - C.x)/(self.targetPosition.x - C.x) 
	elseif self.direction > -Arrow.C_DIRECTION and self.direction < Arrow.C_DIRECTION then	--	if tempY > 0 then
		t = (-CENTERY+Arrow.ARROW_INSET - C.y)/(self.targetPosition.y - C.y)
	elseif self.direction > -Arrow.C_DIRECTION + math.rad(180) and self.direction < Arrow.C_DIRECTION + math.rad(180) then	--	if tempY > 0 then
		t = (CENTERY-Arrow.ARROW_INSET - C.y)/(self.targetPosition.y - C.y)
	else
		t = (-CENTERX+Arrow.ARROW_INSET - C.x)/(self.targetPosition.x - C.x)
	end
	
	self.x = (self.targetPosition.x - C.x) * t + C.x
	self.y = (self.targetPosition.y - C.y) * t + C.y
	
	local cx,cy = clusters[clusterNumber]:getPos()
	local cr = clusters[clusterNumber]:getRadius()
	local sqdist = ((cx+CENTERX)-self.x) ^ 2 + ((cy+CENTERY)-self.y) ^ 2 -- Within Circle (x-a)^2 + (y-b)^2 = r ^2

	if sqdist < (cr+220) ^ 2 then		
		arrowAlpha = arrowAlpha - dt*120
		if arrowAlpha < 0 then
			arrowAlpha = 0
		end
	else
		arrowAlpha = arrowAlpha + dt*220
		if arrowAlpha > 255 then
			arrowAlpha = 255
		end
	end
end

function Arrow:draw()
    love.graphics.setColor(255,255,255,self.lpha)
    love.graphics.draw(graphics["arrow"],self.x,self.y,self.direction,0.5,0.5,32*.75,32*.75)
end

return Arrow