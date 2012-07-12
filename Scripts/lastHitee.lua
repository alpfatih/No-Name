--[[
    LastHiteee
    v0.5b
    Written by Weee
    Special credits to Zynox and grey (aka mrgreywater)

    Inpsired from all those released lasthit scripts and Zynox' Minion Marker.
    Credits to all FPB community.

    Now script monitors each ally minion attack and saves it as incoming damage for targeted enemy minions, also it saves the time when those attacks will hit enemy minions.
    Script uses this information to predict when minions will have enough health to die from 1 hit and automatically attacks it when you're holding "A" hotkey.

    This one shows simple example of using projectile speed, latency and attack delay (like in auto-skillshot prediction scripts) for auto-attacks.

    If you're interested in helping finishing this - scroll down to Load() function and look at champion list.
    This list does not have some characters (because I don't have them or they are not ranged).
    Right now it needs finding AA projectile speed (projSpeed) for all listed champs starting from Corki.
    To find it use h0nda's particle speed or grey's detector. Particle name is provided at same list as aaParticleName variable.
    Or use h0nda's particle speed script modified by me (you can find it in LastHiteee's thread).

    P.S. - This one should be definitely merged with Advanced Minion Marker by heist, Annie Q auto-farm and so on.
]]

do

--[[         Config        ]]
local HK = 65                    -- Hold key (A by default)

local useDAM = true              -- Will use Advanced Damage Library to calculate damage. Requires lib/dam.lua

local holdPosition = false       -- Will hold your champion's position, so it will lasthit a bit more accurate. Holds only when there is at least 1 minion to kill :p
                                 -- true         - ON
                                 -- false        - OFF

                                 
local animNotify = false         -- Animations like in autoSmiteee, BBWS, etc...
                                 -- true         - ON
                                 -- false        - OFF

local drawCircleRange = false    -- Draws a radius of your character's range.
                                 -- true         - ON
                                 -- false        - OFF

local markAttackedCreeps = 1500  -- Draws a circle around enemy minions which are targeted by our minions.
                                 -- This is pretty useful to know if that 2-hit minion is not targetable by anything and you can kill it with 2 AAs.
                                 -- 0-1000       - ON + How long mark will last (ms)
                                 -- nil          - OFF

local markRadius = 60            -- Radius of markAttackedCreeps.                          

local dmgSmoothness = 0          -- Damage smoothness:
                                 -- dmgSmoothness = 0: script will attack minion with health below ( player:CalcDamage(unit.obj) )
                                 -- dmgSmoothness = 10: script will attack minion with health below ( player:CalcDamage(unit.obj) - 10 )

local dmgSmoothMulti = nil       -- Damage multiplier smoothness. Set it to nil if you want to use values from the champTable.
                                 -- dmgSmoothMulti = 0   : script will attack minion with health below ( player:CalcDamage(unit.obj) )
                                 -- dmgSmoothMulti = 0.7 : script will attack minion with health below ( player:CalcDamage(unit.obj) * (1 - 0.7) ). 30% of normal dmg.
                                 -- dmgSmoothMulti = 1   : script will not attack minions at all since it is 0% from normal damage.
                                 -- dmgSmoothMulti = nil : script will use values from champTable.

local timeSmoothness = 0         -- Time (ms) smoothness in formula of your autoattacks.           Latency + Attack_Delay + Projectile_Travel_Time + timeSmoothness

local m_timeSmoothness = 0       -- Time (ms) smoothness in formula of your minions' autoattacks.  Attack_Delay + Projectile_Travel_Time + m_timeSmoothness


local function CalculatePhysicalDamage(obj)
    return player:CalcDamage(obj, player.totalDamage)
end


--[[     Advanced Damage Library ]]
local function altDoFile(name)
    dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)
end


if useDAM then
    altDoFile("libs/dam.lua")
    DamageLibrary:Damage()

    CalculatePhysicalDamage = function(obj)
        dam = DamageLibrary:CalcDamage(obj)
        return dam.damage
    end
