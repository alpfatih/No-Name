--[[
	Inventory Library by SurfaceS
	Version 0.2
]]--

-- for those who not use loader.lua
if myHero == nil then myHero = GetMyHero() end

inventory = {}
inventory.ItemSlot = {ITEM_1,ITEM_2,ITEM_3,ITEM_4,ITEM_5,ITEM_6}
function inventory.SlotItem( itemID )
    for i=1,6,1 do
        if myHero:getInventorySlot(inventory.ItemSlot[i]) == itemID then return inventory.ItemSlot[i] end
    end
	return nil
end
function inventory.HaveItem( itemID )
    local slot = inventory.SlotItem( itemID ) 
	return (slot ~= nil)
end
function inventory.SlotIsEmpty( slot )
    return (myHero:getInventorySlot(slot) == 0)
end
function inventory.ItemIsCastable( itemID )
	local slot = inventory.SlotItem( itemID )
	if slot == nil then return false end
	return (myHero:CanUseSpell(slot) == READY)
end
-- UseItem(itemID) -> Cast item
-- UseItem(itemID, var1) -> Cast item on hero = var1
-- UseItem(itemID, var1, var2) -> Cast item on posX = var1, pasZ = var2
function inventory.UseItem( itemID, var1, var2 )
	local slot = inventory.SlotItem( itemID )
	if slot == nil then return false end
	if (myHero:CanUseSpell(slot) == READY) then
		if (var2 ~= nil) then CastSpell(slot, var1, var2)
		elseif (var1 ~= nil) then CastSpell(slot, var1)
		else CastSpell(slot)
		end
		return true
	end
	return false
end
