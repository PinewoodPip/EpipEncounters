
local Vanity = Client.UI.Vanity
local Transmog = Epip.GetFeature("Feature_Vanity_Transmog")

---@class Feature_Vanity_Dyes
local Dyes = Epip.GetFeature("Feature_Vanity_Dyes")

---------------------------------------------
-- EVENTS / HOOKS
---------------------------------------------

Dyes.Events.DyeUsed = Dyes:AddEvent("DyeUsed") ---@type VanityDyes_Event_DyeUsed

Dyes.Hooks.GetCategories = Dyes:AddHook("GetCategories") ---@type VanityDyes_Hook_GetCategories

---@class VanityDyes_Event_DyeUsed : Event
---@field RegisterListener fun(self, listener:fun(dye:VanityDye, item:EclItem, character:EclCharacter))
---@field Fire fun(self, dye:VanityDye, item:EclItem, character:EclCharacter)

---@class VanityDyes_Hook_GetCategories : LegacyHook
---@field RegisterHook fun(self, handler:fun(categories:VanityDyeCategory[]))
---@field Return fun(self, categories:VanityDyeCategory[])

---------------------------------------------
-- METHODS
---------------------------------------------

---@param categoryID string
---@param data VanityDyeCategory
function Dyes.AddDyeCategory(categoryID, data)
    setmetatable(data, {__index = {
        ID = categoryID,
        Name = "MISSING NAME",
        Dyes = {},
    }})

    Dyes.DYE_CATEGORIES[categoryID] = data
    table.insert(Dyes.DYE_CATEGORY_ORDER, categoryID)
end

---Register a dye for the dyes tab.
---@param categoryID string
---@param data VanityDye
function Dyes.AddDye(categoryID, data)
    setmetatable(data, {__index = {
        Name = "MISSING NAME",
        Color = "ffffff",
    }})

    if not data.ID then
        Dyes:LogError("Dyes must have an ID field!")
        return nil
    elseif Dyes.DYE_DATA[data.ID] then
        Dyes:LogError("Dye already registered: " .. data.ID)
        return nil
    elseif Dyes.DYE_CATEGORIES[categoryID] == nil then
        Dyes:LogError("AddDyeCategory() must be called first for " .. categoryID .. " category!")
        return nil
    end

    ---@type VanityDyeCategory
    local category = Dyes.DYE_CATEGORIES[categoryID]

    table.insert(category.Dyes, data)
    Dyes.DYE_DATA[data.ID] = data
end

---Reapplies a character's persistent dye to an item.
---@param char EclCharacter
---@param item EclItem Must be equipped.
function Dyes.ReapplyAppearance(char, item)
    local slot = Item.GetEquippedSlot(item, char)
    local dye = Dyes.activeCharacterDyes[slot]

    if dye then
        Dyes.ApplyCustomDye(dye, item)
    end
end

---Use a dye.
---@param id string
function Dyes.UseDye(id)
    local data = Dyes.DYE_DATA[id] or Dyes.CustomDyes[id]

    Dyes:DebugLog("Using dye: " .. id)

    Dyes.Events.DyeUsed:Fire(data, Vanity.GetCurrentItem(), Client.GetCharacter())
end

---Save a custom dye.
---@param id string
---@param data VanityDye
function Dyes.SaveCustomDye(id, data)
    data.Name = id
    data.ID = id
    data.Type = "Custom"
    Dyes.CustomDyes[id] = data

    Vanity.Refresh()
    Vanity.SaveData()
end

function Dyes.SetItemColorOverride(item, dye)
    local statName = string.format("PIP_DYE_%s_%s_%s", dye.Color1:ToHex(), dye.Color2:ToHex(), dye.Color3:ToHex())
    Stats.Update("ItemColor", {
        Name = statName,
        Color1 = dye.Color1:ToDecimal(),
        Color2 = dye.Color2:ToDecimal(),
        Color3 = dye.Color3:ToDecimal(),
    })

    item.ItemColorOverride = statName
end

