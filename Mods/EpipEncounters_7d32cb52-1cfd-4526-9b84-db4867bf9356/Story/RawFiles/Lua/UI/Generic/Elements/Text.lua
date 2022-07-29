
local Generic = Client.UI.Generic

---@class GenericUI_Element_Text : GenericUI_Element
---@field SetText fun(self, text:string, setSize:boolean?)
---@field SetStroke fun(self, color:uint64|RGBColor, size:number, alpha:number, strength:uint64, unknown:uint64)
---@field SetType fun(self, textType:integer)
---@field SetEditable fun(self, editable:boolean)
---@field SetRestrictedCharacters fun(self, restriction:string)

---@class GenericUI_Element_Text
Client.UI.Generic.ELEMENTS.Text = {
    TYPES = {
        LEFT_ALIGN = 0,
        CENTER_ALIGN = 1,
    },
    Events = {
        ---@type SubscribableEvent<GenericUI_Element_Event_MouseUp>
        MouseUp = {},
        ---@type SubscribableEvent<GenericUI_Element_Event_MouseDown>
        MouseDown = {},
        ---@type SubscribableEvent<GenericUI_Element_Event_MouseOver>
        MouseOver = {},
        ---@type SubscribableEvent<GenericUI_Element_Event_MouseOut>
        MouseOut = {},
        ---@type SubscribableEvent<GenericUI_Element_Text_Event_Changed>
        Changed = {},
    },
}
local Text = Client.UI.Generic.ELEMENTS.Text
Inherit(Text, Generic._Element)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_Text_Event_Changed
---@field Text string

---------------------------------------------
-- METHODS
---------------------------------------------

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

Text.SetText = Generic.ExposeFunction("SetText")
Text.SetType = Generic.ExposeFunction("SetType")
Text.SetEditable = Generic.ExposeFunction("SetEditable")
Text.SetRestrictedCharacters = Generic.ExposeFunction("SetRestrictedCharacters")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Text", Text)