--[[
	AutoSmiteee
    v1.1
    Modification by Weee
    
	Credits to Zynox for original AutoSmite v1.2
    
    v1.0    : First release
    v1.1    : Update for new Animation Lib v0.3
	
	Modified by Mariopart for BoL
    
    What's new in AutoSmiteee:
        1) Implemented anim lib.
        2) There are neat animated notifications at upper left corner now. You can set in config to use old PrintChats if you want.
        3) Now there is additional feature (you can turn it off in config, if it annoys you):
            - AutoSmite even when it's OFF but ONLY if you hold the hotkey (ALT by default)
           I find myself this thing pretty useful, because sometimes you have to turn on AutoSmite really fast.
           Since I didn't want to use "fast" hotkey for this - I just added this feature.
        4) Now if you want to make script work faster/slower (pure AutoSmite part) you can set interval for it with scanInterval (default: 50 ms).
        5) This is my last modification of original Zynox' AutoSmite. In future I will release similiar script in Breaking Bad series.
        
    What's different from original version:
        1) Hotkey for switching AutoSmite On/Off (by default: F11). Remember that AutoSmite is OFF until you switch it.
        2) Hold-Hotkey for using AutoSmite (by default: ALT) if you want to use it in this way.
        3) This mod takes more computer resources than original:
            - timerCallback has shorter interval by default (tho you can change it. take a look at scanInterval)
            - anim.lua support
]]
--[[ 		Config		]]
local range = 800         -- Range of smite (~800)
local smiteGolem = true   -- Set to false if you don't want to smite Blue buff
local smiteLizard = true  -- Set to false if you don't want to smite Red buff
local switcher = 122      -- Let's you to switches AutoSmite ON/OFF by pressing this hotkey (F11)
local hold = nil           -- Let's you to AutoSmite even if it's OFF by holding this hotkey (ALT by default). Set it to nil if you don't want to use this feature.
local animNotify = false   -- true - new animated notifications; false - old PrintChat notifications
local scanInterval = 50   -- Interval for Smite part of the script. Recommended to set from 10 to 500. If it drops FPS hard for you then try to set it to 500. (default: 50 ms)

--[[ 		Globals		]]
local sleepTick = 0
local scanTick = 0
local activated = 0
local holding = 0
local animPlayedTick = nil
local smiteSlot = nil
player = GetMyHero()

--[[ 		Code		]]
function altDoFile(name)
    dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)
end
			
if animNotify then
    altDoFile("libs/anim.lua")

    de = DrawingEngine()
    ds = DrawingSets()

    ds:Add("notify",DrawingText("AutoSmite: ",14,70,30,1,1,1,1))
    ds.notify.objects[1].A = 0
end

