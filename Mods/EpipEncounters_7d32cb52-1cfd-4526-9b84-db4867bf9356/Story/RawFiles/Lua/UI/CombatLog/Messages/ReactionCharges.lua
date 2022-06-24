
local Log = Client.UI.CombatLog

---@class CombatLogReactionChargesData
---@field Reaction string
---@field Amount integer

---@class CombatLogReactionChargesMessage : CombatLogScriptedMessage
---@field Reactions CombatLogReactionChargesData[]

---@type CombatLogReactionChargesMessage
local _Charges = {
    PATTERN_ALT = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: has free reaction charges:<br>(.+)', -- TODO
    PATTERN = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: (.+) free reaction charges remaining: (%d+)',
    Type = "ReactionCharges",
}
Inherit(_Charges, Log.MessageTypes.Scripted)
Log.MessageTypes.ReactionCharges = _Charges

---------------------------------------------
-- METHODS
---------------------------------------------

---@param charName string
---@param charColor string
---@param reactions CombatLogReactionChargesData[]
---@return CombatLogReactionChargesMessage
function _Charges.Create(charName, charColor, reactions, fallbackText)
    local text = ""

    -- TODO finish
    if reactions then
        text = Text.Format("%s reaction charges remaining: %s", {
            FormatArgs = {
                reactions[1].Reaction, reactions[1].Amount
            }
        })
    end

    -- Start with a line break for multi-reaction messages
    if reactions and #reactions > 1 then
        for i,reaction in ipairs(reactions) do
            _D(reaction)
            local addendum = ""

            addendum = addendum .. Text.Format("%s: %s", {
                FormatArgs = {
                    reactions[1].Reaction, reactions[1].Amount
                }
            })

            if i ~= #reactions then
                addendum = addendum .. "<br>"
            end
        end

        text = Text.Format("reaction charges remaining:<br>%s", {
            FormatArgs = {addendum},
        })
    end

    if not reactions then
        text = Text.Format("reaction charges remaining:<br>%s", {
            FormatArgs = {fallbackText}
        })
    end

    ---@type CombatLogReactionChargesMessage
    local obj = Log.MessageTypes.Scripted.Create(charName, charColor, text, nil)
    Inherit(obj, _Charges)
    obj.Type = "ReactionCharges"

    obj.Reactions = reactions

    return obj
end

---------------------------------------------
-- PARSING
---------------------------------------------

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, reaction, charges = message:match(_Charges.PATTERN)

    -- Multiple reactions in one message
    if not charColor then
        charColor, charName, reaction = message:match(_Charges.PATTERN_ALT)

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

            obj = _Charges.Create(charName, charColor, nil, reaction)
        end
    else -- just one reaction
        if charColor then
            obj = _Charges.Create(charName, charColor, {{Reaction = reaction, Amount = charges}})
        end
    end

    return obj
end)
