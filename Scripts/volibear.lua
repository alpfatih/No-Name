if GetMyHero().charName == "Volibear" then
--[[
	Volibear Bite Helper v0.1 by ikita for BoL
	Automatically cast bite when someone in range can die from it
]]


--[[		Code		]]
player = GetMyHero()
sleepTick = 0

function tickHandler()
	if player:GetSpellData(_W).level > 0 and player:CanUseSpell(_W) == READY then
		
		for i=1, heroManager.iCount do
			local target = heroManager:GetHero(i)
			local baseHP = (470 + 92*player.level) * 1.03
			local biteDamage = player:CalcDamage(target, math.floor( (((player:GetSpellData(_W).level-1)*45) + 80 + (player.maxHealth - baseHP)*0.15) * (1 + (target.maxHealth - target.health)/(target.maxHealth))))
			
			if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false and player:GetDistance(target) < 400 and player:CanUseSpell(_W) == READY then
				if target.health < biteDamage then
					CastSpell(_W, target)
				end
			end
		end
	end
end



	if player.charName == "Volibear" then
	    BoL:addTickHandler(tickHandler,10)
		PrintChat(" >> Volibear Bite Helper loaded!")

	else

	end
end