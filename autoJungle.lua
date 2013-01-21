PrintChat(" >> Auto Jungle loaded!")

--[[
	Auto Jungle by ikita for BoL Studio 1.0
	numerate spawns, towers functions by botrik/Ivan
]]
--
--require "BugsplatAvoider"
--AvoidBugsplats(true) do return end

-- Code



function statusUpdate()
	--Recall takes Priority
	if GetInventorySlotItem(3106) == nil and player.gold > 750 and firstRecalled == false then  --First recall at 750g for madrd and boots
		status = "recalling"
	end
	if player.gold > 1600 then
		status = "recalling"
	end
	if player.health/player.maxHealth < 0.2 then  --Always recall when hp lower than 20%
		status = "recalling"
	end
	if wolvesCleared and wraithsCleared and redCleared and blueCleared and golemCleared and status == "jungling" then  --Always recall when no camps available
		status = "recalling"
	end
	--Jungle when full hp/mana at base
	if status == "recalling" then
		if GetDistance(allySpawn, player) < 100 then
			if player.health == player.maxHealth then 
				status = "jungling"
			end
		end
	end
	
end

--Recalling AI
function recall() --status = recalling
--Only recall when no enemies around
	recallLoc = player
	for i=1, heroManager.iCount, 1 do
		local target = heroManager:getHero(i)
		if target ~= nil and target.dead == false and target.team ~= player.team and GetDistance(target, player) < 950 then
			recallLoc = GetCloseTower(player,player.team)
			safe = false
		end
	end
	--Can add more recallLoc for tower divings
	--Safe when no enemies around
	if recallLoc ~= player then
		if GetDistance(recallLoc, player) < 500 then
			safe = true
		end
	end
	if recallLoc == player then
		safe = true
	end
	if safe == false then
		player:MoveTo(recallLoc.x, recallLoc.z)
	else
		if recallCasting == false then
			if inGameTime - recallCastTime > 2 then
				CastSpell(RECALL)
				recallCasting = true
				recallCastTime = inGameTime
			end
		end
	end
	--Check if Recall interupted:
	if recallCasting == true and inGameTime - recallCastTime > 2 then
		recallInterupted = true
		for i=1, objManager.maxObjects, 1 do
			local object = objManager:getObject(i)
			if object ~= nil and object.valid and object.name == "TeleportHome.troy" and GetDistance(object, player) < 100 and object.visible then
				recallInterupted = false
			end
		end
		if recallInterupted then
			recallCasting = false
		end
	end
	if GetDistance(allySpawn, player) < 500 then
		recallCasting = false
		statusUpdate()
	end
end

function shop()
	if GetTickCount() > lastBuy + buyDelay then
		if shopList[nextbuyIndex] ~= nil and GetInventorySlotItem(shopList[nextbuyIndex]) ~= nil then
		--Last Buy successful
			nextbuyIndex = nextbuyIndex + 1
		else
		--Last Buy unsuccessful (buy again)
			BuyItem(shopList[nextbuyIndex])
			lastBuy = GetTickCount()
		end
	end
	if nextbuyIndex >= 2 then
		firstRecalled = true
	end
end

--return towers table
function GetTowers(team)
	local towers = {}
	for i=1, objManager.maxObjects, 1 do
		local tower = objManager:getObject(i)
		if tower ~= nil and tower.valid and tower.type == "obj_AI_Turret" and tower.visible and tower.team == team then
			table.insert(towers,tower)
		end
	end
	if #towers > 0 then
		return towers
	else
		return false
	end
end

--here get close tower
function GetCloseTower(hero, team)
	local towers = GetTowers(team)
	if #towers > 0 then
		local candidate = towers[1]
		for i=2, #towers, 1 do
			if (towers[i].health/towers[i].maxHealth > 0.1) and GetDistance(candidate, hero) > GetDistance(towers[i], hero) then candidate = towers[i] end
		end
		return candidate
	else
		return false
	end
end

