--[[
            turnAround v1.1 by Ryan! n_n Credits mostly to h0nda, barasia283, ikita, and yours truly.
            This script will face you in the direction of Tryndamere's Mocking Shout and opp. direction of Cassiopeia's Petrifying Gaze.
            Then it will continue walking to the previous location directed by you, if you had done so.
            
            Updated for BoL by ikita
    ]]
    function altDoFile(name)
    dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)end
    altDoFile("libs/vector.lua")
     
    --[[     GLOBALS     ]]--
    delay = 850
    player = GetMyHero()
    lastRightClick = {x = nil, y = nil, z = nil}
    lastPlayerPos = {x = nil, y = nil}
     
    function SpellTick(objectSpell,spellName,spellLevel, x1, y1, z1, x2, y2, z2)
            if objectSpell ~= nil and objectSpell.team==TEAM_ENEMY then
                    if spellName == "CassiopeiaPetrifyingGaze" and player:GetDistance(objectSpell) <= 750 then
                            A = Vector:New(objectSpell.x,objectSpell.z)
                            B = Vector:New(player.x,player.z)
                            C = B+(B-A):Normalize()*(100)
                            player:MoveTo((C.x),(C.z))
                            if lastRightClick.x ~= nil and lastRightClick.z ~= nil then
                                    Move()
                            end
                    elseif spellName == "MockingShout" and player:GetDistance(objectSpell) <= 850 then
                            A = Vector:New(objectSpell.x,objectSpell.z)
                            B = Vector:New(player.x,player.z)
                            C = B+(B-A):Normalize()*(-100)
                            player:MoveTo((C.x),(C.z))
                            if lastRightClick.x ~= nil and lastRightClick.z ~= nil then
                                    Move()
                            end
                    end
            end
    end
     
    function Move()
    		lastTimedtime = GetTickCount()
    		iambored = 0
    		while (GetTickCount() - lastTimedtime < delay) do
            	iambored = iambored + 1 --is this lagging ? D:
            end
            player:MoveTo(lastRightClick.x, lastRightClick.z)
            
    end
     
    function MouseClick(msgM, key)
            if msgM == WM_RBUTTONDOWN then
                    lastRightClick.x = mousePos.x
                    lastRightClick.y = mousePos.y
                    lastRightClick.z = mousePos.z
            end
    end
     
    function TimerTick()
            if lastRightClick.x ~= nil and lastRightClick.z ~= nil then
                    if math.abs(player.x-lastRightClick.x) <= 75 and math.abs(player.z-lastRightClick.z) <= 75 then
                    --If player has reached last right clicked position.
                            lastRightClick.x = nil
                            lastRightClick.z = nil
                    end
                    if lastPlayerPos.x ~= nil and lastPlayerPos.x == player.x and lastPlayerPos.y == player.y then
                    --If player has not moved since the last tick.
                            lastRightClick.x = nil
                            lastRightClick.y = nil
                    end
                    lastPlayerPos.x = player.x
                    lastPlayerPos.y = player.y
            end
    end
     



            exist = false
            for i=0, heroManager.iCount, 1 do
            local playerObject = heroManager:GetHero(i)
            if playerObject ~= nil and playerObject.team == TEAM_ENEMY and (playerObject.charName == "Tryndamere" or playerObject.charName == "Cassiopeia") then
                exist = true
            end
        	end
            if exist ~= true then
                    PrintChat(" >> No enemy Tryndamere or Cassiopeia! ")
        	else
            PrintChat(" >> turnAround script loaded!")
            BoL:addMsgHandler(MouseClick)
            BoL:addProcessSpellHandler(SpellTick)
            BoL:addTickHandler(TimerTick,10)
        	end

