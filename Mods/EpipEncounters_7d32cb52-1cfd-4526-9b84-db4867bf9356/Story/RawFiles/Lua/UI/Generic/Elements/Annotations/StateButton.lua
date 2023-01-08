
---@meta

---@class GenericUI_Element_StateButton : GenericUI_Element
local StateButton = {}

---Sets the button's visuals.
---@param buttonType GenericUI_Element_StateButton_Type
function StateButton:SetType(buttonType) end

---Sets whether the button is active.<br>
---This has no intrinsic meaning, other than altering the button's graphics.
---@param active boolean
function StateButton:SetActive(active) end

---Sets whether the button is enabled.<br>
---Enabled buttons are interactable and their active state can be changed by the user.
---@param enabled boolean
function StateButton:SetEnabled(enabled) end