--Jungling AI Purple side
function wolvesP()
	--Go to wolves
	if ((player.x - 10754)^2 + (player.z - 8318)^2)^(1/2) > 100 then
		player:MoveTo(10754,8318)
	else
	--At wolves camp
		if true then --Not killed yet
			found813 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "GiantWolf8.1.3" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					CastSpell(_W)
					player:Attack(object)
					wolvesStarted = true
					found813 = true
				end
			end
		end
		if found813 == false then
			found811 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "wolf8.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found811 = true
				end
			end
		end
		if found811 == false then
			found812 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "wolf8.1.2" and GetDistance(object, player) < 600 and not object.dead  and object.visible then
					player:Attack(object)
					found812 = true
				end
			end
		end
		if found812 == false then
			wolvesCleared = true
			wolvesStarted = false
			wolvesClearTime = GetInGameTimer()
		end
	end
end

function blueP()
	--Go to blue
	if ((player.x - 10807)^2 + (player.z - 6687)^2)^(1/2) > 200 then
		player:MoveTo(10807,6687)
	else
	--At blue camp
		if true then --Not killed yet
			found711 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "AncientGolem7.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					blueStarted = true
					CastSpell(_W)
					player:Attack(object)
					CastSpell(_Q, object)
					found711 = true
				end
			end
		end
		if found711 == false then
			found712 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "YoungLizard7.1.2" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found712 = true
				end
			end
		end
		if found712 == false then
			found713 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "YoungLizard7.1.3" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found713 = true
				end
			end
		end
		if found713 == false then
			blueCleared = true
			blueStarted = false
			blueClearTime = GetInGameTimer()
		end
	end
end

function wraithsP()
	--Go to wraiths
	if ((player.x - 7475)^2 + (player.z - 9554)^2)^(1/2) > 200 then
		player:MoveTo(7475,9554)
	else
	--At wraiths camp
		if true then --Not killed yet
			found913 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "Wraith9.1.3" and GetDistance(object, player) < 900 and not object.dead and object.visible then
					player:Attack(object)
					CastSpell(_W)
					wraithsStarted = true
					found913 = true
				end
			end
		end
		if found913 == false then
			found911 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "LesserWraith9.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found911 = true
				end
			end
		end
		if found911 == false then
			found912 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "LesserWraith9.1.2" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found912 = true
				end
			end
		end
		if found912 == false then
			found914 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "LesserWraith9.1.4" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found914 = true
				end
			end
		end
		if found914 == false then
			wraithsCleared = true
			wraithsStarted = false
			wraithsClearTime = GetInGameTimer()
		end
	end
end

function redP()
	--Go to red
	if ((player.x - 6594)^2 + (player.z - 11069)^2)^(1/2) > 500 then
		player:MoveTo(6594,11069)
	else
	--At red camp
		if true then --Not killed yet
			found1011 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "LizardElder10.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					CastSpell(_W)
					CastSpell(_Q, object)
					redStarted = true
					found1011 = true
				end
			end
		end
		if found1011 == false then
			found1012 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "YoungLizard10.1.2" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found1012 = true
				end
			end
		end
		if found1012 == false then
			found1013 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "YoungLizard10.1.3" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found1013 = true
				end
			end
		end
		if found1013 == false then
			redCleared = true
			redStarted = false
			redClearTime = GetInGameTimer()
		end
	end
end

function golemP()
	--Go to golem
	if ((player.x - 5910)^2 + (player.z - 12122)^2)^(1/2) > 100 then
		player:MoveTo(5910,12122)
	else
	--At golem camp
		if true then --Not killed yet
			found1112 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "Golem11.1.2" and GetDistance(object, player) < 800 and not object.dead and object.visible then
					player:Attack(object)
					CastSpell(_W)
					CastSpell(_Q, object)
					golemStarted = true
					found1112 = true
				end
			end
		end
		if found1112 == false then
			found1111 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "SmallGolem11.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found1111 = true
				end
			end
		end
		if found1111 == false then
			golemCleared = true
			golemStarted = false
			golemClearTime = GetInGameTimer()
		end
	end
end

