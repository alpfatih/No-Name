if GetMyHero().charName == "Soraka" then
--[[
	SORAKA SLACKER v8
	By Ivan[russia]
	Credits To Zynox/grey autolvl spell/ikita autosilence/nanja taric/wee Ward Scanner
	I Learned From Their Previous Scripts
	v7: script heal ignited too, but now it preffer unignated targets
	
	Updated for BoL by ikita v8.1
--]]

------------------------------- SETTINGS -------------------------------
-- you can change true to false and false to true
-- false means turn off
-- true means turn on
SetupAutoUlt= true -- Auto Ult
SetupUltEffect=2 -- (between 1-5), script use ult when (Full_Ult_Heal_Possible_Value) > (One_Man_Ult_Heal_Possible_Value * SetupUltEffect)  

SetupAutoHeal= true -- Auto Heal
SetupHealGiveRate= 1 -- At which rate you should heal.      	Example: your usual heal gives 100 hp , SetupHealGiveRate=3 means 100x3, so script heals when target miss 300 hp

SetupAutoMana= true -- Auto Mana
SetupManaGiveRate= 3 -- At which rate you should give mana. 	Example: your usual mana gives 50 mana, SetupManaGiveRate=2 means 50x2, so script gives mana when target miss 100 mana. Check 1 rate if you want give mana often

SetupAutoSilence= true -- Auto Silence --in development
SetupAntiKarthus= true -- Soraka AutoUlt KarthusUlt on low hp targets

SetupDistance= 850 -- How much distance to use spells

SetupTogleKey= 117	--Key to Togle script. [ F6 - 117 ] default
					--key codes
					--http://www.indigorose.com/webhelp/ams/Program_Reference/Misc/Virtual_Key_Codes.htm 

SetupAutoLvLSpell= true -- AutoLvL Spells of soraka
abilitySequence = {2,3,2,3,2,4,2,3,2,3,4,3,1,1,1,4,1,1} -- list for SetupAutoLvLSpell

SetupDrawInfo = true -- Drawing usefull info on screen
SetupDrawX = 0.8 
SetupDrawY = 0.2 -- Position of info, minimum = 0, maximum = 1, SetupDrawX - width, SetupDrawY - height




------------------------------- GLOBALS [Do Not Change] -------------------------------
SetupDebug= false --Debug Mode
abilityLevel = 0
Soraka_SWITCH = true
player = GetMyHero()

--info table
info = {}

-- ultimate info
info[1] = {} 
info[1][1] = false -- state
info[1][2] = 0 -- number
info[1][3] = "ultimate: " -- text
info[1][4] = 0 -- RED
info[1][5] = 255 -- GREEN
info[1][6] = 0 -- BLUE

-- gold info
info[2] = {} 
info[2][1] = false -- state
info[2][2] = 0 -- number
info[2][3] = "gold/10sec: " -- text
info[2][4] = 255 -- RED
info[2][5] = 255 -- GREEN
info[2][6] = 51 -- BLUE


-- gold/10 info
gold10SecAgo = 0
GoldRefreshTick = 0

-- spawn
allySpawn = nil
enemySpawn = nil

------------------------------- MATH SPELLS -------------------------------

-- HEAL
function calcHeal(ignited)
	local rank = player:GetSpellData(1).level
	if rank == 0 then return nil end
	if ignited == false then
		if     rank == 1 then return math.floor(70  + player.ap * 0.45 + 0.5) 
		elseif rank == 2 then return math.floor(140 + player.ap * 0.45 + 0.5) 
		elseif rank == 3 then return math.floor(210 + player.ap * 0.45 + 0.5) 
		elseif rank == 4 then return math.floor(280 + player.ap * 0.45 + 0.5) 
		elseif rank == 5 then return math.floor(350 + player.ap * 0.45 + 0.5) end
	else
		if     rank == 1 then return math.floor((70   + player.ap * 0.45)/2 + 0.5) 
		elseif rank == 2 then return math.floor((140  + player.ap * 0.45)/2 + 0.5) 
		elseif rank == 3 then return math.floor((210  + player.ap * 0.45)/2 + 0.5) 
		elseif rank == 4 then return math.floor((280  + player.ap * 0.45)/2 + 0.5) 
		elseif rank == 5 then return math.floor((350  + player.ap * 0.45)/2 + 0.5) end
	end
