--[[
	Auto Level Spells
	v0.2d
	
	required lib :		autoLevel
	exposed variable :	none, use autoLevel
	
	Levels the Abilities of every single Champion
	Written by grey
	
	Dont forget to check the autoLevel.levelSequence of your champion
	Thanks to Zynox who gave me some ideas and tipps. 
	the default ability sequences are from mobafire :)
	
	Modified by Mistal for BoL
]]

if LIB_PATH == nil then LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2).."Libs\\" end
if autoLevel == nil then dofile(LIB_PATH.."autoLevel.lua") else return end -- unload if autoLevel already in use
if myHero == nil then myHero = GetMyHero() end

--[[ 		Config		]]
autoLevel.checkInterval = 1000

--[[
	in this section you can change the autoLevel.levelSequence of your champion
	please contact me if you find an autoLevel.levelSequence which works, that i can give this an approved seal. also contact me, if it doesnt work (give me the name of this champ written in the ingame console)
	to disable AutoLevelSpells Script for a specific champ just comment out the line like this: --elseif champ=.....
]]
if     myHero.charName=="Ahri" then		autoLevel.levelSequence={1,3,2,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Akali" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,3,1,2,4,3,3,2,2,4,3,2,}
elseif myHero.charName=="Alistar" then 		autoLevel.levelSequence={1,3,2,1,3,4,1,3,1,3,4,1,3,2,2,4,2,2,}
elseif myHero.charName=="Amumu" then 		autoLevel.levelSequence={1,3,3,2,3,4,3,2,3,2,4,2,2,1,1,4,1,1,}
elseif myHero.charName=="Anivia" then 		autoLevel.levelSequence={1,3,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2,}
elseif myHero.charName=="Annie" then 		autoLevel.levelSequence={1,2,1,2,1,4,1,2,1,2,4,2,3,3,3,4,3,3,}
elseif myHero.charName=="Ashe" then 		autoLevel.levelSequence={2,1,3,1,3,4,1,3,1,3,4,1,3,2,2,4,2,2,}
elseif myHero.charName=="Blitzcrank" then 	autoLevel.levelSequence={1,3,2,3,2,4,3,2,3,2,4,3,2,1,1,4,1,1,}
elseif myHero.charName=="Brand" then 		autoLevel.levelSequence={2,1,3,2,2,4,2,3,2,3,4,3,3,1,1,4,1,1,}
elseif myHero.charName=="Caitlyn" then 		autoLevel.levelSequence={2,1,1,3,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Cassiopeia" then 	autoLevel.levelSequence={1,3,1,2,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Chogath" then 		autoLevel.levelSequence={1,3,2,2,2,4,2,3,2,3,4,3,3,1,1,4,1,1,}
elseif myHero.charName=="Corki" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="DrMundo" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,3,1,3,4,3,2,3,2,4,2,2,}
elseif myHero.charName=="Evelynn" then 		autoLevel.levelSequence={2,3,2,1,3,4,3,3,2,3,4,1,1,1,1,4,2,2,}
elseif myHero.charName=="Ezreal" then 		autoLevel.levelSequence={1,3,1,2,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Fiddlesticks" then 	autoLevel.levelSequence={2,3,2,1,3,4,2,2,2,3,4,3,3,1,4,1,1,1,}
elseif myHero.charName=="Fizz" then 		autoLevel.levelSequence={3,1,2,1,2,4,1,1,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Galio" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,2,1,2,4,3,3,2,2,4,3,3,}
elseif myHero.charName=="Gangplank" then 	autoLevel.levelSequence={1,2,1,3,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Garen" then		autoLevel.levelSequence={3,1,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2,}
elseif myHero.charName=="Gragas" then 		autoLevel.levelSequence={1,3,1,2,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Graves" then 		autoLevel.levelSequence={1,3,1,2,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Heimerdinger" then 	autoLevel.levelSequence={1,2,2,1,1,4,3,2,2,2,4,1,1,3,3,4,1,1,}
elseif myHero.charName=="Irelia" then 		autoLevel.levelSequence={1,2,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3,}
elseif myHero.charName=="Janna" then 		autoLevel.levelSequence={3,1,3,2,3,4,3,2,3,2,2,2,4,1,1,4,1,1,}
elseif myHero.charName=="JarvanIV" then 	autoLevel.levelSequence={1,3,1,2,1,4,1,3,2,1,4,3,3,3,2,4,2,2,}
elseif myHero.charName=="Jax" then 		autoLevel.levelSequence={1,2,3,1,1,4,1,2,1,2,4,2,3,2,3,4,3,3,}
elseif myHero.charName=="Karma" then 		autoLevel.levelSequence={1,3,1,2,3,1,3,1,3,1,3,1,3,2,2,2,2,2,}
elseif myHero.charName=="Karthus" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,3,1,3,4,3,2,3,2,4,2,2,}
elseif myHero.charName=="Kassadin" then 	autoLevel.levelSequence={1,2,1,3,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Katarina" then 	autoLevel.levelSequence={3,1,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2,}
elseif myHero.charName=="Kayle" then 		autoLevel.levelSequence={3,2,3,1,3,4,3,2,3,2,4,2,2,1,1,4,1,1,}
elseif myHero.charName=="Kennen" then 		autoLevel.levelSequence={1,2,3,1,2,4,1,2,1,1,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="KogMaw" then 		autoLevel.levelSequence={2,3,2,1,2,4,2,1,2,1,4,1,1,3,3,4,3,3,}
elseif myHero.charName=="LeBlanc" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,2,1,2,4,2,3,2,3,4,3,3,}
elseif myHero.charName=="LeeSin" then 		autoLevel.levelSequence={3,2,1,1,1,4,1,2,1,2,4,2,3,2,3,4,3,3,}
elseif myHero.charName=="Leona" then 		autoLevel.levelSequence={1,3,2,2,2,4,2,3,2,3,4,3,3,1,1,4,1,1,}
elseif myHero.charName=="Lux" then 		autoLevel.levelSequence={3,1,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2,} --approved
elseif myHero.charName=="Malphite" then 	autoLevel.levelSequence={1,3,1,2,1,4,1,3,1,3,4,3,2,3,2,4,2,2,}
elseif myHero.charName=="Malzahar" then 	autoLevel.levelSequence={1,3,3,2,3,4,1,3,1,3,4,2,1,2,1,4,2,2,}
elseif myHero.charName=="Maokai" then 		autoLevel.levelSequence={3,2,3,1,3,4,3,2,3,2,4,1,1,2,2,4,1,1,}
elseif myHero.charName=="MasterYi" then 	autoLevel.levelSequence={3,1,3,1,3,4,3,1,3,1,4,1,2,2,2,4,2,2,}
elseif myHero.charName=="MissFortune" then 	autoLevel.levelSequence={2,1,2,3,2,4,2,3,2,3,4,3,3,1,1,4,1,1,}
elseif myHero.charName=="Mordekaiser" then 	autoLevel.levelSequence={3,1,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2,}
elseif myHero.charName=="Morgana" then 		autoLevel.levelSequence={1,2,2,3,2,4,2,3,2,3,4,3,3,1,1,4,1,1,}
elseif myHero.charName=="Nasus" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,2,1,2,4,2,3,2,3,4,3,3,}
elseif myHero.charName=="Nidalee" then 		autoLevel.levelSequence={2,3,1,3,1,4,3,2,3,1,4,3,1,1,2,4,2,2,}
elseif myHero.charName=="Nocturne" then 	autoLevel.levelSequence={1,2,1,3,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Nunu" then 		autoLevel.levelSequence={3,1,3,2,1,4,3,1,3,1,4,1,3,2,2,4,2,2,}
elseif myHero.charName=="Olaf" then 		autoLevel.levelSequence={2,1,2,3,3,4,3,3,3,1,4,2,1,1,2,4,2,1,}
elseif myHero.charName=="Orianna" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Pantheon" then 	autoLevel.levelSequence={1,2,3,1,1,4,1,3,1,3,4,3,2,3,2,4,2,2,}
elseif myHero.charName=="Poppy" then 		autoLevel.levelSequence={3,2,1,1,1,4,1,2,1,2,2,2,3,3,3,3,4,4,}
elseif myHero.charName=="Rammus" then 		autoLevel.levelSequence={1,2,3,3,3,4,3,2,3,2,4,2,2,1,1,4,1,1,}
elseif myHero.charName=="Renekton" then 	autoLevel.levelSequence={2,1,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Riven" then 		autoLevel.levelSequence={1,2,3,2,2,4,2,3,2,3,4,3,3,1,1,4,1,1,}
elseif myHero.charName=="Rumble" then 		autoLevel.levelSequence={1,3,2,1,1,4,2,1,1,3,4,2,3,2,3,4,2,3,}
elseif myHero.charName=="Ryze" then 		autoLevel.levelSequence={2,1,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Sejuani" then 		autoLevel.levelSequence={2,1,3,3,2,4,3,2,3,3,4,2,1,2,1,4,1,1,}
elseif myHero.charName=="Shaco" then 		autoLevel.levelSequence={2,3,1,3,3,4,3,2,3,2,4,2,2,1,1,4,1,1,}
elseif myHero.charName=="Shen" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Shyvana" then 		autoLevel.levelSequence={2,1,2,3,2,4,2,1,2,1,4,1,1,3,3,4,3,3,}
elseif myHero.charName=="Singed" then 		autoLevel.levelSequence={3,1,2,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Sion" then 		autoLevel.levelSequence={1,3,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2,}
elseif myHero.charName=="Sivir" then 		autoLevel.levelSequence={1,3,1,2,1,4,1,2,1,2,4,2,3,2,3,4,3,3,}
elseif myHero.charName=="Skarner" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Sona" then 		autoLevel.levelSequence={2,1,2,3,2,4,2,1,2,1,4,1,1,3,3,4,3,3,}
elseif myHero.charName=="Soraka" then 		autoLevel.levelSequence={2,3,2,3,1,4,2,3,2,3,4,2,3,1,1,4,1,1,} -- optmized to my Soraka support.
elseif myHero.charName=="Swain" then 		autoLevel.levelSequence={2,3,3,1,3,4,3,1,3,1,4,1,1,2,2,4,2,2,}
elseif myHero.charName=="Talon" then 		autoLevel.levelSequence={2,3,1,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3,}
elseif myHero.charName=="Taric" then 		autoLevel.levelSequence={3,2,1,2,2,4,1,2,2,1,4,1,1,3,3,4,3,3,}
elseif myHero.charName=="Teemo" then 		autoLevel.levelSequence={1,3,2,3,1,4,3,3,3,1,4,2,2,1,2,4,2,1,}
elseif myHero.charName=="Tristana" then 	autoLevel.levelSequence={3,2,2,3,2,4,2,1,2,1,4,1,1,1,3,4,3,3,}
elseif myHero.charName=="Trundle" then 		autoLevel.levelSequence={1,2,1,3,1,4,1,2,1,3,4,2,3,2,3,4,2,3,}
elseif myHero.charName=="Tryndamere" then 	autoLevel.levelSequence={3,1,2,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="TwistedFate" then 	autoLevel.levelSequence={2,1,1,3,1,4,2,1,2,1,4,2,2,3,3,4,3,3,} -- for TF AP
elseif myHero.charName=="Twitch" then 		autoLevel.levelSequence={1,3,3,2,3,4,3,1,3,1,4,1,1,2,2,1,2,2,}
elseif myHero.charName=="Udyr" then 		autoLevel.levelSequence={1,2,1,3,1,3,2,1,2,1,2,3,2,4,3,3,4,4,}
elseif myHero.charName=="Urgot" then 		autoLevel.levelSequence={3,1,1,2,1,4,1,2,1,3,4,2,3,2,3,4,2,3,}
elseif myHero.charName=="Vayne" then 		autoLevel.levelSequence={1,3,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Veigar" then 		autoLevel.levelSequence={1,3,1,2,1,4,2,2,2,2,4,3,1,1,3,4,3,3,}
elseif myHero.charName=="Viktor" then 		autoLevel.levelSequence={3,2,3,1,3,4,3,1,3,1,4,1,2,1,2,4,2,2,}
elseif myHero.charName=="Vladimir" then 	autoLevel.levelSequence={1,3,1,2,1,4,1,3,1,3,4,3,2,3,2,4,2,2,}
elseif myHero.charName=="Volibear" then 	autoLevel.levelSequence={2,3,2,1,2,4,3,2,1,2,4,3,1,3,1,4,3,1,}
elseif myHero.charName=="Warwick" then 		autoLevel.levelSequence={2,1,1,2,1,4,1,3,1,3,4,3,3,3,2,4,2,2,}
elseif myHero.charName=="MonkeyKing" then	autoLevel.levelSequence={3,1,2,1,1,4,3,1,3,1,4,3,3,2,2,4,2,2,} --approved
elseif myHero.charName=="Xerath" then 		autoLevel.levelSequence={1,3,1,2,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="XinZhao" then 		autoLevel.levelSequence={1,3,1,2,1,4,1,2,1,2,4,2,2,3,3,4,3,3,}
elseif myHero.charName=="Yorick" then 		autoLevel.levelSequence={2,3,1,3,3,4,3,2,3,1,4,2,1,2,1,4,2,1,}
elseif myHero.charName=="Ziggs" then 		autoLevel.levelSequence={1,3,1,2,1,4,1,3,1,3,4,3,3,2,2,4,2,2,}
elseif myHero.charName=="Zilean" then 		autoLevel.levelSequence={1,2,3,1,1,4,1,3,1,3,4,2,3,2,3,4,2,2,}
else
	PrintChat(string.format(" >> AutoLevelSpell Script disabled for %s" ,champ))
	autoLevel = nil
	return
end

if autoLevel.levelSequence ~= nil then
	BoL:addTickHandler(autoLevel.levelSpellTick, autoLevel.checkInterval)
	PrintChat(" >> AutoLevelSpell Script loaded!")
end