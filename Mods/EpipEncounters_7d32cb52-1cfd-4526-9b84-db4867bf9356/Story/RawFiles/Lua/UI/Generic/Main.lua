
---------------------------------------------
-- generic.swf is a custom UI made to allow the creation
-- of simple UIs directly through Lua.
---------------------------------------------

Client.UI.Generic = {
    Interfaces = {},
    ID = "PIP_Generic",
    Elements = {},

    ELEMENT_TYPES = {
        Base = true,
        Button = true,
        IggyIcon = true,
        Panel = true,
        Text = true,
    },

    INITIALIZABLE_PRIMITIVES = {
        x = true,
        y = true,
        scaleX = true,
        scaleY = true,
        width = true,
        widthOverride = true,
        heightOverride = true,
        height = true,
        alpha = true,
        mouseEnabled = true,
        mouseChildren = true,
    },
}
local Generic = Client.UI.Generic
Epip.InitializeUI(nil, "Generic", Generic)

-- Generic:Debug()

local DefaultElementParams = {
    PositionList = false,
    ClickBoxWidth = nil,
    ClickBoxHeight = nil,
    ButtonTextY = 0,
    ButtonText = "Button Text",
    Center = {},
    Textures = {},
    Scale = 1,
    Text = "",
    FontSize = 17,
    DebugHitMC = false,
    Anchor = {},
}

local Texture = {
    Icon = nil,
    Width = nil,
    Height = nil,
}

function Generic:GetUI()
    return Ext.UI.GetByName(self.ID)
end

function Generic:GetRoot()
    return Generic:GetUI():GetRoot()
end

-- Create a texture. Used for Iggy icons.
function Generic.CreateTexture(icon, width, height)
    local tex = {}
    setmetatable(tex, {__index = Texture})

    tex.Icon = icon
    tex.Width = width
    tex.Height = tex.Height or tex.Width -- Default to square

    return tex
end

function Generic.CreateInterface(stringId)
    local root = Generic:GetRoot()

    root.CreateInterface(stringId)

    local uiRoot = root[stringId]

    Generic.Interfaces[stringId] = uiRoot

    return uiRoot
end

function Generic.CloseInterface(ui)
    ui.visible = false
end

function Generic.OpenInterface(ui)
    ui.visible = true
end

function Generic.ScaleElement(element, newScale, keepCenter)
    -- newScale = element.scaleX * newScale
    local originalWidth = element.width
    local originalHeight = element.height

    -- local widthDelta = (originalWidth * newScale) - originalWidth
    -- local heightDelta = (originalHeight * newScale) - originalHeight

    element.SetScale(newScale)

    if keepCenter then
        element.x = element.x - (element.width - originalWidth)/2
        element.y = element.y - (element.height - originalHeight)/2
    end
end

