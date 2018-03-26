-- General functions for OFA
-- © Kevin Faherty


local common = {}

function common:mapValue(value,low,high,mapLow,mapHigh) 
	return (((mapHigh - mapLow) * (value / (high - low))) + mapLow)
end

function common:getCircleXY(rad,x,y)
	local radius = rad or 1
	local centerX = x or 0
	local centerY = y or 0
	local r
	local t = 2 * math.pi * math.random()
	local u = math.random(0,radius) + math.random(0,radius)
	if u > radius then
		r = (radius * 2) - u
	else
		r = u
	end
	
	local tempX = r*math.cos(t)
	local tempY = r*math.sin(t)
	return tempX, tempY
end

function common:compareValues(x1,y1,x2,y2)
	local greaterX, greaterY, lesserX, lesserY
	if x1 > x2 then		-- Tested correct
		lesserX = x2
		greaterX = x1
	else 
		lesserX = x1
		greaterX = x2
	end
	if y1 > y2 then	
		lesserY = y2
		greaterY = y1
	else 
		lesserY = y1
		greaterY = y2
	end
	return greaterX, greaterY, lesserX, lesserY
end

function common:clampLower(x1,x2)
	local temp
	if x1 < x2 then 
		temp = x2
	else
		temp = x1
	end
	return temp
end

function common:clampUpper(x1,x2)
	local temp
	if x1 > x2 then 
		temp = x2
	else
		temp = x1
	end
	return temp
end

function common:drawDebugMouse()
	local mx = love.mouse.getX( ) - CENTERX
	local my = love.mouse.getY( ) - CENTERY
	love.graphics.print(mx ..", " ..my,mx + 16, my + 8)					-- Mouse overlay
end

function common:getName()
		local value = math.random(1,17)
		if value == 1 then
			return 'a'
		elseif value == 2 then
			return 'b'
		elseif value == 3 then
			return 'c'
		elseif value == 4 then
			return 'd'
		elseif value == 5 then
			return 'e'
		elseif value == 6 then
			return 'f'
		elseif value == 7 then
			return 'g'
		elseif value == 8 then
			return 'h'
		elseif value == 9 then
			return 'i'
		elseif value == 10 then
			return 'j'
		elseif value == 11 then
			return 'k'
		elseif value == 12 then
			return 'l'
		elseif value == 13 then
			return 'm'
		elseif value == 14 then
			return 'n'
		elseif value == 15 then
			return 'o'
		elseif value == 16 then
			return 'p'
		elseif value == 17 then
			return 'q'
		end
end

--[[
	-- Resources
	
	--				blue = {182,184,195}

	
	colors =	{
				background = {31,37,46},
				white = {255,255,255},
				particle = {72,82,108},
				star = {192,184,185},
				constellation = {192,184,185},
				highlight = {241,152,35},
				green = {49,57,62},
				}		
	fonts =		{
				debug = love.graphics.newFont("res/visitor1.ttf",10),
				title = love.graphics.newFont("res/hyperspace.ttf",160),
				subtitle = love.graphics.newFont("res/whitrabt.ttf",25),
				clock = love.graphics.newFont("res/square.ttf",22),
				about = love.graphics.newFont("res/whitrabt.ttf",20)
				}	
	graphics =  {
				star1 = love.graphics.newImage("resources/star1.png"),
				star2 = love.graphics.newImage("resources/star2.png"),
				comet = love.graphics.newImage("resources/comet.png"),
				arrow = love.graphics.newImage("resources/arrow.png")
				}
]]--

--[[

orbit_direction = math.atan2(center_x - closest_star_x , center_y - closest_star_y)+math.pi/2		-- atan2 = math.atan() - math.pi/2

]]--

return common
