--[[
	Script: Tower Range display v0.3
	Author: Shoot

    Changelog:
        - Fixed bug (though fountain for loop is still a mess)
        - Optimized a bit
]] --

--[[        Configs     ]]
local toggleKey = 112 -- F1
local turretRange = 1000 -- 800 is the known range but it still hits you outside, modify to your liking
local fountainRange = 1550 -- Eyeballed, works with small flaw, modify to your liking
local allyTurretColor = 0xFF80FF00 -- Greenish color, change to your liking (ARGB)
local enemyTurretColor = 0xFFFF0000 -- Redish color, change to your liking (ARGB)

--[[        Variables       ]]
local towers = {}
local fountains = {}
local active = false
local myHero = GetMyHero()


function drawHandler()
    if not active then return end
    for i, tow in ipairs(towers) do
        if tow.health > 0 then
            local col = allyTurretColor
            if tow.team ~= myHero.team then
                col = enemyTurretColor
            end
            DrawCircle(tow.x, tow.y, tow.z, turretRange, col)
        else
            table.remove(towers, i)
        end
    end

    for i, fount in ipairs(fountains) do
        if fount.health > 0 then
            if fount.name == "Turret_ChaosTurretShrine" then
                if fount.team == myHero.team then
                    DrawCircle(fount.x, fount.y, fount.z, fountainRange, allyTurretColor)
                else
                    DrawCircle(fount.x, fount.y, fount.z, fountainRange, enemyTurretColor)
                end
            elseif fount.name == "Turret_OrderTurretShrine" then
                if fount.team == myHero.team then
                    DrawCircle(fount.x, fount.y, fount.z, fountainRange, allyTurretColor)
                else
                    DrawCircle(fount.x, fount.y, fount.z, fountainRange, enemyTurretColor)
                end
            end
        end
    end
end

function msgHandler(msg, key)
    if key == toggleKey and msg == KEY_UP then
        if active then
            PrintChat("Turret range display is OFF")
            active = false
        else
            PrintChat("Turret range display is ON")
            active = true
        end
    end
end

function load()
    towers = {}
    fountains = {}
    for i = 1, objManager.iCount, 1 do
        local obj = objManager:getObject(i)
        if obj ~= nil and string.find(obj.type, "obj_Turret") ~= nil and string.find(obj.name, "_A") == nil and obj.health > 0 then
            if string.find(obj.name, "TurretShrine") then
                table.insert(fountains, obj)
            else
                table.insert(towers, obj)
            end
        end
    end
end

BoL:addDrawHandler(drawHandler)
BoL:addMsgHandler(msgHandler)
load()