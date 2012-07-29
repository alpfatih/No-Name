--[[
        Script: Jungle Display v0.1
		Author: SurfaceS
		
		required libs : 		none
		required sprites : 		Jungle Sprites
		exposed variables : 	jungle, file_exists
		
		UPDATES :
		v0.1					initial release
		
		USAGE :
		The script allow you to move and rotate the display
		
		Icons :
		You have 2 icons on the top left of the jungle display.
		First is for moving, the second is for rotate the display.
		
		Moving :
		Hold the shift key, clic the move icon and drag the jungle display were you want.
		Settings are saved between games
		
		Rotate :
		Hold the shift key, clic the rotate icon. (4 types of rotation)
		Settings are saved between games
		
]]

if SCRIPT_PATH == nil then SCRIPT_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2) end
if LIB_PATH == nil then LIB_PATH = SCRIPT_PATH.."Libs/" end
if SPRITE_PATH == nil then SPRITE_PATH = SCRIPT_PATH:gsub("\\", "/"):gsub("/Scripts", "").."Sprites/" end
if myHero == nil then myHero = GetMyHero() end

jungle = {}
jungle.configFile = LIB_PATH.."jungle.cfg"
jungle.display = {}
jungle.display.x = 500
jungle.display.y = 20
jungle.display.rotation = 0
jungle.display.move = false
jungle.display.moveUnder = false
jungle.display.rotateUnder = false

jungle.shiftKeyPressed = false

jungle.icon = { arrowPressed = { spriteFile = "ArrowPressed_16", }, arrowReleased = { spriteFile = "ArrowReleased_16", }, arrowSwitch = { spriteFile = "ArrowSwitch_16", },}
jungle.camps = {
	team300 = {
		spriteFile = "TeamNeutral_64",
	},
	team100 = {
		spriteFile = "TeamBlue_64",
	},
	team200 = {
		spriteFile = "TeamRed_64",
	},
}
jungle.monsters = {
	{	-- baron
		name = "baron",
        spriteFile = "Baron_Square_64",
        respawn = 420,
		camps = {
			{
		        name = "monsterCamp_12",
				creeps = { { name = "Worm12.1.1" }, },
				team = TEAM_NEUTRAL,
				position = {x = 4439, z = 10082},
			},
		},
	},
    {	-- dragon
		name = "dragon",
        spriteFile = "Dragon_Square_64",
        respawn = 360,
		camps = {
			{
		        name = "monsterCamp_6",
				creeps = { { name = "Dragon6.1.1" }, },
				team = TEAM_NEUTRAL,
				position = {x = 9821, z = 4728},
			},
		},
    },
	{	-- blue
		name = "blue",
        spriteFile = "AncientGolem_Square_64",
        respawn = 300,
		camps = {
			{
				name = "monsterCamp_1",
		        creeps = { { name = "AncientGolem1.1.1" }, { name = "YoungLizard1.1.2" }, { name = "YoungLizard1.1.3" } },
				team = TEAM_BLUE,
				position = {x = 3181, z = 7900,},
			},
			{
				name = "monsterCamp_7",
		        creeps = { { name = "AncientGolem7.1.1" }, { name = "YoungLizard7.1.2" }, { name = "YoungLizard7.1.3" } },
				team = TEAM_RED,
				position = {x = 10917, z = 6612,},
			},
		},
	},
	{	-- red
		name = "red",
        spriteFile = "LizardElder_Square_64",
        respawn = 300,
		camps = {
			{
				name = "monsterCamp_4",
		        creeps = { { name = "LizardElder4.1.1" }, { name = "YoungLizard4.1.2" }, { name = "YoungLizard4.1.3" } },
				team = TEAM_BLUE,
				position = {x = 7600, z = 3517},
			},
			{
				name = "monsterCamp_10",
		        creeps = { { name = "LizardElder10.1.1" }, { name = "YoungLizard10.1.2" }, { name = "YoungLizard10.1.3" } },
				team = TEAM_RED,
				position = {x = 6430, z = 11008},
			},
		},
	},
	{	-- wolves
		name = "wolves",
        spriteFile = "Giantwolf_Square_64",
        respawn = 60,
		camps = {
			{
				name = "monsterCamp_2",
		        creeps = { { name = "GiantWolf2.1.3" }, { name = "wolf2.1.1" }, { name = "wolf2.1.2" } },
				team = TEAM_BLUE,
				position = {x = 3335, z = 6164},
			},
			{
				name = "monsterCamp_8",
		        creeps = { { name = "GiantWolf8.1.3" }, { name = "wolf8.1.1" }, { name = "wolf8.1.2" } },
				team = TEAM_RED,
				position = {x = 10591, z = 8530},
			},
		},
	},
	{	-- wraiths
        name = "wraiths",
		spriteFile = "Wraith_Square_64",
        respawn = 50,
		camps = {
			{
				name = "monsterCamp_3",
		        creeps = { { name = "Wraith3.1.1" }, { name = "LesserWraith3.1.2" }, { name = "LesserWraith3.1.3" }, { name = "LesserWraith3.1.4" } },
				team = TEAM_BLUE,
				position = {x = 6671, z = 4913},
			},
			{
				name = "monsterCamp_9",
		        creeps = { { name = "Wraith9.1.1" }, { name = "LesserWraith9.1.2" }, { name = "LesserWraith9.1.3" }, { name = "LesserWraith9.1.4" } },
				team = TEAM_RED,
				position = {x = 7463, z = 9640},
			},
		},
	},	
}

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

