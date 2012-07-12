--[[
	Auto exhaust v0.2
	Script by SurfaceS
]]

--[[         Code          ]]
-- for those who not use loader.lua
if LIB_PATH == nil then LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2).."Libs\\" end

-- Load exhaust lib if needed
if exhaust == nil then dofile(LIB_PATH.."exhaust.lua") end
if exhaust ~= nil then
	exhaust.forceExhaustKey = 32		-- Press key to force exhaust (spacebar by default)
	exhaust.active = false
	function exhaust.msgHandler(msg, key)
		if msg == KEY_DOWN and key == exhaust.forceExhaustKey then
			exhaust.active = true
		elseif key == exhaust.forceExhaustKey then
			exhaust.active = false
		end
	end
	function exhaust.tickHandler()
		if exhaust.active then
			exhaust.autoExhaust()
		end
	end
	BoL:addTickHandler(exhaust.tickHandler, 100)
	BoL:addMsgHandler(exhaust.msgHandler)
    PrintChat(" >> Auto exhaust script loaded!")
end