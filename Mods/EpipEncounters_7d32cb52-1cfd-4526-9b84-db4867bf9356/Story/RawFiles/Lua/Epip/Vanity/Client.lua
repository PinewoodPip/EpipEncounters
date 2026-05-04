
---@class Feature_Vanity
local Vanity = Epip.GetFeature("Feature_Vanity")

Vanity.Outfits = {}

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.Vanity.Events.CopyAppearanceRequested
---@field ItemToCopy EclItem The item whose appearance is being copied.
---@field TargetItem EclItem The item onto which the appearance is being copied.

---------------------------------------------
-- METHODS
---------------------------------------------

---Saves the client's Vanity data and preferences.
---@param path path? Defaults to `SAVE_FILENAME`.
function Vanity.SaveData(path)
    local save = {
        Version = Vanity.CURRENT_SAVE_VERSION,
    }
    path = path or Vanity.SAVE_FILENAME

    save = Vanity.Hooks.GetSaveData:Throw({SaveData = save}).SaveData

    IO.SaveFile(path, save)
end

---Loads the client's Vanity data and preferences.
---@see Features.Vanity.Events.SaveDataLoaded
---@param path path? Defaults to `SAVE_FILENAME`.
function Vanity.LoadData(path)
    path = path or Vanity.SAVE_FILENAME
    local save = IO.LoadFile(path)
    if save then
        Vanity.Events.SaveDataLoaded:Throw({SaveData = save})
    end
end

-- Request to transform an item into a template.
function Vanity.TransmogItem(item, newTemplate)
    Net.PostToServer("Features.Vanity.Transmog.NetMsgs.Transmog", {
        CharacterNetID = Client.GetCharacter().NetID,
        ItemNetID = item.NetID,
        NewTemplate = newTemplate,
    })
end

---Requests an item to be reverted its original state, discarding all Vanity features applied to it.
---Will notify the server.
---@param char EclCharacter
---@param item EclItem
function Vanity.RevertAppearance(char, item)
    Net.PostToServer(Vanity.NETMSG_REVERT_APPEARANCE, {
        CharacterNetID = char.NetID,
        ItemNetID = item.NetID,
    })
    Vanity._RevertAppearance(char, item)
end

---Reverts an item to its original state, discarding all Vanity features applied to it.
---@param char EclCharacter
---@param item EclItem
function Vanity._RevertAppearance(char, item)
    Vanity.Events.ItemAppearanceReset:Throw({
        Character = char,
        Item = item,
    })
end

---Requests the appearance of an item to be copied onto another one.
---@see Features.Vanity.Events.CopyAppearanceRequested
---@param targetItem EclItem
---@param itemToCopy EclItem
function Vanity.RequestCopyAppearance(targetItem, itemToCopy)
    Vanity.Events.CopyAppearanceRequested:Throw({
        TargetItem = targetItem,
        ItemToCopy = itemToCopy,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests from the server to revert item appearance.
Net.RegisterListener(Vanity.NETMSG_REVERT_APPEARANCE, function (payload)
    local char, item = payload:GetCharacter(), payload:GetItem()
    Vanity._RevertAppearance(char, item) -- Do not send a message back to the server.
end)

-- Save data on pause.
Utilities.Hooks.RegisterListener("GameState", "GamePaused", function()
    Vanity.SaveData()
end)
