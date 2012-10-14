if GetMyHero().charName == "Sona" or GetMyHero().charName == "Soraka" then
--[[
	ikita's item list for Soraka/Sona
]]


require "AllClass"


--[[		Config		]]                      
if GetMyHero().charName == "Sona" then
PrintChat("Support Items Loaded: Sona")
shopList = {2044, 2044, 2044, 1004, 2004, 2004, 1007, 3096, 1001, 1028, 3132, 1033, 3028, 3158, 1028, 3067, 3069, 1028, 1029, 3105, 1029, 3097, 3190, 1028, 3010, 3102}
end
if GetMyHero().charName == "Soraka" then
PrintChat("Support Items Loaded: Soraka")
shopList = {2044, 2044, 2044, 1004, 2004, 2004, 1007, 3096, 1001, 1028, 3132, 3158, 1028, 3067, 3069, 1028, 1029, 3105, 1029, 3097, 3190, 1028, 3010, 3102}
end

buyDelay = 500


lastBuy = 0
nextbuyIndex = 1
wardBought = 0
firstBought = false
--[[ 		Code		]]



function OnTick()
	if firstBought == false and GetTickCount() - startingTime > 2000 then
		BuyItem(2044)
		BuyItem(2044)
		BuyItem(2044)
		BuyItem(1004)
		BuyItem(2004)
		BuyItem(2003)
		firstBought = true
	end
	if GetTickCount() - wardBought > 30000 and GetTickCount() - startingTime > 8000 and GetInventorySlotItem(2044) == nil then
		BuyItem(2044)
		BuyItem(2044)
		wardBought = GetTickCount()
	end
	if GetTickCount() - startingTime > 5000 then
		if GetTickCount() > lastBuy + buyDelay then
			if GetInventorySlotItem(shopList[nextbuyIndex]) ~= nil then
			--Last Buy successful
				nextbuyIndex = nextbuyIndex + 1
			else
			--Last Buy unsuccessful (buy again)
				BuyItem(shopList[nextbuyIndex])
				lastBuy = GetTickCount()
			end
		end
	end
end






function OnLoad()
	if GetInventorySlotIsEmpty(ITEM_1) == false then
		firstBought = true
	end
	startingTime = GetTickCount()
end
end