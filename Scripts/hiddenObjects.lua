--[[
        Script: Hidden Objects Display v0.1
		Author: SurfaceS
		
		required libs : 		minimap
		required sprites : 		Hidden Objects Sprites
		exposed variables : 	hiddenObjects, file_exists
		
		UPDATES :
		v0.1					initial release
		
		
		USAGE :
		Hold shift key to see the hidden object's range.
]]

--[[      GLOBAL      ]]
if SCRIPT_PATH == nil then SCRIPT_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2) end
if LIB_PATH == nil then LIB_PATH = SCRIPT_PATH.."Libs/" end
if SPRITE_PATH == nil then SPRITE_PATH = SCRIPT_PATH:gsub("\\", "/"):gsub("/Scripts", "").."Sprites/" end
if myHero == nil then myHero = GetMyHero() end

hiddenObjects = {}
hiddenObjects.objectsToAdd = {
	{ name = "VisionWard", objectType = "wards", spellName = "VisionWard", color = 0x00FF00FF, range = 1450, duration = 180000, icon = "yellowPoint"},
	{ name = "SightWard", objectType = "wards", spellName = "SightWard", color = 0x0000FF00, range = 1450, duration = 180000, icon = "greenPoint"},
	{ name = "WriggleLantern", objectType = "wards", spellName = "WriggleLantern", color = 0x0000FF00, range = 1450, duration = 180000, icon = "greenPoint"},
	{ name = "ShacoBox", objectType = "boxes", spellName = "ShacoBox", color = 0x00FF0000, range = 300, duration = 60000, icon = "redPoint"},
	{ name = "MaokaiSproutling", objectType = "boxes", spellName = "MaokaiSapling2", color = 0x00FF0000, range = 300, duration = 35000, icon = "redPoint"},
	{ name = "TeemoMushroom", objectType = "traps", spellName = "TeemoMushroom", color = 0x00FF0000, range = 300, duration = 600000, icon = "cyanPoint"},
	{ name = "CaitlynTrap", objectType = "traps", spellName = "CaitlynYordleTrap", color = 0x00FF0000, range = 300, duration = 240000, icon = "cyanPoint"},
	{ name = "Nidalee_Spear", objectType = "traps", spellName = "Nidalee_Spear", color = 0x00FF0000, range = 300, duration = 240000, icon = "cyanPoint"},
}
hiddenObjects.icons = {
	cyanPoint = { spriteFile = "PingMarkerCyan_8", }, 
	redPoint = { spriteFile = "PingMarkerRed_8", }, 
	greenPoint = { spriteFile = "PingMarkerGreen_8", }, 
	yellowPoint = { spriteFile = "PingMarkerYellow_8", },
	greyPoint = { spriteFile = "PingMarkerGrey_8", },
}

hiddenObjects.objects = {}
hiddenObjects.tmpObjects = {}
hiddenObjects.shiftKeyPressed = false

--[[      CONFIG      ]]
hiddenObjects.showOnMiniMap = true			-- show objects on minimap
hiddenObjects.useSprites = true				-- show sprite on minimap

--[[      CODE      ]]
if hiddenObjects.showOnMiniMap and miniMap == nil then dofile(LIB_PATH.."minimap.lua") end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function hiddenObjects.returnSprite(file)
	if file_exists(SPRITE_PATH..file) == true then
		return createSprite(file)
	end
	PrintChat(file.." not found (sprites installed ?)")
	return createSprite("empty.dds")
end

function hiddenObjects.addObject(objectToAdd, x, y, z, fromSpell, object)
	-- add the object
	local objId = objectToAdd.objectType..(math.floor(x) + math.floor(z))
	local tick = GetTickCount()
	if hiddenObjects.objects[objId] == nil then
		hiddenObjects.objects[objId] = {
			object = object,
			color = objectToAdd.color,
			range = objectToAdd.range,
			icon = objectToAdd.icon,
			objectType = objectToAdd.objectType,
			pos = {x = x, y = y, z = z, },
			seenTick = tick,
			endTick = tick + objectToAdd.duration,
			visible = (object == nil),
		}
		if hiddenObjects.showOnMiniMap == true then
			hiddenObjects.objects[objId].minimap = miniMap.ToMinimapPoint(x,z)
		end
	elseif hiddenObjects.objects[objId].object == nil and object ~= nil then
		hiddenObjects.objects[objId].object = object
	end
