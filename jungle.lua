--[[
	Displays a timer for jungle creeps
	v1.4
	Written by Zynox
	Modified by Mistal for BoL and new colors
]]

--[[		Config		]]
hotkey = nil --hotkey for printing timers to chat (not sending them!)
chatHotkey = nil --hotkey for sending drag/baron or liz/drag timers to chat

autoChat = false --sends the respawn timers automatically to chat for all creeps with an alias name

rememberSeconds = 30 -- Time before the script will notify you about respawns, set to 'nil' to disable it
pingTargets = true -- Ping signal if a creep respawns

drawText = true -- Timer in the upper right corner

-- You currently have to redefine these for your resolution
drawX = 1400 --X coordinate for timers
drawY = 100 -- Y Coordinate for timers

bigTable =
{
 {--BLUE TEAM GOLEM
  name = "AncientGolem1.1.1",
  timerFormat = "<font color='#00FFCC'> >>Golem:</font> %i:%02i",
  drawFormat = ">> Blue Golem: %i:%02i",
  drawColor = 0xFF00FF00,
  respawn = 300,
  alias = nil,
 },
 {--BLUE TEAM LIZARD
  name = "LizardElder4.1.1",
  timerFormat = "<font color='#00FFCC'> >>Lizard:</font> %i:%02i",
  drawFormat = ">> Blue Lizard: %i:%02i",
  drawColor = 0xFF00FF00,
  respawn = 300,
  alias = nil,
 },
 {--RED TEAM GOLEM
  name = "AncientGolem7.1.1",
  timerFormat = "<font color='#FF00CC'> >>Golem:</font> %i:%02i",
  drawFormat = ">> Red Golem: %i:%02i",
  drawColor = 0xFFFF0000,
  respawn = 300,
  alias = nil,
 },
 {--RED TEAM LIZARD
  name = "LizardElder10.1.1",
  timerFormat = "<font color='#FF00CC'> >>Lizard:</font> %i:%02i",
  drawFormat = ">> Red Lizard: %i:%02i",
  drawColor = 0xFFFF0000,
  respawn = 300,
  alias = nil,
 },
 {--NEUTRAL TEAM DRAGON
  name = "Dragon6.1.1",
  timerFormat = "<font color='#98F5FF'> >>Dragon:</font> %i:%02i",
  drawFormat = ">> Dragon: %i:%02i",
  drawColor = 0xFFFFFF00,
  respawn = 360,
  alias = "drag",
 },
 {--NEUTRAL TEAM BARON
  name = "Worm12.1.1",
  timerFormat = "<font color='#98F5FF'> >>Nashor:</font> %i:%02i",
  drawFormat = ">> Nashor: %i:%02i",
  drawColor = 0xFFFFFF00,
  respawn = 420,
  alias = "nash",
 },
 {--TWISTED TREELINE LIZARD
  name = "TwistedLizardElder8$1",
  timerFormat = "<font color='#98F5FF'> >>Lizard:</font> %i:%02i",
  drawFormat = ">> Lizard: %i:%02i",
  drawColor = 0xFFFFFF00,
  respawn = 240,
  alias = "liz",
 },
 {--TWISTED TREELINE DRAGON
  name = "blueDragon7$1",
  timerFormat = "<font color='#98F5FF'> >>Dragon:</font> %i:%02i",
  drawFormat = ">> Dragon: %i:%02i",
  drawColor = 0xFFFFFF00,
  respawn = 300,
  alias = "drag",
 },
}



function OnCreateObj(object)
	local element = nil
	for i,v in ipairs(bigTable) do
		if object.name == v.name then
			element = i
			break
		end
	end
	if element ~= nil then
		-- no signal yet
	    --if pingTargets == true and bigTable[ element ].tick ~= nil then
	       --PingSignal(PING_NORMAL,object.x,object.z)
	    --end
	    bigTable[element].tick = nil
	end
end

function OnDeleteObj(object)
 	local element = nil
	for i,v in ipairs(bigTable) do
		if object.name == v.name then
			element = i
			break
		end
	end
	if element ~= nil then
	    local currentTick = GetTickCount()
	    bigTable[ element ].tick = currentTick
	    bigTable[ element ].reminder = true
	   
	    --Add messages for all creeps which have an alias
	    if bigTable[ element ].alias ~= nil then
		    --bigTable[ element ].message = FormatSendText( currentTick, bigTable[ element ].respawn, bigTable[ element ].alias )
			-- no send chat yet
			--if autoChat == true then
			--	SendChat( bigTable[ element ].message )
			--end
		end
	end
end

function OnDraw()
	
	local tick = GetTickCount()
    local counter = 0
    local drawDiff = 17
    --draw all timers
	for i,v in ipairs(bigTable) do
		if v.tick ~= nil then
			local text = FormatPrintText( tick, v.respawn, v.tick, v.drawFormat )
	   		DrawText(text,14,drawX,drawY+drawDiff*counter, v.drawColor)
	   		counter = counter + 1
		end
	end
end

function FormatPrintText( tick, respawn, deathTick, format )
	local diff = respawn - (tick - deathTick) / 1000 
	diff = math.max(0,diff)
	local seconds = diff % 60;
	local minutes = diff / 60;
	return string.format(format,minutes,seconds)
end

function FormatSendText( tick, respawn, alias )
	local diff = (tick - STARTED_TICK) / 1000  + respawn
	diff = math.max(0,diff)
	local seconds = diff % 60;
	local minutes = diff / 60;
	return string.format("%s %i:%02i",alias, minutes, seconds)
end

