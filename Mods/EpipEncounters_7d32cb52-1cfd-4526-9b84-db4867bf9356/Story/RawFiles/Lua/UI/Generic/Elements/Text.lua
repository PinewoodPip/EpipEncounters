
local Generic = Client.UI.Generic

---@class GenericUI_Element_Text : GenericUI_Element
---@field SetText fun(self, text:string)
---@field SetStroke fun(self, color:uint64, size:number, alpha:number, strength:uint64, unknown:uint64)

---@type GenericUI_Element_Text
Client.UI.Generic.ELEMENTS.Text = {}
local Text = Client.UI.Generic.ELEMENTS.Text
Inherit(Text, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

Text.SetText = Generic.ExposeFunction("SetText")
Text.SetStroke = Generic.ExposeFunction("AddStroke")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Text", Text)