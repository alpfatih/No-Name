--[[
ikita's FiddleSticks helper 1.0
spacebar. T to set include ult
]]--
 

require "AllClass"

local player = GetMyHero()
if player.charName == "FiddleSticks" then
 
--[[		Config		]]
function OnLoad()
	killable = {}
	killReady = {}
	lastPrint = {}
	ts = TargetSelector(TARGET_LOW_HP, 800)
	drawSelfRange = true --Draw range
	HK = 32 --spacebar
	HKult = 84 --T
	ultActive = true
	circleThickness = 20 --circle thickness
	dfgDmg = 0
	scriptActive = false
	for i = 1, 20, 1 do
		killable[i] = false
		killReady[i] = false
		lastPrint[i] = 0
	end
	comboJustCast = false
	ultJustCast = false
	dmgDuration = 0
end
 
--[[		Code		]]

function capTime(duration)
	local durTime = 2.5
	if duration > 4.5 then
		durTime = 5
	elseif duration > 4 then
		durTime = 4.5
	elseif duration > 3.5 then
		durTime = 4
	elseif duration > 3 then
		durTime = 3.5
	elseif duration > 2.5 then
		durTime = 3
	elseif duration > 2 then
		durTime = 2.5
	elseif duration > 1.5 then
		durTime = 2
	elseif duration > 1 then
		durTime = 1.5
	elseif duration > 0.5 then
		durTime = 1
	elseif duration > 0 then
		durTime = 0.5
	end
	if player:CanUseSpell(_R) == READY then
		durTime = durTime + 0.5+player:GetSpellData(_Q).level*0.5
		if durTime > 4.5 then
			durTime = 5
		end
	end
	return durTime --in seconds
end

function dmgDurationR(target)
	if (600 - GetDistance(player,target))/target.ms > 0 then
		return (600 - GetDistance(player,target))/target.ms
	else
		return 600/target.ms 
	end
end

function dmgDurationW(target)
	if (750 - GetDistance(player,target))/target.ms > 0 then
		return (750 - GetDistance(player,target))/target.ms
	else
		return 750/target.ms 
	end
end

function OnWndMsg(msg,key)
    if msg == KEY_DOWN then
        if key == HK then
            scriptActive = true
        end
    end
    if msg == KEY_UP then
        if key == HK then
            scriptActive = false
        end
    end
    if msg == KEY_DOWN then
        if key == HKult then
        	if ultActive then
            	ultActive = false
            	PrintChat(">>  Not Include Ult")
            else
            	ultActive = true
            	PrintChat(">>  Include Ult")
            end
        end
    end    
    
end

function OnProcessSpell(object, spell)
if object.name == player.name and spell.name == "FiddlesticksDarkWind" then
	comboJustCast = true
end
if object.name == player.name and spell.name == "Crowstorm" then
	ultJustCast = true
end
end

function OnTick()
	ts:update()
	if ts.target ~=nil and ts.target.dead == false and scriptActive then
		if player:CanUseSpell(_R) == READY and ultActive then
			CastSpell(_Q, ts.target)
			CastSpell(_R, ts.target.x, ts.target.z)
			if ultJustCast == true then
				if player:CanUseSpell(_E) ~= READY then
					CastSpell(_W, ts.target)
					comboJustCast = false
				end
				CastSpell(_E, ts.target)
				if comboJustCast == true then
					CastSpell(_W, ts.target)
					comboJustCast = false
				end
				ultJustCast = false
			end
		else
			CastSpell(_Q, ts.target)
			if player:CanUseSpell(_E) ~= READY then
				CastSpell(_W, ts.target)
				comboJustCast = false
			end
			CastSpell(_E, ts.target)
			if comboJustCast == true then
				CastSpell(_W, ts.target)
				comboJustCast = false
			end
		end	
	end
		
	
	for i = 1, heroManager.iCount do
		--Calculate damage to each champion
		local target = heroManager:GetHero(i)
		local qDmg = 0
		local wDmg = capTime(dmgDurationW(target))*(player:CalcMagicDamage(target, 30*(player:GetSpellData(_W).level-1)+60+ (.45*player.ap)))
		local eDmg = player:CalcMagicDamage(target, 20*(player:GetSpellData(_E).level-1)+65+ (.45*player.ap))
		local rDmg = capTime(dmgDurationR(target))*player:CalcMagicDamage(target, 100*(player:GetSpellData(_R).level-1)+125+ (.45*player.ap))
    	if player:GetSpellData(_Q).level == 0 then
        	qDmg = 0
        end
        if player:GetSpellData(_W).level == 0 then
        	wDmg = 0
        end
        if player:GetSpellData(_E).level == 0 then
        	eDmg = 0
        end
        if player:GetSpellData(_R).level == 0 then
        	rDmg = 0
        end
		if eDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(_E) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end

		elseif wDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(_W) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end
		elseif wDmg + eDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(_E) == READY and player:CanUseSpell(_W) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end	
		elseif wDmg + eDmg + rDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(_R) == READY and player:CanUseSpell(_W) == READY and player:CanUseSpell(_E) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end	
		else
			killReady[i] = false
			killable[i] = false			
		end
			if target.team ~= player.team and target.dead ==false and GetTickCount() - lastPrint[i] > 800 then
				PrintFloatText(target,0,"" .. math.ceil(target.health - (eDmg + rDmg + wDmg)) .. " hp")
				lastPrint[i] = GetTickCount()	
			end	
	end

end


function OnDraw()
	for i = 1, heroManager.iCount do
	local target = heroManager:GetHero(i)
   
	if killReady[i] and target.team ~= player.team and target.visible and not target.dead then
		for j = 0, circleThickness do  
			DrawCircle(target.x,target.y,target.z,200+j*2,0x19A712)
		end
	elseif killable[i] and target.team ~= player.team and target.visible and not target.dead then
		for j = 0, circleThickness do  
			DrawCircle(target.x,target.y,target.z,200+j*2,0x0000FF)
		end
	end
end
   
	if drawSelfRange then
		DrawCircle(player.x,player.y,player.z,575,0x19A712) --Q range & color: green
	end
end

PrintChat(" >> FiddleSticks helper 1.0 loaded!")
end