--[[
    Script: Screen Lib v0.1
    Author: SurfaceS
	
	Prupose : save the WINDOW values
	
	v0.1	initial release
]]

if LIB_PATH == nil then LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2).."Libs\\" end

screen = {}
screen.config_file = LIB_PATH.."screen.cfg"
screen.offsets = {}
screen.resolution = {W=0,H=0,X=0,Y=0}

function screen.writeConfig()
    local file = io.open(screen.config_file, "w")
    if file then
        --file:write("screen.offsets = { "..screen.offsets[1]..", "..screen.offsets[2]..", "..screen.offsets[3]..", "..screen.offsets[4].." }\n")
        file:write("screen.resolution = { W="..WINDOW_W..", H="..WINDOW_H..", X="..WINDOW_X..", Y="..WINDOW_Y.." }\n")
        file:close()
    end
    return file ~= nil
end

-- ===========================================
-- Return true if file exists and is readable.
-- ===========================================
if file_exists == nil then
	function file_exists(path)
		local file = io.open(path, "rb")
		if file then file:close() end
		return file ~= nil
	end
end

-- ===========================================
-- Init-function. Needs to be runned once in the script.
-- ===========================================

if file_exists(screen.config_file) then
	dofile(screen.config_file)
end
if WINDOW_W ~= nil and WINDOW_H ~= nil and WINDOW_W > 1024 and WINDOW_H > 768 and WINDOW_W ~= screen.resolution.W and WINDOW_H ~= screen.resolution.H then
	screen.resolution = {W=WINDOW_W, H=WINDOW_H, X=WINDOW_X, Y=WINDOW_Y,}
	screen.writeConfig()
end