--Jungling AI Blue side
function wolvesB()
	--Go to wolves
	if ((player.x - 3350)^2 + (player.z - 6235)^2)^(1/2) > 100 then
		player:MoveTo(3350,6235)
	else
	--At wolves camp
		if true then --Not killed yet
			found213 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "GiantWolf2.1.3" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					CastSpell(_W)
					player:Attack(object)
					wolvesStarted = true
					found213 = true
				end
			end
		end
		if found213 == false then
			found211 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "wolf2.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found211 = true
				end
			end
		end
		if found211 == false then
			found212 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "wolf2.1.2" and GetDistance(object, player) < 600 and not object.dead  and object.visible then
					player:Attack(object)
					found212 = true
				end
			end
		end
		if found212 == false then
			wolvesCleared = true
			wolvesStarted = false
			wolvesClearTime = GetInGameTimer()
		end
	end
end

function blueB()
	--Go to blue
	if ((player.x - 3600)^2 + (player.z - 7626)^2)^(1/2) > 500 then
		player:MoveTo(3600,7626)
	else
	--At blue camp
		if true then --Not killed yet
			found111 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "AncientGolem1.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					blueStarted = true
					CastSpell(_W)
					player:Attack(object)
					CastSpell(_Q, object)
					found111 = true
				end
			end
		end
		if found111 == false then
			found112 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "YoungLizard1.1.2" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found112 = true
				end
			end
		end
		if found112 == false then
			found113 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "YoungLizard1.1.3" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found113 = true
				end
			end
		end
		if found113 == false then
			blueCleared = true
			blueStarted = false
			blueClearTime = GetInGameTimer()
		end
	end
end

function wraithsB()
	--Go to wraiths
	if ((player.x - 6426)^2 + (player.z - 5209)^2)^(1/2) > 500 then
		player:MoveTo(6426,5209)
	else
	--At wraiths camp
		if true then --Not killed yet
			found313 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "Wraith3.1.3" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					CastSpell(_W)
					wraithsStarted = true
					found313 = true
				end
			end
		end
		if found313 == false then
			found311 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "LesserWraith3.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found311 = true
				end
			end
		end
		if found311 == false then
			found312 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "LesserWraith3.1.2" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found312 = true
				end
			end
		end
		if found312 == false then
			found314 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "LesserWraith3.1.4" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found314 = true
				end
			end
		end
		if found314 == false then
			wraithsCleared = true
			wraithsStarted = false
			wraithsClearTime = GetInGameTimer()
		end
	end
end

function redB()
	--Go to red
	if ((player.x - 7500)^2 + (player.z - 3875)^2)^(1/2) > 500 then
		player:MoveTo(7500,3875)
	else
	--At red camp
		if true then --Not killed yet
			found411 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "LizardElder4.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					CastSpell(_W)
					CastSpell(_Q, object)
					redStarted = true
					found411 = true
				end
			end
		end
		if found411 == false then
			found412 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "YoungLizard4.1.2" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found412 = true
				end
			end
		end
		if found412 == false then
			found413 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "YoungLizard4.1.3" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found413 = true
				end
			end
		end
		if found413 == false then
			redCleared = true
			redStarted = false
			redClearTime = GetInGameTimer()
		end
	end
end

function golemB()
	--Go to golem
	if ((player.x - 8200)^2 + (player.z - 2500)^2)^(1/2) > 500 then
		player:MoveTo(8200,2500)
	else
	--At golem camp
		if true then --Not killed yet
			found512 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "Golem5.1.2" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					CastSpell(_W)
					CastSpell(_Q, object)
					golemStarted = true
					found512 = true
				end
			end
		end
		if found512 == false then
			found511 = false
			for i=1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.valid and object.name == "SmallGolem5.1.1" and GetDistance(object, player) < 600 and not object.dead and object.visible then
					player:Attack(object)
					found511 = true
				end
			end
		end
		if found511 == false then
			golemCleared = true
			golemStarted = false
			golemClearTime = GetInGameTimer()
		end
	end
end