---@param dye VanityDye
---@param item EclItem?
function Dyes.ApplyCustomDye(dye, item)
    item = item or Vanity.GetCurrentItem()
    local itemNetID = item.NetID

    Dyes:DebugLog("Applying dye to ", item.DisplayName, item.Slot)
    Dyes:Dump(dye)

    Dyes.SetItemColorOverride(item, dye)

    Timer.Start(0.55, function()
        Net.PostToServer("EPIPENCOUNTERS_DyeItem", {ItemNetID = itemNetID, Dye = dye, CharacterNetID = Client.GetCharacter().NetID})
    end)
    Timer.Start(0.8, function(_) Dyes.UpdateActiveCharacterDyes() end)
end

---Requests dyes to be removed from an item.
---@param char EclCharacter The character making the request.
---@param item EclItem
function Dyes.RemoveDye(char, item)
    Net.PostToServer(Dyes.NETMSG_REMOVE_DYE, {CharacterNetID = char.NetID, ItemNetID = item.NetID})
end

---Deletes a saved custom dye.
---@param dyeID string
function Dyes.DeleteCustomDye(dyeID)
    Dyes.CustomDyes[dyeID] = nil
    Vanity.SaveData()
    Vanity.Refresh()
end

---@param item EclItem|string
---@param dyeStat StatsItemColorDefinition
function Dyes.CreateDyeStats(item, dyeStat)
    local statType = item
    if type(item) ~= "string" then statType = item.Stats.ItemType end

    local deltaModName = string.format("Boost_%s_%s", statType, dyeStat.Name)
    local boostStatName = "_" .. deltaModName
    local stat = Stats.Get(statType, boostStatName)

    Stats.Update("ItemColor", dyeStat)

    if not stat then
        stat = Ext.Stats.Create(boostStatName, statType)
    end

    stat.ItemColor = dyeStat.Name

    Stats.Update("DeltaModifier", {
        Name = deltaModName,
        MinLevel = 1,
        Frequency = 1,
        BoostType = "ItemCombo",
        ModifierType = statType,
        SlotType = "Sentinel",
        WeaponType = "Sentinel",
        Handedness = "Any",
        Boosts = {
            {
                Boost = boostStatName,
                Count = 1,
            }
        }
    })
end

function Dyes.ApplyGenericDyeFromSliders()
    local color1 = Dyes.currentSliderColor.Color1
    local color2 = Dyes.currentSliderColor.Color2
    local color3 = Dyes.currentSliderColor.Color3

    ---@type VanityDye
    local dyeData = {
        Color1 = color1,
        Color2 = color2,
        Color3 = color3,
    }

    Dyes.ApplyCustomDye(dyeData)
end

---@param index integer
---@return RGBColor
function Dyes.GetCurrentSliderColor(index)
    local sliderColor = Dyes.currentSliderColor["Color" .. index]
    return Color.Create(sliderColor.Red, sliderColor.Green, sliderColor.Blue)
end

---Gets the dye selected in the UI's sliders.
---@return VanityDye
function Dyes.GetSelectedDye()
    ---@type VanityDye
    local dye = {
        Color1 = Dyes.GetCurrentSliderColor(1),
        Color2 = Dyes.GetCurrentSliderColor(2),
        Color3 = Dyes.GetCurrentSliderColor(3),
    }

    return dye
end