end

--[[     Advanced Config     ]]
local unitScanDelay = 500
local scanAdditionalRange = 400

local champTable = {
    Ahri =          { projSpeed = 1.6,   aaParticleName = "ahri_basicattack_mis",         aaSpellName = "ahribasicattack",         dmgSmoothMulti = 0.5, },   -- 
    Anivia =        { projSpeed = 1.05,  aaParticleName = "cryobasicattack_mis",          aaSpellName = "aniviabasicattack",       dmgSmoothMulti = 0.4, },   -- 
    Annie =         { projSpeed = 1.2,   aaParticleName = "anniebasicattack3",            aaSpellName = "anniebasicattack",        dmgSmoothMulti = 0.4, },   -- 
    Ashe =          { projSpeed = 1.9,   aaParticleName = "bowmasterbasicattack_mis",     aaSpellName = "ashebasicattack",         dmgSmoothMulti = 0.7, },   -- great
    Brand =         { projSpeed = 1.975, aaParticleName = "brandbasicattack_mis",         aaSpellName = "brandbasicattack",        dmgSmoothMulti = 0.7, },   -- 
    Caitlyn =       { projSpeed = 2.45,  aaParticleName = "caitlyn_mis_04",               aaSpellName = "caitlynbasicattack",      dmgSmoothMulti = 0.7, },   -- 
    Cassiopeia =    { projSpeed = 1.22,  aaParticleName = "cassbasicattack_mis",          aaSpellName = "cassiopeiabasicattack",   dmgSmoothMulti = 0.7, },   -- 
    Corki =         { projSpeed = 2.0,   aaParticleName = "corki_basicattack_mis",        aaSpellName = "corkibasicattack",        dmgSmoothMulti = 0.7, },   -- 
    Ezreal =        { projSpeed = 2.0,   aaParticleName = "ezreal_basicattack_mis",       aaSpellName = "ezrealbasicattack",       dmgSmoothMulti = 0.7, },   -- 
    FiddleSticks =  { projSpeed = 1.75,  aaParticleName = "fiddlesticks_mis",             aaSpellName = "fiddlesticksbasicattack", dmgSmoothMulti = 0.7, },   --
    Graves =        { projSpeed = 2.0,   aaParticleName = "graves_basicattack_mis",       aaSpellName = "gravesbasicattack",       dmgSmoothMulti = 0.7, },   -- great
    Heimerdinger =  { projSpeed = 1.4,   aaParticleName = "heimerdinger_basicattack_mis", aaSpellName = "heimerdingerbasicAttack", dmgSmoothMulti = 0.7, },   --
    Janna =         { projSpeed = 1.2,   aaParticleName = "jannabasicattack_mis",         aaSpellName = "jannabasicattack",        dmgSmoothMulti = 0.7, },   --
    Karthus =       { projSpeed = 1.25,  aaParticleName = "lichbasicattack_mis",          aaSpellName = "karthusbasicattack",      dmgSmoothMulti = 0.7, },   --
    Kennen =        { projSpeed = 1.35,  aaParticleName = "kennenbasicattack_mis",        aaSpellName = "kennenbasicattack",       dmgSmoothMulti = 0.7, },
    KogMaw =        { projSpeed = 1.75,  aaParticleName = "kogmawbasicattack_mis",        aaSpellName = "kogmawbasicattack",       dmgSmoothMulti = 0.7, },   --
    Leblanc =       { projSpeed = 1.7,   aaParticleName = "leblancbasicattack_mis",       aaSpellName = "leblancbasicattack",      dmgSmoothMulti = 0.7, },
  --Lulu =          { projSpeed = 1.45,  aaParticleName = "lulu_faerie_basicattack",      aaSpellName = "lulubasicattack",         dmgSmoothMulti = 0.7, },   -- pet?
    Lulu =          { projSpeed = 2.5,   aaParticleName = "LuluBasicAttack",              aaSpellName = "LuluBasicAttack",         dmgSmoothMulti = 0.2, },   -- real?
    Lux =           { projSpeed = 1.55,  aaParticleName = "luxbasicattack_mis",           aaSpellName = "luxbasicattack",          dmgSmoothMulti = 0.7, },
    Malzahar =      { projSpeed = 1.5,   aaParticleName = "alzaharbasicattack_mis",       aaSpellName = "malzaharbasicattack",     dmgSmoothMulti = 0.7, },
    MissFortune =   { projSpeed = 1.9,   aaParticleName = "missfortune_basicattack_mis",  aaSpellName = "missfortunebasicattack",  dmgSmoothMulti = 0.7, },   --
    Morgana =       { projSpeed = 1.55,  aaParticleName = "FallenAngelBasicAttack",       aaSpellName = "Morganabasicattack",      dmgSmoothMulti = 0.7, },   --
    Nidalee =       { projSpeed = 1.7,   aaParticleName = "nidalee_javelin_mis",          aaSpellName = "nidaleebasicattack",      dmgSmoothMulti = 0.7, },
    Orianna =       { projSpeed = 1.4,   aaParticleName = "orianabasicattack_mis",        aaSpellName = "oriannabasicattack",      dmgSmoothMulti = 0.7, },
    Ryze =          { projSpeed = 1.4,   aaParticleName = "manaleach_mis",                aaSpellName = "ryzebasicattack",         dmgSmoothMulti = 0.7, },   --
    Sivir =         { projSpeed = 1.42,  aaParticleName = "sivirbasicattack_mis",         aaSpellName = "sivirbasicattack",        dmgSmoothMulti = 0.7, },   --
    Sona =          { projSpeed = 1.6,   aaParticleName = "sonabasicattack_mis",          aaSpellName = "sonabasicattack",         dmgSmoothMulti = 0.7, },
    Soraka =        { projSpeed = 1.0,   aaParticleName = "sorakabasicattack_mis",        aaSpellName = "sorakabasicattack",       dmgSmoothMulti = 0.7, },   --
    Swain =         { projSpeed = 1.6,   aaParticleName = "swainbasicattack_mis",         aaSpellName = "swainbasicattack",        dmgSmoothMulti = 0.7, },   --
    Teemo =         { projSpeed = 1.3,   aaParticleName = "teemobasicattack_mis",         aaSpellName = "teemobasicattack",        dmgSmoothMulti = 0.7, },
    Tristana =      { projSpeed = 2.25,  aaParticleName = "tristannabasicattack_mis",     aaSpellName = "tristanabasicattack",     dmgSmoothMulti = 0.7, },   --
    --TwistedFate =   { projSpeed = 1.55,  aaParticleName = "twistedfatebasicattack_mis",   aaSpellName = "twistedfatebasicattack",  dmgSmoothMulti = 0.2, },
    TwistedFate =   { projSpeed = 1.6,  aaParticleName = "twistedfatebasicattack_mis",   aaSpellName = "twistedfatebasicattack",  dmgSmoothMulti = 0.3, },
    Twitch =        { projSpeed = 2.5,   aaParticleName = "twitch_basicattack_mis",       aaSpellName = "twitchbasicattack",       dmgSmoothMulti = 0.7, },
    Urgot =         { projSpeed = 1.3,   aaParticleName = "urgotbasicattack_mis",         aaSpellName = "urgotbasicattack",        dmgSmoothMulti = 0.7, },   --
    Vayne =         { projSpeed = 1.85,  aaParticleName = "vayne_basicattack_mis",        aaSpellName = "vaynebasicattack",        dmgSmoothMulti = 0.7, },   --
    Veigar =        { projSpeed = 1.05,  aaParticleName = "permission_basicattack_mis",   aaSpellName = "veigarbasicattack",       dmgSmoothMulti = 0.7, },
    Viktor =        { projSpeed = 2.25,  aaParticleName = "viktorbasicattack_mis",        aaSpellName = "viktorbasicattack",       dmgSmoothMulti = 0.7, },
    Vladimir =      { projSpeed = 1.4,   aaParticleName = "vladbasicattack_mis",          aaSpellName = "vladimirbasicattack",     dmgSmoothMulti = 0.7, },
    Xerath =        { projSpeed = 1.2,   aaParticleName = "xerathbasicattack_mis",        aaSpellName = "xerathbasicattack",       dmgSmoothMulti = 0.7, },
    Ziggs =         { projSpeed = 1.5,   aaParticleName = "ziggsbasicattack_mis",         aaSpellName = "ziggsbasicattack",        dmgSmoothMulti = 0.7, },   --
    Zilean =        { projSpeed = 1.25,  aaParticleName = "chronobasicattack_mis",        aaSpellName = "zileanbasicattack",       dmgSmoothMulti = 0.7, },   -- 
}

