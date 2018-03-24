
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
	self.active = false;
	self.outerRadius = 0
	self.innerRadius = 0
	self.hidden = false
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

function Cluster:setActive(value)
	if (self.active == value) then return end
	self.active = value
	if (self.active) then
		tween(0.45, self, { innerRadius = self.radius - 5 }, "outQuad", -- the -5 here is to pad the edges for the player.
			tween, 1, self, { outerRadius = WIDTH }, "inQuad"
		)
	else
		tween( 1, self, { innerRadius = WIDTH, outerRadius = WIDTH + 10 }, "inBack", self:setHidden())
	end
end

function Cluster:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Cluster:setRadius(value)
	self.radius = value
end

function Cluster:update(cx,cy,dt)
	if (!self.active) then return false end
	clusterClock = clusterClock + dt

	if clusterClock > 1 then
		if self:getState(cx,cy) then else
			return true
	 	end
	end

	return false
end

function Cluster:debugDraw()
	love.graphics.setColor(unpack(Cluster.COLOR1))
	love.graphics.circle("line",0.5+math.floor(self.x),0.5+math.floor(self.y),self.radius)
end

function Cluster:draw(cx,cy)
	love.graphics.setColor(unpack(Cluster.COLOR1))

	if (self.active) then
		local ClusterStencil = function()
			love.graphics.circle("fill",cx,cy,clusterTween.innerRadius)
		end

		love.graphics.stencil(ClusterStencil, "replace", 1)
	  love.graphics.setStencilTest("less", 1)

			love.graphics.setColor(colors["cluster"])
			love.graphics.circle("fill",self.x,self.y,cluster:getRadius()+clusterTween.outerRadius)

			love.graphics.setStencilTest()
	else
		love.graphics.circle("fill",0.5+math.floor(self.x),0.5+math.floor(self.y),self.radius)
	end
end

return Cluster
