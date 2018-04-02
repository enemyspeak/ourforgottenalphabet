
local Star = class('Star')

Star.static.KILLZONEX = CENTERX * 2
Star.static.KILLZONEY = CENTERY * 2
Star.static.SAFEZONE = 50

Star.static.COLOR1 = {13,44,64}		-- Black on cluster
Star.static.COLOR2 = {235,165,118} 	-- Highlight
Star.static.COLOR3 = {255,255,255}	-- Normal
Star.static.COLOR4 = {100,212,255}	-- Star variation color

--[[
Star.static.COLOR1 = {0,0,38}		-- Alternate black on cluster
Star.static.COLOR2 = {255,0,0} 		-- Alternate highlight
--]]

Star.static.types = {
    [ 1 ] = love.graphics.newImage("res/star1.png"),
    [ 2 ] = love.graphics.newImage("res/star2.png"),
    [ 3 ] = love.graphics.newImage("res/star3.png"),
    [ 4 ] = love.graphics.newImage("res/star4.png"),
    [ 5 ] = love.graphics.newImage("res/star5.png"),
    [ 6 ] = love.graphics.newImage("res/star6.png")
}

function Star:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or 0
	self.y = attributes.y or 0
  self.typ = attributes.typ or 1 -- Star.types[attributes.typ]
	self.scale = 1
	self.constellation =  false
    self.alt = attributes.alt or false
	self.highlighted = false

	if attributes.constellation == true then
		self.constellation = true
		self.f = false
		self.l = false
	end
end

function Star:update(camera)
	if self.constellation then return end

	if self.x <  ((-camera.x) - Star.KILLZONEX) then
		self.x = ((-camera.x) + (Star.KILLZONEX - Star.SAFEZONE))
	end
	if self.x  > ((-camera.x) + Star.KILLZONEX) then
		self.x = ((-camera.x) - (Star.KILLZONEX - Star.SAFEZONE))
	end
	if self.y <  ((-camera.y) - Star.KILLZONEY) then
		self.y = ((-camera.y) + (Star.KILLZONEY - Star.SAFEZONE))
	end
	if self.y  > ((-camera.y) + Star.KILLZONEY) then
		self.y = ((-camera.y) - (Star.KILLZONEY - Star.SAFEZONE))
	end
end

function Star:setL(value)
end

function Star:setF(value)
end

function Star:draw(value)
	local scale = 1 -- todo
	if self.highlighted then
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
	-- if scale < 0.78 then
	-- 	--[[
	-- 	local n = love.graphics.getPointSize()
	-- 	love.graphics.setPointSize(2)
	-- 	love.graphics.point(math.floor(self.x)+0.5,math.floor(self.y)+0.5)
	-- 	love.graphics.setPointSize(n)
	-- 	--]]
	-- 	--love.graphics.draw(Star.STAR5,math.floor(self.x),math.floor(self.y),0,1/scale,1/scale,2,2)
	-- else
		--love.graphics.draw(self.typ,math.floor(self.x),math.floor(self.y),0,self.scale,self.scale,2,2)
    -- end
    love.graphics.draw(Star.types[self.typ],math.floor(self.x)*scale,math.floor(self.y)*scale,0,self.scale,self.scale,2,2)
end

return Star
