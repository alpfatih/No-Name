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
	local objSP = objManager:getObject(i)
	if objSP ~= nil then
		if objSP.type == "obj_Shop" and objSP.team == TEAM_BLUE then
			PrintChat(objSP.type.." - "..objSP.x.." - "..objSP.y.." - "..objSP.z)
			if math.floor(objSP.x) == -175 and math.floor(objSP.y) == 163 and math.floor(objSP.z) == 1056 then
				map.name = "Summoner's Rift"
				map.shortName = "summonerRift"
				break
			elseif math.floor(objSP.x) == -217 and math.floor(objSP.y) == 276 and math.floor(objSP.z) == 7039 then
				map.name = "The Twisted Treeline"
				map.shortName = "twistedTreeline"
				break
			elseif math.floor(objSP.x) == 556 and math.floor(objSP.y) == 191 and math.floor(objSP.z) == 1887 then
				map.name = "The Proving Grounds"
				map.shortName = "provingGrounds"
				break
			elseif math.floor(objSP.x) == 16 and math.floor(objSP.y) == 168 and math.floor(objSP.z) == 4452 then
				map.name = "The Crystal Scar"
				map.shortName = "crystalScar"
				break
			end
		end
	end
end