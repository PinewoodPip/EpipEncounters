
---------------------------------------------
-- Implements a 9-sliced or 3-sliced resizable texture.
---------------------------------------------

local Generic = Client.UI.Generic
local V = Vector.Create

---@class GenericUI.Prefabs.SlicedTexture : GenericUI_Prefab, GenericUI_I_Stylable, GenericUI_I_Elementable
---@field Root GenericUI_Element_Empty Contains only `Texture` children.
---@field __Style GenericUI.Prefabs.SlicedTexture.Style
---@field _Size Vector2
local SlicedTexture = {
    -- Forwarded from RootElement.
    Events = {
        MouseUp = {}, ---@type Event<GenericUI_Element_Event_MouseUp>
        MouseDown = {}, ---@type Event<GenericUI_Element_Event_MouseDown>
        MouseOver = {}, ---@type Event<GenericUI_Element_Event_MouseOver>
        MouseOut = {}, ---@type Event<GenericUI_Element_Event_MouseOut>
        RightClick = {}, ---@type Event<GenericUI_Element_Event_RightClick>
        TweenCompleted = {}, ---@type Event<GenericUI_Element_Event_TweenCompleted>
        ChildAdded = {}, ---@type Event<GenericUI.Element.Events.ChildAdded>
    },
}
Generic:RegisterClass("GenericUI.Prefabs.SlicedTexture", SlicedTexture, {"GenericUI_Prefab", "GenericUI_I_Stylable", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI.Prefabs.SlicedTexture", SlicedTexture)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.SlicedTexture"

---@alias GenericUI.Prefabs.SlicedTexture.Style.Type "9-Sliced"|"3-Sliced Horizontal"|"3-Sliced Vertical"

---@class GenericUI.Prefabs.SlicedTexture.Style : GenericUI_I_Stylable_Style
---@field Type GenericUI.Prefabs.SlicedTexture.Style.Type See package classes.

---@class GenericUI.Prefabs.SlicedTexture.Style.9Sliced : GenericUI.Prefabs.SlicedTexture.Style
---@field TopLeft TextureLib_Texture
---@field Left TextureLib_Texture
---@field BottomLeft TextureLib_Texture
---@field Top TextureLib_Texture
---@field Center TextureLib_Texture
---@field Bottom TextureLib_Texture
---@field TopRight TextureLib_Texture
---@field Right TextureLib_Texture
---@field BottomRight TextureLib_Texture

---@class GenericUI.Prefabs.SlicedTexture.Style.3SlicedHorizontal : GenericUI.Prefabs.SlicedTexture.Style
---@field Left TextureLib_Texture
---@field Center TextureLib_Texture
---@field Right TextureLib_Texture

---@class GenericUI.Prefabs.SlicedTexture.Style.3SlicedVertical : GenericUI.Prefabs.SlicedTexture.Style
---@field Top TextureLib_Texture
---@field Center TextureLib_Texture
---@field Bottom TextureLib_Texture

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a sliced texture.
---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@param style GenericUI.Prefabs.SlicedTexture.Style
---@param size Vector2
---@return GenericUI.Prefabs.SlicedTexture
function SlicedTexture.Create(ui, id, parent, style, size)
    local instance = SlicedTexture:_Create(ui, id) ---@type GenericUI.Prefabs.SlicedTexture
    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)

    instance._Size = size
    instance.Root = root
    instance:SetStyle(style)

    -- Forward events
    for eventID,eventTbl in pairs(instance.Events) do
        root.Events[eventID]:Subscribe(function (ev)
            eventTbl:Throw(ev)
        end)
    end

    return instance
end

---@override
function SlicedTexture:GetRootElement()
    return self.Root
end

---Updates the prefab's textures to match the current style and size.
function SlicedTexture:_UpdateTextures()
    local style = self.__Style
    -- Destroy previous children
    for _,child in ipairs(self:GetChildren()) do
        child:Destroy()
    end

    if style.Type == "9-Sliced" then
        ---@cast style GenericUI.Prefabs.SlicedTexture.Style.9Sliced
        local top = self:CreateElement("Top", "GenericUI_Element_Texture", self.Root)
        local topRight = self:CreateElement("TopRight", "GenericUI_Element_Texture", self.Root)
        local topLeft = self:CreateElement("TopLeft", "GenericUI_Element_Texture", self.Root)
        local left = self:CreateElement("Left", "GenericUI_Element_Texture", self.Root)
        local center = self:CreateElement("Center", "GenericUI_Element_Texture", self.Root)
        local right = self:CreateElement("Right", "GenericUI_Element_Texture", self.Root)
        local bottomLeft = self:CreateElement("BottomLeft", "GenericUI_Element_Texture", self.Root)
        local bottom = self:CreateElement("Bottom", "GenericUI_Element_Texture", self.Root)
        local bottomRight = self:CreateElement("BottomRight", "GenericUI_Element_Texture", self.Root)

        topRight:SetTexture(style.TopRight)
        topLeft:SetTexture(style.TopLeft)
        bottomLeft:SetTexture(style.BottomLeft)
        bottomRight:SetTexture(style.BottomRight)

        local leftWidth = topLeft:GetWidth()
        local rightWidth = topRight:GetWidth()
        local centerWidth = math.max(0, self._Size[1] - leftWidth - rightWidth)
        local topLeftHeight = topLeft:GetHeight()
        local topRightHeight = topRight:GetHeight()
        local centerHeight = math.max(0, self._Size[2] - topLeftHeight - topRightHeight)

        left:SetTexture(style.Left, V(-1, centerHeight))
        center:SetTexture(style.Center, V(centerWidth, centerHeight))
        right:SetTexture(style.Right, V(-1, centerHeight))
        bottom:SetTexture(style.Bottom, V(centerWidth, -1))
        top:SetTexture(style.Top, V(centerWidth, -1))

        -- TopLeft will already be at (0, 0) by default
        top:SetPosition(leftWidth, 0)
        topRight:SetPosition(leftWidth + centerWidth, 0)
        left:SetPosition(0, topLeftHeight)
        center:SetPosition(leftWidth, topLeftHeight)
        right:SetPosition(leftWidth + centerWidth, topLeftHeight)
        bottomLeft:SetPosition(0, topLeftHeight + centerHeight)
        bottom:SetPosition(leftWidth, topLeftHeight + centerHeight)
        bottomRight:SetPosition(leftWidth + centerWidth, topLeftHeight + centerHeight)
    elseif style.Type == "3-Sliced Horizontal" then
        ---@cast style GenericUI.Prefabs.SlicedTexture.Style.3SlicedHorizontal
        local left = self:CreateElement("Left", "GenericUI_Element_Texture", self.Root)
        local center = self:CreateElement("Center", "GenericUI_Element_Texture", self.Root)
        local right = self:CreateElement("Right", "GenericUI_Element_Texture", self.Root)

        left:SetTexture(style.Left, V(-1, self._Size[2]))
        right:SetTexture(style.Right, V(-1, self._Size[2]))

        local leftWidth = left:GetWidth()
        local rightWidth = right:GetWidth()
        local centerWidth = math.max(0, self._Size[1] - leftWidth - rightWidth)

        center:SetTexture(style.Center, V(centerWidth, self._Size[2]))

        -- Left will already be at (0, 0) by default
        center:SetPosition(leftWidth, 0)
        right:SetPosition(leftWidth + centerWidth, 0)
    elseif style.Type == "3-Sliced Vertical" then
        ---@cast style GenericUI.Prefabs.SlicedTexture.Style.3SlicedVertical
        local top = self:CreateElement("Top", "GenericUI_Element_Texture", self.Root)
        local center = self:CreateElement("Center", "GenericUI_Element_Texture", self.Root)
        local bottom = self:CreateElement("Bottom", "GenericUI_Element_Texture", self.Root)

        top:SetTexture(style.Top, V(self._Size[1], -1))
        bottom:SetTexture(style.Bottom, V(self._Size[1], -1))

        local topHeight = top:GetHeight()
        local bottomHeight = bottom:GetHeight()
        local centerHeight = math.max(0, self._Size[2] - topHeight - bottomHeight)

        center:SetTexture(style.Center, V(self._Size[1], centerHeight))

        -- Top will already be at (0, 0) by default
        center:SetPosition(0, topHeight)
        bottom:SetPosition(0, topHeight + centerHeight)
    else
        Generic:Error("SlicedTexture:__OnStyleChanged", "Unsupported style type", style.Type)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@override
function SlicedTexture:__OnStyleChanged()
    self:_UpdateTextures()
end