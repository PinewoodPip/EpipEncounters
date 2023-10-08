
---@class WorldTooltipUI : UI
local WorldTooltip = {
    _IgnoreNextClick = false,
    _LastTooltipClickWasPrevented = false,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        TooltipClicked = {Preventable = true}, ---@type Event<WorldTooltipUI_Event_TooltipClicked>
    },
    Hooks = {
        UpdateContent = {}, ---@type Event<WorldTooltipUI_Hook_UpdateContent>
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
    if WorldTooltip._IgnoreNextClick then -- This UI has an issue with the click events being fired twice due to quirks with Iggy mouse up events. We track this to avoid issuing events twice.
        WorldTooltip._IgnoreNextClick = false
        if WorldTooltip._LastTooltipClickWasPrevented then -- If the first event was prevented, prevent the repeated one as well.
            WorldTooltip._LastTooltipClickWasPrevented = false
            ev:PreventAction()
        end
        return
    end

    local entity = Ext.Entity.GetGameObject(Ext.UI.DoubleToHandle(flashHandle))
    local eventFieldName

    if GetExtType(entity) == "ecl::Character" then
        eventFieldName = "Character"
    elseif GetExtType(entity) == "ecl::Item" then
        eventFieldName = "Item"
    else
        WorldTooltip:LogError("Clicked an entry with an unknown entity type")
        return
    end

    local eventParams = {}
    eventParams[eventFieldName] = entity

    local event = WorldTooltip.Events.TooltipClicked:Throw(eventParams)

    if event.Prevented then
        ev:PreventAction()
    end

    -- Track events being fired twice.
    WorldTooltip._IgnoreNextClick = true
    WorldTooltip._LastTooltipClickWasPrevented = event.Prevented
end)
