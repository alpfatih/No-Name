--[[
ikita's Fizz helper 1.0
Credits: barasia283
]]--
 

require "AllClass"

local player = GetMyHero()
if player.charName == "Fizz" then
 
--[[		Config		]]
function OnLoad()
	killable = {}
	killReady = {}
	lastPrint = {}
	ts = TargetSelector(TARGET_LOW_HP, 800)
	drawSelfRange = true --Draw range
	HK = 32 --spacebar
	circleThickness = 20 --circle thickness
	dfgDmg = 0
	scriptActive = false
	for i = 1, 20, 1 do
		killable[i] = false
		killReady[i] = false
		lastPrint[i] = 0
	end
end
 
--[[		Code		]]


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
end
function math.sign(x)
if x<0 then
return -1
elseif x>0 then
return 1
else
return 0
end
end
function OnTick()
	ts:update()

	if ts.target ~=nil and ts.target.dead == false and scriptActive then
		if GetInventoryHaveItem(3128) then
			invSlot = GetInventorySlotItem(3128)
			if invSlot ~= nil and  player:CanUseSpell(invSlot) == READY then
				CastSpell(invSlot, ts.target)
			end
		end
		CastSpell(_W)
		CastSpell(_Q, ts.target)
		alpha = math.atan(math.abs(ts.target.z-player.z)/math.abs(ts.target.x-player.x))
		locX = math.cos(alpha)*1200
		locZ = math.sin(alpha)*1200
		CastSpell(_R, math.sign(ts.target.x-player.x)*locX+player.x,  math.sign(ts.target.z-player.z)*locZ+player.z)
		CastSpell(_E, ts.target)	
	end
		
	
	for i = 1, heroManager.iCount do
		--Calculate damage to each champion
		local target = heroManager:GetHero(i)
		local qDmg = player:CalcMagicDamage(target, 30*(player:GetSpellData(_Q).level-1)+10+ (.6*player.ap)) + player:CalcDamage(target, player.totalDamage)
		local wDmgP = player:CalcMagicDamage(target, 10*(player:GetSpellData(_W).level-1)+30+ (.35*player.ap) + (target.maxHealth-target.health)*(player:GetSpellData(_Q).level+3)/100)
		local wDmgA = player:CalcMagicDamage(target, 5*(player:GetSpellData(_W).level-1)+10+ (.35*player.ap))
		local eDmg = player:CalcMagicDamage(target, 50*(player:GetSpellData(_E).level-1)+70+ (.75*player.ap))
		local rDmg = player:CalcMagicDamage(target, 125*(player:GetSpellData(_R).level-1)+200+ (player.ap))
		if GetInventoryHaveItem(3100) then
			qDmg = player:CalcMagicDamage(target, 30*(player:GetSpellData(_Q).level-1)+10+ (.6*player.ap)) + player:CalcDamage(target, player.totalDamage + player.ap)
		end
		if GetInventoryHaveItem(3128) then
			dfgDmg = player:CalcMagicDamage(target,(.25+(.04*(math.floor(player.ap/100))))*target.health)
		end
    	if player:GetSpellData(_Q).level == 0 then
        	qDmg = 0
        end
        if player:GetSpellData(_W).level == 0 then
        	wDmgP = 0
        	wDmgA = 0
        end
        if player:GetSpellData(_E).level == 0 then
        	eDmg = 0
        end
        if player:GetSpellData(_R).level == 0 then
        	rDmg = 0
        end
		if qDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(_Q) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end
		elseif GetInventoryHaveItem(3128) and dfgDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(GetInventorySlotItem(3128)) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end
		elseif qDmg + wDmgP > target.health then
			killable[i] = true
			if player:CanUseSpell(_Q) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end
		elseif qDmg + wDmgP + wDmgA > target.health then
			killable[i] = true
			if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end	
		elseif qDmg + wDmgP + wDmgA + eDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY and player:CanUseSpell(_E) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end	
		elseif qDmg + wDmgP + wDmgA + eDmg + rDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY and player:CanUseSpell(_E) == READY and player:CanUseSpell(_R) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end	
		elseif GetInventoryHaveItem(3128) and qDmg + wDmgP > target.health then
			killable[i] = true
			if player:CanUseSpell(GetInventorySlotItem(3128)) == READY and player:CanUseSpell(_Q) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end
		elseif GetInventoryHaveItem(3128) and qDmg + wDmgP + wDmgA > target.health then
			killable[i] = true
			if player:CanUseSpell(GetInventorySlotItem(3128)) == READY and player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end	
		elseif GetInventoryHaveItem(3128) and qDmg + wDmgP + wDmgA + eDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(GetInventorySlotItem(3128)) == READY and player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY and player:CanUseSpell(_E) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end	
		elseif GetInventoryHaveItem(3128) and qDmg + wDmgP + wDmgA + eDmg + rDmg > target.health then
			killable[i] = true
			if player:CanUseSpell(GetInventorySlotItem(3128)) == READY and player:CanUseSpell(_Q) == READY and player:CanUseSpell(_W) == READY and player:CanUseSpell(_E) == READY and player:CanUseSpell(_R) == READY then
				killReady[i] = true
			else
				killReady[i] = false
			end	
		else
			killReady[i] = false
			killable[i] = false
			if target.team ~= player.team and GetTickCount() - lastPrint[i] > 800 then
				PrintFloatText(target,0,"" .. math.ceil(target.health - (qDmg + dfgDmg + rDmg + wDmgA + wDmgP)) .. " hp")
				lastPrint[i] = GetTickCount()	
			end	
			
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
		DrawCircle(player.x,player.y,player.z,550,0x19A712) --Q range & color: green
	end
end

PrintChat(" >> Fizz helper 1.0 loaded!")
end