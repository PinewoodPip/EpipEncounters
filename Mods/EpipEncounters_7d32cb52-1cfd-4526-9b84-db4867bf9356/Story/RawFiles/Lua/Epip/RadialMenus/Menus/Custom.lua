
local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local MenuClass = RadialMenus:GetClass("Features.RadialMenus.Menu")

---@class Features.RadialMenus.Menu.Custom : Features.RadialMenus.Menu
---@field Slots Features.RadialMenus.Slot[]
local CustomMenu = {}
RadialMenus:RegisterClass("Features.RadialMenus.Menu.Custom", CustomMenu, {"Features.RadialMenus.Menu"})

---@class Features.RadialMenus.Menu.Custom.SaveData : Features.RadialMenus.Menu.SaveData
---@field Slots Features.RadialMenus.Slot[]

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a hotbar row menu.
---@param name string
---@param slotsAmount integer
---@return Features.RadialMenus.Menu.Custom
function CustomMenu.Create(name, slotsAmount)
    local instance = MenuClass.Create(CustomMenu, name) ---@cast instance Features.RadialMenus.Menu.Custom
    instance.Slots = {}
    -- Fill slots with empty ones
    for i=1,slotsAmount,1 do
        instance.Slots[i] = table.shallowCopy(RadialMenus.EMPTY_SLOT) -- Must be copied to avoid editing the original reference
    end
    return instance
end

---@override
---@param saveData Features.RadialMenus.Menu.Custom.SaveData
---@return Features.RadialMenus.Menu.Custom
function CustomMenu:CreateFromSaveData(saveData)
    local instance = MenuClass.CreateFromSaveData(CustomMenu, saveData) ---@cast instance Features.RadialMenus.Menu.Custom
    instance.Slots = saveData.Slots
    return instance
end

---Sets a slot.
---@param index integer
---@param slot Features.RadialMenus.Slot
function CustomMenu:SetSlot(index, slot)
    if index > #self.Slots then self:__Error("SetSlot", "Index out of bounds") end
    self.Slots[index] = slot
end

---Sets the amount of slots.
---If the new amount is lower than the current one,
---excessive slots will be discarded.
---@param amount integer
function CustomMenu:SetSlotsAmount(amount)
    local currentAmount = #self.Slots
    if amount > currentAmount then -- Pad new slots with empty ones
        for i=currentAmount+1,amount,1 do
            self.Slots[i] = table.shallowCopy(RadialMenus.EMPTY_SLOT)
        end
    elseif amount < currentAmount then -- Remove excess slots
        for i=amount+1,currentAmount,1 do
            self.Slots[i] = nil
        end
    end
end

---@override
function CustomMenu:GetSlots()
    return self.Slots
end

---@override
function CustomMenu:GetSaveData()
    local data = MenuClass.GetSaveData(self) ---@cast data Features.RadialMenus.Menu.Custom.SaveData
    data.Slots = self.Slots
    return data
end

---@override
function CustomMenu:GetTypeName()
    return Text.CommonStrings.Custom
end
