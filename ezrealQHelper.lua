if GetMyHero().charName == "Ezreal" then
PrintChat(" >> Ezreal Helper loaded!")
--[[
Ezreal Helper v1.4 by ikita for BoL Studio
Auto Q after each auto-atk
]]

--SETTINGS
hotkeyAA = "G"
hotkeyAlways = "T"
local qAfterAA = true
local qAfterAAKey = string.byte(hotkeyAA) -- G
local alwaysQ = false
local alwaysQKey = string.byte(hotkeyAlways) -- T
local qWidth = 150 -- can change
local blocked = false
local justAA = false
local AAtimer = 0
local waitTime = 100 --if you have good ping, set it to a value higher than 100 ms. if you have bad ping then change this to zero.
local travelDuration = 600
myObjectsTable = {}
--[[ Code ]]

local ts = TargetSelector(TARGET_LOW_HP,900,DAMAGE_PHYSICAL)
ts.name = "Ezreal"

Config = scriptConfig("Ezreal QHelper", "ezrealhelper")
Config:addParam("qAfterAA","qAfterAA Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, qAfterAAKey)
Config:addParam("alwaysQ","Always Q Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, alwaysQKey)
Config:permaShow("qAfterAA")
Config:permaShow("alwaysQ")
Config:addTS(ts)


function OnCreateObj(object121)
if objectIsValid(object121) then table.insert(myObjectsTable, object121) end
end
function OnProcessSpell(object, spell)
local spellName = spell.name
if player:CanUseSpell(_Q) == READY and object.name == player.name and ((spellName == "EzrealBasicAttack") or (spellName == "EzrealBasicAttack2") or (spellName == "EzrealCritAttack")) then
		justAA = true
		AAtimer = GetTickCount()
	end
end

function objectIsValid(object)
   return object and object.valid and object.name:find("Minion_") and object.team ~= myHero.team and object.dead == false 
end

function OnLoad()
	for i = 0, objManager.maxObjects, 1 do
		local object = objManager:GetObject(i)
		if objectIsValid(object) then table.insert(myObjectsTable, object) end
	end
end

function OnTick()
	ts:update()
	if ts.target ~= nil then
		travelDuration = (GetDistance(ts.target, player)/1.2)
	end
	ts:SetPrediction(travelDuration)
	Prediction__OnTick()
    if GetTickCount() - AAtimer > 600 then
    	justAA = false
    end
if ts.target ~= nil and player:CanUseSpell(_Q) == READY then
local predic = ts.nextPosition

blocked = false

for i,object in ipairs(myObjectsTable) do
    if objectIsValid(object) then
    

         
-- --Calculate minion block
-- if player:GetDistance(minionObjectE) + math.sqrt((predic.x - minionObjectE.x)*(predic.x - minionObjectE.x) + (predic.z - minionObjectE.z)*(predic.z - minionObjectE.z))
-- < math.sqrt((predic.x - player.x)*(predic.x - player.x) + (predic.z - player.z)*(predic.z - player.z)) + 350 then
-- blocked = true
-- PrintChat("blocked")
-- end
         --Calculate minion block
         if predic ~= nil and player:GetDistance(object) < 900 then
         --Player coordinates
         ex = player.x
         ez = player.z
         --End coordinates
         tx = predic.x
         tz = predic.z
         --Distance apart
         dx = ex - tx
         dz = ez - tz
         --Find (z = mx + c) of Q
         if dx ~= 0 then
         m = dz/dx
         c = ez - m*ex
         end
         --Minion coordinates:
         mx = object.x
         mz = object.z
        
         --Distance from point to line
         distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
         if distanc < qWidth and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
         blocked = true
         end
             end
         end
     end
     
if predic ~= nil and blocked == false and Config.alwaysQ then
         CastSpell(_Q, predic.x, predic.z)
        end
        if predic ~= nil and blocked == false and Config.qAfterAA and justAA and GetTickCount() - AAtimer > waitTime then
         CastSpell(_Q, predic.x, predic.z)
         justAA = false
        end
end
end

--[[function OnWndMsg(msg,key)
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
end]]
end
