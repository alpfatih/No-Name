--[[
    » Auto Buy Items

]]
--[[Config]]

if myHero == nil then myHero = GetMyHero() end
if LIB_PATH == nil then LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2) end
if SCRIPT_PATH == nil then SCRIPT_PATH = LIB_PATH:gsub("\\", "/"):gsub("/libs", "") end
if SPRITE_PATH == nil then SPRITE_PATH = SCRIPT_PATH:gsub("\\", "/"):gsub("/Scripts", "").."Sprites/" end

--Delay to prevent detection through SpectatorMode
StartBuyTime = 4 --in seconds (set to 0 to disable) | wasn't fixed yet.
MinDelay = 0.6 --in seconds
MaxDelay = 1.2 --in seconds

datDelay = 100 -- function OnTick() delay

--Hotkey
Draw = true
DisableHotkey = 122 --"F11" To disable Overlay; Shift-F11 to Unload the script

--Minimal Frames per Second. If below, it will not update or buy. To Disable set MinFPS -1
MinFPS = 25

--WindowCoordinates
PositionX1 = 59
PositionY1 = 113

DebugMode = false

--[[Globals]]

FramesPerSecond = 0
nextTick = 0

--Tables and Values for PreCalculation
PreInventory = { 0, 0, 0, 0, 0, 0, }
PreInventoryCount = { 0, 0, 0, 0, 0, 0, }
PreItemList1 = {}
PreGold = 0

--Tables and Values for current State
Inventory = { 0, 0, 0, 0, 0, 0, }
InventoryCount = { 0, 0, 0, 0, 0, 0, }

--Calculated and drawn Tables
ItemsToBuy = {}
ItemsToSell = {}
NextItem = nil
NextItemPrice = nil

--User defined Item Lists -> function getItemList()
ItemList1 = {3027,3152,3069,3089,3116,}
ItemList2 = {}
ItemList3 = {}

LastTime = 128005875
LastChamp = "Soraka" -- If it's the same champion you played, you have to manually set it to "None". I know, I know...WORKING ON IT.

-----------------------------------------

ItemDB = {  --[Item Code] = {"Item Name", item price, {item recipe items}, },
    [3001] = { "Abyssal Scepter", 1050, { 1026, 1057, }, },
    [3105] = { "Aegis of the Legion", 750, { 1028, 1033, 1029, }, },
    [1052] = { "Amplifying Tome", 435, {}, },
    [3003] = { "Archangel's Staff", 1000, { 3070, 1026, }, },
    [3174] = { "Athene's Unholy Grail", 500, { 3108, 1052, 3028, }, },
    [3005] = { "Atma's Impaler", 825, { 1031, 1018, }, },
    [3198] = { "Augment: Death", 1000, { 3200, }, },
    [3197] = { "Augment: Gravity", 1000, { 3200, }, },
    [3196] = { "Augment: Power", 1000, { 3200, }, },
    [3093] = { "Avarice Blade", 350, { 1051, }, },
    [1038] = { "B. F. Sword", 1650, {}, },
    [3102] = { "Banshee's Veil", 650, { 1057, 3010, }, },
    [3006] = { "Berserker's Greaves", 150, { 1001, 1042, }, },
    [3144] = { "Bilgewater Cutlass", 400, { 1037, 1053, }, },
    [1026] = { "Blasting Wand", 860, {}, },
    [3117] = { "Boots of Mobility", 650, { 1001, }, },
    [1001] = { "Boots of Speed", 350, {}, },
    [3009] = { "Boots of Swiftness", 650, { 1001, }, },
    [3166] = { "Bonetooth Necklace", 800, {}, },
    [1051] = { "Brawler's Gloves", 400, {}, },
    [3010] = { "Catalyst the Protector", 450, { 1028, 1027, }, },
    [1031] = { "Chain Vest", 700, {}, },
    [3028] = { "Chalice of Harmony", 100, { 1005, 1033, }, },
    [3172] = { "Cloak and Dagger", 200, { 1018, 1042, }, },
    [1018] = { "Cloak of Agility", 830, {}, },
    [1029] = { "Cloth Armor", 300, {}, },
    [1042] = { "Dagger", 420, {}, },
    [3128] = { "Deathfire Grasp", 975, { 3098, 1026, }, },
    [1055] = { "Doran's Blade", 475, {}, },
    [1056] = { "Doran's Ring", 475, {}, },
    [1054] = { "Doran's Shield", 475, {}, },
    [3173] = { "Eleisa's Miracle", 500, { 3096, }, },
    [2038] = { "Elixir of Agility", 250, {}, },
    [2039] = { "Elixir of Brilliance", 250, {}, },
    [2037] = { "Elixir of Fortitude", 250, {}, },
    [3097] = { "Emblem of Valor", 350, { 1029, 1006, }, },
    [3184] = { "Entropy", 600, { 3044, 1038, }, },
    [3123] = { "Executioner's Calling", 500, { 1051, 1053, }, },
    [1004] = { "Faerie Charm", 180, {}, },
    [3108] = { "Fiendish Codex", 300, { 1005, 1052, }, },
    [3109] = { "Force of Nature", 1000, { 1007, 1007, 1057, }, },
    [3110] = { "Frozen Heart", 650, { 1029, 1029, 3024, }, },
    [3022] = { "Frozen Mallet", 825, { 3044, 1011, }, },
    [1011] = { "Giant's Belt", 1110, {}, },
    [3024] = { "Glacial Shroud", 425, { 1027, 1031, }, },
    [3026] = { "Guardian Angel", 1200, { 1033, 1029, 1031, }, },
    [3124] = { "Guinsoo's Rageblade", 400, { 1026, 1037, }, },
    [3136] = { "Haunting Guise", 575, { 1028, 1052, }, },
    [2003] = { "Health Potion", 35, {}, },
    [3132] = { "Heart of Gold", 350, { 1028, }, },
    [3155] = { "Hexdrinker", 585, { 1036, 1033, }, },
    [3146] = { "Hextech Gunblade", 600, { 3144, 3145, }, },
    [3145] = { "Hextech Revolver", 330, { 1052, 1052, }, },
    [3187] = { "Hextech Sweeper", 150, { 1052, 1052, 3067, }, },
    [3031] = { "Infinity Edge", 375, { 1038, 1037, 1018, }, },
    [3158] = { "Ionian Boots of Lucidity", 700, { 1001, }, },
    [3178] = { "Ionic Spark", 775, { 1043, 1028, }, },
    [3098] = { "Kage's Lucky Pick", 330, { 1052, }, },
    [3067] = { "Kindlegem", 375, { 1028, }, },
    [3186] = { "Kitae's Bloodrazor", 700, { 1037, 1043, }, },
    [3035] = { "Last Whisper", 900, { 1037, 1036, }, },
    [3138] = { "Leviathan", 800, { 1028, }, },
    [3100] = { "Lich Bane", 950, { 1033, 3057, 1026, }, },
    [3190] = { "Locket of the Iron Solari", 500, { 3132, 3097, }, },
    [1036] = { "Long Sword", 415, {}, },
    [3126] = { "Madred's Bloodrazor", 775, { 3106, 1037, 1043, }, },
    [3106] = { "Madred's Razors", 285, { 1029, 1036, }, },
    [3114] = { "Malady", 550, { 1042, 1042, 1052, }, },
    [3037] = { "Mana Manipulator", 115, { 1004, 1004, }, },
    [2004] = { "Mana Potion", 40, {}, },
    [3004] = { "Manamune", 700, { 3070, 1036, }, },
    [3156] = { "Maw of Malmortius", 925, { 3155, 1037, }, },
    [3041] = { "Mejai's Soulstealer", 800, { 1052, }, },
    [1005] = { "Meki Pendant", 390, {}, },
    [3111] = { "Mercury's Treads", 450, { 1001, 1033, }, },
    [3170] = { "Moonflair Spellblade", 340, { 1026, }, },
    [3165] = { "Morello's Evil Tome", 440, { 3098, 3108, }, },
    [3115] = { "Nashor's Tooth", 400, { 3101, 3108, }, },
    [1058] = { "Needlessly Large Rod", 1600, {}, },
    [1057] = { "Negatron Cloak", 740, {}, },
    [3047] = { "Ninja Tabi", 200, { 1001, 1029, }, },
    [1033] = { "Null-Magic Mantle", 400, {}, },
    [3180] = { "Odyn's Veil", 650, { 1057, 3010, }, },
    [2042] = { "Oracle's Elixir", 400, {}, },
    [2047] = { "Oracle's Extract", 250, {}, },
    [3044] = { "Phage", 425, { 1028, 1036, }, },
    [3046] = { "Phantom Dancer", 400, { 1018, 3086, 1042, }, },
    [3096] = { "Philosopher's Stone", 185, { 1004, 1007, }, },
    [1037] = { "Pickaxe", 975, {}, },
    [1062] = { "Prospector's Blade", 950, {}, },
    [1063] = { "Prospector's Ring", 950, {}, },
    [3140] = { "Quicksilver Sash", 700, { 1057, }, },
    [3089] = { "Rabadon's Deathcap", 1140, { 1026, 1058, }, },
    [3143] = { "Randuin's Omen", 600, { 3132, 3082, 1029, }, },
    [1043] = { "Recurve Bow", 1050, {}, },
    [1007] = { "Regrowth Pendant", 435, {}, },
    [1006] = { "Rejuvenation Bead", 250, {}, },
    [3027] = { "Rod of Ages", 850, { 3010, 1026, }, },
    [1028] = { "Ruby Crystal", 475, {}, },
    [3116] = { "Rylai's Crystal Scepter", 700, { 1026, 1052, 1011, }, },
    [3181] = { "Sanguine Blade", 800, { 1038, 1053, }, },
    [1027] = { "Sapphire Crystal", 400, {}, },
    [3057] = { "Sheen", 425, { 1027, 1052, }, },
    [3069] = { "Shurelya's Reverie", 550, { 3067, 3096, }, },
    [2044] = { "Sight Ward", 75, {}, },
    [3020] = { "Sorcerer's Shoes", 750, { 1001, }, },
    [3099] = { "Soul Shroud", 485, { 3067, 1028, 3037, }, },
    [3065] = { "Spirit Visage", 300, { 3067, 1033, }, },
    [3101] = { "Stinger", 250, { 1042, 1042, }, },
    [3068] = { "Sunfire Cape", 800, { 1031, 1011, }, },
    [3141] = { "Sword of the Occult", 954, { 1036, }, },
    [3070] = { "Tear of the Goddess", 205, { 1027, 1005, }, },
    [3071] = { "The Black Cleaver", 795, { 1038, 1042, }, },
    [3072] = { "The Bloodthirster", 900, { 1038, 1053, }, },
    [3134] = { "The Brutalizer", 507, { 1036, 1036, }, },
    [3200] = { "The Hex Core", 0, {}, },
    [3185] = { "The Lightbringer", 285, { 1043, 1036, }, },
    [3075] = { "Thornmail", 1000, { 1029, 1031, }, },
    [3077] = { "Tiamat", 250, { 1037, 1036, 1004, 1006, }, },
    [3078] = { "Trinity Force", 300, { 3086, 3057, 3044, }, },
    [1053] = { "Vampiric Scepter", 450, {}, },
    [2043] = { "Vision Ward", 125, {}, },
    [3135] = { "Void Staff", 1000, { 1026, 1052, }, },
    [3082] = { "Warden's Mail", 400, { 1031, 1006, }, },
    [3083] = { "Warmog's Armor", 980, { 1011, 1028, 1007, }, },
    [3152] = { "Will of the Ancients", 440, { 1026, 3145, }, },
    [3091] = { "Wit's End", 700, { 1043, 1033, }, },
    [3154] = { "Wriggle's Lantern", 150, { 1053, 3106, }, },
    [3142] = { "Youmuu's Ghostblade", 600, { 3093, 3134, }, },
    [3086] = { "Zeal", 375, { 1051, 1042, }, },
    [3050] = { "Zeke's Herald", 425, { 3067, 1042, 1053, }, },
    [3157] = { "Zhonya's Hourglass", 800, { 1031, 1058, }, },
}

-----------------------------------------
item = {}
item.Name = function(id) --Returns the ITEM NAME from the table above.
    if ItemDB[id] ~= nil then
        return ItemDB[id][1]
    end
    return nil
end

item.Recipe = function(id)  --Returns the item recipe,items that builds into the main item.
    if ItemDB[id] ~= nil then
        return ItemDB[id][3]
    end
    return {}
end

item.ID = function(name) --Returns the item code. For example: Boots of Speed = 1001
    for k, v in pairs(ItemDB) do --loop the table
        if name == v[1] then return k end --if the item.ID name == Table's ITEM NAME then return ID_code end
    end
    return nil
end

-----------------------------------------
item.IngredientPrice = function(id) --Returns the main item price, for example: Ninja Tabi = 850g | Recipe: (Boots of Speed(350g) + Cloth Armor(300g))+ 200g
    if ItemDB[id] ~= nil then --If the item exist
        return ItemDB[id][2]  --return the price Ex.: Ninja Tabi = 850g
    end
    return nil --If the item is not found, return nothing(nil).
end

item.PriceFull = function(id)
    local recipe = item.Recipe(id) --Takes the recipe prices from the table.
    local price = item.IngredientPrice(id) --Takes the item(not the recipe) PRICE.
    if recipe ~= nil then --If the recipe of that item exists
        for i, v in ipairs(recipe) do --loop that table
            price = price + item.PriceFull(v) -- One item PRICE + RECIPE PRICE = FULL PRICE
        end
    end
    return price -- RETURN THE PRICE.
end

