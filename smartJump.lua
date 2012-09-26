--[[
	Ikita's Smart Jump v2.0   for BoL Studio
    Attempts to ward jump (Wriggles > Sight > Vision) before trying to flash.
]]

--Note: if script is not responsive, move cursor into the wall (towards your champion)
--Or play with the configs

require "AllClass"


--[[		Config		]]                           
local HK = 192 --Hold hotkey to flash to location. default at " ~ " (the key left to number 1)
local flashRange = 420 --Flash range is 400. Real range is larger if you flash inside a wall
local wardRange = 550 --Ward range is 600. I set it smaller so the ward won't pop too far to the other side of the wall, rendering your jump out of reach.
local jumpDelay = 100 -- a slight delay after warding before jumping


--Nothing
local lastJump = 0
local wardTarget
local jumpReady = false

--[[ 		Code		]]

function jumpNowAlready()
	if scriptActive and jumpReady == true then
		for k = 1, objManager.maxObjects do
		local object = objManager:GetObject(k)
			if object ~= nil and (string.find(object.name, "Ward") ~= nil or string.find(object.name, "Wriggle") ~= nil) and math.sqrt((mousePos.x - object.x)*(mousePos.x - object.x) + (mousePos.z - object.z)*(mousePos.z - object.z)) < 300 then
				CastSpell( jumpSlot, object)
				jumpReady = false
			end
		end
	end
end

function OnTick()
	if jumpReady == true and GetTickCount() - lastJump > jumpDelay then
		jumpNowAlready()
	end
	if scriptActive then
	
		local x = mousePos.x
		local z = mousePos.z
		local dx = x - player.x
		local dz = z - player.z
		local rad1 = math.atan2(dz, dx)
		
		--Crap code here needs cleaning up
		if GetInventorySlotItem(3154) ~= nil then
			wardSlot = GetInventorySlotItem(3154)
			
			if player:CanUseSpell(wardSlot) ~= READY then
				if GetInventorySlotItem(2044) ~= nil then
					wardSlot = GetInventorySlotItem(2044)
				elseif GetInventorySlotItem(2043) ~= nil then
					wardSlot = GetInventorySlotItem(2043)
				else
					wardSlot = nil
				end
			end
		elseif GetInventorySlotItem(2044) ~= nil then
			wardSlot = GetInventorySlotItem(2044)
		elseif GetInventorySlotItem(2043) ~= nil then
			wardSlot = GetInventorySlotItem(2043)
		else
			wardSlot = nil
		end
		
		if wardSlot ~= nil and jumpSlot ~= nil then
			--for wards
			local dx1 = flashRange*math.cos(rad1)
			local dz1 = flashRange*math.sin(rad1)
			
			local x1 = x - dx1
			local z1 = z - dz1
			if player:CanUseSpell(jumpSlot) == READY and GetTickCount() - lastJump > 2000 and math.sqrt(dx*dx + dz*dz) < 600 then --Increase this number for smoother flash. (might fail if too large)
				CastSpell( wardSlot, x, z )
				jumpReady = true
            	lastJump = GetTickCount()
			else
				player:MoveTo(x1, z1)
			end
		end
			
		if (not (jumpSlot ~= nil and wardSlot ~= nil and player:CanUseSpell(jumpSlot) == READY) ) and flashSlot ~= nil then
			--for flash
			local dx1 = flashRange*math.cos(rad1)
			local dz1 = flashRange*math.sin(rad1)
			
			local x1 = x - dx1
			local z1 = z - dz1
			if GetTickCount() - lastJump > 2000 and math.sqrt(dx*dx + dz*dz) < flashRange + 90 then --Increase this number for smoother flash. (might fail if too large)
				CastSpell( flashSlot, x, z )
				lastJump = GetTickCount()
			else
				player:MoveTo(x1, z1)
			end
		end
	end	
end



function OnWndMsg(msg,key)
    if key == HK then
        if msg == KEY_DOWN then
            scriptActive = true
        else
            scriptActive = false
        end
    end
end



function OnLoad()
	if string.find(player:GetSpellData(SUMMONER_1).name, "SummonerFlash") ~= nil then
		flashSlot = SUMMONER_1
		PrintChat(" >> Smart Flash script loaded!")
	elseif string.find(player:GetSpellData(SUMMONER_2).name, "SummonerFlash") ~= nil then
		flashSlot = SUMMONER_2
		PrintChat(" >> Smart Flash script loaded!")
	else
		flashSlot = nil
	end
	-- Champions that can ward jump
	if player.charName == "Katarina" then
		jumpSlot = _E
		jumpRange = 700
	elseif player.charName == "Jax" then
		jumpSlot = _Q
		jumpRange = 700
	elseif player.charName == "LeeSin" then
		jumpSlot = _W
		jumpRange = 700
	else
		jumpSlot = nil
		jumpRange = 0
	end
end


	
    
