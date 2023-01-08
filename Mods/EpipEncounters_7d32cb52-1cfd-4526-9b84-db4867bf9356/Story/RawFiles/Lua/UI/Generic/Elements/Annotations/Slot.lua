
---@meta

---@class GenericUI_Element_Slot : GenericUI_Element_IggyIcon
local Slot = {}

---Sets the cooldown displayed by the slot.
---@param cooldown number In turns.
---@param playRefreshAnimation boolean? Defaults to false. If set to true and the cooldown is <= 0, a blink animation will be played.
function Slot:SetCooldown(cooldown, playRefreshAnimation) end

---Sets whether the slot is enabled. Disabled slots are greyed out.
---@param enabled boolean
function Slot:SetEnabled(enabled) end

---Sets the label shown on the bottom right of the slot.
---@param label string
function Slot:SetLabel(label) end

---Sets whether the slot should display a blue border.
---@param enabled boolean
function Slot:SetSourceBorder(enabled) end

---Sets whether the slot should display a warning graphic.
---@param enabled boolean
function Slot:SetWarning(enabled) end

---Sets whether the slot is active. Active slots play a looping ripple animation.
---@param active boolean
function Slot:SetActive(active) end

---Sets whether the slot is highlighted.
---@param highlighted boolean
function Slot:SetHighlighted(highlighted) end