item.SellPrice = function(id)
   --Dorans Blade --Dorans Ring  --Dorans Shield --Avirce Blade --Heart of Gold --Philo Stone -- Kage's lucky pick
    if id == 1055 or id == 1056 or id == 1054 or id == 3093 or id == 3132 or id == 3096 or id == 3098 then
        return math.floor(item.PriceFull(id) * 0.5) --half the price Ex.: 475 * 0.5 = 237.5
    else
        return math.floor(item.PriceFull(id) * 0.7)
    end
end

-----------------------------------------
item.IsInList = function(list, id)
    if list == PreInventory then
        if id == 2043 or id == 2044 or id == 2004 or id == 2003 or id == 2037 or id == 2039 or id == 2038 then
            local count = 0
            for i, v in ipairs(list) do
               if v == id and count ~= 0 then
                   count = count + PreInventoryCount[i]
               end
            end
            return count
        end
    elseif list == Inventory then
        if id == 2043 or id == 2044 or id == 2004 or id == 2003 or id == 2037 or id == 2039 or id == 2038 then
            local count = 0
            for i, v in ipairs(list) do
                if v == id and count ~= 0 then
                    count = count + InventoryCount[i]
                end
            end
            return count
        end
    end

    local count = 0
    for i, v in ipairs(list) do
        if v == id then
            count = count + 1
        end
    end
    return count
end

item.IsInPreInventorySlot = function(id, slot)
    if PreInventory[slot] == id then
        return PreInventoryCount[slot]
    else
        return 0
    end
end
-----------------------------------------
item.RemoveFromList = function(list, id, amount)
    local amount = amount or 1
    if list == PreInventory then
        for i, v in ipairs(PreInventory) do
            if v == id then
                if PreInventoryCount[i] ~= nil and PreInventoryCount[i] > 0 then
                    PreInventoryCount[i] = PreInventoryCount[i] - amount
                end
                if PreInventoryCount[i] ~= nil and PreInventoryCount[i] <= 0 then
                    PreInventory[i] = 0
                    PreInventoryCount[i] = 0
                end
                break
            end
        end
    elseif list == Inventory then
        for i, v in ipairs(Inventory) do
            if v == id then
                if InventoryCount[i] ~= nil and InventoryCount[i] > 0 then InventoryCount[i] = InventoryCount[i] - amount end
                if InventoryCount[i] ~= nil and InventoryCount[i] <= 0 then Inventory[i] = 0 InventoryCount[i] = 0 end
                break
            end
        end
    else for i = 1, amount, 1 do
        for i, v in ipairs(list) do
            if v == id then table.remove(list, i) break end
        end
    end
    end
end

item.AddToList = function(list, id, amount)
    local amount = amount or 1
    if list == PreInventory then
        if id == 2043 or id == 2044 or id == 2004 or id == 2003 or id == 2037 or id == 2039 or id == 2038 then
            local z
            if id == 2004 or id == 2003 then z = 9
            elseif id == 2043 or id == 2044 then z = 5
            elseif id == 2037 or id == 2039 or id == 2038 then z = 3
            end
            if item.IsInList(PreInventory, id) < z then --ToDo add function isInInventorySlot<n else goto next
                for i, v in ipairs(PreInventory) do
                    if v == id and PreInventoryCount[i] ~= nil then
                        PreInventoryCount[i] = PreInventoryCount[i] + amount
                        return
                    end
                end
            end
        end
        for i, v in ipairs(PreInventory) do
            if v == nil then
                PreInventory[i] = id
                PreInventoryCount[i] = PreInventoryCount[i] + amount
                return
            end
        end
    elseif list == Inventory then
        if id == 2043 or id == 2044 or id == 2004 or id == 2003 or id == 2037 or id == 2039 or id == 2038 then
            local z
            if id == 2004 or id == 2003 then z = 9
            elseif id == 2043 or id == 2044 then z = 5
            elseif id == 2037 or id == 2039 or id == 2038 then z = 3
            end
            if item.IsInList(Inventory, id) < z then --ToDo add function isInInventorySlot<n else goto next
                for i, v in ipairs(Inventory) do
                    if v == id then
                        InventoryCount[i] = InventoryCount[i] + amount
                        return
                    end
                end
            end
        end
        for i, v in ipairs(Inventory) do
            if v == 0 then
                Inventory[i] = id
                InventoryCount[i] = InventoryCount[i] + amount
                return
            end
        end
    else
        for i = 1, amount, 1 do
            table.insert(list, id)
        end
    end
end

-- PRECALCULATION; Mostly based on Recursion

item.Price = function(id)
    local price = 0
    for i, v in ipairs(item.RemainingIngredientsToBuy(id)) do
        price = price + item.IngredientPrice(v)
    end
    return price
end
-----------------------------------------
function item.Ingredients(id)
    local ingredients = {} --one item ingredients(recipe items) table
    table.insert(ingredients, id)
    for i, v in ipairs(item.Recipe(id)) do
        if item.Ingredients(v) ~= nil then
            for i, v in ipairs(item.Ingredients(v)) do
                table.insert(ingredients, v)
            end
        end
    end
    return ingredients
end

function item.IsIngredient(itemid, ingredientid)
    local recipe = item.Recipe(itemid)
    for k, v in pairs(recipe) do
        if v == ingredientid or item.IsIngredient(v, ingredientid) then
            return true
        end
    end
    return false
end


function item.GetReserved() -- item ingredients that should not be sold (if in inventory)
    local function Reserved(id)
        local reserve = {}
        table.insert(reserve, id)
        if item.IsInList(PreInventory, id) == 0 then
            for i, v in ipairs(item.Recipe(id)) do
                for i, ingredient in ipairs(Reserved(v)) do
                    table.insert(reserve, ingredient)
                end
            end
        end
        return reserve
    end

    local reserve = {}
    for i, v in ipairs(ItemList2) do
        for i, item in ipairs(Reserved(v)) do
            table.insert(reserve, item)
        end
    end
    for i, v in ipairs(ItemList3) do
        if myHero.level >= v[4] and myHero.level <= v[5] and item.IsInList(PreInventory, v[1]) <= v[2] then item.AddToList(reserve, v[1]) end
    end
    return reserve
end

function item.IsReserved(id)
    if item.IsInList(item.GetReserved(), id) == 0 or item.IsInList(PreInventory, id) > item.IsInList(item.GetReserved(), id) then return false
    else return true
    end
end

-----------------------------------------
function item.RemainingIngredientsToBuy(id)
    local function RemainingCalculator(id)
        local remaining = {}
        if item.IsInList(PreInventory, id) == 0 then table.insert(remaining, id)
        for i, v in ipairs(item.Recipe(id)) do
            if RemainingCalculator(v) ~= nil then
                for i, v in ipairs(RemainingCalculator(v)) do
                    table.insert(remaining, v)
                end
            end
        end
        end
        return remaining
    end

    local remaining = { id, }
    for i, v in ipairs(item.Recipe(id)) do
        for i, v in ipairs(RemainingCalculator(v)) do
            table.insert(remaining, v)
        end
    end
    return remaining
end

-----------------------------------------
function item.DisappearingItems(id)
    local disappearing = {}
    for i, ingredient in ipairs(item.Recipe(id)) do
        if item.IsInList(PreInventory, ingredient) == 0 then
            if item.DisappearingItems(ingredient) ~= nil then
                for i, v in ipairs(item.DisappearingItems(ingredient)) do
                    table.insert(disappearing, v)
                end
            end
        else table.insert(disappearing, ingredient)
        end
    end
    return disappearing
end

function table.copy(from)
    if from == nil or type(from) ~= "table" then return end
    local to = {}
    for k, v in pairs(from) do
        to[k] = v
    end
    return to
end

-----------------------------------------
local function deleteDoubleItems()
    if #ItemsToBuy > 0 and #ItemsToSell > 0 then
        local ItemsToSellold = table.copy(ItemsToSell)
        for i, v in ipairs(ItemsToBuy) do
            item.RemoveFromList(ItemsToSell, v, item.IsInList(ItemsToSell, v))
        end
        for i, v in ipairs(ItemsToSellold) do
            item.RemoveFromList(ItemsToBuy, v, item.IsInList(ItemsToBuy, v))
        end
    end
end

function calculateItemsToTrade()
    PrePreGold = nil
    PreGold = math.floor(myHero.gold)
    PreInventory = table.copy(Inventory)
    PreItemList1 = table.copy(ItemList1)
    PreInventoryCount = table.copy(InventoryCount)
    ItemsToBuy = {}
    ItemsToSell = {}
    unnecessaryItems = {}
    local Buy = whatToBuy()
    local Sell, SellCount = whatToSell()
    while Buy ~= nil or Sell ~= nil do
        if Buy ~= nil then preBuy(Buy) end
        Sell, SellCount = whatToSell()
        if Sell ~= nil then for i = 1, SellCount, 1 do preSell(Sell) end end
        Buy = whatToBuy()
    end
    deleteDoubleItems() --This can be caused by bad calculation. Hopefully, it will not be needed in future.
    NextItem, NextItemPrice = whatToBuyNext()
end

function canBuyBetterItemAfterSell(id)
    if id == 1001 or id == 3117 or id == 3009 or id == 3158 or id == 3006 or id == 3111 then if #ItemList1 > 1 then return 0 end end --Boots
    local saveGold = PreGold
    local savePreInventory = table.copy(PreInventory)
    local savePreInventoryCount = table.copy(PreInventoryCount)

    local function closeSandbox()
        PreGold = saveGold
        PreInventory = table.copy(savePreInventory)
        PreInventoryCount = table.copy(savePreInventoryCount)
    end

    local sellingItemPrice = item.PriceFull(id) or 0 --is not the right value if you have stacked items, but works best.
    local itemWithoutSell = whatToBuy()
    local itemWithoutSellPrice = item.PriceFull(itemWithoutSell) or 0
    -----------------------------
    local itemWithSell, itemWithSellPrice
    if id == 2043 or id == 2044 or id == 2004 or id == 2003 then
        local counter = 0
        local max = item.IsInList(PreInventory, id)
        for i = 1, max, 1 do
            PreGold = PreGold + item.SellPrice(id)
            item.RemoveFromList(PreInventory, id)
            itemWithSell = whatToBuy()
            itemWithSellPrice = item.PriceFull(itemWithSell) or 0
            counter = counter + 1
            if itemWithoutSellPrice <= sellingItemPrice and itemWithSellPrice > sellingItemPrice then --ToDo: Think about this Line, the results are Ok, but I Only can decide if another item is better by comparing there prices.
                closeSandbox()
                return counter
            end
        end

        closeSandbox()
        return 0
    end
    PreGold = PreGold + item.SellPrice(id)
    item.RemoveFromList(PreInventory, id)
    itemWithSell = whatToBuy()
    itemWithSellPrice = item.PriceFull(itemWithSell) or 0

    closeSandbox()
    if #ItemList2 >= 6 and itemWithSellPrice > itemWithoutSellPrice then return 1 end --this should only be activated if you have defined a list of items which should not be sold its a bad rule to decide if you want to sell sth. UNCOOL
    if itemWithoutSellPrice <= sellingItemPrice and itemWithSellPrice > sellingItemPrice and #item.DisappearingItems(itemWithSell) == 0 then return 1 end --ToDo: Think about this Line, the results are Ok, but I Only can decide if another item is better by comparing there prices.
    return 0
end



function whatToBuy()
    local function deleteUnnecessaryItems() --- untested
        unnecessaryItems = unnecessaryItems or {}
        if #PreItemList1 > 1 then
            for i = 2, #PreItemList1, 1 do
                local currentremain = item.RemainingIngredientsToBuy(PreItemList1[i])
                item.RemoveFromList(currentremain, PreItemList1[i])
                for j, v in ipairs(currentremain) do
                    if v ~= 1001 and v == PreItemList1[1] and item.CanBuy(PreItemList1[i]) then
                        table.remove(PreItemList1, 1)
                        table.insert(unnecessaryItems, v)
                        deleteUnnecessaryItems()
                        return
                    end
                end
            end
        end
    end

    local itemToBuy
    for i, v in ipairs(ItemList3) do
        if myHero.level >= v[4] and myHero.level <= v[5] and item.CanBuy(v[1]) and item.IsInList(PreInventory, v[1]) < v[2] and v[3] >= v[2] then
            if v[1] ~= 2038 and v[1] ~= 2039 and v[1] ~= 2037 and v[1] ~= 2042 and v[1] ~= 2047 then return v[1]
            elseif item.IsInList(ItemsToBuy, v[1]) == 0 then return v[1]
            end
        end
    end
    local itemFromList3 = false
    for i, v in ipairs(ItemList3) do
        if myHero.level >= v[4] and myHero.level <= v[5] and item.CanBuy(v[1]) and item.IsInList(PreInventory, v[1]) < v[3] and v[3] >= v[2] then
            if v[1] ~= 2038 and v[1] ~= 2039 and v[1] ~= 2037 and v[1] ~= 2042 and v[1] ~= 2047 then itemToBuy = v[1] itemFromList3 = true break
            elseif item.IsInList(ItemsToBuy, v[1]) == 0 then itemToBuy = v[1] itemFromList3 = true break
            end
        end
    end
    --deleteUnnecessaryItems()
    local highestPrice = 0
    for i, v in ipairs(item.RemainingIngredientsToBuy(PreItemList1[1])) do
        if item.CanBuy(v) and item.PriceFull(v) > highestPrice then
            itemToBuy = v
            highestPrice = item.PriceFull(v)
        end
    end
    if itemFromList3 == true and PrePreGold == nil then PrePreGold = Pregold end
    return itemToBuy
end

