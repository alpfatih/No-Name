if GetMyHero().charName == "Soraka" then
--[[
	ikita's item list for Soraka
]]


require "AllClass"


--[[		Config		]]                      
shopList = {2044, 2044, 2044, 1004, 2003, 2003, 1007, 3096, 1001, 1028, 3132, 3158, 1028, 3067, 3069, 1028, 1029, 1033, 3105}
buyDelay = 500


lastBuy = 0
nextbuyIndex = 1
firstBought = false
--[[ 		Code		]]



function OnTick()
	if firstBought == false and GetTickCount() - startingTime > 2000 then
		BuyItem(2044)
		BuyItem(2044)
		BuyItem(2044)
		BuyItem(1004)
		BuyItem(2003)
		BuyItem(2003)
		firstBought = true
	end
	if GetTickCount() - startingTime > 8000 and GetInventorySlotItem(2044) == nil then
		BuyItem(2044)
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
	PrintChat("Soraka Items Loaded")
end
end