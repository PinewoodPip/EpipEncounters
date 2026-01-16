
---------------------------------------------
-- Automatically identify items when they're generated,
-- either always or if the loremaster requirement is met.
---------------------------------------------

---@class Feature_AutoIdentify : Feature
local AutoIdentify = {
    STATES = {
        DISABLED = 1,
        NEED_LOREMASTER = 2,
        ALWAYS = 3,
    },
    state = 1,
    forceEnable = false,
}
Epip.RegisterFeature("AutoIdentify", AutoIdentify)

function AutoIdentify.SetForceEnable(state)
    AutoIdentify.forceEnable = state or true
end

function AutoIdentify.IsEnabled()
    local state = AutoIdentify.state
    return (state > AutoIdentify.STATES.DISABLED) or AutoIdentify.forceEnable
end

---Attempts to identify an item.
---The item will only be identified if the feature is enabled and the item is eligible.
---@param item EsvItem
---@return boolean -- Whether the item was identified.
function AutoIdentify.ProcessItem(item)
    local identified = false
    if item.Stats and AutoIdentify.IsEnabled() then
        if AutoIdentify.CanIdentify(item) then
            Osi.NRD_ItemSetIdentified(item.MyGuid, 1)
            identified = true
        end
    end
    return identified
end

---Returns whether an item can be auto-identified.
---Ignores whether the feature is enabled.
---@param item EsvItem
---@return boolean
function AutoIdentify.CanIdentify(item)
    local state = AutoIdentify.state
    local canIdentify = state == AutoIdentify.STATES.ALWAYS or AutoIdentify.forceEnable

    -- Check ability requirement
    if item.Stats and not canIdentify and state == AutoIdentify.STATES.NEED_LOREMASTER then
        local partyLeader = Character.Get(Osiris.CharacterGetHostCharacter()) -- We don't have a way of identifying to who is looting this item.
        local loremaster = Character.GetHighestPartyAbility(partyLeader, "Loremaster")

        local requirement = Item.GetIdentifyRequirement(item)

        canIdentify = loremaster >= requirement
    end

    return canIdentify
end

-- Auto-identify items on generation.
Ext.Events.TreasureItemGenerated:Subscribe(function (ev)
    AutoIdentify.ProcessItem(ev.Item)
end)

-- Auto-identify items moved to inventories.
Osiris.RegisterSymbolListener("ItemTemplateAddedToCharacter", 3, "after", function(_, itemGUID, _)
    if Osi.ObjectExists(itemGUID) == 0 then return end -- Occurs during character creation when dummies are transformed.
    local item = Item.Get(itemGUID)
    if item then -- Is frequently nil within character creation.
        AutoIdentify.ProcessItem(item)
    end
end)

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting
    if setting.ModTable == "EpipEncounters" and setting.ID == "AutoIdentify" then
        AutoIdentify.state = ev.Value

        AutoIdentify:DebugLog("Toggled autoidentify to state " .. AutoIdentify.state)

        -- Auto-identify all items in the party inventory when the feature is enabled mid-session.
        if AutoIdentify:IsEnabled() then
            local host = Character.Get(Osi.CharacterGetHostCharacter())
            if host then
                local items = Item.GetItemsInPartyInventory(host, function (item)
                    return item.Stats and not Item.IsIdentified(item)
                end, true)
                for _,item in ipairs(items) do
                    AutoIdentify.ProcessItem(item)
                end
            end
        end
    end
end)
