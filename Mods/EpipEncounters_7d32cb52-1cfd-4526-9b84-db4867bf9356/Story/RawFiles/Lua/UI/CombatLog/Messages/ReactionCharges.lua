
---------------------------------------------
-- Handler for "X has Y reaction charges remaining" messages from Epic Encounters.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.ReactionCharges : UI.CombatLog.Messages.Scripted
---@field Reactions UI.CombatLog.Messages.ReactionCharges.Reaction[]
local _Charges = {
    PATTERN_ALT = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: has free reaction charges:<br>(.+)', -- TODO
    PATTERN = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: (.+) free reaction charges remaining: (%d+)',
}
Log:RegisterClass("UI.CombatLog.Messages.ReactionCharges", _Charges, {"UI.CombatLog.Messages.Scripted"})
Log.RegisterMessageHandler(_Charges)

local TSKs = {
    ReactionCharges_Remaining_Prefixed = Log:RegisterTranslatedString({
        Handle = "hbb7f4c8bgf1a1g4b2bg8e6fgc6e2e4e2d3e4",
        Text = [[%s reaction charges remaining: %s]],
        ContextDescription = [[Message for a character's remaining charges for a reaction; params are reaction type and amount.]],
    }),
    ReactionCharges_Remaining = Log:RegisterTranslatedString({
        Handle = "h0095bd8ag2e26g4cc3gb6e0gb86d38e65b3a",
        Text = [[reaction charges remaining: %s]],
        ContextDescription = [[Message for a character's summary of remaining reaction charges of all types; param is the reaction charges (ex. "Predator: 1<br>Celestial: 2").]],
    }),
}

---@class UI.CombatLog.Messages.ReactionCharges.Reaction
---@field Reaction string
---@field Amount integer

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a new reaction charges message.
---@param charName string
---@param charColor string
---@param reactions UI.CombatLog.Messages.ReactionCharges.Reaction[]
---@return UI.CombatLog.Messages.ReactionCharges
function _Charges:Create(charName, charColor, reactions, fallbackText)
    local text = ""

    -- TODO finish
    if reactions then
        text = TSKs.ReactionCharges_Remaining_Prefixed:Format(reactions[1].Reaction, reactions[1].Amount)
    end

    -- Start with a line break for multi-reaction messages
    if reactions and #reactions > 1 then
        local addendum = ""
        for i,reaction in ipairs(reactions) do
            addendum = addendum .. Text.Format("%s: %s", {
                FormatArgs = {
                    reaction.Reaction, reaction.Amount
                }
            })

            if i ~= #reactions then
                addendum = addendum .. "<br>"
            end
        end

        text = TSKs.ReactionCharges_Remaining:Format(addendum)
    end

    if not reactions then
        text = TSKs.ReactionCharges_Remaining:Format(fallbackText)
    end

    ---@type UI.CombatLog.Messages.ReactionCharges
    local obj = self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Text = text,
        Reactions = reactions
    })
    return obj
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local rawMsg = ev.RawMessage
    local charColor, charName, reaction, charges = rawMsg:match(_Charges.PATTERN)

    -- Multiple reactions in one message
    if not charColor then
        charColor, charName, reaction = rawMsg:match(_Charges.PATTERN_ALT)

        -- TODO finish. the split function does not work with more than one char!!! wth. the lua patterns are pissing me off and i should switch to some regex lib.
        if reaction then
            -- local reactions = Text.Split(reaction, "<br>")
            -- _D(reactions)
            -- local data = {}

            -- if not reactions then
            --     reactions = {reaction}
            -- end

            -- for i,r in ipairs(reactions) do
            --     local t, amount = r:match("(.+): (%d+)")

            --     table.insert(data, {Reaction = t, Amount = amount})
            -- end

            ev.ParsedMessage = _Charges.Create(charName, charColor, nil, reaction)
        end
    else -- Single reaction
        if charColor then
            ev.ParsedMessage = _Charges:Create(charName, charColor, {{Reaction = reaction, Amount = charges}})
        end
    end
end)
