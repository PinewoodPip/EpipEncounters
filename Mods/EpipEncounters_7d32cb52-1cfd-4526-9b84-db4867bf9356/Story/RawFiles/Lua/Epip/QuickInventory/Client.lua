
---@class Feature_QuickInventory : Feature
local QuickInventory = {
    RARITY_PRIORITY = {
        Common = 1,
        Uncommon = 2,
        Rare = 3,
        Epic = 4,
        Legendary = 5,
        Divine = 6,
        Unique = 7,
        Artifact = 8,
    },

    Settings = {},

    TranslatedStrings = {
        Header = {
           Handle = "hf196badfg6c61g4bd5g91e8g7bfbf9874cbf",
           Text = "Quick Find",
           ContextDescription = "Header for the UI",
        },
        SettingsMenuInfo = {
           Handle = "h6232b543g92dag4b65gac80g0d3f7e833f72",
           Text = "Quick Find is a UI that shows a customizable filtered view of the party inventory, opened using Ctrl+F by default.",
           ContextDescription = "Info shown in settings menu",
        },
        ItemCategory_Name = {
           Handle = "h87e9e867gfd89g458eg850fga1129b558d59",
           Text = "Item Category",
           ContextDescription = "Name for item category filter dropdown (equipment/consumable/skillbook etc.)",
        },
        ShowLearntSkills_Name = {
           Handle = "hd5a53bd8gdcaag4280ga76dg905f40bde45e",
           Text = "Show learned skills",
           ContextDescription = "Checkbox for showing learnt skillbooks",
        },
        ConsumablesCategory_Name = {
           Handle = "hb29270e7g6dc8g44c0g9391g21b25965aea6",
           Text = "Consumable Type",
           ContextDescription = "Name for consumables dropdown (for selecting potion/scroll etc.)",
        },
        ScrollsAndGrenades = {
           Handle = "hc9a05852g3523g4c85gad7cg49f293c2cd29",
           Text = "Scrolls and Grenades",
           ContextDescription = "Name for consumables dropdown option",
        },
        CloseAfterUsing_Name = {
           Handle = "h1d691e43g71beg469ag8795g8f6fdf95be62",
           Text = "Close UI after using an item",
           ContextDescription = "Setting name",
        },
        CloseAfterUsing_Description = {
           Handle = "h8de93e20gae0dg45cfg9695g478ba659f71a",
           Text = "If enabled, the UI will close after using an item.\n\nYou can hold shift while clicking an item to temporarily invert this setting.",
           ContextDescription = "Tooltip for 'close after using' setting",
        },
        Setting_CloseOnClickOutOfBounds_Name = {
           Handle = "h14aad639gb9c4g456bgb7fcg48e9cd5fef17",
           Text = "Close upon world interaction",
           ContextDescription = "Setting name",
        },
        Setting_CloseOnClickOutOfBounds_Description = {
           Handle = "h8b035113g39eag49e6gae13g9a1de5375471",
           Text = "If enabled, the UI will be closed if you click anything in the world.",
           ContextDescription = "Setting tooltip for 'Close upon world interaction'",
        },
        Setting_CulledOnly_Name = {
           Handle = "h84ec181aga466g41e0g9f8bg9af1de57d37a",
           Text = "Show Culled Only",
           ContextDescription = "Filter setting name",
        },
        Setting_ShowEquippedItems_Name = {
           Handle = "h16a45dc1g56e7g4bb0ga3f6g6f4cb7f66fae",
           Text = "Show Equipped Items",
           ContextDescription = "Filter setting name",
        },
        Setting_ShowWares_Name = {
            Handle = "hf97f3dfegd102g443cg8416ga0c854b499b8",
            Text = "Show Wares",
            ContextDescription = "Filter setting name",
        },
        Setting_ShowWares_Description = {
            Handle = "h05a441a6gbe67g46adg9053g4e553bbf229c",
            Text = "If enabled, items marked as wares will be shown.",
            ContextDescription = "Filter setting tooltip",
        },
        Setting_DynamicStat_Name = {
           Handle = "h4f83fd0cg8556g4826gb76cg82ec728bef2b",
           Text = "Stat Boost",
           ContextDescription = "Text field for filtering equipment by stat boost",
        },
        Setting_DynamicStat_Description = {
           Handle = "h54323161g125cg4289gb934g2d9fc803c92c",
           Text = "Filters items by stat boost, such as attribute or ability boosts.\nEx. 'Summoning' will show items that increase the Summoning ability. Queries need not be whole words.",
           ContextDescription = "Stat filter text field tooltip",
        },
        ContextMenuButtonLabel = {
           Handle = "h3c90f954gcf43g4f24gab42gca440c18cdda",
           Text = "Quick Swap...",
           ContextDescription = "Context menu button label",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetPartyItems = {}, ---@type Hook<Features.QuickInventory.Hooks.GetPartyItems>
        IsItemVisible = {}, ---@type Event<Feature_QuickInventory_Hook_IsItemVisible>
        SortItems = {}, ---@type Event<Feature_QuickInventory_Hook_SortItems>
    }
}
Epip.RegisterFeature("QuickInventory", QuickInventory)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Features.QuickInventory.Hooks.GetPartyItems
---@field Items EclItem[] Hookable.

---@class Feature_QuickInventory_Hook_IsItemVisible
---@field Item EclItem
---@field Visible boolean Hookable. Defaults to `true`.

---@class Feature_QuickInventory_Hook_SortItems
---@field ItemA EclItem
---@field ItemB EclItem
---@field Result boolean Hookable. Defaults to sorting by handle.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the items from the party's inventory that match the filters set by hooks.
---@see Features.QuickInventory.Hooks.GetPartyItems
---@see Feature_QuickInventory_Hook_IsItemVisible
---@return EclItem[]
function QuickInventory.GetItems()
    local char = Client.GetCharacter()
    local recursiveSearch = QuickInventory:GetSettingValue(QuickInventory.Settings.RecursiveSearch) == true or QuickInventory:GetSettingValue(QuickInventory.Settings.InContainersOnly) == true -- TODO if only InContainersOnly is set, then we should only iterate first depth level
    local allItems = QuickInventory.Hooks.GetPartyItems:Throw({
        Items = Item.GetItemsInPartyInventory(char, nil, recursiveSearch),
    }).Items
    local items = {} ---@type EclItem[]

    for _,item in ipairs(allItems) do
        local visible = QuickInventory.Hooks.IsItemVisible:Throw({
            Item = item,
            Visible = true,
        }).Visible

        if visible then
            table.insert(items, item)
        end
    end

    -- Sort items
    table.sort(items, function (itemA, itemB)
        local sortOutcome = QuickInventory.Hooks.SortItems:Throw({
            ItemA = itemA,
            ItemB = itemB,
            Result = Ext.UI.HandleToDouble(itemA.Handle) > Ext.UI.HandleToDouble(itemB.Handle),
        }).Result

        return sortOutcome
    end)

    return items
end

---Returns whether an item has any tags from a set.
---@param item EclItem
---@param tags DataStructures_Set
function QuickInventory.ItemHasRelevantTag(item, tags)
    local hasTag = false
    for tag in tags:Iterator() do
        if item:HasTag(tag) then
            hasTag = true
            break
        end
    end
    return hasTag
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Exclude items outside containers if "InContainersOnly" is enabled.
QuickInventory.Hooks.GetPartyItems:Subscribe(function (ev)
    if QuickInventory:GetSettingValue(QuickInventory.Settings.InContainersOnly) == true then
        ev.Items = table.filter(ev.Items, function (item)
            local rootInventory = Item.GetInventoryParent(item)
            return rootInventory and not Entity.IsCharacter(rootInventory)
        end)
    end
end)
