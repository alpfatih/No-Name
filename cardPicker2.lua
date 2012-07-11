--[[
        Script: Pick a Card v1.0
        Author: Modified by Keoshin/Taikumi
       Credits: This script was largely based on Sumizome's Pick a Card v1.3 mod5, updated by Zynox,
                Weee & h0nda, and was modified to use BoL's scripting API.
    ]]--
     
     
     
    -- Config:
    HotkeyRed    = 90 --Z
    HotkeyYellow = 88 --X
    HotkeyBlue   = 67 --C
     
    -- Globals:
    cards = {}
    cards[HotkeyYellow] = "Card_Yellow"
    cards[HotkeyBlue] = "Card_Blue"
    cards[HotkeyRed] = "Card_Red"
    selected = HotkeyYellow
    spellUsed = nil
    lastUse = 0
    player = GetMyHero()
    KEY_UP = 0x101
     
    function msgHandler(msg, key)
        if msg ~= KEY_UP or player:CanUseSpell(_W) ~= READY or GetTickCount() - lastUse <= 2500 or player.dead or cards[key] == nil or spellUsed ~= nil then return end    
        lastUse = GetTickCount()
        spellUsed = true
        selected = key
        CastSpell(_W, player.x, player.y, player.z)
    end
     
    function tickHandler() -- modified to be able to pick the first card
        for k = 1, objManager.maxObjects do
        	local object = objManager:GetObject(k)
        	if object ~= nil and object.name:find(cards[selected]) and player:GetDistance(object) < 80 then
            	CastSpell(_W, player.x, player.y, player.z) -- If we detect the card, cast W again to capture it
            	spellUsed = nil
        	end
        end
    end
     
 
    BoL:addTickHandler(tickHandler,50)
    BoL:addMsgHandler(msgHandler)
    
