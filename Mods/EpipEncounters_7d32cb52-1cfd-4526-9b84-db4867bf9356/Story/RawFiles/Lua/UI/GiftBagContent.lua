
---@meta Library: GiftBagContentUI, ContextClient

local MODS = Data.Mods

-- TODO annotation

---@class GiftBagContentUI : Feature

---@type GiftBagContentUI
local GB = {
    ID_TO_MOD = {
        [0] = MODS.GB_8AP,
        [1] = MODS.GB_CAT,
        [2] = MODS.GB_HERBS,
        [3] = MODS.GB_REST_SOURCE,
        [4] = MODS.GB_RESTSURRECT,
        [5] = MODS.GB_PETPAL,
        [6] = MODS.GB_BARTER,
        [7] = MODS.GB_RANDOMIZER,
        [8] = MODS.GB_CRAFTING,
        [9] = MODS.GB_TALENTS,
        [10] = MODS.GB_SPIRIT_VISION,
        [11] = MODS.GB_RESPEC,
        [12] = MODS.GB_ORGANIZATION,
        [13] = MODS.GB_SUMMONING,
        [14] = MODS.GB_LEVELUP_ITEMS,
        [15] = MODS.GB_SPRINT,
    },
    Events = {
        ---@type GiftBagContentUI_Event_ContentUpdated
        ContentUpdated = {},
    },
    Hooks = {
        ---@type GiftBagContentUI_Hook_GetContent
        GetContent = {},
    },
}
Client.UI.GiftBagContent = GB

---Fired after the UI's content is updated, upon opening the UI.
---@class GiftBagContentUI_Event_ContentUpdated : Event
---@field RegisterListener fun(self, listener:fun(content:GiftBagContentUIEntry[]))
---@field Fire fun(self, content:GiftBagContentUIEntry[])

---Fired when the content of the UI needs to be updated.
---@class GiftBagContentUI_Hook_GetContent : Hook
---@field RegisterHook fun(self, handler:fun(content:GiftBagContentUIEntry[]))
---@field Return fun(self, content:GiftBagContentUIEntry[])

Epip.InitializeUI(Client.UI.Data.UITypes.giftBagContent, "GiftBagContent", GB)
GB:Debug()

---@class GiftBagContentUIEntry
---@field ID number ID in UI.
---@field Name string
---@field Description string
---@field Enabled boolean
---@field Locked boolean Locked giftbags cannot be toggled.
---@field Mod string GUID of giftbag mod.

---Returns a giftbag mod by its numerical ID.
---@param id number
---@return GUID
function GB.GetModGUID(id)
    return GB.ID_TO_MOD[id]
end

function GB.RenderContent()
    local root = GB:GetRoot()
    local arr = root.items_array
    ---@type GiftBagContentUIEntry[]
    local content = {}

    for i=0,#arr-1,5 do
        table.insert(content, {
            ID = arr[i],
            Name = arr[i + 1],
            Description = arr[i + 2],
            Enabled = arr[i + 3],
            Locked = arr[i + 4],
            Mod = GB.ID_TO_MOD[arr[i]],
        })
    end

    content = GB:ReturnFromHooks("GetContent", content)

    for i,entry in ipairs(content) do
        root.giftContent_mc.addItem(entry.ID, entry.Name, entry.Description, entry.Enabled, entry.Locked)
    end

    GB:DebugLog("Content updated.")
    GB.Events.ContentUpdated:Fire(content)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

GB:RegisterInvokeListener("refreshContent", function(ev)
    GB.RenderContent()
    ev:PreventAction()
end)