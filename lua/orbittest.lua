
local OrbitTest = Gamestate:addState('OrbitTest')

local Comet = require 'obj.comet'
local ParticleManager = require 'obj.particlemanager'
local StarManager = require 'obj.starmanager'

-- define some constants
local LERP_TIME = 0.05

-- define some singletons
local player, particleManager, starManager

-- define some values
local camera = {
  x = CENTERX,
  y = CENTERY
}

local lerp = function(from, to, t)
  return t < 0.5 and from + (to-from)*t or to + (from-to)*(1-t)
end

function OrbitTest:enteredState()
  -- create singletons
  player = Comet:new({ x = 0, y = 0 })
  particleManager = ParticleManager:new()
  starManager = StarManager:new()
end

local drawScale = 0.8

function OrbitTest:update(dt)
  player:update(dt)

  local previousCameraX = camera.x
  local previousCameraY = camera.y

  -- lerp camera
  camera.x = lerp(camera.x, -player.x + CENTERX/drawScale, LERP_TIME)
  camera.y = lerp(camera.y, -player.y + CENTERY/drawScale, LERP_TIME)
  -- dont lerp
  -- camera.x = -player.x + CENTERX/drawScale
  -- camera.y = -player.y + CENTERY/drawScale

  particleManager:update(dt, { x = camera.x - previousCameraX, y = camera.y - previousCameraY }, camera, drawScale)
  starManager:update(camera, { x = player.x, y = player.y }, drawScale)
end

function OrbitTest:draw()
  love.graphics.push()
    lg.scale(drawScale)
    love.graphics.translate(camera.x,camera.y)
      particleManager:draw(camera.x,camera.y)
      starManager:draw(drawScale, false)
      player:draw()
  love.graphics.pop()
end

function OrbitTest:keypressed()
  -- todo check gamestate..
  if starManager.nearestStar == nil then else
    local star = starManager:getClosestStar()
    player:keypressed({ x = star.x*drawScale, y = star.y*drawScale })
    starManager:keypressed()
  end
end

function OrbitTest:keyreleased()
  player:keyreleased()
  starManager:keyreleased()
end

-- get difference of vel to previous
-- lerp difference value to smooth
-- closer to 0, adjust the lerp speed of camera to catch up to straight lines, lag more on orbits