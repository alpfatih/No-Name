--[[
	Irelia Helper v1.0 by ikita for BoL
]]
if GetMyHero().charName == "Irelia" then

--[[		Code		]]
player = GetMyHero()
local qMinionsActiveI = false
local qMinionKeyI = 84

function tickHandlerI()
	local myQ = math.floor( ((player:GetSpellData(_Q).level-1)*30) + 20 + player.totalDamage)
	--KS function
	if player:GetSpellData(_Q).level > 0 and player:CanUseSpell(_Q) == READY then
		for i=1, heroManager.iCount do
			local target = heroManager:GetHero(i)
			local qDamage = player:CalcDamage(target, myQ)
			
			if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false and player:GetDistance(target) < 650 then
				if target.health < qDamage then
					CastSpell(_Q, target)
				end
			end
		end
	end
	--Q minion founction
    if qMinionsActiveI then
    	for k = 1, objManager.maxObjects do
        	local minionObjectI = objManager:GetObject(k)
        	if minionObjectI ~= nil and string.find(minionObjectI.name,"Minion_") == 1 and minionObjectI.team ~= player.team and minionObjectI.dead == false then
        		if  player:GetDistance(minionObjectI) < 650 and math.sqrt((mousePos.x - minionObjectI.x)*(mousePos.x - minionObjectI.x) + (mousePos.z - minionObjectI.z)*(mousePos.z - minionObjectI.z)) < 300 and minionObjectI.health <= player:CalcDamage(minionObjectI, myQ) then	
            		CastSpell(_Q, minionObjectI)
            	end
        	end
    	end
    end
end

function HotkeyI(msg,key)
	if msg == KEY_DOWN then 
    	if key == qMinionKeyI then
        	if qMinionsActiveI then
            	qMinionsActiveI = false
                PrintChat(" >> Auto Q minions disabled!")  
            else
                qMinionsActiveI = true
                PrintChat(" >> Auto Q minions enabled!")
            end     
        end
    end   
end



	if player.charName == "Irelia" then
	    BoL:addTickHandler(tickHandlerI,10)
	    BoL:addMsgHandler(HotkeyI)
		PrintChat(" >> Irelia Helper loaded!")

	else
	end
	
end