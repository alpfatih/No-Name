--[[
        Script: Kilua_UI v1.3
		Author: Kilua
		
		required libs : 		minimap
		exposed variables : 	ui, math.round, math.tronc, file_exists
		
		UPDATES :
		v1.2					initial release
		v1.3					added support for minimap hack / reworked
]]

if SCRIPT_PATH == nil then SCRIPT_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2) end
if LIB_PATH == nil then LIB_PATH = SCRIPT_PATH.."Libs/" end
if SPRITE_PATH == nil then SPRITE_PATH = SCRIPT_PATH:gsub("\\", "/"):gsub("/Scripts", "").."Sprites/" end
if myHero == nil then myHero = GetMyHero() end

ui = {}

--[[      CONFIG      ]]
ui.minimapHack = true

--[[      GLOBAL      ]]
ui.configFile = LIB_PATH.."ui.cfg"
ui.ennemyHero = {}
ui.herosSprite = {}
ui.summonerSprite = {}
ui.herosMiniMapSprite = {}
ui.shiftKeyPressed = false
ui.spellBot = { {false;false;false;false;false;false} ; {false;false;false;false;false;false} ; {false;false;false;false;false;false} ; {false;false;false;false;false;false} }
ui.spells = {SPELL_1, SPELL_2, SPELL_3, SPELL_4}
ui.summoners = {SUMMONER_1, SUMMONER_2}
ui.display = {}
ui.display.x = 300													-- INIT
ui.display.y = 200
ui.display.move = false

ui.case_gap = 86 --70

--[[      EXTERNAL FUNCTION THAT SHOULD BE IN LIBRARY      ]]
if math.round == nil then
	function math.round(num, idp)
		local idp=idp or 0
		local num = num*10^idp
		local upper=math.ceil(num)
		local lower=upper-1
		if num>0 then
			if num-lower>=0.5 then return upper/10^idp
			else return lower/10^idp end
		else
			if num-lower>0.5 then return upper/10^idp
			else return lower/10^idp end
		end
	end
end

if math.tronc == nil then
	function math.tronc(num, idp)
		return math.ceil(num)-1
	end
end

if file_exists == nil then
	function file_exists(name)
	   local f=io.open(name,"r")
	   if f~=nil then io.close(f) return true else return false end
	end
end

--[[      CODE      ]]
if ui.minimapHack and minimap == nil then dofile(LIB_PATH.."minimap.lua") end

if file_exists(ui.configFile) then dofile(ui.configFile) end

function ui.returnSprite(file)
	if file_exists(SPRITE_PATH..file) == true then
		return createSprite(file)
	end
	PrintChat(file.." not found (sprites installed ?)")
	return createSprite("empty.dds")
end

function ui.writeConfigs()
    local file = io.open(ui.configFile, "w")
    if file then
        local offset1 = ui.display.x
        local offset2 = ui.display.y
        file:write("ui.display.x = "..offset1.."\nui.display.y = "..offset2.."\n")
        file:close()
    end
end

function ui.tickHandler()
	for i = 1, ui.ennemyHeroCount, 1 do
		local hero = ui.ennemyHero[i].hero
		if hero.dead then
			if ui.ennemyHero[i].deathStart == nil then
				ui.ennemyHero[i].deathStart = GetTickCount()
			end
			ui.ennemyHero[i].deathTimer = math.ceil(hero.deathTimer - ((GetTickCount() - ui.ennemyHero[i].deathStart)/1000))
			ui.ennemyHero[i].missTimer = nil
			ui.ennemyHero[i].missStart = nil
		else
			ui.ennemyHero[i].deathTimer = nil
			if not hero.visible then
				if ui.ennemyHero[i].missStart == nil then
					ui.ennemyHero[i].missStart = GetTickCount()
					if ui.minimapHack then
						ui.ennemyHero[i].missMinimap = miniMap.ToMinimapPoint(hero.x,hero.z)
					end
				end
				ui.ennemyHero[i].missTimer = GetTickCount() - ui.ennemyHero[i].missStart
				ui.ennemyHero[i].missTimerText = (string.format("%02d:%02d", math.tronc(ui.ennemyHero[i].missTimer / 60000,0), math.tronc((ui.ennemyHero[i].missTimer % 60000)/1000)))
			else
				ui.ennemyHero[i].missTimer = nil
				ui.ennemyHero[i].missStart = nil
			end
		end
	end
	if ui.display.move == true then
		if ui.display.cursorShift == nil or ui.display.cursorShift.x == nil or ui.display.cursorShift.y == nil then
			ui.display.cursorShift = { x = GetCursorPos().x - ui.display.x, y = GetCursorPos().y - ui.display.y, }
		else
			ui.display.x = GetCursorPos().x - ui.display.cursorShift.x
			ui.display.y = GetCursorPos().y - ui.display.cursorShift.y
		end
	end
