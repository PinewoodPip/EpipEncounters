
---------------------------------------------
-- Registers settings for Quick Inventory.
---------------------------------------------

local CommonStrings = Text.CommonStrings

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

QuickInventory.Settings.ItemCategory = QuickInventory:RegisterSetting("ItemCategory", {
    Type = "Choice",
    Name = QuickInventory.TranslatedStrings.ItemCategory_Name,
    DefaultValue = "Equipment",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Equipment", NameHandle = CommonStrings.Equipment.Handle},
        {ID = "Consumables", NameHandle = CommonStrings.Consumables.Handle},
        {ID = "Skillbooks", NameHandle = CommonStrings.Skillbooks.Handle},
    },
})

QuickInventory.Settings.ItemSlot = QuickInventory:RegisterSetting("ItemSlot", {
    Type = "Choice",
    Name = CommonStrings.ItemSlot,
    DefaultValue = "Helmet",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = CommonStrings.Any.Handle},
        {ID = "Helmet", NameHandle = CommonStrings.Helmet.Handle},
        {ID = "Breast", NameHandle = CommonStrings.Breast.Handle},
        {ID = "Leggings", NameHandle = CommonStrings.Leggings.Handle},
        {ID = "Weapon", NameHandle = CommonStrings.Weapon.Handle},
        {ID = "Shield", NameHandle = CommonStrings.Shield.Handle},
        {ID = "Ring", NameHandle = CommonStrings.Ring.Handle},
        {ID = "Boots", NameHandle = CommonStrings.Boots.Handle},
        {ID = "Belt", NameHandle = CommonStrings.Belt.Handle},
        {ID = "Amulet", NameHandle = CommonStrings.Amulet.Handle},
    },
})

QuickInventory.Settings.WeaponSubType = QuickInventory:RegisterSetting("WeaponSubType", {
    Type = "Choice",
    Name = CommonStrings.WeaponType,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = Text.CommonStrings.Any.Handle},
        {ID = "Sword", NameHandle = Text.CommonStrings.Sword.Handle},
        {ID = "Axe", NameHandle = Text.CommonStrings.Axe.Handle},
        {ID = "Club", NameHandle = Text.CommonStrings.Club.Handle},
        {ID = "Staff", NameHandle = Text.CommonStrings.Staff.Handle},
        {ID = "Knife", NameHandle = Text.CommonStrings.Knife.Handle},
        {ID = "Spear", NameHandle = Text.CommonStrings.Spear.Handle},
    },
})

QuickInventory.Settings.LearntSkillbooks = QuickInventory:RegisterSetting("LearntSkillbooks", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.ShowLearntSkills_Name,
    DefaultValue = false,
})

QuickInventory.Settings.SkillbookSchool = QuickInventory:RegisterSetting("SkillbookSchool", {
    Type = "Choice",
    Name = CommonStrings.AbilitySchool,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = { -- Ordered by appearance in skillbook UI
        {ID = "Any", NameHandle = Text.CommonStrings.Any.Handle},
        {ID = "Warrior", NameHandle = Text.CommonStrings.Warfare.Handle},
        {ID = "Ranger", NameHandle = Text.CommonStrings.Huntsman.Handle},
        {ID = "Rogue", NameHandle = Text.CommonStrings.Scoundrel.Handle},
        {ID = "Fire", NameHandle = Text.CommonStrings.Pyrokinetic.Handle},
        {ID = "Water", NameHandle = Text.CommonStrings.Hydrosophist.Handle},
        {ID = "Air", NameHandle = Text.CommonStrings.Aerotheurge.Handle},
        {ID = "Earth", NameHandle = Text.CommonStrings.Geomancer.Handle},
        {ID = "Death", NameHandle = Text.CommonStrings.Necromancer.Handle},
        {ID = "Summoning", NameHandle = Text.CommonStrings.Summoning.Handle},
        {ID = "Polymorph", NameHandle = Text.CommonStrings.Polymorph.Handle},
    },
})