
local PartyInventory = Client.UI.PartyInventory
local ContainerInventory = Client.UI.ContainerInventory
local TooltipLib = Client.Tooltip
local TooltipUI = Client.UI.Tooltip
local V = Vector.Create

---@class Features.TooltipAdjustments.InventoryTooltipsRepositioning : Feature
local TooltipRepositioning = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    -- Values for the Position setting.
    POSITIONS = {
        BY_CURSOR = 1,
        ON_UI_SIDES = 2,
    },

    TranslatedStrings = {
        Setting_Position_Name = {
            Handle = "h9035058dg4e1ag41a5g9209gccee07be7808",
            Text = "Inventory Item Tooltips Position",
            ContextDescription = "Setting name",
        },
        Setting_Position_Description = {
            Handle = "h2f7ed974g4184g404fga2abg640d32f6f7aa",
            Text = "Controls the position of item tooltips within the Party Inventory and Container Inventory UIs.<br><br>- Near cursor: vanilla behaviour; tooltips appear near the cursor.<br>- On UI sides: tooltips will be positioned on the left side of the source UI if possible, or on the right otherwise.",
            ContextDescription = "Setting tooltip",
        },
        Setting_Position_Choice_NearCursor = {
            Handle = "h6bf580c5gf8feg44b5ga13egfca29ae88c6d",
            Text = "Near Cursor",
            ContextDescription = "Dropdown setting choice",
        },
        Setting_Position_Choice_UISides = {
            Handle = "h5f55f283g3f47g4d04g9f4eg44d2617254a4",
            Text = "On UI Sides",
            ContextDescription = "Dropdown setting choice",
        },
    },
    Events = {
        OffsetRequested = {}, ---@type Event<Features.TooltipAdjustments.InventoryTooltipsRepositioning.Events.OffsetRequested>
    },
    Settings = {},
}
Epip.RegisterFeature("Features.TooltipAdjustments.InventoryTooltipsRepositioning", TooltipRepositioning)
local TSK = TooltipRepositioning.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

TooltipRepositioning.Settings.Position = TooltipRepositioning:RegisterSetting("Position", {
    Type = "Choice",
    Context = "Client",
    Name = TSK.Setting_Position_Name,
    Description = TSK.Setting_Position_Description,
    DefaultValue = TooltipRepositioning.POSITIONS.BY_CURSOR,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = TooltipRepositioning.POSITIONS.BY_CURSOR, NameHandle = TSK.Setting_Position_Choice_NearCursor.Handle},
        {ID = TooltipRepositioning.POSITIONS.ON_UI_SIDES, NameHandle = TSK.Setting_Position_Choice_UISides.Handle},
    },
})

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.TooltipAdjustments.InventoryTooltipsRepositioning.Events.OffsetRequested
---@field TooltipData TooltipLib_TooltipSourceData

---------------------------------------------
-- METHODS
---------------------------------------------

---Positions a tooltip on the left or right side of a UI.
---@param ui TooltipUI
---@param leftUIPos Vector2
---@param rightUIPos Vector2
function TooltipRepositioning._PositionTooltip(ui, leftUIPos, rightUIPos)
    local tooltipWidth = TooltipRepositioning._GetTooltipWidth(ui)
    local uiScale = ui:GetUI():GetUIScaleMultiplier()
    local pos = leftUIPos
    if pos[1] < tooltipWidth then -- Position the tooltip on the right if there is no space on the left.
        pos = rightUIPos
    else
        local offset = V(-tooltipWidth + 25 * uiScale, 0)
        pos = pos + offset
    end

    pos[1], pos[2] = math.floor(pos[1]), math.floor(pos[2])
    ui:SetPosition(pos)
end

---Returns the width of the tooltip UI, in pixels.
---@param ui TooltipUI
---@return integer
function TooltipRepositioning._GetTooltipWidth(ui)
    local tooltipRoot = ui:GetRoot()
    local tooltipMC = tooltipRoot.formatTooltip
    local compareTooltipMC = tooltipRoot.ctf
    local tooltipWidth = tooltipMC.tooltip_mc.width
    if compareTooltipMC then -- Add the width of the compare tooltip, if there is one.
        tooltipWidth = tooltipWidth + compareTooltipMC.tooltip_mc.width - 30
    end
    tooltipWidth = tooltipWidth * TooltipUI:GetUI():GetUIScaleMultiplier()

    return tooltipWidth
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Throw events requesting tooltips to be offset.
TooltipLib.Events.TooltipPositioned:Subscribe(function (_)
    local currentTooltip = TooltipLib.GetCurrentTooltipSourceData()
    if currentTooltip then
        TooltipRepositioning.Events.OffsetRequested:Throw({
            TooltipData = currentTooltip,
        })
    end
end)

-- Reposition item tooltips from the PartyInventory UI.
TooltipRepositioning.Events.OffsetRequested:Subscribe(function (ev)
    if ev.TooltipData.UIType == PartyInventory:GetUI():GetTypeId() and ev.TooltipData.Type == "Item" and ev.TooltipData.IsFromGame then -- The PartyInventory UI is used for custom tooltips by TooltipLib; we must avoid repositioning those.
        local inventoryUIObj = PartyInventory:GetUI()
        local pos = V(inventoryUIObj:GetPosition())
        local topRightCorner = pos + V(inventoryUIObj.FlashSize[1], 0)

        TooltipRepositioning._PositionTooltip(TooltipUI, pos, topRightCorner)
    end
end, {EnabledFunctor = function ()
    return TooltipRepositioning:GetSettingValue(TooltipRepositioning.Settings.Position) == TooltipRepositioning.POSITIONS.ON_UI_SIDES
end})

-- Reposition item tooltips from the PartyInventory UI.
TooltipRepositioning.Events.OffsetRequested:Subscribe(function (ev)
    if ev.TooltipData.UIType == ContainerInventory:GetUI():GetTypeId() and ev.TooltipData.Type == "Item" then
        local inventoryUIObj = ContainerInventory:GetUI()
        local inventoryMC = inventoryUIObj:GetRoot().inv_mc
        local uiScale = inventoryUIObj:GetUIScaleMultiplier()
        local parent = inventoryMC.parent
        local posX = inventoryMC.x
        while parent do -- Fetch global position of the inventory.
            posX = posX + parent.x
            parent = parent.parent
        end
        posX = posX + 250
        posX = posX * uiScale

        local pos = V(inventoryUIObj:GetPosition())
        local uiObjectPositionWasNegative = pos[1] < 0
        if uiObjectPositionWasNegative then -- If the UIObject position is negative, the X position of the MCs is different.
            pos[1] = pos[1] - 230 * uiScale
        else
            pos[1] = pos[1] + posX
        end
        pos[2] = pos[2] + 250 * uiScale

        -- Yes the differences between these 2 situations are hilariously annoying and I don't know how to handle them better.
        local topRightCorner = pos
        if uiObjectPositionWasNegative then
            topRightCorner = topRightCorner + V(1120 * uiScale, 0)
        else
            topRightCorner = topRightCorner + V(315 * uiScale, 0)
        end

        TooltipRepositioning._PositionTooltip(TooltipUI, pos, topRightCorner)
    end
end, {EnabledFunctor = function ()
    return TooltipRepositioning:GetSettingValue(TooltipRepositioning.Settings.Position) == TooltipRepositioning.POSITIONS.ON_UI_SIDES
end})
