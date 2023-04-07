
---------------------------------------------
-- Implements a custom UI to render character statuses,
-- as a replacement for PlayerInfo.
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo

---@class Feature_StatusesDisplay : Feature
local StatusesDisplay = {
    _Displays = {}, ---@type table<ComponentHandle, Feature_StatusesDisplay_Manager>
    TranslatedStrings = {
        Setting_Enabled_Name = {
           Handle = "hb5e67864g87f1g4493gb758g47bdab2b69aa",
           Text = "Alternative Status Display",
           ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
           Handle = "h0d296a7dgd716g475agb4c6g9b3de417c79f",
           Text = "Replaces the statuses container by your characters's portraits with a custom UI.",
           ContextDescription = "Setting tooltip",
        },
    }
}
Epip.RegisterFeature("StatusesDisplay", StatusesDisplay)

---------------------------------------------
-- SETTINGS
---------------------------------------------

StatusesDisplay:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = StatusesDisplay.TranslatedStrings.Setting_Enabled_Name,
    Description = StatusesDisplay.TranslatedStrings.Setting_Enabled_Description,
    Context = "Client",
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function StatusesDisplay:IsEnabled()
    return self:GetSettingValue("Enabled") and _Feature.IsEnabled(self)
end

---Creates a status display for a character.
---@param char EclCharacter
function StatusesDisplay.Create(char)
    if StatusesDisplay.Get(char) ~= nil then
        StatusesDisplay:Error("Create", char.DisplayName, "already has a manager")
    end
    local class = StatusesDisplay:GetClass("Feature_StatusesDisplay_Manager")
    local instance = class.Create(char)

    StatusesDisplay._Displays[char.Handle] = instance
end

---Returns the manager for a character, if any.
---@param char EclCharacter
---@return Feature_StatusesDisplay_Manager?
function StatusesDisplay.Get(char)
    return StatusesDisplay._Displays[char.Handle]
end

---Creates managers for all characters in PlayerInfo.
function StatusesDisplay._Initialize()
    -- Create managers for existing characters
    local chars = Character.GetPartyMembers(Client.GetCharacter())
    for _,char in ipairs(chars) do
        if StatusesDisplay.Get(char) == nil then
            StatusesDisplay.Create(char)
        end
    end

    -- Hide vanilla status displays.
    PlayerInfo.ToggleStatuses(false)
end

---Destroys all status managers.
function StatusesDisplay._Destroy()
    for _,manager in pairs(StatusesDisplay._Displays) do
        manager:Destroy()
    end
    StatusesDisplay._Displays = {}

    PlayerInfo.ToggleStatuses(true)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Create displays for characters being added to playerInfo UI.
PlayerInfo:RegisterInvokeListener("addInfo", function (_, handle)
    local char = Character.Get(handle, true)

    if StatusesDisplay.Get(char) == nil and StatusesDisplay:IsEnabled() then
        StatusesDisplay.Create(char)
    end
end, "After")

-- Listen for setting being toggled.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting == StatusesDisplay.Settings.Enabled then
        local enabled = ev.Value

        if enabled then
            StatusesDisplay._Initialize()
        else
            StatusesDisplay._Destroy()
        end
    end
end)

-- Create listeners on load.
GameState.Events.GameReady:Subscribe(function (_)
    if StatusesDisplay:IsEnabled() then
        StatusesDisplay._Initialize()
    end
end)