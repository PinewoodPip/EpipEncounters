
---------------------------------------------
-- Adds Greatforge options to item context menus.
---------------------------------------------

Epip.Features.GreatforgeContextMenu = {
    Entries = {
        -- requires shift+click if item has runes.
        DISMANTLE = {
            id = "epip_Dismantle",
            type = "button",
            text = "Dismantle",
        },
        -- enabled/disabled based on whether the item has runes.
        EXTRACT_RUNES = {
            id = "epip_ExtractRunes",
            type = "button",
            text = "Extract Runes",
        },
        REMOVE_MODS = {
            id = "epip_RemoveMods",
            type = "subMenu",
            subMenu = "epip_RemoveMods_menu",
            text = "Cull...",
        },
    },

    -- TODO move to GF lib
    SUPPORTED_MODS = {

    },
    DELTAMOD_TO_MOD = {},
}
local GreatforgeContextMenu = Epip.Features.GreatforgeContextMenu
local ContextMenu = Client.UI.ContextMenu

local options

-- Returns the mod family name and the value of the deltamod passed,
-- if it is compatible with EE systems. Otherwise, returns nil.
function GreatforgeContextMenu.IsCullable(deltamod)
    local mod = GreatforgeContextMenu.DELTAMOD_TO_MOD[deltamod]
    local value = nil

    if mod then
        value = mod.DeltaMods[deltamod]
    end

    return mod,value
end

-- TODO fix
function GreatforgeContextMenu.GetDeltaModTier(data, deltamod)
    local tier = nil

    if data then
        local reversed = {}
        
        local maxValue = 0
        for d,v in pairs(data.DeltaMods) do
            if v > maxValue then
                maxValue = v
            end
        end

        local orderedDeltamods = {}
        for i=1,maxValue,1 do
            local dmod = ReverseLookup(data.DeltaMods, i)

            if dmod then
                table.insert(orderedDeltamods, dmod)
            end
        end

        for i,dmod in ipairs(orderedDeltamods) do
            if dmod == deltamod then
                tier = i
                break
            end
        end
    end

    return tier
end

---------------------------------------------
-- DISMANTLE
---------------------------------------------
ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    -- Greatforge menus are only applicable to equipment.
    if not item.Stats or not Item.IsEquipment(item) then return nil end

    local hasRunes = Item.HasRunes(item)
    local isEquipped = Item.IsEquipped(Client.GetCharacter(), item)

    local entries = {
        GreatforgeContextMenu.Entries.EXTRACT_RUNES,
    }

    -- Dismantling uniques is disabled due to unidentified tech issues, as well as common items, as per normal Greatforge behaviour.
    if item.Stats.ItemTypeReal ~= "Unique" and item.Stats.ItemTypeReal ~= "Common" then
        table.insert(entries, GreatforgeContextMenu.Entries.DISMANTLE)
    end

    -- TODO finish
    -- table.insert(entries, GreatforgeContextMenu.Entries.REMOVE_MODS)

    -- If the item has runes, enable rune extraction.
    GreatforgeContextMenu.Entries.EXTRACT_RUNES.selectable = hasRunes
    GreatforgeContextMenu.Entries.EXTRACT_RUNES.faded = not hasRunes

    -- Additionally, require shift+click for dismantling if items has runes.
    GreatforgeContextMenu.Entries.DISMANTLE.requireShiftClick = hasRunes or isEquipped

    ContextMenu.AddElements(ContextMenu.VanillaUI, {
        id = "main",
        entries = entries,
    })
end)

ContextMenu.RegisterElementListener("epip_Dismantle", "buttonPressed", function(item)
    Ext.Net.PostMessageToServer("EPIPENCOUNTERS_QuickReduce", Ext.Json.Stringify({Char = Client.GetCharacter().NetID, Item = item.NetID}))
end)

