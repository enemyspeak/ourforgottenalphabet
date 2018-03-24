
local Clock = class('Clock')

Clock.static.CENTERX = love.graphics.getWidth()/2
Clock.static.CENTERY = love.graphics.getHeight()/2
Clock.static.COLOR1 = {255,255,255}

function Clock:initialize(attributes)
	local attributes = attributes or {}
  self.time = 0
  self.paused = false
end

function Clock:setPaused(value)
  self.paused = value
end

function Clock:addTime(value)
  self.paused = true
  local tweenTo = self.time + value
  -- todo
  self.time = tweenTo
  self.setPaused(true)
end

function Clock:update(dt)
  self.time = self.time - dt
	if self.time < 1 then
		self.time = 0
	end
end

function Clock:draw(cx,cy)
  if self.paused then return end

  local digits = ""
	if math.floor(self.time) < 10 then
		digits = "0000"
	elseif math.floor(self.time) < 100 then
		digits = "000"
	end

	love.graphics.setColor(unpack(colors["background"]))
	love.graphics.rectangle("fill",10,8,40,12)
	love.graphics.setColor(unpack(colors["white"]))
	love.graphics.setFont(fonts["clock"])
	love.graphics.print(digits..math.floor(self.time), 10, 5)
end

return Clock
