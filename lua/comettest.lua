
local CometTest = Gamestate:addState('CometTest')

local Comet = require 'obj.comet'
local player = Comet:new({ x = WIDTH / 2, y = HEIGHT / 2 })

local cometScale = 0.75

function CometTest:enteredState()
end

function CometTest:update(dt)
  local mx,my = love.mouse.getPosition()
  mx = mx -CENTERX
  my = my -CENTERY
  player.vel = { x = mx, y = -my }

  player:update(dt)
end

function CometTest:draw()
  love.graphics.push()
    lg.scale(cometScale)
    love.graphics.translate(-player.x + CENTERX/cometScale,-player.y + CENTERY/cometScale)

    player:draw()
  love.graphics.pop()
end
