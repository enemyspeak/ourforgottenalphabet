function love.conf(t)
	t.identity = "OurForgottenAlphabetBeta"
    -- t.version = "0.9.0"                -- The LÖVE version this game was made for (string)
    t.console = false                  -- Attach a console (boolean, Windows only)

	t.window.title =  " "
    t.window.icon = nil                -- Filepath to an image to use as the window's icon (string)
    -- w = 1136
    -- h = 640
    t.window.width = 640              -- The window width (number)
    t.window.height = 360              -- The window height (number)
    --t.window.width = 960              -- The window width (number)
    --    t.window.height = 720    -- 4:3          -- The window height (number)

    -- t.window.width = 2208              -- The window width (number)
    -- t.window.height = 1242    -- 3:4          -- The window height (number)


    t.window.borderless = true        -- Remove all border visuals from the window (boolean)
    t.window.highdpi = true
    t.window.fullscreen = false        -- Enable fullscreen (boolean)
    t.window.vsync = true              -- Enable vertical sync (boolean)
    t.window.fsaa = 0                  -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.display = 1               -- Index of the monitor to show the window in (number)

    t.modules.audio = true             -- Enable the audio module (boolean)
    t.modules.event = true             -- Enable the event module (boolean)
    t.modules.graphics = true          -- Enable the graphics module (boolean)
    t.modules.image = true             -- Enable the image module (boolean)
    t.modules.joystick = true          -- Enable the joystick module (boolean)
    t.modules.keyboard = true          -- Enable the keyboard module (boolean)
    t.modules.math = true              -- Enable the math module (boolean)
    t.modules.mouse = true             -- Enable the mouse module (boolean)
    t.modules.physics = true           -- Enable the physics module (boolean)
    t.modules.sound = true             -- Enable the sound module (boolean)
    t.modules.system = true            -- Enable the system module (boolean)
    t.modules.timer = true             -- Enable the timer module (boolean)
    t.modules.window = true            -- Enable the window module (boolean)

  --  t.console = true
end
