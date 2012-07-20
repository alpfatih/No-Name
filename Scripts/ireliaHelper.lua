--[[
	Irelia Helper v1.1 by ikita for BoL
]]
if GetMyHero().charName == "Irelia" then

--[[		Code		]]
player = GetMyHero()
local qMinionsActiveI = false
local qMinionKeyI = 84

--SHEEN
local sheenID = 3057
local sheenActive = false
local sheenReady = false
local lastSheenOn = 0
local lastSheenOff = 0

--TRIFORCE
local trinID = 3078
local trinActive = false
local trinReady = false
local lastTrinOn = 0
local lastTrinOff = 0

function SpellI(object, spellName)
	--SHEEN
	if sheenSlot ~= nil and sheenReady == true and object ~= nil and object.name == player.name and ((spellName == "IreliaTranscendentBlades") or (spellName == "IreliaGatotsu") or (spellName == "IreliaHitenStyle") or (spellName == "IreliaEquilibriumStrike")) then
		sheenActive = true
		lastSheenOn = GetTickCount()
    end
    if sheenSlot ~= nil and sheenActive == true and object ~= nil and object.name == player.name and ((spellName == "IreliaBasicAttack") or (spellName == "IreliaGatotsu") or (spellName == "IreliaBasicAttack2") or (spellName == "IreliaCritAttack")) then --On hit triggers
		lastSheenOff = GetTickCount()
		sheenActive = false
    end
    
    --TRIFORCE
    if trinSlot ~= nil and trinReady == true and object ~= nil and object.name == player.name and ((spellName == "IreliaTranscendentBlades") or (spellName == "IreliaGatotsu") or (spellName == "IreliaHitenStyle") or (spellName == "IreliaEquilibriumStrike")) then
		trinActive = true
		lastTrinOn = GetTickCount()
    end
    if sheenSlot ~= nil and trinActive == true and object ~= nil and object.name == player.name and ((spellName == "IreliaBasicAttack") or (spellName == "IreliaGatotsu") or (spellName == "IreliaBasicAttack2") or (spellName == "IreliaCritAttack")) then --On hit triggers
		lastTrinOff = GetTickCount()
		trinActive = false
    end
end



function tickHandlerI()
	local myQ = math.floor( ((player:GetSpellData(_Q).level-1)*30) + 20 + player.totalDamage) --Normal damage

	--augment SHEEN Q damage
	sheenSlot = findItemSlotInInventory(sheenID)
	if sheenSlot ~= nil then
		if sheenActive == true and GetTickCount() - lastSheenOn > 10000 then --Turn off sheen if too long not used
			sheenActive = false
		end
		
		if GetTickCount() - lastSheenOff > 2000 then --Check if sheen is ready to trigger
			sheenReady = true
			myQ = player.totalDamage - player.addDamage + math.floor( ((player:GetSpellData(_Q).level-1)*30) + 20 + player.totalDamage)
		else
			sheenReady = false
			myQ = math.floor( ((player:GetSpellData(_Q).level-1)*30) + 20 + player.totalDamage)
		end
	end
	
	--augment TRIFORCE Q damage
	trinSlot = findItemSlotInInventory(trinID)
	if trinSlot ~= nil then
		if trinActive == true and GetTickCount() - lastTrinOn > 10000 then --Turn off sheen if too long not used
			trinActive = false
		end
		
		if GetTickCount() - lastTrinOff > 2000 then --Check if sheen is ready to trigger
			trinReady = true
			myQ = (player.totalDamage - player.addDamage)*1.5 + math.floor( ((player:GetSpellData(_Q).level-1)*30) + 20 + player.totalDamage)
		else
			trinReady = false
			myQ = math.floor( ((player:GetSpellData(_Q).level-1)*30) + 20 + player.totalDamage)
		end
	end	
	
	--KS with Q function
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

--Sheen/Triforce
function findItemSlotInInventory(item)
	local itemfound = false
	local ItemSlot = {ITEM_1,ITEM_2,ITEM_3,ITEM_4,ITEM_5,ITEM_6,}
	for i=1, 6, 1 do
    	if player:getInventorySlot(ItemSlot[i]) == item then 
    		itemfound = true
    		return ItemSlot[i]
    	end -- add nil here
    end
    if itemfound == false then
    	return nil
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
	    BoL:addProcessSpellHandler(SpellI)
		PrintChat(" >> Irelia Helper loaded!")

	else
	end
	
end