
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local V = Vector.Create

local RadialMenus = Epip.GetFeature("Features.RadialMenus")

---@class Features.RadialMenus.Prefabs.Slot : GenericUI_Prefab, GenericUI_I_Elementable
---@field Root GenericUI_Element_Empty
---@field Icon GenericUI_Element_IggyIcon
---@field Header GenericUI_Prefab_Text
---@field _Slot Features.RadialMenus.Slot
local Slot = {
    ICON_SIZE = V(48, 48),
    HEADER_SIZE = V(150, 150)
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

    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)
    instance.Root = root

    local icon = instance:CreateElement("Icon", "GenericUI_Element_IggyIcon", root)
    if slot.Icon then
        icon:SetIcon(slot.Icon, instance.ICON_SIZE:unpack())
    else
        icon:SetVisible(false)
    end
    instance.Icon = icon

    local header = TextPrefab.Create(ui, instance:PrefixID("Header"), root, slot.Name, "Center", instance.HEADER_SIZE)
    header:FitSize()
    header:Move(0, icon:GetHeight())
    instance.Header = header

    -- If the header doesn't fit in one line, resize to minimum height.
    if header:GetWidth() > instance.HEADER_SIZE[1] then
        header:SetWordWrap(true) -- Necessary to determine minimum text height with wrapping considered.
        header:SetSize(instance.HEADER_SIZE[1], math.maxinteger)
        local width, height = instance.HEADER_SIZE:unpack(), header:GetTextSize()[2]
        header:SetSize(width, height)
    end

    -- Center the icon horizontally
    icon:Move(header:GetWidth() / 2 - icon:GetWidth() / 2, 0)

    return instance
end

---@override
function Slot:GetRootElement()
    return self.Root
end
