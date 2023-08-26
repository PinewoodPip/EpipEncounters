
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
        EntryElementCreated = {}, ---@type Event<GenericUI_Prefab_FormSet_Event_EntryElementCreated>
    }
}
Generic:RegisterClass("GenericUI_Prefab_FormSet", Prefab, {"GenericUI_Prefab_FormElement"})
Generic.RegisterPrefab("GenericUI_Prefab_FormSet", Prefab)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_FormSet"

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Prefab_FormSet_Event_EntryElementCreated
---@field Element GenericUI_Prefab_FormSetEntry

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

    instance:_CreateList()

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

    return instance
end

---@param setting SettingsLib_Setting_Set
function Prefab:RenderFromSetting(setting)
    local list = self.HorizontalList
    local set = setting:GetValue() ---@type DataStructures_Set

    list = self:_CreateList()
    for element in set:Iterator() do
        self:_AddEntry(tostring(element))
    end
    list:RepositionElements()

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

    self.Events.EntryElementCreated:Throw({
        Element = entry,
    })
end

---@return GenericUI_Element_HorizontalList
function Prefab:_CreateList()
    local list = self.HorizontalList

    if list then -- TODO investigate issue with Clear() when row holders are used
        list:Destroy()
    end

    list = self:CreateElement("List", "GenericUI_Element_HorizontalList", self.Background)
    list:GetMovieClip().list.m_MaxWidth = self._MinimumSize[1]
    list:SetElementSpacing(15)
    list:SetRepositionAfterAdding(false)
    list:SetPosition(0, self._MinimumSize[2])

    self.HorizontalList = list

    return self.HorizontalList
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