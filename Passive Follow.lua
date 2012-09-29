--[[
	Passive Follow by ivan[russia]

	!!!ALERT!!!
	AUTOFOLLOW NOT TOO INTELECTUAL, PLAYERS CAN REPORT AUTOFOLLOW FOR FEED OR CHEATING OR BOTING, THEN YOU CAN GET BAN, POSIBLE BAN FOR HACKING
    IN DEVELOPMENT
    cmd list:
   .follow start DummyNick  -- starts follow champion with nickname: DummyNick
   .follow stop             -- stops follow champion
   
   Updated for BoL by ikita
]]
require "AllClass"

-- SETTINGS
do
-- you can change true to false and false to true
-- false is turn off
-- true is turn on

SetupTogleKey = 117	 --Key to Togle script. [ F6 - 117 ] default
					 --key codes
					 --http://www.indigorose.com/webhelp/ams/Program_Reference/Misc/Virtual_Key_Codes.htm

SetupFollowDistance = 600
--Distance between FollowTarget and Champion in which champion starts correcting itself
--Should be more then 400

SetupFollowAlly = true
-- you start follow near ally when your followtarget have been diead

SetupRunAway = true
-- if no ally was near when followtarget died, you run to close tower

SetupRunAwayRecall = true
-- if you succesfully recall after followtarget died or recalled, you start recall

SetupFollowRecall = true
-- should you recall as soon as follow target racalled

SetupAutoHold = true -- Need work
-- stop autohit creeps when following target
end

-- GLOBALS [Do Not Change]
do
SetupDebug = true
switcher = true
following = nil
temp_following = nil
stopPosition = false

--state of app enum
FOLLOW = 1
TEMP_FOLLOW = -33
WAITING_FOLLOW_RESP = 150
GOING_TO_TOWER = 666

--by default
state = FOLLOW

-- spawn
allySpawn = nil
enemySpawn = nil

version = 1
player = GetMyHero()
end

-- ABSTRACTION-METHODS

--return players table
function GetPlayers(team, includeDead, includeSelf)
	local players = {}
	for i=1, heroManager.iCount, 1 do
		local member = heroManager:getHero(i)
		if member ~= nil and member.valid and member.type == "obj_AI_Hero" and member.visible and member.team == team then
			if member.name ~= player.name or includeSelf then 
				if includeDead then
					table.insert(players,member)
				elseif member.dead == false then
					table.insert(players,member)
				end
			end
		end
	end
	if #players > 0 then
		return players
	else
		return false
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
			if (towers[i].health/towers[i].maxHealth > 0.1) and  hero:GetDistance(candidate) > hero:GetDistance(towers[i]) then candidate = towers[i] end
		end
		return candidate
	else
		return false
	end
end

--here get close player
function GetClosePlayer(hero, team)
	local players = GetPlayers(team,false,false)
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
	local players = GetPlayers(team,false,true)
	for i=1, #players, 1 do
		if players[i] ~= hero and hero:GetDistance(players[i]) < distance then cnt = cnt + 1 end
	end
	return cnt
end

-- return %hp of champs near hero
function hpOfChampsNear(hero,team,distance)
	local percent = 0 -- default %hp of champs near HERO
	local players = GetPlayers(team,false, true)
	for i=1, #players, 1 do
		if players[i] ~= hero and hero:GetDistance(players[i]) < distance then percent = percent + players[i].health/players[i].maxHealth end
	end
	return percent
end

-- is recall, return true/false
function isRecall(hero)
	if hero ~= nil then 
			if TargetHaveParticle("TeleportHomeImproved.troy",hero,100) or TargetHaveParticle("TeleportHome.troy",hero,100) then return true end
    end
	return false
end

-- turn (off - on) by SetupTogleKey
function OnWndMsg(msg, keycode)
	if keycode == SetupTogleKey and msg == KEY_DOWN then
        if switcher == true then
            switcher = false
			PrintChat("<font color='#FF0000'>Passive Follow >> TURNED OFF </font>")
        else
            switcher = true
			PrintChat("<font color='#00FF00'>Passive Follow >> TURNED ON </font>")
        end
    end
end

-- CHAT CALLBACK
function OnSendChat(text)
	if string.sub(text,1,7) == ".follow" then
	BlockChat()
		if string.sub(text,9,13) == "start" then
			name = string.sub(text,15)
			players = GetPlayers(player.team, true, false)
			if players ~= false then
				for i=1, #players, 1 do
					if (string.lower(players[i].name) == string.lower(name))  then 
						following = players[i]
						PrintChat("Passive Follow >> following summoner: "..players[i].name)
						if following.dead then state = WAITING_FOLLOW_RESP else state = FOLLOW end
					end
				end
				if following == nil then PrintChat("Passive Follow >> "..name.." did not found") end
			end
		end
		if string.sub(text,9,12) == "stop" then
			following = nil
			state = FOLLOW
			PrintChat("Passive Follow >> terminated")
		end
	end
