
local ClusterTest = Gamestate:addState('ClusterTest')

local Comet = require 'obj.comet'
local ParticleManager = require 'obj.particlemanager'
local StarManager = require 'obj.starmanager'
local Cluster = require 'obj.cluster'

-- define some constants
local LERP_TIME = 0.05

-- define some singletons
local player, particleManager, starManager

-- define some values
local camera = {
  x = CENTERX,
  y = CENTERY,
  scale = 1
}

local lerp = function(from, to, t)
  return t < 0.5 and from + (to-from)*t or to + (from-to)*(1-t)
end

function ClusterTest:enteredState()
  -- create singletons
  player = Comet:new({ x = 0, y = 0 })
  particleManager = ParticleManager:new()
  starManager = StarManager:new()
  cluster = Cluster:new({ x = 0, y = 0 })
end

function ClusterTest:update(dt)
  player:update(dt)

  local previousCameraX = camera.x
  local previousCameraY = camera.y

  camera.scale = lerp(camera.scale, (HEIGHT-10)/(cluster.radius*2), LERP_TIME)

  -- lerp camera to cluster.
  camera.x = lerp(camera.x, -cluster.x + CENTERX/camera.scale, LERP_TIME)
  camera.y = lerp(camera.y, -cluster.y + CENTERY/camera.scale, LERP_TIME)
  -- lerp camera
  -- camera.x = lerp(camera.x, -player.x + CENTERX/drawScale, LERP_TIME)
  -- camera.y = lerp(camera.y, -player.y + CENTERY/drawScale, LERP_TIME)
  -- dont lerp
  -- camera.x = -player.x + CENTERX/drawScale
  -- camera.y = -player.y + CENTERY/drawScale


  particleManager:update(dt, { x = camera.x - previousCameraX, y = camera.y - previousCameraY }, camera)
  starManager:update(camera, { x = player.x, y = player.y })
  cluster:update(player.x, player.y, dt)
end

function ClusterTest:draw()
  love.graphics.push()
    lg.scale(camera.scale)
    love.graphics.translate(camera.x,camera.y)
      particleManager:draw(camera.x,camera.y)
      starManager:draw(camera.scale, true)
      player:draw()
      cluster:draw(camera.scale, player.x, player.y)
  love.graphics.pop()
end

function ClusterTest:keypressed()
  -- todo check gamestate..
  if starManager.nearestStar == nil then else
    local star = starManager:getClosestStar()
    player:keypressed({ x = star.x + CENTERX, y = star.y + CENTERY })
    starManager:keypressed()
  end
end

function ClusterTest:keyreleased()
  player:keyreleased()
  starManager:keyreleased()
end

-- get difference of vel to previous
-- lerp difference value to smooth
-- closer to 0, adjust the lerp speed of camera to catch up to straight lines, lag more on orbits
