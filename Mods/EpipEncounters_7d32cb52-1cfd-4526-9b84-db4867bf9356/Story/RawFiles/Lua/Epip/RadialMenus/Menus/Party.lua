
---------------------------------------------
-- Radial menu that displays the party members and allows switching the active character.
---------------------------------------------

local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local MenuClass = RadialMenus:GetClass("Features.RadialMenus.Menu")

---@class Features.RadialMenus.Menu.Party : Features.RadialMenus.Menu
local PartyMenu = {}
RadialMenus:RegisterClass("Features.RadialMenus.Menu.Party", PartyMenu, {"Features.RadialMenus.Menu"})

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a Party menu.
---@param name string
---@return Features.RadialMenus.Menu.Party
function PartyMenu.Create(name)
    local instance = MenuClass.Create(PartyMenu, name) ---@cast instance Features.RadialMenus.Menu.Party
    return instance
end

---@override
---@param saveData Features.RadialMenus.Menu.SaveData
---@return Features.RadialMenus.Menu.Party
function PartyMenu:CreateFromSaveData(saveData)
    local instance = MenuClass.CreateFromSaveData(PartyMenu, saveData) ---@cast instance Features.RadialMenus.Menu.Party
    return instance
end

---@override
function PartyMenu:GetSlots()
    local chars = Character.GetPartyMembers(Client.GetCharacter())
    local slots = {} ---@type Features.RadialMenus.Slot.PartyMember[]
    for _,char in ipairs(chars) do
        ---@type Features.RadialMenus.Slot.PartyMember
        local slot = {
            Type = "PartyMember",
            CharacterHandle = char.Handle,
        }
        table.insert(slots, slot)
    end
    return slots
end

---@override
function PartyMenu:GetSaveData()
    local data = MenuClass.GetSaveData(self) ---@cast data Features.RadialMenus.Menu.SaveData
    return data -- Needs no additional data.
end

---@override
function PartyMenu:GetTypeName()
    return Text.CommonStrings.PartyMembers
end
