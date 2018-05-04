
local Cluster = class('Cluster')

local Star = require 'obj/star'

Cluster.static.CENTERX = love.graphics.getWidth()/2
Cluster.static.CENTERY = love.graphics.getHeight()/2
Cluster.static.COLOR1 = {255,255,255}

function Cluster:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x
	self.y = attributes.y
	self.numStars = attributes.numStars or 7
	self.radius = attributes.radius or 320
	self.n = attributes.number or 1
	self.active = false;
	self.outerRadius = 0
	self.innerRadius = 0
	self.hidden = false
	self.stars = {}
	self.clock = 0
end

function Cluster:createStars() -- star gen stuff here.
	local temp = {}

	local radius = self.radius * 0.75
	local distanceTest = (radius/(self.n/2))^2
	local interationCount = 0

	local value = true
	while value do
		temp = {}

		for i=1, self.n do
			local t = 2 * math.pi * math.random()
			local u = math.random(0,radius) + math.random(0,radius)

			local r
			if u > radius then
				r = (radius * 2) - u
			else
				r = u
			end

			if r > radius then
				r = 0
			end

			table.insert(temp, { x = self.x + r * math.cos(t), y = self.y + r * math.sin(t) })
		end

		value = false

		for k,s in ipairs(temp) do
			for i,v in ipairs(temp) do
				local distance = (s.x - v.x)^2 + (s.y - v.y)^2

				if distance == 0 then else
					if distance < distanceTest then
						value = true
					end
				end
			end
		end

		interationCount = interationCount + 1
		if interationCount > 500 then break end	 -- infinite loop failsafe
	end

	-- print("interationCount "..interationCount)

	for i,v in ipairs(temp) do
		local flag = false
		if i < #temp/2 then
			flag  = true
		end
		self.stars[#self.stars + 1] = Star:new({
			x = v.x,
			y = v.y,
			typ = math.random(1,6)
		})
	end
end

function Cluster:getState(xpos,ypos, value)
	local value = value or 0
	local temp = false
	if ( self.x - xpos ) ^ 2 + ( self.y - ypos ) ^ 2 < (self.radius - value) ^ 2 then		-- Within Circle (x-a)^2 + (y-b)^2 = r ^2
		temp = true
	end
	return temp
end

function Cluster:setHidden(value)
	self.hidden = value
end

function Cluster:setActive(value,cx,cy)
	-- TODO: hide other stars.
	-- TODO: make sure that other stars are hidden if they're overlapping.
	if (self.active == value) then return end
		self.active = value
	if (self.active) then
		self.innerTargetX = cx
		self.innerTargetY = cy
		tween(0.45, self, { innerRadius = self.radius - 5, innerTargetX = self.x, innerTargetY = self.y }, "outQuad", -- the -5 here is to pad the edges for the player.
			tween, 1, self, { outerRadius = WIDTH }, "inQuad"
		)
		self:createStars()
	else
		tween( 1, self, { innerRadius = WIDTH, outerRadius = WIDTH + 10 }, "inBack", self:setHidden())
	end
end

function Cluster:update(cx,cy,dt)
	if ( not self.active) then
		if self:getState(cx,cy) then
			self:setActive(true,cx,cy)
		end
	else
		self.clock = self.clock + dt

		if self.clock > 1 and not self:getState(cx,cy) then
			-- TODO: this should break drawing mode.
			self.active = false
			self:setActive(false,cx,cy)
		end
	end
end

function Cluster:debugDraw()
	love.graphics.setColor(unpack(Cluster.COLOR1))
	love.graphics.circle("line", self.x, self.y ,self.radius)
end

function Cluster:draw(cx,cy)
	love.graphics.setColor(unpack(Cluster.COLOR1))
	-- debug
	-- love.graphics.circle("line",0.5+math.floor(self.x),0.5+math.floor(self.y),self.radius)

	if (self.active) then
		local ClusterStencil = function()
			love.graphics.circle("fill", self.innerTargetX, self.innerTargetY, self.innerRadius)
		end

		love.graphics.stencil(ClusterStencil, "replace", 1)
	  love.graphics.setStencilTest("less", 1)

			-- self:debugDraw()
			love.graphics.setColor(colors["cluster"])
			love.graphics.circle("fill",self.x,self.y,self.radius+self.outerRadius)

		love.graphics.setStencilTest()
		love.graphics.setColor(unpack(Cluster.COLOR1))
	else
		love.graphics.circle("fill",0.5+math.floor(self.x),0.5+math.floor(self.y),self.radius)
	end
end

return Cluster