end

function ui.msgHandler(msg,keycode)
	if keycode == 16 then ui.shiftKeyPressed = (msg == KEY_DOWN) end
	if ui.shiftKeyPressed and msg == WM_LBUTTONDOWN then
		if ui.display.x <= GetCursorPos().x and ui.display.x+54 >= GetCursorPos().x and GetCursorPos().y >= ui.display.y and GetCursorPos().y <= ui.display.y+62+15+4*ui.case_gap then
			ui.display.move = true
		end
	elseif ui.display.move and msg == WM_LBUTTONUP then
		ui.display.move = false
		ui.writeConfigs()
		ui.display.cursorShift = nil
	end
end

function ui.drawHandler()
	for i = 1, ui.ennemyHeroCount, 1 do
		local hero = ui.ennemyHero[i].hero
		if hero ~= nil then
			ui.herosSprite[hero.charName]:Draw(ui.display.x, ui.display.y+(i-1)*ui.case_gap,0xFF)				-- ICON CHAMPION
			ui.spritecase:Draw(ui.display.x,ui.display.y +(i-1)*ui.case_gap,0xFF)								-- CASE
			if hero.level > 9 then																-- LVL TXT
				DrawText(""..hero.level,17,ui.display.x+40,ui.display.y+(i-1)*ui.case_gap+26,0xFFFF0000)
				--DrawText(""..(hero.isAI and "T" or "F"),17,ui.display.x+40,ui.display.y+(i-1)*ui.case_gap+26,0xFFFF0000)
			elseif hero.level <= 9 then
				DrawText(""..hero.level,17,ui.display.x+45,ui.display.y+(i-1)*ui.case_gap+26,0xFFFF0000)
				--DrawText(""..(hero.isAI and "T" or "F"),17,ui.display.x+40,ui.display.y+(i-1)*ui.case_gap+26,0xFFFF0000)
			end
			
			for j = 1, 2 do																		-- SPELL SUMMONERS
				ui.summonerSprite[ui.ennemyHero[i].summonerSpellName[j]]:Draw(ui.display.x-35,ui.display.y+(i-1)*ui.case_gap+((j-1)*32),0xFF)
				if hero:CanUseSpell(ui.summoners[j]) == COOLDOWN or hero:CanUseSpell(ui.summoners[j]) == NOTLEARNED then
					ui.spritespellblackfilter:Draw(ui.display.x-35,ui.display.y+(i-1)*ui.case_gap+((j-1)*32),0xCF)
				end
			end
			
			for j = 1, 3 do																			-- SPELL STATE
				if hero:CanUseSpell(ui.spells[j]) == READY then
					ui.spriteready:Draw(ui.display.x+(j-1)*16,ui.display.y+64 +(i-1)*ui.case_gap,0xFF)
				elseif hero:CanUseSpell(ui.spells[j]) == COOLDOWN then
					ui.spritecooldown:Draw(ui.display.x+(j-1)*16,ui.display.y+64 +(i-1)*ui.case_gap,0xFF)
					if hero.isAI and ui.ennemyHero[i].spellLearned[j] == false then
						ui.ennemyHero[i].spellLearned[j] = true
					end
				elseif hero:CanUseSpell(ui.spells[j]) == NOTLEARNED then
					if not hero.isAI or (not ui.ennemyHero[i].spellLearned[j] and hero.level < 13) then
						ui.spritenotlearned:Draw(ui.display.x+(j-1)*16,ui.display.y+64 +(i-1)*ui.case_gap,0xFF)
					else
						ui.spriteready:Draw(ui.display.x+(j-1)*16,ui.display.y+64 +(i-1)*ui.case_gap,0xFF)
					end
				end
			end
			
			if hero:CanUseSpell(_R) == READY then												-- ULTI READY
				ui.spriteready:Draw(ui.display.x+3*16,ui.display.y+64 +(i-1)*ui.case_gap,0xFF)
				ui.spriteultiready:Draw(ui.display.x+49,ui.display.y-2 +(i-1)*ui.case_gap,0xFF)
			elseif hero:CanUseSpell(_R) == COOLDOWN then
				ui.spritecooldown:Draw(ui.display.x+3*16,ui.display.y+64 +(i-1)*ui.case_gap,0xFF)
				ui.spriteulticooldown:Draw(ui.display.x+49,ui.display.y-2 +(i-1)*ui.case_gap,0xFF)
			elseif hero:CanUseSpell(_R) == NOTLEARNED then
				if not hero.isAI or hero.level < 6 then
					ui.spritenotlearned:Draw(ui.display.x+3*16,ui.display.y+64 +(i-1)*ui.case_gap,0xFF)
					ui.spriteulticooldown:Draw(ui.display.x+49,ui.display.y-2 +(i-1)*ui.case_gap,0xFF)				
				else
					ui.spriteready:Draw(ui.display.x+3*16,ui.display.y+64 +(i-1)*ui.case_gap,0xFF)
					ui.spriteultiready:Draw(ui.display.x+49,ui.display.y-2 +(i-1)*ui.case_gap,0xFF)				
				end
			end
			
			DrawText("Q",15,ui.display.x+3,ui.display.y+64+(i-1)*ui.case_gap,0xFF000000)
			DrawText("W",15,ui.display.x+2+16,ui.display.y+64+(i-1)*ui.case_gap,0xFF000000)
			DrawText("E",15,ui.display.x+4+2*16,ui.display.y+64+(i-1)*ui.case_gap,0xFF000000)
			DrawText("R",15,ui.display.x+4+3*16,ui.display.y+64+(i-1)*ui.case_gap,0xFF000000)

			
			if not hero.dead then
				-- HEALTH BAR
				ui.spritelifestart:Draw(ui.display.x + 7,ui.display.y+(i-1)*ui.case_gap+ 45,0xFF)
				local nbpartlife = math.round(hero.health*25/hero.maxHealth,0) -1
				for j = 1, nbpartlife, 1 do
					ui.spritelifepart:Draw(ui.display.x+7+2*j,ui.display.y+(i-1)*ui.case_gap+45,0xFF) 		-- 1 part = 4% life
				end
				-- MANA BAR
				if hero.mana > 0 then
					ui.spritemanastart:Draw(ui.display.x+7,ui.display.y+(i-1)*ui.case_gap+55,0xFF)
					local nbpartmana = math.round(hero.mana*25/hero.maxMana,0) -1
					for j = 1, nbpartmana, 1 do
						ui.spritemanapart:Draw(ui.display.x+7+2*j,ui.display.y+(i-1)*ui.case_gap+55,0xFF)	-- 1 part = 4% mana
					end
				end
				-- MOUSE OVERLAY HEALTH
				if ui.display.x-100 <= GetCursorPos().x and ui.display.x+54+80 >= GetCursorPos().x and GetCursorPos().y >= ui.display.y+(i-1)*ui.case_gap and GetCursorPos().y <= ui.display.y+62+15+(i-1)*ui.case_gap then
					DrawText(""..math.round(hero.health,0).."/"..math.round(hero.maxHealth,0),17,ui.display.x + 0,ui.display.y+(i-1)*ui.case_gap+ 47,0xFF00FF00)
				end
				-- MISS TIMER
				if not hero.visible then
					if ui.ennemyHero[i].missTimer ~= nil then
						if ui.minimapHack then
							ui.herosMiniMapSprite[hero.charName]:Draw(ui.ennemyHero[i].missMinimap.x, ui.ennemyHero[i].missMinimap.y,200)
						end
						ui.spritemisstimer:Draw(ui.display.x+4,ui.display.y+27 +(i-1)*ui.case_gap,200)
						DrawText(ui.ennemyHero[i].missTimerText,15,ui.display.x+4,ui.display.y+28+(i-1)*ui.case_gap,0xFF00FF00)
					end
				end
			else
				if not hero.visible then
					ui.spriteblackfilter:Draw(ui.display.x,ui.display.y+(i-1)*ui.case_gap+16,0xAF)				-- DIE AND MISS BLACK ICONS	for spells
				end
				ui.spritedie:Draw(ui.display.x,ui.display.y+(i-1)*ui.case_gap+45,0xFF)
				DrawText("dead",25,ui.display.x+3,ui.display.y+(i-1)*ui.case_gap+48,0xFFFF0000)
				ui.spritedie:Draw(ui.display.x,ui.display.y+(i-1)*ui.case_gap+45,0xAF)
				if ui.ennemyHero[i].deathTimer ~= nil then
					if (ui.ennemyHero[i].deathTimer > 9) then
						DrawText(""..ui.ennemyHero[i].deathTimer,35,ui.display.x+13,ui.display.y+5+(i-1)*ui.case_gap,0xFF00FF00)		-- DEATH TIMER
					elseif ui.ennemyHero[i].deathTimer >= 0 then
						DrawText(""..ui.ennemyHero[i].deathTimer,35,ui.display.x+20,ui.display.y+5+(i-1)*ui.case_gap,0xFF00FF00)
					end
				else
					DrawText("?",35,ui.display.x+20,ui.display.y+5+(i-1)*ui.case_gap,0xFF00FF00)
				end
			end
		end
	end