---Gets the custom dye of the item. If item is nil, returns the values from the sliders instead.
---@param item EclItem?
---@param useSliders boolean? Defaults to true.
---@param useDefaultColors boolean? Defaults to true.
---@return VanityDye
function Dyes.GetCurrentCustomDye(item, useSliders, useDefaultColors)
    if useSliders == nil then useSliders = true end
    if useDefaultColors == nil then useDefaultColors = true end
    local colorData

    -- Read custom dye.
    if item then
        local tags = item:GetTags()
        for i=#tags,1,-1 do
            local tag = tags[i]

            local color1, color2, color3 = tag:match(Dyes.DYED_ITEM_TAG)

            if color1 then
                color1 = Color.CreateFromHex(color1)
                color2 = Color.CreateFromHex(color2)
                color3 = Color.CreateFromHex(color3)

                colorData = {Color1 = color1, Color2 = color2, Color3 = color3}
                break
            end
        end

        -- Support for legacy dyes applied via deltamod.
        if not colorData then
            for _,mod in ipairs(item:GetDeltaMods()) do
                local c1,c2,c3 = string.match(mod, "PIP_GENCOLOR_FF(%x%x%x%x%x%x)_FF(%x%x%x%x%x%x)_FF(%x%x%x%x%x%x)")
    
                if c1 then
                    colorData = {
                        Color1 = Color.CreateFromHex(c1),
                        Color2 = Color.CreateFromHex(c2),
                        Color3 = Color.CreateFromHex(c3),
                    }
                end
            end
        end
    end

    -- Try to get the base color of the item
    if not colorData and item and useDefaultColors then
        local stats = item.StatsFromName ---@type StatsLib_StatsEntry_Armor|StatsLib_StatsEntry_Weapon
        local statObject = Ext.Stats.Get(item.Stats.Name) ---@type StatsLib_StatsEntry_Armor|StatsLib_StatsEntry_Weapon
        local itemGroup = Ext.Stats.ItemGroup.GetLegacy(statObject.ItemGroup)
        local colorStat = stats.ItemColor

        if item.ItemColorOverride ~= "" and not string.find(item.ItemColorOverride, "^PIP_DYE_") then -- Ignore our own dyes.
            colorStat = item.ItemColorOverride
        elseif itemGroup and item.Stats.LevelGroupIndex < #itemGroup.LevelGroups then
            -- Fetch color from progression
            local levelGroup = itemGroup.LevelGroups[item.Stats.LevelGroupIndex + 1]
            local rootGroup = levelGroup.RootGroups[item.Stats.RootGroupIndex + 1]
            if rootGroup.Color ~= "" then
                colorStat = rootGroup.Color
            end
        else
            -- Search for colors from deltamods
            -- Latest deltamod takes priority.
            for i=#item.Stats.DynamicStats,1,-1 do
                local dynStat = item.Stats.DynamicStats[i]
                if dynStat.ItemColor ~= "" then
                    colorStat = dynStat.ItemColor
                    break
                end
            end
        end

        -- Fetch the colors from the ItemColor stat
        if colorStat ~= "" then
            local itemColor = Ext.Stats.ItemColor.Get(colorStat)
            colorData = {
                Color1 = Color.CreateFromDecimal(itemColor.Color1),
                Color2 = Color.CreateFromDecimal(itemColor.Color2),
                Color3 = Color.CreateFromDecimal(itemColor.Color3),
            }

            -- The game uses `pow(channel, 2.2)` for each color channel for armor and weapon visual colors.
            for i=1,3,1 do
                local r, g, b = colorData["Color" .. tostring(i)]:ToFloats()
                colorData["Color" .. tostring(i)] = Color.Create(r ^ 2.2 * 255, g ^ 2.2 * 255, b ^ 2.2 * 255)
            end
        end
    end

    -- Fall back to sliders.
    if not colorData and useSliders then
        colorData = Dyes.GetSelectedDye()
    end

    return colorData
end

---Returns true if the colors of both dyes are the same.
---@param dye1 VanityDye
---@param dye2 VanityDye
---@return boolean
function Dyes.DyesAreEqual(dye1, dye2)
    return dye1.Color1:Equals(dye2.Color1) and dye1.Color2:Equals(dye2.Color2) and dye1.Color3:Equals(dye2.Color3)
end

function Dyes.UpdateActiveCharacterDyes()
    local char = Client.GetCharacter()

    for _,slot in ipairs(Data.Game.SLOTS_WITH_VISUALS) do
        local item = char:GetItemBySlot(slot)

        if item then
            item = Ext.GetItem(item)
            local dye = Dyes.GetCurrentCustomDye(item, false, false)

            Dyes.activeCharacterDyes[slot] = dye
        else
            Dyes.activeCharacterDyes[slot] = nil
        end
    end

    -- Dyes:DebugLog("Active character's dyes:")
    -- Dyes:Dump(Dyes.activeCharacterDyes)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Apply colors to dyed items.
