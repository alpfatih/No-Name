if GetMyHero().charName == "Leblanc" then

--[[
                    Leblanc Helper v1.0b by ikita
                    Based on Veiger Helper v0.7 by NewHotness
                    

                    Thanks to BoL community for suggestions and reports
                    
                    Script is very clumsy and poorly structured. Any help / suggestion to clean up is welcome !
            ]]
             
        --STUFF AND OTHER THINGS      
            local player = GetMyHero()
            local scriptActive = false
            local DFGId = 3128
            local qMinionsActive = false
            local QHarassActive = false
            -- AM I DOING THIS RIGHT :D ?
            local killable = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
            local killableRdy = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
            local killableRdyW = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
            local invSlot = nil
         	local KEY_DOWN = 0x100
         	local KEY_UP = 0x101
			local lastSpell = ":D"
           
        --BASIC OPTIONS
            --HOTKEYS
            local HK = 32                                             -- Spacebar to NUKE (PANIC KEY)
            local qMinionKey = 119                                    -- F8 to enable/disable: Q minions with Q
            local harassHK = 90                                       -- Z  to Auto Q enemy in range
           
            --FUNCTIONS
            local steal = true                                        --Casts spells on killable targets (Not including W). Why would you set it to false
            local drawKillable = true                                 --Draw Green/Blue Circle and Kill-Combo Text if killable
            local drawSelfRange = false                               --Draw spell ranges for Veigar
            
           
            --OTHER STUFF
            local circleThickness = 20                                --Set Circle thickness for Killable Enemies.
           
        --FUNCTIONS           
            
               
               
               
            function Spell(object, spellName)
            	if object.name == player.name and (spellName == "LeblancChaosOrb" or spellName == "LeblancSlide" or spellName == "LeblancSoulShackle") then
                	lastSpell = spellName
                	lastSpellUlt = spellName
            	end
            	if object.name == player.name and spellName == "LeblancChaosOrbM" then
                	lastSpellUlt = spellName
            	end
            end
            
            function tickHandler()
                    
             
                    invSlot = findItemSlotInInventory(DFGId)
             
                    for i = 1, heroManager.iCount do
                            local target = heroManager:GetHero(i)
                            local qDmg = player:CalcMagicDamage(target, 40*(player:GetSpellData(_Q).level-1)+70+ (.6*player.ap))
                            local wDmg = player:CalcMagicDamage(target, 40*(player:GetSpellData(_W).level-1)+85+ (.6*player.ap))
                            local qProc = player:CalcMagicDamage(target, 20*(player:GetSpellData(_Q).level-1)+20+ (.3*player.ap))
                            local rqDmg = player:CalcMagicDamage(target, (40*(player:GetSpellData(_Q).level-1)+70+ (.6*player.ap))*((((player:GetSpellData(_R).level-1)*15+10)/100)+1))
                            local rwDmg = player:CalcMagicDamage(target, (40*(player:GetSpellData(_W).level-1)+85+ (.6*player.ap))*((((player:GetSpellData(_R).level-1)*15+10)/100)+1))
                            local rqProc = player:CalcMagicDamage(target, (20*(player:GetSpellData(_Q).level-1)+20+ (.3*player.ap))*((((player:GetSpellData(_R).level-1)*15+10)/100)+1))
                            local dfgDmg = 0
                           
                            if player:GetSpellData(_Q).level == 0 then
                                    qDmg = 0
                                    qProc = 0
                            end
                            if player:GetSpellData(_W).level == 0 then
                                    wDmg = 0
                            end
                            if player:GetSpellData(_R).level == 0 then
                                    rqDmg = 0
                                    wqDmg = 0
                                    rqProc = 0
                            end
                           
                            if invSlot ~= nil then
                                    dfgDmg = player:CalcMagicDamage(target,(.25+(.04*(math.floor(player.ap/100))))*target.health)
                            end
                            if invSlot ~= nil and (.25+(.04*(math.floor(player.ap/100))))*target.health < 200 then
                                    dfgDmg = player:CalcMagicDamage(target,200)
                            end
                            if invSlot == nil then
                                    dfgDmg = 0
                            end
                           
                            if drawKillable then
                                    if target.team ~= player.team and target.visible and not target.dead then
                                            if qDmg > target.health then
                                                    PrintFloatText(target,0,"Q")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif dfgDmg > target.health then
                                                    PrintFloatText(target,0,"DFG")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(invSlot) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif rqDmg > target.health then
                                                    PrintFloatText(target,0,"R(q)")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_R) == READY and lastSpell == "LeblancChaosOrb" then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + dfgDmg > target.health then
                                                    PrintFloatText(target,0,"DFG > Q")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + rqDmg + qProc > target.health then
                                                    PrintFloatText(target,0,"Q > R")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_R) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + rqDmg + rqProc > target.health then
                                                    PrintFloatText(target,0,"R > Q")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_R) == READY and lastSpell == "LeblancChaosOrb" then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif dfgDmg + rqDmg > target.health then
                                                    PrintFloatText(target,0,"DFG > R")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY and lastSpell == "LeblancChaosOrb" then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + dfgDmg + rqDmg + qProc > target.health then
                                                    PrintFloatText(target,0,"DFG > Q > R")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + dfgDmg + rqDmg + rqProc > target.health then
                                                    PrintFloatText(target,0,"DFG > R > Q")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY and lastSpell == "LeblancChaosOrb" then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + wDmg + qProc > target.health then
                                                    PrintFloatText(target,0,"Q > W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif dfgDmg + wDmg > target.health then
                                                    PrintFloatText(target,0,"DFG > W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif rqDmg + wDmg + rqProc > target.health then
                                                    PrintFloatText(target,0,"R > W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY and lastSpell == "LeblancChaosOrb" then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif qDmg + dfgDmg + wDmg + qProc > target.health then
                                                    PrintFloatText(target,0,"DFG > Q > W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif qDmg + rqDmg + wDmg + qProc + rqProc > target.health then
                                                    PrintFloatText(target,0,"Q > R > W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif dfgDmg + rqDmg + wDmg + rqProc > target.health then
                                                    PrintFloatText(target,0,"DFG > R > W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY and lastSpell == "LeblancChaosOrb" then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif qDmg + dfgDmg + rqDmg + wDmg + qProc + rqProc > target.health then
                                                    PrintFloatText(target,0,"DFG > Q > R > W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY and player:CanUseSpell(_Q) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif true then
                                                    PrintFloatText(target,0,"" .. math.ceil(target.health - (qDmg + dfgDmg + rqDmg + wDmg + qProc + rqProc)) .. " hp")
                                                    killable[i] = false
                                                    killableRdy[i] = false
                                                    killableRdyW[i] = false
                                            end
                                            
                                    end
                            end
                           
                           
                            x = mousePos.x
                            z = mousePos.z
                           
                            if target ~= nil and target.team ~= player.team and scriptActive == true then
                                    hero = findHeroNearestMouse()
                                    if invSlot ~= nil then
                                            CastSpell(invSlot, hero)
                                    end
                                    if lastSpell == "LeblancChaosOrb" then
                                    	CastSpell(_R, hero)
                                    	CastSpell(_Q, hero)
                                    	if lastSpell == "LeblancChaosOrb" then
                                   			CastSpell(_W, x, z)
                                   		end
                                   	else
                                   		CastSpell(_Q, hero)
                                    end
                                    scriptActive = false
                            end
                           
                            if target ~= nil and target.visible and target.team ~= player.team and player:GetDistance(target) < 700 and not target.dead then
                                    if steal then
                                            if qDmg > target.health and player:CanUseSpell(_Q) == READY then
                                                    CastSpell(_Q, target)
                                            elseif invSlot ~= nil and dfgDmg > target.health and player:CanUseSpell(invSlot) == READY and player:GetDistance(target) < 650 then
                                                    CastSpell(invSlot, target)
                                            elseif rqDmg > target.health and player:CanUseSpell(_R) == READY and lastSpell == "LeblancChaosOrb" then
                                                    CastSpell(_R, target)
                                            elseif invSlot ~= nil and qDmg + dfgDmg > target.health and player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:GetDistance(target) < 650 then
                                                    CastSpell(invSlot, target)
                                                    CastSpell(_Q, target)
                                            elseif qDmg + rqDmg + qProc > target.health and player:CanUseSpell(_Q) == READY and player:CanUseSpell(_R) == READY then
                                                    CastSpell(_Q, target)
                                                    CastSpell(_R, target)
                          					elseif qDmg + rqDmg + rqProc > target.health and player:CanUseSpell(_Q) == READY and player:CanUseSpell(_R) == READY and lastSpell == "LeblancChaosOrb" then
                                                    CastSpell(_R, target)
                                                    CastSpell(_Q, target)
                                            elseif invSlot ~= nil and dfgDmg + rqDmg > target.health and player:CanUseSpell(_R) == READY and player:CanUseSpell(invSlot) == READY and lastSpell == "LeblancChaosOrb" and player:GetDistance(target) < 650 then
                                                    CastSpell(invSlot, target)
                                                    CastSpell(_R, target)
                                            elseif  invSlot ~= nil and qDmg + dfgDmg + rqDmg + qProc > target.health and player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY and player:GetDistance(target) < 650 then
                                                    CastSpell(invSlot, target)
                                                    CastSpell(_Q, target)
                                                    CastSpell(_R, target)
                                            elseif  invSlot ~= nil and qDmg + dfgDmg + rqDmg + rqProc > target.health and player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY and lastSpell == "LeblancChaosOrb" and player:GetDistance(target) < 650 then
                                                    CastSpell(invSlot, target)
                                                    CastSpell(_R, target)
                                                    CastSpell(_Q, target)
                                            end
                                    end
                                    
                                    if QHarassActive and player:CanUseSpell(_Q) == READY then
                                    	CastSpell(_Q, target)
                                    end
                            end
                           
                    end
                   
            
             
                    if qMinionsActive then
                            for k = 1, objManager.maxObjects do
                                    local minionObject = objManager:GetObject(k)
                                    if minionObject ~= nil and minionObject.team ~= player.team and string.find(minionObject.name,"Minion_") == 1 and minionObject.dead == false then
                                            if  player:GetDistance(minionObject) < 700 and minionObject.health <= player:CalcMagicDamage(minionObject, 40*(player:GetSpellData(_Q).level-1)+70+ (.6*player.ap)) then
                                                    CastSpell(_Q, minionObject)
                                            end
                                    end
                            end
                    end       
                    
            end
           
 
   
            function findHeroNearestMouse()
                    local closest
                    for i = 1, heroManager.iCount do
                            local target = heroManager:GetHero(i)
                            if target ~= nil and target.team ~= player.team then
                                    if (distanceFromMouse(target) < distanceFromMouse(closest) or closest == nil) then
                                            closest = target
                                    end
                            end
                    end
                    return closest
            end
             
            function distanceFromMouse(target)
                    x = mousePos.x
                    z = mousePos.z
                    if target ~= nil then
                            return math.floor(math.sqrt((target.x-x)*(target.x-x) + (target.z-z)*(target.z-z)))
                    else return 5000
                    end
            end
             
            function findItemSlotInInventory( item )
                local ItemSlot = {ITEM_1,ITEM_2,ITEM_3,ITEM_4,ITEM_5,ITEM_6,}
                for i=1, 6, 1 do
                    if player:getInventorySlot(ItemSlot[i]) == item then return ItemSlot[i] end
                end
            end
             
             
             
            function Hotkey(msg,key)
                if msg == KEY_DOWN then
                    --key down
                    if key == HK then
                        scriptActive = true
                    end
                end
                if msg == KEY_UP then
                    if key == HK then
                        scriptActive = false
                    end
                end
                --Minionkey
                if msg == KEY_DOWN then 
                	if key == qMinionKey then
                		if qMinionsActive then
                			qMinionsActive = false
                			PrintChat(" >> Auto Q minions disabled!")  
                		else
                	    	qMinionsActive = true
                        	PrintChat(" >> Auto Q minions enabled!")
                        end     
                    end
                end       

                
                --Toggle Q harass
                if msg == KEY_DOWN then
                                if key == harassHK then
                        if QHarassActive then
                                QHarassActive = false
                                PrintChat(" >> Auto Q enemy in range disabled!")
                        else
                                QHarassActive = true
                                PrintChat(" >> Auto Q enemy in range enabled!")
                        end
                        end
                end
                
               
            end
           
            function Drawer()
                    for i = 1, heroManager.iCount do
                            local target = heroManager:GetHero(i)
                           
                            if killableRdyW[i] and target.visible and not target.dead then
                                for j = 0, circleThickness do  
                                    DrawCircle(target.x,target.y,target.z,200+j*2,0x0000FF)
                                end
                            elseif killableRdy[i] and target.visible and not target.dead then
                                for j = 0, circleThickness do  
                                    DrawCircle(target.x,target.y,target.z,200+j*2,0x33FF00)
                                end
                            elseif killable[i] and target.visible and not target.dead then
                                for j = 0, circleThickness do  
                                    DrawCircle(target.x,target.y,target.z,200+j*2,0xFF0000)
                                end
                            end
                    end
           
                        if drawSelfRange then
                            	DrawCircle(player.x,player.y,player.z,700,0x19A712) --Q range & color: green
                                DrawCircle(player.x,player.y,player.z,850,0xEA3737) --W range & color: orange
                                DrawCircle(player.x,player.y,player.z,950,0xB820C3) --E range & color: purple
                        end
            end
             
             

     
     
            if player.charName == "Leblanc" then
                    BoL:addTickHandler(tickHandler,50)
                    BoL:addMsgHandler(Hotkey)
                    PrintChat(" >> Leblanc Helper Loaded.")
                    BoL:addDrawHandler(Drawer)
                    BoL:addProcessSpellHandler(Spell)
            else
                       
            end
end