local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local V = Vector.Create

---@class Feature_Fishing
local Fishing = Epip.GetFeature("Feature_Fishing")
local UI = Generic.Create("Feature_Fishing_CollectionLog")
Fishing.CollectionLogUI = UI

---------------------------------------------
-- CONSTANTS
---------------------------------------------

UI.SIZE = V(600, 450)
UI.HEADER_SIZE = V(600, 50)
UI.KEYBIND = "EpipEncounters_Fishing_OpenCollectionLog"
UI.FISH_SIZE = V(64, 64)
UI.FISH_GRID_SIZE = V(500, 300)
UI.UNCAUGHT_FISH_MATERIAL = "126592b3-f4b0-4652-9fd5-a81a9619c447"
UI.UNCAUGHT_FISH_TOOLTIP = { ---@type TooltipLib_FormattedTooltip
    Elements = {
        {
            Type = "ItemName",
            Label = "???",
        },
        {
            Type = "SkillDescription",
            Label = Fishing.TSK["CollectionLog_UncaughtFish"],
        },
        {
            Type = "ItemRarity",
            Label = "???",
        },
    }
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@param id string
---@return TooltipLib_FormattedTooltip
function UI.GetFishTooltip(id)
    local fish = Fishing.GetFish(id)

    return Fishing.GetTimesCaught(fish.ID) > 0 and fish:GetTooltip() or UI.UNCAUGHT_FISH_TOOLTIP
end

function UI._SetupFishGrid()
    local grid = UI.FishGrid
    grid:ClearElements()

    local fishes = {} ---@type Feature_Fishing_Fish[]
    for _,fish in pairs(Fishing.GetFishes()) do
        table.insert(fishes, fish)
    end

    table.sortByName(fishes)

    for _,fish in ipairs(fishes) do
        local icon = grid:AddChild(fish.ID, "GenericUI_Element_IggyIcon")
        local greyedOut = Fishing.GetTimesCaught(fish.ID) == 0
        local width, height = UI.FISH_SIZE:unpack()

        icon:SetIcon(greyedOut and "unknown" or fish:GetIcon(), width, height, greyedOut and UI.UNCAUGHT_FISH_MATERIAL or nil)

        -- TODO rework Generic to use new tooltip lib
        -- icon.Tooltip = {
        --     Type = "Formatted",
        --     Data = fish:GetTooltip(),
        -- }
        icon.Events.MouseOver:Subscribe(function (_)
            Client.Tooltip.ShowCustomFormattedTooltip(UI.GetFishTooltip(fish.ID))
        end)
        icon.Events.MouseOut:Subscribe(function (_)
            Client.Tooltip.HideTooltip()
        end)
    end

    UI.RootContainer:RepositionElements()
end

---@diagnostic disable-next-line: duplicate-set-field
function UI:Show()
    UI._SetupFishGrid()

    Client.UI._BaseUITable.Show(self)
    UI:SetPositionRelativeToViewport("center", "center")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Toggle the UI when the keybind is used.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == UI.KEYBIND then
        if UI:IsVisible() then
            UI:Hide()
        else
            UI:Show()
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function UI:__Setup()
    local bg = UI:CreateElement("Background", "GenericUI_Element_TiledBackground")
    bg:SetBackground("RedPrompt", UI.SIZE:unpack())

    UI:GetUI().SysPanelSize = UI.SIZE

    local rootContainer = bg:AddChild("RootContainer", "GenericUI_Element_VerticalList")
    UI.RootContainer = rootContainer

    local filler = rootContainer:AddChild("Filler", "GenericUI_Element_Empty")
    filler:SetSizeOverride(V(0, 60))
    TextPrefab.Create(UI, "Header", rootContainer, Text.Format("Fishing Journal", {Color = Color.BLACK}), "Center", UI.HEADER_SIZE)

    local grid = rootContainer:AddChild("FishGrid", "GenericUI_Element_Grid")
    grid:SetGridSize(UI.FISH_GRID_SIZE[1] // UI.FISH_SIZE[1], -1)
    grid:SetCenterInLists(true)
    UI.FishGrid = grid

    local closeButton = bg:AddChild("CloseButton", "GenericUI_Element_Button")
    closeButton:SetType("Close")
    closeButton:SetPositionRelativeToParent("TopRight", -20, 20)

    closeButton.Events.Pressed:Subscribe(function (_)
        UI:Hide()
    end)

    UI:Hide()
end