Character.Hooks.CreateEquipmentVisuals:Subscribe(function (ev)
    local request = ev.Request
    local char = ev.Character
    local item

    if char then
        local itemGUID = char:GetItemBySlot(request.Slot)

        if itemGUID then
            item = Item.Get(itemGUID)
        end

        if item then
            -- We need to apply the color even if the item is not dyed, as it could've been a slot that the game would've normally masked - in which case the color fields will not have been set correctly.
            local dye = Dyes.GetCurrentCustomDye(item, false, true)
            if dye then
                request.Colors[3] = {dye.Color1:ToFloats()}
                request.Colors[4] = {dye.Color2:ToFloats()}
                request.Colors[5] = {dye.Color3:ToFloats()}

                Dyes.SetItemColorOverride(item, dye) -- TODO custom color check?

                -- This flag will be false for slots that would normally be masked by others by vanilla logic.
                ev.Request.ApplyColors = true
            end
        end
    end
end)

-- Reapply dyes when an item's appearaance is reapplied.
Transmog.Events.AppearanceReapplied:Subscribe(function (ev)
    Dyes.ReapplyAppearance(ev.Character, ev.Item)
end)

GameState.Events.GameReady:Subscribe(function ()
    Dyes.UpdateActiveCharacterDyes()
end)

Utilities.Hooks.RegisterListener("Client", "ActiveCharacterChanged", function()
    Dyes.UpdateActiveCharacterDyes()
end)

Vanity.Events.AppearanceReapplied:Subscribe(function (_)
    Dyes.UpdateActiveCharacterDyes()
end)

Ext.Events.SessionLoading:Subscribe(function()
    local file = IO.LoadFile("pip_useddyes.json")

    Dyes.CACHE = file or {}

    if file then
        -- print("creating dyes from cache")
        for _,dye in pairs(file) do
            Dyes.CreateDyeStats("Armor", dye)
            Dyes.CreateDyeStats("Weapon", dye)
        end
    end
end)

-- Keep a history of recently-used dyes. TODO finish
Dyes.Events.DyeUsed:RegisterListener(function (dye, item, character)

    if #Dyes.DyeHistory == 0 or not Dyes.DyesAreEqual(Dyes.DyeHistory[#Dyes.DyeHistory], dye) then
        dye.Name = dye.Name or "Unnamed"

        table.insert(Dyes.DyeHistory, dye)

        if #Dyes.DyeHistory > Dyes.DYE_HISTORY_LIMIT then
            table.remove(Dyes.DyeHistory, 1)
        end

        if Vanity.IsCategoryOpen("CustomDyes") or #Dyes.DyeHistory == 1 then
            Vanity.Refresh()
        end
    end
end)

Vanity.Hooks.GetSaveData:RegisterHook(function (data)
    data.Dyes = Dyes.CustomDyes

    return data
end)

Vanity.Events.SaveDataLoaded:RegisterListener(function (data)
    if data.Version >= 4 then
        Dyes.CustomDyes = data.Dyes or {}

        -- Initialize Color objects for saved dyes
        for id,dye in pairs(Dyes.CustomDyes) do
            Dyes.CustomDyes[id].Color1 = Color.Create(dye.Color1)
            Dyes.CustomDyes[id].Color2 = Color.Create(dye.Color2)
            Dyes.CustomDyes[id].Color3 = Color.Create(dye.Color3)
            dye.Type = "Custom"
        end

        -- Initialize Color objects for outfits
        local outfits = data.Outfits ---@type table<string, VanityOutfit>
        for _,outfit in pairs(outfits) do
            ---@diagnostic disable undefined-field
            for slot,dye in pairs(outfit.CustomDyes or {}) do
                outfit.CustomDyes[slot] = {
                    Color1 = Color.Create(dye.Color1),
                    Color2 = Color.Create(dye.Color2),
                    Color3 = Color.Create(dye.Color3),
                }
                ---@diagnostic enable undefined-field
            end
        end
    end
end)

