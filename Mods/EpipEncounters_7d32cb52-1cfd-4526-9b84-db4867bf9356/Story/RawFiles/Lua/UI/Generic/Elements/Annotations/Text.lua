
---@meta

---@class GenericUI_Element_Text : GenericUI_Element
local Text = {}

---Sets the element's text.
---Note that the text will be culled if it doesn't fit the dimensions of the element.
---@param text string
---@param setSize boolean? Defaults to `false`. If `true`, the element will be automatically resized to fit the new text.
function Text:SetText(text, setSize) end

---Sets the alignment of the text.
---@param textType GenericUI_Element_Text_Align
function Text:SetType(textType) end

---Sets whether the text is editable by the user.
---@param editable boolean
function Text:SetEditable(editable) end

---Sets the restriction for characters that the user can enter onto the text field.
---Has no effect on setting the text from scripting.
---@see GenericUI_Element_Text.SetEditable
---@param restriction string
function Text:SetRestrictedCharacters(restriction) end

---Returns the height of a line.
---@param lineIndex integer 1-based.
---@return number
function Text:GetLineHeight(lineIndex) end