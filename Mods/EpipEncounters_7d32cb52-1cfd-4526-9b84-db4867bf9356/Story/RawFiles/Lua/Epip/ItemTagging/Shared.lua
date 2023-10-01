
---------------------------------------------
-- Tags items after certain events or conditions.
---------------------------------------------

---@class Features.ItemTagging : Feature
local ItemTagging = {
    KEY_USED_TAG = "PIP_ITEMTAGGING_KEYUSED",
    BOOK_READ_TAG = "PIP_ITEMTAGGING_BOOKUSED",
    USED_ITEM_HINT_COLOR = "488f1f",

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    TranslatedStrings = {
        Hint_UsedItem_Book = {
            Handle = "h47312526g9ce5g4deeg8e67gde4e20811748",
            Text = "Book read.",
            ContextDescription = "Tooltip hint for used books",
        },
        Hint_UsedItem_Key = {
            Handle = "he782b845g749cg4c62g9095g0164424ed054",
            Text = "Key used.",
            ContextDescription = "Tooltip hint for used keys",
        },
    },

    Hooks = {
        IsItemUsed = {}, ---@type Event<Features.ItemTagging.Hooks.IsItemUsed>
    },
}
Epip.RegisterFeature("ItemTagging", ItemTagging)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.ItemTagging.Hooks.IsItemUsed
---@field Item Item
---@field Used boolean Hookable. Defaults to `false`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether an item has been used for its purpose.
---@see Features.ItemTagging.Hooks.IsItemUsed
---@param item Item
---@return boolean
function ItemTagging.IsItemUsed(item)
    return ItemTagging.Hooks.IsItemUsed:Throw({
        Item = item,
        Used = false,
    }).Used
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Default implementation for IsItemUsed.
ItemTagging.Hooks.IsItemUsed:Subscribe(function (ev)
    local item = ev.Item
    ev.Used = ev.Used or item:HasTag(ItemTagging.KEY_USED_TAG) or item:HasTag(ItemTagging.BOOK_READ_TAG)
end, {StringID = "DefaultImplementation"})