function Generic.AddElement(ui, id, data)
    if not data.Type then
        Generic:LogError("Element data table must have a Type property!")
        return nil
    elseif not Generic.ELEMENT_TYPES[data.Type] then
        Generic:LogError("No such element Type: " .. data.Type)
        return nil
    end

    data = data or {}
    setmetatable(data, {__index = DefaultElementParams})

    ui.AddElement(data.Type, id, data.PositionList)

    local element = ui.elements[#ui.elements - 1]

    element.scaleX = data.Scale
    element.scaleY = data.Scale

    if data.width then
        data.widthOverride = data.width * data.Scale
    end
    if data.height then
        data.heightOverride = data.height * data.Scale
    end

    -- Set primitives
    for field,_ in pairs(Generic.INITIALIZABLE_PRIMITIVES) do
        if data[field] then -- Only set these if they were defined in the table
            element[field] = data[field]
        end
    end

    -- Clickbox
    if not data.ClickBoxWidth and data.Type == "IggyIcon" then
        data.ClickBoxWidth = data.Texture.Width
    end
    if not data.ClickBoxHeight and data.Type == "IggyIcon" then
        data.ClickBoxHeight = data.Texture.Height
    end

    if data.ClickBoxWidth and element.hit_mc then
        element.hit_mc.width = data.ClickBoxWidth
    end
    if data.ClickBoxHeight and element.hit_mc then
        element.hit_mc.height = data.ClickBoxHeight
    end

    -- Button stuff
    if data.Type == "Button" then
        if data.ButtonText ~= "" then
            -- element.EnableText()
            element.SetText(data.ButtonText)

            if data.ButtonTextY then
                element.SetTextY(data.ButtonTextY)
            end
        end
        element.text_txt.mouseEnabled = false -- TODO why doesnt this work from flash init?

        element.text_txt.width = element.hit_mc.width
        element.text_txt.height = element.hit_mc.height
    elseif data.Type == "Text" then
        element.SetFontSize(data.FontSize)
        element.SetText(data.Text)
    end

    for texture,data in pairs(data.Textures) do
        local iggyId = id .. "_" .. texture:lower()
        Generic:GetUI():SetCustomIcon(iggyId, data.Icon, data.Width, data.Height)
    end

    if data.Texture then
        local icon = data.Texture.Icon
        element.name = "iggy_" .. id -- TODO use numid
        Generic:GetUI():SetCustomIcon(id, icon, data.Texture.Width, data.Texture.Height)
    end

    -- Anchor
    for type,parent in pairs(data.Anchor) do
        if type == "Bottom" then
            element.y = parent.hit_mc.height - element.height -- TODO real height
        elseif type == "Top" then
            element.y = 0
        elseif type == "Right" then
            element.x = parent.hit_mc.width - element.hit_mc.width
        end
    end

    -- Center
    if data.Center.H then
        Generic.CenterElement(element, data.Center.H, true)
    end
    if data.Center.V then
        Generic.CenterElement(element, data.Center.V, false, true)
    end
    if data.Center.OffsetY then
        element.y = element.y + data.Center.OffsetY
    end
    if data.Center.OffsetX then
        element.x = element.x + data.Center.OffsetX
    end

    if data.Anchor.OffsetY then
        element.y = element.y + data.Anchor.OffsetY
    end
    if data.Anchor.OffsetX then
        element.x = element.x + data.Anchor.OffsetX
    end

    Generic.Elements[element.id] = {
        UI = ui.stringId,
        StringID = id,
    }

    if data.DebugHitMC then
        element.hit_mc.alpha = 1
    end

    return element
end

function Generic.CenterElement(element, parent, horizontal, vertical, addCoords)
    if not horizontal and not vertical then
        Generic:LogError("CenterElement must be passed a bool for either horizontal, vertical or both.")
    else
        local parentWidth = parent.width
        local parentHeight = parent.height
        local elementWidth = element.width
        local elementHeight = element.height

        if parent.hit_mc then
            parentWidth = parent.hit_mc.width * parent.scaleX
            parentHeight = parent.hit_mc.height * parent.scaleY
        end

        if element.hit_mc then
            elementWidth = element.hit_mc.width * element.scaleX -- Is the width not affected by parent scale???
            elementHeight = element.hit_mc.height * element.scaleX
        end

        if horizontal then
            element.x = parentWidth / 2
            element.x = element.x - (elementWidth / 2)

            if addCoords then
                element.x = element.x + parent.x
            end
        end

        if vertical then
            element.y = parentHeight / 2
            element.y = element.y - (elementHeight / 2)

            if addCoords then
                element.y = element.y + parent.y
            end
        end
    end
end

function Generic.PositionElement(element, parent, verticalPosition, horizontalPosition)
    if horizontalPosition == "right" then
        element.x = parent.width - element.width
    end

    if verticalPosition == "top" then
        element.y = parent.y
    end
end

function Generic.AddSlicedBackground(ui, id, grid)
    local backgroundWidth = #grid.Grid[1] * grid.SliceSize
    local backgroundHeight = #grid.Grid * grid.SliceSize

    local bg = Generic.AddElement(ui, id, {
        Type = "Base",
        ClickBoxWidth = backgroundWidth,
        ClickBoxHeight = backgroundHeight,
    })

    for i,row in ipairs(grid.Grid) do
        for z,texture in ipairs(row) do
            local element = Generic.AddElement(bg, id .. "_icon_" .. i .. "_" .. z, {
                Type = "IggyIcon",
                Texture = texture,
                x = (z - 1) * grid.SliceSize,
                y = (i - 1) * grid.SliceSize,
            })

            -- TODO does this cause problems? used to workaround the clipping issue
            -- ideally iggy icons should be child of the movieclip though. not set name on the mc itself!
            element.hit_mc.height = 250
            element.hit_mc.width = 250
        end
    end

    if grid.Offset then
        if grid.Offset.x then
            bg.x = bg.x - grid.Offset.x
        end
        if grid.Offset.y then
            bg.y = bg.y - grid.Offset.y
        end
    end

    return bg
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

function Generic.FireElementEvent(interfaceId, elementId, event)
    -- TODO pass element
    Generic:FireEvent(interfaceId .. "_" .. elementId .. "_" .. event)
end

function Generic.RegisterElementListener(element, event, handler)
    -- TODO type check?
    Generic:RegisterListener(element.interfaceId .. "_" .. element.stringId .. "_" .. event, handler)
end

local function OnElementHitOver(ui, method, interfaceId, numId, stringId)
    Generic:DebugLog("MouseOver: " .. stringId)
    
    Generic.FireElementEvent(interfaceId, stringId, "MouseOver")
end

local function OnElementHitOut(ui, method, interfaceId, numId, stringId)
    Generic.FireElementEvent(interfaceId, stringId, "MouseOut")
end

local function OnElementHitDown(ui, method, interfaceId, numId, stringId)
    Generic.FireElementEvent(interfaceId, stringId, "MouseDown")
end

local function OnElementHitUp(ui, method, interfaceId, numId, stringId)
    Generic.FireElementEvent(interfaceId, stringId, "MouseUp")
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function()
    local ui = Ext.UI.Create(Generic.ID, "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/generic.swf", 15)
    Generic:GetUI():ExternalInterfaceCall("setPosition","topleft","screen","topleft")
    Generic:GetUI():Show()
    Generic:GetUI():ExternalInterfaceCall("setMcSize", 1920, 1080) -- TODO

    Generic:GetRoot().examine_mc.visible = false

    -- Client.Timer.Start("t", 2.5, function()
    --     Generic.Test()
    -- end)

    Ext.RegisterUICall(Generic:GetUI(), "buttonElementClicked", function(ui, method) print("click!") end)

    Ext.RegisterUICall(Generic:GetUI(), "elementHitOver", OnElementHitOver)
    Ext.RegisterUICall(Generic:GetUI(), "elementHitOut", OnElementHitOut)
    Ext.RegisterUICall(Generic:GetUI(), "elementHitDown", OnElementHitDown)
    Ext.RegisterUICall(Generic:GetUI(), "elementHitUp", OnElementHitUp)
    Ext.RegisterUICall(Generic:GetUI(), "buttonElementClicked", function(ui, method, interfaceId, numId, stringId)
        Generic.FireElementEvent(interfaceId, stringId, "ButtonClicked")
    end)
end)

