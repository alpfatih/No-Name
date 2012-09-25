if GetMyHero().charName == "Ezreal" then
PrintChat(" >> Ezreal Helper loaded!")
--[[
Ezreal Helper v1.2b by ikita for BoL Studio
Auto Q after each auto-atk
]]

--SETTINGS
local qAfterAA = true
local qAfterAAKey = 71 -- G
local alwaysQ = false
local alwaysQKey = 84 -- T
local qWidth = 150 -- can change
local blocked = false
local justAA = false
local AAtimer = 0
local waitTime = 100 --if you have good ping, set it to a value higher than 100 ms. if you have bad ping then change this to zero.
--[[ Code ]]


require "TargetSelectorClass"
require "vector"
require "linear_prediction"

local lp = LinearPrediction:new(900,1.2)
local ts = TargetSelector(TARGET_LOW_HP,900)

function OnProcessSpell(object, spell)
local spellName = spell.name
if player:CanUseSpell(_Q) == READY and object.name == player.name and ((spellName == "EzrealBasicAttack") or (spellName == "EzrealBasicAttack2") or (spellName == "EzrealCritAttack")) then
		justAA = true
		AAtimer = GetTickCount()
	end
end

function OnTick()
	ts:updateTarget()
    lp:tick()
    if GetTickCount() - AAtimer > 600 then
    	justAA = false
    end
if ts.target ~= nil and player:CanUseSpell(_Q) == READY then
local predic = lp:getPredictionFor(ts.target.name)
blocked = false

for k = 1, objManager.maxObjects do
         local minionObjectE = objManager:GetObject(k)
         if minionObjectE ~= nil and string.find(minionObjectE.name,"Minion_") == 1 and minionObjectE.team ~= player.team and minionObjectE.dead == false then
-- --Calculate minion block
-- if player:GetDistance(minionObjectE) + math.sqrt((predic.x - minionObjectE.x)*(predic.x - minionObjectE.x) + (predic.z - minionObjectE.z)*(predic.z - minionObjectE.z))
-- < math.sqrt((predic.x - player.x)*(predic.x - player.x) + (predic.z - player.z)*(predic.z - player.z)) + 350 then
-- blocked = true
-- PrintChat("blocked")
-- end
         --Calculate minion block
         if predic ~= nil and player:GetDistance(minionObjectE) < 900 then
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
if predic ~= nil and blocked == false and alwaysQ then
         CastSpell(_Q, predic.x, predic.z)
        end
        if predic ~= nil and blocked == false and qAfterAA and justAA and GetTickCount() - AAtimer > waitTime then
         CastSpell(_Q, predic.x, predic.z)
         justAA = false
        end
end
end

function OnWndMsg(msg,key)
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
end