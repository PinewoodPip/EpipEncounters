
local TextDisplay = Client.UI.TextDisplay

---@class TooltipLib : Feature
local Tooltip = {
    nextTooltipData = nil, ---@type TooltipLib_TooltipSourceData
    _nextCustomTooltip = nil, ---@type TooltipLib_CustomFormattedTooltip

    _POSITION_OFFSET = -34,

    SURFACE_DAMAGE_ELEMENT_TYPES = {
        Fire = true,
        Water = true,
        Earth = true,
        Air = true,
        Poison = true,
        Physical = true,
        Sulphur = true,
    },

    SIMPLE_TOOLTIP_STYLES = {
        Fancy = 0,
        Simple = 1,
    },
    SIMPLE_TOOLTIP_MOUSE_STICK_MODE = {
        None = 0,
        BottomRight = 1,
        BottomLeft = 2,
        TopRight = 3,
        TopLeft = 4,
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        RenderFormattedTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderFormattedTooltip>
        RenderCustomFormattedTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderCustomFormattedTooltip>
        RenderSkillTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderSkillTooltip>
        RenderItemTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderItemTooltip>
        RenderSurfaceTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderFormattedTooltip>
        RenderMouseTextTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderMouseTextTooltip>
        RenderSimpleTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderSimpleTooltip>
    },
}
Client.Tooltip = Tooltip
Epip.InitializeLibrary("TooltipLib", Tooltip)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias TooltipLib_FormattedTooltipType "Surface"|"Skill"|"Item"|"Custom"
---@alias TooltipLib_Element table See `Game.Tooltip`. TODO
---@alias TooltipLib_FormattedTooltipElementType string TODO

---@class TooltipLib_TooltipSourceData
---@field UIType integer
---@field Type TooltipLib_FormattedTooltipType
---@field FlashCharacterHandle FlashObjectHandle?
---@field FlashItemHandle FlashObjectHandle?
---@field SkillID string?

---@class TooltipLib_SimpleTooltip
---@field Label string Supports <bp>, <line> and <shortline>
---@field Position Vector2D
---@field UseDelay boolean
---@field MouseStickMode "None"|"BottomRight"|"BottomLeft"|"TopRight"|"TopLeft"
---@field TooltipStyle "Simple"|"Fancy"

---@class TooltipLib_FormattedTooltip
---@field Elements TooltipLib_Element[]
local _FormattedTooltip = {}

---@param element TooltipLib_Element
---@param index integer? Defaults to next index.
function _FormattedTooltip:InsertElement(element, index)
    table.insert(self.Elements, index or #self.Elements + 1, element)
end

---@param elementType TooltipLib_FormattedTooltipElementType?
---@return TooltipLib_Element[] If elementType is nil, the list will be passed by reference.
function _FormattedTooltip:GetElements(elementType)
    local elements = {}

    if elementType ~= nil then
        for _,element in ipairs(self.Elements) do
            if element.Type == elementType then
                table.insert(elements, element)
            end
        end
    else
        elements = self.Elements
    end

    return elements
end

---@param elementType TooltipLib_FormattedTooltipElementType?
function _FormattedTooltip:GetFirstElement(elementType)
    return self:GetElements(elementType)[1]
end

---If the target element is not found, the new element will be inserted at the end.
---@param target TooltipLib_Element|TooltipLib_FormattedTooltipElementType The element before which to insert the new one.
---@param element TooltipLib_Element The element to insert.
function _FormattedTooltip:InsertAfter(target, element)
    local inserted = false

    for i=#self.Elements,1,-1 do
        local existingElement = self.Elements[i]

        if existingElement.Type == target or existingElement == target then
            self:InsertElement(element, i + 1)
            inserted = true
            break
        end
    end

    if not inserted then
        _FormattedTooltip:InsertElement(element)
    end
end

---If the target element is not found, the new element will be inserted at the end.
---@param target TooltipLib_Element|TooltipLib_FormattedTooltipElementType The element before which to insert the new one.
---@param element TooltipLib_Element The element to insert.
function _FormattedTooltip:InsertBefore(target, element)
    local inserted = false

    for i,existingElement in ipairs(self.Elements) do
        if existingElement.Type == target or existingElement == target then
            self:InsertElement(element, i)
            inserted = true
            break
        end
    end

    if not inserted then
        _FormattedTooltip:InsertElement(element)
    end
end

---@class TooltipLib_CustomFormattedTooltip : TooltipLib_FormattedTooltip
---@field ID string
---@field Position Vector2D

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class TooltipLib_Hook_RenderFormattedTooltip : PreventableEventParams
---@field Type TooltipLib_FormattedTooltipType
---@field Tooltip TooltipLib_FormattedTooltip Hookable.
---@field UI UIObject

---@class TooltipLib_Hook_RenderCustomFormattedTooltip : TooltipLib_Hook_RenderFormattedTooltip
---@field Tooltip TooltipLib_CustomFormattedTooltip Hookable.

---@class TooltipLib_Hook_RenderItemTooltip : TooltipLib_Hook_RenderFormattedTooltip
---@field Item EclItem

---@class TooltipLib_Hook_RenderSkillTooltip : TooltipLib_Hook_RenderFormattedTooltip
---@field SkillID string

---@class TooltipLib_Hook_RenderMouseTextTooltip : PreventableEventParams
---@field Text string Hookable.

---@class TooltipLib_Hook_RenderSimpleTooltip : PreventableEventParams
---@field Tooltip TooltipLib_SimpleTooltip

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui UIObject
---@param tooltipType TooltipLib_FormattedTooltipType
---@param tooltip TooltipLib_FormattedTooltip
function Tooltip.ShowFormattedTooltip(ui, tooltipType, tooltip)
    local root = ui:GetRoot()

    if tooltipType == "Surface" then
        local originalTbl = Game.Tooltip.ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, "tooltipArray"))
        local newTable = Game.Tooltip.EncodeTooltipArray(tooltip.Elements)

        Game.Tooltip.ReplaceTooltipArray(ui, "tooltipArray", newTable, originalTbl)

        root.displaySurfaceText(Client.GetMousePosition())
    else
        Tooltip:LogError("ShowFormattedTooltip(): Tooltip type not supported: " .. tooltipType)
    end
