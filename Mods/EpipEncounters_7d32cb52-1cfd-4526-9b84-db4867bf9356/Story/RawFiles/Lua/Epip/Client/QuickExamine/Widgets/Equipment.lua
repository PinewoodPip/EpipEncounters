
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local CommonStrings = Text.CommonStrings
local V = Vector.Create

---@class Features.QuickExamine.Widgets.Equipment : Feature
local Equipment = {
    ---Values should be unique.
    ---Slot to integer map is initialized after feature registration.
    ---@type table<ItemSlot, integer>|table<integer, ItemSlot>
    SLOT_ORDER = {
        "Helmet",
        "Breast",
        "Leggings",
        "Boots",
        "Gloves",
        "Belt",

        "Weapon",
        "Shield",
        "Ring",
        "Ring2",
        "Amulet",
    },
    SKILL_ICON_SIZE = 40,
    MAX_COLUMNS = 6, -- Maximum amount of columns in the grid.

    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h0cd1bcdcgdf0cg4740gaa47g6c551697f31a",
            Text = "Show Equipped Items",
            ContextDescription = "Setting name for the widget",
        },
        Setting_Enabled_Description = {
            Handle = "h130006d8gccb5g4164g87aeged4685812627",
            Text = "If enabled, the target character's equipped items will be shown on the Quick Examine UI.",
            ContextDescription = "Setting tooltip for equipped items widget",
        },
    },
    Settings = {},
}
Epip.RegisterFeature("Features.QuickExamine.Widgets.Equipment", Equipment)
local TSK = Equipment.TranslatedStrings

-- Setup the slot -> order index map.
for i,slot in ipairs(Equipment.SLOT_ORDER) do
    Equipment.SLOT_ORDER[slot] = i
end

---------------------------------------------
-- SETTINGS
---------------------------------------------

Equipment.Settings.Enabled = Equipment:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = true,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Renders an item onto a container.
---@param container GenericUI_Element_Grid
---@param char EclCharacter
---@param item EclItem Must be equipped.
function Equipment._RenderItem(container, char, item)
    local element = HotbarSlot.Create(QuickExamine.UI, "ItemSlot_" .. tostring(Item.GetEquippedSlot(item)), container)
    local movieClip = element.SlotElement:GetMovieClip()
    local ownerHandle = char.Handle

    element:SetUpdateDelay(-1)
    element:SetUsable(false)
    element:SetItem(item)
    element:SetEnabled(true)
    element:SetCooldown(0)
    element:SetIcon(Item.GetIcon(item))
    movieClip.width = Equipment.SKILL_ICON_SIZE
    movieClip.height = Equipment.SKILL_ICON_SIZE

    element.Hooks.GetTooltipData:Subscribe(function (ev)
        local position = V(QuickExamine.UI:GetUI():GetPosition())

        ev.Owner = Character.Get(ownerHandle)
        ev.Position = position - V(420, 0) -- Rough width of tooltip UI
    end)
end

---------------------------------------------
-- WIDGET
---------------------------------------------

local Widget = QuickExamine.RegisterWidget("Features.QuickExamine.Widgets.Equipment", {Setting = Equipment.Settings.Enabled})

---@override
function Widget:CanRender(entity)
    local equippedItems = {}
    if Entity.IsCharacter(entity) then
        ---@cast entity EclCharacter
        -- Only show the widget for player characters.
        if Character.IsPlayer(entity) then
            equippedItems = Character.GetEquippedItems(entity)
        end
    end

    -- Only show the widget for characters with any items equipped in visible slots.
    return Equipment:IsEnabled() and table.getFirst(equippedItems, function (slot, _)
        return Equipment.SLOT_ORDER[slot] ~= nil
    end) ~= nil
end

---@override
function Widget:Render(entity)
    ---@cast entity EclCharacter
    local container = QuickExamine.GetContainer()

    self:CreateHeader("Equipment_Header", container, CommonStrings.Equipment:GetString())

    local grid = container:AddChild("Equipment_Grid", "GenericUI_Element_Grid")
    grid:SetGridSize(6, -1)

    local columns = math.min(QuickExamine.GetContainerWidth() / Equipment.SKILL_ICON_SIZE - 2, Equipment.MAX_COLUMNS)
    grid:SetCenterInLists(true)
    grid:SetGridSize(columns, -1) -- Prefer the set amount of columns, use container size as fallback.

    local items = Character.GetEquippedItems(entity)
    local orderedItems = {} -- Order items by slot enum value.
    for _,item in pairs(items) do
        table.insert(orderedItems, item)
    end
    table.sort(orderedItems, function (a, b)
        local slotA, slotB = Ext.Enums.ItemSlot[Item.GetEquippedSlot(a)], Ext.Enums.ItemSlot[Item.GetEquippedSlot(b)]
        return Equipment.SLOT_ORDER[slotA] < Equipment.SLOT_ORDER[slotB]
    end)
    for _,item in ipairs(orderedItems) do
        Equipment._RenderItem(grid, entity, item)
    end

    -- Center the second row if not all columns are filled
    local slotsInSecondRow = #orderedItems - columns
    local missingSlots = columns - slotsInSecondRow
    local slots = grid:GetChildren()
    local slotWidth = slots[1]:GetWidth()
    for i=columns+1,#orderedItems,1 do
        local slot = slots[i]
        local x, y = slot:GetPosition()
        slot:SetPosition(x + missingSlots * slotWidth / 2, y)
    end

    self:CreateDivider("EquipmentDivider", container)
end
