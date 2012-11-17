--[[
ikita's Emote spam on spell casts/attacks
credits to Broland and his Funny Phrases
]]

HK = string.byte("7")
 
--[[ Config ]] --
function OnLoad()
scriptActiveS = true
PrintChat(" >> Emote Spam loaded")
end

-- (dance = 0, taunt=1, laugh=2, joke=3)
function Emote(id)
	p = CLoLPacket(0x45)
	p:EncodeF(myHero.networkID)
	p:Encode1(id)
	p.dwArg1 = 1
	p.dwArg2 = 0
	SendPacket(p)
end


--[[ Code ]] --

function OnProcessSpell(object, spell)
local spellName = spell.name
	if object.name == player.name and scriptActiveS then
	--Emote(math.floor(math.random(3))) --ENABLE this line for spamming every auto attack. (warning: cancels AA at low attack speeds)
	--PrintChat(spellName) -- USE this line to find spell names to include in exclusions in the following line:
		if (not (string.find(spellName,"Attack") or string.find(spellName,"Crit") or string.find(spellName,"Basic"))) then --add spell exclusions here		
			Emote(math.floor(math.random(3)))		
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