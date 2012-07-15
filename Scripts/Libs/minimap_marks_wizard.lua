--[[
    MiniMap Marks Wizard
    v1.1
    Written by Weee
	Port by Kilua
	
    Should be started in classic 5v5.
]]


LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)
unloadscript = false

--[[      Code      ]]
dofile(LIB_PATH.."anim.lua")

de = DrawingEngine()
ds = DrawingSets()

offsetPoints = {
    topLeft  = { x = 300, y = 200, color = {255,0,255,255}, LMBHold = false },     --purple
    botRight = { x = 300, y = 225, color = {255,0,0,255}, LMBHold = false },     --red
}

shiftHold = false
mouse2D = { x = 0, y = 0 }
CONFIG_PATH = LIB_PATH.."minimap_marks.cfg"

for i,pt in pairs(offsetPoints) do
    ds:Add("offsetPoint_"..i, DrawingText("o",31,pt.x-3,pt.y-9,0,0,0,255), DrawingText("w",14,pt.x,pt.y,pt.color[1],pt.color[2],pt.color[3],pt.color[4]))
end


-- Returns distances between 2 objects. If it has Z coord than it will use X,Z if not - then X,Y.
function GetDistance2D( o1, o2 )
    if o1.z == nil or o2.z == nil then return math.sqrt( math.pow(o1.x - o2.x, 2) + math.pow(o1.y - o2.y, 2) ) end
    return math.sqrt( math.pow(o1.x - o2.x, 2) + math.pow(o1.z - o2.z, 2) )
end

function writeConfig(path)
    local file = io.open(path, "w")
    if file then
        local offset1 = offsetPoints.topLeft.x
        local offset2 = offsetPoints.topLeft.y
        local offset3 = offsetPoints.botRight.x
        local offset4 = offsetPoints.botRight.y
        file:write("minimapOffsets = { "..offset1..", "..offset2..", "..offset3..", "..offset4.." }")
        file:close()
    end
    return file ~= nil
end

--function Timer(tick)
function Timer()
	if unloadscript == false then
		de:ComputeAnimations(ds)
		PingSignal(PING_FALLBACK,-538,0,14439,0)  -- top left corner
		PingSignal(PING_FALLBACK,14007,0,-165,0)  -- bottom right corner
	end
end

function Drawer()
	if unloadscript == false then
		mouse2D.x = GetCursorPos().x
		mouse2D.y = GetCursorPos().y
	
		for i,pt in pairs(offsetPoints) do
			if shiftHold and pt.LMBHold then
				ds["offsetPoint_"..i].objects[1].position.x, ds["offsetPoint_"..i].objects[2].position.x, pt.x = mouse2D.x-10, mouse2D.x-10+3, mouse2D.x
				ds["offsetPoint_"..i].objects[1].position.y, ds["offsetPoint_"..i].objects[2].position.y, pt.y = mouse2D.y-10, mouse2D.y-10+9, mouse2D.y
				break
			end
		end

		de:Draw(ds)
		DrawText("Top Left:",14,300 - 50,200,0xFF80FF00)
		DrawText("Bottom Right:",14,300 - 80,225,0xFF80FF00)
	
		DrawText("Minimap Marks Wizard Setup v1.0",17,350,170,0xFF80FF00)
		DrawText("by Weee and port by Kilua",13,500,185,0xFF80FF00)
		DrawText("Instructions:",17,350,200,0xFF80FF00)
		DrawText("These colored marks (w) are movable. Hold shift and left mouse button to move it.",17,350,215,0xFF80FF00)
		DrawText("Right now two corners on your minimap are pinged with yellow circles.",17,350,230,0xFF80FF00)
		DrawText("You have to move each (w) to it's own corner:",17,350,245,0xFF80FF00)
		DrawText("Try to be as accurate as you can! Each mark must be in the center of it's own ping-circle!",17,350,275,0xFF80FF00)
		DrawText("More accurate you are - more accurate marks in other scripts you'll get.",17,350,290,0xFF80FF00)
		DrawText("Type .done (don't forget the dot) in chat when you're done!",17,350,310,0xFF80FF00)
	end
end

function HotKey(msg,keycode)
	if unloadscript == false then
		if keycode == 16 then if msg == KEY_DOWN then if not shiftHold then shiftHold = true end else shiftHold = false end end
	
		if msg ~= WM_LBUTTONDOWN and msg ~= WM_LBUTTONUP then return end
		for i,pt in pairs(offsetPoints) do
			if msg == WM_LBUTTONDOWN then
				if shiftHold then
					if GetDistance2D(mouse2D,pt) <= 20 then
						if not pt.LMBHold then pt.LMBHold = true end
					else
						pt.LMBHold = false
					end
				else
					pt.LMBHold = false
				end
		elseif msg == WM_LBUTTONUP then
				pt.LMBHold = false
			end
		end
	end
end

function ChatCommand(text)
	if unloadscript == false then
		if text == ".done" then
			BlockChat()
			PrintChat(" >> MiniMap Marks Wizard Setup: Config saved. Bye-bye! Thanks for using!")
			writeConfig(CONFIG_PATH)
			LoadScript = false
			unloadscript = true
			
		end
	end
end

BoL:addTickHandler(Timer,1300)
BoL:addDrawHandler(Drawer)
BoL:addMsgHandler(HotKey)
BoL:addChatHandler(ChatCommand)
PrintChat(" >> MiniMap Marks Wizard Setup: Hai! Follow the steps printed on your screen.")