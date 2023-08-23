
local Generic = Client.UI.Generic
local SaveLoad = Client.UI.SaveLoad

---@type Feature|table
local Overlay = {
    UI = nil, ---@type GenericUI_Instance
    sortingMode = "Sort_Date",
    searchTerm = nil,

    _nextAccessIsFromGameMenu = false,

    SORTING_MODES = {
        DATE = "Sort_Date",
        ALPHABETIC = "Sort_Alphabetic",
    },
    SORTING_MODES_SETTINGS = {
        "Sort_Date",
        "Sort_Alphabetic",
    },
}
Epip.RegisterFeature("SaveLoadOverlay", Overlay)

---------------------------------------------
-- METHODS
---------------------------------------------

function Overlay:IsEnabled()
    return Settings.GetSettingValue("Epip_SaveLoad", "SaveLoad_Overlay") and not Client.IsUsingController()
end

function Overlay.GetSortingMode()
    return Overlay.SORTING_MODES_SETTINGS[Settings.GetSettingValue("Epip_SaveLoad", "SaveLoad_Sorting")]
end

---@param mode "Sort_Date"|"Sort_Alphabetic"
function Overlay.SetSortingMode(mode)
    local index = table.reverseLookup(Overlay.SORTING_MODES_SETTINGS, mode)

    Settings.SetValue("Epip_SaveLoad", "SaveLoad_Sorting", index)
end

---@param entries SaveLoadUI_Entry[]
---@return SaveLoadUI_Entry[] --By reference (table passed by parameter is mutated).
function Overlay.SortContent(entries)
    local mode = Overlay.GetSortingMode()

    if mode == "Sort_Alphabetic" then
        table.sort(entries, function(a, b) return a.Name < b.Name end)
    end

    return entries
end

---@param entries SaveLoadUI_Entry[]
---@param fieldName string
---@param text string
---@return SaveLoadUI_Entry[] By reference (table passed by parameter is mutated).
function Overlay.FilterContent(entries, fieldName, text)
    if text ~= nil and text ~= "" then
        text = text:lower() -- Searching is case-insensitive - this does technically break using patterns, but oh well.

        local i = 1
        while i <= #entries do
            local entry = entries[i]
            local fieldValue = entry[fieldName]

            if not fieldValue:lower():match(text) then
                table.remove(entries, i)
                i = i - 1
            end

            i = i + 1
        end
    end

    return entries
end

function Overlay.Position()
    local ui = Overlay.UI
    local saveLoadUI = Ext.UI.GetByType(Ext.UI.TypeID.saveLoad)

    ui:SetPanelSize(saveLoadUI.SysPanelSize)
    ui:ExternalInterfaceCall("setPosition", "top", "screen", "top")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the menu being opened from GameMenu.
-- The feature currently does not work when it is opened from the
-- game over state due to issues with the modal flag and
-- msgBox UI.
Client.UI.GameMenu.Events.ButtonPressed:Subscribe(function (ev)
    if ev.NumID == Client.UI.GameMenu.BUTTON_IDS.LOAD then
        Overlay._nextAccessIsFromGameMenu = true
    end
end)

-- Sort content and show overlay.
SaveLoad.Events.GetContent:Subscribe(function (e)
    if Overlay:IsEnabled() and Overlay._nextAccessIsFromGameMenu then
        local ui = Overlay.UI

        ui:GetUI():Show()
        ui:GetUI().Layer = SaveLoad:GetUI().Layer + 100
        SaveLoad:SetFlag("OF_PlayerModal1", false)

        if Overlay.searchTerm == nil then
            local searchBox = Overlay.UI:GetElementByID("SearchText") ---@type GenericUI_Element_Text
            local sortingCombobox = Overlay.UI:GetElementByID("Sorting") ---@type GenericUI_Element_ComboBox

            searchBox:SetText("Enter to search...")
            searchBox:SetSize(200, 50)
            sortingCombobox:SelectOption(Overlay.GetSortingMode())
        end

        -- Sort and filter content
        Overlay.FilterContent(e.Entries, "Name", Overlay.searchTerm)
        Overlay.SortContent(e.Entries)
        Overlay.Position()
    end
end)

-- Hide the overlay when the save menu is closed.
Ext.Events.Tick:Subscribe(function (_)
    if Overlay.UI and Overlay.UI:IsVisible() and (not SaveLoad:Exists() or not SaveLoad:IsVisible()) then
        Overlay.UI:GetUI():Hide()
        Overlay.searchTerm = nil
        Overlay._nextAccessIsFromGameMenu = false
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

local function SetupUI()
    local ui = Overlay.UI

    local panel = ui:CreateElement("Panel", "GenericUI_Element_TiledBackground")
    panel:SetAlpha(0)
    panel:SetPosition(60, 957)

    local sorting = panel:AddChild("Sorting", "GenericUI_Element_ComboBox")
    sorting:SetOptions({
        {ID = "Sort_Date", Label = "Date"},
        {ID = "Sort_Alphabetic", Label = "Alphabetic"},
    })
    sorting:SelectOption(Overlay.GetSortingMode())
    sorting.Events.OptionSelected:Subscribe(function (e)
        Overlay.SetSortingMode(e.Option.ID)
        SaveLoad.RenderContent()
    end)
    sorting:SetOpenUpwards(true)

    local searchBar = panel:AddChild("SearchBar", "GenericUI_Element_TiledBackground")
    searchBar:SetBackground("Black", 180, 40)
    searchBar:SetAlpha(0.3)
    local searchText = searchBar:AddChild("SearchText", "GenericUI_Element_Text")
    searchText:SetEditable(true)
    searchBar:SetPosition(280, 6)
    searchText.Events.Changed:Subscribe(function (e)
        Overlay.searchTerm = e.Text
        SaveLoad.RenderContent()
    end)

    local uiObject = ui:GetUI()

    uiObject:Hide()

    Client.Events.ViewportChanged:Subscribe(function (_)
        if ui:IsVisible() then
            Overlay.Position()
        end
    end)

    ui:Hide()
end

-- We don't use __Setup so as to allow the setting to be toggled at any time.
Ext.Events.SessionLoaded:Subscribe(function (_)
    if Client.IsUsingController() then
        Overlay:SetEnabled("IsUsingController", false)
    else
        Overlay.UI = Generic.Create("PIP_Overlay")
        SetupUI()
    end
end)