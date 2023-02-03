
---@meta

---@class GenericUI_Element_ComboBox : GenericUI_Element
local ComboBox = {}

---Sets the currently selected option.
---@param id string
function ComboBox:SelectOption(id) end

---Removes all options from the combobox.
function ComboBox:ClearOptions() end

---Sets whether the combobox should open upwards, or downwards (default)
---Use to determine the orientation of the options selector when opened.
---@param openUpwards boolean
function ComboBox:SetOpenUpwards(openUpwards) end