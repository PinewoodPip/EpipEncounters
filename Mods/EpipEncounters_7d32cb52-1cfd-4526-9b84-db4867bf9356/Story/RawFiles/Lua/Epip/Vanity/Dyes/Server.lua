
local Vanity = Epip.GetFeature("Feature_Vanity")

---@class Feature_Vanity_Dyes
local Dyes = Epip.GetFeature("Feature_Vanity_Dyes")

---------------------------------------------
-- METHODS
---------------------------------------------

---Removes dyes from an item.
---**Does not request the appearance to be re-applied.**
---@param item EsvItem
function Dyes.RemoveDye(item)
    -- Clear previous dye tags
    for _,existingTag in ipairs(item:GetTags()) do
        if existingTag:match("^PIP_DYE_(%x+)_(%x+)_(%x+)$") then -- TODO extract
            Dyes:DebugLog("Removing previous color tag:", existingTag)
            Osiris.ClearTag(item, existingTag)
        end
    end
end

---Clears the dyes for an item and refreshes the character if necessary.
---@param char EsvCharacter
---@param item EsvItem
function Dyes.RevertAppearance(char, item)
    Dyes.RemoveDye(item)
    if Item.IsEquipped(char, item) then
        Vanity.TryRefreshAppearance(char, item, true)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local function hex(val, minLength)
    minLength = minLength or 0
    local valStr = string.format("%x", val)

    while string.len(valStr) < minLength do
        valStr = "0" .. valStr
    end

    return valStr:upper()
end

Net.RegisterListener("EPIPENCOUNTERS_DyeItem", function(payload)
    local item = Item.Get(payload.ItemNetID)
    local dye = payload.Dye
    local char = Character.Get(payload.CharacterNetID)
    local color1 = dye.Color1
    local color2 = dye.Color2
    local color3 = dye.Color3
    local tag = string.format("PIP_DYE_%s%s%s_%s%s%s_%s%s%s", hex(color1.Red, 2), hex(color1.Green, 2), hex(color1.Blue, 2), hex(color2.Red, 2), hex(color2.Green, 2), hex(color2.Blue, 2), hex(color3.Red, 2), hex(color3.Green, 2), hex(color3.Blue, 2))

    Dyes:DebugLog("Color tag: " .. tag)

    -- Remove previous dyes and apply the new one
    Dyes.RemoveDye(item)
    Osiris.SetTag(item, tag)

    Vanity.RefreshAppearance(char, true)
end)

-- Handle requests to remove dyes.
Net.RegisterListener(Dyes.NETMSG_REMOVE_DYE, function (payload)
    local char, item = payload:GetCharacter(), payload:GetItem()
    Dyes.RevertAppearance(char, item)
end)

-- Remove dyes when an item is reset.
Vanity.Events.ItemAppearanceReset:Subscribe(function (ev)
    local char, item = ev.Character, ev.Item
    Dyes.RevertAppearance(char, item)
end)
