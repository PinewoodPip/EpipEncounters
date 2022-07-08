
local Generic = Client.UI.Generic

---@class GenericUI_Element_Text : GenericUI_Element
---@field SetText fun(self, text:string)

---@type GenericUI_Element_Text
Client.UI.Generic.ELEMENTS.Text = {}
local Text = Client.UI.Generic.ELEMENTS.Text
Inherit(Text, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

Text.SetText = Generic.ExposeFunction("SetText")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Text", Text)