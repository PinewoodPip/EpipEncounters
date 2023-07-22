
---------------------------------------------
-- Implements a settings menu tab that allows you to view and edit Input action bindings.
---------------------------------------------

local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
local CommonStrings = Text.CommonStrings
local Input = Client.Input

---@type Feature
local InputSettingsMenu = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsActionVisible = {}, ---@type Event<Features.InputSettingsMenu.Hooks.IsActionVisible>
    }
}
Epip.RegisterFeature("InputSettingsMenu", InputSettingsMenu)

---@type Feature_SettingsMenu_Tab
local tab = {
    ID = InputSettingsMenu:GetFeatureID(),
    HeaderLabel = CommonStrings.Keybinds:GetString(),
    ButtonLabel = CommonStrings.Keybinds:GetString(),
    Entries = {},
}
SettingsMenu.RegisterTab(tab)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.InputSettingsMenu.Hooks.IsActionVisible
---@field Action InputLib_Action
---@field Visible boolean Hookable. Defaults to `true`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether an action should be visible within the menu.
---@see Features.InputSettingsMenu.Hooks.IsActionVisible
---@param action InputLib_Action
---@return boolean
function InputSettingsMenu.IsActionVisible(action)
    return InputSettingsMenu.Hooks.IsActionVisible:Throw({
        Action = action,
        Visible = true,
    }).Visible
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Request all visible actions to be rendered as entries.
SettingsMenu.Hooks.GetTabEntries:Subscribe(function (ev)
    if ev.Tab == tab then
        -- Get all visible actions
        local actions = {} ---@type InputLib_Action[]
        for _,action in pairs(Input.GetActions()) do
            if InputSettingsMenu.IsActionVisible(action) then
                table.insert(actions, action)
            end
        end
        table.sort(actions, function (a, b) -- Sort by name
            return a:GetName() < b:GetName()
        end)

        -- Add an entry for each visible action
        for _,action in ipairs(actions) do
            local setting = Input.GetActionBindingSetting(action.ID)
            table.insert(ev.Entries, {Type = "Setting", Module = setting.ModTable, ID = setting:GetID()})
        end
    end
end, {Priority = 9999})