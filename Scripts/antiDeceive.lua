--Anti Deceive. Made by Barasia283. Shows the location where Shaco Deceived to, if you/ally saw him Deceive. Dont be fooled by Shaco again!
lastdeceive = 0
deceive = 0
player = GetMyHero()

function Spell(from,name,level,posStart,posEnd)
    		if from ~= nil and from.charName == "Shaco" and from.team ~= player.team and name == "Deceive" then
				deceive = 1
				lastdeceive = os.clock()
				if math.floor(math.sqrt((posEnd.x-posStart.x)^2 + (posEnd.z-posStart.z)^2)) <500 then
					deceivex = posEnd.x
					deceivey = posEnd.y
					deceivez = posEnd.z
				end
				if math.floor(math.sqrt((posEnd.x-posStart.x)^2 + (posEnd.z-posStart.z)^2)) >500 then
					deceivex = posStart.x + 500/(math.floor(math.sqrt((posEnd.x-posStart.x)^2 + (posEnd.z-posStart.z)^2)))*(posEnd.x-posStart.x)
					deceivez = posStart.z + 500/(math.floor(math.sqrt((posEnd.x-posStart.x)^2 + (posEnd.z-posStart.z)^2)))*(posEnd.z-posStart.z)
					deceivey = posEnd.y
				end 
				PrintChat("Shaco Deceived!")
				--PingSignal(1,deceivex,deceivey,deceivez,1)
    		end
end
 
function Drawer()
	if deceive == 1 then
		DrawCircle(deceivex, deceivey, deceivez, 100, 0x0000FFFF)
	end
end

function Timer(tick)
	if (deceive == 0) then
        return
    end
    if os.clock() > (lastdeceive + 3.5) then
        deceive = 0
    end
end


BoL:addDrawHandler(Drawer) --drawHandler()
BoL:addTickHandler(Timer,500)
BoL:addProcessSpellHandler(Spell); --processSpellHandler(from,name,level,posStart,posEnd)