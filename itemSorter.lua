--[[
ikita's item sorter script 1.0
]]

HK = string.byte("8")
 
--[[ Config ]] --
            --Q, W, E, R, D, F, 1, 2, 3, 4, 5, 6
keypress = {81,87,69,82,68,70,49,50,51,52,53,54}



function OnLoad()
scriptActive = false
toggleActive = false
PrintChat(" >> ikita's Item sorter loaded")
end

--Item swap function
function swap(slotA,slotB)
	p = CLoLPacket(0x20)
	p.dwArg1 = 1
	p.dwArg2 = 0
	p:EncodeF(myHero.networkID)
	p:Encode1(slotA)
	p:Encode1(slotB)
	SendPacket(p)
end


--[[ Code ]] --

function OnTick()
if scriptActive and toggleActive then
for i = 0, 6, 1 do
swap(i,i+1)
end
end
end


 
function OnWndMsg( msg, keycode )
	if msg == KEY_DOWN then 
		if keycode == HK then
			if toggleActive then
				toggleActive = false
				scriptActive = false
				PrintChat(" >> Item sort disabled!")  
			else
				toggleActive = true
				scriptActive = true
				PrintChat(" >> Item sort enabled!")
			end     
		end
	end
	if msg == KEY_DOWN then
		for i = 0, #keypress, 1 do
			if keycode == keypress[i] then
				scriptActive = false
				tempStop = true
			end
		end
	end
	if msg == WM_LBUTTONUP and tempStop then
		scriptActive = true
		tempStop = false
	end
end