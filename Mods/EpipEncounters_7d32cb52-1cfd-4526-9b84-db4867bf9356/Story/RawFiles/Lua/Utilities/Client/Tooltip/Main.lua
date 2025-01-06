
local TooltipUI = Client.UI.Tooltip
local TextDisplay = Client.UI.TextDisplay
local Examine = Client.UI.Examine

---@class TooltipLib : Library
local Tooltip = {
    nextTooltipData = nil, ---@type TooltipLib_TooltipSourceData?
    _currentTooltipData = nil, ---@type TooltipLib_TooltipSourceData?
    _nextSkillTooltip = nil, ---@type TooltipLib_SkillTooltipRequest?
    _nextCustomTooltip = nil, ---@type TooltipLib_CustomFormattedTooltip?
    _LastCustomTooltipSource = nil, ---@type TooltipLib_TooltipSourceData?
    _LastCustomTooltipEntry = nil, ---@type TooltipLib_CustomFormattedTooltip?
    _PartyInventoryUIInitialized = false,

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

    -- Engine IDs for `showStatTooltip` UI call.
    ---@enum TooltipLib.StatID
    STAT_IDS = {
        STRENGTH = 0,
        FINESSE = 1,
        VITALITY = 12,
        INTELLIGENCE = 2,
        CONSTITUTION = 3,
        MEMORY = 4,
        WITS = 5,
        DAMAGE = 6,
        PHYSICAL_ARMOR = 7,
        MAGIC_ARMOR = 8,
        CRITICAL_CHANCE = 9,
        ACCURACY = 10,
        DODGING = 11,
        ACTION_POINTS = 13,
        SOURCE_POINTS = 14,
        REPUTATION = 15,
        KARMA = 16,
        SIGHT = 17,
        HEARING = 18,
        VISION_ANGLE = 19,
        MOVEMENT = 20,
        INITIATIVE = 21,
        BLOCK = 22,
        PIERCING_RESISTANCE = 23,
        PHYSICAL_RESISTANCE = 24,
        CORROSIVE_RESISTANCE = 25,
        MAGIC_RESISTANCE = 26,
        TENEBRIUM_RESISTANCE = 27,
        FIRE_RESISTANCE = 28,
        WATER_RESISTANCE = 29,
        EARTH_RESISTANCE = 30,
        AIR_RESISTANCE = 31,
        POISON_RESISTANCE = 32,
        CUSTOM_RESISTANCE = 33, -- No description whatsoever.
        WILLPOWER = 34,
        BODYBUILDING = 35,
        EXPERIENCE = 36,
        NEXT_LEVEL = 37,
        MAX_AP = 38,
        START_AP = 39,
        AP_RECOVERY = 40,
        MAX_WEIGHT = 41,
        MIN_DAMAGE = 42,
        MAX_DAMAGE = 43,
        LIFESTEAL = 44,
        GAIN = 45,
    },

    -- Engine IDs for `showAbilityTooltip` UI call.
    ---@enum TooltipLib.AbilityID
    ABILITY_IDS = {
        WARFARE = 0,
        HUNTSMAN = 1,
        SCOUNDREL = 2,
        SINGLE_HANDED = 3,
        TWO_HANDED = 4,
        RETRIBUTION = 5,
        RANGED = 6,
        SHIELDBEARER = 7,
        REFLEXES = 8,
        PHYSICAL_ARMOR = 9,
        MARGIC_ARMOR = 10,
        VITALITY = 11,
        SOURCERY = 12,
        PYROKINETIC = 13,
        HYDROSOPHIST = 14,
        AEROTHEURGE = 15,
        GEOMANCER = 16,
        NEOCROMANCER = 17,
        SUMMONING = 18,
        POLYMORPH = 19,
        TELEKINESIS = 20,
        BLACKSMITHING = 21,
        SNEAKING = 22,
        PICKPOCKETING = 23,
        THIEVERY = 24,
        LOREMASTER = 25,
        CRAFTING = 26,
        BARTERING = 27,
        CHARM = 28,
        INTIMIDATE = 29,
        REASON = 30,
        PERSUASION = 31,
        LEADERSHIP = 32,
        LUCKY_CHARM = 33,
        DUAL_WIELDING = 34,
        WAND = 35,
        PERSEVERANCE = 36,
        RUNE_CRAFTING = 37,
        BREW_MASTER = 38,
        UNKNOWN_39 = 39, -- "Increases all Exposive damage you deal"
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
        TooltipHidden = {}, ---@type Event<Empty>
        TooltipPositioned = {}, ---@type Event<Empty>
    },
    Hooks = {
        RenderFormattedTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderFormattedTooltip>
        RenderCustomFormattedTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib_Hook_RenderCustomFormattedTooltip>
        RenderSkillTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderSkillTooltip>
        RenderItemTooltip = {Preventable = true,}, ---@type PreventableEvent<TooltipLib_Hook_RenderItemTooltip>
        RenderStatTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib.Hooks.RenderStatTooltip>
        RenderAbilityTooltip = {Preventable = true}, ---@type PreventableEvent<TooltipLib.Hooks.RenderAbilityTooltip>
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

---@alias TooltipLib_TooltipType "Custom"|"Skill"|"Item"|"Status"|"Simple"|"Stat"|"Ability" TODO talent, others?
---@alias TooltipLib_FormattedTooltipType "Surface"|"Skill"|"Item"|"Custom"|"Status"|"Stat"|"Ability"
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
---@field StatID TooltipLib.StatID
---@field AbilityID TooltipLib.AbilityID
---@field CustomTooltipID string?
---@field IsFromGame boolean `false` if the tooltip originated from this library.

---@class TooltipLib_SimpleTooltip
---@field Label string Supports <bp>, <line> and <shortline>
---@field Position Vector2D? In screen coordinates. Defaults to mouse position, in which case the position is determined after the delay (if any).
---@field UseDelay boolean If `true`, the tooltip will be shown after a delay. `See TooltipUI.SIMPLE_TOOLTIP_DELAY`.
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
---@return TooltipLib_Element[] -- If elementType is nil, the list will be passed by reference.
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
        self:InsertElement(element)
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
---@field ID string?
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

---@class TooltipLib.Hooks.RenderStatTooltip : TooltipLib_Hook_RenderFormattedTooltip
---@field StatID TooltipLib.StatID

---@class TooltipLib.Hooks.RenderAbilityTooltip : TooltipLib_Hook_RenderFormattedTooltip
---@field AbilityID TooltipLib.AbilityID

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

        local cursor = Vector.Create(Client.GetMousePosition())
        -- Cursor position is in pixels, we need to convert it to "1080p-relative" stage space.
        local stageCursorPos = Client.Flash.ScreenSpaceToStretchedStage(cursor)
        root.displaySurfaceText(stageCursorPos:unpack())
    else
        Tooltip:LogError("ShowFormattedTooltip(): Tooltip type not supported: " .. tooltipType)
    end
end

---Shows a simple tooltip.
---Does not fire events.
---@param data TooltipLib_SimpleTooltip
function Tooltip.ShowSimpleTooltip(data)
    local ui = TooltipUI
    local root = ui:GetRoot()
    local useCursorPosition = data.Position == nil
    local position = data.Position or Vector.Create(Client.GetMousePosition())
    local x, y = position:unpack() -- No need to consider UI scale, as this positioning happens within the Tooltip UI's flash space.

    root.addTooltip(data.Label, x, y, data.UseDelay, Tooltip.SIMPLE_TOOLTIP_MOUSE_STICK_MODE[data.MouseStickMode], Tooltip.SIMPLE_TOOLTIP_STYLES[data.TooltipStyle])

    -- We need to position the UI ourselves if no mouse-sticking is requested;
    -- Normally this is done via setAnchor UICall.
    if data.MouseStickMode == "None" then
        local functor = function ()
            -- Show the tooltip at the updated cursor position;
            -- otherwise it might appear that the tooltip "lags" behind the cursor.
            if useCursorPosition then
                position = Vector.Create(Client.GetMousePosition())
                x, y = position:unpack()
            end
            ui:SetPosition(Vector.Create(math.floor(root.frameSpacing + x), math.floor(root.frameSpacing + y)))
        end
        if data.UseDelay then
            Timer.Start(ui.SIMPLE_TOOLTIP_DELAY, functor)
        else
            Ext.OnNextTick(functor)
        end
    end

    Tooltip._LastCustomTooltipSource = nil
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
    Tooltip._LastCustomTooltipEntry = tooltip
    -- TODO allow setting source
    Tooltip._SetNextTooltipSource({
        UIType = Ext.UI.TypeID.containerInventory.Default,
        Type = "Custom",
        UICall = "showSkillTooltip",
        FlashParams = {Ext.UI.HandleToDouble(Client.GetCharacter().Handle), "Teleportation_FreeFall", mouseX, mouseY, 100, 100, "Left"},
        CustomTooltipID = tooltip.ID,
        IsFromGame = false,
    })

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

    TooltipUI:GetRoot().removeTooltip()

    Tooltip._currentTooltipData = nil
end

---Returns the default UI to be used for displaying custom tooltips.
---@return UIObject
function Tooltip._GetDefaultCustomTooltipUI()
    return Ext.UI.GetByType(Ext.UI.TypeID.containerInventory.Pickpocket) -- Exists for both input methods. The default containerInventory's item tooltips use the owner character of items to show compare tooltips, instead of the client character.
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
        StatID = sourceData.StatID,
        AbilityID = sourceData.AbilityID,
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

---@param ui UIObject
---@param fieldName string
---@return table
local function ParseArray(ui, fieldName)
    return Tooltip._ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, fieldName))
