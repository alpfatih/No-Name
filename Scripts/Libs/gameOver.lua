--[[
    Script: Game Over Lib v0.1
    Author: SurfaceS
	Goal : return the game over state
	
	Todo : find a way for the map "The Crystal Scar"
	
	Required libs : 		map
	Exposed variables : 	gameOver

	v0.1					initial release
]]

if gameOver ~= nil then return end

if LIB_PATH == nil then LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2) end
if map == nil then dofile(LIB_PATH.."map.lua") end

gameOver = {}
gameOver.objects = {}
gameOver.isOver = false
gameOver.looser = 0
gameOver.winner = 0

if map.index == 1 or map.index == 2 or map.index == 3 then
	gameOver.objectName = "obj_HQ"
else
	return
end

gameOver.objectFounded = 0
for i = 1, objManager.maxObjects, 1 do
	local object = objManager:getObject(i)
	if object ~= nil and object.type == gameOver.objectName then 
		gameOver.objectFounded = gameOver.objectFounded + 1
		gameOver.objects[gameOver.objectFounded] = { object = object, team = object.team }
	end
end

function gameOver.tickHandler()
	for i, objectCheck in pairs(gameOver.objects) do
		if objectCheck.object == nil or objectCheck.object.dead or objectCheck.object.health == 0 then
			gameOver.isOver = true
			gameOver.looser = objectCheck.team
			gameOver.winner = (objectCheck.team == TEAM_BLUE and TEAM_RED or TEAM_BLUE)
			gameOver.tickHandler = nil
			break
		end
	end
end

BoL:addTickHandler(gameOver.tickHandler, 250)