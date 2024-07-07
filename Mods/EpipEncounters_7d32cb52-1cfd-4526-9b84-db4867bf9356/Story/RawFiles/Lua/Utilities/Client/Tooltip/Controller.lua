
local ControllerUIs = Client.UI.Controller
local ExamineC = ControllerUIs.Examine
local BottomBarC = ControllerUIs.BottomBar
local PartyInventoryC = ControllerUIs.PartyInventory
local EquipmentPanelC = ControllerUIs.EquipmentPanel
local InventorySkillPanelC = ControllerUIs.InventorySkillPanel

---@class TooltipLib
local Tooltip = Client.Tooltip

-- Controller UIs to handle tooltips for.
-- These are assumed to have the tooltip elements embedded or imported.
---@type {UI:UI, Invokes:{FunctionName:string, ArrayName:string}[]}[]
Tooltip.CONTROLLER_UIS = {
    {UI = ExamineC, Invokes = {
        {FunctionName = "showFormattedTooltip", ArrayName = "tooltipArray"},
    }},
    {UI = InventorySkillPanelC, Invokes = {
        -- TODO are the other ones used or copy-paste leftovers? Ex. updateItemTooltip()
        {FunctionName = "updateSkillTooltip", ArrayName = "tooltip_array"},
    }},
    {UI = BottomBarC, Invokes = {
        {FunctionName = "updateTooltip", ArrayName = "tooltip_array"},
    }},
    {UI = PartyInventoryC, Invokes = {
        {FunctionName = "updateTooltip", ArrayName = "tooltip_array"}, -- TODO offhand/compare tooltips
    }},
    {UI = EquipmentPanelC, Invokes = {
        {FunctionName = "updateEquipTooltip", ArrayName = "equipTooltip_array"},
        {FunctionName = "updateTooltip", ArrayName = "tooltip_array"}, -- The UI has confusing names for the arrays; equipTooltip_array is the equipped item, tooltip_array is for items from the equip widget.
    }},
}

---@type {UICall:string, TooltipType:TooltipLib_TooltipType}[]
Tooltip.CONTROLLER_EXAMINE_TOOLTIP_TYPES = {
    {"selectStat", "Stat"},
    {"selectAbility", "Stat"}, -- TODO distinguish these as Ability
    -- {"selectTalent", "Talent"},
    -- {"selectTitle", "Title"},
    {"selectStatus", "Status"},
}

-- Maps input event to tick delay before fetching tooltip source data.
-- These aren't actually the UI events used by the UI (those are consumed and don't fire events),
-- but are bound to the same inputs.
---@type table<InputLib_InputEventStringID, integer>
Tooltip.CONTROLLER_BOTTOMBAR_TOOLTIP_REFRESH_INPUTEVENTS = {
    ["RotateItemLeft"] = 3,
    ["RotateItemRight"] = 3,
    ["ToggleSkills"] = 1,
    ["SelectorMoveLeft"] = 1,
    ["SelectorMoveRight"] = 1,
}

---------------------------------------------
-- EXAMINE UI
---------------------------------------------

-- Handle selection changing, upon which the tooltip is sent to the UI
-- ahead of the user choosing to display it.
for _,examineTooltipType in ipairs(Tooltip.CONTROLLER_EXAMINE_TOOLTIP_TYPES) do
    ExamineC:RegisterCallListener(examineTooltipType[1], function (ev, id)
        local char = ExamineC.GetCharacter()
        ---@type TooltipLib_TooltipSourceData
        local sourceData = {
            UIType = ev.UI:GetTypeId(),
            UICall = ev.Function,
            Type = examineTooltipType[2],
            FlashCharacterHandle = Ext.UI.HandleToDouble(char.Handle),
            IsFromGame = true,
            FlashStatusHandle = id,
            StatID = id,
            FlashParams = {id},
        }
        Tooltip._SetNextTooltipSource(sourceData)
    end)
end

---------------------------------------------
-- INVENTORY SKILL PANEL
---------------------------------------------

-- Handle skills being selected.
InventorySkillPanelC:RegisterCallListener("selectSkill", function (ev, skillID)
    if skillID ~= "" then
        local char = Client.GetCharacter()
        ---@type TooltipLib_TooltipSourceData
        local sourceData = {
            UIType = ev.UI:GetTypeId(),
            UICall = ev.Function,
            Type = "Skill",
            FlashCharacterHandle = Ext.UI.HandleToDouble(char.Handle),
            IsFromGame = true,
            SkillID = skillID,
            FlashParams = {skillID},
        }
        Tooltip._SetNextTooltipSource(sourceData)
    end
end)

---------------------------------------------
-- BOTTOM BAR
---------------------------------------------