Client.UI.MessageBox.RegisterMessageListener("PIP_Vanity_SaveDye", Client.UI.MessageBox.Events.InputSubmitted, function(input, id, data)
    Dyes.SaveCustomDye(input, Dyes.GetSelectedDye())
end)

Epip.GetFeature("Feature_Vanity_Outfits").Hooks.GetOutfitSaveData:RegisterHook(function(outfit, char)
    outfit.CustomDyes = {}

    for i,slot in ipairs(Data.Game.SLOTS_WITH_VISUALS) do
        local item = char:GetItemBySlot(slot)

        if item then
            item = Ext.GetItem(item)

            local dye = Dyes.GetCurrentCustomDye(item, false)
            outfit.CustomDyes[slot] = dye
        end
    end

    return outfit
end)

Epip.GetFeature("Feature_Vanity_Outfits").Events.OutfitApplied:RegisterListener(function (outfit, char)
    if outfit.CustomDyes then
        for slot,dye in pairs(outfit.CustomDyes) do
            local item = char:GetItemBySlot(slot)
            item = item and Item.Get(item)

            if item then
                Dyes.ApplyCustomDye(dye, item)
            end
        end

        Dyes:DebugLog("Applied saved dyes to outfit " .. outfit.Name)
    end
end)

Dyes.Events.DyeUsed:RegisterListener(function (dye, item, character)
    if dye.Type == "Custom" then
        Dyes.ApplyCustomDye(dye)

        Dyes.Tab:SetSliderColors(dye)
    end
end)

-- Custom Dyes.
Dyes.Hooks.GetCategories:RegisterHook(function (categories)
    local dyes = {}

    for id,dye in pairs(Dyes.CustomDyes) do
        table.insert(dyes, dye)
    end

    table.insert(categories, {
        ID = "CustomDyes",
        Name = "Custom Dyes",
        Dyes = dyes,
    })

    return categories
end)

-- Dye history tab.
-- Dyes.Hooks.GetCategories:RegisterHook(function (categories)
--     if #Dyes.DyeHistory > 0 then
--         ---@type VanityDyeCategory
--         local category = {
--             ID = "DyeHistory",
--             Name = "Recent Dyes",
--             Dyes = {},
--         }

--         for i=#Dyes.DyeHistory,1,-1 do
--             table.insert(category.Dyes, Dyes.DyeHistory[i])
--         end

--         table.insert(categories, category)
--     end

--     return categories
-- end)

-- Registered categories of premade dyes.
Dyes.Hooks.GetCategories:RegisterHook(function (categories)
    for _,categoryID in ipairs(Dyes.DYE_CATEGORY_ORDER) do
        local category = Dyes.DYE_CATEGORIES[categoryID]

        table.insert(categories, category)
    end

    return categories
end)

-- Register all ItemColors into their own category.
function Dyes:__Setup()
    ---@type VanityDyeCategory
    local category = {
        Name = "Built-in Colors",
        ID = "BUILT-IN",
        Dyes = {},
    }

    Dyes.AddDyeCategory(category.ID, category)

    ---@type VanityDye[]
    local dyes = {}
    local i = 1
    for id,colorStat in pairs(Ext.Stats.ItemColor.GetAll()) do
        local dye = {
            Name = Text.Join(Text.SplitPascalCase(id)), -- Make name more human-readable.
            ID = id,
            Color1 = Color.CreateFromDecimal(colorStat.Color1),
            Color2 = Color.CreateFromDecimal(colorStat.Color2),
            Color3 = Color.CreateFromDecimal(colorStat.Color3),
            Type = "Custom",
        }
        dyes[i] = dye
        i = i + 1
    end
    -- Sort alphabetically
    table.sort(dyes, function (a, b)
        return a.Name < b.Name
    end)

    for _,dye in ipairs(dyes) do
        if not Dyes.DYE_DATA[dye.ID] and not string.find(dye.ID, "PIP_GENCOLOR", nil, true) and not string.find(dye.ID, "PIP_DYE", nil, true) then -- Do not include stats for custom dyes.
            Dyes.AddDye(category.ID, dye)
        end
    end
end