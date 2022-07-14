
---------------------------------------------
-- Automatically identify items when they're generated,
-- either always or if the loremaster requirement is met.
---------------------------------------------

Epip.Features.AutoIdentify = {
    STATES = {
        DISABLED = 1,
        NEED_LOREMASTER = 2,
        ALWAYS = 3,
    },
    state = 1,
    forceEnable = false,
}
local AutoIdentify = Epip.Features.AutoIdentify

function AutoIdentify.SetForceEnable(state)
    AutoIdentify.forceEnable = state or true
end

function AutoIdentify.IsEnabled()
    local state = AutoIdentify.state
    return (state > AutoIdentify.STATES.DISABLED) or forceEnable
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
    if not canIdentify and state == AutoIdentify.STATES.NEED_LOREMASTER then
        local level = item.Stats.Level
        local loremaster = Utilities.GetHighestPartyAbility("Loremaster")

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

Net.RegisterListener("EPIPENCOUNTERS_ServerOptionChanged", function(channel, payload)
    if payload.Mod == "EpipEncounters" and payload.Setting == "AutoIdentify" then
        AutoIdentify.state = payload.Value

        Utilities.Log("AutoIdentify", "Toggled autoidentify to state " .. AutoIdentify.state)
    end
end)