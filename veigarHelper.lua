if player.charName == "Veigar" then

--[[
                    Veigar Helper v1.8d by ikita
                    Based on Veiger Helper v0.7 by NewHotness
                    Inspired by llama's fpb veigar script and this script uses his stun calculations. Many thanks !
                    

                    Also thanks to Burn who helped me out when I am stuck.
                    And BoL community for suggestions and reports
                    
                    Script is very clumsy and poorly structured. Any help / suggestion to clean up is welcome !
            ]]
             
        --STUFF AND OTHER THINGS      
            local player = GetMyHero()
            local scriptActive = false
            local cageActive = false
            local ECastActive = false
            local DFGId = 3128
            local qMinionsActive = false
            local QHarassActive = false
            -- AM I DOING THIS RIGHT :D ?
            local killable = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
            local killableRdy = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
            local killableRdyW = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
            local eradius=350  -- event horizon's radius has bounds from 300 to 400
            local erange=600
            local ecastspeed=0.5 -- 0.5 second cast delay
            local nukeIncluesWToggle = true --Spacebar includes W when game initiates if true.
            local objectOfStun = nil
            local invSlot = nil
         	local KEY_DOWN = 0x100
         	local KEY_UP = 0x101
         	local hero2
         	local victim
           
        --BASIC OPTIONS
            --HOTKEYS
            local HK = 32                                             -- Spacebar to NUKE (PANIC KEY)
            local nukeIncluesWToggleKey = 118                 	     -- F7 to enable/disable: Include W in your Spacebar combo
            local qMinionKey = 67                                    -- C to enable/disable: Q minions with Q
            local EHK = 69                                            -- E  to AUTO - STUN
            local cageAll = 71                                        -- G  to Encircle as many as possible with E
            local harassHK = 90                                       -- Z  to Auto Q enemy in range
           
            --FUNCTIONS
            local steal = true                                        --Casts spells on killable targets (Not including W). Why would you set it to false
            local wOnStun = true                                      --If enemy within range is stunned W is casted at enemy
            local nukeOnStun = false                                  --autocast on all stunned targets
            local drawKillable = true                                 --Draw Green/Blue Circle and Kill-Combo Text if killable
            local eSmartcast = true                                   --Press E to SMARTCast on target nearest mouse location
            local drawSelfRange = false                               --Draw spell ranges for Veigar
            
           
            --OTHER STUFF
            local circleThickness = 20                                --Set Circle thickness for Killable Enemies.
           
        --FUNCTIONS
            function altDoFile(name)
                dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)end
                altDoFile("libs/TimingLib.lua")
                altDoFile("libs/mec.lua")
                altDoFile("libs/circle.lua")
                altDoFile("libs/vector.lua")  
               
                local targetNum = 0
                local timer = Timer:new()
               
            function OnTick()

                                timer:tickHandler()
                    
             
                    invSlot = findItemSlotInInventory(DFGId)
             
                    for i = 1, heroManager.iCount do
                            local target = heroManager:GetHero(i)
                            local qDmg = player:CalcMagicDamage(target, 45*(player:GetSpellData(_Q).level-1)+80+ (.6*player.ap))
                            local wDmg = player:CalcMagicDamage(target, 50*(player:GetSpellData(_W).level-1)+120+ (1*player.ap))
                            local rDmg = player:CalcMagicDamage(target, 125*(player:GetSpellData(_R).level-1)+250+ (1.2*player.ap) + (.8 * target.ap))
                            local dfgDmg = 0
                           
                            if player:GetSpellData(_Q).level == 0 then
                                    qDmg = 0
                            end
                            if player:GetSpellData(_W).level == 0 then
                                    wDmg = 0
                            end
                            if player:GetSpellData(_R).level == 0 then
                                    rDmg = 0
                            end
                           
                            if invSlot ~= nil then
                                    dfgDmg = player:CalcMagicDamage(target,(.25+(.04*(math.floor(player.ap/100))))*target.health)
                            end
                            if dfgDmg < 200 then
                                    dfgDmg = 200
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
                                            elseif rDmg > target.health then
                                                    PrintFloatText(target,0,"R")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_R) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + dfgDmg > target.health then
                                                    PrintFloatText(target,0,"Q+DFG")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + rDmg > target.health then
                                                    PrintFloatText(target,0,"Q+R")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_R) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif dfgDmg + rDmg > target.health then
                                                    PrintFloatText(target,0,"DFG+R")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + dfgDmg + rDmg > target.health then
                                                    PrintFloatText(target,0,"Q+DFG+R")
                                                    killable[i] = true
                                                    killableRdyW[i] = false
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY then
                                                            killableRdy[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                    end
                                            elseif qDmg + wDmg > target.health then
                                                    PrintFloatText(target,0,"Q+W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif dfgDmg > target.health then
                                                    PrintFloatText(target,0,"DFG+W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif rDmg + wDmg > target.health then
                                                    PrintFloatText(target,0,"R+W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif qDmg + dfgDmg + wDmg > target.health then
                                                    PrintFloatText(target,0,"Q+DFG+W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif qDmg + rDmg + wDmg > target.health then
                                                    PrintFloatText(target,0,"Q+R+W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif dfgDmg + rDmg + wDmg > target.health then
                                                    PrintFloatText(target,0,"DFG+R+W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif qDmg + dfgDmg + rDmg + wDmg > target.health then
                                                    PrintFloatText(target,0,"Q+DFG+R+W")
                                                    killable[i] = true
                                                    if player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY and player:CanUseSpell(_Q) == READY then
                                                            killableRdy[i] = true
                                                            killableRdyW[i] = true
                                                    elseif true then
                                                            killableRdy[i] = false
                                                            killableRdyW[i] = false
                                                    end
                                            elseif true then
                                                            PrintFloatText(target,0,"" .. math.ceil(target.health - (qDmg + dfgDmg + rDmg + wDmg)) .. " hp")
                                                    killable[i] = false
                                                    killableRdy[i] = false
                                                    killableRdyW[i] = false
                                            end
                                    end
                            end
                           
                           
                            x = mousePos.x
                            z = mousePos.z
                           
                            if target ~= nil and target.team ~= player.team and scriptActive == true then
                                    if nukeIncluesWToggle then
                                        CastSpell(_W, x, z)
                                    end
                                    hero = findHeroNearestMouse()
                                    if invSlot ~= nil then
                                            CastSpell(invSlot, hero)
                                    end
                                    CastSpell(_R, hero)
                                    CastSpell(_Q, hero)
                                    scriptActive = false
                            end
                           
                            if target ~= nil and target.visible and target.team ~= player.team and player:GetDistance(target) < 650 and not target.dead then
                                    if steal then
                                            if qDmg > target.health and player:CanUseSpell(_Q) == READY then
                                                    CastSpell(_Q, target)
                                            elseif invSlot ~= nil and dfgDmg > target.health and player:CanUseSpell(invSlot) == READY then
                                                    CastSpell(invSlot, target)
                                            elseif rDmg > target.health and player:CanUseSpell(_R) == READY then
                                                    CastSpell(_R, target)
                                            elseif invSlot ~= nil and qDmg + dfgDmg > target.health and player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY then
                                                    CastSpell(invSlot, target)
                                                    CastSpell(_Q, target)
                                            elseif qDmg + rDmg > target.health and player:CanUseSpell(_Q) == READY and player:CanUseSpell(_R) == READY then
                                                    CastSpell(_Q, target)
                                                    CastSpell(_R, target)
                                            elseif invSlot ~= nil and dfgDmg + rDmg > target.health and player:CanUseSpell(_R) == READY and player:CanUseSpell(invSlot) == READY then
                                                    CastSpell(invSlot, target)
                                                    CastSpell(_R, target)
                                            elseif  invSlot ~= nil and qDmg + dfgDmg + rDmg > target.health and player:CanUseSpell(_Q) == READY and player:CanUseSpell(invSlot) == READY and player:CanUseSpell(_R) == READY then
                                                    CastSpell(invSlot, target)
                                                    CastSpell(_Q, target)
                                                    CastSpell(_R, target)
                                            end
                                    end
                                    if QHarassActive and player:CanUseSpell(_Q) == READY then
                                    	CastSpell(_Q, target)
                                    end
                            end
                           
                           
                            if target ~= nil and target.team ~= player.team and target.dead == false then
                                    if nukeOnStun or wOnStun then
     
     
                                                                                    if objectOfStun ~= nil and objectOfStun:GetDistance(target) <= 100 then
                                                            if wOnStun and player:GetDistance(target) < 900 then
                                                                    CastSpell(_W, target)
                                                            end
                                                            if nukeOnStun and player:GetDistance(target) < 650 then
                                                                    if invSlot ~= nil then
                                                                            CastSpell(invSlot, target)
                                                                    end
                                                                    CastSpell(_R, target)
                                                                    CastSpell(_Q, target)
                                                            end
                                                   objectOfStun = nil
                                                                                    end
     
                                    end
                            end     
                    end
                   
            
             
                    if qMinionsActive then
                            for k = 1, objManager.maxObjects do
                                    local minionObject = objManager:GetObject(k)
                                    if minionObject ~= nil and minionObject.team ~= player.team and minionObject.dead == false then
                                            if  player:GetDistance(minionObject) < 650 and minionObject.health <= player:CalcMagicDamage(minionObject, 45*(player:GetSpellData(_Q).level-1)+80+ (.6*player.ap)) then
                                                    CastSpell(_Q, minionObject)
                                            end
                                    end
                            end
                    end
                   
                   
                   
                   
                    hero2 = findHeroNearestMouse()
                    if ECastActive == true and player:GetDistance(hero2) < (eradius+erange) then
                                        CastESingleTarget(hero2)
                                        ECastActive = false
                                end
                   
                        if cageActive == true then
                                        spellPos = FindGroupCenterFromNearestEnemies(eradius,erange)
                                        if spellPos ~= nil then
                                                CastSpell(_E,spellPos.center.x,spellPos.center.z)
                                        end
                                        cageActive = false
                                end
                                

            end
           
                          function OnCreateObj(object121)


                for i = 1, heroManager.iCount do
                local target2 = heroManager:GetHero(i)
                                    if target2 ~= nil and object121 ~= nil and object121.name == "Stun_glb.troy" and target2:GetDistance(object121) <= 100 and target2.team ~= player.team and target2.dead == false then
                                                        if nukeOnStun or wOnStun then
     
     
     
                                                            if wOnStun and player:GetDistance(target2) < 900 then
                                                                    CastSpell(_W, target2)
                                                            end
                                                            if nukeOnStun and player:GetDistance(target2) < 650 then
                                                                    if invSlot ~= nil then
                                                                            CastSpell(invSlot, target2)
                                                                    end
                                                                    CastSpell(_R, target2)
                                                                    CastSpell(_Q, target2)
                                                            end
     
     
                                    end
                                    end
                            end
                    end
           
           
           
            function CastESingleTarget(hero2)
                        if(hero2 ~= nil ) and eSmartcast and player:CanUseSpell(_E) == READY and not hero2.dead then
                                for i = 1, heroManager.iCount do
                        victim = heroManager:GetHero(i)
                        if victim.name == hero2.name then
                                targetNum = i
                        end
                    end
                                --I have no idea how this line works
                                local targetNextMove = timer:predictMovement(targetNum, ecastspeed)
         
                                        local px=player.x
                                        local pz=player.z
                                        local r=eradius
                                        local sgn=0
                                        local CircX=0
                                        local CircZ=0
               
                                        px=px-targetNextMove.x
                                        pz=pz-targetNextMove.z  
         
                                        local tx=0
                                        local tz=0
         
                                        local dr = math.sqrt((px)^2+(pz)^2)
         
                                        if (-pz < 0) then
                                                sgn= -1
                                        else
                                                sgn= 1
                                        end
         
                                        local xplus=(sgn*(-px)*math.sqrt((r^2)*(dr^2)))/(dr^2)
                                        local xmin=(-sgn*(-px)*math.sqrt((r^2)*(dr^2)))/(dr^2)
                       
                                        local zplus=(math.abs(pz)*math.sqrt((r^2)*(dr^2)))/(dr^2)
                                        local zmin=(-math.abs(pz)*math.sqrt((r^2)*(dr^2)))/(dr^2)
         
                                        px=px+targetNextMove.x
                                        pz=pz+targetNextMove.z
         
                                        xplus = xplus + targetNextMove.x
                                        zplus = zplus + targetNextMove.z
                                        xmin = xmin + targetNextMove.x
                                        zmin = zmin + targetNextMove.z
         
                                        local dplus = math.sqrt((xplus - px)^2 + (zplus - pz)^2)
                                        local dmin = math.sqrt((xmin - px)^2 + (zmin - pz)^2)
         
                                        if dplus <= dmin then
                                                CircX=xplus
                                                CircZ=zplus
                                        else
                                                CircX=xmin
                                                CircZ=zmin
                                        end
                                        CastSpell(_E, CircX,CircZ)
                               
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
             
             
             
            function OnWndMsg(msg,key)
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
                --Ecast
                if msg == KEY_DOWN then
                                if key == EHK then
                        ECastActive = true
                        end
                else
                        if key == EHK then
                                ECastActive = false
                        end
                end
                --Toggle W in nuke
                if msg == KEY_DOWN then
                                if key == nukeIncluesWToggleKey then
                        if nukeIncluesWToggle then
                                nukeIncluesWToggle = false
                                PrintChat(" >> Nuke does not include W !")
                        else
                                nukeIncluesWToggle = true
                                PrintChat(" >> Nuke includes W !")
                        end
                        end
                end
                --Cage All
                if msg == KEY_DOWN then
                        if key == cageAll then
                        		cageActive = true
                        end
                end
                if msg == KEY_UP then
                        if key == cageAll then
                                cageActive = false
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
           
            function OnDraw()
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
                            DrawCircle(player.x,player.y,player.z,650,0x19A712) --Q range & color: green
                                DrawCircle(player.x,player.y,player.z,900,0xEA3737) --W range & color: orange
                                DrawCircle(player.x,player.y,player.z,950,0xB820C3) --E range & color: purple [erange+eradius]
                        end
            end
             
             

     
            if player.charName == "Veigar" then
                    PrintChat(" >> Veigar Helper Loaded.")
            else
                       
            end
end