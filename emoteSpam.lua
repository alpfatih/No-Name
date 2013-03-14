--[[
ikita's Emote spam
credits to Broland and his Funny Phrases
]]

HK = string.byte("8")
 
--[[ Config ]] --
function OnLoad()
scriptActiveS = true
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

	Emote(math.floor(math.random(3)))		
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
