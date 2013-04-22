--[[
ikita's Emote spam 1.1
credits to Broland and his Funny Phrases
]]

HK = string.byte("8") --Default hotkey 8

lastSpam = 0

--[[ Config ]] --
function OnLoad()
scriptActiveS = false
PrintChat(" >> Emote Spam loaded")
end

-- (dance = 0, taunt=1, laugh=2, joke=3)
function Emote(id)
	p = CLoLPacket(0x47)
	p:EncodeF(myHero.networkID)
	p:Encode1(id)
	p.dwArg1 = 1
	p.dwArg2 = 0
	SendPacket(p)
end


--[[ Code ]] --

function OnTick()	
	if scriptActiveS then
	player:MoveTo(mousePos.x,mousePos.z)
	if GetTickCount() - lastSpam > 5000 then -- change 5000 to lower for quicker spams
		-- Use emote(2) to spam only laugh. Use the other line to spam random emotes
		Emote(2)
		--Emote(math.floor(math.random(3)))
		lastSpam = GetTickCount()
	end
	end
end
  
 
function OnWndMsg( msg, keycode )
	if msg == KEY_DOWN then 
		if keycode == HK then
			if scriptActiveS then
				scriptActiveS = false
				PrintChat(" >> Emote Spam disabled!")  
			else
				scriptActiveS = true
				PrintChat(" >>  Emote Spam enabled!")
			end     
		end
	end
end