end

-- TIMER CALLBACK
mytime = GetTickCount() 

function OnTick()
	if GetTickCount() - mytime > 800 and switcher then 
		Brain()
		mytime = GetTickCount() 
	end
	if following ~= nil then
		Status(following, 1, value)
	end
end

-- STATUS CALLBACK
function Status(member, desc, value)
	if member == following and desc == 1 then
		if member.dead and state == FOLLOW then
			PrintChat("Passive Follow >> "..member.name.." dead")
			-- if SetupFollowAlly == true and ALLYNEAR then temporary changing follow target
			if SetupFollowAlly and player:GetDistance(GetClosePlayer(player,player.team)) < SetupFollowDistance then 
				temp_following = GetClosePlayer(player,player.team)
				PrintChat("Passive Follow >> "..(GetClosePlayer(player,player.team)).name.." temporary following")
				state = TEMP_FOLLOW
			elseif SetupRunAway then 
				state = GOING_TO_TOWER
			else
				state = WAITING_FOLLOW_RESP
			end
		end
		if member.dead == false then
			if state == WAITING_FOLLOW_RESP then
				PrintChat("Passive Follow >> "..member.name.." alive")
				state = FOLLOW
			end
			if state == TEMP_FOLLOW then
				temp_following = nil
				PrintChat("Passive Follow >> "..member.name.." alive")
				state = FOLLOW
			end
			if state == GOING_TO_TOWER then
				PrintChat("Passive Follow >> "..member.name.." alive")
				state = FOLLOW
			end
		end
	end
end

-- SEMICORE
-- run(follow) to target
function Run(target)
	if target.type == "obj_AI_Hero" then
		if target:GetDistance(allySpawn) > SetupFollowDistance then
			if (player:GetDistance(target) > SetupFollowDistance or player:GetDistance(target) < 275 --[[this is to stop get aoe, which are often 275 range]] or player:GetDistance(allySpawn) + 275 > target:GetDistance(allySpawn)) then
				followX = ((allySpawn.x - target.x)/(target:GetDistance(allySpawn)) * ((SetupFollowDistance - 300) / 2 + 300) + target.x + math.random(-((SetupFollowDistance-300)/3),((SetupFollowDistance-300)/3)))
				followZ = ((allySpawn.z - target.z)/(target:GetDistance(allySpawn)) * ((SetupFollowDistance - 300) / 2 + 300) + target.z + math.random(-((SetupFollowDistance-300)/3),((SetupFollowDistance-300)/3)))
				player:MoveTo(followX, followZ)
			else
				player:HoldPosition()
			end
		elseif SetupFollowRecall and player:GetDistance(allySpawn) > (SetupFollowDistance * 3) then
			state = GOING_TO_TOWER
		end
	end
	if target.type == "obj_AI_Turret" then 
		if player:GetDistance(target) > 300 then 
			player:MoveTo(target.x + math.random(-150,150), target.z + math.random(-150,150))
		elseif SetupRunAwayRecall then
			CastSpell(RECALL)
			if following.dead == true then
				state = WAITING_FOLLOW_RESP
			else
				state = FOLLOW
			end
		end
	end
end

-- CORE
function Brain()
	if following ~= nil and player.dead == false and isRecall(player) == false then 
		if state == FOLLOW then 
			Run(following) 
		end
		if state == TEMP_FOLLOW and temp_following ~= nil then Run(temp_following) end
		if state == GOING_TO_TOWER then Run(GetCloseTower(player,player.team)) end
		
	end
end

-- AT LOADING OF SCRIPT

	-- here checking timer
function OnLoad()
	PrintChat("Passive Follow >> v"..tostring(version).." LOADED")

	-- numerate spawn
	for i=1, objManager.maxObjects, 1 do
		local candidate = objManager:getObject(i)
		if candidate ~= nil and candidate.valid and candidate.type == "obj_SpawnPoint" then 
			if candidate.x < 3000 then 
				if player.team == TEAM_BLUE then allySpawn = candidate else enemySpawn = candidate end
			else 
				if player.team == TEAM_BLUE then enemySpawn = candidate else allySpawn = candidate end
			end
		end
	end
	-- fix user settings
	if SetupFollowDistance < 400 then SetupFollowDistance = 400 end
end
