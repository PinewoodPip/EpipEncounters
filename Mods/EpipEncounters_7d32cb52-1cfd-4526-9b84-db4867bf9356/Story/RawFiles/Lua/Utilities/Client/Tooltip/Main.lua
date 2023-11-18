
local TextDisplay = Client.UI.TextDisplay
local Examine = Client.UI.Examine

---@class TooltipLib : Library
local Tooltip = {
    nextTooltipData = nil, ---@type TooltipLib_TooltipSourceData
    _nextCustomTooltip = nil, ---@type TooltipLib_CustomFormattedTooltip
    _nextSkillTooltip = nil, ---@type TooltipLib_SkillTooltipRequest
    _currentTooltipData = nil, ---@type TooltipLib_TooltipSourceData

    _POSITION_OFFSET = -34,

    -- Damage type IDs used in surface tooltips.
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

    Events = {
        TooltipHidden = {}, ---@type Event<EmptyEvent>
        TooltipPositioned = {}, ---@type Event<EmptyEvent>
    },
    Hooks = {
        RenderFormattedTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderFormattedTooltip>
        RenderCustomFormattedTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderCustomFormattedTooltip>
        RenderSkillTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderSkillTooltip>
        RenderItemTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderItemTooltip>
        RenderSurfaceTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderFormattedTooltip>
        RenderStatusTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderStatusTooltip>
        RenderMouseTextTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderMouseTextTooltip>
        RenderSimpleTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderSimpleTooltip>
    },
}
Client.Tooltip = Tooltip
Epip.InitializeLibrary("TooltipLib", Tooltip)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias TooltipLib_TooltipType "Custom"|"Skill"|"Item"|"Status"|"Simple" TODO talent, stat, others
---@alias TooltipLib_FormattedTooltipType "Surface"|"Skill"|"Item"|"Custom"|"Status"
---@alias TooltipLib_Element table See `Game.Tooltip`. TODO
---@alias TooltipLib_FormattedTooltipElementType string TODO

---@class TooltipLib_TooltipSourceData
---@field UIType integer
---@field Type TooltipLib_FormattedTooltipType
---@field FlashCharacterHandle FlashObjectHandle?
---@field FlashStatusHandle FlashObjectHandle?
---@field FlashItemHandle FlashObjectHandle?
---@field SkillID string?
---@field FlashParams LuaFlashCompatibleType[]?
---@field UICall string?

---@class TooltipLib_SimpleTooltip
---@field Label string Supports <bp>, <line> and <shortline>
---@field Position Vector2D? Defaults to mouse position.
---@field UseDelay boolean
---@field MouseStickMode "None"|"BottomRight"|"BottomLeft"|"TopRight"|"TopLeft"
---@field TooltipStyle "Simple"|"Fancy"
---@field IsCharacterTooltip boolean Whether this tooltip comes from a showCharTooltip call.
---@field IsExperienceTooltip boolean Whether this tooltip comes from a showExpTooltip call.

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

---Removes an element.
---@param element integer|TooltipLib_Element integer option refers to element index.
function _FormattedTooltip:RemoveElement(element)
    local index = nil ---@type integer?
    if type(element) == "number" then
        index = element
    else
        for i,existingElement in ipairs(self.Elements) do
            if existingElement == element then
                index = i
                break
            end
        end
    end
    if index then
        table.remove(self.Elements, index)
    else
        Tooltip:Error("FormattedTooltip:RemoveElement", "Element not found")
    end
end

---@class TooltipLib_CustomFormattedTooltip : TooltipLib_FormattedTooltip
---@field ID string
---@field Position Vector2D

---@class TooltipLib_SkillTooltipRequest
---@field CharacterHandle ComponentHandle
---@field SkillID string
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

---@class TooltipLib_Hook_RenderStatusTooltip : TooltipLib_Hook_RenderFormattedTooltip
---@field Character EclCharacter
---@field Status EclStatus

