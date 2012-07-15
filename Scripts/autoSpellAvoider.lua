--[[
	autoSpellAvoider v0.1
	Author: barasia283
]]

-- for those who not use loader.lua
if LIB_PATH == nil then LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2).."Libs\\" end

if spellAvoider == nil then dofile(LIB_PATH.."spellAvoider.lua") end
if spellAvoider ~= nil then
	--[[         Config        ]]
	spellAvoider.globalspacing = 250														-- default spacing between circle in line
	spellAvoider.colors = {0x0000FFFF, 0x0000FFFF, 0xFFFFFF00, 0x0000FFFF, 0xFF00FF00}		-- color for skill type (indexed)
	spellAvoider.dodgeSkillShot = false														-- default autoDodge (true/false)
	spellAvoider.drawSkillShot = true														-- default draw Skill (true/false)
	spellAvoider.dodgeSkillShotHK = 74 														-- autoDodge toogle key (jJj by default)
	
	--[[         Code          ]]
	function spellAvoider.chatHandler(text) 
		 if text == ".addspacing" then
			BlockChat()
			spellAvoider.setGlobalspacing(true)
		 elseif text == ".minusspacing" then
			BlockChat()
			spellAvoider.setGlobalspacing(false)
		elseif text == ".dodgeon" then
			BlockChat()
			spellAvoider.setDodgeSkillShot(true)
		elseif text == ".dodgeoff" then
			BlockChat()
			spellAvoider.setDodgeSkillShot(false)
		elseif text == ".drawon" then
			BlockChat()
			spellAvoider.setDrawSkillShot(true)
		elseif text == ".drawoff" then
			BlockChat()
			spellAvoider.setDrawSkillShot(false)
		end
	end
	
	function spellAvoider.setGlobalspacing(up)
		local value = (up and 50 or -50)
		spellAvoider.globalspacing = spellAvoider.globalspacing + value
		if not up and spellAvoider.globalspacing < 100 then
			spellAvoider.globalspacing = 100
		end
		PrintChat("Skillshot Spacing : "..spellAvoider.globalspacing)
	end
	
	function spellAvoider.setDodgeSkillShot(value)
		if spellAvoider.dodgeSkillShot ~= value then
			spellAvoider.dodgeSkillShot = value
			PrintChat("AutoDodge "..(spellAvoider.dodgeSkillShot and "ON" or "OFF").." !")
		end
	end
	
	function spellAvoider.setDrawSkillShot(value)
		if spellAvoider.drawSkillShot ~= value then
			spellAvoider.drawSkillShot = value
			PrintChat("Draw Skillshot "..(spellAvoider.drawSkillShot and "ON" or "OFF").." !")
		end
	end
	
	function spellAvoider.msgHandler( msg, keycode )
		if keycode == spellAvoider.dodgeSkillShotHK and msg == KEY_UP then -- J
			spellAvoider.setDodgeSkillShot(not spellAvoider.dodgeSkillShot)
		end
	end
	
    PrintChat("AntiSkillshot! type '.addspacing' or '.minusspacing' to change spacing. type '.dodgeon' or '.dodgeoff' to toggle autododge. type '.drawon' or '.drawoff' to toggle drawing skillshots")

	BoL:addChatHandler(spellAvoider.chatHandler) 				--chatHandler(text)
	BoL:addDrawHandler(spellAvoider.drawHandler)
	BoL:addProcessSpellHandler(spellAvoider.addProcessSpell)
	BoL:addTickHandler(spellAvoider.tickHandler, 250)
	BoL:addMsgHandler(spellAvoider.msgHandler)					--msgHandler(msg,wParam)
else
	PrintChat("No Skillshot Character!")
end

