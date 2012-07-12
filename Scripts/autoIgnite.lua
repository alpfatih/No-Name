--[[
	Auto ignite v0.2
	Script by SurfaceS
]]

--[[         Code          ]]
-- for those who not use loader.lua
if LIB_PATH == nil then LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2).."Libs\\" end

-- Load ignite lib if needed
if ignite == nil then dofile(LIB_PATH.."ignite.lua") end
if ignite ~= nil then
	ignite.toggleKey = 78			-- Press key to toggle autoIgnite mode (nNn by default)
	ignite.forceIgniteKey = 84		-- Press key to force ignite (tTt by default)
	ignite.active = true			-- Default script active or not
	ignite.forced = false			-- global, do not touch
	
	function ignite.msgHandler(msg, key)
		if msg == KEY_DOWN then
			if key == ignite.toggleKey then
				ignite.active = not ignite.active
				PrintChat(" >> Auto ignite : "..(ignite.active and "ON" or "OFF"))
			elseif key == ignite.forceIgniteKey then
				ignite.forced = true
			end
		elseif key == ignite.forceIgniteKey then
			ignite.forced = false
		end
	end
	function ignite.tickHandler()
		if ignite.forced then
			ignite.autoIgniteLowestHealth()
		elseif ignite.active then
			ignite.autoIgniteIfKill()
		end
	end
	
	BoL:addTickHandler(ignite.tickHandler, 100)
	BoL:addMsgHandler(ignite.msgHandler)
    PrintChat(" >> Auto ignite script loaded !")
	PrintChat(" >> Auto ignite : "..(ignite.active and "ON" or "OFF"))
end