end

---Shows a simple tooltip.
---Does not fire events.
---@param data TooltipLib_SimpleTooltip
function Tooltip.ShowSimpleTooltip(data)
    local root = Client.UI.Tooltip:GetRoot()
    local x, y = data.Position:unpack()

    root.addTooltip(data.Label, x, y, data.UseDelay, Tooltip.SIMPLE_TOOLTIP_MOUSE_STICK_MODE[data.MouseStickMode], Tooltip.SIMPLE_TOOLTIP_STYLES[data.TooltipStyle])

    if data.MouseStickMode == "None" then
        root.checkTooltipBoundaries(root.getTooltipWidth(), root.getTooltipHeight(), x + root.frameSpacing, y + root.frameSpacing) -- This function is responsible for positioning the tooltip if it is not set to stick to mouse.
    end
        
    Ext.OnNextTick(function ()
        root.INTshowTooltip()
    end)
end

---@param text string
function Tooltip.ShowMouseTextTooltip(text)
    local root = TextDisplay:GetRoot()

    root.addText(text, Client.GetMousePosition())
end

---@param tooltip TooltipLib_CustomFormattedTooltip
function Tooltip.ShowCustomFormattedTooltip(tooltip)
    local ui = Client.UI.Hotbar -- TODO replace once a better option becomes available.
    local characterHandle = Client.UI.Hotbar:GetRoot().hotbar_mc.characterHandle
    local mouseX, mouseY = Client.GetMousePosition()

    tooltip.Position = tooltip.Position or Vector.Create(mouseX, mouseY)

    Tooltip._nextCustomTooltip = tooltip

    ui:ExternalInterfaceCall("showSkillTooltip", characterHandle, "Teleportation_FreeFall", mouseX, mouseY, 100, 100, "left")
end

---@param ui UIObject
---@param tooltipType TooltipLib_FormattedTooltipType
---@param data TooltipLib_Element[]
---@param sourceData TooltipLib_TooltipSourceData
---@return TooltipLib_Hook_RenderFormattedTooltip
function Tooltip._SendFormattedTooltipHook(ui, tooltipType, data, sourceData)
    local obj = {Elements = data} ---@type TooltipLib_FormattedTooltip
    Inherit(obj, _FormattedTooltip)
    local character
    local item

    -- Fetch entities involved
    if sourceData.FlashCharacterHandle then
        character = Character.Get(sourceData.FlashCharacterHandle, true)
    end
    if sourceData.FlashItemHandle then
        item = Item.Get(sourceData.FlashItemHandle, true)
    end

    ---@type TooltipLib_Hook_RenderFormattedTooltip
    local hook = {
        Type = tooltipType,
        Tooltip = obj,
        UI = ui,
        Character = character,
        Item = item,
        SkillID = sourceData.SkillID,
    }

    -- Specific listeners go first.
    local specificEvent = tooltipType == "Custom" and Tooltip.Hooks.RenderCustomFormattedTooltip or Tooltip.Hooks["Render" .. tooltipType .. "Tooltip"]
    if specificEvent then
        specificEvent:Throw(hook)
    else
        Tooltip:LogWarning("No specific hook defined for tooltip type " .. tooltipType)
    end

    Tooltip.Hooks.RenderFormattedTooltip:Throw(hook)

    return hook
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@param ui UIObject
---@param fieldName string
---@return table
local function ParseArray(ui, fieldName)
    return Game.Tooltip.ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, fieldName))
end

