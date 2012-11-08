--[[
Darius Ownage
v1.1
written by Weee
Modified by Delusional Logic
]]
 require "AllClass"
--[[ Config ]]
qHK = 90 -- Hotkey for perfect Q harass (default: Z)
cHK = 67 -- Hotkey for perfect E (default: C)
useExecutioner = true -- calculate Executioner or not? True / False
havocPoints = 3 -- how many points in Havoc? 0 / 1 / 2 / 3
 
--[[ Advanced Config ]]
targetFindRange = 80 -- This is a distance between targeted spell coordinates and your real target's coordinates.
qBladeRange = 270
qRange = 425
eRange = 550
rRange = 475
wDmgRatioPerLvl = 0.2
rDmgRatioPerHemo = 0.2
hemoTimeOut = 5000
 
 
--[[ Globals ]]
enemyToAttack = nil
enemyTable = {}
scriptActive = false
cActive = false
player = GetMyHero()
 
hemoTable = {
    [1] = "Data\\Particles\\darius_hemo_counter_01.troy",
    [2] = "Data\\Particles\\darius_hemo_counter_02.troy",
    [3] = "Data\\Particles\\darius_hemo_counter_03.troy",
    [4] = "Data\\Particles\\darius_hemo_counter_04.troy",
    [5] = "Data\\Particles\\darius_hemo_counter_05.troy",
}
 
damageTable = {
    Q = { base = 35, baseScale = 35, adRatio = 0.7, },
    R = { base = 70, baseScale = 90, adRatio = 0.75, },
}
 
 
--[[ Code ]]
  

 
function OnWndMsg( msg, keycode )
                if msg == KEY_DOWN then 
                	if keycode == qHK then
                		if scriptActiveZ then
                			scriptActiveZ = false
                			PrintChat(" >> Perfect Q disabled!")  
                		else
                	    	scriptActiveZ = true
                        	PrintChat(" >> Perfect Q enabled!")
                        end     
                    end
                end
                if msg == KEY_DOWN then 
                	if keycode == cHK then
                		if cActive then
                			cActive = false
                			PrintChat(" >> Perfect E disabled!")  
                		else
                	    	cActive = true
                        	PrintChat(" >> Perfect E enabled!")
                        end     
                    end
                end
    

end
 
function OnTick()
    local rDmg = (damageTable.R.base + (damageTable.R.baseScale*player:GetSpellData(_R).level) + damageTable.R.adRatio*player.addDamage)
    local qDmg = damageTable.Q.base + (damageTable.Q.baseScale*player:GetSpellData(_Q).level) + damageTable.Q.adRatio*player.addDamage
    for i, enemy in pairs(enemyTable) do
        if (GetTickCount() - enemy.hemo.tick > hemoTimeOut) or (enemy and enemy.dead) then enemy.hemo.count = 0 end
        if enemy and not enemy.dead and enemy.visible then
            local scale = 1 + havocPoints*0.005
            if useExecutioner and enemy.health < enemy.maxHealth*0.4 then scale = scale + 0.06 end
            qDmg = player:CalcDamage(enemy,qDmg)
            if scriptActiveZ and player:CanUseSpell(_Q) == READY and GetDistance(enemy,player) < qRange and GetDistance(enemy,player) >= qBladeRange then CastSpell(_Q) end
            if cActive and player:CanUseSpell(_E) == READY and GetDistance(enemy,player) < eRange then CastSpell(_E,enemy.x,enemy.z) end
            if GetTickCount() - enemy.pauseTickQ >= 500 and GetTickCount() - enemy.pauseTickR >= 200 then
                if qDmg * scale > enemy.health and player:CanUseSpell(_Q) == READY and GetDistance(enemy,player) < qRange then
                    CastSpell(_Q)
                    enemy.pauseTickQ = GetTickCount()
                elseif ( qDmg * 1.5 ) * scale > enemy.health and player:CanUseSpell(_Q) == READY and GetDistance(enemy,player) < qRange and GetDistance(enemy,player) >= qBladeRange then
                    CastSpell(_Q)
                    enemy.pauseTickQ = GetTickCount()
                elseif rDmg * ( 1.0 + rDmgRatioPerHemo * enemy.hemo.count ) > enemy.health and player:CanUseSpell(_R) == READY and GetDistance(enemy,player) < rRange then
                    CastSpell(_R,enemy)
                    enemy.pauseTickR = GetTickCount()
                end
            end
        end
    end
end
 
function OnCreateObj( object )
    if object and string.find(string.lower(object.name),"darius_hemo_counter") then
        for i, enemy in pairs(enemyTable) do
            if enemy and not enemy.dead and enemy.visible and GetDistance(enemy,object) <= targetFindRange then
                for k, hemo in pairs(hemoTable) do
                    if object.name == hemo then enemy.hemo.tick = GetTickCount() enemy.hemo.count = k end
                end
            end
        end
    end
end

if player.charName == "Darius" then
    --if player:GetSpellData(SUMMONER_1).name == "SummonerSmite" or player:GetSpellData(SUMMONER_2).name == "SummonerSmite" then
        --useExecutioner = false
    --end
    for i=0, heroManager.iCount, 1 do
        local playerObj = heroManager:GetHero(i)
        if playerObj and playerObj.team ~= player.team then
            playerObj.hemo = { tick = 0, count = 0, }
            playerObj.pauseTickQ = 0
            playerObj.pauseTickR = 0
            table.insert(enemyTable,playerObj)
        end
    end
end