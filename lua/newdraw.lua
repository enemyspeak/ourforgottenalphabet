
local NewDraw = Gamestate:addState('NewDraw')

-- load some files
local Comet = require 'obj.comet'
local ParticleManager = require 'obj.particlemanager'
local StarManager = require 'obj.starmanager'
local ClusterManager = require 'obj.clustermanager'

-- define some constants
local CAMERA_LERP_TIME = 0.025
local CAMERA_LOW_TIME = 0.08
local CAMERA_HIGH_TIME = 0.4

-- define some singletons
local player, particleManager, starManager, clusterManager

-- define some values
local camera = {
  x = CENTERX,
  y = CENTERY
}
local drawScale = 1
-- local velocityDampen = 0
-- local velocityMagnitude = 0
local cameraLerpTime = CAMERA_HIGH_TIME
local currentCameraLerpTime = CAMERA_HIGH_TIME

-- define some functions
local lerp = function(from, to, t)
  return t < 0.5 and from + (to-from)*t or to + (from-to)*(1-t)
end
local map = function(value,low,high,mapLow,mapHigh)
	return (((mapHigh - mapLow) * (value / (high - low))) + mapLow)
end

function NewDraw:enteredState()
  -- create singletons
  player = Comet:new({ x = 0, y = 0 })
  particleManager = ParticleManager:new()
  starManager = StarManager:new()
  clusterManager = ClusterManager:new()
end

function NewDraw:update(dt)
  -- player
  player:update(dt)

  -- camera
  local previousCameraX = camera.x
  local previousCameraY = camera.y

  -- local currentVelocityMagnitude = math.atan2(player.vel.x,player.vel.y)+math.pi/2
  -- -- velocityDampen = lerp(velocityDampen,velocityDiff,LERP_TIME) -- 25 to 0
  -- local velocityDampen = math.abs(currentVelocityMagnitude - velocityMagnitude)
  -- velocityMagnitude = currentVelocityMagnitude
  -- if velocityDampen > 0.1 then velocityDampen = 0.1 end
  -- local currentCameraLerpTime = map(math.abs(velocityDampen), 0, 0.1, 0.25, 0.95)
  -- if currentCameraLerpTime < 0.01 then currentCameraLerpTime = 0.01 end -- clip

  -- lerp
  cameraLerpTime = lerp(cameraLerpTime,currentCameraLerpTime,CAMERA_LERP_TIME) -- 25 to 0
  camera.x = lerp(camera.x, -player.x + CENTERX/drawScale, cameraLerpTime)
  camera.y = lerp(camera.y, -player.y + CENTERY/drawScale, cameraLerpTime)
  -- dont lerp
  -- camera.x = -player.x + CENTERX/drawScale
  -- camera.y = -player.y + CENTERY/drawScale

  -- managers
  particleManager:update(dt, { x = camera.x - previousCameraX, y = camera.y - previousCameraY }, camera)
  starManager:update(camera, { x = player.x, y = player.y })
  clusterManager:update()
end

function NewDraw:draw()
  love.graphics.push()
    lg.scale(drawScale)
    love.graphics.translate(camera.x,camera.y)
      particleManager:draw(camera.x,camera.y)
      starManager:draw()
      player:draw()
  love.graphics.pop()
end

function NewDraw:keypressed()
  -- todo check gamestate..
  if starManager.nearestStar == nil then else
    local star = starManager:getClosestStar()
    player:keypressed({ x = star.x + CENTERX, y = star.y + CENTERY })
    starManager:keypressed()
    currentCameraLerpTime = CAMERA_LOW_TIME
  end
end

function NewDraw:keyreleased()
  player:keyreleased()
  starManager:keyreleased()
  currentCameraLerpTime = CAMERA_HIGH_TIME
end

-- get difference of vel to previous
-- lerp difference value to smooth
-- closer to 0, adjust the lerp speed of camera to catch up to straight lines, lag more on orbits
