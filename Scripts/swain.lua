--[[
	ikita: 	Swain toggle auto QE
			Snare prediction
			v1.0
]]--

if GetMyHero().charName == "Swain" then


local hotkey = 90 -- Z
local WHK = 87 -- W
local WDelay = 1
local targetNum = 0
local scriptActive = false
local player = GetMyHero()
local WActive = false

local function altDoFile(name)
    dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)
end
altDoFile("libs/target_selector.lua")
altDoFile("libs/TimingLib.lua")
local ts = TargetSelector:new(TARGET_LOW_HP, 700, DAMAGE_MAGIC)
local ts2 = TargetSelector:new(TARGET_LOW_HP, 1000, DAMAGE_MAGIC)
local timer = Timer:new()

local function tickHandler()
	ts:tick()
	ts2:tick()
	timer:tickHandler()
	if not player.dead and scriptActive then
		if ts.target ~= nil and player:CanUseSpell(_Q) == READY and player:GetDistance(ts.target) <= 625 then
			CastSpell(_Q, ts.target)
		end
		if ts.target ~= nil and player:CanUseSpell(_E) == READY and player:GetDistance(ts.target) <= 625 then
			CastSpell(_E, ts.target)
		end		
	end

    if WActive == true and ts.target ~= nil and not player.dead then

                        for i = 1, heroManager.iCount do
                        local obj = heroManager:GetHero(i)
                                if obj ~= nil and obj.team ~= player.team and obj.charName == ts2.target.charName then
                                        targetNum = i
                                end
                        end
                            
        local wPred = timer:predictMovement(targetNum, WDelay)
                                CastSpell(_W, wPred.x, wPred.z)

        WActive = false
    end
end



local function msgHandler(msg, key)	
	if msg == KEY_DOWN then
    	if key == hotkey then
    		if scriptActive then
    			scriptActive = false
    			PrintChat(" >> QE Combo disabled!")  
    		else
    	    	scriptActive = true
            	PrintChat(" >> QE Combo enabled!")
            end     
        end
        --W Snare
    	if key == WHK then
    		WActive = true
        end
    end
end

BoL:addMsgHandler(msgHandler)
BoL:addTickHandler(tickHandler, 0)
PrintChat(" >> Swain Helper loaded")

end