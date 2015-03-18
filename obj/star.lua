		
local Star = class('Star')

Star.static.SAFEZONE = 64		 --this is a class variable
Star.static.KILLZONE = 256

Star.static.COLOR1 = {13,44,64}		-- Black on cluster
Star.static.COLOR2 = {235,165,118} 	-- Highlight
Star.static.COLOR3 = {255,255,255}	-- Normal
Star.static.COLOR4 = {100,212,255}	-- Star variation color

--[[
Star.static.COLOR1 = {0,0,38}		-- Alternate black on cluster
Star.static.COLOR2 = {255,0,0} 		-- Alternate highlight
--]]
				 
Star.static.CENTERX = IRESX/2
Star.static.CENTERY = IRESY/2
Star.static.STAR1 = love.graphics.newImage("res/star1.png")
Star.static.STAR2 = love.graphics.newImage("res/star2.png")
Star.static.STAR3 = love.graphics.newImage("res/star3.png")
Star.static.STAR4 = love.graphics.newImage("res/star4.png")
Star.static.STAR5 = love.graphics.newImage("res/star5.png")
Star.static.STAR6 = love.graphics.newImage("res/star6.png")

function Star:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or love.graphics.getWidth() + Star.SAFEZONE
	self.y = attributes.y or love.graphics.getHeight() + Star.SAFEZONE
	self.typ = attributes.typ or Star.STAR1
	self.scale = 1
	self.constellation =  false	
	self.alt = attributes.alt or false

	if attributes.constellation == true then
		self.constellation = true
		self.f = false
		self.l = false
	end

	self.finished = false
end

function Star:setL(value)
	self.l = value
end

function Star:setF(value)
	self.f = value
end

function Star:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Star:getL()
	return self.l
end

function Star:getF()
	return self.f
end

function Star:update(dt,value)	
	local value = value or false
	self.x = self.x + -vel.x * dt
	self.y = self.y + vel.y * dt

	if value then else
		local cull = (Star.CENTERX + Star.KILLZONE)
		if self.x < -cull or self.x  > cull then
			self.finished = true
		end
		cull = (Star.CENTERY + Star.KILLZONE)
		if self.y < -cull or self.y  > cull then
			self.finished = true
		end
	end
end

function Star:isOnScreen()
	self.onScreen = false
	if self.x < Star.CENTERX+4 and self.x > -Star.CENTERX-4 then
		if self.y < Star.CENTERY+4 and self.y > -Star.CENTERY-4 then
			self.onScreen = true
		end
	end
	return self.onScreen
end

function Star:getKill()
	if self.constellation then
		return false		-- NO!
	else
		return self.finished
	end
end

function Star:setKill(value)
	self.finished = value
end

function Star:getConstellation()
	return self.constellation
end

function Star:getDistance(x,y)
	if x == nil or y == nil then 
		return (self.x)^2+(self.y)^2
	else
		return (self.x-x)^2+(self.y-y)^2
	end
end

function Star:getPos()
	return self.x, self.y
end

function Star:draw(value,s)
	local scale = s or 1

	if value then
		love.graphics.setColor(unpack(Star.COLOR2))	-- highlight
		love.graphics.circle("fill",math.floor(self.x)*scale,math.floor(self.y)*scale,5)	
		love.graphics.setColor(unpack(Star.COLOR3))	-- normal, probably
	elseif value == false then
		love.graphics.setColor(unpack(Star.COLOR1))	-- probably outside of a cluster- black on white
	else
		love.graphics.setColor(unpack(Star.COLOR3))	-- normal, probably
	end
	if self.alt then
		love.graphics.setColor(unpack(Star.COLOR4)) -- Color variation override
	end
	if scale < 0.78 then
		--[[
		local n = love.graphics.getPointSize()
		love.graphics.setPointSize(2)
		love.graphics.point(math.floor(self.x)+0.5,math.floor(self.y)+0.5)
		love.graphics.setPointSize(n)
		--]]
		--love.graphics.draw(Star.STAR5,math.floor(self.x),math.floor(self.y),0,1/scale,1/scale,2,2)
	else
		--love.graphics.draw(self.typ,math.floor(self.x),math.floor(self.y),0,self.scale,self.scale,2,2)
	end
		love.graphics.draw(self.typ,math.floor(self.x)*scale,math.floor(self.y)*scale,0,self.scale,self.scale,2,2)
end

return Star