function OnLoad()
firstRecalled = false
shopList = {1039, 3106, 1001, 1036, 1053, 3154, 1033, 3111, 1028, 1036, 3044, 1033, 1043, 3091, 1031, 1011, 3068, 1011, 3022, 1031, 1033, 3026, 1036, 1053, 1037, 3144, 3153}
buyDelay = 250
lastBuy = 0
nextbuyIndex = 1
recallInterupted = false
recallCasting = false
abilityLevel = 0
status = "jungling"
inGameTime = 0
pauseHK = 48 -- 0 
paused = false
found811 = true
found812 = true
found813 = true
found711 = true
found712 = true
found713 = true
found911 = true
found912 = true
found913 = true
found914 = true
found1011 = true
found1012 = true
found1013 = true
found1111 = true
found1112 = true
found211 = true
found212 = true
found213 = true
wolvesStarted = false
wolvesCleared = false
found111 = true
found112 = true
found113 = true
blueStarted = false
blueCleared = false
found313 = true
found311 = true
found312 = true
found314 = true
wraithsStarted = false
wraithsCleared = false
found411 = true
found412 = true
found413 = true
redStarted = false
redCleared = false
found511 = true
found512 = true
golemStarted = false
golemCleared = false
blueClearTime = -5000
redClearTime = -5000
wolvesClearTime = -5000
wraithsClearTime = -5000
golemClearTime = -5000
recallArrivalTime = -5000
mode = 0
currentMode = nil
safe = true
abilitySequence = {2,1,2,3,2,4,2,1,2,1,4,1,1,3,3,4,3,3}
recallCastTime = -5000
	-- numerate spawn
	for i=1, objManager.maxObjects, 1 do
		local spawnCandidate = objManager:getObject(i)
		if spawnCandidate ~= nil and spawnCandidate.type == "obj_SpawnPoint" then
			if spawnCandidate.team == TEAM_ENEMY then enemySpawn = spawnCandidate
			elseif spawnCandidate.team == player.team then allySpawn = spawnCandidate end --removed <3000x check
					
		end
	end
end