---@class TooltipLib_Hook_RenderSkillTooltip : TooltipLib_Hook_RenderFormattedTooltip
---@field SkillID string
---@field Character EclCharacter

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
        local originalTbl = Tooltip._ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, "tooltipArray"))
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
    local position = data.Position or Vector.Create(Client.GetMousePosition())
    local root = Client.UI.Tooltip:GetRoot()
    local x, y = position:unpack()

    root.addTooltip(data.Label, x, y, data.UseDelay, Tooltip.SIMPLE_TOOLTIP_MOUSE_STICK_MODE[data.MouseStickMode], Tooltip.SIMPLE_TOOLTIP_STYLES[data.TooltipStyle])
end

---@param text string
---@param offset Vector2D?
function Tooltip.ShowMouseTextTooltip(text, offset)
    local mousePos = Vector.Create(Client.GetMousePosition())
    local position = mousePos

    if offset then
        position = position + offset
    end

    TextDisplay.ShowText(text, position)
end

---Returns the source data of the currently visible **formatted** tooltip.
---@return TooltipLib_TooltipSourceData? `nil` if there is no tooltip visible.
function Tooltip.GetCurrentTooltipSourceData()
    return Tooltip._currentTooltipData
end

function Tooltip.HideMouseTextTooltip()
    local root = TextDisplay:GetRoot()

    root.removeText()
end

---@param tooltip TooltipLib_CustomFormattedTooltip
function Tooltip.ShowCustomFormattedTooltip(tooltip)
    local ui = Tooltip._GetDefaultCustomTooltipUI()
    local characterHandle = Ext.UI.HandleToDouble(Client.GetCharacter().Handle)
    local mouseX, mouseY = Client.GetMousePosition()

    Tooltip._nextCustomTooltip = tooltip

    ui:ExternalInterfaceCall("showSkillTooltip", characterHandle, "Teleportation_FreeFall", mouseX, mouseY, 100, 100, "left")
end

---@param char EclCharacter
---@param skillID string
---@param position Vector2D? Defaults to mouse position.
function Tooltip.ShowSkillTooltip(char, skillID, position)
    local ui = Tooltip._GetDefaultCustomTooltipUI()
    local mouseX, mouseY = Client.GetMousePosition()

    Tooltip._nextSkillTooltip = {
        CharacterHandle = char.Handle,
        SkillID = skillID,
        Position = position or Vector.Create(mouseX, mouseY)
    }

    ui:ExternalInterfaceCall("showSkillTooltip", Ext.UI.HandleToDouble(char.Handle), skillID, mouseX, mouseY, 20, 0, "left")
end

---Renders an item tooltip.
---@param item EclItem
---@param position Vector2D? Defaults to mouse position.
function Tooltip.ShowItemTooltip(item, position)
    local ui = Tooltip._GetDefaultCustomTooltipUI()
    local mouseX, mouseY = Client.GetMousePosition()

    Tooltip._nextItemTooltip = {
        ItemHandle = item.Handle,
        Position = position or Vector.Create(mouseX, mouseY)
    }

    ui:ExternalInterfaceCall("showItemTooltip", Ext.UI.HandleToDouble(item.Handle), mouseX, mouseY, 100, 100, -1, "left") -- TODO customize align
end

function Tooltip.HideTooltip()
    local ui = Tooltip._GetDefaultCustomTooltipUI()

    ui:ExternalInterfaceCall("hideTooltip")

    Client.UI.Tooltip:GetRoot().removeTooltip()

    Tooltip._currentTooltipData = nil
end

---Returns the default UI to be used for displaying custom tooltips.
---@return UIObject
function Tooltip._GetDefaultCustomTooltipUI()
    -- In GM mode, the container UI appears to only exist when needed.
    return Ext.UI.GetByType(Ext.UI.TypeID.containerInventory.Default) or Ext.UI.GetByType(Ext.UI.TypeID.gmInventory)
end

