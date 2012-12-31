if GetMyHero().charName == "LeeSin" then
--[[
    Lee Sin Simple Ult (sometimes with Q) by ikita
]]
 
--[[            Config          ]]
--None

local player = GetMyHero()
local qTar
--[[            Code            ]]
   
     
function OnCreateObj(object)
	if object.name == "blindMonk_Q_resonatingStrike_tar.troy" then
		qTar = nil
	    local players = heroManager.iCount
        for i = 1, players, 1 do
        	local target = heroManager:getHero(i)
        	if target:GetDistance(object) < 100 then
        		qTar = target
        	end
        end
	end
end

function OnTick() 
--With Q
	if qTar ~= nil then
        local rDmg
        if player:GetSpellData(_R).level<1 then 
        	rDmg=0 
        else 
        	rDmg = player:CalcDamage(qTar, ((player:GetSpellData(_R).level)*200 + player.addDamage*2))
        end
        local qDmg = player:CalcDamage(qTar, (((qTar.maxHealth - (qTar.health - rDmg))/qTar.maxHealth)*0.08) + (player:GetSpellData(_Q).level-1)*30 + 50 + 0.9*player.addDamage)
        if player:GetSpellData(_Q).name == "blindmonkqtwo" and qTar.visible == true and qTar.team ~= player.team and qTar.dead == false and qTar.health < rDmg + qDmg and player:GetDistance(qTar) < 375 and player:CanUseSpell(_R) == READY and player:CanUseSpell(_Q) == READY and player.mana > 30 then
            CastSpell(_R, qTar)
            CastSpell(_Q)
        end
	end
--Ult only
    local players = heroManager.iCount
    for i = 1, players, 1 do
        local target = heroManager:getHero(i)
        local rDmg
        if player:GetSpellData(_R).level<1 then 
        	rDmg=0 
        else 
        	rDmg = player:CalcDamage(target, ((player:GetSpellData(_R).level)*200 + player.addDamage*2))
        end
        if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false and target.health < rDmg and player:GetDistance(target) < 375 and player:CanUseSpell(_R) == READY then
            CastSpell(_R, target)
        end
    end
    
end
     
         PrintChat(" >> LeeSin Ultimate Helper loaded!")
end