function OnTick()
	if paused == false then
		-- BLUE LOOP
		if allySpawn.x ~= nil and allySpawn.x < 3000 then --Blue
			
			--Spam shop
			if inGameTime > 100 then
			shop()
			end
			
		--Always check the time
			inGameTime = GetInGameTimer()
			
		
		--First spawn at fountain
			if inGameTime < 100 and inGameTime > 1 then
				BuyItem(1029)--cloth armor
				BuyItem(2003)--pots
				player:MoveTo(3350,6235) --wait at Wolves BLUE !!!!!!
			end
		
		--Auto level up spells
			if player.level > abilityLevel then
				abilityLevel=abilityLevel+1
				if abilitySequence[abilityLevel] == 1 then LevelSpell(_Q)
				elseif abilitySequence[abilityLevel] == 2 then LevelSpell(_W)
				elseif abilitySequence[abilityLevel] == 3 then LevelSpell(_E)
				elseif abilitySequence[abilityLevel] == 4 then LevelSpell(_R) end
			end
		
		--Reset camps when they spawn
			if GetInGameTimer() - wolvesClearTime > 60 then
				wolvesCleared = false
				found211 = true
				found212 = true
				found213 = true
			end
			if GetInGameTimer() - wraithsClearTime > 50 then
				wraithsCleared = false
				found313 = true
				found311 = true
				found312 = true
				found314 = true
			end
			if GetInGameTimer() - redClearTime > 300 then
				redCleared = false
				found411 = true
				found412 = true
				found413 = true
			end
			if GetInGameTimer() - blueClearTime > 300 then
				blueCleared = false
				found111 = true
				found112 = true
				found113 = true
			end
			if GetInGameTimer() - golemClearTime > 60 then
				golemCleared = false
				found511 = true
				found512 = true
			end
			
		--Jungling AI
			--Always finish current camp once started
			if wolvesStarted then
				wolvesB()
			elseif wraithsStarted then
				wraithsB()
			elseif redStarted then
				redB()
			elseif blueStarted then
				blueB()
			elseif golemStarted then
				golemB()
			elseif inGameTime > 102 then
			
				statusUpdate()
				
				if status == "jungling" then --Keep switching camps. Path: wolves->blue->wraiths->red->golems->wraiths->wolves->golems->wraiths->wolves..etc
					if golemCleared == false and redCleared == true then
						golemB()
					elseif blueCleared == false and wolvesCleared == true then
						blueB()
					elseif wraithsCleared == false and blueCleared == true then
						wraithsB()
					elseif redCleared == false and wraithsCleared == true then
						redB()
					elseif wolvesCleared == false and blueCleared == false then
						wolvesB()
					elseif wraithsCleared == false and golemCleared == true then
						wraithsB()
					elseif wolvesCleared == false and wraithsCleared == true then
						wolvesB()
					end
				end
			end
		
			if status == "recalling" then
				recall()
			end
		
		else --PURPLE LOOP
		
			--Spam shop
			if inGameTime > 100 then
			shop()
			end
			
		--Always check the time
			inGameTime = GetInGameTimer()
			
		
		--First spawn at fountain
			if inGameTime < 100 and inGameTime > 1 then
				BuyItem(1029)--cloth armor
				BuyItem(2003)--pots
				player:MoveTo(10754,8318) --wait at Wolves PURPLE !!!!!!
			end
		
		--Auto level up spells
			if player.level > abilityLevel then
				abilityLevel=abilityLevel+1
				if abilitySequence[abilityLevel] == 1 then LevelSpell(_Q)
				elseif abilitySequence[abilityLevel] == 2 then LevelSpell(_W)
				elseif abilitySequence[abilityLevel] == 3 then LevelSpell(_E)
				elseif abilitySequence[abilityLevel] == 4 then LevelSpell(_R) end
			end
		
		--Reset camps when they spawn
			if GetInGameTimer() - wolvesClearTime > 60 then
				wolvesCleared = false
				found811 = true
				found812 = true
				found813 = true
			end
			if GetInGameTimer() - wraithsClearTime > 50 then
				wraithsCleared = false
				found913 = true
				found911 = true
				found912 = true
				found914 = true
			end
			if GetInGameTimer() - redClearTime > 300 then
				redCleared = false
				found1011 = true
				found1012 = true
				found1013 = true
			end
			if GetInGameTimer() - blueClearTime > 300 then
				blueCleared = false
				found711 = true
				found712 = true
				found713 = true
			end
			if GetInGameTimer() - golemClearTime > 60 then
				golemCleared = false
				found1011 = true
				found1012 = true
			end
			
		--Jungling AI
			--Always finish current camp once started
			if wolvesStarted then
				wolvesP()
			elseif wraithsStarted then
				wraithsP()
			elseif redStarted then
				redP()
			elseif blueStarted then
				blueP()
			elseif golemStarted then
				golemP()
			elseif inGameTime > 102 then
			
				statusUpdate()
				
				if status == "jungling" then --Keep switching camps. Path: wolves->blue->wraiths->red->golems->wraiths->wolves->golems->wraiths->wolves..etc
					if golemCleared == false and redCleared == true then
						golemP()
					elseif blueCleared == false and wolvesCleared == true then
						blueP()
					elseif wraithsCleared == false and blueCleared == true then
						wraithsP()
					elseif redCleared == false and wraithsCleared == true then
						redP()
					elseif wolvesCleared == false and blueCleared == false then
						wolvesP()
					elseif wraithsCleared == false and golemCleared == true then
						wraithsP()
					elseif wolvesCleared == false and wraithsCleared == true then
						wolvesP()
					end
				end
			end
		
			if status == "recalling" then
				recall()
			end	
		
		
		end
	end	
end

function OnWndMsg(msg,key)
    if msg == KEY_DOWN then
    	if key == pauseHK then
            if paused then
                    paused = false
                    PrintChat(" >> resumed!")
            else
                    paused = true
                    PrintChat(" >> paused")
            end
        end
    end
end