---@param ui UIObject
---@param tooltipType TooltipLib_FormattedTooltipType
---@param data TooltipLib_Element[]
---@param sourceData TooltipLib_TooltipSourceData
---@return TooltipLib_Hook_RenderFormattedTooltip
function Tooltip._SendFormattedTooltipHook(ui, tooltipType, data, sourceData)
    local obj = {Elements = data} ---@type TooltipLib_FormattedTooltip
    Inherit(obj, _FormattedTooltip)
    local character, item, status

    -- Fetch entities involved
    if sourceData.FlashCharacterHandle then
        character = Character.Get(sourceData.FlashCharacterHandle, true)
    end
    if sourceData.FlashItemHandle then
        item = Item.Get(sourceData.FlashItemHandle, true)
    end
    if sourceData.FlashStatusHandle then
        status = Character.GetStatusByHandle(character, Ext.UI.DoubleToHandle(sourceData.FlashStatusHandle))
    end

    ---@type TooltipLib_Hook_RenderFormattedTooltip
    local hook = {
        Type = tooltipType,
        Tooltip = obj,
        UI = ui,
        Character = character,
        Item = item,
        SkillID = sourceData.SkillID,
        Status = status,
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
    return Tooltip._ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, fieldName))
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
    Tooltip._currentTooltipData = tooltipData
end

-- Listen for global tooltip request calls.
Ext.Events.UICall:Subscribe(function(ev)
    local param1, param2 = table.unpack(ev.Args)

    if ev.Function == "showSkillTooltip" and not Tooltip._nextCustomTooltip then
        local char = Character.Get(param1, true)
        Tooltip.nextTooltipData = {UIType = ev.UI:GetTypeId(), Type = "Skill", FlashCharacterHandle = param1, SkillID = param2, UICall = ev.Function, FlashParams = {table.unpack(ev.Args)}, Character = char}
        Tooltip._currentTooltipData = Tooltip.nextTooltipData
    elseif ev.Function == "showItemTooltip" then
        Tooltip.nextTooltipData = {UIType = ev.UI:GetTypeId(), Type = "Item", FlashItemHandle = param1, UICall = ev.Function, FlashParams = {table.unpack(ev.Args)}}
        Tooltip._currentTooltipData = Tooltip.nextTooltipData
    elseif ev.Function == "showStatusTooltip" then
        Tooltip.nextTooltipData = {UIType = ev.UI:GetTypeId(), Type = "Status", FlashStatusHandle = param2, FlashCharacterHandle = param1}
        Tooltip._currentTooltipData = Tooltip.nextTooltipData
    end
end)

-- Listen for formatted tooltip invokes on the main tooltip UI.
Client.UI.Tooltip:RegisterInvokeListener("addFormattedTooltip", function(ev, _, _, _)
    HandleFormattedTooltip(ev, "tooltip_array", Tooltip.nextTooltipData, nil)
end)

-- Listen for status tooltip invokes on the main tooltip UI.
Client.UI.Tooltip:RegisterInvokeListener("addStatusTooltip", function (ev)
    HandleFormattedTooltip(ev, "tooltip_array", Tooltip.nextTooltipData)
end)

-- Listen for custom formatted tooltip render requests.
Client.UI.Tooltip:RegisterInvokeListener("addFormattedTooltip", function(ev, _, _, _)
    if Tooltip._nextCustomTooltip then
        local tooltipData = Tooltip._nextCustomTooltip

        -- Clear the previous tooltip data
        Client.UI.Tooltip:GetRoot().tooltip_array.length = 0

        HandleFormattedTooltip(ev, "tooltip_array", {UIType = Ext.UI.TypeID.hotBar, Type = "Custom", FlashCharacterHandle = Ext.UI.HandleToDouble(Client.GetCharacter().Handle)}, tooltipData.Elements)
    end
end)

-- Position custom formatted tooltips after rendering.
Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(ui)
    if Tooltip._nextCustomTooltip then
        local pos = Tooltip._nextCustomTooltip.Position or Vector.Create(Client.GetMousePosition())

        -- Tooltips are offset vertically so the position matches up with the top left corner.
        ui:SetPosition(math.floor(pos[1]), math.floor(pos[2]) + Tooltip._POSITION_OFFSET)

        Tooltip._nextCustomTooltip = nil
    end
end, "After")

