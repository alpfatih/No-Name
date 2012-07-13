--[[
        MiniMap Hack
        v2.0
        Written by Kilua
]]

--[[ DONT TOUCH THIS LINE SAVED RESOLUTION DATA ]] Wsave = nil
--[[ DONT TOUCH THIS LINE SAVED RESOLUTION DATA ]] Hsave = nil

resolutionOffsetTable = {
    { offsets = {1627,897,1907,1182}, W = 1920, H = 1200 },
    { offsets = {1627,777,1907,1062}, W = 1920, H = 1080 },
    { offsets = {1387,747,1667,1032}, W = 1680, H = 1050 },
    { offsets = {1322,915,1587,1185}, W = 1600, H = 1200 },
    { offsets = {1322,736,1587,1007}, W = 1600, H = 1024 },
    { offsets = {1322,612,1587,883},  W = 1600, H = 900 },
    { offsets = {1190,641,1428,883},  W = 1440, H = 900 },
    { offsets = {1128,520,1355,751},  W = 1366, H = 768 },
    { offsets = {1124,520,1349,751},  W = 1360, H = 768 },
    { offsets = {1057,793,1269,1011}, W = 1280, H = 1024 },
    { offsets = {1057,729,1269,947},  W = 1280, H = 960 },
    { offsets = {1057,569,1269,787},  W = 1280, H = 800 },
    { offsets = {1057,535,1269,753},  W = 1280, H = 768 },
    { offsets = {1057,487,1269,705},  W = 1280, H = 720 },
}

MiniMapHackSprite = {}

function FindResolution()
    for i,v in ipairs(resolutionOffsetTable) do
        if v.W == Wsave and v.H == Hsave then
            return v.offsets
        end
    end
    PrintChat(" >> Your resolution "..Wsave.."x"..Hsave.." is not supported!")
    return nil
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function drawHandler()
		for i = 1, heroManager.iCount, 1 do
			local heros = heroManager:getHero(i)
            if heros ~= nil and heros.team ~= player.team  and heros.dead == false and heros.visible == false and heros.x ~= nil and heros.y ~= nil and heros.z ~= nil then
				MiniMapHackSprite[heros.charName]:Draw(minimapX+minimapL*(heros.x/14007)-4,minimapY-minimapH*(heros.z/14439)-2,200)
            end
        end
end

if Wsave == nil or Hsave == nil then
	if WINDOW_W ~= nil and WINDOW_H ~= nil then
		File = debug.getinfo(1).source:gsub("@",""):gsub("\\", "/")
		MyFile = io.open(File, 'r')
		data = MyFile:read("*all")
		MyFile:close()
		MyFile = io.open(File, 'w')
		data = string.gsub(data, "Wsave = nil", "Wsave = "..WINDOW_W - WINDOW_X,1)
		data = string.gsub(data, "Hsave = nil", "Hsave = "..WINDOW_H - WINDOW_Y,1)
		MyFile:write(data)
		MyFile:close()
		Wsave = WINDOW_W - WINDOW_X
		Hsave = WINDOW_H - WINDOW_Y
		PrintChat(" >> Detected resolution saved in your file : "..Wsave.."x"..Hsave)
	end
end

if Wsave ~= nil and Hsave ~= nil then
	Minimap = FindResolution()
	if Minimap ~= nil then
		minimapX = Minimap[1]
		minimapL = Minimap[3] - Minimap[1]
		minimapY = Minimap[4]
		minimapH = Minimap[4] - Minimap[2]
	end
end

for i = 1, heroManager.iCount, 1 do
	local heros = heroManager:getHero(i) 
    if heros ~= nil and heros.team ~= player.team then 
		if file_exists(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2):gsub("\\", "/"):gsub("/Scripts", "").."Sprites/BTN"..heros.charName..".png") == true then
			MiniMapHackSprite[heros.charName] = createSprite("BTN"..heros.charName..".png")
		else
			MiniMapHackSprite[heros.charName] = createSprite("BTNUnknow.png")
			PrintChat("MiniMapHack >> Dont find sprite 'BTN"..heros.charName..".png' for "..heros.charName..". So this sprite is replace by a black [?].")
		end
    end
end

PrintChat(" >> MiniMapHack loaded !")
BoL:addDrawHandler(drawHandler)