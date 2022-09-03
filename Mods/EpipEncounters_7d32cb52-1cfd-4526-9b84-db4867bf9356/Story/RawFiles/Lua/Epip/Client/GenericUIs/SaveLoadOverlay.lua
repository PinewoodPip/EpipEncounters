
local Generic = Client.UI.Generic
local SaveLoad = Client.UI.SaveLoad
local OptionsSettings = Client.UI.OptionsSettings

---@type Feature|table
local Overlay = {
    UI = nil, ---@type GenericUI_Instance

    sortingMode = "Sort_Date",
    searchTerm = nil,

    SORTING_MODES = {
        DATE = "Sort_Date",
        ALPHABETIC = "Sort_Alphabetic",
    },
    SORTING_MODES_SETTINGS = {
        "Sort_Date",
        "Sort_Alphabetic",
    },
}
Epip.AddFeature("Overlay", "Overlay", Overlay)

---------------------------------------------
-- METHODS
---------------------------------------------

function Overlay:IsEnabled()
    return OptionsSettings.GetOptionValue("EpipEncounters", "SaveLoad_Overlay") and not Client.IsUsingController()
end

function Overlay.GetSortingMode()
    return Overlay.SORTING_MODES_SETTINGS[OptionsSettings.GetOptionValue("EpipEncounters", "SaveLoad_Sorting")]
end

---@param mode "Sort_Date"|"Sort_Alphabetic"
function Overlay.SetSortingMode(mode)
    local index = table.reverseLookup(Overlay.SORTING_MODES_SETTINGS, mode)

    OptionsSettings.SetOptionValue("EpipEncounters", "SaveLoad_Sorting", index)
end

---@param entries SaveLoadUI_Entry[]
---@return SaveLoadUI_Entry[] By reference (table passed by parameter is mutated).
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

    ui:ExternalInterfaceCall("setMcSize", 723, 1010)
    ui:ExternalInterfaceCall("setPosition", "top", "screen", "top")

    -- God I hate positioning. Not very good at it just yet
    local vp = Ext.UI.GetViewportSize()
    local pos = ui:GetUI():GetPosition()
    ui:GetUI():SetPosition(pos[1] - (260), pos[2] + (360 * vp[2]//1080))
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Sort content and show overlay.
SaveLoad.Events.GetContent:Subscribe(function (e)
    if Overlay:IsEnabled() then
        local ui = Overlay.UI

        ui:GetUI():Show()
        ui:GetUI().Layer = SaveLoad:GetUI().Layer + 100
        SaveLoad:SetFlag("OF_PlayerModal1", false)

        if Overlay.searchTerm == nil then
            Overlay.UI:GetElementByID("SearchText"):SetText("Enter to search...")
            Overlay.UI:GetElementByID("SearchText"):SetSize(200, 50)
            Overlay.UI:GetElementByID("Sorting"):SelectOption(Overlay.GetSortingMode())
        end

        -- Sort and filter content
        Overlay.FilterContent(e.Entries, "Name", Overlay.searchTerm)
        Overlay.SortContent(e.Entries)
        Overlay.Position()
    end
end)

-- Hide the overlay when the save menu is closed.
Ext.Events.Tick:Subscribe(function (e)
    if Overlay.UI and Overlay.UI:IsVisible() and (not SaveLoad:Exists() or not SaveLoad:IsVisible()) then
        Overlay.UI:GetUI():Hide()
        Overlay.searchTerm = nil
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

local function SetupUI()
    local ui = Overlay.UI

    local panel = ui:CreateElement("Panel", "GenericUI_Element_TiledBackground")
    panel:SetAlpha(0)
    panel:SetPosition(0, 600)

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

    uiObject.SysPanelPosition = {0, 19}
    uiObject.SysPanelSize = {1083, 1013}
    uiObject.FlashMovieSize = {1920, 1080}
    ui:ExternalInterfaceCall("setPosition", "top", "screen", "top")
    uiObject:Hide()

    ui.Events.ViewportChanged:Subscribe(function (e)
        Overlay.Position()
    end)

    ui:Hide()
end

-- We don't use __Setup so as to allow the setting to be toggled at any time.
Ext.Events.SessionLoaded:Subscribe(function (_)
    if Client.IsUsingController() then
        Overlay:Disable()
    else
        Overlay.UI = Generic.Create("PIP_Overlay")
        SetupUI()
    end
end)