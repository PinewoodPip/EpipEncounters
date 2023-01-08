
local Generic = Client.UI.Generic

---@class GenericUI_Element_Text : GenericUI_Element
---@field Events GenericUI_Element_Text_Events
local Text = {
    ---@enum GenericUI_Element_Text_Align
    TYPES = {
        LEFT_ALIGN = "Left",
        CENTER_ALIGN = "Center",
        RIGHT_ALIGN = "Right",
    },
}
local _Text = Text

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_Text_Events : GenericUI_Element_Events
Text.Events = {
    Changed = {}, ---@type Event<GenericUI_Element_Text_Event_Changed>
}
Generic.Inherit(Text, Generic._Element)

---@class GenericUI_Element_Text_Event_Changed
---@field Text string

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets the stroke style and color of the text element.
---@param color uint64|RGBColor
---@param size number
---@param alpha number
---@param strength uint64
---@param unknown uint64
function Text:SetStroke(color, size, alpha, strength, unknown)
    local root = self:GetMovieClip()
    local tableType = GetMetatableType(color)
    if tableType and tableType == "RGBColor" then
        color = color:ToDecimal()
    end

    root.AddStroke(color, size, alpha, strength, unknown)
end

_Text.SetText = Generic.ExposeFunction("SetText")
_Text.SetType = Generic.ExposeFunction("SetType")
_Text.SetEditable = Generic.ExposeFunction("SetEditable")
_Text.SetRestrictedCharacters = Generic.ExposeFunction("SetRestrictedCharacters")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Text", Text)