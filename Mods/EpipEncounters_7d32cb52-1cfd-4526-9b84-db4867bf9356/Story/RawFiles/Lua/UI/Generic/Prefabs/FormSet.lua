
local Generic = Client.UI.Generic
local EntryPrefab = Generic.GetPrefab("GenericUI_Prefab_FormSetEntry")
local MessageBox = Client.UI.MessageBox

---@class GenericUI_Prefab_FormSet : GenericUI_Prefab_FormElement
---@field HorizontalList GenericUI_Element_HorizontalList
---@field AddButton GenericUI_Element_Button
---@field _MinimumSize Vector2
local Prefab = {
    Events = {
        EntryRemoved = {}, ---@type Event<GenericUI_Prefab_FormSet_Event_EntryModified>
        EntryAdded = {}, ---@type Event<GenericUI_Prefab_FormSet_Event_EntryModified>
    }
}
Inherit(Prefab, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("GenericUI_Prefab_FormSet", Prefab)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Prefab_FormSet_Event_EntryModified
---@field Value string

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param minimumSize Vector2
---@return GenericUI_Prefab_FormSet
function Prefab.Create(ui, id, parent, label, minimumSize)
    local instance = Prefab:_Create(ui, id) ---@type GenericUI_Prefab_FormSet
    instance._MinimumSize = minimumSize

    instance:__SetupBackground(parent, minimumSize)
    instance:SetLabel(label)

    local list = instance:CreateElement("List", "GenericUI_Element_HorizontalList", instance.Background)
    list:SetPosition(0, minimumSize[2])

    local addButton = instance:CreateElement("AddButton", "GenericUI_Element_Button", instance.Background)
    addButton:SetType("Brown")
    addButton:SetText("Add", 3)
    addButton:SetPositionRelativeToParent("TopRight", -15, 15)
    addButton.Events.Pressed:Subscribe(function (_)
        Client.UI.MessageBox.Open({
            Type = "Input",
            Header = "Add entry", -- TODO allow customization and localize default text
            Message = "Enter an entry.",
            ID = "Epip_GenericUI_FormSet_AddEntry",
            Buttons = {
                {ID = 1, Text = "Add"},
                {ID = 2, Text = "Cancel"},
            },
            _Prefab = instance,
        })
    end)

    instance.HorizontalList = list

    return instance
end

---@param setting SettingsLib_Setting_Set
function Prefab:RenderFromSetting(setting)
    local list = self.HorizontalList
    local set = setting:GetValue() ---@type DataStructures_Set

    list:Clear()
    for element in set:Iterator() do
        self:_AddEntry(tostring(element))
    end

    self:SetBackgroundSize(self._MinimumSize + Vector.Create(0, list:GetHeight()))
end

---Adds an entry onto the element.
---@param label string
function Prefab:_AddEntry(label)
    local entry = EntryPrefab.Create(self.UI, self:PrefixID(label), self.HorizontalList, label, Vector.Create(100, 30))

    entry.Events.RemovePressed:Subscribe(function (_)
        self.Events.EntryRemoved:Throw({
            Value = label,
        })
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for entries being added through the message box.
MessageBox.RegisterMessageListener("Epip_GenericUI_FormSet_AddEntry", MessageBox.Events.InputSubmitted, function (text, buttonID, params)
    if buttonID == 1 then
        local prefab = params._Prefab ---@type GenericUI_Prefab_FormSet
    
        prefab.Events.EntryAdded:Throw({
            Value = text,
        })
    end
end)