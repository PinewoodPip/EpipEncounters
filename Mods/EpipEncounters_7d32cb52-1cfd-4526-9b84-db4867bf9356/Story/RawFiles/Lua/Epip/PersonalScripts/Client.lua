
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
local SettingsMenuOverlay = Epip.GetFeature("Feature_SettingsMenuOverlay")
local MsgBox = Client.UI.MessageBox

---@class Features.PersonalScripts
local PersonalScripts = Epip.GetFeature("Features.PersonalScripts")
local TSK = PersonalScripts.TranslatedStrings

PersonalScripts._RenderedEntries = nil ---@type Features.PersonalScripts.Prefabs.Entry[]?
PersonalScripts._SETTINGS_TAB_BUTTONID_ADD_SCRIPT = "Features.PersonalScripts.AddScript"
PersonalScripts._MSGBOX_ADD_SCRIPT = "Features.PersonalScripts.AddScript"
---@type table<integer, ScriptContext>
PersonalScripts._MSGBOX_BUTTONID_TO_CONTEXT = {
    [1] = "Shared",
    [2] = "Client",
    [3] = "Server",
}
local SETTINGS_MENU_TABID = PersonalScripts:GetNamespace()

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an instance of a Generic prefab to configure a script.
---@param script Features.PersonalScripts.Script
---@param index integer? Script load order index.
---@return Features.PersonalScripts.Prefabs.Entry
function PersonalScripts._CreateEntryPrefab(script, index)
    -- This function is in no way intended to be used outside of the default settings tab implementation. It assumes all entries come from it and are not altered by anything else while alive.
    index = index or table.reverseLookup(PersonalScripts.GetAllScripts(), script)
    local EntryPrefab = Client.UI.Generic.GetPrefab("Features.PersonalScripts.Prefabs.Entry") -- The prefab is registered after this script loads.
    local entry = EntryPrefab.Create(SettingsMenuOverlay.UI, "PersonalScripts.Entry." .. script.Path, SettingsMenuOverlay.UI.List, script, index)
    entry:SetCenterInLists(true)

    -- Handle button presses
    entry.LoadOrderUpButton.Events.Pressed:Subscribe(function (_)
        local scripts = PersonalScripts.GetAllScripts()
        script = scripts[index]
        local prevScript = scripts[index - 1]
        if prevScript then
            scripts[index - 1], scripts[index] = script, prevScript
            PersonalScripts._RenderedEntries[index - 1]:SetScript(script, index - 1)
            PersonalScripts._RenderedEntries[index]:SetScript(prevScript, index)
            PersonalScripts.SaveConfig()
        end
    end)
    entry.LoadOrderDownButton.Events.Pressed:Subscribe(function (_)
        local scripts = PersonalScripts.GetAllScripts()
        script = scripts[index]
        local nextScript = scripts[index + 1]
        if nextScript then
            scripts[index], scripts[index + 1] = nextScript, script
            PersonalScripts._RenderedEntries[index]:SetScript(nextScript, index)
            PersonalScripts._RenderedEntries[index + 1]:SetScript(script, index + 1)
            PersonalScripts.SaveConfig()
        end
    end)
    entry.EnabledCheckbox.Events.Pressed:Subscribe(function (_)
        -- Toggle the script when the button is pressed.
        entry:GetScript().Enabled = entry.EnabledCheckbox:IsActivated()
        PersonalScripts.SaveConfig()
    end)

    PersonalScripts._RenderedEntries[index] = entry

    return entry
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Render entries in the settings menu.
SettingsMenuOverlay.Events.TabRendered:Subscribe(function (ev)
    if ev.Tab.ID == SETTINGS_MENU_TABID then
        local scripts = PersonalScripts.GetAllScripts()
        PersonalScripts._RenderedEntries = {}
        for i,script in ipairs(scripts) do
            PersonalScripts._CreateEntryPrefab(script, i)
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register settings tab.
---@type Feature_SettingsMenu_Tab
local Tab = {
    ID = SETTINGS_MENU_TABID,
    HeaderLabel = TSK.FeatureName:GetString(),
    ButtonLabel = TSK.FeatureName:GetString(),
    Entries = {
        {Type = "Label", Label = TSK.Label_Explanation:GetString()},
        {Type = "Label", Label = TSK.Label_Details:Format({
            FormatArgs = {
                {
                    Text = PersonalScripts._GetPrefixedFolderPath(),
                    Font = Text.FONTS.ITALIC,
                },
            },
        })},
        {Type = "Button", ID = PersonalScripts._SETTINGS_TAB_BUTTONID_ADD_SCRIPT, Label = TSK.Label_AddScript:GetString(), Tooltip = ""},
    },
}
SettingsMenu.RegisterTab(Tab)

-- Handle requests to add scripts.
SettingsMenu.Events.ButtonPressed:Subscribe(function (ev)
    if ev.ButtonID == PersonalScripts._SETTINGS_TAB_BUTTONID_ADD_SCRIPT then
        MsgBox.Open({
            ID = PersonalScripts._MSGBOX_ADD_SCRIPT,
            Header = TSK.Label_AddScript:GetString(),
            Message = TSK.MsgBox_AddScript_Body:GetString(),
            Type = "Input",
            Buttons = {
                {ID = 1, Text = TSK.MsgBox_AddScript_Button_Shared:GetString()},
                {ID = 2, Text = TSK.MsgBox_AddScript_Button_Client:GetString()},
                {ID = 3, Text = TSK.MsgBox_AddScript_Button_Server:GetString()},
            },
        })
    end
end)
MsgBox.RegisterMessageListener(PersonalScripts._MSGBOX_ADD_SCRIPT, MsgBox.Events.InputSubmitted, function(text, id, _)
    local pathWithoutExtension = text:gsub("^/", "")
    local unprefixedPath = pathWithoutExtension .. ".lua" -- The message box requires you to type the path without the extension, as the UI disallows periods by default.
    local fullPath = PersonalScripts.FOLDER_PATH .. "/" .. unprefixedPath
    local fullPathWithoutExtension = PersonalScripts.FOLDER_PATH .. "/" .. pathWithoutExtension
    local isFolder = Ext.IO.IsDirectory(fullPathWithoutExtension)
    local wasValidScript = false

    -- Try to load as a "script set" (Shared.lua, Client.lua & Server.lua scripts)
    if isFolder then
        ---@type {Context: ScriptContext, Path: path}[]
        local files = {
            {Context = "Shared", Path = pathWithoutExtension .. "/Shared.lua"},
            {Context = "Client", Path = pathWithoutExtension .. "/Client.lua"},
            {Context = "Server", Path = pathWithoutExtension .. "/Server.lua"},
        }
        for _,file in ipairs(files) do
            if Ext.IO.IsFile(PersonalScripts.FOLDER_PATH .. "/" .. file.Path) then
                ---@type Features.PersonalScripts.Script
                local config = {
                    Path = file.Path,
                    ModTable = "EpipEncounters",
                    Enabled = true,
                    Context = file.Context,
                    PathRoot = "user",
                }
                PersonalScripts.RegisterScript(config)
                wasValidScript = true
            end
        end
    elseif Ext.IO.IsFile(fullPath) then -- Load single script
        ---@type Features.PersonalScripts.Script
        local config = {
            Path = unprefixedPath,
            ModTable = "EpipEncounters", -- TODO? Or at least allow changing it later
            Enabled = true,
            Context = PersonalScripts._MSGBOX_BUTTONID_TO_CONTEXT[id],
            PathRoot = "user",
        }
        PersonalScripts.RegisterScript(config)
        wasValidScript = true
    end

    -- Show warning if no script was found
    if not wasValidScript then
        -- Cannot open a message box immediately from another one's handler; will softlock.
        Timer.Start(0.1, function (_)
            MsgBox.Open({
                Header = "",
                Message = TSK.MsgBox_InvalidPath_Body:Format(PersonalScripts._GetPrefixedFolderPath() .. "/" .. unprefixedPath),
            })
        end)
    end
end)

-- Refresh the tab when a new script is registered.
PersonalScripts.Events.ScriptRegistered:Subscribe(function (_)
    if SettingsMenuOverlay.UI:IsVisible() and SettingsMenu.IsTabOpen(SETTINGS_MENU_TABID) then
        SettingsMenu.SetActiveTab(SETTINGS_MENU_TABID)
    end
end)
