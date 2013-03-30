--[[

	Mass Pings v1.0 by ikita for BoL Studio

]]


casterTimer = {0,0,0,0,0,0,0,0,0,0,0}
pingTypeHero = {0,0,0,0,0,0,0,0,0,0,0}

PrintChat(">> Mass Pings loaded")

local HK = 72

function OnRecvPacket(p)
	if p.header == 0x3F then
		
			p.dwArg1 = 0
  		p.dwArg2 = 0
  		header = p:Decode1()
		unk1 = p:Decode4() -- 4 bytes unused space (always 00 00)
		xLoc = p:DecodeF() -- X
		zLoc = p:DecodeF() -- Z
		unk2 = p:Decode4() -- 4 bytes unused space (always 00 00)
		casterID = p:DecodeF() -- 4 Bytes networkID
		pingType = p:Decode1() -- 1 byte
		for i=1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.networkID == casterID then
				casterTimer[i] = GetTickCount()
				pingTypeHero[i] = pingType
			end
			if casterID == player.networkID and pingType == 178 then
				massPing(xLoc + 700,zLoc,0)
				massPing(xLoc + 700*math.cos(2*math.pi / 5),zLoc + 700*math.sin(2*math.pi / 5),0)
				massPing(xLoc + 700*math.cos(4*math.pi / 5),zLoc + 700*math.sin(4*math.pi / 5),0)
				massPing(xLoc + 700*math.cos(6*math.pi / 5),zLoc + 700*math.sin(6*math.pi / 5),0)
				massPing(xLoc + 700*math.cos(8*math.pi / 5),zLoc + 700*math.sin(8*math.pi / 5),0)
			end
		end
	end
end

function massPing(xLoc,zLoc,target)
	p = CLoLPacket(0x56)
	p:Encode4(0)
	p:EncodeF(xLoc)
	p:EncodeF(zLoc)
	p:EncodeF(target)
	p:Encode2(05)
	p.dwArg1 = 1
	p.dwArg2 = 0
	SendPacket(p)
end

function massPingNearest()
	for i=1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero~= nil and hero.networkID ~=nil and hero.team == player.team and math.sqrt((mousePos.z - hero.z)^2 +(mousePos.x - hero.x)^2) < 400 then
		xLoc = hero.x
		zLoc = hero.z
		massPing(xLoc,zLoc,hero.networkID)
		massPing(xLoc + 700,zLoc,hero.networkID)
		massPing(xLoc + 700*math.cos(2*math.pi / 5),zLoc + 700*math.sin(2*math.pi / 5),hero.networkID)
		massPing(xLoc + 700*math.cos(4*math.pi / 5),zLoc + 700*math.sin(4*math.pi / 5),hero.networkID)
		massPing(xLoc + 700*math.cos(6*math.pi / 5),zLoc + 700*math.sin(6*math.pi / 5),hero.networkID)
		massPing(xLoc + 700*math.cos(8*math.pi / 5),zLoc + 700*math.sin(8*math.pi / 5),hero.networkID)
		end
	end
end

function OnWndMsg(msg,key)
	if msg == KEY_DOWN then
		if key == HK then
			massPingNearest()
		end
	end
	if msg == KEY_UP then
		if key == HK then
    end
	end
end