--[[      BOL Script API      ]]
local player = GetMyHero()


local weAtBottom = ( player.team == 100 )
local minionInfo = {}
minionInfo[(weAtBottom and "Blue" or "Red").."_Minion_Basic"] =      { aaDelay = 400, projSpeed = 0    }
minionInfo[(weAtBottom and "Blue" or "Red").."_Minion_Caster"] =     { aaDelay = 484, projSpeed = 0.68 }
minionInfo[(weAtBottom and "Blue" or "Red").."_Minion_Wizard"] =     { aaDelay = 484, projSpeed = 0.68 }
minionInfo[(weAtBottom and "Blue" or "Red").."_Minion_MechCannon"] = { aaDelay = 365, projSpeed = 1.18 }
minionInfo.obj_AI_Turret =                                           { aaDelay = 150, projSpeed = 1.14 }


--[[         Globals        ]]

local scriptActive = false
local units = {}
local incDmg = {}
local oldDelayTick = 0
local unitScanTick = 0
local holding = 0
local animPlayedTick = nil

local aaPos = {x = 0, z = 0}

local aaDelay = 320
local aaTick = 0

--[[         Code        ]]
if animNotify then
    altDoFile("libs/anim.lua")

    de = DrawingEngine()
    ds = DrawingSets()

    ds:Add("notify",DrawingText("LastHit: ",14,70,60,1,1,1,1))
    ds.notify.objects[1].A = 0
