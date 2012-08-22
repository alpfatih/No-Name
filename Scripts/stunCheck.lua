if GetMyHero().charName ~= nil then
--[[
	Stun Alert v1.1
	Will show how many champions currently has stun/silence/supression/knockbacks
]]
stunChamps = 999
player = GetMyHero()
--[[		Code		]]

local function drawHandlerS()
	local number = countStun()
	DrawText("Stuns: " .. number, 18, 200, 120, 0xFFFFFF00)
end


local function countStun()
	local stunFlag = 0
	for i=1, heroManager.iCount do
		targetS = heroManager:GetHero(i)
		if targetS ~= nil and targetS.team ~= player.team and targetS.dead == false then
			--Champions that have stuns
			if targetS.charName == "Ahri" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Alistar" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_W) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Amumu" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Anivia" then
				if targetS:CanUseSpell(_W) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Annie" then
				local passive3 = false
				for k = 1, objManager.maxObjects do
        			local objectS = objManager:GetObject(k)
					if objectS ~= nil and objectS.name == "Data\\Particles\\Stun3.troy" and targetS:GetDistance(objectS) <= 100 then
						passive3 = true
					end
				end
				if passive3 == true then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Ashe" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end		
			if targetS.charName == "Blitzcrank" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_E) == 3 or targetS:CanUseSpell(_R) then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Brand" then
				if targetS:CanUseSpell(_Q) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Cassiopeia" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Chogath" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_W) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Darius" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Diana" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Draven" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end		
			if targetS.charName == "Fiddlesticks" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Galio" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Garen" then
				if targetS:CanUseSpell(_Q) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Gragas" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Hecarim" then
				if targetS:CanUseSpell(_E) == 3 or targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Heimerdinger" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Irelia" then
				local player = GetMyHero()
				if targetS:CanUseSpell(_E) == 3 and (targetS.health/targetS.maxHealth) < (player.health/player.maxHealth) then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Janna" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "JarvanIV" then
				if targetS:CanUseSpell(_Q) == 3 and targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Jax" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Jayce" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Kassadin" then
				if targetS:CanUseSpell(_Q) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Kennen" then --Need help
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "LeBlanc" then
				if targetS:CanUseSpell(_Q) == 3 and (targetS:CanUseSpell(_W) == 3 or targetS:CanUseSpell(_E) == 3 or targetS:CanUseSpell(_R) == 3) then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "LeeSin" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Leona" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Lulu" then
				if targetS:CanUseSpell(_W) == 3 or targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Malphite" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Malzahar" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Maokai" then
				if targetS:CanUseSpell(_Q) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Morgana" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Nautilus" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Nocturne" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Orianna" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Pantheon" then
				if targetS:CanUseSpell(_W) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Poppy" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Rammus" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Malphite" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Malzahar" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Renekton" then
				if targetS:CanUseSpell(_W) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Riven" then
				if targetS:CanUseSpell(_W) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Sejuani" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Shen" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Shyvana" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Singed" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Skarner" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Sona" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Talon" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Taric" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Tristana" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "TwistedFate" then
				local cardFound = false
        		for k = 1, objManager.maxObjects do
        			local objectS = objManager:GetObject(k)
        			if objectS ~= nil and objectS.name:find("Card_Yellow") and targetS:GetDistance(objectS) < 80 then
						cardFound = true
					end
				end
				if cardFound == true then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Udyr" then -- Need help
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Urgot" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Vayne" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Veigar" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Viktor" then
				if targetS:CanUseSpell(_W) == 3 or targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Volibear" then
				if targetS:CanUseSpell(_Q) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Warwick" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "MonkeyKing" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Xerath" then
				if targetS:CanUseSpell(_E) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "XinZhao" then
				if targetS:CanUseSpell(_Q) == 3 or targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
			if targetS.charName == "Ziggs" then
				if targetS:CanUseSpell(_W) == 3 then
					stunFlag = stunFlag + 1
				end
			end	
			if targetS.charName == "Zyra" then
				if targetS:CanUseSpell(_R) == 3 then
					stunFlag = stunFlag + 1
				end
			end
		end
	end
	stunChamps = stunFlag
	return stunChamps
end



BoL:addDrawHandler(drawHandlerS)
PrintChat(" >> Stun alert loaded!")

end