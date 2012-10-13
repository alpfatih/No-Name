    --[[
	Auto Potions, in case you forget.
	by ikita
    ]]
     
    --[[  Globals  ]]
    MPotUsed = false
    HPotUsed = false
    manaLimit = 0.375 
    hpLimit = 0.375
    lastTimeMPot = 0
    lastTimeHPot = 0
    
    --[[   Code   ]]
    function OnTick()
    	local player = GetMyHero()
        local manaPercent = player.mana/(player.maxMana - player.mana)
        local ItemSlot = {ITEM_1,ITEM_2,ITEM_3,ITEM_4,ITEM_5,ITEM_6,}
            for i=1, 6, 1 do
                if player:getInventorySlot(ItemSlot[i]) == 2004 and manaLimit >= manaPercent and MPotUsed == false then
                	FinalItemslotM = ItemSlot[i]
                	CastSpell(FinalItemslotM)
                	MPotUsed = true
                	lastTimeMPot = GetTickCount()
                end
            end
            if GetTickCount() - lastTimeMPot > 15000 then
            	MPotUsed = false
            end
            
            
        local hpPercent = player.health/(player.maxHealth - player.health)
            for i=1, 6, 1 do
                if player:getInventorySlot(ItemSlot[i]) == 2003 and hpLimit >= hpPercent and HPotUsed == false then
                	FinalItemslotH = ItemSlot[i]
                	CastSpell(FinalItemslotH)
                	HPotUsed = true
                	lastTimeHPot = GetTickCount()
                end
            end
            if GetTickCount() - lastTimeHPot > 15000 then
            	HPotUsed = false
            end
    end
     
     
     
        PrintChat(" >> Auto Potions loaded!")