---Updates tooltip source data for tooltips originating from BottomBar.
---@param ui UIObject
---@param funcName string
---@param char EclCharacter
---@param slotID integer 0-based.
function Tooltip._UpdateBottomBarCSourceData(ui, funcName, char, slotID)
    -- Convert slot index to skillbar index
    local SLOTS_PER_ROW = ui:GetRoot().slotAmount
    local itemIndex = SLOTS_PER_ROW * char.PlayerData.SelectedSkillSet + slotID -- On controller, SelectedSkillSet is directly the 1st skillbar index to show on the UI.
    local slot = char.PlayerData.SkillBarItems[itemIndex + 1]

    if slot.Type ~= "None" then
        local statID = slot.SkillOrStatId
        local tooltipType ---@type TooltipLib_TooltipType
        if slot.Type == "Skill" or slot.Type == "Action" then
            tooltipType = "Skill"
        elseif slot.Type == "Item" then
            tooltipType = "Item"
        else
            Tooltip:__LogWarning("(UICall Listener) BottomBarC:updateSelection", "Unimplemented tooltip type for slot type", slot.Type)
        end
        ---@type TooltipLib_TooltipSourceData
        local sourceData = {
            UIType = ui:GetTypeId(),
            UICall = funcName,
            Type = tooltipType,
            FlashCharacterHandle = Ext.UI.HandleToDouble(char.Handle),
            FlashItemHandle = Ext.UI.HandleToDouble(slot.ItemHandle),
            SkillID = statID,
            FlashParams = {statID},
            IsFromGame = true,
        }
        Tooltip._SetNextTooltipSource(sourceData)
        Tooltip:DebugLog("Received BottomBarC tooltip source data")
    end
end

-- Listen for input events that come right before bottom bar tooltips being updated to track tooltip sources.
GameState.Events.GameReady:Subscribe(function (_)
    Ext.Events.InputEvent:Subscribe(function (ev)
        local name = Client.Input.GetGameEvent(ev.Event.EventId).EventName
        local tickDelay = Tooltip.CONTROLLER_BOTTOMBAR_TOOLTIP_REFRESH_INPUTEVENTS[name]
        if tickDelay then
            local ui = BottomBarC:GetUI()
            local root = ui:GetRoot()
            local currentSlotIndex = root.bottombar_mc.slotsHolder_mc.currentHLSlot

            -- For events other than opening the bar, only update the info if the bar is active.
            if (name == "ToggleSkills" and Client.Input.IsAcceptingInput()) or BottomBarC.IsActive() then
                Timer.StartTickTimer(tickDelay, function ()
                    Tooltip._UpdateBottomBarCSourceData(ui, "updateSelection", Client.GetCharacter(), currentSlotIndex) -- TODO splitscreen support
                end)
            end
        end
    end)
end, {EnabledFunctor = Client.IsUsingController})

-- Handle skills being selected.
BottomBarC:RegisterCallListener("updateSelection", function (ev, slotID)
    local char = Client.GetCharacter()
    Tooltip._UpdateBottomBarCSourceData(ev.UI, "updateSelection", char, slotID)
end)

---------------------------------------------
-- PARTY INVENTORY
---------------------------------------------

-- Handle item tooltips.
PartyInventoryC:RegisterCallListener("slotOver", function (ev, itemFlashHandle, slotFlashIndex, inventoryOwnerFlashHandle)
    if itemFlashHandle ~= 0 then
        ---@type TooltipLib_TooltipSourceData
        local sourceData = {
            UIType = ev.UI:GetTypeId(),
            UICall = ev.Function,
            Type = "Item",
            FlashCharacterHandle = Ext.UI.HandleToDouble(Client.GetCharacter().Handle), -- Tooltips are generated based on active character, not the owner of the inventory being browsed.
            FlashItemHandle = itemFlashHandle,
            FlashParams = {itemFlashHandle, slotFlashIndex, inventoryOwnerFlashHandle},
            IsFromGame = true,
        }
        Tooltip._SetNextTooltipSource(sourceData)
    end
end)

---------------------------------------------
-- EQUIPMENT PANEL
---------------------------------------------

-- Handle item tooltips.
local function OnEquipmentPanelItemSelected(ev, itemFlashHandle)
    if itemFlashHandle ~= 0 then
        ---@type TooltipLib_TooltipSourceData
        local sourceData = {
            UIType = ev.UI:GetTypeId(),
            UICall = ev.Function,
            Type = "Item",
            FlashCharacterHandle = Ext.UI.HandleToDouble(Client.GetCharacter().Handle),
            FlashItemHandle = itemFlashHandle,
            FlashParams = {itemFlashHandle},
            IsFromGame = true,
        }
        Tooltip._SetNextTooltipSource(sourceData)
    end
end
EquipmentPanelC:RegisterCallListener("itemDollOver", OnEquipmentPanelItemSelected) -- Equipped items.
EquipmentPanelC:RegisterCallListener("itemOver", OnEquipmentPanelItemSelected) -- Items within the swapping widget.

---------------------------------------------
-- OTHER
---------------------------------------------

-- Handle controller formatted tooltips.
for _,uiData in ipairs(Tooltip.CONTROLLER_UIS) do
    for _,invokeData in ipairs(uiData.Invokes) do
        uiData.UI:RegisterInvokeListener(invokeData.FunctionName, function (ev)
            -- Some UIObjects call the invoke even when no tooltip is expected, with a check within flash for whether the array is empty.
            -- We need to respect this to avoid erroneous hooks from firing.
            if ev.UI:GetRoot()[invokeData.ArrayName].length > 0 then
                Tooltip:DebugLog("Handling tooltip for UIType", uiData.UI.UITypeID)
                Tooltip._HandleFormattedTooltip(ev, invokeData.ArrayName, Tooltip.nextTooltipData)
            end
        end)
    end
end
