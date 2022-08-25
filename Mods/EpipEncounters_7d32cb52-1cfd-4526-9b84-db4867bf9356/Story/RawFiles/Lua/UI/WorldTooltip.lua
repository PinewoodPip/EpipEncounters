
---@class WorldTooltipUI : UI
local WorldTooltip = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        UpdateContent = {}, ---@type SubscribableEvent<WorldTooltipUI_Event_UpdateContent>
    }
}
Client.UI.WorldTooltip = WorldTooltip
Epip.InitializeUI(Ext.UI.TypeID.worldTooltip, "WorldTooltip", WorldTooltip)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class WorldTooltipUI_Entry
---@field ID FlashObjectHandle
---@field Label string
---@field X number
---@field Y number
---@field SortHelper number
---@field IsItem boolean

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class WorldTooltipUI_Event_UpdateContent
---@field Entries WorldTooltipUI_Entry[]

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

WorldTooltip:RegisterInvokeListener("updateTooltips", function (ev)
    local arr = ev.UI:GetRoot().worldTooltip_array

    ---@type WorldTooltipUI_Entry[]
    local arrayEntryTemplate = {
        "ID",
        "X",
        "Y",
        "Label",
        "SortHelper",
        "IsItem",
    }
    local parsed = Client.Flash.ParseArray(arr, arrayEntryTemplate)

    ---@type WorldTooltipUI_Event_UpdateContent
    local update = WorldTooltip.Hooks.UpdateContent:Throw({
        Entries = parsed,
    })

    Client.Flash.EncodeArray(arr, arrayEntryTemplate, update.Entries)
end)