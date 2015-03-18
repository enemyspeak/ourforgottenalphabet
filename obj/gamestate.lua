-- Sets up default state
Gamestate = class('Gamestate'):include(Stateful)

function Gamestate:initialize()
end

function Gamestate:update(dt)
end

function Gamestate:draw()
end

function Gamestate:focus(f)
end

function Gamestate:resize(w,h)
end

function Gamestate:joystickpressed(joystick, button)
end

function Gamestate:joystickreleased(joystick, button)
end

function Gamestate:keypressed(key, unicode)
end

function Gamestate:keyreleased(key)
end

function Gamestate:mousepressed(x, y, button)
end

function Gamestate:mousereleased(x, y, button)
end

function Gamestate:quit()
end