local function HandleFormattedTooltip(ev, arrayFieldName, sourceData, tooltipData)
    if sourceData then
        tooltipData = tooltipData or ParseArray(ev.UI, arrayFieldName)

        local hook = Tooltip._SendFormattedTooltipHook(Ext.UI.GetByType(sourceData.UIType), sourceData.Type, tooltipData, sourceData)

        if not hook.Prevented then
            local newTable = Game.Tooltip.EncodeTooltipArray(hook.Tooltip.Elements)

            Game.Tooltip.ReplaceTooltipArray(ev.UI, arrayFieldName, newTable, tooltipData)
        else
            ev:PreventAction()
        end
    end

    Tooltip.nextTooltipData = nil
end

-- Listen for global tooltip request calls.
Ext.Events.UICall:Subscribe(function(ev)
    local param1, param2 = table.unpack(ev.Args)

    if ev.Function == "showSkillTooltip" and not Tooltip._nextCustomTooltip then
        Tooltip.nextTooltipData = {UIType = ev.UI:GetTypeId(), Type = "Skill", FlashCharacterHandle = param1, SkillID = param2}
    elseif ev.Function == "showItemTooltip" then
        Tooltip.nextTooltipData = {UIType = ev.UI:GetTypeId(), Type = "Item", FlashItemHandle = param1}
    elseif ev.Function == "displaySurfaceText" then
        Tooltip.nextTooltipData = {UIType = ev.UI:GetTypeId(), Type = "Surface"}
    end
end)

-- Listen for formatted tooltip invokes on the general tooltip UI.
Client.UI.Tooltip:RegisterInvokeListener("addFormattedTooltip", function(ev, _, _, _)
    HandleFormattedTooltip(ev, "tooltip_array", Tooltip.nextTooltipData, nil)
end)

-- Listen for custom formatted tooltip render requests.
Client.UI.Tooltip:RegisterInvokeListener("addFormattedTooltip", function(ev, _, _, _)
    if Tooltip._nextCustomTooltip then
        local tooltipData = Tooltip._nextCustomTooltip

        HandleFormattedTooltip(ev, "tooltip_array", {UIType = Ext.UI.TypeID.hotBar, Type = "Custom", FlashCharacterHandle = Ext.UI.HandleToDouble(Client.GetCharacter().Handle)}, tooltipData.Elements)
    end
end)

-- Position custom formatted tooltips after rendering.
Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(ui)
    if Tooltip._nextCustomTooltip then
        local pos = Tooltip._nextCustomTooltip.Position

        -- Tooltips are offset vertically so the position matches up with the top left corner.
        ui:SetPosition(math.floor(pos[1]), math.floor(pos[2]) + Tooltip._POSITION_OFFSET)

        Tooltip._nextCustomTooltip = nil
    end
end, "After")

-- Listen for surface tooltips from TextDisplay.
TextDisplay:RegisterInvokeListener("displaySurfaceText", function(ev, _, _)
    local ui = ev.UI
    local arrayFieldName = "tooltipArray"

    local tbl = Game.Tooltip.ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, arrayFieldName))

    local hook = Tooltip._SendFormattedTooltipHook(ui, "Surface", tbl, Tooltip.nextTooltipData)

    if not hook.Prevented then
        local newTable = Game.Tooltip.EncodeTooltipArray(hook.Tooltip.Elements)

        Game.Tooltip.ReplaceTooltipArray(ui, arrayFieldName, newTable, tbl)
    else
        ev:PreventAction()
    end
end)

-- Listen for mouse text tooltips.
TextDisplay:RegisterInvokeListener("addText", function(ev, text, x, y)
    local hook = {Text = text} ---@type TooltipLib_Hook_RenderMouseTextTooltip

    Tooltip.Hooks.RenderMouseTextTooltip:Throw(hook)

    if not hook.Prevented then
        ev.Args[1] = hook.Text
        ev.UI:GetRoot().addText(hook.Text, x, y)
        ev:PreventAction()
    else
        ev:PreventAction()
    end
end)

-- Listen for simple tooltips.
Client.UI.Tooltip:RegisterInvokeListener("addTooltip", function (ev, text, x, y, allowDelay, stickToMouseMode, tooltipStyle)
    local root = ev.UI:GetRoot()

    -- Default values from flash method.
    x = x or 0
    y = y or 18
    stickToMouseMode = stickToMouseMode or 0
    if allowDelay == nil then allowDelay = true end
    if tooltipStyle == nil then tooltipStyle = 0 end

    local event = Tooltip.Hooks.RenderSimpleTooltip:Throw({
        Tooltip = {
            Label = text,
            Position = Vector.Create(x, y),
            UseDelay = allowDelay,
            MouseStickMode = table.reverseLookup(Tooltip.SIMPLE_TOOLTIP_MOUSE_STICK_MODE, stickToMouseMode),
            TooltipStyle = table.reverseLookup(Tooltip.SIMPLE_TOOLTIP_STYLES, tooltipStyle)
        }
    })

    if not event.Prevented then
        Tooltip.ShowSimpleTooltip(event.Tooltip)
    end

    ev:PreventAction()
end, "Before")