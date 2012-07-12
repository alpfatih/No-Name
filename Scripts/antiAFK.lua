--[[
        Anti AFK
        v1.0
        Written by Kilua
]]

player = GetMyHero()
tick = nil
xtemp = player.x
ztemp = player.z

function tickHandler()
	if tick == nil and player.x == xtemp and player.z == ztemp then
		tick = GetTickCount()
		timer = math.random(50000,100000)
	elseif tick ~= nil and GetTickCount() - tick > timer and player.x == xtemp and player.z == ztemp then
		player:MoveTo(player.x,player.z)
		tick = nil
	elseif player.x ~= xtemp or player.z ~= ztemp then
		xtemp = player.x
		ztemp = player.z
		tick = nil
	end
end

PrintChat(" >> AntiAfk Loaded !")
BoL:addTickHandler(tickHandler,100)