end

function Tooltip._HandleFormattedTooltip(ev, arrayFieldName, sourceData, tooltipData)
    if sourceData then
        tooltipData = tooltipData or ParseArray(ev.UI, arrayFieldName)

        local hook = Tooltip._SendFormattedTooltipHook(Ext.UI.GetByType(sourceData.UIType), sourceData.Type, tooltipData, sourceData)

        if not hook.Prevented then
            local newTable = Game.Tooltip.EncodeTooltipArray(hook.Tooltip.Elements)

            Tooltip._ReplaceTooltipArray(ev.UI, arrayFieldName, newTable)
        else
            ev:PreventAction()
        end
    else
        Tooltip:__LogWarning("Handling tooltip with no source data", arrayFieldName)
    end

    Tooltip._SetCurrentTooltipSource(sourceData)
    Tooltip.nextTooltipData = nil -- Marks the tooltip as handled.
end

---Sets the source data of the next tooltip to display.
---@param source TooltipLib_TooltipSourceData
function Tooltip._SetNextTooltipSource(source)
    Tooltip.nextTooltipData = source
    -- Current tooltip source is instead set after handling it.
end

---Sets the source data of the currently-displayed tooltip.
---@param source TooltipLib_TooltipSourceData?
function Tooltip._SetCurrentTooltipSource(source)
    Tooltip._currentTooltipData = source
    if source and source.Type == "Custom" then
        Tooltip._LastCustomTooltipSource = source
    else
        Tooltip._LastCustomTooltipSource = nil
        Tooltip._LastCustomTooltipEntry = nil
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for global tooltip request calls.
Ext.Events.UICall:Subscribe(function(ev)
    local param1, param2 = table.unpack(ev.Args)

    if ev.Function == "showSkillTooltip" and not Tooltip._nextCustomTooltip then
        Tooltip._SetNextTooltipSource({
            UIType = ev.UI:GetTypeId(),
            Type = "Skill",
            FlashCharacterHandle = param1,
            SkillID = param2,
            UICall = ev.Function,
            FlashParams = {table.unpack(ev.Args)},
            IsFromGame = Tooltip._nextSkillTooltip == nil,
        })
    elseif ev.Function == "showItemTooltip" then
        Tooltip._SetNextTooltipSource({
            UIType = ev.UI:GetTypeId(),
            Type = "Item",
            FlashItemHandle = param1,
            UICall = ev.Function,
            FlashParams = {table.unpack(ev.Args)},
            IsFromGame = Tooltip._nextItemTooltip == nil,
        })
    elseif ev.Function == "showStatusTooltip" then
        Tooltip._SetNextTooltipSource({
            UIType = ev.UI:GetTypeId(),
            Type = "Status",
            FlashStatusHandle = param2,
            FlashCharacterHandle = param1,
            IsFromGame = true,
        })
    elseif ev.Function == "showStatTooltip" then
        Tooltip._SetNextTooltipSource({
            UIType = ev.UI:GetTypeId(),
            Type = "Stat",
            StatID = param1,
            IsFromGame = true,
        })
    elseif ev.Function == "showAbilityTooltip" then
        Tooltip._SetNextTooltipSource({
            UIType = ev.UI:GetTypeId(),
            Type = "Ability",
            AbilityID = param1,
            IsFromGame = true,
        })
    end
end)

