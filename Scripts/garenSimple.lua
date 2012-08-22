if GetMyHero().charName == "Garen" then
--[[
    Garen Simple Ult by ikita
]]
 
--[[            Config          ]]
 
--Mode Settings
local player = GetMyHero()
--[[            Code            ]]
     
local function Timer() 
        local players = heroManager.iCount
        for i = 1, players, 1 do
            local target = heroManager:getHero(i)
            local rDmg
            if player:GetSpellData(_R).level<1 then 
            	rDmg=0 
            else 
            	rDmg = math.floor(player:CalcMagicDamage(target, (target.maxHealth - target.health) / (3.5 - ((player:GetSpellData(_R).level - 1) * .5)) + (player:GetSpellData(_R).level * 175)))
            end
            if target.health < rDmg and player:GetDistance(target) < 400 and player:CanUseSpell(_R) == READY then
                CastSpell(_R, target)
            end
        end
    
end
     
        if player.charName == "Garen" then
            BoL:addTickHandler(Timer,50)
            PrintChat(" >> Garen Ultimate Helper loaded!")
        end
end