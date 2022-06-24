
---------------------------------------------
-- Locks giftbags incompatible with EE.
---------------------------------------------

local MODS = Data.Mods
local GBL = {
    enabledGiftbags = {},
    warnedGiftbags = {},

    INCOMPATIBLE_GIFTBAGS = {
        [MODS.GB_8AP] = "The value of an action point has been halved, meaning characters have a maximum of 12 AP by default.",
        [MODS.GB_CRAFTING] = "Breaks dual-wielding AP cost and reintroduces removed gear perks.",
        [MODS.GB_PETPAL] = "Pet Pal is already innate in EE.",
        [MODS.GB_LEVELUP_ITEMS] = "Breaks item statistics and is unnecessary due to the Greatforge already having a way to level up items.",
        [MODS.GB_SUMMONING] = "Reverts EE's changes to summoning.",
        [MODS.GB_TALENTS] = "Prevents you from choosing Glass Cannon. The new talents are unsupported.",
        [MODS.GB_SPIRIT_VISION] = "Already included in EE.",
    },
    UNDESIRABLE_GIFTBAGS = {
        [MODS.GB_RANDOMIZER] = "Not designed for EE, and is buggy, bestowing permanent resistance boosts to your characters.",
        [MODS.GB_REST_SOURCE] = "Unnecessary due to the new Source system.",
        [MODS.GB_ORGANIZATION] = "Poorly implemented, creates a lot of tedium and inconvenience.",
        [MODS.GB_BARTER] = "Buggy in multiplayer, prevents trading.",
    },
}

local GBUI = Client.UI.GiftBagContent

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

GBUI:RegisterCallListener("buttonPressed", function(ev)
    local type,id = ev.Args[1],ev.Args[2]
    local mod = GBUI.GetModGUID(id)
    local isEnabled = GBL.enabledGiftbags[id]
    local isIncompatible = GBL.INCOMPATIBLE_GIFTBAGS[mod]
    local isUnwanted = GBL.UNDESIRABLE_GIFTBAGS[mod]

    if not isEnabled then
        if isIncompatible then
            ev:PreventAction()
        elseif isUnwanted and not GBL.warnedGiftbags[id] then
            GBL.warnedGiftbags[id] = true
            Client.UI.MessageBox.ShowMessageBox({
                Header = "EPIC ENCOUNTERS WARNING",
                Message = "This giftbag has been marked as unnecessary or potentially undesirable and may negatively affect the EE experience. See the Discord FAQ channel for more information."
            })
        end
    end
end)

GBUI.Hooks.GetContent:RegisterHook(function (content)
    GBL.warnedGiftbags = {}

    for i,entry in ipairs(content) do
        GBL.enabledGiftbags[entry.ID] = entry.Enabled
        if GBL.INCOMPATIBLE_GIFTBAGS[entry.Mod] then
            local reason = GBL.INCOMPATIBLE_GIFTBAGS[entry.Mod]

            entry.Description = Text.Format("%s\nReason:\n%s\n\n%s", {
                FormatArgs = {
                    {Color = "992f2f", Text = "Incompatible with Epic Encounters."},
                    reason,
                    entry.Description,
                },
            })

            -- Only lock giftbags that are not already enabled - this is so they can still be disabled (if possible)
            if not entry.Enabled then
                entry.Locked = true
            end
        elseif GBL.UNDESIRABLE_GIFTBAGS[entry.Mod] then
            local reason = GBL.UNDESIRABLE_GIFTBAGS[entry.Mod]

            entry.Description = Text.Format("%s\nReason:\n%s\n\n%s", {
                FormatArgs = {
                    {Text = "Undesirable with Epic Encounters.", Color = "945b00"},
                    reason,
                    entry.Description,
                }
            })
        end
    end

    return content
end)