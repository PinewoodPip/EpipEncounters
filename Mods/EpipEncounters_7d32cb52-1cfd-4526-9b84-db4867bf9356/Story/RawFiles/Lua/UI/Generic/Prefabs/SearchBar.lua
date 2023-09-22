
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

-- Prefab for a text search bar.
---@class GenericUI_Prefab_SearchBar : GenericUI_Prefab, GenericUI_I_Elementable
---@field Background GenericUI_Element_TiledBackground
---@field SearchText GenericUI_Prefab_Text
---@field HintLabel GenericUI_Prefab_Text
local SearchBar = {
    BACKGROUND_ALPHA = 0.2,
    DEFAULT_HINT_TEXT = Generic:RegisterTranslatedString("h42920f03g276eg49e3gbe24gee444973feef", {
        Text = "Search...",
        ContextDescription = "Search bar prefab hint label",
    }),

    Events = {
        SearchChanged = {}, ---@type Event<GenericUI_Element_Text_Event_Changed>
    },
}
Generic:RegisterClass("GenericUI_Prefab_SearchBar", SearchBar, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI_Prefab_SearchBar", SearchBar)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_SearchBar"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@param size Vector2
---@param hintLabel string? Defaults to `DEFAULT_HINT_TEXT`.
---@return GenericUI_Prefab_SearchBar
function SearchBar.Create(ui, id, parent, size, hintLabel)
    local instance = SearchBar:_Create(ui, id) ---@type GenericUI_Prefab_SearchBar

    local root = instance:CreateElement("Background", "GenericUI_Element_TiledBackground", parent)
    root:SetBackground("Black", size:unpack())
    root:SetAlpha(instance.BACKGROUND_ALPHA)

    -- Should be ordered before the interactable text.
    local hintText = TextPrefab.Create(ui, instance:PrefixID("HintLabel"), root, hintLabel or instance.DEFAULT_HINT_TEXT:GetString(), "Left", size)

    local searchText = TextPrefab.Create(ui, instance:PrefixID("SearchText"), root, "", "Left", size)
    searchText:SetEditable(true)

    -- Hide hint text upon search bar focus
    searchText.Events.Focused:Subscribe(function (_)
        hintText:SetVisible(false)
    end)

    -- Forward text events
    searchText.Events.TextEdited:Subscribe(function (ev)
        instance.Events.SearchChanged:Throw(ev)
    end)

    instance.Background = root
    instance.SearchText = searchText
    instance.HintLabel = hintText

    return instance
end

---Clears the search term and re-sets the hint label.
function SearchBar:Reset()
    self.HintLabel:SetVisible(true)
    self.SearchText:SetText("")
end

---@override
function SearchBar:GetRootElement()
    return self.Background
end
