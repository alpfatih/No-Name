--[[
        Script: Jungle Display v0.1b
		Author: SurfaceS
		
		required libs : 		map
		required sprites : 		Jungle Sprites
		exposed variables : 	jungle, file_exists
		
		UPDATES :
		v0.1					initial release
		v0.1b					added twisted treeline + ping and chat functions.
		
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

--[[      GLOBAL      ]]
if SCRIPT_PATH == nil then SCRIPT_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2) end
if LIB_PATH == nil then LIB_PATH = SCRIPT_PATH.."Libs/" end
if SPRITE_PATH == nil then SPRITE_PATH = SCRIPT_PATH:gsub("\\", "/"):gsub("/Scripts", "").."Sprites/" end
if myHero == nil then myHero = GetMyHero() end
if map == nil then dofile(LIB_PATH.."map.lua") else return end

jungle = {}

-- [[     CONFIG     ]]
jungle.pingOnRespawn = true				-- ping location on respawn
jungle.pingOnRespawnBefore = true		-- ping location before respawn
jungle.textOnRespawn = true				-- print chat text on respawn
jungle.textOnRespawnBefore = true		-- print chat text before respawn
jungle.adviceBefore = 20				-- time in second to advice before monster respawn
jungle.adviceEnemyMonsters = true		-- advice enemy monster, or just our monsters

--[[      GLOBAL      ]]
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
jungle.teams = {
	team100 = {	spriteFile = "TeamBlue_64",	},
	team200 = {	spriteFile = "TeamRed_64",},
	team300 = {	spriteFile = "TeamNeutral_64", },
}

jungle.monsters = {
	summonerRift = {
		{	-- baron
			name = "baron",
			spriteFile = "Baron_Square_64",
			respawn = 420,
			advise = true,
			camps = {
				{
					name = "monsterCamp_12",
					creeps = { { { name = "Worm12.1.1" }, }, },
					team = TEAM_NEUTRAL,
				},
			},
		},
		{	-- dragon
			name = "dragon",
			spriteFile = "Dragon_Square_64",
			respawn = 360,
			advise = true,
			camps = {
				{
					name = "monsterCamp_6",
					creeps = { { { name = "Dragon6.1.1" }, }, },
					team = TEAM_NEUTRAL,
				},
			},
		},
		{	-- blue
			name = "blue",
			spriteFile = "AncientGolem_Square_64",
			respawn = 300,
			advise = true,
			camps = {
				{
					name = "monsterCamp_1",
					creeps = { { { name = "AncientGolem1.1.1" }, { name = "YoungLizard1.1.2" }, { name = "YoungLizard1.1.3" }, }, },
					team = TEAM_BLUE,
				},
				{
					name = "monsterCamp_7",
					creeps = { { { name = "AncientGolem7.1.1" }, { name = "YoungLizard7.1.2" }, { name = "YoungLizard7.1.3" }, }, },
					team = TEAM_RED,
				},
			},
		},
		{	-- red
			name = "red",
			spriteFile = "LizardElder_Square_64",
			respawn = 300,
			advise = true,
			camps = {
				{
					name = "monsterCamp_4",
					creeps = { { { name = "LizardElder4.1.1" }, { name = "YoungLizard4.1.2" }, { name = "YoungLizard4.1.3" }, }, },
					team = TEAM_BLUE,
				},
				{
					name = "monsterCamp_10",
					creeps = { { { name = "LizardElder10.1.1" }, { name = "YoungLizard10.1.2" }, { name = "YoungLizard10.1.3" }, }, },
					team = TEAM_RED,
				},
			},
		},
		{	-- wolves
			name = "wolves",
			spriteFile = "Giantwolf_Square_64",
			respawn = 60,
			advise = false,
			camps = {
				{
					name = "monsterCamp_2",
					creeps = { { { name = "GiantWolf2.1.3" }, { name = "wolf2.1.1" }, { name = "wolf2.1.2" }, }, },
					team = TEAM_BLUE,
				},
				{
					name = "monsterCamp_8",
					creeps = { { { name = "GiantWolf8.1.3" }, { name = "wolf8.1.1" }, { name = "wolf8.1.2" }, }, },
					team = TEAM_RED,
				},
			},
		},
		{	-- wraiths
			name = "wraiths",
			spriteFile = "Wraith_Square_64",
			respawn = 50,
			advise = false,
			camps = {
				{
					name = "monsterCamp_3",
					creeps = { { { name = "Wraith3.1.1" }, { name = "LesserWraith3.1.2" }, { name = "LesserWraith3.1.3" }, { name = "LesserWraith3.1.4" }, }, },
					team = TEAM_BLUE,
				},
				{
					name = "monsterCamp_9",
					creeps = { { { name = "Wraith9.1.1" }, { name = "LesserWraith9.1.2" }, { name = "LesserWraith9.1.3" }, { name = "LesserWraith9.1.4" }, }, },
					team = TEAM_RED,
				},
			},
		},
		{	-- Golems
			name = "Golems",
			spriteFile = "AncientGolem_Square_64",
			respawn = 60,
			advise = false,
			camps = {
				{
					name = "monsterCamp_5",
					creeps = { { { name = "Golem5.1.2" }, { name = "SmallGolem5.1.1" }, }, },
					team = TEAM_BLUE,
				},
				{
					name = "monsterCamp_11",
					creeps = { { { name = "Golem11.1.2" }, { name = "SmallGolem11.1.1" }, }, },
					team = TEAM_RED,
				},
			},
		},
	},
	twistedTreeline = {
		{	-- Dragon
			name = "Dragon",
			spriteFile = "Dragon_Square_64",
			respawn = 300,
			advise = true,
			camps = {
				{
					name = "monsterCamp_7",
					creeps = { { { name = "blueDragon7$1" }, }, },
					team = TEAM_NEUTRAL,
				},
			},
		},
		{	-- Lizard
			name = "Lizard",
			spriteFile = "LizardElder_Square_64",
			respawn = 240,
			advise = true,
			camps = {
				{
					name = "monsterCamp_8",
					creeps = { { { name = "TwistedLizardElder8$1" }, }, },
					team = TEAM_NEUTRAL,
				},
			},
		},
		{	-- Ghast Wraith or Radib Wolf
			name = "Buff Camp",
			spriteFile = "Wraith_Square_64",
			respawn = 180,
			advise = true,
			camps = {
				{
					name = "monsterCamp_5",
					creeps = {
						{ { name = "Ghast5$1" }, { name = "TwistedBlueWraith5$2" }, { name = "TwistedBlueWraith5$3" }, },
						{ { name = "RabidWolf5$1" }, { name = "TwistedGiantWolf5$2" }, { name = "TwistedGiantWolf5$3" }, },
					},
					team = TEAM_BLUE,
				},
				{
					name = "monsterCamp_6",
					creeps = {
						{ { name = "Ghast6$1" }, { name = "TwistedBlueWraith6$2" }, { name = "TwistedBlueWraith6$3" }, },
						{ { name = "RabidWolf6$1" }, { name = "TwistedGiantWolf6$2" }, { name = "TwistedGiantWolf6$3" }, },
					},
					team = TEAM_RED,
				},
				
			},
		},
		{	-- Small Golems - Young Lizard, Lizard, Golem
			name = "bottom small camp",
			spriteFile = "AncientGolem_Square_64",
			respawn = 75,
			advise = false,
			camps = {
				{
					name = "monsterCamp_1",
					creeps = {
						{ { name = "Lizard1$1" }, { name = "TwistedGolem1$2" }, { name = "TwistedYoungLizard1$3" }, },
						{ { name = "TwistedBlueWraith1$1" }, { name = "TwistedTinyWraith1$2" }, { name = "TwistedTinyWraith1$3" }, { name = "TwistedTinyWraith1$4" }, },
					},
					team = TEAM_BLUE,
				},
				{
					name = "monsterCamp_2",
					creeps = { 
						{ { name = "Lizard2$1" }, { name = "TwistedGolem2$2" }, { name = "TwistedYoungLizard2$3" }, },
						{ { name = "TwistedBlueWraith2$1" }, { name = "TwistedTinyWraith2$2" }, { name = "TwistedTinyWraith2$3" }, { name = "TwistedTinyWraith2$4" }, },
					 },
					team = TEAM_RED,
				},
			},
		},
		{	-- Small Golems - Young Lizard, Lizard, Golem
			name = "Top small camp",
			spriteFile = "Giantwolf_Square_64",
			respawn = 75,
			advise = false,
			camps = {
				{
					name = "monsterCamp_3",
					creeps = { 
						{ { name = "TwistedGiantWolf3$3" }, { name = "TwistedSmallWolf3$1" }, { name = "TwistedSmallWolf3$2" }, },
						{ { name = "TwistedGolem3$1" }, { name = "TwistedGolem3$2" } },
					},
					team = TEAM_BLUE,
				},
				{
					name = "monsterCamp_4",
					creeps = { 
						{ { name = "TwistedGiantWolf4$3" }, { name = "TwistedSmallWolf4$1" }, { name = "TwistedSmallWolf4$2" }, },
						{ { name = "TwistedGolem4$1" }, { name = "TwistedGolem4$2" } },
					},
					team = TEAM_RED,
				},
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

function jungle.timerSecondLeft(tick, respawn, deathTick)
	return math.ceil(math.max(0, respawn - (tick - deathTick) / 1000))
end

function jungle.timerText(seconds)
	--local timeLeft = respawn - (tick - deathTick) / 1000
	--timeLeft = math.max(0,timeLeft)
	--local seconds_tl = seconds % 60
	--local minutes_tl = seconds / 60
	return string.format("%i:%02i",seconds / 60,seconds % 60)
end

function jungle.drawHandler()
	local monsterCount = 0
	for i,monster in pairs(jungle.monsters[map.shortName]) do
		if monster.isSeen == true then			
			if jungle.display.rotation == 0 or jungle.display.rotation == 2 then
				jungle.monsters[map.shortName][i].sprite:Draw(jungle.display.x + (monsterCount * 64),jungle.display.y,0xFF)
			else
				jungle.monsters[map.shortName][i].sprite:Draw(jungle.display.x,jungle.display.y + (monsterCount * 64),0xFF)
			end
			for j,camp in pairs(monster.camps) do
				if camp.status > 0 then
					local shiftX,shiftY
					if jungle.display.rotation == 0 then
						shiftX = (monsterCount * 64)
						shiftY = (camp.enemyTeam and 90 or 70)
					elseif jungle.display.rotation == 1 then
						shiftX = 70
						shiftY = (monsterCount * 64) + (camp.enemyTeam and 32 or 12)
					elseif jungle.display.rotation == 2 then
						shiftX = (monsterCount * 64)
						shiftY = (camp.enemyTeam and -40 or -20)
					elseif jungle.display.rotation == 3 then
						shiftX = -70
						shiftY = (monsterCount * 64) + (camp.enemyTeam and 32 or 12)
					end
					jungle.teams["team"..camp.team].sprite:Draw(jungle.display.x + shiftX,jungle.display.y + shiftY,0xFF)
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
		for i,monster in pairs(jungle.monsters[map.shortName]) do
			for j,camp in pairs(monster.camps) do
				if camp.name == object.name then
					camp.object = object
					return
				end
				for k,creepPack in ipairs(camp.creeps) do
					for l,creep in ipairs(creepPack) do
						if object.name == creep.name then
							creep.object = object
							return
						end
					end
				end
			end
		end
	end
end

function jungle.removeCreep(object)
	if object ~= nil and object.name ~= nil then
		for i,monster in pairs(jungle.monsters[map.shortName]) do
			for j,camp in pairs(monster.camps) do
				for k,creepPack in ipairs(camp.creeps) do
					for l,creep in ipairs(creepPack) do
						if object.name == creep.name then
							creep.object = nil
							return
						end
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
	for i,monster in pairs(jungle.monsters[map.shortName]) do
		for j,camp in pairs(monster.camps) do
			local campStatus = 0
			for k,creepPack in ipairs(camp.creeps) do
				for l,creep in ipairs(creepPack) do
					if creep.object ~= nil and creep.object.dead == false then
						if l == 1 then
							campStatus = 1
						elseif campStatus ~= 1 then
							campStatus = 2
						end
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
					camp.advisedBefore = false
					camp.advised = false
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
					local secondLeft = jungle.timerSecondLeft(tick, monster.respawn, camp.deathTick)
					if monster.advise == true and (jungle.adviceEnemyMonsters == true or camp.enemyTeam == false) then
						if secondLeft == 0 and camp.advised == false then
							camp.advised = true
							if jungle.textOnRespawn then PrintChat("<font color='#00FFCC'>"..(camp.enemyTeam and "Enemy " or "")..monster.name.."</font> has respawned") end
							if jungle.pingOnRespawn then PingSignal(PING_FALLBACK,camp.object.x,camp.object.y,camp.object.z,2) end
						elseif secondLeft <= jungle.adviceBefore and camp.advisedBefore == false then
							camp.advisedBefore = true
							if jungle.textOnRespawnBefore then PrintChat("<font color='#00FFCC'>"..(camp.enemyTeam and "Enemy " or "")..monster.name.."</font> will respawn in "..secondLeft.." sec") end
							if jungle.pingOnRespawnBefore then PingSignal(PING_FALLBACK,camp.object.x,camp.object.y,camp.object.z,2) end
						end
					end
					-- temp fix until camp.showOnMinimap work
					if secondLeft == 0 then
						camp.status = 0
					end
					camp.drawText = " "..jungle.timerText(secondLeft)
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

if jungle.monsters[map.shortName] ~= nil then
	-- load icons drawing sprites
	for i,icon in pairs(jungle.icon) do
		icon.sprite = jungle.returnSprite(icon.spriteFile..".dds")
	end
	-- load side drawing sprites
	for i,camps in pairs(jungle.teams) do
		camps.sprite = jungle.returnSprite(camps.spriteFile..".dds")
	end
	-- load monster sprites and init values
	for i,monster in pairs(jungle.monsters[map.shortName]) do
		monster.sprite = jungle.returnSprite(monster.spriteFile..".dds")
		monster.isSeen = false
		for j,camp in pairs(monster.camps) do
			camp.enemyTeam = (camp.team ~= TEAM_NEUTRAL and camp.team ~= myHero.team)
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
else
	jungle = nil
end