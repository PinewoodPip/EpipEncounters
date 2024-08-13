
local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local MenuClass = RadialMenus:GetClass("Features.RadialMenus.Menu")

---@class Features.RadialMenus.Menu.Hotbar : Features.RadialMenus.Menu
---@field StartingIndex integer
---@field SlotsAmount integer
local _HotbarMenu = {}
RadialMenus:RegisterClass("Features.RadialMenus.Menu.Hotbar", _HotbarMenu, {"Features.RadialMenus.Menu"})

---@class Features.RadialMenus.Menu.Hotbar.SaveData : Features.RadialMenus.Menu.SaveData
---@field StartingIndex integer
---@field SlotsAmount integer

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a hotbar row menu.
---@param name string
---@param startingIndex integer
---@param slots integer
---@return Features.RadialMenus.Menu.Hotbar
function _HotbarMenu.Create(name, startingIndex, slots)
    local instance = MenuClass.Create(_HotbarMenu, name) ---@cast instance Features.RadialMenus.Menu.Hotbar
    instance.StartingIndex = startingIndex
    instance.SlotsAmount = slots
    return instance
end

---@override
---@param saveData Features.RadialMenus.Menu.Hotbar.SaveData
---@return Features.RadialMenus.Menu.Hotbar
function _HotbarMenu:CreateFromSaveData(saveData)
    local instance = MenuClass.CreateFromSaveData(_HotbarMenu, saveData) ---@cast instance Features.RadialMenus.Menu.Hotbar
    instance.StartingIndex = saveData.StartingIndex
    instance.SlotsAmount = saveData.SlotsAmount
    return instance
end

---@override
function _HotbarMenu:GetSlots()
    local char = Client.GetCharacter() -- Hotbar menus use current active character.
    local skillBar = char.PlayerData.SkillBarItems
    local startIndex = self.StartingIndex
    local slots = {} ---@type (Features.RadialMenus.Slot.Skill|Features.RadialMenus.Slot.Item|Features.RadialMenus.Slot.Empty)[]
    for i=startIndex,math.min(startIndex+self.SlotsAmount-1, 145),1 do
        local skillBarSlot = skillBar[i]
        if skillBarSlot.Type == "Skill" then
            table.insert(slots, RadialMenus.CreateSkillSlot(skillBarSlot.SkillOrStatId))
        elseif skillBarSlot.Type == "Action" then
            local action = Stats.GetAction(skillBarSlot.SkillOrStatId)
            ---@type Features.RadialMenus.Slot.Skill
            local slot = {
                Type = "Skill",
                Name = action:GetName(), -- TODO support alt names?
                Icon = action.Icon,
                SkillID = skillBarSlot.SkillOrStatId,
            }
            table.insert(slots, slot)
        elseif skillBarSlot.Type == "Item" then
            local item = Item.Get(skillBarSlot.ItemHandle)
            table.insert(slots, RadialMenus.CreateItemSlot(item))
        else -- ItemTemplate slots are ignored (as they're unused by the game?).
            table.insert(slots, RadialMenus.CreateEmptySlot())
        end
    end
    -- Fill rest of the menu with empty slots (ex. if the starting index is near the end of the array)
    for i=#slots+1,self.SlotsAmount,1 do
        slots[i] = RadialMenus.CreateEmptySlot()
    end
    return slots
end

---@override
function _HotbarMenu:GetSaveData()
    local data = MenuClass.GetSaveData(self) ---@cast data Features.RadialMenus.Menu.Hotbar.SaveData
    data.StartingIndex = self.StartingIndex
    data.SlotsAmount = self.SlotsAmount
    return data
end

---@override
function _HotbarMenu:GetTypeName()
    return Text.CommonStrings.Hotbar
end