-- Position custom skill tooltips after rendering.
Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(ui)
    local customTooltip = Tooltip._nextSkillTooltip or Tooltip._nextItemTooltip
    if customTooltip then
        local pos = customTooltip.Position or Vector.Create(Client.GetMousePosition())

        -- Tooltips are offset vertically so the position matches up with the top left corner.
        ui:SetPosition(math.floor(pos[1]), math.floor(pos[2]) + Tooltip._POSITION_OFFSET)

        Tooltip._nextSkillTooltip = nil
        Tooltip._nextItemTooltip = nil
    end
end, "After")

-- Fire events for tooltips having finished positioning.
-- TODO world and surface tooltips
Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(_)
    Tooltip.Events.TooltipPositioned:Throw()
end, "After")

-- Listen for surface tooltips from TextDisplay.
TextDisplay:RegisterInvokeListener("displaySurfaceText", function(ev, _, _)
    local ui = ev.UI
    local arrayFieldName = "tooltipArray"

    Tooltip.nextTooltipData = {UIType = ev.UI:GetTypeId(), Type = "Surface"}

    local tbl = Tooltip._ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, arrayFieldName))

    local hook = Tooltip._SendFormattedTooltipHook(ui, "Surface", tbl, Tooltip.nextTooltipData)

    if not hook.Prevented then
        local newTable = Game.Tooltip.EncodeTooltipArray(hook.Tooltip.Elements)

        Game.Tooltip.ReplaceTooltipArray(ui, arrayFieldName, newTable, tbl)
    else
        ev:PreventAction()
    end
end)

-- Listen for mouse text tooltips.
TextDisplay.Hooks.GetText:Subscribe(function (ev)
    local hook = {Text = ev.Label} ---@type TooltipLib_Hook_RenderMouseTextTooltip

    Tooltip.Hooks.RenderMouseTextTooltip:Throw(hook)

    if hook.Prevented then
        ev:Prevent()
    else
        ev.Label = hook.Text
    end
end)

-- Listen for simple tooltips.
local isCharTooltip = false
local isExpTooltip = false
Ext.Events.UICall:Subscribe(function(ev)
    ev = ev ---@type EclLuaUICallEvent

    if ev.When == "Before" then
        if ev.Function == "showCharTooltip" then
            isCharTooltip = true
        elseif ev.Function == "showExpTooltip" then
            isExpTooltip = true
        end
    end
end)
Client.UI.Tooltip:RegisterInvokeListener("addTooltip", function (ev, text, x, y, allowDelay, stickToMouseMode, tooltipStyle)
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
            TooltipStyle = table.reverseLookup(Tooltip.SIMPLE_TOOLTIP_STYLES, tooltipStyle),
            IsCharacterTooltip = isCharTooltip,
            IsExperienceTooltip = isExpTooltip,
        }
    })

    if not event.Prevented then
        Tooltip.ShowSimpleTooltip(event.Tooltip)
    end

    isCharTooltip = false
    isExpTooltip = false

    ev:PreventAction()
end, "Before")

-- Re-render the current tooltip when shift is pressed/released
-- Used for conditional rendering based on the shift key being pressed.
-- Currently only supported for skill and item tooltips.
Client.Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "lshift" then
        local currentTooltip = Tooltip._currentTooltipData

        if currentTooltip and currentTooltip.UICall then
            Ext.OnNextTick(function()
                local ui = Ext.UI.GetByType(currentTooltip.UIType)

                ui:ExternalInterfaceCall("hideTooltip")
                ui:ExternalInterfaceCall(currentTooltip.UICall, unpack(currentTooltip.FlashParams))
            end)
        end
    end
end)

-- Throw events for tooltips being removed.
Ext.RegisterUINameCall("hideTooltip", function()
    Tooltip._currentTooltipData = nil

    Tooltip.Events.TooltipHidden:Throw()
end)
TextDisplay.Events.FormattedTooltipRemoved:Subscribe(function (_) -- In TextDisplay this is being done via an engine invoke, not a UI call.
    Tooltip._currentTooltipData = nil

    Tooltip.Events.TooltipHidden:Throw()
end)

-- Hide custom tooltips from the Examine UI,
-- as the game does not appear to do this properly when hovering out of stats with custom IDs.
Examine:RegisterCallListener("hideTooltip", function (_)
    local ui = Tooltip._GetDefaultCustomTooltipUI()
    ui:Hide()
end, "After")
