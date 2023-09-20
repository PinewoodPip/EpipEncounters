
local Set = DataStructures.Get("DataStructures_Set")
local V = Vector.Create

---@type Feature
local Layout = {
    RIGHT_EDGE_LEEWAY = 50, -- Amount of pixels that right overflow is "allowed" for. This exists due to some UIs such as PartyInventory having panel sizes that extend beyond the actual UI area.

    _TrackedUIs = Set.Create(), ---@type DataStructures_Set<UI>

    Settings = {},
    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h626e6a30gaf91g438aga001g799e54be1477",
            Text = "Remember Panel Positions",
            ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
            Handle = "h4025c1c4g6527g4b6ag8369g49c0b1949dea",
            Text = "If enabled, the positions of the character sheet and party inventory UIs will be remembered across sessions.",
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
    local currentPosition = ui:Exists() and V(ui:GetPosition()) or nil

    Layout._TrackedUIs:Add(ui)

    -- TODO use some other identifier for Generic UIs
    Layout:RegisterSetting(Layout._GetPositionSettingID(ui), {
        Type = "Vector",
        Arity = 2,
        DefaultValue = currentPosition or Vector.Create(0, 0),
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
---@return Vector2
function Layout.GetStoredPosition(ui)
    local setting = Layout:GetSettingValue(Layout._GetPositionSettingID(ui)) ---@type Vector2
    return setting
end

---Restores the positions of tracked UIs.
---Ignores whether the feature is enabled.
function Layout.RestorePositions()
    for ui in Layout._TrackedUIs:Iterator() do
        ---@cast ui UI
        if ui:Exists() then
            local pos = Layout.GetStoredPosition(ui)
            local panelSize = ui:GetUI().SysPanelSize
            local rightEdge = pos[1] + panelSize[1] - Layout.RIGHT_EDGE_LEEWAY
            local bottomEdge = pos[2] + panelSize[2]
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
    end
end

---Returns the ID for the setting that stores the position of a UI.
---@param ui UI
---@return string
function Layout._GetPositionSettingID(ui)
    return "UIPosition_" .. ui:GetPath()
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
    Layout.RegisterTrackedUI(Client.UI.CharacterSheet)
    Layout.RegisterTrackedUI(Client.UI.PartyInventory)

    if Layout:IsEnabled() then
        Layout.RestorePositions()
    end
end)

-- Update stored position after a drag.
Pointer.Events.UIDragEnded:Subscribe(function (ev)
    local ui = Client.GetUI(ev.UI)
    if ui and Layout.IsTracked(ui) then
        Layout.UpdateStoredPosition(ui)
    end
end)