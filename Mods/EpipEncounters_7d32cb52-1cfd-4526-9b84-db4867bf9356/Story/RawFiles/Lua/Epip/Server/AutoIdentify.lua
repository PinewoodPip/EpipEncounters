
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

function AutoIdentify.ProcessItem(item)
    if item.Stats and AutoIdentify.IsEnabled() then
        if AutoIdentify.CanIdentify(item) then
            Osi.NRD_ItemSetIdentified(item.MyGuid, 1)
        end
    end
end

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

Ext.RegisterListener("TreasureItemGenerated", function(item)
    AutoIdentify.ProcessItem(item)
end)

Ext.Osiris.RegisterListener("ItemTemplateAddedToCharacter", 3, "after", function(template, item, char)
    AutoIdentify.ProcessItem(item)
end)

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting

    if setting.ModTable == "EpipEncounters" and setting.ID == "AutoIdentify" then
        AutoIdentify.state = ev.Value

        Utilities.Log("AutoIdentify", "Toggled autoidentify to state " .. AutoIdentify.state)
    end
end)