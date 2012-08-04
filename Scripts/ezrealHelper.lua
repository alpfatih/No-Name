if GetMyHero().charName == "Ezreal" then

--[[
	Ezreal Helper v1.1e by ikita
	Auto Q after each auto-atk
]]

--Weird but necessary stuff that i'm too lazy to tidy up
freq = GetTickCount()
local iVar = 0
local lastTime = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local nowX = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local nowZ = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local nowTime = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local lastX = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local lastZ = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local qAfterAA = true
local qAfterAAKey = 71 -- G
local alwaysQ = false
local alwaysQKey = 84 -- T
local qWidth = 150 -- can change
local blocked = false
local justAA = false
local AAtimer = 0
local waitTime = 100 --if you have good ping, set it to a value higher than 100 ms. if you have bad ping then change this to zero.
local difX = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local difZ = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local difTime = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local travelTime = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local predicX = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local predicZ = {-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99,-99}
local targetValid = {false,false,false,false,false,false,false,false,false,false,false,false}
--[[		Code		]]
function altDoFile(name)
    dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)
end

altDoFile("libs/target_selector.lua")
altDoFile("libs/vector.lua")

local ts = TargetSelector:new(TARGET_LOW_HP,900)
ts.buildarray()


function SpellE(object, spellName)
	if player:CanUseSpell(_Q) == READY and object.name == player.name and ((spellName == "EzrealBasicAttack") or (spellName == "EzrealBasicAttack2") or (spellName == "EzrealCritAttack")) then
		justAA = true
		
		AAtimer = GetTickCount()
	end
end

function getPredFor(someName)

end

function linePredAll()
	if GetTickCount() - freq > 0 then
	freq = GetTickCount()
		for i = 1, heroManager.iCount do
			targetE = heroManager:GetHero(i)
			if targetValid[i] then
				nowTime[i] = GetTickCount()
				nowX[i] = targetE.x
				nowZ[i] = targetE.z
				difX[i] = nowX[i] - lastX[i]
				difZ[i] = nowZ[i] - lastZ[i]
				difTime[i]  = nowTime[i] - lastTime[i]
				travelTime[i] = GetMyHero():GetDistance(targetE)/1.2 --projectile speed = 1.2
				predicX[i] = nowX[i] + (difX[i]/difTime[i])*travelTime[i]
				predicZ[i] = nowZ[i] + (difZ[i]/difTime[i])*travelTime[i]
			end
			if targetE.team ~= GetMyHero().team and targetE.visible and targetE.dead == false then
				targetValid[i] = true
				lastTime[i] = GetTickCount()
				lastX[i] = targetE.x
				lastZ[i] = targetE.z
				
			else
			
				targetValid[i] = false
				
			end
		end
	end
end

function tickHandlerE()
	ts:tick()
    if GetTickCount() - AAtimer > 600 then
    	justAA = false
    end
	if ts.target ~= nil and player:CanUseSpell(_Q) == READY then
		for i = 1, heroManager.iCount do
			local matchI = heroManager:GetHero(i)
			if ts.target.name == matchI.name then
				iVar = i
			end
		end

	    blocked = false
	    for k = 1, objManager.maxObjects do
        	local minionObjectE = objManager:GetObject(k)
        	if minionObjectE ~= nil and string.find(minionObjectE.name,"Minion_") == 1 and minionObjectE.team ~= player.team and minionObjectE.dead == false then
--        		--Calculate minion block
--        		if player:GetDistance(minionObjectE) + math.sqrt((predic.x - minionObjectE.x)*(predic.x - minionObjectE.x) + (predic.z - minionObjectE.z)*(predic.z - minionObjectE.z)) 
--        		< math.sqrt((predic.x - player.x)*(predic.x - player.x) + (predic.z - player.z)*(predic.z - player.z)) + 350 then
--        			blocked = true
--        			PrintChat("blocked")
--        		end
        		--Calculate minion block
        		if  player:GetDistance(minionObjectE) < 900 then
        			--Player coordinates
        			ex = player.x
        			ez = player.z
        			--End coordinates
        			tx = predicX[iVar]
        			tz = predicZ[iVar]
        			--Distance apart
        			dx = ex - tx
        			dz = ez - tz
        			--Find (z = mx + c) of Q
        			if dx ~= 0 then
        				m = dz/dx
        				c = ez - m*ex
        			end
        			--Minion coordinates:
        			mx = minionObjectE.x
        			mz = minionObjectE.z
        			
        			--Distance from point to line
        			distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
        			if distanc < qWidth and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
        				blocked = true
        			end
            	end
        	end
    	end
		if blocked == false and alwaysQ then
        	CastSpell(_Q, predicX[iVar], predicZ[iVar])
        end
        if blocked == false and qAfterAA and justAA and GetTickCount() - AAtimer > waitTime then
        	CastSpell(_Q, predicX[iVar], predicZ[iVar])
        	justAA = false
        end
	end
end


function HotkeyE(msg,key)
	if msg == KEY_DOWN then 
    	if key == alwaysQKey then
        	if alwaysQ then
            	alwaysQ = false
                PrintChat(" >> Always Q disabled!")  
            else
                alwaysQ = true
                PrintChat(" >> Always Q enabled!")
            end     
        end
    end   
	if msg == KEY_DOWN then 
    	if key == qAfterAAKey then
        	if qAfterAA then
            	qAfterAA = false
                PrintChat(" >> Q After AA disabled!")  
            else
                qAfterAA = true
                PrintChat(" >> Q After AA enabled!")
            end     
        end
    end   
end


if player.charName == "Ezreal" then 
	BoL:addTickHandler(tickHandlerE,10)
	BoL:addTickHandler(linePredAll)
	BoL:addMsgHandler(HotkeyE)
	BoL:addProcessSpellHandler(SpellE)
	PrintChat(" >> Ezreal Helper loaded!")
end
	
	
end