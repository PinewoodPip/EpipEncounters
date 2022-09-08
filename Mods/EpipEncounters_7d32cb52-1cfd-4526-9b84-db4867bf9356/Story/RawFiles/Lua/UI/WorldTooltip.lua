
---@class WorldTooltipUI : UI
local WorldTooltip = {
    _ignoreNextClick = false,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        TooltipClicked = {Preventable = true}, ---@type SubscribableEvent<WorldTooltipUI_Event_TooltipClicked>
    },
    Hooks = {
        UpdateContent = {}, ---@type SubscribableEvent<WorldTooltipUI_Hook_UpdateContent>
    },
}
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

---Fired when a world tooltip is clicked.
---@class WorldTooltipUI_Event_TooltipClicked : PreventableEventParams
---@field Character EclCharacter?
---@field Item EclItem?

---@class WorldTooltipUI_Hook_UpdateContent
---@field Entries WorldTooltipUI_Entry[]

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for updates.
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

    ---@type WorldTooltipUI_Hook_UpdateContent
    local update = WorldTooltip.Hooks.UpdateContent:Throw({
        Entries = parsed,
    })

    Client.Flash.EncodeArray(arr, arrayEntryTemplate, update.Entries)
end)

-- Listen for entries being clicked.
WorldTooltip:RegisterCallListener("tooltipClicked", function (ev, flashHandle)
    if WorldTooltip._ignoreNextClick then WorldTooltip._ignoreNextClick = false return nil end

    local entity = Ext.Entity.GetGameObject(Ext.UI.DoubleToHandle(flashHandle))
    local eventFieldName

    if GetExtType(entity) == "ecl::Character" then
        eventFieldName = "Character"
    elseif GetExtType(entity) == "ecl::Item" then
        eventFieldName = "Item"
    else
        WorldTooltip:LogError("Clicked an entry with an unknown entity type")
        return nil
    end

    local eventParams = {}
    eventParams[eventFieldName] = entity

    local event = WorldTooltip.Events.TooltipClicked:Throw(eventParams)

    if event.Prevented then
        ev:PreventAction()
    end

    -- This UI has an issue with the click events being fired twice.
    WorldTooltip._ignoreNextClick = true
end)