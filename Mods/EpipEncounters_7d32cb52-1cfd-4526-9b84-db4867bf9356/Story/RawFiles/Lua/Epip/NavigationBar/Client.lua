
local Generic = Client.UI.Generic
local SlicedTexture = Generic.GetPrefab("GenericUI.Prefabs.SlicedTexture")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local XboxControllerTextures = Textures.INPUT.CONTROLLER.XBOX
local PlaystationControllerTextures = Textures.INPUT.CONTROLLER.PLAYSTATION
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Input = Client.Input
local V = Vector.Create

---@class Features.NavigationBar : Feature
local Navbar = {
    INPUTEVENT_TO_TEXTURE = {
        ---@type table<InputRawType, TextureLib_Texture>
        XBOX = {
            ["start"] = XboxControllerTextures.START,
            ["guide"] = XboxControllerTextures.SELECT,

            ["controller_a"] = XboxControllerTextures.A_BUTTON,
            ["controller_b"] = XboxControllerTextures.B_BUTTON,
            ["controller_x"] = XboxControllerTextures.X_BUTTON,
            ["controller_y"] = XboxControllerTextures.Y_BUTTON,

            ["leftshoulder"] = XboxControllerTextures.LEFT_BUTTON,
            ["rightshoulder"] = XboxControllerTextures.RIGHT_BUTTON,
            ["lefttrigger"] = XboxControllerTextures.LEFT_TRIGGER,
            ["righttrigger"] = XboxControllerTextures.RIGHT_TRIGGER,

            ["leftstick"] = XboxControllerTextures.LEFT_STICK.PRESS,
            ["leftstick_xneg"] = XboxControllerTextures.LEFT_STICK.LEFT,
            ["leftstick_ypos"] = XboxControllerTextures.LEFT_STICK.UP,
            ["leftstick_xpos"] = XboxControllerTextures.LEFT_STICK.RIGHT,
            ["leftstick_yneg"] = XboxControllerTextures.LEFT_STICK.DOWN,

            ["rightstick"] = XboxControllerTextures.RIGHT_STICK.PRESS,
            ["rightstick_xneg"] = XboxControllerTextures.RIGHT_STICK.LEFT,
            ["rightstick_ypos"] = XboxControllerTextures.RIGHT_STICK.UP,
            ["rightstick_xpos"] = XboxControllerTextures.RIGHT_STICK.RIGHT,
            ["rightstick_yneg"] = XboxControllerTextures.RIGHT_STICK.DOWN,

            ["dpad_up"] = XboxControllerTextures.DPAD.LEFT,
            ["dpad_down"] = XboxControllerTextures.DPAD.UP,
            ["dpad_left"] = XboxControllerTextures.DPAD.RIGHT,
            ["dpad_right"] = XboxControllerTextures.DPAD.DOWN,
        },
        ---@type table<InputRawType, TextureLib_Texture>
        PLAYSTATION = {
            ["start"] = PlaystationControllerTextures.START,
            ["guide"] = PlaystationControllerTextures.SELECT,

            ["controller_a"] = PlaystationControllerTextures.A_BUTTON,
            ["controller_b"] = PlaystationControllerTextures.B_BUTTON,
            ["controller_x"] = PlaystationControllerTextures.X_BUTTON,
            ["controller_y"] = PlaystationControllerTextures.Y_BUTTON,

            ["leftshoulder"] = PlaystationControllerTextures.LEFT_BUTTON,
            ["rightshoulder"] = PlaystationControllerTextures.RIGHT_BUTTON,
            ["lefttrigger"] = PlaystationControllerTextures.LEFT_TRIGGER,
            ["righttrigger"] = PlaystationControllerTextures.RIGHT_TRIGGER,

            ["leftstick"] = PlaystationControllerTextures.LEFT_STICK.PRESS,
            ["leftstick_xneg"] = PlaystationControllerTextures.LEFT_STICK.LEFT,
            ["leftstick_ypos"] = PlaystationControllerTextures.LEFT_STICK.UP,
            ["leftstick_xpos"] = PlaystationControllerTextures.LEFT_STICK.RIGHT,
            ["leftstick_yneg"] = PlaystationControllerTextures.LEFT_STICK.DOWN,

            ["rightstick"] = PlaystationControllerTextures.RIGHT_STICK.PRESS,
            ["rightstick_xneg"] = PlaystationControllerTextures.RIGHT_STICK.LEFT,
            ["rightstick_ypos"] = PlaystationControllerTextures.RIGHT_STICK.UP,
            ["rightstick_xpos"] = PlaystationControllerTextures.RIGHT_STICK.RIGHT,
            ["rightstick_yneg"] = PlaystationControllerTextures.RIGHT_STICK.DOWN,

            ["dpad_up"] = PlaystationControllerTextures.DPAD.LEFT,
            ["dpad_down"] = PlaystationControllerTextures.DPAD.UP,
            ["dpad_left"] = PlaystationControllerTextures.DPAD.RIGHT,
            ["dpad_right"] = PlaystationControllerTextures.DPAD.DOWN,
        },
        ---@type table<InputRawType, TextureLib_Texture>
        FALLBACK = {},
    },

    -- These should be kept in-sync with keys within INPUTEVENT_TO_TEXTURE.
    _SETTING_GLYPHSTYLE_CHOICES = {
        XBOX = "XBOX",
        PLAYSTATION = "PLAYSTATION",
    },

    _UsedBindings = nil, ---@type set<InputRawType>
    _CurrentUIs = {}, ---@type set<UI>

    TranslatedStrings = {
        Setting_EnabledForKeyboard_Name = {
            Handle = "hf2b30b24ge1a7g432cgb1b4g72820964705a",
            Text = "Show keyboard Navigation Bar",
            ContextDescription = [[Setting name]],
        },
        Setting_EnabledForKeyboard_Description = {
            Handle = "h236b1865g25e1g4264ga431g97e1e853005b",
            Text = "If enabled, Epip UIs that support keyboard navigation will show a bar with the UI's keyboard controls when playing with keyboard + mouse.<br><br>Toggling this setting requires affected UIs to be closed and reopened for it to take effect.",
            ContextDescription = [[Setting tooltip for "Show keyboard Navigation Bar"]],
        },
        Setting_EnabledForController_Name = {
            Handle = "h6c98e77ag7451g4fb9g983bg1c9982916ce6",
            Text = "Show controller Navigation Bar",
            ContextDescription = [[Setting name]],
        },
        Setting_EnabledForController_Description = {
            Handle = "hdfd37c7dg00c0g4077gbe73gd2a79a31d654",
            Text = "If enabled, Epip UIs that support controller navigation will show a bar with the UI's controls when playing with a controller.<br><br>Toggling this setting requires affected UIs to be closed and reopened for it to take effect.",
            ContextDescription = [[Setting tooltip for "Show controller Navigation Bar]],
        },
        Setting_GlyphStyle_Name = {
            Handle = "h2e3a6261g5eceg4785ga00dgedb0fd8284b7",
            Text = "Controller Icons Style",
            ContextDescription = [[Setting name]],
        },
        Setting_GlyphStyle_Description = {
            Handle = "h3cc0c39cgc634g4afcg8398g3507057fbe69",
            Text = "Determines which controller icons to show on the Navigation Bar.",
            ContextDescription = [[Setting tooltip for "Controller Icons Style"]],
        },
    },
    Settings = {},
}
Epip.RegisterFeature("Features.NavigationBar", Navbar)
local TSK = Navbar.TranslatedStrings

---@class Features.NavigationBar.UI : GenericUI_Instance
local UI = Generic.Create("Features.Navbar.UI", 99)
UI.ACTION_HEIGHT = 50
UI.PADDING = 30
UI.BOTTOM_MARGIN = 50 -- In UIObject space.
UI.ACTION_SPACING = 50
UI.SUBSCRIBERID_TICK = "Features.NavigationBar." -- Suffixed with UI ID.
UI.ICON_SIZE = V(40, 40) -- Input icon size.
UI._PreviousActions = {} ---@type GenericUI.Navigation.Component.Action[]

---------------------------------------------
-- SETTINGS
---------------------------------------------

Navbar.Settings.EnabledForKeyboard = Navbar:RegisterSetting("EnabledForKeyboard", {
    Type = "Boolean",
    Name = TSK.Setting_EnabledForKeyboard_Name,
    Description = TSK.Setting_EnabledForKeyboard_Description,
    DefaultValue = false,
})
Navbar.Settings.EnabledForController = Navbar:RegisterSetting("EnabledForController", {
    Type = "Boolean",
    Name = TSK.Setting_EnabledForController_Name,
    Description = TSK.Setting_EnabledForController_Description,
    DefaultValue = true,
})
Navbar.Settings.GlyphStyle = Navbar:RegisterSetting("GlyphStyle", {
    Type = "Choice",
    Name = TSK.Setting_GlyphStyle_Name,
    Description = TSK.Setting_GlyphStyle_Description,
    DefaultValue = Navbar._SETTING_GLYPHSTYLE_CHOICES.XBOX,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = Navbar._SETTING_GLYPHSTYLE_CHOICES.XBOX, Name = "Xbox"}, -- It should not be necessary to translate these.
        {ID = Navbar._SETTING_GLYPHSTYLE_CHOICES.PLAYSTATION, Name = "Playstation"}, -- It should not be necessary to translate these.
    }
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Shows the bar for a UI, if it is enabled by the user.
---@param ui GenericUI.Navigation.UI
---@param positionOffset Vector2?
---@return boolean -- Whether the navigation bar was opened. Ex. it might've not if disabled by user settings.
function Navbar.Setup(ui, positionOffset)
    local setting = Client.IsUsingController() and Navbar.Settings.EnabledForController or Navbar.Settings.EnabledForKeyboard
    if setting:GetValue() == false then return false end

    positionOffset = positionOffset or Vector.zero2
    if not ui.___NavigationController then
        Navbar:__Error("Setup", "UI must have a navigation controller")
    end
    UI._PositionOffset = positionOffset
    UI._Initialize()

    Navbar._CurrentUIs[ui] = true

    -- Hide the bar when the target UI becomes hidden.
    local subscriberID = UI.SUBSCRIBERID_TICK .. ui:GetID()
    GameState.Events.Tick:Subscribe(function (_)
        if not ui:IsVisible() then
            Navbar._CurrentUIs[ui] = nil
            if not next(Navbar._CurrentUIs) then -- Only hide the navbar if all UIs were closed.
                UI:Hide()
            end
            GameState.Events.Tick:Unsubscribe(subscriberID)
        else
            Navbar.UpdateActions(ui)
        end
    end, {StringID = subscriberID})

    UI:Show()

    return true
end

---Updates the actions shown.
---@param ui GenericUI.Navigation.UI Must be the current active UI.
function Navbar.UpdateActions(ui)
    if ui ~= Navbar.GetCurrentUI() then return end -- Can only update the current UI.
    local list = UI.ActionList
    local actions = ui.___NavigationController:GetCurrentActions()

    if Navbar._ActionListsAreDifferent(actions, UI._PreviousActions) then
        UI._UsedBindings = {}
        list:Clear()

        for _,action in ipairs(actions) do
            UI._RenderAction(action)
        end

        list:RepositionElements()

        list:SetPositionRelativeToParent("Center")

        local bg = UI.Background
        local uiObj = UI:GetUI()
        uiObj.SysPanelSize = bg:GetSize() * uiObj:GetUIScaleMultiplier() + V(0, UI.BOTTOM_MARGIN)
        UI:SetPositionRelativeToViewport("bottom", "bottom", "screen")
        UI:Move(UI._PositionOffset)

        UI._PreviousActions = actions
    end
end

---Returns the UI that the bar is currently active for, if any.
---@return UI -- The UI of the highest layer.
function Navbar.GetCurrentUI()
    local maxLayer = -1
    local topUI = nil
    for ui in pairs(Navbar._CurrentUIs) do
        local uiObj = ui:GetUI()
        if uiObj and (not topUI or uiObj.Layer > maxLayer) then
            topUI = ui
            maxLayer = uiObj.Layer
        end
    end
    return topUI
end

---Adds an action to the list.
---@param action GenericUI.Navigation.Component.Action
function UI._RenderAction(action)
    local actionName = Text.Resolve(action.Name)
    local id = "Action." .. actionName .. "." .. Text.GenerateGUID() -- There may be multiple actions with the same name.
    local list = UI.ActionList:AddChild(id, "GenericUI_Element_HorizontalList")
    list:SetCenterInLists(true)

    for inputEvent in pairs(action.Inputs) do
        local binding = Input.GetBinding(inputEvent, Client.IsUsingController() and "C" or "Key")
        if not binding or UI._UsedBindings[binding.InputID] then goto continue end -- Avoid showing bindings that are in use by an earlier, higher-priority action.
        local texture = binding and Navbar._GetIconForBinding(binding) or nil
        if texture then
            local icon = list:AddChild(id .. "_Icon", "GenericUI_Element_Texture")
            icon:SetTexture(texture)
            icon:SetCenterInLists(true)
        elseif binding then
            -- Fallback to showing just the name
            local keyCombo = binding:ToKeyCombination()
            local bindingStr = Input.StringifyBinding(keyCombo)
            bindingStr = string.format("[%s]", bindingStr)
            local label = TextPrefab.Create(UI, id .. "_IconLabel", list, bindingStr, "Center", V(1, UI.ACTION_HEIGHT))
            label:FitSize()
            label:SetCenterInLists(true)
        end
        UI._UsedBindings[binding.InputID] = true
        ::continue::
    end

    -- Label for the action's name
    local label = TextPrefab.Create(UI, id .. "_Label", list, actionName, "Center", V(1, UI.ACTION_HEIGHT))
    label:FitSize()
    label:SetCenterInLists(true)

    list:RepositionElements()
end

---Initializes the UI's static elements.
function UI._Initialize()
    if UI._Initialized then return end

    local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
    local bg = SlicedTexture.Create(UI, "Background", root, SlicedTexture:GetStyle("SimpleTooltip"), V(1800, UI.ACTION_HEIGHT + UI.PADDING)) -- TODO autosize
    UI.Background = bg

    local actionList = bg:AddChild("ActionList", "GenericUI_Element_HorizontalList")
    actionList:SetElementSpacing(UI.ACTION_SPACING)
    UI.ActionList = actionList

    UI._Initialized = true
end

---Returns the icon to use for a binding's raw input ID.
---@param binding InputLib_InputEventBinding
---@return TextureLib_Texture
function Navbar._GetIconForBinding(binding)
    local controllerGlyphsStyle = Navbar.Settings.GlyphStyle:GetValue()
    local textureSet = Navbar.INPUTEVENT_TO_TEXTURE[controllerGlyphsStyle]
    return textureSet[binding.InputID] or Navbar.INPUTEVENT_TO_TEXTURE.FALLBACK[binding.InputID]
end

---Returns whether 2 action lists are different.
---@param list1 GenericUI.Navigation.Component.Action[]
---@param list2 GenericUI.Navigation.Component.Action[]
---@return boolean
function Navbar._ActionListsAreDifferent(list1, list2)
    if #list1 ~= #list2 then return true end
    for i,action1 in ipairs(list1) do
        local action2 = list2[i]
        if action1.ID ~= action2.ID then
            return true
        end
    end
    return false
end