---------------------------------------------
-- TESTING
---------------------------------------------

function Generic.Test()
    local root = Generic:GetRoot()

    local ui = Generic.CreateInterface("test")

    local bg = Generic.AddSlicedBackground(ui, "background_panel", {
        Grid = {
            {{Icon = "examine_panel_top", Width = 512, Height = 512}},
            {{Icon = "examine_panel_bottom", Width = 512, Height = 512}},
        },
        Offset = {y = 100, x = -10},
        SliceSize = 512,
    })

    -- PANEL / background

    -- TODO lua wrappers to automatically keep track of stringid -> numid, as well as listeners
    -- TODO funcs to center respective to another elemen
    -- TODO lists
    -- TODO events: pressed, hovered in/out
    -- TODO lua wrapper for creating panels, elements and returning them
    -- TODO a way to center a UI onto the screen, and other anchor points
    -- TODO tween helpers: simple and loopable (might be able to just use lua for loop)
    -- TODO improve draggable to prevent moving out of screen entirely (causes issues with iggy icon)

    -- TEXT
    -- Generic.AddElement(ui, "Panel", "Asdadsd")
    local text = Generic.AddElement(bg, "testelement", {
        Type = "Text",
        Center = {Horizontal = ui, Vertical = ui}
    })

    text.SetText("test222222222")

    ui.MakeDraggable()

    -- BUTTON
    -- ui.AddElement("Button", "button")
    -- local button = ui.elements[2]
    -- button.button_mc.bg_mc.gotoAndStop(1) -- TODO why does this not work from script?
    
    -- print("Button", button.visible, button.button_mc.visible, button.button_mc.currentFrame)

    -- button.x = 50
    -- button.y = 50

    -- -- Test cool panel
    -- ui.AddElement("IggyIcon", "examine_panel_top")
    -- ui.AddElement("IggyIcon", "examine_panel_bottom")
    -- Generic:GetUI():SetCustomIcon("examine_panel_top", "examine_panel_top", 512, 512)
    -- Generic:GetUI():SetCustomIcon("examine_panel_bottom", "examine_panel_bottom", 512, 512)

    -- local top = ui.elements[4]
    -- local bottom = ui.elements[5]

    -- top.y = 0
    -- bottom.y = 512

    -- -- REMOVAL
    -- -- ui.RemoveElement("button")

    -- 
    -- -- ui.list.positionElements()
    -- ui.AddElement("Base", "testlist")
    -- local list = ui.elements[6]

    -- for i=0,5,1 do
    --     list.AddElement("Button", "b" .. i, true)

    --     local el = list.elements[i]
    --     print(el.SetText(i .. " Layout Testing!"))
    -- end

    -- LISTS
    local list = Generic.AddElement(ui, "button_list", {
        Type = "Base",
        -- Center = {Horizontal = ui},
        -- width = 256/2,
        y = 50,
    })

    for i=1,5,1 do
        local button = Generic.AddElement(list, "button_" .. i, Generic.TEMPLATES.BUTTONS.GREEN)

        button.SetText("Test Button " .. i)
    end

    -- Testing templates
    local count = 0
    for id,template in pairs(Generic.TEMPLATES.BUTTONS) do
        local el = Generic.AddElement(list, id, template)
        count = count + el.width
    end

    list.list.positionElements()
    Generic.CenterElement(list, bg, true)
end