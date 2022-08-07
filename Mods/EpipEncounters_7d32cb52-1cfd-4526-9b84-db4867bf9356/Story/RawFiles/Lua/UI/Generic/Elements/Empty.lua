
local Generic = Client.UI.Generic

---@class GenericUI_Element_Empty : GenericUI_Element
local Empty = {
    Events = {},
}
Generic.Inherit(Empty, Generic._Element)

Generic.RegisterElementType("Empty", Empty)