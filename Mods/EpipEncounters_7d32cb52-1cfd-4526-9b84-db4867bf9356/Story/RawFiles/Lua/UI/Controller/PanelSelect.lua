
---------------------------------------------
-- NOT CURRENTLY USED! Needs a rewrite.
---------------------------------------------

---@class UI.PanelSelect : UI
local Wheel = {
    hidden = true,
    PANELS = {},
    RENDER_ORDER = {},
    ---@type table<number, PanelSelectVanillaPanelState>
    VANILLA_PANEL_STATES = {},
    VANILLA_PANEL_IDS = {
        -- TODO
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/panelSelect_c.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/panelSelect_c.swf"
    },
}
Epip.InitializeUI(Ext.UI.TypeID.panelSelect_c, "PanelSelect", Wheel) -- TODO move to Controller namespace
Wheel:Debug()

---------------------------------------------
-- METHODS
---------------------------------------------

---@class PanelSelectFlashPanel
---@field ID number
---@field Label string

---@class PanelSelectPanel
---@field ID string
---@field Label string
---@field Icon string

---@class PanelSelectVanillaPanelState
---@field Enabled boolean
---@field Flash boolean

---@param panel PanelSelectPanel
function Wheel.RegisterPanel(panel)
    Wheel.PANELS[panel.ID] = panel
    table.insert(Wheel.RENDER_ORDER, panel.ID)

    Wheel:DebugLog("Panel registered: " .. panel.ID)

    -- TODO create it if ui is open?
end