end

function calcHealResult(hero)
	local healValue = calcHeal(isIgnited(hero))
	if healValue == nil then return nil end
	-- return healed value
	if (hero.maxHealth - hero.health) < healValue then return hero.maxHealth - hero.health else return healValue end
end

-- MANA
function calcMana()
	local rank = player:GetSpellData(2).level
	if rank == 0 then return nil
	elseif rank == 1 then return 40
	elseif rank == 2 then return 80
	elseif rank == 3 then return 120
	elseif rank == 4 then return 160
	elseif rank == 5 then return 200 end
end

function calcManaResult(hero)
	local manaValue = calcMana()
	if manaValue == nil then return nil end
	-- return mana'ed value
	if (hero.maxMana - hero.mana) < manaValue then return hero.maxMana - hero.mana else return manaValue end
end

-- ULT
function calcUlt(ignited)
	local rank = player:GetSpellData(3).level
	if rank == 0 then return nil end
	if ignited == false then
		if 	   rank == 1 then return math.floor(200 + player.ap * 0.7 + 0.5) 
		elseif rank == 2 then return math.floor(320 + player.ap * 0.7 + 0.5)
		elseif rank == 3 then return math.floor(440 + player.ap * 0.7 + 0.5) end
	else
		if 	   rank == 1 then return math.floor((200 + player.ap * 0.7)/2 + 0.5) 
		elseif rank == 2 then return math.floor((320 + player.ap * 0.7)/2 + 0.5)
		elseif rank == 3 then return math.floor((440 + player.ap * 0.7)/2 + 0.5) end
	end
end

function calcUltResult()
	if calcUlt(false) == nil then return nil end
	--calc ult for players
	local ultResult = 0
	local players = GetPlayers(player.team , false, true)
	for i=1, #players, 1 do
		-- dont count targets at Spawn
		if isInSpawn(players[i]) == false and isRecall(players[i]) == false then
			if (players[i].maxHealth - players[i].health) < calcUlt(isIgnited(players[i])) then 
				ultResult = ultResult +  players[i].maxHealth - players[i].health 
			else 
				ultResult = ultResult + calcUlt(isIgnited(players[i]))
			end
		end
	end
	--return total result
	return math.floor(ultResult + 0.5)
end

------------------------------- ABSTRACTION-METHODS -------------------------------
-- return players table
function GetPlayers(team, includeDead, includeSelf)
	local players = {}
	for i=1, heroManager.iCount, 1 do
		local member = heroManager:getHero(i)
		if member ~= nil and member.type == "obj_AI_Hero" and member.team == team then
			if member.charName ~= player.charName or includeSelf then 
				if includeDead then
					table.insert(players,member)
				elseif member.dead == false then
					table.insert(players,member)
				end
			end
		end
	end
	return players
end

-- return towers table
function GetTowers(team)
	local towers = {}
	for i=1, objManager.maxObjects, 1 do
		local tower = objManager:getObject(i)
		if tower ~= nil and tower.type == "obj_AI_Turret" and tower.visible and tower.team == team then
			table.insert(towers,tower)
		end
	end
	if #towers > 0 then
		return towers
	else
		return false
	end
end

-- here get close tower
function GetCloseTower(hero, team)
	local towers = GetTowers(team)
	if #towers > 0 then
		local candidate = towers[1]
		for i=2, #towers, 1 do
			if (towers[i].health/towers[i].maxHealth > 0.1) and  hero:GetDistance(candidate) > hero:GetDistance(towers[i]) then candidate = towers[i] end
		end
		return candidate
	else
		return false
	end
end

-- here get close player
function GetClosePlayer(hero, team)
	local players = GetPlayers(team,false)
	if #players > 0 then
		local candidate = players[1]
		for i=2, #players, 1 do
			if hero:GetDistance(candidate) > hero:GetDistance(players[i]) then candidate = players[i] end
		end
		return candidate
	else
		return false
	end
end

