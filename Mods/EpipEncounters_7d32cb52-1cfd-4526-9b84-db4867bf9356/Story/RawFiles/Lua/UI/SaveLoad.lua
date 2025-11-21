
---------------------------------------------
-- APIs for the saveLoad.swf UI.
---------------------------------------------

local Flash = Client.Flash
local ParseFlashArray, EncodeFlashArray = Flash.ParseArray, Flash.EncodeArray

---@class SaveLoadUI : UI
local SaveLoad = {
    _PreviousSaves = {}, ---@type UI.SaveLoad.Entries.Save[]
    _PreviousCloudIcons = {}, ---@type UI.SaveLoad.Entries.CloudIcon[]

    FLASH_ENTRY_TEMPLATES = {
        SAVE = {
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
                },
            },
            {
                Name = "Difficulty",
                Enum = {
                    [0] = "Story",
                    [1] = "Explorer",
                    [2] = "Classic",
                    [3] = "Tactician",
                    [4] = "Honour",
                },
            },
        },
        CLOUD_ICON = {
            "Num1",
            "Num2",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    CLOUD_STATES = { -- Names need confirming! TODO
        DISABLED = 0,
        UPLOADED = 1,
        UPLOADING = 2,
        UNUPLOADED = 3,
    },
    ---@type table<UI.SaveLoad.Difficulty, integer>
    DIFFICULTIES = {
        STORY = 0,
        EXPLORER = 1,
        CLASSIC = 2,
        TACTICIAN = 3,
        HONOUR = 4,
    },

    Hooks = {
        GetContent = {}, ---@type Event<UI.SaveLoad.Hooks.GetContent>
    },
}
Epip.InitializeUI(39, "SaveLoad", SaveLoad)
SaveLoad:Debug()

---@alias UI.SaveLoad.CloudState "Disabled"|"Uploaded"|"Uploading"|"Unuploaded"
---@alias UI.SaveLoad.Difficulty "Story"|"Explorer"|"Classic"|"Tactician"|"Honour"

---@class UI.SaveLoad.Entries.Save
---@field IsSave boolean
---@field ID number
---@field Name string
---@field Enabled boolean
---@field DateTimeString string
---@field IngameTime string Date and time, of the day/night 'system'.
---@field SaveVersion string
---@field GameVersion string
---@field Message string Purpose unknown.
---@field CloudState UI.SaveLoad.CloudState
---@field Difficulty UI.SaveLoad.Difficulty

---@class UI.SaveLoad.Entries.CloudIcon
---@field SaveID integer
---@field IconID integer

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class UI.SaveLoad.Hooks.GetContent
---@field Saves UI.SaveLoad.Entries.Save[]
---@field CloudIcons UI.SaveLoad.Entries.CloudIcon[]

---------------------------------------------
-- METHODS
---------------------------------------------

---Renders content onto the UI.
---If no entries are passed, the previous content is re-rendered;
---useful for reordering entries through the GetContent hook.
---@see UI.SaveLoad.Hooks.GetContent
---@param saves UI.SaveLoad.Entries.Save[]?
---@param cloudIcons UI.SaveLoad.Entries.CloudIcon[]?
---@param isFromEngine boolean?
function SaveLoad.RenderContent(saves, cloudIcons, isFromEngine)
    local root = SaveLoad:GetRoot()
    if not saves then saves = SaveLoad._PreviousSaves end
    if not cloudIcons then cloudIcons = SaveLoad._PreviousCloudIcons end
    saves = table.deepCopy(saves) -- TODO why was this necessary?
    cloudIcons = table.deepCopy(cloudIcons)

    SaveLoad.Hooks.GetContent:Throw({
        Saves = saves,
        CloudIcons = cloudIcons,
    })

    EncodeFlashArray(root.entry_array, SaveLoad.FLASH_ENTRY_TEMPLATES.SAVE, saves)
    EncodeFlashArray(root.cloudIcon_array, SaveLoad.FLASH_ENTRY_TEMPLATES.CLOUD_ICON, cloudIcons)

    if not isFromEngine then
        root.removeItems()
        root.updateArraySystem()
    end

    SaveLoad:DebugLog("Content updated.")
end

---Returns whether the UI is in "Load Save" mode.
---**Inaccurate while the UI is being setup.**
---@return boolean? -- `nil` if the UI is not visible.
function SaveLoad.IsLoadUI()
    return SaveLoad:IsVisible() and SaveLoad:GetRoot().loadSave_mc.newSaveButton_mc.visible or nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Hook entry updates.
SaveLoad:RegisterInvokeListener("updateArraySystem", function(ev)
    local root = ev.UI:GetRoot()

    ---@type UI.SaveLoad.Entries.Save[]
    local entries = ParseFlashArray(root.entry_array, SaveLoad.FLASH_ENTRY_TEMPLATES.SAVE)
    SaveLoad._PreviousSaves = entries

    ---@type UI.SaveLoad.Entries.CloudIcon[]
    local cloudIcons = ParseFlashArray(root.cloudIcon_array, SaveLoad.FLASH_ENTRY_TEMPLATES.CLOUD_ICON)
    SaveLoad._PreviousCloudIcons = cloudIcons

    SaveLoad.RenderContent(entries, cloudIcons, true)
end)
