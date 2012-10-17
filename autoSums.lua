    --[[
	Auto Summoners, best for afk. 1.0
	by ikita
    ]]
     
     
--[[  Config  ]]
hpLimit = 0.25
manaLimit = 0.3
exhaustLimit = 0.5
     
--[[  Globals  ]]
require "AllClass"
player = GetMyHero()
sums = {player:GetSpellData(SUMMONER_1).name, player:GetSpellData(SUMMONER_2).name}


--[[   Code   ]]
function OnTick()
	for i = 1, 2, 1 do
	--Promote
		if string.find(sums[i], "SummonerPromoteSR") ~= nil then
			if player:CanUseSpell(10+i) == READY then
				CastSpell(10+i)
			end
		end
	--Heal with friends
		if string.find(sums[i], "SummonerHeal") ~= nil then
			if player:CanUseSpell(10+i) == READY then
				for j = 1, heroManager.iCount do
                	local target = heroManager:GetHero(j)
					if target ~= nil and target.visible == true and target.team == player.team and target.dead == false and player:GetDistance(target) < 300 then
						if target.health/target.maxHealth < hpLimit then
							CastSpell(10+i)
						end
					end
				end
			end
		end
	--Clarity with friends
		if string.find(sums[i], "SummonerMana") ~= nil then
			if player:CanUseSpell(10+i) == READY then
				for j = 1, heroManager.iCount do
                	local target = heroManager:GetHero(j)
					if target ~= nil and target.visible == true and target.team == player.team and target.dead == false and player:GetDistance(target) < 300 then
						if target.mana/target.maxMana < manaLimit then
							CastSpell(10+i)
						end
					end
				end
			end
		end
	--Ignite
		if string.find(sums[i], "SummonerDot") ~= nil then
			local igniteDamage = 50 + 20 * player.level
			if player:CanUseSpell(10+i) == READY then
				for j = 1, heroManager.iCount do
                	local target = heroManager:GetHero(j)
					if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false and player:GetDistance(target) < 600 then
						if target.health < igniteDamage then
							CastSpell(10+i, target)
						end
					end
				end
			end
		end	
	--Cleanse
		cleanseList = {
		"stun", "Stun", "Fear", "taunt", "LuxLightBindingMis", "Wither", "SonaCrescendo", "RunePrison", 
		"DarkBindingMissile", "caitlynyordletrapdebuff", "EnchantedCrystalArrow", "CurseoftheSadMummy", "LuluWTwo", "fizzmarinerdoombomb"
		 }
		if string.find(sums[i], "SummonerBoost") ~= nil then
			if player:CanUseSpell(10+i) == READY then
				for k = 1, player.buffCount, 1 do
					for j = 1, #cleanseList, 1 do
						if player:getBuff(k) == cleanseList[j] then
							CastSpell(10+i)
						end
					end
				end
			end
		end	
	--Exhaust (very stupid version)
		if string.find(sums[i], "SummonerExhaust") ~= nil then
			if player:CanUseSpell(10+i) == READY then
				for j = 1, heroManager.iCount do
                	local target = heroManager:GetHero(j)
					if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false and player:GetDistance(target) < 550 then
						if target.health/target.maxHealth < exhaustLimit then
							for k = 1, heroManager.iCount do
								local target2 = heroManager:GetHero(k)
								if target2 ~= nil and target2.visible == true and target2.team == player.team and target2.dead == false and player:GetDistance(target2) < 550 then
									CastSpell(10+i, target)
								end
							end
						end
					end
				end
			end
		end	
	--Ghost
		if string.find(sums[i], "SummonerHaste") ~= nil then
			if player:CanUseSpell(10+i) == READY then
				for j = 1, heroManager.iCount do
                	local target = heroManager:GetHero(j)
					if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false and player:GetDistance(target) < 850 then
						if target.health/target.maxHealth > player.health*1.66/player.maxHealth then
							ghostFlag = false
							for k = 1, heroManager.iCount do
								local target2 = heroManager:GetHero(k)
								if target2 ~= nil and target2.visible == true and target2.team == player.team and target2.dead == false and player:GetDistance(target2) < 600 then
								else
									ghostFlag = true
								end
							end
							if ghostFlag then
								CastSpell(10+i)
							end
						end
					end
				end
			end
		end			
	--CV
		if string.find(sums[i], "SummonerClairvoyance") ~= nil then
			if player:CanUseSpell(10+i) == READY then
				visibleFlag = false
				for j = 1, heroManager.iCount do
                	local target = heroManager:GetHero(j)
					if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false then
						visibleFlag = true
					end
				end
				if visibleFlag == false then
					CastSpell(10+i, 4835, 9591) --baron
				end
				for j = 1, heroManager.iCount do
                	local target = heroManager:GetHero(j)
                	if target ~= nil and target.team ~= player.team and target.dead == false and target.visible == false then
                		CastSpell(10+i. target.x, target.z)
                	end
                end
			end
		end	
		
	end
end
     
    
     
PrintChat(" >> Auto SummonerSpells loaded!")