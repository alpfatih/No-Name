--[[
	ikita's Spin-To-Win
]]--

--Config:
local spinSpeed = 8 -- This is the (number of points it will face in a full circle)/2
local HKH = 72 --Hold H

--Other stuff
local spin = false
local direction = 0
local lastSpined = 0

function OnWndMsg(msg,key)
	if key == HKH then
	    if msg == KEY_DOWN then
	        spin = true
	    else
	    	spin = false
	    end 
	end
end

function OnTick()
	if spin then
		spinX = 100*math.sin(math.pi*direction / spinSpeed)
		spinZ = 100*math.cos(math.pi*direction / spinSpeed)
		myHero:MoveTo(myHero.x + spinX,myHero.z + spinZ)
		direction = direction + 1
		directionCount = directionCount + 1
	else
		directionCount = spinSpeed + 1
		direction = (((math.pi/2) - math.atan2((mousePos.z - myHero.z),(mousePos.x - myHero.x)))*spinSpeed)/math.pi
	end
end
PrintChat(" >> Spin To Win loaded!")