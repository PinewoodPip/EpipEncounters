
---@meta

---@class GenericUI_Element_Button : GenericUI_Element
local Button = {}

---@alias GenericUI_Element_Button_Type "Brown"|"Red"|"RedBig"|"TextEdit"|"StatMinus"|"StatPlus"|"Close"

---Sets the button's text.
---@param text string
---@param textY number? Vertical offset for the text. Use for centering.
function Button:SetText(text, textY) end

---Sets the button's visuals.
---@param buttonType GenericUI_Element_Button_Type
function Button:SetType(buttonType) end

---Sets the button's enabled state. Enabled buttons are interactable.
---@param enabled boolean
function Button:SetEnabled(enabled) end

---Returns whether the button is enabled.
---@return boolean
function Button:IsEnabled() end