-- Listen for formatted tooltip invokes on the main tooltip UI.
TooltipUI:RegisterInvokeListener("addFormattedTooltip", function(ev, _, _, _)
    Tooltip._HandleFormattedTooltip(ev, "tooltip_array", Tooltip.nextTooltipData, nil)
end)

-- Listen for status tooltip invokes on the main tooltip UI.
TooltipUI:RegisterInvokeListener("addStatusTooltip", function (ev)
    Tooltip._HandleFormattedTooltip(ev, "tooltip_array", Tooltip.nextTooltipData)
end)

-- Listen for custom formatted tooltip render requests.
TooltipUI:RegisterInvokeListener("addFormattedTooltip", function(ev, _, _, _)
    if Tooltip._nextCustomTooltip then
        local tooltipData = Tooltip._nextCustomTooltip

        -- Clear the previous tooltip data
        TooltipUI:GetRoot().tooltip_array.length = 0

        local mouseX, mouseY = Client.GetMousePosition()
        Tooltip._SetNextTooltipSource({
            UIType = Ext.UI.TypeID.containerInventory.Default,
            Type = "Custom",
            UICall = "showSkillTooltip",
            FlashParams = {Ext.UI.HandleToDouble(Client.GetCharacter().Handle), "Teleportation_FreeFall", mouseX, mouseY, 100, 100, "Left"},
            CustomTooltipID = tooltipData.ID,
            IsFromGame = false,
        })
        Tooltip._HandleFormattedTooltip(ev, "tooltip_array", Tooltip._currentTooltipData, tooltipData.Elements)
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

    Tooltip._SetNextTooltipSource({
        UIType = ev.UI:GetTypeId(),
        Type = "Surface",
        IsFromGame = true,
    })

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
TooltipUI:RegisterInvokeListener("addTooltip", function (ev, text, x, y, allowDelay, stickToMouseMode, tooltipStyle)
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

    -- Clear custom tooltip tracking
    -- so as to prevent it from showing up again when re-rendering.
    Tooltip._LastCustomTooltipSource = nil
    Tooltip._LastCustomTooltipEntry = nil

    if not event.Prevented then
        local tooltipData = event.Tooltip
        ev.UI:GetRoot().addTooltip(tooltipData.Label, tooltipData.Position[1], tooltipData.Position[2], tooltipData.UseDelay, Tooltip.SIMPLE_TOOLTIP_MOUSE_STICK_MODE[tooltipData.MouseStickMode], Tooltip.SIMPLE_TOOLTIP_STYLES[tooltipData.TooltipStyle])
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
        if Tooltip._LastCustomTooltipSource then
            Tooltip.HideTooltip()
            Tooltip.ShowCustomFormattedTooltip(Tooltip._LastCustomTooltipEntry)
        elseif currentTooltip and currentTooltip.UICall then
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
    ui:ExternalInterfaceCall("hideTooltip")
end, "After")
