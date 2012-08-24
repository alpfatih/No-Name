if GetMyHero().charName == "Katarina" then
--[[
	Simple Kat KS
	v1.0 ikita
]]


--[[		Code		]]
player = GetMyHero()
local DFGId = 3128


local function tickHandlerK()
	local invSlot = findItemSlotInInventory(DFGId)
	local dfgDmg = 0

	for i=1, heroManager.iCount do
		local target = heroManager:GetHero(i)
		if invSlot ~= nil then
	            dfgDmg = player:CalcMagicDamage(target,(.25+(.04*(math.floor(player.ap/100))))*target.health)
	        if dfgDmg < 200 then
	            dfgDmg = 200
	    	end
	    end
	
	    if invSlot == nil then
	            dfgDmg = 0
	    end	
	
		local eDmg = player:CalcMagicDamage(target, 30*(player:GetSpellData(_E).level-1)+40+(.4*player.ap))
		local wDmg = player:CalcMagicDamage(target, 40*(player:GetSpellData(_W).level-1) +40+ (.3*player.ap)+(.6*player.addDamage)) --375
		local qDmg = player:CalcMagicDamage(target, 35*(player:GetSpellData(_Q).level-1)+50+(.5*player.ap))
		local qProc = player:CalcMagicDamage(target, 15*(player:GetSpellData(_Q).level-1) +15+(.2*player.ap))
		--[[
		Combo: 	e>q>w +p 700
				e>w 700
				e>q 700
				e 700
				
				q>e +p 675
				q 675

				q>w +p 375
				w 375
				
				
		]]
		
		if target ~= nil and target.visible == true and player.team ~= target.team and target.dead == false then
			--Without DFG
			--700	
			if player:CanUseSpell(_E) == READY and player:GetDistance(target) < 700 then
				if target.health < eDmg + qDmg + wDmg + qProc and player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY then
					CastSpell(_E, target)
					CastSpell(_Q, target)
					CastSpell(_W)
				end
				if target.health < eDmg + wDmg and player:CanUseSpell(_W) == READY then
					CastSpell(_E, target)
					CastSpell(_W)
				end
				if target.health < eDmg + wDmg and player:CanUseSpell(_Q) == READY then
					CastSpell(_E, target)
					CastSpell(_Q, target)
				end				
				if target.health < eDmg  then
					CastSpell(_E, target)
				end						
			end
			--675
			if player:CanUseSpell(_Q) == READY and player:GetDistance(target) < 675 then
				if target.health < eDmg + qDmg + qProc and player:CanUseSpell(_E) == READY then
					CastSpell(_Q, target)
					CastSpell(_E, target)
				end		
				if target.health < qDmg  then
					CastSpell(_Q, target)
				end						
			end
			--375
			if player:CanUseSpell(_W) == READY and player:GetDistance(target) < 375 then
				if target.health < wDmg + qDmg + qProc and player:CanUseSpell(_W) == READY then
					CastSpell(_Q, target)
					CastSpell(_W)
				end		
				if target.health < wDmg  then
					CastSpell(_W)
				end						
			end
			
			--DFG combo
			if invSlot ~= nil then
				if player:CanUseSpell(invSlot) == READY then
				
					--700	
					if player:CanUseSpell(_E) == READY and player:GetDistance(target) < 700 then
						if target.health < eDmg + qDmg + wDmg + qProc + dfgDmg and player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY then
							CastSpell(invSlot, target)
							CastSpell(_E, target)
							CastSpell(_Q, target)
							CastSpell(_W)
						end
						if target.health < eDmg + wDmg + dfgDmg and player:CanUseSpell(_W) == READY then
							CastSpell(invSlot, target)
							CastSpell(_E, target)
							CastSpell(_W)
						end
						if target.health < eDmg + wDmg + dfgDmg and player:CanUseSpell(_Q) == READY then
							CastSpell(invSlot, target)
							CastSpell(_E, target)
							CastSpell(_Q, target)
						end				
						if target.health < eDmg + dfgDmg then
							CastSpell(invSlot, target)
							CastSpell(_E, target)
						end						
					end
					--675
					if player:CanUseSpell(_Q) == READY and player:GetDistance(target) < 675 then
						if target.health < eDmg + qDmg + qProc + dfgDmg and player:CanUseSpell(_E) == READY then
							CastSpell(invSlot, target)
							CastSpell(_Q, target)
							CastSpell(_E, target)
						end		
						if target.health < qDmg + dfgDmg  then
							CastSpell(invSlot, target)
							CastSpell(_Q, target)
						end						
					end
					--375
					if player:CanUseSpell(_W) == READY and player:GetDistance(target) < 375 then
						if target.health < wDmg + qDmg + qProc + dfgDmg and player:CanUseSpell(_W) == READY then
							CastSpell(invSlot, target)
							CastSpell(_Q, target)
							CastSpell(_W)
						end		
						if target.health < wDmg + dfgDmg then
							CastSpell(invSlot, target)
							CastSpell(_W)
						end						
					end
				end
			end
		end
	
	end

end

local function findItemSlotInInventory( item )
    local ItemSlot = {ITEM_1,ITEM_2,ITEM_3,ITEM_4,ITEM_5,ITEM_6,}
    for i=1, 6, 1 do
        if player:getInventorySlot(ItemSlot[i]) == item then return ItemSlot[i] end
    end
end

if player.charName == "Katarina" then
	BoL:addTickHandler(tickHandlerK,10)
	PrintChat(" >> Katarina ShumpoSteal loaded!")

else

end
end