
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local CommonStrings = Text.CommonStrings
local V = Vector.Create

---@class Features.QuickExamine.Widgets.Equipment : Feature
local Equipment = {
    MAX_COLUMNS = 6, -- Maximum amount of columns in the grid.
    SLOT_ORDER_SETTING_VALUES = {
        WEAPONS_AND_TRINKETS_FIRST = "WeaponsAndTrinketsFirst",
        ARMOR_FIRST = "ArmorFirst",
    },

    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h0cd1bcdcgdf0cg4740gaa47g6c551697f31a",
            Text = "Show Equipped Items",
            ContextDescription = "Setting name for the widget",
        },
        Setting_Enabled_Description = {
            Handle = "h130006d8gccb5g4164g87aeged4685812627",
            Text = "If enabled, the Quick Examine UI will show the equipped items of player characters.",
            ContextDescription = "Setting tooltip for equipped items widget",
        },
        Setting_SlotOrder_Name = {
            Handle = "h614e84c5g5e03g4672g8b1cga7a8455f4a5a",
            Text = "Equipment Slots Order",
            ContextDescription = "Setting name",
        },
        Setting_SlotOrder_Description = {
            Handle = "h405ae4b4g1499g463fgbe98ge384c0eaac2e",
            Text = "Determines the order in which equipment slots are shown in Quick Examine's equipment widget.",
            ContextDescription = "Setting tooltip",
        },
        Setting_SlotOrder_Choice_WeaponAndTrinketsFirst = {
            Handle = "h7b5b3f77gecb7g400cgafedg1be1b2227264",
            Text = "Weapons & Accessories First",
            ContextDescription = [[Option name for "Equipment Slots Order" setting.]],
        },
        Setting_SlotOrder_Choice_ArmorFirst = {
            Handle = "he518f8b3gac8eg4855gb7b3gfd6217a94fde",
            Text = "Armor First",
            ContextDescription = [[Option name for "Equipment Slots Order" setting.]],
        },
    },
    Settings = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetSlots = {}, ---@type Hook<Features.QuickExamine.Widgets.Equipment.Hooks.GetSlots>
    },
}
Epip.RegisterFeature("Features.QuickExamine.Widgets.Equipment", Equipment)
local TSK = Equipment.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Equipment.Settings.Enabled = Equipment:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = true,
})
Equipment.Settings.SlotOrder = Equipment:RegisterSetting("SlotOrder", {
    Type = "Choice",
    Context = "Client",
    NameHandle = TSK.Setting_SlotOrder_Name,
    DescriptionHandle = TSK.Setting_SlotOrder_Description,
    DefaultValue = Equipment.SLOT_ORDER_SETTING_VALUES.WEAPONS_AND_TRINKETS_FIRST,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = Equipment.SLOT_ORDER_SETTING_VALUES.WEAPONS_AND_TRINKETS_FIRST, NameHandle = TSK.Setting_SlotOrder_Choice_WeaponAndTrinketsFirst.Handle},
        {ID = Equipment.SLOT_ORDER_SETTING_VALUES.ARMOR_FIRST, NameHandle = TSK.Setting_SlotOrder_Choice_ArmorFirst.Handle},
    },
})

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.QuickExamine.Widgets.Equipment.Hooks.GetSlots
---@field Slots ItemSlot[] Hookable. Slots to display as well as their order. Defaults to empty list.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the slots to show as well as their order.
---@see Features.QuickExamine.Widgets.Equipment.Hooks.GetSlots
---@return ItemSlot[]
function Equipment.GetSlots()
    return Equipment.Hooks.GetSlots:Throw({
        Slots = {},
    }).Slots
end

---------------------------------------------
-- WIDGET
---------------------------------------------

---@type Features.QuickExamine.Widgets.Grid
local Widget = {
    HEADER_LABEL = CommonStrings.Equipment,
    Setting = Equipment.Settings.Enabled,
}
Equipment:RegisterClass("Features.QuickExamine.Widgets.Equipment.Widget", Widget, {"Features.QuickExamine.Widgets.Grid"})
QuickExamine.RegisterWidget(Widget)

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
    local visibleSlots = table.swap(Equipment.GetSlots())
    return Equipment:IsEnabled() and table.getFirst(equippedItems, function (slot, _)
        return visibleSlots[slot] ~= nil
    end) ~= nil
end

---Renders an item onto the grid.
---@param char EclCharacter
---@param item EclItem Must be equipped.
function Widget:RenderItem(char, item)
    local grid = self.Grid
    local element = HotbarSlot.Create(QuickExamine.UI, "ItemSlot_" .. tostring(Item.GetEquippedSlot(item)), grid)
    local ownerHandle = char.Handle

    element:SetUpdateDelay(-1)
    element:SetUsable(false)
    element:SetItem(item)
    element:SetEnabled(true)
    element:SetCooldown(0)
    element:SetIcon(Item.GetIcon(item))
    element:SetSize(self.ELEMENT_SIZE, self.ELEMENT_SIZE)

    element.Hooks.GetTooltipData:Subscribe(function (ev)
        local position = V(QuickExamine.UI:GetUI():GetPosition())

        ev.Owner = Character.Get(ownerHandle)
        ev.Position = position - V(420, 0) -- Rough width of tooltip UI
    end)
end

---@override
function Widget:RenderGridElements(entity)
    ---@cast entity EclCharacter
    local columns = self:GetGridSize()[1]
    local grid = self.Grid

    local items = Character.GetEquippedItems(entity)
    local orderedItems = {} -- Order items by slot enum value.
    for _,item in pairs(items) do
        table.insert(orderedItems, item)
    end
    local slotOrder = table.swap(Equipment.GetSlots())
    table.sort(orderedItems, function (a, b)
        local slotA, slotB = Ext.Enums.ItemSlot[Item.GetEquippedSlot(a)], Ext.Enums.ItemSlot[Item.GetEquippedSlot(b)]
        return slotOrder[slotA] < slotOrder[slotB]
    end)
    for _,item in ipairs(orderedItems) do
        self:RenderItem(entity, item)
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
end

---@override
function Widget:GetGridSize()
    -- Prefer the set amount of columns, and use container size as fallback.
    return V(math.min(QuickExamine.GetContainerWidth() / self.ELEMENT_SIZE - 2, Equipment.MAX_COLUMNS), -1)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Set slot order based on settings.
Equipment.Hooks.GetSlots:Subscribe(function (ev)
    local slotOrderSetting = Equipment.Settings.SlotOrder:GetValue()
    if slotOrderSetting == Equipment.SLOT_ORDER_SETTING_VALUES.WEAPONS_AND_TRINKETS_FIRST then
        ev.Slots = {
            "Weapon",
            "Shield",
            "Ring",
            "Ring2",
            "Amulet",
            "Belt",

            "Helmet",
            "Breast",
            "Leggings",
            "Boots",
            "Gloves",
        }
    elseif slotOrderSetting == Equipment.SLOT_ORDER_SETTING_VALUES.ARMOR_FIRST then
        ev.Slots = {
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
        }
    end
end, {StringID = "DefaultImplementation"})