end

local function GetRealTick()
    return os.clock()*1000
end

local function GetDistance2D( o1, o2 )    -- Improved GetDistance2D which detects if we're finding distance between 2D objects (x,y) or 3D objects (x,z)
    local c = "z"
    if o1.z == nil or o2.z == nil then c = "y" end
    return math.sqrt(math.pow(o1.x - o2.x, 2) + math.pow(o1[c] - o2[c], 2))
end

local function Timer()
    local tick = GetTickCount()
    
    if animNotify then
        de:ComputeAnimations(ds)
        if animPlayedTick ~= nil and tick - animPlayedTick >= 2000 then
            animPlayedTick = nil
            ds:Get("notify"):RunAnimation("fadeinout",FADING,OPACITY,1,0,0.015,0)
            ds:Get("notify"):RunAnimation("slide",FADING,POSITIONX,70,0,0.3,0)
        end
    end
    -- Scanning through objects, finding enemy minions in our range, adding them to the units table.
    if scriptActive or tick - unitScanTick >= unitScanDelay then
        unitScanTick = tick
        for i = 1, objManager.maxObjects, 1 do
            local object = objManager:getObject(i)
            if object ~= nil and object.team ~= player.team and object.type == "obj_AI_Minion" and string.find(object.charName,"Minion") then
                if not object.dead and GetDistance2D(object,player) <= (player.range + scanAdditionalRange) then
                    if units[object.name] == nil then
                        units[object.name] = { obj = object, markTick = 0 }
                    end
                else
                    units[object.name] = nil
                end
            end
        end
    end
    
    -- Going through units table and doing all main stuff:
    for i, unit in pairs(units) do
        if unit.obj == nil or unit.obj.dead or GetDistance2D(player,unit.obj) > (player.range + scanAdditionalRange) then
            units[i] = nil
        else
            local predictedDmg = 0
            local timeToHit = GetLatency()*100 + aaDelay + ( GetDistance2D(player,unit.obj) / projSpeed ) + timeSmoothness
            --local timeToHit = GetLatency() + aaDelay + ( GetDistance2D(player,unit.obj) / projSpeed ) + timeSmoothness
            for k, dmg in pairs(incDmg) do
                if (dmg.sourceObj == nil or dmg.sourceObj.dead or dmg.targetObj == nil or dmg.targetObj.dead)
                or (dmg.sourceObj.x ~= dmg.aaPos.x or dmg.sourceObj.z ~= dmg.aaPos.z) then
                    incDmg[k] = nil
                elseif unit.obj.networkID == dmg.targetObj.networkID then
                    --[[
                    if dmg.timeToHit == nil and dmg.projSpeed ~= nil and GetRealTick() - dmg.startTick >= dmg.aaDelay then
                        --dmg.timeToHit = dmg.aaDelay + GetDistance2D(dmg.sourceObj,unit.obj) / dmg.projSpeed
                        dmg.timeToHit = GetDistance2D(dmg.sourceObj,unit.obj) / dmg.projSpeed
                    end
                    if dmg.timeToHit ~= nil then
                        if GetRealTick() >= (dmg.startTick + dmg.timeToHit) then
                            incDmg[k] = nil
                        elseif GetRealTick() + timeToHit > (dmg.startTick + dmg.timeToHit) then
                            predictedDmg = predictedDmg + dmg.amount
                        end
                    end
                    ]]
                    dmg.timeToHit = ( dmg.projSpeed == 0 and ( dmg.aaDelay ) or ( dmg.aaDelay + GetDistance2D(dmg.sourceObj,unit.obj) / dmg.projSpeed ) )
                    if GetRealTick() >= (dmg.startTick + dmg.timeToHit) then
                        incDmg[k] = nil
                    elseif GetRealTick() + timeToHit > (dmg.startTick + dmg.timeToHit) then
                        predictedDmg = predictedDmg + dmg.amount
                    end
                end
            end
            if unit.obj.health - predictedDmg <= CalculatePhysicalDamage(unit.obj) * (1 - dmgSmoothMulti) - dmgSmoothness and unit.obj.health - predictedDmg > 0 then
                if scriptActive and (player.x ~= aaPos.x or player.z ~= aaPos.z or GetRealTick() - aaTick >= aaDelay) then
                    if holdPosition then player:HoldPosition() end
                    player:Attack(unit.obj)
                    aaPos.x, aaPos.z = player.x, player.z
                    aaTick = GetRealTick()
                    return
                end
            end
        end
    end

    if scriptActive and (player.x ~= aaPos.x or player.z ~= aaPos.z or GetRealTick() - aaTick >= aaDelay) then
        for i, unit in pairs(units) do
            if unit ~= nil and unit.obj ~= nil and not unit.obj.dead and unit.obj.health > 0 then
                -- Damage calculation using dam.lua
                if unit.obj.health <= CalculatePhysicalDamage(unit.obj) then
                    if holdPosition then player:HoldPosition() end
                    player:Attack(unit.obj)
                    aaPos.x,aaPos.y,aaPos.z = player.x, player.y, player.z
                    aaTick = GetRealTick()
                    return
                end
            end
        end
    end