function whatToBuyNext()
    local itemToBuy
    local lowestPrice = math.huge
    for i, v in ipairs(item.RemainingIngredientsToBuy(PreItemList1[1])) do
        if item.PriceFull(v) < lowestPrice then
            itemToBuy = v
            lowestPrice = item.PriceFull(v)
        end
    end
    for i, v in ipairs(ItemList3) do
        if myHero.level >= v[4] and myHero.level <= v[5] and item.PriceFull(v[1]) < lowestPrice and item.IsInList(PreInventory, v[1]) < v[2] and v[3] >= v[2] then
            if v[1] ~= 2038 and v[1] ~= 2039 and v[1] ~= 2037 and v[1] ~= 2042 and v[1] ~= 2047 then itemToBuy = v[1] lowestPrice = item.PriceFull(v[1])
            elseif item.IsInList(ItemsToBuy, v[1]) == 0 then itemToBuy = v[1] lowestPrice = item.PriceFull(v[1])
            end
        end
    end

    local function getMaxSellableItemprice() --so much problems here, jesus..
        local highestPrice = 0
        if PreInventory[1] ~= 0 and PreInventory[2] ~= 0 and PreInventory[3] ~= 0 and PreInventory[4] ~= 0 and PreInventory[5] ~= 0 and PreInventory[6] ~= 0 then
            for i, v in ipairs(PreInventory) do
                local price = item.SellPrice(v)
                if v ~= 0 and highestprice ~= nil and item.IsInList(item.GetReserved(), v) == 0 and price > highestPrice and v ~= 2043 and v ~= 2044 and v ~= 2004 and v ~= 2003 then
                    highestPrice = (PreInventoryCount[i] * price) -- error - Line 618: attempt to perform arithmetic on field '?' (a nil value)
                end
            end
        end
        for i, v in ipairs(ItemList3) do
            if myHero.level >= v[4] and myHero.level <= v[5] then
                local amount = item.IsInList(PreInventory, v[1]) - v[2]
                if amount > 0 then
                    if v ~= 2043 and v ~= 2044 and v ~= 2004 and v ~= 2003 then highestPrice = highestPrice + item.SellPrice(v[1]) * amount end
                end
            end
        end
        return highestPrice
    end

    local NextItemPrice
    local PreGold = PrePreGold or PreGold
    if itemToBuy ~= nil then NextItemPrice = (item.Price(itemToBuy) - PreGold) - getMaxSellableItemprice() else NextItemPrice = 0 end
    if NextItemPrice < 0 then NextItemPrice = item.Price(itemToBuy) - PreGold end
    return itemToBuy, NextItemPrice
end

function whatToSell()
    local itemToSell, itemToSellCount
    if PreInventory[1] ~= 0 and PreInventory[2] ~= 0 and PreInventory[3] ~= 0 and PreInventory[4] ~= 0 and PreInventory[5] ~= 0 and PreInventory[6] ~= 0 then
        local LowestPrice = math.huge
        for i, v in ipairs(PreInventory) do
            local price
            if v == 2043 or v == 2044 or v == 2004 or v == 2003 then price = item.PriceFull(v) * item.IsInList(PreInventory, v) else price = item.PriceFull(v) end
            local amount = canBuyBetterItemAfterSell(v)
            if amount > 0 and v ~= 0 and v ~= 3200 and not item.IsReserved(v) and price < LowestPrice then
                itemToSell = v
                itemToSellCount = amount
                LowestPrice = price
            end
        end
        return itemToSell, itemToSellCount
    end
    return nil
end

function item.CanBuy(id)
    if PreGold >= item.Price(id) and item.FitInInventory(id) then
        return true
    end
    return false
end

function item.ElexirOver(id)
    if myHero.buffCount == nil then return false end --debug
    local function isBuffActive(name)
        local buffCount = myHero.buffCount
        for i = 1, buffCount, 1 do
            local buff = myHero:getBuff(i)
            if buff:find(name) then
                return true
            end
        end
        return false
    end

    if id == 2038 and not isBuffActive("PotionOfElusiveness") then return true
    elseif id == 2039 and not isBuffActive("PotionOfBrilliance") then return true
    elseif id == 2037 and not isBuffActive("PotionOfGiantStrength") then return true
        --elseif id == 2047 and not isBuffActive("...") then return true --ToDo: Add Oracles Extract
    elseif id == 2042 and not isBuffActive("OracleElixirSight") then return true
    end
    return false
end

function item.FitInInventory(id)
    if id == 2003 or id == 2004 then
        if item.IsInList(PreInventory, id) > 0 and item.IsInList(PreInventory, id) < 9 then return true
        end
    end
    if id == 2044 or id == 2043 then
        if item.IsInList(PreInventory, id) > 0 and item.IsInList(PreInventory, id) < 5 then return true
        end
    end
    if id == 2037 or id == 2038 or id == 2039 or id == 2042 or id == 2047 then
        return item.ElexirOver(id)
    end
    if PreInventory[1] == 0 or PreInventory[2] == 0 or PreInventory[3] == 0 or PreInventory[4] == 0 or PreInventory[5] == 0 or PreInventory[6] == 0 or #item.DisappearingItems(id) > 0 then return true
    end
    return false
end

-----------------------------------------
function preBuy(id)
    PreGold = PreGold - item.Price(id) --subtract from pregold
    if id ~= 2037 and id ~= 2038 and id ~= 2039 and id ~= 2042 and id ~= 2047 then
        for i, v in ipairs(item.DisappearingItems(id)) do --remove disappearing Items
            item.RemoveFromList(PreInventory, v)
        end
        item.AddToList(PreInventory, id)
    end
    item.RemoveFromList(PreItemList1, id) --remove from the Purchase Order.
    item.AddToList(ItemsToBuy, id)
end

function preSell(id)
    PreGold = PreGold + item.SellPrice(id)
    item.RemoveFromList(PreInventory, id)
    item.AddToList(ItemsToSell, id)
end

-- FINAL TRADING
function UseElexir()
    local ItemSlot = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, }
        for i = 1, 6, 1 do
        local item = myHero:getInventorySlot(ItemSlot[i])
        if item == 2038 or item == 2039 or item == 2037 or item == 2042 or item == 2047 then
            CastSpell(ItemSlot[i])
        end
    end
end

function sell(id)
    local ItemSlot = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, }
    for i = 1, 6, 1 do --from 1 slot to 6 slot.
        if myHero:getInventorySlot(ItemSlot[i]) == id then
        return SellItem(ItemSlot[i])
        end
    end
    item.RemoveFromList(Inventory, id)
    return false
end

function buy(id)
    if id ~= nil and id ~= 0 then
        if BuyItem(id) then
            item.RemoveFromList(ItemList1, id)
            if unnecessaryItems then
                for i, v in ipairs(unnecessaryItems) do
                    item.RemoveFromList(ItemList1, v)
                end
                unnecessaryItems = nil
            end
            return true
        end
    end
    return false
end

-----------------------------------------
function inShop() --distance myHero to shop < range
    local function getShopCoordinates()
        for i = 1, objManager.iCount, 1 do
            local object = objManager:GetObject(i)
            if object ~= nil and string.lower(object.name) == string.lower("LevelProp_ShopMale") and myHero.team == TEAM_RED then return object.x - 50, object.y + 200, object.z + 70, 1250
            elseif object ~= nil and string.lower(object.name) == string.lower("LevelProp_ShopMale1") and myHero.team == TEAM_BLUE then return object.x + 45, object.y + 150, object.z + 100, 1250
            end
        end
    end

    if ShopX == nil or ShopY == nil or ShopZ == nil or ShopRange == nil then --check if was able to get shopCoordinates.
        if getShopCoordinates() ~= nil then ShopX, ShopY, ShopZ, ShopRange = getShopCoordinates() else PrintChat("Unable to get Shop Coordinates.") return end
    end

    if math.sqrt((ShopX - myHero.x) ^ 2 + (ShopZ - myHero.z) ^ 2) < ShopRange then return true, ShopX, ShopY, ShopZ, ShopRange
    end
    return false, ShopX, ShopY, ShopZ, ShopRange
end

function isJungling()
    if myHero.buffCount == nil then return false end --debug
    if myHero:GetSpellData(SUMMONER_1).name:find("Smite") ~= nil or myHero:GetSpellData(SUMMONER_2).name:find("Smite") ~= nil then
        return true
    else
        return false
    end
end

function getMapName() -- All Credits to Sergio_G
    if myHero.buffCount == nil then return false end --debug
    for i = 1, objManager.iCount do
        local object = objManager:getObject(i)
        if object ~= nil and object.name == "Turret_OrderTurretShrine" then
            local x = object.x
            if x > 0 then return "Dominion"
            elseif x > -300 and x < 0 then return "Summoners Rift"
            elseif x < -300 then return "The Twisted Treeline"
            end
        end
    end
    return "UNKNOWN"
end

