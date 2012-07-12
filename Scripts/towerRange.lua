--[[
	Script: Tower Range v0.1
	Author: SurfaceS on idea from Shoot
		
	Usage : Press toggle key to walk thru :
		-> Do nothing (Default)
		-> Show enemy turrets range close to your champion
		-> Show all enemy turrets range
		-> Show all turrets range
]]--

--[[         Config         ]]
local toggleKey = 116 					-- F5
local turretRange = 950 				-- 950
local fountainRange = 1050 				-- 1050
local allyTurretColor = 0xFF80FF00 		-- Greenish color, change to your liking (ARGB)
local enemyTurretColor = 0xFFFF0000 	-- Redish color, change to your liking (ARGB)

--[[         Globals        ]]
local turrets = {}
local activeType = 1

--[[         Code           ]]
if myHero == nil then myHero = GetMyHero() end
if GetDistance2D == nil then 
	function GetDistance2D( p1, p2 )
		if p1.z == nil or p2.z == nil then
			return math.sqrt((p1.x-o2.x)^2+(p1.y-p2.y)^2)
		else
			return math.sqrt((p1.x-p2.x)^2+(p1.z-p2.z)^2)
		end
	end
end

function drawHandler()
    if activeType > 0 then
        for i, turret in ipairs(turrets) do
            if turret ~= nil and turret.active and ( activeType == 3 or ( turret.team ~= myHero.team and ( activeType == 2 or ( activeType == 1 and myHero.dead == false and GetDistance2D(myHero, turret) < 2000 ) ) ) ) then
				DrawCircle(turret.x, turret.y, turret.z, turret.range, turret.color)
			end
		end
	end
end

function msgHandler(msg, key)
    if key == toggleKey and msg == KEY_UP then
		if activeType == 0 then
			PrintChat("Turret range display is ON (enemy close)")
			activeType = 1
		elseif activeType == 1 then
			PrintChat("Turret range display is ON (enemy)")
			activeType = 2
		elseif activeType == 2 then
			PrintChat("Turret range display is ON (all)")
			activeType = 3
		else
			PrintChat("Turret range display is OFF")
			activeType = 0
		end
    end
end

function tickHandler()
	if activeType > 0 then
		local activeTurrets = {}
		for i = 1, objManager.iCount, 1 do
			local obj = objManager:getObject(i)
			if obj ~= nil and obj.type == "obj_AI_Turret" then
				table.insert(activeTurrets, obj.name)
			end
		end
		for i, turret in ipairs(turrets) do
			local turretActive = false
			for j, activeTurretName in ipairs(activeTurrets) do
				if turret.name == activeTurretName then
					turretActive = true
					break
				end
			end
			turret.active = turretActive
		end
	end
end

for i = 1, objManager.iCount, 1 do
	local obj = objManager:getObject(i)
	if obj ~= nil and obj.type == "obj_AI_Turret" then
		local turret = {}
		turret.name = obj.name
		turret.team = obj.team
		turret.active = true
		if obj.name == "Turret_OrderTurretShrine_A" or obj.name == "Turret_ChaosTurretShrine_A" then
			turret.range = fountainRange
			for j = 1, objManager.iCount, 1 do
				local objSP = objManager:getObject(j)
				if objSP ~= nil and objSP.type == "obj_SpawnPoint" and obj:GetDistance(objSP) < 1000 then
					turret.x = objSP.x
					turret.z = objSP.z
				elseif objSP ~= nil and objSP.type == "obj_HQ" and obj:GetDistance(objSP) < 3000 then
					turret.y = objSP.y
				end
			end
		else
			turret.range = turretRange
			turret.x = obj.x
			turret.y = obj.y
			turret.z = obj.z
		end
		if turret.team == myHero.team then
			turret.color = allyTurretColor
		else
			turret.color = enemyTurretColor
		end
		table.insert(turrets, turret)
	end
end

BoL:addDrawHandler(drawHandler)
BoL:addMsgHandler(msgHandler)
BoL:addTickHandler(tickHandler, 250)