-- return count of champs near hero
function cntOfChampsNear(hero,team,distance)
	local cnt = 0 -- default count of champs near HERO
	local players = GetPlayers(team,false)
	for i=1, #players, 1 do
		if hero:GetDistance(players[i]) < distance then cnt = cnt + 1 end
	end
	return cnt
end

-- return %hp of champs near hero
function hpOfChampsNear(hero,team,distance)
	local percent = 0 -- default %hp of champs near HERO
	local players = GetPlayers(team,false)
	for i=1, #players, 1 do
		if hero:GetDistance(players[i]) < distance then percent = percent + players[i].health/players[i].maxHealth end
	end
	return percent
end

-- is recall, return true/false
function isRecall(hero)
	if hero ~= nil then 
		for i = 1, hero.buffCount, 1 do
			local buff = hero:getBuff(i)
			if buff == "Recall" or buff == "SummonerTeleport" or buff == "RecallImproved" then return true end
		end
    end
	return false
end

-- CHECK IS HERO IGNITED
 function isIgnited(hero)
	if detectBuffs(hero,{"SummonerDot","grievouswound"}) then return 1 else return 0 end
 end

 -- DETECT BUFFS IN TABLE buffs ON HERO
 function detectBuffs(hero,buffs)
	for j = 1, hero.buffCount, 1 do
		buff = hero:getBuff(j)
		for i = 1, #buffs, 1 do
			if buff == buffs[i] then return true end
		end
	end
	return false
 end
 
-- CHECK IS HERO IN SPAWN
function isInSpawn(hero)
	if  math.sqrt((allySpawn.x - hero.x) ^ 2 + (allySpawn.z - hero.z) ^ 2) < 1000 then return true end
	return false
end

------------------------------- CORE -------------------------------
function AutoUlt()
	if SetupDebug == true then PrintChat("debug >> AutoUlt()") end
	--check is ult lvled and ready
	if player:GetSpellData(3).level > 0 and  player:CanUseSpell(_R) == READY then
		if  calcUltResult() > (calcUlt(false) * SetupUltEffect) then
			CastSpell(_R)
		end
	end
end

--if SetupAutoSilence or SetupAntiKarthus then script.createObjectCallback = "AutoSilence" end
function AutoSilence(object) --Working on it
--[[	if object ~= nil and object.name == "Data\Particles\FallenOne_nova.troy" and object.team == TEAM_ENEMY then 
		if player:GetSpellLevel(3) > 0 and  player:GetSpellState(_R) == STATE_READY and SetupAntiKarthus  then
			players = GetPlayers(player.team, false, true)
			for i=1,#players,1 do
				if karthus:CalculateMagicDamage(players[i],(400 * karthus.level/11 + karthus.ap * 0.6) *  1.2)  > players[i].health then
					player:UseSpell(_R)
					PrintChat("SORAKA SLACK >> AntiKarthus Ultimate!")
				end
			end
		end
	end]]
end

function AutoHeal()
	if SetupDebug == true then PrintChat("debug >> AutoHeal()") end
	--check is heal lvled and ready
	if player:GetSpellData(1).level > 0 and player:CanUseSpell(_W) == READY then
		local healTarget = nil
		local players = GetPlayers(player.team, false, true)
		-- check is need heal and select target
		for i=1, #players, 1 do
			if player:GetDistance(players[i]) < SetupDistance and isRecall(players[i]) == false and isInSpawn(players[i]) == false then
				-- calculate is need heal to target
				if healTarget ~= nil and ((players[i].maxHealth - players[i].health) / (isIgnited(players[i]) + 1)) > ((healTarget.maxHealth - healTarget.health) / (isIgnited(healTarget) + 1)) then healTarget = players[i]
				elseif  healTarget == nil and (players[i].maxHealth - players[i].health) > (calcHeal(isIgnited(players[i])) * SetupHealGiveRate) then healTarget = players[i] end
			end
		end
		--heal targets
		if  healTarget ~= nil then CastSpell(_W, healTarget) end
	end
end

