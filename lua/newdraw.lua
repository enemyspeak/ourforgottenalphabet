
local NewDraw = Gamestate:addState('NewDraw')

local Comet = require 'obj.comet'
local ParticleManager = require 'obj.particlemanager'
local StarManager = require 'obj.starmanager'

-- define some singletons
local player, particleManager, starManager

-- define some values
local vel = {
  x = 0,
  y = 0
}
local camera = {
  x = CENTERX,
  y = CENTERY
}

local lerp = function(from, to, t)
  return t < 0.5 and from + (to-from)*t or to + (from-to)*(1-t)
end

function NewDraw:enteredState()
  -- create singletons
  player = Comet:new({ x = 0, y = 0 })
  particleManager = ParticleManager:new()
  starManager = StarManager:new()

end

local drawScale = 1

function NewDraw:update(dt)
  local mx,my = love.mouse.getPosition()
  mx = mx -CENTERX
  my = my -CENTERY
  vel = { x = mx, y = -my }

  player.vel = vel

  player:update(dt)

  local previousCameraX = camera.x
  local previousCameraY = camera.y

  -- lerp camera
  camera.x = lerp(camera.x, -player.x + CENTERX/drawScale, 0.025)
  camera.y = lerp(camera.y, -player.y + CENTERY/drawScale, 0.025)
  -- dont lerp
  -- camera.x = -player.x + CENTERX/drawScale
  -- camera.y = -player.y + CENTERY/drawScale

  particleManager:update(dt, { x = camera.x - previousCameraX, y = camera.y - previousCameraY }, camera) -- this vel here is relative to the camera
  starManager:update(camera, { x = player.x, y = player.y }) -- this vel here is relative to the camera
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
