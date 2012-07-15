--[[
        Script: MiniMap Hack v3.0a
		Author: Kilua
		
		required libs : minimap_marks_lib, minimap_marks_wizard, anim
		
		- fixing bugsplat ?
]]

-- for those who not use loader.lua
if SCRIPT_PATH == nil then SCRIPT_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2) end
if LIB_PATH == nil then LIB_PATH = SCRIPT_PATH.."Libs/" end
if SPRITE_PATH == nil then SPRITE_PATH = SCRIPT_PATH:gsub("\\", "/"):gsub("/Scripts", "").."Sprites/" end
if myHero == nil then myHero = GetMyHero() end

MiniMapHackSprite = {}

if initMarks == nil then dofile(LIB_PATH.."minimap_marks_lib.lua") end
initMarks()

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function drawHandler()
	for i = 1, heroManager.iCount, 1 do
		local heros = heroManager:getHero(i)
		if heros ~= nil and heros.team ~= myHero.team and heros.dead == false and heros.visible == false and heros.x ~= nil and heros.y ~= nil and heros.z ~= nil then
			if initMarksState == 1 then
				Xminimap, Yminimap = convertToMinimap(heros.x,heros.z)
				if MiniMapHackSprite[heros.charName] ~= nil then
					MiniMapHackSprite[heros.charName]:Draw(Xminimap, Yminimap,200)
				end
			else
				initMarks()
			end
		end
	end
end

for i = 1, heroManager.iCount, 1 do
	local heros = heroManager:getHero(i) 
    if heros ~= nil and heros.team ~= myHero.team then 
		if file_exists(SPRITE_PATH.."BTN"..heros.charName..".png") == true then
			MiniMapHackSprite[heros.charName] = createSprite("BTN"..heros.charName..".png")
		else
			MiniMapHackSprite[heros.charName] = createSprite("BTNUnknow.png")
			PrintChat("MiniMapHack >> Dont find sprite 'BTN"..heros.charName..".png' for "..heros.charName..". So this sprite is replace by a black [?].")
		end
    end
end

BoL:addDrawHandler(drawHandler)
PrintChat(" >> MiniMapHack loaded !")