end

ui.ennemyHeroCount = 0
for i = 1, heroManager.iCount, 1 do
	local hero = heroManager:getHero(i) 
    if hero ~= nil and hero.team ~= myHero.team then 
		ui.ennemyHeroCount = ui.ennemyHeroCount + 1
		ui.ennemyHero[ui.ennemyHeroCount] = {}
		ui.ennemyHero[ui.ennemyHeroCount].hero = hero
		if hero.isAI then
			ui.ennemyHero[ui.ennemyHeroCount].spellLearned = {false, false, false, false}
		end
		ui.herosSprite[hero.charName] = ui.returnSprite("UI_"..hero.charName..".png")
		if ui.minimapHack then
			ui.herosMiniMapSprite[hero.charName] = ui.returnSprite("BTN"..hero.charName..".png")
		end
	
		-- SPELL SUMMONERS SPRITES
		ui.ennemyHero[ui.ennemyHeroCount].summonerSpellName = {}
		for j = 1, 2 do
			local summonerSpellName = hero:GetSpellData(ui.summoners[j]).name
			ui.ennemyHero[ui.ennemyHeroCount].summonerSpellName[j] = summonerSpellName
			if ui.summonerSprite[summonerSpellName] == nil then
				ui.summonerSprite[summonerSpellName] = ui.returnSprite("UI_"..summonerSpellName..".png")
			end
		end
    end
end

ui.spritelifestart = ui.returnSprite("UI_life_start.png")
ui.spritelifepart = ui.returnSprite("UI_life_part.png")
ui.spritemanastart = ui.returnSprite("UI_mana_start.png")
ui.spritemanapart = ui.returnSprite("UI_mana_part.png")
ui.spritecase = ui.returnSprite("UI_case_original.png")
ui.spriteultiready = ui.returnSprite("UI_Ulti_READY.png")
ui.spriteulticooldown = ui.returnSprite("UI_Ulti_COOLDOWN.png")
ui.spritecooldown = ui.returnSprite("UI_COOLDOWN.png")
ui.spriteready = ui.returnSprite("UI_READY.png")
ui.spritenotlearned = ui.returnSprite("UI_NOTLEARNED.png")
ui.spriteblackfilter = ui.returnSprite("UI_black_filter.png")
ui.spritemisstimer = ui.returnSprite("UI_MissTimer.png")
ui.spritedie = ui.returnSprite("UI_DIE.png")
ui.spritespellblackfilter = ui.returnSprite("UI_game_spell_black_filter.png")

BoL:addTickHandler(ui.tickHandler, 100)
BoL:addMsgHandler(ui.msgHandler)
BoL:addDrawHandler(ui.drawHandler)

