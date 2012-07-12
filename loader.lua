--[[
	Loader selector for other lua scripts
	v0.2a
	Written by SurfaceS
	idea from Zynox
]]

--[[         Globals        ]]
-- put here all variables that you will have common to all scripts
SCRIPT_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2).."Scripts\\"
LIB_PATH = SCRIPT_PATH.."Libs\\"
SPRITE_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2):gsub("\\", "/"):gsub("/Scripts", "").."Sprites\\"

myHero = GetMyHero()

--[[		Config		]]
showLoadedScript = false		-- Print Script loaded in chat
showErrorScript = false			-- Print Script load error in chat

scriptToLoad =
{
	
	--Put your scripts into the "Scripts/Scripts" folder and add them to this list!
	--Order is important as you should load champion script that use a library that should be run only once.
	--example is if you load champion script that use the exhaust lib, you don't want the autoExhaust script to be loaded.
	
	--{ file = "scriptname1",  		load = (myHero.charName == "Ahri") },
	--{ file = "scriptname2", 		load = true},
	{ file = "ryze", 			load = (myHero.charName == "Ryze") },
	{ file = "autoZhonya", 			load = false },
	{ file = "cloneRevealer", 		load = true },
	{ file = "jungleTimer", 		load = true },
	{ file = "autoExhaust", 		load = (string.find(myHero:GetSpellData(SUMMONER_1).name..myHero:GetSpellData(SUMMONER_2).name, "SummonerExhaust")) },
	{ file = "autoIgnite", 			load = (string.find(myHero:GetSpellData(SUMMONER_1).name..myHero:GetSpellData(SUMMONER_2).name, "SummonerDot")) },

}

--[[ 		Code		]]
function LoadScript(name)
	local scriptFunction, scriptError = loadfile(SCRIPT_PATH..name..".lua")
	if scriptFunction ~= nil then
		if showLoadedScript then
			PrintChat("> "..name.." script loaded")
		end
		return scriptFunction()
	elseif showErrorScript then
		PrintChat("> Error on "..name.." script : "..scriptError)
		PrintChat("> "..name.." script not loaded")
	end
end

for i,script in ipairs(scriptToLoad) do
	if script.load then
		LoadScript(script.file)
	end
end