function Wheel.RenderPanels()
    local root = Wheel:GetRoot()

    Wheel:DebugLog("Rendering wheels")

    -- root.clearPanels()
    root.list.clearElements()

    for i,id in pairs(Wheel.RENDER_ORDER) do
        local data = Wheel.PANELS[id]
        local isVisible = Wheel:ReturnFromHooks("IsPanelVisible", true, id)

        if isVisible then
            local iconName
            local icon

            root.addPanel(id, data.Label)
            root.showPanelFlash(id, Wheel:ReturnFromHooks("IsPanelFlashing", false, id))
            root.setPanelEnabled(id, Wheel:ReturnFromHooks("IsPanelEnabled", true, id))

            icon = root.list.content_array[#root.list.content_array-1].info_mc.icon_mc

            -- TODO
            -- iconName = Wheel:ReturnFromHooks("GetPanelIcon", data.Icon, id)

            -- if iconName then
            --     icon.name = "iggy_pip_panelSelect_" .. id
            --     Wheel:GetUI():SetCustomIcon("pip_panelSelect_" .. id, iconName, 64, 64)
            -- end
        end
    end

    root.list.positionElements()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Prevent the UI from being closed, as we rely on it to get stick data.
Wheel:RegisterCallListener("hideUI", function(ev)
    -- Wheel:SetFlag("OF_PlayerInput1", true)
    -- Wheel:GetRoot().visible = false
    -- Wheel.hidden = true
    Wheel.hidden = true
    -- Wheel:GetRoot().alpha = 0
    -- ev:PreventAction()
    -- if Wheel.ignoreOpen then
    --     ev:PreventAction()
    --     return nil
    -- end
    -- if ev.When == "Before" then
    --     Timer.Start("_", 1, function()
    --         Wheel.ignoreOpen = true
    --         -- Wheel:SetFlag("OF_PlayerInput1", true)
    --         Wheel:GetUI():Show()
            
    --         Wheel:GetRoot().alpha = 1

    --         Ext.OnNextTick(function()
    --             Wheel:ExternalInterfaceCall("closing")
    --             print("ignoring open")

    --             Timer.Start("ignoreopen", 1, function()
    --                 Wheel.ignoreOpen = nil
    --                 print("not ignore open")
    --             end)
    --         end)
    --     end)
    -- end
end)

Wheel:RegisterCallListener("closing", function(ev)
    if not Wheel.hidden then
        -- ev:PreventAction()
    end
end)

Wheel:RegisterCallListener("PlaySound", function(ev)
    local sound = ev.Args[1]

    -- Prevent sound played in onFrame from stick updates while the UI is supposed to be hidden.
    if Wheel.hidden then
        ev:PreventAction()
    end
end, "Before")

---@class StickAxes
---@field Horizontal number
---@field Vertical number

function Wheel.GetStickAxes()
    local root = Wheel:GetRoot()

    return {Horizontal = root.stickHAxis, Vertical = root.stickVAxis}
end

-- Ext.Events.Tick:Subscribe(function()

--     if Client.IsUsingController() then
--         Wheel:SetFlag(Client.UI._BaseUITable.UI_FLAGS.VISIBLE, true)

--         -- Wheel:GetRoot().events[0] = "IE UICancel"
        
--         -- Wheel:GetRoot().events[1] = "IE PanelSelect"
--         if Wheel.hidden then
--             Wheel:SetFlag(Client.UI._BaseUITable.UI_FLAGS.PLAYER_INPUT_1, false)
--             -- Wheel:GetRoot().events[0] = "None"
--         else
--             Wheel:SetFlag(Client.UI._BaseUITable.UI_FLAGS.PLAYER_INPUT_1, true)
--             -- Wheel:GetRoot().events[0] = "IE UICancel"
--         end
--         -- Wheel:SetFlag(Client.UI._BaseUITable.UI_FLAGS.PLAYER_INPUT_1, true)
--         -- Wheel:GetRoot().events[0] = "IE UICancel"
--         -- Wheel:GetRoot().events[0] = "None"
--         _D(Wheel.GetStickAxes())
--         -- Wheel:SetFlag(Client.UI._BaseUITable.UI_FLAGS.VISIBLE, false)
--     end
-- end)

-- Vanilla functionality
Wheel:RegisterHook("IsPanelFlashing", function(flashing, id)
    if Wheel.VANILLA_PANEL_STATES[id] then
        flashing = Wheel.VANILLA_PANEL_STATES[id].Flash
    end
    return flashing
end)

Wheel:RegisterHook("IsPanelEnabled", function(enabled, id)
    if Wheel.VANILLA_PANEL_STATES[id] then
        enabled = Wheel.VANILLA_PANEL_STATES[id].Enabled
    end
    return enabled
end)

Wheel:RegisterCallListener("openPanel", function(ev)
    if ev.When == "Before" then
        local id = ev.Args[1]

        if type(id) ~= "number" then
            -- Wheel:GetUI():ExternalInterfaceCall("openPanel", id)
            ev:PreventAction()
        end

        Wheel:FireEvent("PanelRequested", id)
    end

end)

-- Render panels on open.
Wheel:RegisterCallListener("PlaySound", function(ev)
    if ev.Args[1] == "UI_Panel_Select_R" and ev.When == "Before" and not Wheel.ignoreOpen then
        Wheel:GetRoot().alpha = 1
        Wheel.RenderPanels()
    end
end)

-- Register vanilla panels.
Wheel:RegisterInvokeListener("updatePanels", function(ev)
    local root = Wheel:GetRoot()
    local arr = root.panelArray

    ---@type PanelSelectPanel[]
    local content = {}

    for i=0,#arr-1,2 do
        local panel = {
            ID = arr[i],
            Label = arr[i + 1],
            Icon = "unknown", -- TODO
        }

        Wheel.VANILLA_PANEL_STATES[panel.ID] = {
            Flash = false,
            Enabled = true,
        }

        Wheel.RegisterPanel(panel)
    end

    ev:PreventAction()
end)

-- Track vanilla panel enables/disables.
Wheel:RegisterInvokeListener("updatePanelStates", function(ev)
    local root = Wheel:GetRoot()
    local arr = root.panelStateArray

    Wheel:DebugLog("Updating vanilla panel states")

    for i=0,#arr-1,2 do
        local id = arr[i]
        local enabled = arr[i + 1]

        Wheel.VANILLA_PANEL_STATES[id].Enabled = enabled
    end

    ev:PreventAction()
end)

-- Update vanilla flashes.
Wheel:RegisterInvokeListener("showPanelFlash", function(ev)
    local id, state = ev.Args[1], ev.Args[2]

    Wheel:DebugLog("Updating vanilla panel flash for " .. id)

    Wheel.VANILLA_PANEL_STATES[id].Flash = state

    ev:PreventAction()
end)

-- Restore vanilla panel data
Ext.Events.ResetCompleted:Subscribe(function()
    local p = {
        {
            ID = 0,
            Icon = "unknown",
            Label = "Inventory",
        },
        {
            ID = 1,
            Icon = "unknown",
            Label = "Character",
        },
        {
            ID = 2,
            Icon = "unknown",
            Label = "Skills",
        },
        {
            ID = 3,
            Icon = "unknown",
            Label = "Crafting",
        },
        {
            ID = 4,
            Icon = "unknown",
            Label = "Journal",
        },
        {
            ID = 5,
            Icon = "unknown",
            Label = "Equipment",
        },
    }

    for i,panel in ipairs(p) do
        Wheel.RegisterPanel(panel)

        Wheel.VANILLA_PANEL_STATES[panel.ID] = {
            Flash = false,
            Enabled = true,
        }
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Ext.Events.SessionLoaded:Subscribe(function()
--     print("session loaded!!!")
--     local ui = Ext.UI.GetByPath("Public/Game/GUI/panelSelect_c.iggy")
--     local root = ui:GetRoot()

--     root.list.m_radius = 280

--     local list = root.list.content_array

--     local btn = list[#list-1]
--     btn.info_mc.text_txt.htmlText = "Meditate"
--     btn.showFlash(true)
--     btn.info_mc.icon_mc.gotoAndStop(3)
--     btn.setEnabled(true)

--     root.list.positionElements()

--     for i=0,120,1 do
--         local ui = Ext.UI.GetByType(i)

--         if ui then
--             print("UI Found with id " .. i .. ": " .. ui.Path)
--         end
--     end

--     print("here")



--     -- root.addPanel(10, "test")
-- end)