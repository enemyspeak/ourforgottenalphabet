
local StarManager = class('StarManager') -- star manager 2017

local Star = require 'obj/star'

StarManager.static.COLOR1 = {255,255,255}
StarManager.static.MAX_STARS = 15
StarManager.static.MAX_DISTANCE = (CENTERX*2)^2

function StarManager:initialize(attributes)
	local attributes = attributes or {}
	self.x = 0 or attributes.x
	self.y = 0 or attributes.y
	self.stars = {}
	for i = 1, StarManager.MAX_STARS do
		self.stars[i] = Star:new({
			x = math.random(self.x - CENTERX * 3, self.x + CENTERX * 1),
			y = math.random(self.y - CENTERY * 3, self.y + CENTERY * 1),
			typ = math.random(1,6)
		})
	end
end

function StarManager:update(camera, player)
	if self.nearestStar then
		self.stars[self.nearestStar].highlighted = false
	end
	self.nearestStar = nil
	local closestStar = StarManager.MAX_DISTANCE
	for i,v in ipairs(self.stars) do
		self.stars[i]:update(camera)
		local starDistance = (self.stars[i].x - player.x+ CENTERX )^2 + (self.stars[i].y - player.y + CENTERY)^2
		if starDistance < closestStar then
			closestStar = starDistance
			self.nearestStar = i
		end
	end
	self.stars[self.nearestStar].highlighted = true
end

function StarManager:getClosestStar() 
	return self.stars[self.nearestStar]
end

function StarManager:draw()
	lg.push()
	lg.translate(CENTERX,CENTERY)
		for i,v in ipairs(self.stars) do
			self.stars[i]:draw()
		end
	lg.pop()
end

return StarManager
