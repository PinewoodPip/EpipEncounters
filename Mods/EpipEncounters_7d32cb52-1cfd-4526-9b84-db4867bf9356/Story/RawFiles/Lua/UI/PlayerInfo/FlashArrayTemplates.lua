
---@class PlayerInfoUI
local PlayerInfo = Client.UI.PlayerInfo

PlayerInfo.UPDATE_INFOS_FLASH_ARRAY_TEMPLATE = {
    [0] = {
        Name = "SetSummonNextTurnText",
        Template = {
            "CharacterFlashHandle",
            "Unknown1",
        },
    },
    [1] = {
        Name = "SetEquipState",
        Template = {
            "CharacterFlashHandle",
            "State",
        },
    },
    [2] = {
        Name = "SetHealthBar",
        Template = {
            "CharacterFlashHandle",
            "Percentage",
        },
    },
    [3] = {
        Name = "SetSourcePoints",
        Template = {
            "CharacterFlashHandle",
            "Available",
            "Maximum",
        },
    },
    [4] = {
        Name = "SetArmorBar",
        Template = {
            "CharacterFlashHandle",
            "Percentage",
        },
    },
    [5] = {
        Name = "SetArmorBarColor",
        Template = {
            "CharacterFlashHandle",
            "ColorValue",
        },
    },
    [6] = {
        Name = "SetMagicArmorBar",
        Template = {
            "CharacterFlashHandle",
            "Percentage",
        },
    },
    [7] = {
        Name = "SetMagicArmorBarColor",
        Template = {
            "CharacterFlashHandle",
            "ColorValue",
        },
    },
    [8] = {
        Name = "SetDisabled",
        Template = {
            "CharacterFlashHandle",
            "Disabled",
        },
    },
    [9] = {
        Name = "SetHealthColor",
        Template = {
            "CharacterFlashHandle",
            "ColorValue",
        },
    },
    [10] = {
        Name = "SetControlled",
        Template = {
            "CharacterFlashHandle",
            "Controlled",
        },
    },
    [11] = {
        Name = "SetActionState",
        Template = {
            "CharacterFlashHandle",
            "State",
        },
    },
    [12] = {
        Name = "SetLevelUp",
        Template = {
            "CharacterFlashHandle",
            "LevelUpAnimation",
            "AttributePoints",
            "AbilityPointsPending",
            "TalentPoints",
        },
    },
    [13] = {
        Name = "SetPlayerStatus",
        Template = {
            "CharacterFlashHandle",
            "Status",
        },
    },
}

---@enum UI.PlayerInfo.Entries.SetEquipState.State
PlayerInfo.EQUIPMENT_STATES = {
    NONE = 0,
    YELLOW = 1, -- <=25% durability on an item
    ORANGE = 2, -- <=15% durability on an item
    RED = 3, -- <=5% durability on an item
    BROKEN = 4,
}

---@enum UI.PlayerInfo.Entries.SetActionState.State
PlayerInfo.ACTION_STATES = {
    NONE = 0,
    IN_COMBAT = 1,
    IN_DIALOGUE = 2,
    TRADING = 3,
    LISTENING = 4, -- Dialogue listening.
    UNUSED_COMBAT2 = 5, -- Unknown.
}

---@enum UI.PlayerInfo.Entries.SetPlayerStatus.Status
PlayerInfo.PLAYER_STATUSES = {
    INGAME = 0,
    PAUSED = 1,
    IN_VIGNETTE = 2,
    IN_OVERVIEW_MAP = 3,
    ROLLING_DICE = 4,
    VIEWING_DICE_ROLL = 5,
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class UI.PlayerInfo.Entries.Base
---@field CharacterFlashHandle FlashObjectHandle
---@field EntryTypeID "SetSummonNextTurnText"|"SetEquipState"|"SetHealthBar"|"SetSourcePoints"|"SetArmorBar"|"SetArmorBarColor"|"SetMagicArmorBar"|"SetMagicArmorBarColor"|"SetDisabled"|"SetHealthColor"|"SetControlled"|"SetActionState"|"SetLevelUp"|"SetPlayerStatus" See classes in Entries package for casting.

---@class UI.PlayerInfo.Entries.SetSummonNextTurnText : UI.PlayerInfo.Entries.Base
---@field Unknown1 string

---@class UI.PlayerInfo.Entries.SetEquipState : UI.PlayerInfo.Entries.Base
---@field State UI.PlayerInfo.Entries.SetEquipState.State

---Used for SetHealthBar, SetArmorBar, SetMagicArmorBar
---@class UI.PlayerInfo.Entries.SetBar : UI.PlayerInfo.Entries.Base
---@field Percentage number

---@class UI.PlayerInfo.Entries.SetSourcePoints : UI.PlayerInfo.Entries.Base
---@field Available integer
---@field Maximum integer

---Used for SetArmorBarColor, SetMagicArmorBarColor, SetHealthColor
---@class UI.PlayerInfo.Entries.SetBarColor : UI.PlayerInfo.Entries.Base
---@field ColorValue integer

---@class UI.PlayerInfo.Entries.SetDisabled : UI.PlayerInfo.Entries.Base
---@field Disabled boolean

---@class UI.PlayerInfo.Entries.SetControlled : UI.PlayerInfo.Entries.Base
---@field Controlled boolean

---@class UI.PlayerInfo.Entries.SetActionState : UI.PlayerInfo.Entries.Base
---@field State integer UI.PlayerInfo.Entries.SetActionState.State

---@class UI.PlayerInfo.Entries.SetLevelUp : UI.PlayerInfo.Entries.Base
---@field LevelUpAnimation boolean
---@field AttributePoints integer
---@field AbilityPointsPending boolean `true` if the character has either ability or civil points pending. The flash scripting itself compares it to a number, suggesting it previously worked differently.
---@field TalentPoints integer

---@class UI.PlayerInfo.Entries.SetPlayerStatus : UI.PlayerInfo.Entries.Base
---@field Status UI.PlayerInfo.Entries.SetPlayerStatus.Status