ContextMenu.RegisterElementListener("epip_ExtractRunes", "buttonPressed", function(item)
    Ext.Net.PostMessageToServer("EPIPENCOUNTERS_QuickExtractRunes", Ext.Json.Stringify({Char = Client.GetCharacter().NetID, Item = item.NetID}))
end)

ContextMenu.RegisterElementListener("epip_RemoveMods_Mod", "buttonPressed", function(item, params)
    _D(params)

    Ext.Net.PostMessageToServer("EPIPENCOUNTERS_QuickGreatforge_RemoveMods", Ext.Json.Stringify({Char = Client.GetCharacter().NetID, Item = item.NetID, Modifier = params.Modifier}))
end)

---------------------------------------------
-- REMOVE MODS (Cull)
---------------------------------------------

ContextMenu.RegisterMenuHandler("epip_RemoveMods_menu", function()
    local item = ContextMenu.item
    local deltamods = item:GetDeltaMods()
    local entries = {
        {
            id = "epip_RemoveMods_menu_header",
            type = "header",
            text = "Choose one to keep:",
        }
    }
    local mods = {}

    -- Find the highest level of each supported mod on the item.
    for i,deltamod in ipairs(deltamods) do
        local mod,value = GreatforgeContextMenu.IsCullable(deltamod)

        if mod and not mod.Implicit then
            if not mods[mod.Name] or value > mods[mod.Name].Value then
                mods[mod.Name] = {
                    DeltaMod = deltamod,
                    Value = value
                }
            end
        end
    end

    for mod,data in pairs(mods) do
        local modData = GreatforgeContextMenu.SUPPORTED_MODS[mod]
        local tier = GreatforgeContextMenu.GetDeltaModTier(modData, data.DeltaMod)

        table.insert(entries, {
            id = "epip_RemoveMods_menu_option_" .. mod,
            -- text = string.format("%s (Tier %d/%d)", mod, tier, modData.Tiers),
            text = string.format("%s (%d)", mod, data.Value),
            type = "button",
            eventIDOverride = "epip_RemoveMods_Mod",
            params = {
                Modifier = data.DeltaMod,
            },
        })
    end

    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_RemoveMods_menu",
            entries = entries,
        }
    })
end)

---------------------------------------------
-- MASS DISMANTLE (Containers)
---------------------------------------------

ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    local items = item:GetInventoryItems()
    local hasEquipment = false

    -- Only show this option if the container has at least one piece of equipment
    -- TODO: also check if it can be dismantled? might be excessive for performance
    for index,guid in pairs(items) do
        local item = Ext.GetItem(guid)

        if Item.IsEquipment(item) then
            hasEquipment = true
            break
        end
    end

    if hasEquipment then
        ContextMenu.AddElements(ContextMenu.VanillaUI, {
            id = "main",
            entries = {
                {
                    id = "epip_MassDismantle",
                    type = "button",
                    text = "Dismantle All",
                },
            },
        }) 
    end
end)

ContextMenu.RegisterElementListener("epip_MassDismantle", "buttonPressed", function(item)
    Net.PostToServer("EPIPENCOUNTERS_MassDismantle", {Char = Client.GetCharacter().NetID, Container = item.NetID})
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Store Deltamod info.
Net.RegisterListener("EPIPENCOUNTERS_QuickGreatforge_ModList", function(cmd, payload)
    for i,tuple in ipairs(payload) do
        local mod = tuple[1]
        local deltamod = tuple[2]
        local value = tuple[3]

        if not GreatforgeContextMenu.SUPPORTED_MODS[mod] then
            GreatforgeContextMenu.SUPPORTED_MODS[mod] = {
                Name = mod,
                Implicit = string.find(mod, "Implicit") ~= nil,
                Tiers = 0,
                DeltaMods = {

                },
            }
        end

        local data = GreatforgeContextMenu.SUPPORTED_MODS[mod]

        data.DeltaMods[deltamod] = value
        data.Tiers = data.Tiers + 1

        GreatforgeContextMenu.DELTAMOD_TO_MOD[deltamod] = data
    end
end)