
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI_Prefab_LabelledIcon : GenericUI_Prefab
local Icon = {
    Icon = nil, ---@type GenericUI_Element_IggyIcon
    Text = nil, ---@type GenericUI_Prefab_Text
    List = nil, ---@type GenericUI_Element_HorizontalList
}
Generic.RegisterPrefab("GenericUI_Prefab_LabelledIcon", Icon)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param icon string
---@param text string
---@param iconSize Vector2
---@param textSize Vector2
---@return GenericUI_Prefab_LabelledIcon
function Icon.Create(ui, id, parent, icon, text, iconSize, textSize)
    local obj = Icon:_Create(ui, id, parent) ---@type GenericUI_Prefab_LabelledIcon

    local list = obj.UI:CreateElement(obj:PrefixID("Container"), "GenericUI_Element_HorizontalList", parent)
    obj.List = list

    local iconElement = list:AddChild(obj:PrefixID("Icon"), "GenericUI_Element_IggyIcon")
    iconElement:SetIcon(icon, iconSize:unpack())
    iconElement:SetCenterInLists(true)
    obj.Icon = iconElement

    local textElement = TextPrefab.Create(ui, obj:PrefixID("Text"), list, text, "Left", textSize)
    obj.Text = textElement

    list:RepositionElements()
    
    return obj
end