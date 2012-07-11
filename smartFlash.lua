--[[
	Smart flash v1.1 by ikita
    
]]

player = GetMyHero()

--[[		Config		]]                           
HK = 192 --Hold hotkey to flash to location. default at " ~ " (the key left to number 1)
range = 420 --Flash range is 400. Real range is larger if you flash across a wall

--[[ 		Code		]]
function tickHandler()
	if scriptActive == true then
		x = mousePos.x
		z = mousePos.z
		dx = x - player.x
		dz = z - player.z
		rad1 = math.atan2(dz, dx)
		dx1 = range*math.cos(rad1)
		dz1 = range*math.sin(rad1)
		x1 = x - dx1
		z1 = z - dz1
		if math.sqrt(dx*dx + dz*dz) < range + 90 then --Increase this number for smoother flash. (might fail if too large)
			CastSpell( flashSlot, x, z )
		else
			player:MoveTo(x1, z1)
		end
	end
end



function Hotkey(msg,key)
    if key == HK then
        if msg == KEY_DOWN then
            scriptActive = true
        else
            scriptActive = false
        end
    end
end




	if string.find(GetSpellData(SPELL_SUMMONER_1).name, "SummonerFlash") ~= nil then
		flashSlot = SPELL_SUMMONER_1
		PrintChat(" >> Smart Flash script loaded!")
		BoL:addMsgHandler(Hotkey)
		BoL:addTickHandler(tickHandler,50)
	elseif string.find(GetSpellData(SPELL_SUMMONER_2).name, "SummonerFlash") ~= nil then
		flashSlot = SPELL_SUMMONER_2
		PrintChat(" >> Smart Flash script loaded!")
		BoL:addMsgHandler(Hotkey)
		BoL:addTickHandler(tickHandler,50)
	end
	


	
    
