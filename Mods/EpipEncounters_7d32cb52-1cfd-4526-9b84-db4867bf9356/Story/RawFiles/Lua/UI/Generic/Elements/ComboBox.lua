
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_ComboBox : GenericUI_Element
---@field AddOption fun(self, ID:string, label:string)
---@field SelectOption fun(self, ID:string)
---@field ClearOptions fun(self)
---@field SetOpenUpwards fun(self, openUpwards:boolean)
local ComboBox = {
    Events = {
        ---@type SubscribableEvent<GenericUI_Element_ComboBox_Event_OptionSelected>
        OptionSelected = {},
    }
}
Client.UI.Generic.ELEMENTS.ComboBox = ComboBox
Generic.Inherit(ComboBox, Generic._Element)

---@class GenericUI_Element_ComboBox_Option
---@field Label string
---@field ID string

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_ComboBox_Event_OptionSelected
---@field Option GenericUI_Element_ComboBox_Option
---@field Index integer

---------------------------------------------
-- METHODS
---------------------------------------------

ComboBox.AddOption = Generic.ExposeFunction("AddOption")
ComboBox.SelectOption = Generic.ExposeFunction("SelectOption")
ComboBox.ClearOptions = Generic.ExposeFunction("ClearOptions")
ComboBox.SetOpenUpwards = Generic.ExposeFunction("SetOpenUpwards")

---@param options GenericUI_Element_ComboBox_Option[]
function ComboBox:SetOptions(options)
    self:ClearOptions()

    for _,option in ipairs(options) do
        self:AddOption(option.ID, option.Label)
    end
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("ComboBox", ComboBox)