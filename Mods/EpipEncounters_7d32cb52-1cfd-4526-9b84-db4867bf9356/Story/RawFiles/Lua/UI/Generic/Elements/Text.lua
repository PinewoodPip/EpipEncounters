
local Generic = Client.UI.Generic

---@class GenericUI_Element_Text : GenericUI_Element
---@field SetText fun(self, text:string)
---@field SetStroke fun(self, color:uint64, size:number, alpha:number, strength:uint64, unknown:uint64)
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

Text.SetText = Generic.ExposeFunction("SetText")
Text.SetStroke = Generic.ExposeFunction("AddStroke")
Text.SetType = Generic.ExposeFunction("SetType")
Text.SetEditable = Generic.ExposeFunction("SetEditable")
Text.SetRestrictedCharacters = Generic.ExposeFunction("SetRestrictedCharacters")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Text", Text)