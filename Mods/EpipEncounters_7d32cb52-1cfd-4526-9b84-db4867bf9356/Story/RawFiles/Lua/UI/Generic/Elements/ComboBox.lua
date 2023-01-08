
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_ComboBox : GenericUI_Element
---@field Events GenericUI_Element_ComboBox_Events
local ComboBox = {

}
local _ComboBox = ComboBox ---@type GenericUI_Element_ComboBox Used to workaround an IDE issue with annotations pointing to ExposeFunction().

---Represents an option in the combobox.
---@class GenericUI_Element_ComboBox_Option
---@field Label string
---@field ID string

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_ComboBox_Events : GenericUI_Element_Events
ComboBox.Events = {
    OptionSelected = {}, ---@type Event<GenericUI_Element_ComboBox_Event_OptionSelected>
}
Generic.Inherit(ComboBox, Generic._Element)

---Fired when the user selects an option.
---@class GenericUI_Element_ComboBox_Event_OptionSelected
---@field Option GenericUI_Element_ComboBox_Option
---@field Index integer

---------------------------------------------
-- METHODS
---------------------------------------------

_ComboBox.AddOption = Generic.ExposeFunction("AddOption")
_ComboBox.SelectOption = Generic.ExposeFunction("SelectOption")
_ComboBox.ClearOptions = Generic.ExposeFunction("ClearOptions")
_ComboBox.SetOpenUpwards = Generic.ExposeFunction("SetOpenUpwards")

---Sets the options for the combobox. Equivalent to calling `ClearOptions()` then `AddOption()` for each option in the list passed.
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