end

local function Drawer()
    if animNotify then 
        de:Draw(ds) 
    end
    if drawCircleRange then DrawCircle(player.x, player.y, player.z, player.range, 0xFF80FF00) end
    if markAttackedCreeps and scriptActive then
        DrawText("Lasthit Active",18,100,80,0xFF80FF00)
        for i, unit in pairs(units) do
            if unit.obj ~= nil and not unit.obj.dead and GetRealTick() - unit.markTick <= markAttackedCreeps then
                DrawCircle(unit.obj.x, unit.obj.y, unit.obj.z, markRadius, 0xFF80FF00)
            end
        end
    end
end

local function Add(object)
    if object ~= nil and string.find(string.lower(object.name),string.lower(aaParticleName)) and player:GetDistance(object) <= 200 then
        aaDelay = GetRealTick() - oldDelayTick
    end
end

local function SpellTrack(object, spellName, spellLevel, posStart, posEnd)
    local x1 = posStart.x
    local y1 = posStart.y
    local z1 = posStart.z
    local x2 = posEnd.x
    local y2 = posEnd.y
    local z2 = posEnd.z
    
    if object ~= nil and object.networkID == player.networkID and string.find(string.lower(spellName),string.lower(aaSpellName)) then oldDelayTick = GetRealTick() return end

    if object ~= nil and object.team == player.team
    and (object.type == "obj_AI_Minion" or object.type == "obj_AI_Turret")
    and GetDistance2D(object,player) < player.range + scanAdditionalRange * 3 then
        for i,unit in pairs(units) do
            if unit.obj ~= nil and unit.obj.x == x2 and unit.obj.z == z2 then
                if object ~= nil and minionInfo[object.charName] ~= nil then
                    local m_aaD = ( object.type == "obj_AI_Turret" and minionInfo.obj_AI_Turret.aaDelay or minionInfo[object.charName].aaDelay )
                    local m_pS = ( object.type == "obj_AI_Turret" and minionInfo.obj_AI_Turret.projSpeed or minionInfo[object.charName].projSpeed )
                    incDmg[object.name] = { sourceObj = object, targetObj = unit.obj, amount = object:CalcDamage(unit.obj), startTick = GetRealTick(), aaPos = { x = object.x, z = object.z }, aaDelay = m_aaD, projSpeed = m_pS }
                    unit.markTick = GetRealTick()
                    return
                end
            end
        end
    end
