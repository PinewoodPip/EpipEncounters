
local Generic = Client.UI.Generic
local Set = DataStructures.Get("DataStructures_Set")
local V = Vector.Create

---@class Features.UILayout : Feature
local Layout = {
    RIGHT_EDGE_LEEWAY = 50, -- Amount of pixels that right overflow is "allowed" for. This exists due to some UIs such as PartyInventory having panel sizes that extend beyond the actual UI area.

    _TrackedUIs = Set.Create(), ---@type DataStructures_Set<UI>

    Settings = {},
    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h626e6a30gaf91g438aga001g799e54be1477",
            Text = "Remember panel positions",
            ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
            Handle = "h4025c1c4g6527g4b6ag8369g49c0b1949dea",
            Text = "If enabled, the positions of the following UIs will be remembered across sessions:<br>- Character Sheet<br>- Party Inventory<br>- Quick Find<br>- Quick Loot",
            ContextDescription = "Setting tooltip",
        },
    },
}
Epip.RegisterFeature("Features.UILayout", Layout)
local TSK = Layout.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Layout.Settings.Enabled = Layout:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a UI to have its position be restored across sessions.
---Should be called before `ClientReady`.
---@param ui UI
function Layout.RegisterTrackedUI(ui)
    Layout._TrackedUIs:Add(ui)

    Layout:RegisterSetting(Layout._GetPositionSettingID(ui), {
        Type = "Vector",
        Arity = 2,
        DefaultValue = V(-1, -1), -- Special value to indicate no position saved yet. TODO this technically can lead to an edgecase if a UI uses this pos
    })
end

---Returns whether a UI's position is tracked.
---@param ui UI
---@return boolean
function Layout.IsTracked(ui)
    return Layout._TrackedUIs:Contains(ui)
end

---Updates the stored position of a UI.
---@param ui UI
function Layout.UpdateStoredPosition(ui)
    local pos = V(ui:GetPosition())

    Layout:SetSettingValue(Layout._GetPositionSettingID(ui), pos)
    Layout:SaveSettings()

    Layout:DebugLog("Position saved for", ui:GetPath())
    Layout:Dump(pos)
end

---Returns the stored position for a UI.
---@param ui UI
---@return Vector2? `nil` if the UI has no position stored yet.
function Layout.GetStoredPosition(ui)
    local pos = Layout:GetSettingValue(Layout._GetPositionSettingID(ui)) ---@type Vector2
    return (pos[1] ~= -1 or pos[2] ~= -1) and pos or nil
end

---Restores the position of a UI, if the setting is enabled.
---@param ui UI
---@param sizeOverride Vector2? Override for determining the UI's bounds, used to push UIs back in-bounds if they were to overflow (ex. from lowering resolution across sessions)
function Layout.RestorePosition(ui, sizeOverride)
    if not Layout:IsEnabled() then return end
    local pos = Layout.GetStoredPosition(ui)
    if not pos then return end

    -- Determine any overflow
    local uiObj = ui:GetUI()
    local panelSize = sizeOverride or uiObj.SysPanelSize
    local uiScale = uiObj:GetUIScaleMultiplier()
    local rightEdge = math.floor(pos[1] + (panelSize[1] - uiObj.Right) * uiScale - Layout.RIGHT_EDGE_LEEWAY) -- Uses the Right property since some UIs allow some overflow, and some Generic UIs add "padding" this way to offset centering the UIs with `setPosition` UICall.
    local bottomEdge = math.floor(pos[2] + (panelSize[2] - uiObj.Top) * uiScale)
    local viewport = Client.GetViewportSize()
    local rightOverflow = rightEdge - viewport[1]
    local bottomOverflow = bottomEdge - viewport[2]

    -- Prevent overflows through right and bottom edges
    if rightOverflow > 0 then
        pos[1] = pos[1] - rightOverflow
    end
    if bottomOverflow > 0 then
        pos[2] = pos[2] - bottomOverflow
    end

    ui:SetPosition(pos)
    Layout:DebugLog("Restored position of", Layout._GetPositionSettingID(ui), pos[1], pos[2])
end

---Attempts to restore the positions of all tracked UIs, if they exist.
function Layout.RestorePositions()
    for ui in Layout._TrackedUIs:Iterator() do
        ---@cast ui UI
        if ui:Exists() then
            Layout.RestorePosition(ui)
        end
    end
end

---Returns the ID for the setting that stores the position of a UI.
---@param ui UI
---@return string
function Layout._GetPositionSettingID(ui)
    return "UIPosition_" .. ui:GetClassName()
end

---@override
function Layout:IsEnabled()
    return self:GetSettingValue(Layout.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Register tracked UIs and restore their positions when the client loads in.
GameState.Events.ClientReady:Subscribe(function (_)
    if Client.IsUsingKeyboardAndMouse() then
        Layout.RegisterTrackedUI(Client.UI.CharacterSheet)
        Layout.RegisterTrackedUI(Client.UI.PartyInventory)
    end

    if Layout:IsEnabled() then
        Layout.RestorePositions()
    end
end)

-- Update stored position after a drag.
Pointer.Events.UIDragEnded:Subscribe(function (ev)
    local ui = Generic.GetInstance(ev.UI.Type) or Client.GetUI(ev.UI)
    if ui and Layout.IsTracked(ui) then
        Layout.UpdateStoredPosition(ui)
    end
end)