if file_exists(jungle.configFile) then
    dofile(jungle.configFile)
end

function jungle.writeConfigs()
    local file = io.open(jungle.configFile, "w")
    if file then
        local var1 = jungle.display.x
        local var2 = jungle.display.y
		local var3 = jungle.display.rotation
        file:write("jungle.display.x = "..var1.."\njungle.display.y = "..var2.."\njungle.display.rotation = "..var3.."\n")
        file:close()
    end
end

function jungle.returnSprite(file)
	if file_exists(SPRITE_PATH..file) == true then
		return createSprite(file)
	end
	return createSprite("empty.dds")
end

function jungle.timerText( tick, respawn, deathTick )
	local timeLeft = respawn - (tick - deathTick) / 1000
	timeLeft = math.max(0,timeLeft)
	local seconds_tl = timeLeft % 60
	local minutes_tl = timeLeft / 60
	return string.format("%i:%02i",minutes_tl,seconds_tl)
end

function jungle.drawHandler()
	local monsterCount = 0
	for i,monster in pairs(jungle.monsters) do
		if monster.isSeen == true then			
			if jungle.display.rotation == 0 or jungle.display.rotation == 2 then
				jungle.monsters[i].sprite:Draw(jungle.display.x + (monsterCount * 64),jungle.display.y,0xFF)
			else
				jungle.monsters[i].sprite:Draw(jungle.display.x,jungle.display.y + (monsterCount * 64),0xFF)
			end
			for j,camp in pairs(monster.camps) do
				if camp.status > 0 then
					local shiftX,shiftY
					if jungle.display.rotation == 0 then
						shiftX = (monsterCount * 64)
						shiftY = (camp.ennemyTeam and 90 or 70)
					elseif jungle.display.rotation == 1 then
						shiftX = 70
						shiftY = (monsterCount * 64) + (camp.ennemyTeam and 32 or 12)
					elseif jungle.display.rotation == 2 then
						shiftX = (monsterCount * 64)
						shiftY = (camp.ennemyTeam and -40 or -20)
					elseif jungle.display.rotation == 3 then
						shiftX = -70
						shiftY = (monsterCount * 64) + (camp.ennemyTeam and 32 or 12)
					end
					jungle.camps["team"..camp.team].sprite:Draw(jungle.display.x + shiftX,jungle.display.y + shiftY,0xFF)
					DrawText(camp.drawText,17,jungle.display.x + shiftX + 10,jungle.display.y + shiftY - 3,camp.drawColor)
				end
			end
			monsterCount = monsterCount + 1
		end
	end
	if monsterCount > 0 then
		--jungle.icon[(jungle.display.moveUnder and "arrowPressed" or "arrowReleased")].sprite:Draw(jungle.display.x,jungle.display.y,0xFF)
		jungle.icon.arrowPressed.sprite:Draw(jungle.display.x,jungle.display.y,(jungle.shiftKeyPressed and 0xFF or 0xAA))
		jungle.icon.arrowSwitch.sprite:Draw(jungle.display.x+16,jungle.display.y,(jungle.shiftKeyPressed and 0xFF or 0xAA))
	end
end

function jungle.addCampAndCreep(object)
	if object ~= nil and object.name ~= nil then
		for i,monster in pairs(jungle.monsters) do
			for j,camp in pairs(monster.camps) do
				if camp.name == object.name then
					camp.object = object
					return
				end
				for k,creep in ipairs(camp.creeps) do
					if object.name == creep.name then
						creep.object = object
						return
					end
				end
			end
		end
	end
end

function jungle.removeCreep(object)
	if object ~= nil and object.name ~= nil then
		for i,monster in pairs(jungle.monsters) do
			for j,camp in pairs(monster.camps) do
				for k,creep in ipairs(camp.creeps) do
					if object.name == creep.name then
						creep.object = nil
						return
					end
				end
			end
		end
	end
end

function jungle.msgHandler(msg, key)
	if key == 16 then jungle.shiftKeyPressed = (msg == KEY_DOWN) end
	if jungle.display.moveUnder and msg == WM_LBUTTONDOWN then
		jungle.display.move = true
	elseif jungle.display.move and msg == WM_LBUTTONUP then
		jungle.display.move = false
		jungle.display.moveUnder = false
		jungle.display.cursorShift = nil
		jungle.writeConfigs()
	elseif jungle.display.rotateUnder and msg == WM_LBUTTONDOWN then
		jungle.display.rotation = (jungle.display.rotation == 3 and 0 or jungle.display.rotation + 1)
		jungle.writeConfigs()
	end
