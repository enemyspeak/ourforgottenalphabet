
local ClusterManager = class('ClusterManager') -- star manager 2017

local Cluster = require 'obj/cluster'
local Arrow = require 'obj/arrow'

ClusterManager.static.COLOR1 = {255,255,255}
ClusterManager.static.MAX_DISTANCE = (4000)^2

ClusterManager.static.getRandomSigned = function(low,high)
	local temp = math.random(low,high)
	if math.random(1,2) == 1 then
		temp = -temp
	end
	return temp
end

function ClusterManager:initialize(attributes)
	local attributes = attributes or {}

    self.clusters = {}
    self.updateNearest = true
    
    self.arrowAlpha = 255
	self.timeout = 0
    self.arrow = Arrow:new({ x = 0, y = 0})
    self:createCluster(0,0) -- initial cluster
end

function ClusterManager:createCluster(targetx, targety)
    -- while whatever
    -- generate location
    local clusterX = math.floor(targetx + ClusterManager.getRandomSigned(1000,2000))
    local clusterY = math.floor(targety + ClusterManager.getRandomSigned(1000,2000))

    -- test overlap


    -- end
    -- add to array
    self.clusters[#self.clusters] = Cluster:new({
        x = clusterX,
        y = clusterY,
        radius = 200 + 4 * 9,
        numStars = math.floor(math.random(9,9 + #self.clusters))
    })
    self.arrow:setTarget(clusterX,clusterY)
end

function ClusterManager:update(dt, player)
	for i,v in ipairs(self.clusters) do -- this should only update the 'active' one.
		self.clusters[i]:update(player) -- star updates!
    end
    self.arrow:update()
    -- check if the player is still in here.
    -- if (!self.active) then return false end
	-- self.timeout = self.timeout + dt

	-- if self.timeout > 1 then
	-- 	if self:getState(cx,cy) then else
	-- 		return true
	--  	end
	-- end

	-- return false
end

function ClusterManager:draw()
    self.clusters[#self.clusters]:draw()
    self.arrow:draw()
end

return ClusterManager