end

function hiddenObjects.createObjHandler(object)
	if object ~= nil and object.name ~= nil and object.team ~= myHero.team then
		for i,objectToAdd in pairs(hiddenObjects.objectsToAdd) do
			if object.name == objectToAdd.name then
				-- add the object
				hiddenObjects.addObject(objectToAdd, object.x, object.y, object.z, false, (object.team == 0 and object or nil))
			end
        end
	end
end

function hiddenObjects.addProcessSpell(object,spellName,spellLevel, posStart, posEnd)
	if object ~= nil and object.team ~= myHero.team then
		for i,objectToAdd in pairs(hiddenObjects.objectsToAdd) do
			if spellName == objectToAdd.spellName then
				-- add the object
				hiddenObjects.addObject(objectToAdd, posEnd.x, posEnd.y, posEnd.z, true)
			end
		end
	end
end

function hiddenObjects.deleteObjHandler(object)
	if object ~= nil and object.name ~= nil and object.team ~= myHero.team then
		for i,objectToAdd in pairs(hiddenObjects.objectsToAdd) do
			if object.name == objectToAdd.name then
				-- remove the object
				local objId = objectToAdd.objectType..(math.floor(object.x) + math.floor(object.z))
				if objId ~= nil and hiddenObjects.objects[objId] ~= nil then hiddenObjects.objects[objId] = nil end
			end
        end
	end
end

function hiddenObjects.drawHandler()
	for i,obj in pairs(hiddenObjects.objects) do
		if obj.visible == true then
			DrawCircle(obj.pos.x, obj.pos.y, obj.pos.z, 100, obj.color)
			if hiddenObjects.shiftKeyPressed then
				DrawCircle(obj.pos.x, obj.pos.y, obj.pos.z, obj.range, obj.color)
			else
				DrawCircle(obj.pos.x, obj.pos.y, obj.pos.z, 200, obj.color)
			end
			--minimap
			if hiddenObjects.showOnMiniMap == true then
				if hiddenObjects.useSprites then
					hiddenObjects.icons[obj.icon].sprite:Draw(obj.minimap.x, obj.minimap.y, 0xFF)
				else
					DrawText("o",31,obj.minimap.x-7,obj.minimap.y-13,obj.color)
				end
			end
		end
	end
end

function hiddenObjects.tickHandler()
	local tick = GetTickCount()
	for i,obj in pairs(hiddenObjects.objects) do
		if obj.object == nil or (obj.object ~= nil and obj.object.team ~= 0 and obj.object.team ~= myHero.team) then
			obj.visible = true
		end
		if tick > obj.endTick or (obj.object ~= nil and obj.object.team == myHero.team) then
			hiddenObjects.objects[i] = nil
		end
	end
end

function hiddenObjects.msgHandler(msg, key)
	if key == 16 then hiddenObjects.shiftKeyPressed = (msg == KEY_DOWN) end
end

if hiddenObjects.showOnMiniMap and hiddenObjects.useSprites then
	for i,icon in pairs(hiddenObjects.icons) do
		hiddenObjects.icons[i].sprite = hiddenObjects.returnSprite(icon.spriteFile..".dds")
	end
end

for i = 1, objManager.maxObjects, 1 do
	local object = objManager:getObject(i)
	if object ~= nil then 
		hiddenObjects.createObjHandler(object)
	end
end

BoL:addDrawHandler(hiddenObjects.drawHandler)
BoL:addProcessSpellHandler(hiddenObjects.addProcessSpell)
BoL:addCreateObjHandler(hiddenObjects.createObjHandler)
BoL:addTickHandler(hiddenObjects.tickHandler, 250)
BoL:addMsgHandler(hiddenObjects.msgHandler)
