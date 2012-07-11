--[[
	Karthus Ult Alert v1.0 by ikita
	Alerts player to ult if someone can die from it
	
]]


--[[		Code		]]
player = GetMyHero()

function drawHandler()
	if player:GetSpellData(_R).level > 0 and player:CanUseSpell(_R) == READY then
		
		for i=1, heroManager.iCount do
			targetX = heroManager:GetHero(i)
			ultDamage = player:CalcMagicDamage(targetX, math.floor(((player:GetSpellData(_R).level-1)*150) + 250 + 0.6*player.ap))
			if targetX ~= nil and targetX.team == TEAM_ENEMY and targetX.dead == false and ultDamage - targetX.health > 0 then
				DrawText("" .. targetX.charName, 20, 200, 170+23*i, 0xFFFFFF00)
			end
		end
	end
end



	if player.charName == "Karthus" then
	    BoL:addDrawHandler(drawHandler)
		PrintChat(" >> Karthus Ult alert loaded!")

	else

	end