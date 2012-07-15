--[[
        Anti AFK
        v1.0
        Written by Kilua
]]

if myHero == nil then myHero = GetMyHero() end
antiAFK = {}
antiAFK.tick = nil
antiAFK.x = myHero.x
antiAFK.z = myHero.z
antiAFK.timer = 0

function antiAFK.tickHandler()
	if antiAFK.tick == nil and myHero.x == antiAFK.x and myHero.z == antiAFK.z then
		antiAFK.tick = GetTickCount()
		antiAFK.timer = math.random(50000,100000)
	elseif antiAFK.tick ~= nil and GetTickCount() - antiAFK.tick > timer and myHero.x == antiAFK.x and myHero.z == antiAFK.z then
		myHero:MoveTo(myHero.x,myHero.z)
		antiAFK.tick = nil
	elseif myHero.x ~= antiAFK.x or myHero.z ~= antiAFK.z then
		antiAFK.x = myHero.x
		antiAFK.z = myHero.z
		antiAFK.tick = nil
	end
end

PrintChat(" >> AntiAfk Loaded !")
BoL:addTickHandler(antiAFK.tickHandler,5000)