function getItemList() --ToDo Add ItemLists from Mobafire
    local champ = myHero.charName
    local itemsToBuy = {}
    local itemsNotToSell = {}
    local tools = {}
    if champ == "Ahri" then
        itemsToBuy = { "Doran's Ring", "Hextech Revolver", "Boots of Speed", "Sorcerer's Shoes", "Needlessly Large Rod", "Giant's Belt", "Rylai's Crystal Scepter", "Will of the Ancients", "Rabadon's Deathcap", "Morello's Evil Tome", "Void Staff", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rylai's Crystal Scepter", "Will of the Ancients", "Rabadon's Deathcap", "Morello's Evil Tome", "Void Staff" }
        tools = {}
    elseif champ == "Akali" then
        itemsToBuy = { "Boots of Speed", "Hextech Revolver", "Mercury's Treads", "Giant's Belt", "Rylai's Crystal Scepter", "Sheen", "Lich Bane", "Rabadon's Deathcap", "Hextech Gunblade", "Void Staff", "Guardian Angel", }
        itemsNotToSell = { "Rylai's Crystal Scepter", "Lich Bane", "Rabadon's Deathcap", "Hextech Gunblade", "Void Staff", "Guardian Angel" }
        tools = { { "Health Potion", 1, 3, 1, 10, }, { "Elixir of Brilliance", 0, 1, 15, 18 }, { "Elixir of Fortitude", 0, 1, 15, 18 }, { "Elixir of Brilliance", 0, 1, 15, 18 }, }
    elseif champ == "Alistar" then
        itemsToBuy = { "Faerie Charm", "Philosopher's Stone", "Boots of Speed", "Heart of Gold", "Boots of Mobility", "Aegis of the Legion", "Shurelya's Reverie", "Spirit Visage", "Randuin's Omen", "Trinity Force", }
        itemsNotToSell = { "Boots of Mobility", "Aegis of the Legion", "Shurelya's Reverie", "Spirit Visage", "Randuin's Omen", "Trinity Force", }
        tools = { { "Health Potion", 1, 3, 1, 10, }, { "Sight Ward", 1, 3, 1, 18 }, }
    elseif champ == "Amumu" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Boots of Speed", "Giant's Belt", "Boots of Swiftness", "Sunfire Cape", "Abyssal Scepter", "Eleisa's Miracle", "Banshee's Veil", "Guardian Angel", }
        itemsNotToSell = { "Boots of Swiftness", "Sunfire Cape", "Abyssal Scepter", "Eleisa's Miracle", "Banshee's Veil", "Guardian Angel", }
        tools = { { "Mana Potion", 0, 3, 1, 5, }, }
    elseif champ == "Anivia" then
        itemsToBuy = { "Boots of Speed", "Catalyst the Protector", "Sorcerer's Shoes", "Rod of Ages", "Needlessly Large Rod", "Rabadon's Deathcap", "Zhonya's Hourglass", "Hextech Revolver", "Void Staff", "Will of the Ancients", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rod of Ages", "Rabadon's Deathcap", "Zhonya's Hourglass", "Void Staff", "Will of the Ancients", }
        tools = { { "Health Potion", 1, 3, 1, 10, }, }
    elseif champ == "Annie" then
        itemsToBuy = { "Boots of Speed", "Doran's Ring", "Doran's Ring", "Rod of Ages", "Rylai's Crystal Scepter", "Rabadon's Deathcap", "Void Staff", "Zhonya's Hourglass", }
        itemsNotToSell = { "Doran's Ring", "Rod of Ages", "Rylai's Crystal Scepter", "Rabadon's Deathcap", "Void Staff", "Zhonya's Hourglass", }
        tools = { { "Health Potion", 1, 3, 1, 10, }, }
    elseif champ == "Ashe" then
        itemsToBuy = { "Doran's Blade", "Boots of Speed", "B. F. Sword", "Berserker's Greaves", "Infinity Edge", "Zeal", "Vampiric Scepter", "Phantom Dancer", "Last Whisper", "The Bloodthirster", "Guardian Angel", }
        itemsNotToSell = { "Berserker Greaves", "Infinity Edge", "Phantom Dancer", "Last Whisper", "The Bloodthirster", "Guardian Angel", }
        tools = {}
    elseif champ == "Blitzcrank" then
        itemsToBuy = { "Sapphire Crystal", "Tear of the Goddess", "Boots of Speed", "Sapphire Crystal", "Sheen", "Manamune", "Mercury's Treads", "Glacial Shroud", "Frozen Heart", "Banshee's Veil", "Phage", "Trinity Force", "Guardian Angel", }
        itemsNotToSell = { "Manamune", "Mercury's Treads", "Frozen Heart", "Banshee's Veil", "Trinity Force", "Guardian Angel", }
        tools = { { "Health Potion", 1, 1, 1, 5, }, }
    elseif champ == "Brand" then
        itemsToBuy = { "Boots of Speed", "Doran's Ring", "Doran's Ring", "Hextech Revolver", "Rabadon's Deathcap", "Void Staff", "Rylai's Crystal Scepter", "Zhonya's Hourglass", "Will of the Ancients", }
        itemsNotToSell = { "Doran's Ring", "Rabadon's Deathcap", "Void Staff", "Rylai's Crystal Scepter", "Zhonya's Hourglass", "Will of the Ancients", }
        tools = { { "Health Potion", 1, 3, 1, 10, }, }
    elseif champ == "Caitlyn" then
        itemsToBuy = { "Doran's Blade", "Boots of Speed", "Doran's Blade", "Berserker's Greaves", "B. F. Sword", "Vampiric Scepter", "Infinity Edge", "Zeal", "The Bloodthirster", "Phantom Dancer", "Banshee's Veil", "Last Whisper", }
        itemsNotToSell = { "Berserker's Greaves", "Infinity Edge", "The Bloodthirster", "Phantom Dancer", "Banshee's Veil", "Last Whisper", }
        tools = {}
    elseif champ == "Cassiopeia" then
        itemsToBuy = { "Boots of Speed", "Doran's Ring", "Sorcerer's Shoes", "Needlessly Large Rod", "Rabadon's Deathcap", "Giant's Belt", "Rylai's Crystal Scepter", "Negatron Cloak", "Banshee's Veil", "Void Staff", "Will of the Ancients", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rabadon's Deathcap", "Rylai's Crystal Scepter", "Banshee's Veil", "Void Staff", "Will of the Ancients", }
        tools = { { "Health Potion", 1, 3, 1, 5, }, }
    elseif champ == "Chogath" then
        itemsToBuy = { "Doran's Ring", "Mercury's Treads", "Rod of Ages", "Frozen Heart", "Force of Nature", "Rabadon's Deathcap", }
        itemsNotToSell = { "Doran's Ring", "Mercury's Treads", "Rod of Ages", "Frozen Heart", "Force of Nature", "Rabadon's Deathcap", }
        tools = {}
    elseif champ == "Corki" then
        itemsToBuy = { "Doran's Blade", "Doran's Blade", "Berserker's Greaves", "Phage", "Trinity Force", "The Bloodthirster", "Banshee's Veil", "Last Whisper", "Infinity Edge", }
        itemsNotToSell = { "Berserker's Greaves", "Trinity Force", "The Bloodthirster", "Banshee's Veil", "Last Whisper", "Infinity Edge", }
        tools = {}
    elseif champ == "DrMundo" then
        itemsToBuy = { "Doran's Shield", "Mercury's Treads", "Heart of Gold", "Avarice Blade", "Warmog's Armor", "Chain Vest", "Negatron Cloak", "Force of Nature", "Randuin's Omen", "Zeke's Herald", "Youmuu's Ghostblade", }
        itemsNotToSell = { "Mercury's Treads", "Warmog's Armor", "Force of Nature", "Randuin's Omen", "Zeke's Herald", "Youmuu's Ghostblade", }
        tools = {}
    elseif champ == "Evelynn" then
        itemsToBuy = { "Boots of Speed", "Boots of Mobility", "Sheen", "Trinity Force", "Pickaxe", "Guinsoo's Rageblade", "Guardian Angel", "Hextech Gunblade", "Banshee's Veil", }
        itemsNotToSell = { "Boots of Mobility", "Trinity Force", "Guinsoo's Rageblade", "Guardian Angel", "Hextech Gunblade", "Banshee's Veil", }
        tools = { { "Health Potion", 1, 3, 1, 5, }, }
    elseif champ == "Ezreal" then
        itemsToBuy = { "Sapphire Crystal", "Boots of Speed", "Sheen", "Berserker's Greaves", "The Brutalizer", "Phage", "Vampiric Scepter", "Trinity Force", "The Black Cleaver", "The Bloodthirster", "Madred's Bloodrazor", "Infinity Edge", }
        itemsNotToSell = { "The Brutalizer", "Trinity Force", "The Black Cleaver", "The Bloodthirster", "Madred's Bloodrazor", "Infinity Edge", }
        tools = { { "Health Potion", 1, 2, 1, 5, }, }
    elseif champ == "FiddleSticks" then
        itemsToBuy = { "Doran's Ring", "Sorcerer's Shoes", "Hextech Revolver", "Blasting Wand", "Rod of Ages", "Rabadon's Deathcap", "Abyssal Scepter", "Zhonya's Hourglass", "Will of the Ancients", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rod of Ages", "Rabadon's Deathcap", "Abyssal Scepter", "Zhonya's Hourglass", "Will of the Ancients" }
        tools = {}
    elseif champ == "Fiora" then
        itemsToBuy = { "Doran's Blade", "Berserker's Greaves", "The Black Cleaver", "Zeal", "Infinity Edge", "Vampiric Scepter", "Phantom Dancer", "The Bloodthirster", "Frozen Mallet" }
        itemsNotToSell = { "Berserker's Greaves", "The Black Cleaver", "Infinity Edge", "Phantom Dancer", "The Bloodthirster", "Frozen Mallet" }
        tools = {}
    elseif champ == "Fizz" then
        itemsToBuy = { "Boots of Speed", "Catalyst the Protector", "Sheen", "Ionian Boots of Lucidity", "Rod of Ages", "Lich Bane", "Rabadon's Deathcap", "Deathfire Grasp", "Giant's Belt", "Rylai's Crystal Scepter", "Negatron Cloak", "Abyssal Scepter", "Guardian Angel", }
        itemsNotToSell = { "Lich Bane", "Rabadon's Deathcap", "Deathfire Grasp", "Rylai's Crystal Scepter", "Abyssal Scepter", "Guardian Angel" }
        tools = { { "Health Potion", 1, 3, 1, 5, } }
    elseif champ == "Galio" then
        itemsToBuy = { "Null-Magic Mantle", "Chalice of Harmony", "Mercury's Treads", "Banshee's Veil", "Aegis of the Legion", "Abyssal Scepter", "Force of Nature", "Thornmail", "Guardian Angel" }
        itemsNotToSell = { "Banshee's Veil", "Aegis of the Legion", "Abyssal Scepter", "Force of Nature", "Thornmail", "Guardian Angel", }
        tools = { { "Health Potion", 1, 2, 1, 3, } }
    elseif champ == "Gangplank" then
        itemsToBuy = { "Brawler's Gloves", "Avarice Blade", "Sheen", "Zeal", "Ionian Boots of Lucidity", "Trinity Force", "Cloak of Agility", "B. F. Sword", "Pickaxe", "Infinity Edge", "Zeal", "Phantom Dancer", "Last Whisper", "Atma's Impaler", }
        itemsNotToSell = { "Ionian Boots of Lucidity", "Trinity Force", "Infinity Edge", "Phantom Dancer", "Last Whisper", "Atma's Impaler", }
        tools = { { "Health Potion", 1, 2, 1, 5, } }
    elseif champ == "Garen" then
        itemsToBuy = { "Doran's Blade", "Boots of Speed", "Doran's Blade", "Doran's Blade", "B. F. Sword", "Boots of Swiftness", "Infinity Edge", "Frozen Mallet", "Phantom Dancer", "Atma's Impaler", "Zeke's Herald", }
        itemsNotToSell = { "Boots of Swiftness", "Infinity Edge", "Frozen Mallet", "Phantom Dancer", "Atma's Impaler", "Zeke's Herald", }
        tools = {}
    elseif champ == "Gragas" then
        itemsToBuy = { "Boots of Speed", "Doran's Ring", "Doran's Ring", "Doran's Ring", "Sorcerer's Shoes", "Rod of Ages", "Hextech Revolver", "Rabadon's Deathcap", "Will of the Ancients", "Void Staff", "Mercury's Treads", "Lich Bane", }
        itemsNotToSell = { "Rod of Ages", "Rabadon's Deathcap", "Will of the Ancients", "Mercury's Treads", "Lich Bane", }
        tools = { { "Health Potion", 1, 3, 1, 5, } }
    elseif champ == "Graves" then
        itemsToBuy = { "Doran's Blade", "Boots of Speed", "B. F. Sword", "The Bloodthirster", "Zeal", "Berserker's Greaves", "B. F. Sword", "Phantom Dancer", "Infinity Edge", "Phage", "Frozen Mallet", "The Black Cleaver", }
        itemsNotToSell = { "The Bloodthirster", "Berserker's Greaves", "Phantom Dancer", "Infinity Edge", "Frozen Mallet", "The Black Cleaver", }
        tools = {}
    elseif champ == "Heimerdinger" then
        itemsToBuy = { "Meki Pendant", "Tear of the Goddess", "Boots of Speed", "Rylai's Crystal Scepter", "Sorcerer's Shoes", "Needlessly Large Rod", "Zhonya's Hourglass", "Archangel's Staff", "Negatron Cloak", "Abyssal Scepter", "Will of the Ancients", }
        itemsNotToSell = { "Rylai's Crystal Scepter", "Sorcerer's Shoes", "Zhonya's Hourglass", "Archangel's Staff", "Abyssal Scepter", "Will of the Ancients", }
        tools = { { "Health Potion", 1, 3, 1, 5, } }
    elseif champ == "Irelia" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Heart of Gold", "Boots of Speed", "Sheen", "Mercury's Treads's", "Trinity Force", "Negatron Cloak", "Warden's Mail", "Force of Nature", "Randuin's Omen", }
        itemsNotToSell = { "Philosopher's Stone", "Mercury's Treads", "Trinity Force", "Force of Nature", "Randuin's Omen", }
        tools = { { "Health Potion", 1, 1, 1, 3, } }
    elseif champ == "Janna" then
        itemsToBuy = { "Faerie Charm", "Philosopher's Stone", "Boots of Speed", "Heart of Gold", "Kage's Lucky Pick", "Ionian Boots of Lucidity", "Shurelya's Reverie", "Aegis of the Legion", "Frozen Heart", "Banshee's Veil", }
        itemsNotToSell = { "Kage's Lucky Pick", "Ionian Boots of Lucidity", "Shurelya's Reverie", "Aegis of the Legion", "Frozen Heart", "Banshee's Veil", }
        tools = { { "Sight Ward", 1, 2, 1, 5, }, { "Vision Ward", 1, 1, 1, 5, }, { "Health Potion", 1, 1, 1, 5, } }
    elseif champ == "JarvanIV" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Heart of Gold", "Mercury's Treads", "Phage", "Trinity Force", "Null-Magic Mantle", "Aegis of the Legion", "Chain Vest", "Atma's Impaler", "Randuin's Omen", "Negatron Cloak", "Banshee's Veil", }
        itemsNotToSell = { "Mercury's Treads", "Trinity Force", "Aegis of the Legion", "Atma's Impaler", "Randuin's Omen", "Banshee's Veil", }
        tools = {}
    elseif champ == "Jax" then
        itemsToBuy = { "Doran's Ring", "Ninja Tabi", "Guinsoo's Rageblade", "Sheen", "Hextech Gunblade", "Rylai's Crystal Scepter", "Lich Bane", "Rabadon's Deathcap", }
        itemsNotToSell = { "Ninja Tabi", "Guinsoo's Rageblade", "Hextech Gunblade", "Rylai's Crystal Scepter", "Lich Bane", "Rabadon's Deathcap", }
        tools = {}
    elseif champ == "Karma" then
        itemsToBuy = { "Doran's Ring", "Sapphire Crystal", "Catalyst the Protector", "Boots of Speed", "Rod of Ages", "Ionian Boots of Lucidity", "Glacial Shroud", "Abyssal Scepter", "Frozen Heart", "Negatron Cloak", "Needlessly Large Rod", "Banshee's Veil", "Rabadon's Deathcap", }
        itemsNotToSell = { "Rod of Ages", "Ionian Boots of Lucidity", "Abyssal Scepter", "Frozen Heart", "Banshee's Veil", "Rabadon's Deathcap", }
        tools = { { "Sight Ward", 0, 3, 11, 18, }, }
    elseif champ == "Karthus" then
        itemsToBuy = { "Sapphire Crystal", "Boots of Speed", "Tear of the Goddess", "Sorcerer's Shoes", "Rabadon's Deathcap", "Needlessly Large Rod", "Archangel's Staff", "Zhonya's Hourglass", "Abyssal Scepter", "Void Staff", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rabadon's Deathcap", "Archangel's Staff", "Zhonya's Hourglass", "Abyssal Scepter", "Void Staff", }
        tools = { { "Mana Potion", 0, 3, 1, 10, }, { "Health Potion", 1, 3, 1, 10, }, }
    elseif champ == "Kassadin" then
        itemsToBuy = { "Boots of Speed", "Catalyst the Protector", "Rod of Ages", "Sorcerer's Shoes", "Rabadon's Deathcap", "Banshee's Veil", "Void Staff", "Abyssal Scepter", }
        itemsNotToSell = { "Rod of Ages", "Sorcerer's Shoes", "Rabadon's Deathcap", "Banshee's Veil", "Void Staff", "Abyssal Scepter", }
        tools = { { "Health Potion", 1, 3, 1, 10, }, }
    elseif champ == "Katarina" then
        itemsToBuy = { "Boots of Speed", "Hextech Revolver", "Ionian Boots of Lucidity", "Rylai's Crystal Scepter", "Rabadon's Deathcap", "Hextech Gunblade", "Zhonya's Hourglass", "Void Staff", }
        itemsNotToSell = { "Ionian Boots of Lucidity", "Rylai's Crystal Scepter", "Rabadon's Deathcap", "Hextech Gunblade", "Zhonya's Hourglass", "Void Staff", }
        tools = { { "Health Potion", 1, 3, 1, 10, }, { "Elixir of Brilliance", 0, 1, 15, 18, }, }
    elseif champ == "Kayle" then
        itemsToBuy = { "Doran's Ring", "Boots of Speed", "Blasting Wand", "Mercury's Treads", "Guinsoo's Rageblade", "Nashor's Tooth", "Madred's Bloodrazor", "Banshee's Veil", "Hextech Gunblade", }
        itemsNotToSell = { "Mercury's Treads", "Guinsoo's Rageblade", "Nashor's Tooth", "Madred's Bloodrazor", "Banshee's Veil", "Hextech Gunblade", }
        tools = {}
    elseif champ == "Kennen" then
        itemsToBuy = { "Doran's Shield", "Hextech Revolver", "Boots of Speed", "Will of the Ancients", "Sorcerer's Shoes", "Rylai's Crystal Scepter", "Rabadon's Deathcap", "Abyssal Scepter", "Zhonya's Hourglass", }
        itemsNotToSell = { "Will of the Ancients", "Sorcerer's Shoes", "Rylai's Crystal Scepter", "Rabadon's Deathcap", "Abyssal Scepter", "Zhonya's Hourglass", }
        tools = {}
    elseif champ == "KogMaw" then
        itemsToBuy = { "Doran's Blade", "Berserker's Greaves", "Phantom Dancer", "Executioner's Calling", "Phantom Dancer", "Infinity Edge", "The Bloodthirster", }
        itemsNotToSell = { "Berserker's Greaves", "Phantom Dancer", "Executioner's Calling", "Phantom Dancer", "Infinity Edge", "The Bloodthirster", }
        tools = {}
    elseif champ == "LeBlanc" then
        itemsToBuy = { "Amplifying Tome", "Mejai's Soulstealer", "Boots of Speed", "Sorcerer's Shoes", "Needlessly Large Rod", "Rabadon's Deathcap", "Catalyst the Protector", "Rod of Ages", "Blasting Wand", "Archangel's Staff", "Blasting Wand", "Void Staff", }
        itemsNotToSell = { "Mejai's Soulstealer", "Sorcerer's Shoes", "Rabadon's Deathcap", "Rod of Ages", "Archangel's Staff", "Void Staff", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Elixir of Brilliance", 0, 1, 15, 18, }, { "Elixir of Fortitude", 0, 1, 18, 18, }, }
    elseif champ == "LeeSin" then
        itemsToBuy = { "Vampiric Scepter", "Cloth Armor", "Wriggle's Lantern", "Mercury's Treads", "Phage", "Atma's Impaler", "Trinity Force", "Warmog's Armor", "Force of Nature", "The Bloodthirster", }
        itemsNotToSell = { "Mercury's Treads", "Atma's Impaler", "Trinity Force", "Warmog's Armor", "Force of Nature", "The Bloodthirster", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Wriggle's Lantern", 1, 0, 1, 15, }, }
    elseif champ == "Leona" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Boots of Speed", "Heart of Gold", "Mercury's Treads", "Glacial Shroud", "Giant's Belt", "Negatron Cloak", "Shurelya's Reverie", "Frozen Heart", "Force of Nature", "Warmog's Armor", }
        itemsNotToSell = { "Heart of Gold", "Mercury's Treads", "Shurelya's Reverie", "Frozen Heart", "Force of Nature", "Warmog's Armor", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Oracle's Elixir", 0, 1, 15, 18, }, { "Elixir of Fortitude", 0, 1, 18, 18, }, { "Elixir of Agility", 0, 1, 18, 18, }, { "Elixir of Brilliance", 0, 1, 18, 18, }, }
    elseif champ == "Lux" then
        itemsToBuy = { "Doran's Ring", "Kage's Lucky Pick", "Boots of Speed", "Rabadon's Deathcap", "Sorcerer's Shoes", "Lich Bane", "Zhonya's Hourglass", "Void Staff", "Morello's Evil Tome", "Banshee's Veil", }
        itemsNotToSell = { "Sorcerer's Shoes", "Lich Bane", "Zhonya's Hourglass", "Void Staff", "Morello's Evil Tome", "Banshee's Veil", }
        tools = { { "Sight Ward", 1, 3, 5, 10, }, { "Sight Ward", 0, 3, 11, 18, }, { "Elixir of Brilliance", 0, 1, 15, 18, }, { "Rabadon's Deathcap", 1, 0, 0, 17, }, }
    elseif champ == "Malphite" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Boots of Speed", "Heart of Gold", "Mercury's Treads", "Glacial Shroud", "Negatron Cloak", "Warmog's Armor", "Frozen Heart", "Force of Nature", "Randuin's Omen", "Guardian Angel", }
        itemsNotToSell = { "Mercury's Treads", "Warmog's Armor", "Frozen Heart", "Force of Nature", "Randuin's Omen", "Guardian Angel", }
        tools = { { "Mana Potion", 0, 3, 1, 10, }, }
    elseif champ == "Malzahar" then
        itemsToBuy = { "Doran's Ring", "Boots of Speed", "Doran's Ring", "Tear of the Goddess", "Sorcerer's Shoes", "Catalyst the Protector", "Archangel's Staff", "Banshee's Veil", "Rabadon's Deathcap", "Zhonya's Hourglass", "Void Staff", }
        itemsNotToSell = { "Sorcerer's Shoes", "Archangel's Staff", "Banshee's Veil", "Rabadon's Deathcap", "Zhonya's Hourglass", "Void Staff", }
        tools = { { "Elixir of Brilliance", 0, 1, 15, 18, }, { "Oracle's Elixir", 0, 1, 18, 18, }, }
    elseif champ == "Maokai" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Catalyst the Protector", "Boots of Swiftness", "Eleisa's Miracle", "Rod of Ages", "Glacial Shroud", "Negatron Cloak", "Frozen Heart", "Force of Nature", "Abyssal Scepter", "Locket of the Iron Solari", }
        itemsNotToSell = { "Abyssal Scepter", "Boots of Swiftness", "Eleisa's Miracle", "Frozen Heart", "Force of Nature", "Locket of the Iron Solari", }
        tools = {}
        if getMapName() == "Summoners Rift" and isJungling() then
            itemsToBuy = { "Regrowth Pendant", "Boots of Speed", "Philosopher's Stone", "Heart of Gold", "Mercury's Treads", "Rod of Ages", "Glacial Shroud", "Aegis of the Legion", "Shurelya's Reverie", "Force of Nature", "Frozen Heart", }
            itemsNotToSell = { "Mercury's Treads", "Rod of Ages", "Aegis of the Legion", "Shurelya's Reverie", "Force of Nature", "Frozen Heart", }
            tools = {}
        end
    elseif champ == "MasterYi" then
        itemsToBuy = { "Vampiric Scepter", "Boots of Speed", "Long Sword", "Wriggle's Lantern", "Mercury's Treads", "Zeal", "Phage", "Phantom Dancer", "B. F. Sword", "Infinity Edge", "Frozen Mallet", "Quicksilver Sash", }
        itemsNotToSell = { "Wriggle's Lantern", "Mercury's Treads", "Phantom Dancer", "Infinity Edge", "Frozen Mallet", "Quicksilver Sash", }
        tools = {}
    elseif champ == "MissFortune" then
        itemsToBuy = { "Boots of Speed", "Sapphire Crystal", "Tear of the Goddess", "Manamune", "Berserker's Greaves", "Long Sword", "Sword of the Occult", "B. F. Sword", "Pickaxe", "Cloak of Agility", "Infinity Edge", "Trinity Force", "The Black Cleaver", }
        itemsNotToSell = { "Infinity Edge", "Trinity Force", "The Black Cleaver", "Manamune", "Berserker's Greaves", "Sword of the Occult", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Mordekaiser" then
        itemsToBuy = { "Regrowth Pendant", "Sorcerer's Shoes", "Will of the Ancients", "Rylai's Crystal Scepter", "Lich Bane", "Abyssal Scepter", "Guardian Angel", }
        itemsNotToSell = { "Sorcerer's Shoes", "Will of the Ancients", "Rylai's Crystal Scepter", "Lich Bane", "Abyssal Scepter", "Guardian Angel", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Morgana" then
        itemsToBuy = { "Doran's Ring", "Boots of Speed", "Doran's Ring", "Sorcerer's Shoes", "Catalyst the Protector", "Rod of Ages", "Rabadon's Deathcap", "Zhonya's Hourglass", "Void Staff", "Banshee's Veil", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rod of Ages", "Rabadon's Deathcap", "Zhonya's Hourglass", "Void Staff", "Banshee's Veil", }
        tools = {}
    elseif champ == "Nasus" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Mercury's Treads", "Glacial Shroud", "Sheen", "Sunfire Cape", "Banshee's Veil", "Trinity Force", "Frozen Heart", "Force of Nature", }
        itemsNotToSell = { "Mercury's Treads", "Sunfire Cape", "Banshee's Veil", "Trinity Force", "Frozen Heart", "Force of Nature", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Nautilus" then
        itemsToBuy = { "Boots of Speed", "Heart of Gold", "Mercury's Treads", "Warmog's Armor", "Glacial Shroud", "Frozen Heart", "Banshee's Veil", "Force of Nature", "Thornmail", }
        itemsNotToSell = { "Mercury's Treads", "Warmog's Armor", "Frozen Heart", "Banshee's Veil", "Force of Nature", "Thornmail", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Nidalee" then
        itemsToBuy = { "Boots of Speed", "Vampiric Scepter", "Wriggle's Lantern", "The Brutalizer", "Mercury's Treads", "Phage", "Giant's Belt", "Atma's Impaler", "Warmog's Armor", "Sheen", "Trinity Force", "Youmuu's Ghostblade", "Last Whisper", }
        itemsNotToSell = { "Mercury's Treads", "Atma's Impaler", "Warmog's Armor", "Trinity Force", "Youmuu's Ghostblade", "Last Whisper", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Wriggle's Lantern", 1, 0, 1, 16, }, }
    elseif champ == "Nocturne" then
        itemsToBuy = { "Vampiric Scepter", "Boots of Speed", "Wriggle's Lantern", "Berserker's Greaves", "The Brutalizer", "Negatron Cloak", "Frozen Mallet", "Atma's Impaler", "Youmuu's Ghostblade", "Banshee's Veil", }
        itemsNotToSell = { "Wriggle's Lantern", "Berserker's Greaves", "Frozen Mallet", "Atma's Impaler", "Youmuu's Ghostblade", "Banshee's Veil", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Nunu" then
        itemsToBuy = { "Boots of Speed", "Health Potion", "Mana Potion", "Mana Potion", "Doran's Ring", "Rabadon's Deathcap", "Sorcerer's Shoes", "Giant's Belt", "Blasting Wand", "Amplifying Tome", "Rylai's Crystal Scepter", "Banshee's Veil", "Void Staff", "Frozen Heart", }
        itemsNotToSell = { "Rabadon's Deathcap", "Sorcerer's Shoes", "Rylai's Crystal Scepter", "Banshee's Veil", "Void Staff", "Frozen Heart", }
        tools = {}
    elseif champ == "Olaf" then
        itemsToBuy = { "Vampiric Scepter", "Boots of Speed", "Madred's Razors", "Wriggle's Lantern", "Ruby Crystal", "Mercury's Treads", "Phage", "Frozen Mallet", "Zeal", "Chain Vest", "Atma's Impaler", "Phantom Dancer", "Banshee's Veil", "The Bloodthirster", }
        itemsNotToSell = { "Mercury's Treads", "Frozen Mallet", "Atma's Impaler", "Phantom Dancer", "Banshee's Veil", "The Bloodthirster", }
        tools = { { "Wriggle's Lantern", 1, 0, 0, 16, }, }
    elseif champ == "Orianna" then
        itemsToBuy = { "Boots of Speed", "Doran's Ring", "Doran's Ring", "Hextech Revolver", "Needlessly Large Rod", "Boots of Mobility", "Will of the Ancients", "Rabadon's Deathcap", "Nashor's Tooth", "Lich Bane", "Zhonya's Hourglass", }
        itemsNotToSell = { "Boots of Mobility", "Will of the Ancients", "Rabadon's Deathcap", "Nashor's Tooth", "Lich Bane", "Zhonya's Hourglass", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Pantheon" then
        itemsToBuy = { "Boots of Speed", "Doran's Blade", "Doran's Blade", "The Brutalizer", "Mercury's Treads", "Giant's Belt", "Warmog's Armor", "Chain Vest", "Atma's Impaler", "B. F. Sword", "The Bloodthirster", "Youmuu's Ghostblade", "B. F. Sword", "Infinity Edge", }
        itemsNotToSell = { "Mercury's Treads", "Warmog's Armor", "Atma's Impaler", "The Bloodthirster", "Youmuu's Ghostblade", "Infinity Edge", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Poppy" then
        itemsToBuy = { "Sheen", "Berserker's Greaves", "Zeal", "Phage", "Trinity Force", "Zeal", "Phantom Dancer", "Vampiric Scepter", "The Bloodthirster", "B. F. Sword", "The Black Cleaver", "B. F. Sword", "Infinity Edge", }
        itemsNotToSell = { "Berserker's Greaves", "Trinity Force", "Phantom Dancer", "The Bloodthirster", "The Black Cleaver", "Infinity Edge", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Rammus" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Boots of Speed", "Heart of Gold", "Mercury's Treads", "Giant's Belt", "Guardian Angel", "Sunfire Cape", "Randuin's Omen", "Warmog's Armor", "Thornmail", "Force of Nature", "Frozen Heart", "Banshee's Veil", }
        itemsNotToSell = { "Randuin's Omen", "Warmog's Armor", "Thornmail", "Force of Nature", "Frozen Heart", "Banshee's Veil", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Guardian Angel", 1, 0, 1, 17, }, }
    elseif champ == "Renekton" then
        itemsToBuy = { "Boots of Speed", "The Brutalizer", "Giant's Belt", "Mercury's Treads", "Warmog's Armor", "Atma's Impaler", "Negatron Cloak", "Last Whisper", "Force of Nature", "The Bloodthirster", }
        itemsNotToSell = { "Mercury's Treads", "Warmog's Armor", "Atma's Impaler", "Last Whisper", "Force of Nature", "The Bloodthirster", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Rengar" then
        itemsToBuy = { "Boots of Speed", "Health Potion", "Health Potion", "Health Potion", "Doran's Blade", "Phage", "Bonetooth Necklace", "Mercury's Treads", "B. F. Sword", "Frozen Mallet", "The Bloodthirster", "Hexdrinker","Maw of Malmortius", "Randuin's Omen", }
        itemsNotToSell = { "Mercury's Treads", "Bonetooth Necklace", "Frozen Mallet", "Maw of Malmortius", "The Bloodthirster", "Randuin's Omen", }
        tools = {}
--        if isJungling() and getMapName() == "Summoners Rift" then
--            itemsToBuy = { "Cloth Armor", "Madred's Razors", "Boots of Speed", "Wriggle's Lantern", "Mercury's Treads", "Bonetooth Necklace", "Phage", "Frozen Mallet", "Atma's Impaler", "Guardian Angel", }
--            itemsNotToSell = { "Wriggle's Lantern", "Mercury's Treads", "Bonetooth Necklace", "Frozen Mallet", "Atma's Impaler", "Guardian Angel", }
--            tools = { { "Health Potion", 0, 3, 1, 10, }, }
--        end
    elseif champ == "Riven" then
        itemsToBuy = { "Boots of Speed", "Wriggle's Lantern", "Mercury's Treads", "Warmog's Armor", "Atma's Impaler", "The Bloodthirster", "Last Whisper", "Guardian Angel", }
        itemsNotToSell = { "Mercury's Treads", "Warmog's Armor", "Atma's Impaler", "The Bloodthirster", "Last Whisper", "Guardian Angel", }
        tools = { { "Wriggle's Lantern", 1, 0, 1, 16, }, }
    elseif champ == "Rumble" then
        itemsToBuy = { "Boots of Speed", "Hextech Revolver", "Giant's Belt", "Mercury's Treads", "Rylai's Crystal Scepter", "Chain Vest", "Abyssal Scepter", "Sunfire Cape", "Rabadon's Deathcap", "Hextech Gunblade", }
        itemsNotToSell = { "Mercury's Treads", "Rylai's Crystal Scepter", "Abyssal Scepter", "Sunfire Cape", "Rabadon's Deathcap", "Hextech Gunblade", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Ryze" then
        itemsToBuy = { "Sapphire Crystal", "Tear of the Goddess", "Boots of Speed", "Sapphire Crystal", "Catalyst the Protector", "Ionic Boots of Lucidity", "Archangel's Staff", "Glacial Shroud", "Hextech Revolver", "Rod of Ages", "Will of the Ancients", "Banshee's Veil", "Frozen Heart", }
        itemsNotToSell = { "Ionic Boots of Lucidity", "Banshee's Veil", "Frozen Heart", "Rod of Ages", "Archangel's Staff", "Will of the Ancients", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Sejuani" then
        itemsToBuy = { "Cloth Armor", "Boots of Speed", "Philosopher's Stone", "Heart of Gold", "Phage", "Mercury's Treads", "Warden's Mail", "Shurelya's Reverie", "Randuin's Omen", "Negatron Cloak", "Force of Nature", "Frozen Mallet", "Warmog's Armor", }
        itemsNotToSell = { "Mercury's Treads", "Shurelya's Reverie", "Randuin's Omen", "Force of Nature", "Frozen Mallet", "Warmog's Armor", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Shaco" then
        itemsToBuy = { "Boots of Speed", "Wriggle's Lantern", "Boots of Mobility", "Trinity Force", "Infinity Edge", "Guardian Angel", "The Bloodthirster", }
        itemsNotToSell = { "Wriggle's Lantern", "Boots of Mobility", "Trinity Force", "Infinity Edge", "Guardian Angel", "The Bloodthirster", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Shen" then
        itemsToBuy = { "Ruby Crystal", "Boots of Speed", "Heart of Gold", "Mercury's Treads", "Giant's Belt", "Sunfire Cape", "Force of Nature", "Spirit Visage", "Randuin's Omen", "Rylai's Crystal Scepter", }
        itemsNotToSell = { "Mercury's Treads", "Sunfire Cape", "Force of Nature", "Spirit Visage", "Randuin's Omen", "Rylai's Crystal Scepter", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "Shyvana" then
        itemsToBuy = { "Boots of Speed", "Wriggle's Lantern", "Mercury's Treads", "Recurve Bow", "Wit's End", "Phage", "Zeal", "Trinity Force", "Giant's Belt", "B. F. Sword", "The Bloodthirster", "Sunfire Cape", "Madred's Bloodrazor", }
        itemsNotToSell = { "Mercury's Treads", "Wit's End", "Trinity Force", "The Bloodthirster", "Sunfire Cape", "Madred's Bloodrazor", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Wriggle's Lantern", 1, 0, 1, 16, }, }
    elseif champ == "Singed" then
        itemsToBuy = { "Sapphire Crystal", "Catalyst the Protector", "Boots of Speed", "Rod of Ages", "Mercury's Treads", "Force of Nature", "Giant's Belt", "Rylai's Crystal Scepter", "Guardian Angel", "Rabadon's Deathcap", }
        itemsNotToSell = { "Rod of Ages", "Mercury's Treads", "Force of Nature", "Rylai's Crystal Scepter", "Guardian Angel", "Rabadon's Deathcap", }
        tools = { { "Health Potion", 1, 2, 1, 5, }, { "Mana Potion", 0, 3, 1, 7, }, }
    elseif champ == "Sion" then
        itemsToBuy = { "Doran's Blade", "Berserker's Greaves", "Mercury's Treads", "Zeal", "B. F. Sword", "Phantom Dancer", "Infinity Edge", "Warmog's Armor", "Atma's Impaler", "Force of Nature", }
        itemsNotToSell = { "Mercury's Treads", "Phantom Dancer", "Infinity Edge", "Warmog's Armor", "Atma's Impaler", "Force of Nature", }
        tools = {}
    elseif champ == "Sivir" then
        itemsToBuy = { "Boots of Speed","Doran's Blade", "Doran's Blade", "Berserker's Greaves", "B. F. Sword", "The Bloodthirster", "Pickaxe", "Zeal", "B. F. Sword", "Infinity Edge", "Phantom Dancer", "Last Whisper", }
        itemsNotToSell = { "Berserker's Greaves", "The Bloodthirster", "Infinity Edge", "Phantom Dancer", "Thornmail", "Last Whisper", }
        tools = {}
    elseif champ == "Skarner" then
        itemsToBuy = { "Doran's Shield", "Boots of Speed", "Sheen", "Catalyst the Protector", "Mercury's Treads", "Rod of Ages", "Trinity Force", "Wit's End", "Guardian Angel", "Hextech Gunblade", }
        itemsNotToSell = { "Mercury's Treads", "Rod of Ages", "Trinity Force", "Wit's End", "Guardian Angel", "Hextech Gunblade", }
        tools = {}
        if getMapName() == "Summoners Rift" and isJungling() then
            itemsToBuy = { "Cloth Armor", "Wriggle's Lantern", "Boots of Speed", "Heart of Gold", "Mercury's Treads", "Sheen", "Trinity Force", "Banshee's Veil", "Randuin's Omen", "Atma's Impaler", "Hextech Gunblade", }
            itemsNotToSell = { "Mercury's Treads", "Trinity Force", "Banshee's Veil", "Randuin's Omen", "Atma's Impaler", "Hextech Gunblade", }
            tools = { { "Health Potion", 0, 5, 1, 6, }, { "Wriggle's Lantern", 1, 0, 1, 17, }, }
        end
    elseif champ == "Sona" then
        itemsToBuy = { "Faerie Charm", "Philosopher's Stone", "Boots of Speed", "Heart of Gold", "Ionian Boots of Lucidity", "Aegis of the Legion", "Shurelya's Reverie", "Will of the Ancients", "Randuin's Omen", }
        itemsNotToSell = { "Ionian Boots of Lucidity", "Aegis of the Legion", "Shurelya's Reverie", "Will of the Ancients", "Randuin's Omen", }
        tools = { { "Sight Ward", 1, 5, 11, 18, }, { "Mana Potion", 0, 3, 1, 10, }, }
    elseif champ == "Soraka" then
        itemsToBuy = { "Doran's Ring", "Boots of Speed", "Philosopher's Stone", "Ionian Boots of Lucidity", "Hextech Revolver", "Rod of Ages", "Will of the Ancients", "Shurelya's Reverie", "Rabadon's Deathcap", "Rylai's Crystal Scepter", }
        itemsNotToSell = { "Ionian Boots of Lucidity", "Rod of Ages", "Will of the Ancients", "Shurelya's Reverie", "Rabadon's Deathcap", "Rylai's Crystal Scepter", }
        tools = {}
    elseif champ == "Swain" then
        itemsToBuy = { "Boots of Speed", "Catalyst the Protector", "Sorcerer's Shoes", "Rod of Ages", "Blasting Wand", "Rabadon's Deathcap", "Chain Vest", "Zhonya's Hourglass", "Amplifying Tome", "Amplifying Tome", "Hextech Revolver", "Will of the Ancients", "Negatron Cloak", "Abyssal Scepter", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rod of Ages", "Rabadon's Deathcap", "Zhonya's Hourglass", "Will of the Ancients", "Abyssal Scepter", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Elixir of Brilliance", 0, 1, 15, 18, }, { "Elixir of Fortitude", 0, 1, 18, 18, }, { "Oracle's Elixir", 0, 1, 18, 18, }, { "Elixir of Agility", 0, 1, 18, 18, }, }
    elseif champ == "Talon" then
        itemsToBuy = { "Ionian Boots of Lucidity", "Long Sword", "Long Sword", "The Brutalizer", "B. F. Sword", "Vampiric Scepter", "The Bloodthirster", "Zeal", "Phage", "Sheen", "Trinity Force", "Youmuu's Ghostblade", "B. F. Sword", "Pickaxe", "Cloak of Agility", "Infinity Edge", "Frozen Mallet", }
        itemsNotToSell = { "Ionian Boots of Lucidity", "The Bloodthirster", "Trinity Force", "Youmuu's Ghostblade", "Infinity Edge", "Frozen Mallet", }
        tools = { { "Health Potion", 1, 2, 1, 5, }, { "Mana Potion", 0, 3, 1, 7, }, }
    elseif champ == "Taric" then
        itemsToBuy = { "Faerie Charm", "Philosopher's Stone", "Boots of Speed", "Heart of Gold", "Mercury's Treads", "Aegis of the Legion", "Shurelya's Reverie", "Randuin's Omen", "Banshee's Veil", "Frozen Heart", }
        itemsNotToSell = { "Mercury's Treads", "Aegis of the Legion", "Shurelya's Reverie", "Randuin's Omen", "Banshee's Veil", "Frozen Heart", }
        tools = { { "Sight Ward", 0, 2, 1, 15, }, { "Health Potion", 0, 2, 1, 5, }, { "Mana Potion", 0, 3, 1, 7, }, { "Oracle's Elixir", 0, 1, 15, 18, }, }
    elseif champ == "Teemo" then
        itemsToBuy = { "Doran's Blade", "Boots of Speed", "Berserker's Greaves", "Malady", "Recurve Bow", "Wit's End", "Recurve Bow", "Madred's Bloodrazor", "Phage", "Giant's Belt", "Frozen Mallet", "Guardian's Angel", }
        itemsNotToSell = { "Berserker's Greaves", "Malady", "Wit's End", "Madred's Bloodrazor", "Frozen Mallet", "Guardian Angel", }
        tools = {}
    elseif champ == "Tristana" then
        itemsToBuy = { "Doran's Blade", "Doran's Blade", "Boots of Speed", "B. F. Sword", "Berserker's Greaves", "Infinity Edge", "Zeal", "Phantom Dancer", "Vampiric Scepter", "Last Whisper", "Quicksilver Sash", "The Bloodthirster", }
        itemsNotToSell = { "Berserker's Greaves", "Infinity Edge", "Phantom Dancer", "Last Whisper", "Quicksilver Sash", "The Bloodthirster", }
        tools = {}
    elseif champ == "Trundle" then
        itemsToBuy = { "Wriggle's Lantern", "Mercury's Treads", "Frozen Mallet", "The Bloodthirster", "The Black Cleaver", "Guardian Angel", }
        itemsNotToSell = { "Wriggle's Lantern", "Mercury's Treads", "Frozen Mallet", "The Bloodthirster", "The Black Cleaver", "Guardian Angel", }
        tools = {}
    elseif champ == "Tryndamere" then
        itemsToBuy = { "Boots of Speed", "Cloth Armor", "Madred's Razors", "Wriggle's Lantern", "Zeal", "Berserker's Greaves", "Phantom Dancer", "Infinity Edge", }
        itemsNotToSell = { "Wriggle's Lantern", "Berserker's Greaves", "Phantom Dancer", "Infinity Edge", "Quicksilver Sash", "The Bloodthirster", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
    elseif champ == "TwistedFate" then
        itemsToBuy = { "Doran's Blade", "Berserker's Greaves", "Phage", "Sheen", "Trinity Force", "B. F. Sword", "Vampiric Scepter", "The Black Cleaver", "B. F. Sword", "Infinity Edge", "Catalyst the Protector", "Banshee's Veil", "The Bloodthirster", }
        itemsNotToSell = { "Berserker's Greaves", "Trinity Force", "The Black Cleaver", "Infinity Edge", "Banshee's Veil", "The Bloodthirster", }
        tools = {}
    elseif champ == "Twitch" then
        itemsToBuy = { "Doran's Blade", "Doran's Blade", "Boots of Mobility", "B. F. Sword", "Vampiric Scepter", "Infinity Edge", "Zeal", "Phantom Dancer", "The Black Cleaver", "The Bloodthirster", "Banshee's Veil", }
        itemsNotToSell = { "Boots of Mobility", "Infinity Edge", "Phantom Dancer", "The Black Cleaver", "The Bloodthirster", "Banshee's Veil", }
        tools = { { "Mana Potion", 1, 3, 2, 10, }, { "Health Potion", 1, 3, 2, 10, }, }
    elseif champ == "Udyr" then
        itemsToBuy = { "Vampiric Scepter", "Wriggle's Lantern", "Boots of Mobility", "Wit's End", "Giant's Belt", "Chain Vest", "Phage", "Frozen Mallet", "Atma's Impaler", "Warmog's Armor", "Madred's Bloodrazor", "The Bloodthirster", }
        itemsNotToSell = { "Boots of Mobility", "Frozen Mallet", "Atma's Impaler", "Warmog's Armor", "Madred's Bloodrazor", "The Bloodthirster", }
        tools = {}
        if getMapName() == "Summoners Rift" and isJungling() then
            itemsToBuy = { "Cloth Armor", "Wriggle's Lantern", "Boots of Speed", "Sheen", "Phage", "Mercury's Treads", "Zeal", "Trinity Force", "Sunfire Cape", "Atma's Impaler", "Randuin's Omen", }
            itemsNotToSell = { "Wriggle's Lantern", "Mercury's Treads", "Trinity Force", "Sunfire Cape", "Atma's Impaler", "Randuin's Omen", }
            tools = { { "Health Potion", 0, 3, 1, 10, }, }
        end
    elseif champ == "Urgot" then
        itemsToBuy = { "Meki Pendant", "Tear of the Goddess", "Boots of Speed", "The Brutalizer", "Ionian Boots of Lucidity", "Manamune", "The Bloodthirster", "Last Whisper", "Frozen Heart", "Banshee's Veil", }
        itemsNotToSell = { "Ionian Boots of Lucidity", "Manamune", "The Bloodthirster", "Last Whisper", "Frozen Heart", "Banshee's Veil", }
        tools = { { "Mana Potion", 0, 3, 1, 10, }, { "Health Potion", 1, 3, 1, 10, }, }
    elseif champ == "Varus" then
        itemsToBuy = { "Doran's Blade", "Boots of Speed", "B. F. Sword", "Berserker's Greaves", "Pickaxe", "Infinity Edge", "Zeal", "Vampiric Scepter", "Phantom Dancer", "The Bloodthirster", "Banshee's Veil", "Last Whisper", }
        itemsNotToSell = { "Berserker's Greaves", "Infinity Edge", "Phantom Dancer", "The Bloodthirster", "Banshee's Veil", "Last Whisper", }
        tools = {}
    elseif champ == "Vayne" then
        itemsToBuy = { "Doran's Blade", "Berserker's Greaves", "B. F. Sword", "The Black Cleaver", "Zeal", "Vampiric Scepter", "The Bloodthirster", "Phantom Dancer", "Infinity Edge", "Guardian Angel", }
        itemsNotToSell = { "Berserker's Greaves", "The Black Cleaver", "The Bloodthirster", "Phantom Dancer", "Infinity Edge", "Guardian Angel", }
        tools = { { "Elixir of Fortitude", 0, 1, 15, 18, }, { "Elixir of Agility", 0, 1, 18, 18, }, }
    elseif champ == "Veigar" then
        itemsToBuy = { "Doran's Ring", "Boots of Speed", "Doran's Ring", "Kage's Lucky Pick", "Sorcerer's Shoes", "Rabadon's Deathcap", "Deathfire Grasp", "Void Staff", "Zhonya's Hourglass", "Banshee's Veil", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rabadon's Deathcap", "Deathfire Grasp", "Void Staff", "Zhonya's Hourglass", "Banshee's Veil", }
        tools = {}
    elseif champ == "Viktor" then
        itemsToBuy = { "Boots of Speed", "Doran's Ring", "Doran's Ring", "Needlessly Large Rod", "Rabadon's Deathcap", "Sorcerer's Shoes", "Rylai's Crystal Scepter", "Augment: Gravity", "Rod of Ages", "Void Staff", "Zhonya's Hourglass", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rylai's Crystal Scepter", "Augment: Gravity", "Rod of Ages", "Void Staff", "Zhonya's Hourglass", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Rabadon's Deathcap", 1, 0, 0, 17, }, }
    elseif champ == "Vladimir" then
        itemsToBuy = { "Boots of Speed", "Hextech Revolver", "Will of the Ancients", "Ionian Boots of Lucidity", "Needlessly Large Rod", "Rabadon's Deathcap", "Giant's Belt", "Blasting Wand", "Rylai's Crystal Scepter", "Needlessly Large Rod", "Blasting Wand", "Zhonya's Hourglass", "Void Staff", "Abyssal Scepter", "Lich Bane", "Warmog's Armor", }
        itemsNotToSell = { "Rylai's Crystal Scepter", "Zhonya's Hourglass", "Void Staff", "Abyssal Scepter", "Lich Bane", "Warmog's Armor", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Elixir of Brilliance", 0, 1, 15, 18, }, { "Elixir of Fortitude", 0, 1, 18, 18, }, { "Oracle's Elixir", 0, 1, 18, 18, }, { "Rabadon's Deathcap", 1, 0, 1, 17, }, }
    elseif champ == "Volibear" then
        itemsToBuy = { "Regrowth Pendant", "Philosopher's Stone", "Boots of Speed", "Doran's Shield", "Mercury's Treads", "Kindlegem", "Spirit Visage", "Catalyst the Protector", "Giant's Belt", "Warmog's Armor", "Chain Vest", "Atma's Impaler", "Giant's Belt", "Rylai's Crystal Scepter", "Banshee's Veil", }
        itemsNotToSell = { "Mercury's Treads", "Spirit Visage", "Warmog's Armor", "Atma's Impaler", "Rylai's Crystal Scepter", "Banshee's Veil", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, }
        if getMapName() == "Summoners Rift" and isJungling() then
            itemsToBuy = { "Regrowth Pendant", "Boots of Speed", "Warmog's Armor", "Mercury's Treads", "Atma's Impaler", "Frozen Mallet", "Wit's End", "Force of Nature", "Spirit Visage", "Shurelya's Reverie", "Zeke's Herald", }
            itemsNotToSell = { "Frozen Mallet", "Wit's End", "Force of Nature", "Spirit Visage", "Shurelya's Reverie", "Zeke's Herald", }
            tools = { { "Mana Potion", 0, 2, 1, 5, }, { "Health Potion", 0, 3, 1, 10, }, { "Elixir of Fortitude", 0, 1, 15, 18, }, }
        end
        if getMapName() == "Dominion" then
            itemsToBuy = { "Boots of Speed", "Prospector's Blade", "Spirit Visage", "Mercury's Treads", "Phage", "Chain Vest", "Frozen Mallet", "Atma's Impaler", "Sanguine Blade", "Kitae's Bloodrazor", }
            itemsNotToSell = { "Spirit Visage", "Mercury's Treads", "Frozen Mallet", "Atma's Impaler", "Sanguine Blade", "Kitae's Bloodrazor", }
            tools = {}
        end
    elseif champ == "Warwick" then
        itemsToBuy = { "Doran's Ring", "Kindlegem", "Chalice of Harmony", "Boots of Speed", "Spirit Visage", "Giant's Belt", "Sorcerer's Shoes", "Wit's End", "Sunfire Cape", "Madred's Bloodrazor", }
        itemsNotToSell = { "Chalice of Harmony", "Spirit Visage", "Sorcerer's Shoes", "Wit's End", "Sunfire Cape", "Madred's Bloodrazor", }
        tools = {}
        if getMapName() == "Summoners Rift" and isJungling() then
            itemsToBuy = { "Cloth Armor", "Madred's Razors", "Boots of Speed", "Sorcerer's Shoes", "Vampiric Scepter", "Madred's Bloodrazor", "Wit's End", "Malady", "Banshee's Veil", "Hextech Gunblade", "The Black Cleaver", "Guardian Angel", "Sunfire Cape", }
            itemsNotToSell = { "Malady", "Banshee's Veil", "Hextech Gunblade", "The Black Cleaver", "Guardian Angel", "Sunfire Cape", }
            tools = { { "Health Potion", 0, 3, 1, 10, }, }
        end
    elseif champ == "MonkeyKing" then
        itemsToBuy = { "Doran's Blade", "Mercury's Treads", "Phage", "Vampiric Scepter", "Sheen", "Trinity Force", "The Brutalizer", "The Bloodthirster", "Youmuu's Ghostblade", "Infinity Edge", }
        itemsNotToSell = { "Doran's Blade", "Mercury's Treads", "Vampiric Scepter", "Trinity Force", "The Bloodthirster", "Youmuu's Ghostblade", "Infinity Edge", }
        tools = { { "Elixir of Fortitude", 0, 1, 15, 18, }, { "Elixir of Agility", 0, 1, 18, 18, }, { "Elixir of Brilliance", 0, 1, 18, 18, }, }
    elseif champ == "Xerath" then
        itemsToBuy = { "Boots of Speed", "Doran's Ring", "Doran's Ring", "Sorcerer's Shoes", "Giant's Belt", "Rylai's Crystal Scepter", "Rabadon's Deathcap", "Chain Vest", "Zhonya's Hourglass", "Negatron Cloak", "Abyssal Scepter", "Blasting Wand", "Void Staff", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rylai's Crystal Scepter", "Rabadon's Deathcap", "Zhonya's Hourglass", "Abyssal Scepter", "Void Staff", }
        tools = { { "Health Potion", 0, 3, 1, 10, }, { "Elixir of Brilliance", 0, 1, 15, 18, }, { "Elixir of Fortitude", 0, 1, 18, 18, }, { "Oracle's Elixir", 0, 1, 18, 18, }, { "Elixir of Agility", 0, 1, 18, 18, }, }
    elseif champ == "XinZhao" then
        itemsToBuy = { "Dagger", "Berserker's Greaves", "B. F. Sword", "The Black Cleaver", "Zeal", "Phantom Dancer", "Zeal", "Sheen", "Trinity Force", "The Bloodthirster", "Infinity Edge", }
        itemsNotToSell = { "Berserker's Greaves", "The Black Cleaver", "Phantom Dancer", "Trinity Force", "The Bloodthirster", "Infinity Edge", }
        tools = {}
    elseif champ == "Yorick" then
        itemsToBuy = { "Meki Pendant", "Boots of Speed", "Tear of the Goddess", "Manamune", "Mercury's Treads", "Ionian Boots of Lucidity", "Frozen Mallet", "Atma's Impaler", "The Bloodthirster", }
        itemsNotToSell = { "Manamune", "Mercury's Treads", "Ionian Boots of Lucidity", "Frozen Mallet", "Atma's Impaler", "The Bloodthirster", }
        tools = { { "Health Potion", 1, 3, 1, 10, }, }
    elseif champ == "Ziggs" then
        itemsToBuy = { "Doran's Ring", "Doran's Ring", "Sorcerer's Shoes", "Needlessly Large Rod", "Rabadon's Deathcap", "Hextech Revolver", "Will of the Ancients", "Zhonya's Hourglass", "Void Staff", "Lich Bane", }
        itemsNotToSell = { "Sorcerer's Shoes", "Rabadon's Deathcap", "Will of the Ancients", "Zhonya's Hourglass", "Void Staff", "Lich Bane", }
        tools = {}
    elseif champ == "Zilean" then
        itemsToBuy = { "Doran's Ring", "Doran's Ring", "Ionian Boots of Lucidity", "Rod of Ages", "Morello's Evil Tome", "Rabadon's Deathcap", "Void Staff", "Zhonya's Hourglass", }
        itemsNotToSell = { "Ionian Boots of Lucidity", "Rod of Ages", "Morello's Evil Tome", "Rabadon's Deathcap", "Void Staff", "Zhonya's Hourglass", }
        tools = {}
    end
    if itemsToBuy ~= nil and itemsNotToSell ~= nil and tools ~= nil then
        for i, v in ipairs(itemsToBuy) do
            if item.ID(v) ~= nil then table.insert(ItemList1, item.ID(v))
            elseif myHero.buffCount then PrintChat("Error: " .. v .. " is not a valid item")
            else print("Error: " .. v .. " is not a valid item")
            end
        end
        for i, v in ipairs(itemsNotToSell) do
            if item.ID(v) then table.insert(ItemList2, item.ID(v))
            elseif myHero.buffCount then PrintChat("Error: " .. v .. " is not a valid item")
            else print("Error: " .. v .. " is not a valid item")
            end
        end
        for i, v in ipairs(tools) do
            ItemList3[i] = v
            if item.ID(v[1]) ~= nil then ItemList3[i][1] = item.ID(v[1])
            elseif myHero.buffCount then PrintChat("Error: " .. v[1] .. " is not a valid item") return false
            else print("Error: " .. v[1] .. " is not a valid item") return false
            end
        end
        if #ItemList1 > 0 and ItemList2 ~= nil and ItemList3 ~= nil then LastChamp = champ return true
        end
    end
    return false
end

function getInventory()
    local ItemSlot = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, }
    for i = 1, 6, 1 do
        if myHero:getInventorySlot(ItemSlot[i]) then
            Inventory[i] = myHero:getInventorySlot(ItemSlot[i])
            InventoryCount[i] = myHero:getInventorySlot(ItemSlot[i])
        else
            Inventory[i], InventoryCount[i] = 0, 0
        end
    end
end

local function writeWindowPositionToFile()
    local file, error = assert(io.open(SCRIPT_PATH .. debug.getinfo(1).short_src:match"^.*[/\\]([^/\\]*)$"))
    if error then return error end
    local t = file:read("*all")
    file:close()
    t = string.gsub(t, "PositionX1 = [-]?%d+", "PositionX1 = " .. PositionX1, 1)
    t = string.gsub(t, "PositionY1 = [-]?%d+", "PositionY1 = " .. PositionY1, 1)
    local file, error = assert(io.open(SCRIPT_PATH .. debug.getinfo(1).short_src:match"^.*[/\\]([^/\\]*)$", "w"))
    if error then return error end
    file:write(t)
    file:close()
end

function OnDraw()
    timeold = time or os.clock()
    time = os.clock()
    FramesPerSecond = 1 / (time - timeold)
    if DebugMode then
        local width = 20
        local ItemSlot = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, }
        for i = 1, 6, 1 do
            if myHero:getInventorySlot(ItemSlot[i]) ~= nil then
                local object = myHero:getInventorySlot(ItemSlot[i])
                local count = myHero:getInventorySlot(ItemSlot[i])
                --PrintChat(tostring(count))
                if count == 0 then
                    return
                else
                    t = item.Name(object).."("..(tostring(count))..")"
                end
                DrawText(t, 14, width, 100, 0xFFFF0000)
                width = width + #t * 7
            end
        end
        width = 10
        for i, v in ipairs(Inventory) do
            if item.Name(v) and InventoryCount[i] then
                local t = item.Name(v).."("..InventoryCount[i]..")"
                DrawText(t, 14, width, 150, 0xFFFF0000)
                width = width + #t * 6
            end
        end
    end


    local function DrawItemWindow(X1, Y1)
        local X1 = X1 + 2 or 10
        local maxHeight = Y1 + 10 or 140
        local maxWidth = 0
        local Y1 = maxHeight
        if Draw then
            ---
            fade = fade or -1
            if FramesPerSecond < MinFPS then
                if fade < 1 then fade = fade + 0.05 end
            else
                if fade > -1 then fade = fade - 0.01 end
            end
            if fade > 0 then DrawText("Low FPS, overlay does not refresh!", 14, X1, maxHeight - 15, 0xFFFF0000) end
            --

            if NextItem ~= nil then
                local text = string.format("Next: %s - Gold: %s(%s)", item.Name(NextItem), NextItemPrice, math.ceil(NextItemPrice / (20 + (GetTickCount() / 180))))
                if #text > maxWidth then maxWidth = #text end
                DrawText(text, 14, X1, maxHeight, 0xFF80FF00)
                maxHeight = maxHeight + 15
            end
            if ItemsToBuy ~= nil and #ItemsToBuy > 0 then
                local text = "Items To Buy:"
                if #text > maxWidth then maxWidth = #text end
                DrawText(text, 14, X1, maxHeight, 0xFF80FF00)
                maxHeight = maxHeight + 10
                local BuyDrawList = table.copy(ItemsToBuy)
                for i, buy in ipairs(BuyDrawList) do
                    if buy ~= nil then
                        local n = item.IsInList(BuyDrawList, buy)
                        if n > 1 then
                            text = string.format("%sx%s", n, item.Name(buy))
                            if #text > maxWidth then maxWidth = #text end
                            DrawText(text, 14, X1, maxHeight, 0xFFFF0000)
                            for j, v in ipairs(BuyDrawList) do
                                if buy == v then
                                    BuyDrawList[j] = nil
                                end
                            end
                        else
                            text = string.format("%s", item.Name(buy))
                            if #text > maxWidth then maxWidth = #text end
                            DrawText(text, 14, X1, maxHeight, 0xFFFF0000)
                        end
                        maxHeight = maxHeight + 10
                    end
                end
                maxHeight = maxHeight + 5
            end

            if ItemsToSell ~= nil and #ItemsToSell > 0 then
                local text = "Items To Sell:"
                if #text > maxWidth then maxWidth = #text end
                DrawText(text, 14, X1, maxHeight, 0xFFFF0000)
                maxHeight = maxHeight + 10
                local SellDrawList = table.copy(ItemsToSell)
                for i, sell in ipairs(SellDrawList) do
                    if sell ~= nil then
                        local n = item.IsInList(SellDrawList, sell)
                        if n > 1 then
                            text = string.format("%sx%s", n, item.Name(sell))
                            if #text > maxWidth then maxWidth = #text end
                            DrawText(text, 14, X1, maxHeight, 0xFFFF0000)
                            for j, v in ipairs(SellDrawList) do if sell == v then SellDrawList[j] = nil end end
                        else
                            text = string.format("%s", item.Name(sell))
                            if #text > maxWidth then maxWidth = #text end
                            DrawText(text, 14, X1, maxHeight, 0xFFFF0000)
                        end
                        maxHeight = maxHeight + 10
                    end
                end
                maxHeight = maxHeight + 5
            end
        end
        return math.ceil(X1 + maxWidth * 5.64), maxHeight
    end

    if Draw and inShop() then DrawCircle(ShopX, ShopY, ShopZ,ShopRange,0xFF80FF00) end

    if rPosX ~= nil and rPosY ~= nil then
        local X, Y = GetCursorPos().x, GetCursorPos().y
        PositionX1 = X - rPosX
        PositionY1 = Y - rPosY
        PositionX2, PositionY2 = DrawItemWindow(PositionX1, PositionY1)
        for x = PositionX1 - 1, PositionX2, 1 do --ok... I know, thats a really expensive workaround
            DrawText(".", 14, x, PositionY1, 0xFFFF0000)
            DrawText(".", 14, x, PositionY2 - 10, 0xFFFF0000)
        end
        for y = PositionY1, PositionY2 - 10, 1 do
            DrawText(".", 14, PositionX1 - 1, y, 0xFFFF0000)
            DrawText(".", 14, PositionX2, y, 0xFFFF0000)
        end
    else
        PositionX2, PositionY2 = DrawItemWindow(PositionX1, PositionY1)
    end
end

--Three Rings for the Elven kings under the sky,
--Seven for the Dwarf-lords in their halls of stone,
--Nine for Mortal Men, doomed to die,
--One for the Dark Lord on his Dark Throne,
--In the land of Mordor where the shadows lie,
--One Ring to rule them all,
--One Ring to find them,
--One ring to bring them all,
--And in the darkness bind them,
--In the Land of Mordor where the shadows lie.

local function saveItemsToFile()
    --save LastTime save ItemList1 LastChamp
    local file, error = assert(io.open(SCRIPT_PATH .. debug.getinfo(1).short_src:match"^.*[/\\]([^/\\]*)$"))
    if error then return error end
    local t = file:read("*all")
    file:close()
    t = string.gsub(t, "LastTime = %d+", "LastTime = " .. math.floor(LastTime), 1)
    t = string.gsub(t, [[LastChamp = "%a+"]], [[LastChamp = "]] .. LastChamp .. [["]], 1)
    local ItemList1toString = "ItemList1 = {"
    for i, v in ipairs(ItemList1) do
        ItemList1toString = ItemList1toString .. v .. ","
    end
    ItemList1toString = ItemList1toString .. "}"
    t = string.gsub(t, "\nItemList1 = {([%d+%,]*)}", "\n" .. ItemList1toString, 1)
    local file, error = assert(io.open(SCRIPT_PATH .. debug.getinfo(1).short_src:match"^.*[/\\]([^/\\]*)$", "w"))
    if error then return error end
    file:write(t)
    file:close()
end

local function saveDebugFile()
    local t = ""
    for i, v in ipairs(item.GetReserved()) do
        if item.Name(v) then
            t = t .."Items to BUY:" .. item.Name(v) .. "\n"
        else t = t .. v .. "/n"
        end
    end
    t = t .. "\n"
    for i, v in ipairs(ItemList2) do
        if item.Name(v) then
            t = t .."Items to not SELL:" .. item.Name(v) .. "\n"
        else t = t .. v .. "/n"
        end
    end
    local file, error = assert(io.open(SCRIPT_PATH .. "ABI Debug.log", "w+"))
    if error then return error end
    file:write(t)
    file:close()
end


function OnTick()
    if nextTick > GetTickCount() then return end
    nextTick = GetTickCount() + datDelay

    UseElexir()
    if FramesPerSecond > MinFPS or inShop() then
        getInventory()
        if DebugMode then saveDebugFile() end
        calculateItemsToTrade()
        if inShop() or myHero.dead then
            if GetTickCount() > StartBuyTime and GetTickCount() - LastTime > math.random(MinDelay * 10, MaxDelay * 10) / 10 then
                LastTime = GetTickCount()
                for i = 1, #ItemsToSell, 1 do
                    if not sell(ItemsToSell[i]) then return end
                    if MaxDelay > 0 then saveItemsToFile() return end
                end
                for i = 1, #ItemsToBuy, 1 do
                    if not buy(ItemsToBuy[i]) then return end
                    if MaxDelay > 0 then saveItemsToFile() return end
                end
                saveItemsToFile()
            end
        end
    end
end

function OnWndMsg(msg, key)
    if key == DisableHotkey then
        if msg == KEY_DOWN then
            if SHIFT then
                writeWindowPositionToFile()
                return
            else
                if Draw then
                    Draw = false
                else
                    Draw = true
                end
            end
        end
    elseif key == 16 then
        if msg == KEY_DOWN then
            SHIFT = true
        else
            SHIFT = false
        end
    end
    if msg == WM_LBUTTONDOWN then
        local X, Y = GetCursorPos().x,GetCursorPos().y
        if X > PositionX1 and X < PositionX2 and Y > PositionY1 and Y < PositionY2 then
            rPosX = X - PositionX1
            rPosY = Y - PositionY1
        end
    elseif msg == WM_LBUTTONUP then
        if rPosX ~= nil or rPosY ~= nil then
            writeWindowPositionToFile()
            rPosX = nil
            rPosY = nil
        end
    end
end

function recoverLastState()
    if LastChamp ~= myHero.charName or GetTickCount() < 1 or LastTime > GetTickCount() then --I need to figure out how to begin new calculations if the previous game was quited or ended properly(there is looser/winner)
        ItemList1 = {}
        LastTime = GetTickCount()
        return getItemList() --begin new calculations
    else
        local lastItemList1 = table.copy(ItemList1)
        ItemList1 = {}
        LastTime = GetTickCount()
        if getItemList() then ItemList1 = lastItemList1 return true else return false end
    end
end

function OnLoad()
    if recoverLastState() then
        if getMapName() == "Summoners Rift" or getMapName() == "The Twisted Treeline" then
            if DebugMode == true then PrintChat(" » Debug mode ON") end
            PrintChat(" » Auto Buy Items loaded on "..tostring(getMapName()).."!!!")
        else
            PrintChat((" >> Auto Buy Items script unloaded! The script is currently not compatible with %s."):format(getMapName())) return
        end
    else
        PrintChat(" » Auto Buy Items script unloaded! Check your Itemlist.")
        return
    end
end

function BuyOrderDebug(charName, interval, skip)
    local skip = skip or 1
    myHero = {}
    myHero.charName = charName or "Lux"
    myHero.gold = 475
    myHero.level = 1
    local n = interval or 500
    PreInventory = { 0, 0, 0, 0, 0, 0, }
    PreInventoryCount = { 0, 0, 0, 0, 0, 0, }
    PreItemList1 = {}
    PreGold = 0
    Inventory = { 0, 0, 0, 0, 0, 0, }
    InventoryCount = { 0, 0, 0, 0, 0, 0, }
    ItemsToBuy = {}
    ItemsToSell = {}
    NextItem = nil
    NextItemPrice = nil
    ItemList1 = {}
    ItemList2 = {}
    ItemList3 = {}
    FramesPerSecond = math.huge
    if getItemList() then
        PrintChat("ItemList1: ") PrintChat(tostring(ItemList1))
        PrintChat("ItemList2: ") PrintChat(tostring(ItemList2))
        PreGold = 475
        Gold = 475
        local counter = 0
        local t
        local aold, bold, cold, dold, eold, fold
        repeat
            counter = counter + 1
            PreGold = PreGold + n
            myHero.gold = PreGold
            Gold = Gold + n
            if myHero.level < 18 then myHero.level = math.ceil((Gold / 1000) * (20 / 15))
            end
            t0 = os.clock()
            calculateItemsToTrade()
            t = os.clock() - t0
            Inventory = table.copy(PreInventory)
            InventoryCount = table.copy(PreInventoryCount)
            ItemList1 = table.copy(PreItemList1)
            if #ItemsToBuy > 0 then PrintChat("Buy: ") PrintChat(tostring(ItemsToBuy)) end
            if #ItemsToSell > 0 then PrintChat("Sell: ") PrintChat(tostring(ItemsToSell)) end
            local a, b, c, d, e, f = "empty", "empty", "empty", "empty", "empty", "empty"
            if PreInventory[1] ~= 0 then a = PreInventoryCount[1] .. "x" .. item.Name(PreInventory[1]) or "empty" end
            if PreInventory[2] ~= 0 then b = PreInventoryCount[2] .. "x" .. item.Name(PreInventory[2]) or "empty" end
            if PreInventory[3] ~= 0 then c = PreInventoryCount[3] .. "x" .. item.Name(PreInventory[3]) or "empty" end
            if PreInventory[4] ~= 0 then d = PreInventoryCount[4] .. "x" .. item.Name(PreInventory[4]) or "empty" end
            if PreInventory[5] ~= 0 then e = PreInventoryCount[5] .. "x" .. item.Name(PreInventory[5]) or "empty" end
            if PreInventory[6] ~= 0 then f = PreInventoryCount[6] .. "x" .. item.Name(PreInventory[6]) or "empty" end
            if skip == 1 then
                if aold ~= a or bold ~= b or cold ~= c or dold ~= d or eold ~= e or fold ~= f then
                    print(string.format("%s | %s | %s |%s | %s | %s | %s | %s | %s | %s", a, b, c, d, e, f, PreGold, Gold, NextItemPrice, myHero.level))
                end
            else print(string.format("%s | %s | %s |%s | %s | %s | %s | %s | %s | %s", a, b, c, d, e, f, PreGold, Gold, NextItemPrice, myHero.level))
            end
            aold, bold, cold, dold, eold, fold = a, b, c, d, e, f
            until Gold >= 25000
        print(string.format("Time per Calculation: %s ms", (t / counter) * 1000))
    end
end