function AutoMana() --Champion check seems bugged ?
	if SetupDebug == true then PrintChat("debug >> AutoMana()") end
	--check is E lvled and ready
	if player:GetSpellData(2).level > 0 and player:CanUseSpell(_E) == READY then
		local manaTarget = nil
		local players = GetPlayers(player.team, false, false)
		-- check is need mana and select target
		for i=1, #players, 1 do
			if isRecall(players[i]) == false and isInSpawn(players[i]) == false and players[i].charName ~= "Mordekaiser" and player:GetDistance(players[i]) < SetupDistance and players[i].maxMana > 201 then
				-- calculate is need mana to target
				if manaTarget ~= nil and (players[i].maxMana - players[i].mana) > (manaTarget.maxMana - manaTarget.mana) then manaTarget = players[i]
				elseif manaTarget == nil and (players[i].maxMana - players[i].mana) > (calcMana() * SetupManaGiveRate) then manaTarget = players[i] end
			end
		end
		--mana targets
		if  manaTarget ~= nil then CastSpell(_E, manaTarget) end
	end
end

--get info to draw
--called every TimerCallback
function GetInfo()
	--ultimate info
	if player:GetSpellData(3).level > 0 --[[and player:GetSpellState(_R) == STATE_READY]] then
		info[1][2] = calcUltResult()
		info[1][1] = true
	else info[1][1] = false end
	--gold / 10 info
	if GetTickCount() - GoldRefreshTick > 9999 then
		if (player.gold - gold10SecAgo) > 0 and (player.gold - gold10SecAgo) < 84 then
			info[2][1] = true
			
			info[2][2] = string.format("%.02f", (player.gold - gold10SecAgo))
		end
		gold10SecAgo = player.gold
		GoldRefreshTick = GetTickCount()
	end
	
end

--draw info
--called every frame
function OnDraw()
	if SetupDrawInfo then
		local curString = 0
		for i=1, #info, 1 do
			if info[i][1] then
					--    text 
				DrawText(info[i][3]..tostring(info[i][2]),
					-- size   			x      					   				y                                   
						20 , (WINDOW_W - WINDOW_X) * SetupDrawX,  (WINDOW_H - WINDOW_Y) * SetupDrawY + curString, 0xFF00FF00)
				curString = curString + 20
			end
		end
	end
end

--turn off - on
function OnWndMsg(msg, keycode)
	if keycode == SetupTogleKey and msg == KEY_DOWN then
		if SetupDebug == true then PrintChat("debug >> Toggle(msg, keycode == SetupTogleKey )") end
        if Soraka_SWITCH == true then
            Soraka_SWITCH = false
			PrintChat("<font color='#FF0000'> SORAKA SLACK >> Run Soraka, RUN </font>")
        else
            Soraka_SWITCH = true
			PrintChat("<font color='#00FF00'> SORAKA SLACK >> Heal Soraka, HEAL </font>")
        end
    end
end

-- TIMER and BRAIN
function OnTick() --Need 200ms interval
	if SetupDebug then PrintChat("debug >> Timer(tick)") end
	if player.dead == false and isRecall(player) == false then
		if Soraka_SWITCH then
			if SetupAutoUlt then AutoUlt() end
			if SetupAutoHeal then AutoHeal() end
			if SetupAutoMana then AutoMana() end
		end
	end
    if SetupAutoLvLSpell and player.level > abilityLevel then
		abilityLevel=abilityLevel+1
		if abilitySequence[abilityLevel] == 1 then LevelSpell(_Q)
		elseif abilitySequence[abilityLevel] == 2 then LevelSpell(_W)
		elseif abilitySequence[abilityLevel] == 3 then LevelSpell(_E)
		elseif abilitySequence[abilityLevel] == 4 then LevelSpell(_R) end
	end
	if SetupDrawInfo then GetInfo() end
end
-- LOAD --
function OnLoad()
	player = GetMyHero()
	PrintChat("SORAKA SLACK >> SORAKA SLACKER v8.1 loaded!")	
	-- numerate spawn
	for i=1, objManager.maxObjects, 1 do
		local candidate = objManager:getObject(i)
		if candidate ~= nil and candidate.type == "obj_SpawnPoint" then 
			if candidate.x < 3000 then 
				if player.team == TEAM_BLUE then allySpawn = candidate else enemySpawn = candidate end
			else 
				if player.team == TEAM_BLUE then enemySpawn = candidate else allySpawn = candidate end
			end
		end
	end
end
end