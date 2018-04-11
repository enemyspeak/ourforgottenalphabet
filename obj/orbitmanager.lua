-- orbitManager
local OrbitManager = class('OrbitManager')

local Ring = require('obj.ring')

OrbitManager.static.MAX_RINGS =  55

function OrbitManager:initialize(attributes)
    local attributes = attributes or {}
    self.oribtCanvas = love.graphics.newCanvas( WIDTH, HEIGHT )
    self.rings = {}
    self.translate = {0,0}
    self.orbitDirection = 0
    self.orbitDistance = 0
    for i = 1, OrbitManager.MAX_RINGS do
		self.rings[i] = Ring:new({
			
		})
	end
end

function OrbitManager:update(dt, comet, star)
    for i,v in ipairs(self.rings) do
        self.rings[i]:update(dt)
    end

    self.orbitDirection = math.atan2(comet.x - star.x , comet.y-star.y)
    self.orbitDistance = math.sqrt((comet.x - star.x )^2  + ( comet.y - star.y)^2 )
    self.translate = {
        comet.x -((comet.x - star.x)/2),
        comet.y -((comet.y - star.y)/2)
    }
    
    -- orbitBuffer = orbitBuffer + dt
    -- if orbitBuffer > interval and #rings < MAXRINGS then
    --     orbitBuffer = 0
    --     local flag = getOrbitHide()
    --     rings[#rings+1] = Ring:new({ X1 = comet.x, Y1 = comet.y, X2 = star.x, Y2 = star.y, r = 0, alpha = alpha, distance = self.orbitDistance, hide = flag })
    -- end


    -- for i,v in ipairs(rings) do
    --     if rings[i]:getKill() then
    --         table.remove(rings,i)
    --     else
    --         rings[i]:setDistance(self.orbitDistance)
    --         rings[i]:setCometPos(comet.x,comet.y)
    --         rings[i]:setStarPos(star.x,star.y)
    --         rings[i]:update(dt)
    --         if self.orbitDistance < 10 then
    --             rings[i]:setHidden(-1)	--HARD ON (on = hidden)
    --         elseif self.orbitDistance < 60 then
    --             rings[i]:setHidden(2)	--High
    --         elseif self.orbitDistance < 120 then
    --             rings[i]:setHidden(1)	--Low
    --         else
    --             rings[i]:setHidden(0)	--Off
    --         end
    --     end
    -- end
end

function OrbitManager:draw(comet,star)
    local c = love.graphics.getCanvas()
    love.graphics.setCanvas(self.oribtCanvas)
    lg.clear(unpack(colors["background"]))

    local createInvertedStencil = function()
        local maskScale = 0.8
        love.graphics.push()
        -- love.graphics.translate(CENTERX,CENTERY)
        -- love.graphics.scale(drawTween.drawScale)
        -- love.graphics.translate(drawTween.translateX,drawTween.translateY)
        love.graphics.translate(unpack(self.translate))
        love.graphics.scale(maskScale)
        love.graphics.rotate(-self.orbitDirection)
            love.graphics.ellipse("fill",(-self.orbitDistance/8),0,self.orbitDistance/9,self.orbitDistance/6,0,30) --top
            love.graphics.ellipse("fill",(self.orbitDistance/8),0,self.orbitDistance/9,self.orbitDistance/6,0,30) --bottom
        love.graphics.pop()
        love.graphics.push()
        -- love.graphics.translate(CENTERX,CENTERY)
        -- love.graphics.scale(drawTween.drawScale)
        -- love.graphics.translate(drawTween.translateX,drawTween.translateY)
        love.graphics.translate(unpack(self.translate))
        love.graphics.scale(maskScale)
        love.graphics.rotate(-self.orbitDirection-math.pi/4)
            love.graphics.ellipse("fill",(-self.orbitDistance/8+self.orbitDistance/12),(-self.orbitDistance/3-self.orbitDistance/48),self.orbitDistance/6,self.orbitDistance/3,0,30) --bottom
        love.graphics.pop()
        love.graphics.push()
        -- love.graphics.translate(CENTERX,CENTERY)
        -- love.graphics.scale(drawTween.drawScale)
        -- love.graphics.translate(drawTween.translateX,drawTween.translateY)
        love.graphics.translate(unpack(self.translate))
        love.graphics.scale(maskScale)
        love.graphics.rotate(-self.orbitDirection+math.pi/4)
            love.graphics.ellipse("fill",(self.orbitDistance/8-self.orbitDistance/12),(-self.orbitDistance/3-self.orbitDistance/48),self.orbitDistance/6,self.orbitDistance/3,0,30)	 --top
        love.graphics.pop()
        love.graphics.push()
        -- love.graphics.translate(CENTERX,CENTERY)
        -- love.graphics.scale(drawTween.drawScale)
        -- love.graphics.translate(drawTween.translateX,drawTween.translateY)
            love.graphics.circle("fill",comet.x,comet.y,7)
            love.graphics.circle("fill",star.x,star.y,8)
        love.graphics.pop()
    end

    local createStencil = function ()
        love.graphics.push()
        love.graphics.translate(CENTERX,CENTERY)
        -- love.graphics.scale(drawTween.drawScale)
        -- love.graphics.translate(drawTween.translateX,drawTween.translateY)
        love.graphics.translate(unpack(self.translate))
        love.graphics.rotate(-self.orbitDirection)
            love.graphics.circle("fill",0,0,self.orbitDistance/8)	-- overall
            love.graphics.ellipse("fill",0,self.orbitDistance/4,self.orbitDistance/12,(self.orbitDistance/4),0,20) -- mouse
            love.graphics.circle("fill",0,(-self.orbitDistance/4) - ((self.orbitDistance/5.75)),self.orbitDistance/5)	-- star
            love.graphics.circle("fill",0,(-self.orbitDistance/4),self.orbitDistance/7)	-- star between orverall
        love.graphics.pop()
    end
    
    love.graphics.stencil(createInvertedStencil, "replace", 1)
    love.graphics.push()
    love.graphics.translate(CENTERX,CENTERY)
    love.graphics.setStencilTest("less", 1)
        love.graphics.setColor(unpack(colors["blue"],orbitFade))
        for i,v in ipairs(self.rings) do
            self.rings[i]:draw()
        end
    love.graphics.pop()
    love.graphics.setStencilTest()

    love.graphics.setCanvas(c)
    love.graphics.stencil(createStencil, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
        love.graphics.setColor(255,255,255)
        love.graphics.draw(self.oribtCanvas, 0,0, 0, 1,1)
    love.graphics.setStencilTest()
    love.graphics.setColor(255,255,255)
end

return OrbitManager