end

function jungle.createObjHandler(object)
    if object ~= nil then
		jungle.addCampAndCreep(object)
    end
end

function jungle.deleteObjHandler(object)
    if object ~= nil then
		jungle.removeCreep(object)
    end
end

function jungle.tickHandler()
	local tick = GetTickCount()
	for i,monster in pairs(jungle.monsters) do
		for j,camp in pairs(monster.camps) do
			local campStatus = 0
			for k,creep in ipairs(camp.creeps) do
				if creep.object ~= nil and creep.object.dead == false then
					if k == 1 then
						campStatus = 1
					elseif campStatus ~= 1 then
						campStatus = 2
					end
				end
			end
			--[[  Not used until camp.showOnMinimap work
			if (camp.object and camp.object.showOnMinimap == 1) then
				-- camp is here
				if campStatus == 0 then campStatus = 3 end
			elseif camp.status == 3 then 						-- empty not seen when killed
				campStatus = 5
			elseif campStatus == 0 and (camp.status == 1 or camp.status == 2) then
				campStatus = 4
				camp.deathTick = tick
			end
			]]
			-- temp fix until camp.showOnMinimap work
			-- not so good
			if camp.object ~= nil and campStatus == 0 then
				if (camp.status == 1 or camp.status == 2) then
					campStatus = 4
					camp.deathTick = tick
				elseif (camp.status == 4) then
					campStatus = 4
				else
					campStatus = 3
				end
			end
			if camp.status ~= campStatus or campStatus == 4 then
				if campStatus ~= 0 then
					if monster.isSeen == false then monster.isSeen = true end
					camp.status = campStatus
				end
				if camp.status == 1 then				-- ready
					camp.drawText = "ready"
					camp.drawColor = 0xFF00FF00
				elseif camp.status == 2 then			-- ready, master creeps dead
					camp.drawText = "stolen"
					camp.drawColor = 0xFFFF0000
				elseif camp.status == 3 then			-- ready, not creeps shown
					camp.drawText = "   ?"
					camp.drawColor = 0xFF00FF00			
				elseif camp.status == 4 then			-- empty from creeps kill
					local texted = jungle.timerText( tick, monster.respawn, camp.deathTick )
					-- temp fix until camp.showOnMinimap work
					if texted == "0:00" then
						camp.status = 0
					end
					camp.drawText = " "..jungle.timerText( tick, monster.respawn, camp.deathTick )
					camp.drawColor = 0xFFFFFF00
				elseif camp.status == 5 then			-- empty from camp disabled on minimap
					camp.drawText = "   -"
					camp.drawColor = 0xFFFF0000
				end
			end
		end
	end
	if jungle.display.move == true then
		if jungle.display.cursorShift == nil or jungle.display.cursorShift.x == nil or jungle.display.cursorShift.y == nil then
			jungle.display.cursorShift = {}
			jungle.display.cursorShift.x = GetCursorPos().x - jungle.display.x
			jungle.display.cursorShift.y = GetCursorPos().y - jungle.display.y
		else
			jungle.display.x = GetCursorPos().x - jungle.display.cursorShift.x
			jungle.display.y = GetCursorPos().y - jungle.display.cursorShift.y
		end
	else
		jungle.display.moveUnder = (jungle.shiftKeyPressed and GetCursorPos().x >= jungle.display.x and GetCursorPos().x <= jungle.display.x+16 and GetCursorPos().y >= jungle.display.y and GetCursorPos().y <= jungle.display.y+16)
		jungle.display.rotateUnder = (jungle.shiftKeyPressed and GetCursorPos().x >= jungle.display.x+16 and GetCursorPos().x <= jungle.display.x+32 and GetCursorPos().y >= jungle.display.y and GetCursorPos().y <= jungle.display.y+16)
	end
end

-- load icons drawing sprites
for i,icon in pairs(jungle.icon) do
	icon.sprite = jungle.returnSprite(icon.spriteFile..".dds")
end
-- load side drawing sprites
for i,camps in pairs(jungle.camps) do
	camps.sprite = jungle.returnSprite(camps.spriteFile..".dds")
end
-- load monster sprites and init values
for i,monster in pairs(jungle.monsters) do
	monster.sprite = jungle.returnSprite(monster.spriteFile..".dds")
	monster.isSeen = false
	for j,camp in pairs(monster.camps) do
		camp.ennemyTeam = (camp.team ~= TEAM_NEUTRAL and camp.team ~= myHero.team)
		camp.status = 0
		camp.drawText = ""
		camp.drawColor = 0xFF00FF00
	end
end

for i = 1, objManager.maxObjects, 1 do
	local object = objManager:getObject(i)
	if object ~= nil then 
		jungle.createObjHandler(object)
	end
end

BoL:addDeleteObjHandler(jungle.deleteObjHandler)
BoL:addCreateObjHandler(jungle.createObjHandler)
BoL:addDrawHandler(jungle.drawHandler)
BoL:addMsgHandler(jungle.msgHandler)
BoL:addTickHandler(jungle.tickHandler, 250)