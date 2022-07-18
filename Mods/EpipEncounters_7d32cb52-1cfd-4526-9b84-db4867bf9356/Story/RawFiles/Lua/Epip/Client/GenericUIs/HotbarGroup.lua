
local Generic = Client.UI.Generic
local HotbarSlot = Generic.PREFABS.HotbarSlot ---@type GenericUI_Prefab_HotbarSlot

local GroupManager = {
    -- UI = Generic.Create("PIP_HotbarGroup"), ---@type GenericUI_Instance
}
Epip.AddFeature("HotbarGroupManager", "HotbarGroupManager", GroupManager)

---@class HotbarGroup
local HotbarGroup = {
    UI = nil, ---@type GenericUI_Instance
    ROWS = 12,
    COLUMNS = 28,
    SLOT_SIZE = 50,
    SLOT_SPACING = 0,
}

---@return number, number -- Width, height
function HotbarGroup:GetSlotAreaSize()
    local width = self.COLUMNS * self.SLOT_SIZE + (self.COLUMNS - 1) * self.SLOT_SPACING
    local height = self.ROWS * self.SLOT_SIZE + (self.ROWS - 1) * self.SLOT_SPACING

    return width, height
end

function HotbarGroup:_Init()
    local content = self.UI:CreateElement("ContentContainer", "TiledBackground")
    content:SetAlpha(0)
    content:SetBackground(1, self:GetSlotAreaSize())

    local container = content:AddChild("container", "VerticalList")
    container:SetElementSpacing(HotbarGroup.SLOT_SPACING - 4)

    for i=1,self.ROWS,1 do
        local row = container:AddChild("Row_" .. i, "HorizontalList")
        row:SetElementSpacing(HotbarGroup.SLOT_SPACING)

        for z=1,self.COLUMNS,1 do
            -- Prefabs can be created as wrapper APIs for working with groups of elements, simulating custom sprites
            local slot = HotbarSlot.Create(self.UI, "Row_" .. i .. "_Slot_" .. z, row)

            -- HotbarSlot extends the "Slot" element type to provide hotbar-style behaviour, automatically setting fields on its self-instanced Slot element like amount_txt, cooldown, etc.
            -- slot:SetSkill("my skill")
        end
    end

    -- local dragArea = container:AddChild("DragArea", "Button")
    -- dragArea:SetEnabled(false)
    -- dragArea:SetText(Text.Format("Click here to drag", {Color = Color.COLORS.WHITE}))
    -- dragArea:SetAsDraggableArea()

    -- local testTxt = container:AddChild("lmao", "Text")
    -- testTxt:SetText(Text.Format("lmao is this enough bars?", {
    --     Size = 30,
    --     Color = Color.COLORS.WHITE,
    -- }))
    -- testTxt:SetSize(1000, 40)

    -- local btn = container:AddChild("btn", "Button")
    -- btn:SetType(2) -- Sets the button appearance (custom buttons through Iggy textures will be supported too)
    -- btn:SetText(Text.Format("NOT ENOUGH YET", {
    --     Color = Color.COLORS.WHITE,
    -- }))

    -- -- Event listeners can be registered from the element table, including generic ones like MouseOver, MouseUp etc.
    -- btn.Events.Pressed:Subscribe(function (e)
    --     Client.UI.MessageBox.Open({
    --         Header = "Goddamnit",
    --         Message = "for some people its just never enough"
    --     })
    -- end)

    -- Direct MC access
    local mc = btn:GetMovieClip()
    btn:SetPosition(btn:GetMovieClip().x + 325, mc.y)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param id string
---@return HotbarGroup
function GroupManager.Create(id)
    local group = {} ---@type HotbarGroup
    Inherit(group, HotbarGroup)

    group.UI = Generic.Create(id)

    group:_Init()

    return group
end

Ext.Events.SessionLoaded:Subscribe(function (e)
    local group = GroupManager.Create("test")
end)