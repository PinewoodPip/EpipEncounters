
---@class Feature_MassDismantle : Feature
local MassDismantle = {
    REQUEST_NET_MSG = "Feature_MassDismantle_NetMsg_RequestMassDismantle",

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    TranslatedStrings = {
        ContextMenuButtonLabel = {
           Handle = "hc53e69e8ge732g435dg84dcgfb0541f33326",
           Text = "Dismantle All",
           ContextDescription = "Button label for context menu",
        },
        Overhead_DismantledCost = {
            Handle = "ha278dabdg5febg46f4gbb76g82435dd2883a",
            Text = "Dismantled for %s Gold.",
            ContextDescription = [[Overhead shown after dismantling an item. Param is gold cost.]],
        },
    },
    Hooks = {
        IsEligible = {}, ---@type Event<Feature_MassDismantle_Hook_IsEligible>
    },
}
Epip.RegisterFeature("MassDismantle", MassDismantle)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_MassDismantle_NetMsg_RequestMassDismantle : NetLib_Message_Character, NetLib_Message_Item

---------------------------------------------
-- EVENTS
---------------------------------------------

---Thrown when gathering equipment from a container to mass-dismantle.
---@class Feature_MassDismantle_Hook_IsEligible
---@field Item Item Will always be an equipment.
---@field Eligible boolean Hookable. Defaults to `true`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a list of the valid items to mass-dismantle within a container.
---@param container Item
---@return Item[]
function MassDismantle.GetEligibleItems(container)
    local items = Item.GetContainedItems(container, function (item)
        -- Being equipment is a prerequisite.
        local eligible = Item.IsEquipment(item)

        if eligible then
            eligible = MassDismantle.Hooks.IsEligible:Throw({
                Item = item,
                Eligible = eligible,
            }).Eligible
        end

        return eligible
    end)

    return items
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Filter out unique items (including artifacts).
MassDismantle.Hooks.IsEligible:Subscribe(function (ev)
    local eligible = ev.Eligible

    -- Cannot mass-dismantle unique items (which includes artifacts)
    eligible = eligible and not Item.IsUnique(ev.Item)

    ev.Eligible = eligible
end, {StringID = "DefaultImplementation"})