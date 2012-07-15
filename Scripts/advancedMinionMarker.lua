--[[
  ADVANCED MINION MARKER v2.1
  Displays a circle for all minions, which can be killed with an auto attack
  Written by heist
  CREDITS: Zynox (MinionMarker v1.1)

  Changelog:
    v1.0
      Initial Release
    v1.0.1
      Added support for Fizz
    v1.1
      Removed hotkey support
      Added support for chat commands (/amm)
    v1.2
      Add support for abilities
        Added Vladimir's Q
        Added Irelia's Q
      Added support for neutral monsters (AKA jungle creeps)
    v1.2.1
      Added support for Teemo
    v1.2.2
      Added support for Rumble's Overheat
      Fixed target selection so minion spells aren't considered minions themselves
    v1.3
      Added player range circles -
        can be toggled on and off within game
          defaults are found at the top of the file
        the range on one circle can be set within game
      Added support for Annie's Q
      Added support for Gangplank's Q
      Added support for Karthus' Q -
        replaced the normal mark with the multi-target damage
        use the ability mark for the single-target damage
      Added support for Kassadin's Q and W
      Added support for Katarina's Q and W passive
      Added support for Kennen's W passive
      Added support for Ryze's Q
      Added support for Shen's passive and Q
      Added support for Sion's W
      Added support for Veigar's Q
      Added support for Zigg's passive
      Added default ability ranges for
        Annie's Q, Gangplank's Q, Irelia's Q, Karthus' Q, Kassadin's Q,
        Katarina's Q, Ryze's Q, Shen's Q, Sion's W, Veigar's Q, Vladimir's Q
    v2.0
      Moved the damage calculations to a new library -- Advanced Damage Library
      Script requires this library (dam.lua) to be in the libs folder
      Temporarily removed support for player range circles
    v2.1
      Add support for Color Library
      Made marker red
      Made ability marker blue
      Changed thickness and how thickness is handled
      Changed default radii
	  
	  Modified by Mariopart for BoL

  Todo List:
    Re-add support for player range circles
    Expand support to Color Library to make use of gradient scales
--]]

function altDoFile(name)
    dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)
end

altDoFile("libs/dam.lua")
altDoFile("libs/color.lua")

player = GetMyHero()
range = 1200 -- range of minions near player
circleRadius = 70 -- radius of circles on minions
abilitycircleRadius = 70 -- radius of circles on minions for ability last hitting
thickness = 32 -- thickness of circle
abilitythickness = 16 -- thickness of ability circle
circlecolor = Color(255,255,0,0)
abilitycirclecolor = Color(255,0,100,255)

minionTable, abilityminionTable = {}, {}

prefs = {
  use_masteries = true,
  butcherpoints = 0,
  havocpoints = 0,
  use_executioner = false
}

function Timer()
local tick = GetTickCount()
  minionTable, abilityminionTable = {}, {}
  if player.dead then return end
  local count = objManager.maxObjects
  for i = 0, count - 1 do
    local object, dmg, abilitydmg = objManager:getObject(i), 0, 0
    if object and (object.team == TEAM_ENEMY or object.team == TEAM_NEUTRAL) and object.type == "obj_AI_Minion" and object.dead == false then
      if player:GetDistance(object) < range then
        if tick ~= lasttick then
          lasttick = tick
          DamageLibrary:Damage(prefs)
        end
        dmg = DamageLibrary:CalcDamage(object)
        if object.health <= dmg.damage then
          table.insert(minionTable, object )
        elseif dmg.abilitydamage > 0 and object.health <= dmg.abilitydamage then
          table.insert(abilityminionTable, object)
        end
      end
    end
  end
end

function Drawer()
  if player.dead then return end
  for i, object in ipairs(minionTable) do
    if object.valid and object.visible and object.dead == false then
      for j = 0, thickness do
        DrawCircle(object.x, object.y, object.z, circleRadius + j*0.25, circlecolor.hex)
      end
    end
  end
  for i, object in ipairs(abilityminionTable) do
    if object.valid and object.dead == false then
      for j = 0, abilitythickness do
        DrawCircle(object.x, object.y, object.z, abilitycircleRadius + j*0.25, abilitycirclecolor.hex)
      end
    end
  end
end

function Chat(text)
  w = {}
  string.gsub(text, "(%S+)", function(x) table.insert(w,string.lower(x)) end)
  if w[1] == "/amm" or w[1] == "/h/amm" then
    if w[2] == "butcher" or w[2] == "butch" or w[2] == "b" then
      if w[3] == "0" or w[3] == "1" or w[3] == "2" then
        PrintChat(string.format("[AMM] Butcher %sset to %s", w[3] == tostring(prefs.butcherpoints) and "already " or "", w[3]))
        prefs.butcherpoints = tonumber(w[3])
      elseif w[3] then
        PrintChat("[AMM] Invalid command.")
      else
        PrintChat(string.format("[AMM] Butcher: %i", prefs.butcherpoints))
      end
    elseif w[2] == "havoc" or w[2] == "havok" or w[2] == "h" then
      if w[3] == "0" or w[3] == "1" or w[3] == "2" or w[3] == "3" then
        PrintChat(string.format("[AMM] Havoc %sset to %s", w[3] == tostring(prefs.havocpoints) and "already " or "", w[3]))
        prefs.havocpoints = tonumber(w[3])
      elseif w[3] then
        PrintChat("[AMM] Invalid command")
      else
        PrintChat(string.format("[AMM] Havoc: %i", prefs.havocpoints))
      end
    elseif w[2] == "executioner" or w[2] == "execute" or w[2] == "e" then
      if w[3] == "true" or w[3] == "enable" or w[3] == "on" or w[3] == "1" then
        PrintChat(string.format("[AMM] Executioner %senabled", prefs.use_executioner and "already " or ""))
        prefs.use_executioner = true
      elseif w[3] == "false" or w[3] == "disable" or w[3] == "off" or w[3] == "0" then
        PrintChat(string.format("[AMM] Executioner %sdisabled", prefs.use_executioner and "" or "already "))
        prefs.use_executioner = false
      elseif w[3] then
        PrintChat("[AMM] Invalid command")
      elseif prefs.use_executioner then
        PrintChat("[AMM] Executioner: Enabled")
      else
        PrintChat("[AMM] Executioner: Disabled")
      end
    elseif w[2] == "help" then
      PrintChat("[AMM] Advanced Minion Marker doesn't have access to what masteries you are using. To tell it what masteries you are using use the following syntax:")
      PrintChat(" /amm [option] [value]")
      PrintChat(" /amm [value1] [value2] [value3]")
      PrintChat("  Options [values]:")
      PrintChat("   butcher or b [0-2]")
      PrintChat("   havoc or h [0-3]")
      PrintChat("   executioner or e [enable/on/off/disable/0/1]")
    elseif w[2] then
      PrintChat("[AMM] Invalid command")
    else
      PrintChat(string.format("[AMM] Butcher: %i Havoc: %i Executioner: %s (type \"/amm help\" for help)", prefs.butcherpoints, prefs.havocpoints, prefs.use_executioner and "Enabled" or "Disabled"))
    end
    return ""
  end
end

thickness = math.max(thickness,1)
abilitythickness = math.max(abilitythickness,1)
BoL:addDrawHandler(Drawer)
BoL:addChatHandler(Chat)
BoL:addTickHandler(Timer, 20)
PrintChat("AdvancedMinionMarker Script loaded!")