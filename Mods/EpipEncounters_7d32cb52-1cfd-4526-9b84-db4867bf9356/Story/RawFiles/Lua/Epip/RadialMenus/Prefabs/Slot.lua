
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local V = Vector.Create

local RadialMenus = Epip.GetFeature("Features.RadialMenus")

---@class Features.RadialMenus.Prefabs.Slot : GenericUI_Prefab, GenericUI_I_Elementable
---@field Root GenericUI_Element_Empty
---@field Icon GenericUI_Element_IggyIcon? Created only for slot types that do not use HotbarSlot.
---@field Header GenericUI_Prefab_Text
---@field HotbarSlot GenericUI_Prefab_HotbarSlot? Created only when necessary.
---@field _Slot Features.RadialMenus.Slot
local Slot = {
    ICON_SIZE = V(48, 48),
    HEADER_SIZE = V(150, 150),

    ---@type set<Features.RadialMenus.Slot.Type>
    HOTBAR_LIKE_SLOT_TYPES = {
        ["Skill"] = true,
        ["Item"] = true,
    },
}
RadialMenus:RegisterClass("Features.RadialMenus.Prefabs.Slot", Slot, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("Features.RadialMenus.Prefabs.Slot", Slot)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier
---@param slot Features.RadialMenus.Slot
---@return Features.RadialMenus.Prefabs.Slot
function Slot.Create(ui, id, parent, slot)
    local instance = Slot:_Create(ui, id) ---@cast instance Features.RadialMenus.Prefabs.Slot
    instance._Slot = slot

    local slotData = RadialMenus.GetSlotData(slot)

    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)
    instance.Root = root

    -- Create icon-like element
    local iconElement = nil ---@type GenericUI_Element
    if instance.HOTBAR_LIKE_SLOT_TYPES[slot.Type] then -- Create HotbarSlot if adequate for the slot type
        -- Note: disabling drag & other mouse events is not necessary as the RadialMenu prefab always occludes the Slots.
        local hotbarSlot = HotbarSlot.Create(ui, instance:PrefixID("HotbarSlot"), root, {
            TextLabel = slot.Type == "Item", -- Items need to display stack amount.
            CooldownAnimations = true,
        })
        if slot.Type == "Skill" then
            ---@cast slot Features.RadialMenus.Slot.Skill
            hotbarSlot:SetSkill(slot.SkillID)
        elseif slot.Type == "Item" then
            ---@cast slot Features.RadialMenus.Slot.Item
            local item = Item.Get(slot.ItemHandle)
            if item then
                hotbarSlot:SetItem(item)
            end
        end
        instance.HotbarSlot = hotbarSlot
        iconElement = hotbarSlot
    else -- Use iggy icon for other types
        local icon = instance:CreateElement("Icon", "GenericUI_Element_IggyIcon", root)
        if slotData.Icon then
            icon:SetIcon(slotData.Icon, instance.ICON_SIZE:unpack())
        else
            icon:SetVisible(false)
        end
        instance.Icon = icon
        iconElement = icon
    end

    local header = TextPrefab.Create(ui, instance:PrefixID("Header"), root, slotData.Name, "Center", instance.HEADER_SIZE)
    header:FitSize()
    header:Move(0, iconElement:GetHeight())
    instance.Header = header

    -- If the header doesn't fit in one line, resize to minimum height.
    if header:GetWidth() > instance.HEADER_SIZE[1] then
        header:SetWordWrap(true) -- Necessary to determine minimum text height with wrapping considered.
        header:SetSize(instance.HEADER_SIZE[1], math.maxinteger)
        local width, height = instance.HEADER_SIZE:unpack(), header:GetTextSize()[2]
        header:SetSize(width, height)
    end

    -- Center the icon horizontally
    iconElement:Move(header:GetWidth() / 2 - iconElement:GetWidth() / 2, 0)

    return instance
end

---@override
function Slot:GetRootElement()
    return self.Root
end
