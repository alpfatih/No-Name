                                                                     
                                                                     
                                                                     
                                             
PrintChat(" >> Chat Bubbles loaded!")



--[[

	Chat Bubbles v1.4 by ikita for BoL Studio
	Credits to delusionallogic, and grey
	I learned from dermalib and AllClass
]]





--[[		Code		]]
bubbles = {}
bubblesTimer = {0,0,0,0,0,0,0,0,0,0,0}
staticString = {"","","","","","","","","","","","","","",""}
dummyj = {}
animationUpdate = {0,0,0,0,0,0,0,0,0,0,0}

function OnTick()
	for i=1, heroManager.iCount do
		if GetTickCount() - bubblesTimer[i] > 9000 then 
			dummyj[i] = 1
		end
		if string.len(staticString[i]) ~= nil and GetTickCount() - animationUpdate[i] > 40 and dummyj[i] <= string.len(staticString[i]) then
			bubbles[i] = string.sub(staticString[i], 1, dummyj[i])
			dummyj[i] = dummyj[i] + 1
			animationUpdate[i] = GetTickCount()
		end
	end
end

function OnRecvChat(from,msg)
	for i=1, heroManager.iCount do
		local target = heroManager:GetHero(i)

		if target ~= nil and target.visible and from == target.name then
			staticString[i] = msg
			bubblesTimer[i] = GetTickCount()
			dummyj[i] = 1
		end
	end
	
end

function OnSpeech(msg)
	for i=1, heroManager.iCount do
		local target = heroManager:GetHero(i)
		if target ~= nil and target.visible and player.name == target.name then
			staticString[i] = msg
			bubblesTimer[i] = GetTickCount()
			dummyj[i] = 1
		end
	end	
end

function OnDraw()
	for i=1, heroManager.iCount do
	local target = heroManager:GetHero(i)
		local heroX, heroY, onScreen = get2DFrom3D(target.x, target.y+GetDistance(target.minBBox, target.maxBBox)*.9, target.z)
		if target ~= nil and target.visible and bubbles[i] ~= nil and onScreen and GetTickCount() - bubblesTimer[i] < 9000 then
			drawFilledRect(heroX-GetTextArea(bubbles[i], 20).x/2, heroY-15, GetTextArea(bubbles[i], 20).x, 20, 0, 822083568, 4294967280 )
			--Close both sides 
			for j=1, 10 do
				DrawLine(heroX-GetTextArea(bubbles[i], 20).x/2-j, heroY-15+(10-math.sqrt(10^2-j^2)), heroX-GetTextArea(bubbles[i], 20).x/2-j, heroY-15+20-(10-math.sqrt(10^2-j^2)), 1, 4294967280)
				DrawLine(heroX-GetTextArea(bubbles[i], 20).x/2+GetTextArea(bubbles[i], 20).x +j, heroY-15+(10-math.sqrt(10^2-j^2)), heroX-GetTextArea(bubbles[i], 20).x/2+GetTextArea(bubbles[i], 20).x +j, heroY-15+20-(10-math.sqrt(10^2-j^2)), 1, 4294967280)
			--Close bottom
				DrawLine(heroX-j/2, heroY-15+20, heroX-j/2, heroY-15+20+15-j*3/2, 1, 4294967280)
				DrawLine(heroX+j/2, heroY-15+20, heroX+j/2, heroY-15+20+15-j*3/2, 1, 4294967280)
			end
			DrawText(bubbles[i],20,heroX-GetTextArea(bubbles[i], 20).x/2,heroY-15, 0xff000000 )
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