
---@class SaveLoadUI : UI
local SaveLoad = {
    currentContent = {},
    currentCloudIcons = {},

    USE_LEGACY_EVENTS = false,

    CLOUD_STATES = { -- Names need confirming! TODO
        DISABLED = 0,
        UPLOADED = 1,
        UPLOADING = 2,
        UNUPLOADED = 3,
    },
    ---@type table<SaveLoadUI_Difficulty, integer>
    DIFFICULTIES = {
        STORY = 0,
        EXPLORER = 1,
        CLASSIC = 2,
        TACTICIAN = 3,
        HONOUR = 4,
    },

    Events = {
        ---@type SubscribableEvent<SaveLoadUI_Event_GetContent>
        GetContent = {},
    },
}
Epip.InitializeUI(39, "SaveLoad", SaveLoad)
Client.UI.SaveLoad = SaveLoad
SaveLoad:Debug()

---@alias SaveLoadUI_CloudState "Disabled"|"Uploaded"|"Uploading"|"Unuploaded"
---@alias SaveLoadUI_Difficulty "Story"|"Explorer"|"Classic"|"Tactician"|"Honour"

---@class SaveLoadUI_Entry
---@field IsSave boolean
---@field ID number
---@field Name string
---@field Enabled boolean
---@field DateTimeString string
---@field IngameTime string Date and time, of the day/night 'system'.
---@field SaveVersion string
---@field GameVersion string
---@field Message string Purpose unknown.
---@field CloudState SaveLoadUI_CloudState
---@field Difficulty SaveLoadUI_Difficulty

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class SaveLoadUI_Event_GetContent
---@field IsLoadUI boolean Whether the UI is being used to load saves.
---@field Entries SaveLoadUI_Entry[]

---------------------------------------------
-- METHODS
---------------------------------------------

---@param content SaveLoadUI_Entry[]?
function SaveLoad.RenderContent(content)
    local root = SaveLoad:GetRoot()
    root.removeItems()
    content = content or table.deepCopy(SaveLoad.currentContent)

    SaveLoad.Events.GetContent:Throw({
        IsLoadUI = #content > 0 and not content[1].IsSave, -- TODO edge case with no saves to load?
        Entries = content,
    })

    for _,entry in ipairs(content) do
        local fun = root.loadSave_mc.addLoad
        if entry.IsSave then
            fun = root.loadSave_mc.addSave
        end

        local cloudState = SaveLoad.CLOUD_STATES[entry.CloudState:upper()]
        local difficulty = SaveLoad.DIFFICULTIES[entry.Difficulty:upper()]

        if not cloudState or not difficulty then
            SaveLoad:LogError("Invalid CloudState or Difficulty in entry " .. entry.Name)
            return nil
        end

        fun(entry.ID, entry.Name, entry.Enabled, entry.DateTimeString, entry.IngameTime, entry.SaveVersion, entry.GameVersion, entry.Message, cloudState, difficulty)
    end

    for _,cloudIconState in ipairs(SaveLoad.currentCloudIcons) do
        root.setEntryCloudIcon(cloudIconState.Num1, cloudIconState.Num2)
    end

    SaveLoad:DebugLog("Content updated.")

    root.updateButtonAndInfo()
    root.loadSave_mc.replaceCursor()

    root.showWin()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

SaveLoad:RegisterInvokeListener("removeItems", function(ev)
    SaveLoad:DebugLog("Content cleared.")
end)

SaveLoad:RegisterInvokeListener("updateArraySystem", function(ev)
    local root = ev.UI:GetRoot()
    ev:PreventAction()

    root.hideWin()

    ---@type SaveLoadUI_Entry[]
    local entries = Client.Flash.ParseArray(root.entry_array, {
        "IsSave",
        "ID",
        "Name",
        "Enabled",
        "DateTimeString",
        "IngameTime",
        "SaveVersion",
        "GameVersion",
        "Message",
        {
            Name = "CloudState",
            Enum = {
                [0] = "Disabled",
                [1] = "Uploaded",
                [2] = "Uploading",
                [3] = "Unuploaded",
            }
        },
        {
            Name = "Difficulty",
            Enum = {
                [0] = "Story",
                [1] = "Explorer",
                [2] = "Classic",
                [3] = "Tactician",
                [4] = "Honour",
            }
        }
    })

    local cloudIcons = Client.Flash.ParseArray(root.cloudIcon_array, {
        "Num1",
        "Num2",
    })
    SaveLoad.currentCloudIcons = cloudIcons

    SaveLoad.currentContent = entries

    -- TODO support replacing the table
    Ext.OnNextTick(function()
        SaveLoad.RenderContent(entries)
    end)
end)