end

local function Hotkey(msg,key)
    if key == HK then
        if msg == KEY_DOWN and not scripActive and holding == 0 then
            scriptActive = true
            holding = 1
            if animNotify then 
                animPlayedTick = nil
                ds:Get("notify"):RunAnimation("fadeinout",FADING,OPACITY,0,1,0.025,0)
                ds:Get("notify"):RunAnimation("slide",FADINGVELOCITY,POSITIONX,-70,70,6.8,0,0.955)
                ds.notify.objects[1].text = "LastHit: HOLD"
                ds.notify.objects[1].R = 0
                ds.notify.objects[1].G = 1
                ds.notify.objects[1].B = 0
            else
                --PrintChat("<font color='#7CFC00'> >> LastHit: ON</font>")
            end
        end
        if msg == KEY_UP and scriptActive and holding == 1 then
            scriptActive = false
            holding = 0
            if animNotify then
                animPlayedTick = nil
                ds:Get("notify"):RunAnimation("fadeinout",FADING,OPACITY,1,0,0.015,0)
                ds:Get("notify"):RunAnimation("slide",FADING,POSITIONX,70,0,0.3,0)
            else
                --PrintChat("<font color='#FF4500'> >> LastHit: OFF</font>")
            end
        end
    end
end

if champTable[player.charName] ~= nil then
    projSpeed = champTable[player.charName].projSpeed
    aaParticleName = champTable[player.charName].aaParticleName
    aaSpellName = champTable[player.charName].aaSpellName
    dmgSmoothMulti = (dmgSmoothMulti or champTable[player.charName].dmgSmoothMulti)
    BoL:addMsgHandler(Hotkey)
    BoL:addDrawHandler(Drawer)
    BoL:addTickHandler(Timer, 10)
    BoL:addCreateObjHandler(Add)
    BoL:addProcessSpellHandler(SpellTrack)
    PrintChat(" >> LastHiteee v0.5b by Weee, modified for BoL by Keoshin")
else
    PrintChat(" >> LastHiteee [ERROR]: you're playing not supported champion! " .. player.charName)
end

end