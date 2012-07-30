--[[
        Libray: Map Name v0.1
		Author: SurfaceS
		
		required libs : 		none
		exposed variables : 	map
		
		UPDATES :
		v0.1					initial release
		
		USAGE :
		Load the libray from your script
		
		map.name -> return you the full map name
		map.shortName -> return you the shorted map name (usefull for using it in table)
]]

map = {}
map.name, map.shortName = "unknown" , "unknown"
for i = 1, objManager.maxObjects do
	local object = objManager:getObject(i)
	if object ~= nil then
		if object.type == "obj_Shop" and object.team == TEAM_BLUE then
			if math.floor(object.x) == -175 and math.floor(object.y) == 163 and math.floor(object.z) == 1056 then
				map.name = "Summoner's Rift"
				map.shortName = "summonerRift"
				break
			elseif math.floor(object.x) == -217 and math.floor(object.y) == 276 and math.floor(object.z) == 7039 then
				map.name = "The Twisted Treeline"
				map.shortName = "twistedTreeline"
				break
			elseif math.floor(object.x) == 556 and math.floor(object.y) == 191 and math.floor(object.z) == 1887 then
				map.name = "The Proving Grounds"
				map.shortName = "provingGrounds"
				break
			elseif math.floor(object.x) == 16 and math.floor(object.y) == 168 and math.floor(object.z) == 4452 then
				map.name = "The Crystal Scar"
				map.shortName = "crystalScar"
				break
			end
		end
	end
end