function msgHandler(msg,wParam)
    if wParam ~= switcher and wParam ~= hold then return end
    if wParam == switcher and msg == KEY_UP then
        if activated == 0 then
            activated = 1
            holding = 0
            if animNotify then
                animPlayedTick = GetTickCount()
                ds:Get("notify"):RunAnimation("fadeinout",FADING,OPACITY,0,1,0.025,0)
                ds:Get("notify"):RunAnimation("slide",FADINGVELOCITY,POSITIONX,-70,70,6.8,0,0.955)
                ds.notify.objects[1].text = "AutoSmite: ON"
                ds.notify.objects[1].R = 0
                ds.notify.objects[1].G = 1
                ds.notify.objects[1].B = 0
            else
                PrintChat("<font color='#7CFC00'> >> AutoSmite: ON</font>")
            end
        else
            activated = 0
            holding = 0
            if animNotify then
                animPlayedTick = GetTickCount()
                ds:Get("notify"):RunAnimation("fadeinout",FADING,OPACITY,0,1,0.025,0)
                ds:Get("notify"):RunAnimation("slide",FADINGVELOCITY,POSITIONX,-70,70,6.8,0,0.955)
                ds.notify.objects[1].text = "AutoSmite: OFF"
                ds.notify.objects[1].R = 1
                ds.notify.objects[1].G = 0
                ds.notify.objects[1].B = 0
            else
                PrintChat("<font color='#FF4500'> >> AutoSmite: OFF</font>")
            end
        end
    end
    if wParam == hold then
        if msg == KEY_DOWN and activated == 0 and holding == 0 then
            activated = 1
            holding = 1
            if animNotify then 
                animPlayedTick = nil
                ds:Get("notify"):RunAnimation("fadeinout",FADING,OPACITY,0,1,0.025,0)
                ds:Get("notify"):RunAnimation("slide",FADINGVELOCITY,POSITIONX,-70,70,6.8,0,0.955)
                ds.notify.objects[1].text = "AutoSmite: HOLD"
                ds.notify.objects[1].R = 0
                ds.notify.objects[1].G = 1
                ds.notify.objects[1].B = 0
            else
                PrintChat("<font color='#7CFC00'> >> AutoSmite: ON</font>")
            end
        end
        if msg == KEY_UP and activated == 1 and holding == 1 then
            activated = 0
            holding = 0
            if animNotify then
                animPlayedTick = nil
                ds:Get("notify"):RunAnimation("fadeinout",FADING,OPACITY,1,0,0.015,0)
                ds:Get("notify"):RunAnimation("slide",FADING,POSITIONX,70,0,0.3,0)
            else
                PrintChat("<font color='#FF4500'> >> AutoSmite: OFF</font>")
            end
        end
    end
end

function tickHandler()
    local tick = GetTickCount()
    if animNotify then
        de:ComputeAnimations(ds)
        if animPlayedTick ~= nil and tick - animPlayedTick >= 2000 then
            animPlayedTick = nil
            ds:Get("notify"):RunAnimation("fadeinout",FADING,OPACITY,1,0,0.015,0)
            ds:Get("notify"):RunAnimation("slide",FADING,POSITIONX,70,0,0.3,0)
        end
    end
    if GetTickCount() - scanTick < scanInterval then return end
    scanTick = GetTickCount()
    if sleepTick <= GetTickCount() then
		if activated == 1 then
			if player:CanUseSpell(smiteSlot) == READY then
				local smiteDamage = 420 + 25 * player.level
				local count = objManager.maxObjects
				for i = 0, count - 1, 1 do
					local object = objManager:getObject(i)
					if (object ~= nil and player:GetDistance(object) < range and object.team == TEAM_NEUTRAL and object.dead == false) and (string.find(object.name,"Worm12.1.1") ~= nil or string.find(object.name,"Dragon6.1.1") ~= nil or string.find(object.name,"TwistedLizardElder8$1") ~= nil or string.find(object.name,"blueDragon7$1") ~= nil or (smiteGolem == true and (string.find(object.name,"AncientGolem1.1.1") ~= nil or string.find(object.name,"AncientGolem7.1.1") ~= nil)) or (smiteLizard == true and (string.find(object.name,"LizardElder4.1.1") ~= nil or string.find(object.name,"LizardElder10.1.1") ~= nil))) and object.health <= smiteDamage then
							CastSpell( smiteSlot, object )
							Sleep(1000)	
							return
					end
				end    
			end
		end
	end
end

function drawHandler()
    de:Draw(ds)
end

function Sleep( ms )
    sleepTick = GetTickCount() + ms
end

if string.find(player:GetSpellData(SUMMONER_1).name, "Smite") ~= nil then
	smiteSlot = SUMMONER_1
	if animNotify then BoL:addDrawHandler(drawHandler) end
	BoL:addTickHandler(tickHandler,10)
	BoL:addMsgHandler(msgHandler)
	PrintChat("autoSmiteee Script loaded!")
elseif string.find(player:GetSpellData(SUMMONER_2).name, "Smite") ~= nil then
	smiteSlot = SUMMONER_2
	if animNotify then BoL:addDrawHandler(drawHandler) end
	BoL:addTickHandler(tickHandler,10)
	BoL:addMsgHandler(msgHandler)
	PrintChat("autoSmiteee Script loaded!")
else
	smiteSlot = nil
end