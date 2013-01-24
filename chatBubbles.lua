PrintChat(" >> Chat Bubbles loaded!")

--[[
	Chat Bubbles v1.0 by ikita for BoL Studio
	Credits to delusionallogic, and grey
	I learned from dermalib and AllClass
]]


--[[		Code		]]
bubbles = {}
bubblesTimer = {}

function OnTick()
end

function OnRecvChat(from,msg)
	for i=1, heroManager.iCount do
		local target = heroManager:GetHero(i)
		if from == target.name then
			bubbles[i] = msg
			bubblesTimer[i] = GetTickCount()
		end
	end
	
end

function OnDraw()
	for i=1, heroManager.iCount do
	local target = heroManager:GetHero(i)
		local heroX, heroY, onScreen = get2DFrom3D(target.x, target.y+GetDistance(target.minBBox, target.maxBBox)*.9, target.z)
		if bubbles[i] ~= nil and onScreen and GetTickCount() - bubblesTimer[i] < 9000 then
			DrawText(bubbles[i],20,heroX-GetTextArea(bubbles[i], 20).x/2,heroY, 4294967280 )
			drawFilledRect(heroX-GetTextArea(bubbles[i], 20).x/2, heroY, GetTextArea(bubbles[i], 20).x, 20, 0, 822083568, 0x50000000 )
			--Close both sides 
			for j=1, 10 do
				DrawLine(heroX-GetTextArea(bubbles[i], 20).x/2-j, heroY+j, heroX-GetTextArea(bubbles[i], 20).x/2-j, heroY+20-j, 1, 0x50000000)
				DrawLine(heroX-GetTextArea(bubbles[i], 20).x/2+GetTextArea(bubbles[i], 20).x +j, heroY+j, heroX-GetTextArea(bubbles[i], 20).x/2+GetTextArea(bubbles[i], 20).x +j, heroY+20-j, 1, 0x50000000)
			end
		end
	end
end

function drawRect(x, y, width, height, thickness, color)
    if thickness == 0 then
        return
    end
    x = x - 1
    y = y - 1
    width = width + 2
    height = height + 2
    local halfThick = math.floor(thickness/2)
    DrawLine(x - halfThick, y, x + width + halfThick, y, thickness, color)
    DrawLine(x, y + halfThick, x, y + height - halfThick, thickness, color)
    DrawLine(x + width, y + halfThick, x + width, y + height - halfThick, thickness, color)
    DrawLine(x - halfThick, y + height, x + width + halfThick, y + height, thickness, color)
end

function drawFilledRect(x, y, width, height, thickness, color, backgroundColor)
    DrawLine(x, y + (height/2), x + width+1, y + (height/2), height+1, backgroundColor)
    drawRect(x, y, width, height, thickness, color)
end