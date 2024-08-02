
local CommonStrings = Text.CommonStrings

---@class Feature_Vanity_Transmog : Feature
local Transmog = {
    NET_MSG_ICON_REMOVED = "Feature_Vanity_Transmog_NetMessage_IconOverrideRemoved",
    NET_MSG_SET_ICON = "Feature_Vanity_Transmog_NetMsg_SetIcon",
    NET_MSG_REVERT_APPEARANCE = "Features.Vanity.Transmog.NetMsgs.RevertAppearance",
    NETMSG_SET_WEAPON_ANIMATION_OVERRIDE = "Features.Vanity.Transmog.SetWeaponAnimationOverride",

    KEEP_APPEARANCE_TAG_PREFIX = "PIP_Vanity_Transmog_KeepAppearance_",
    INVISIBLE_TAG = "PIP_VANITY_INVISIBLE",
    KEEP_ICON_TAG = "PIP_VANITY_TRANSMOG_ICON_%s",
    KEEP_ICON_PATTERN = "^PIP_VANITY_TRANSMOG_ICON_(.+)$",
    TRANSMOGGED_TAG = "PIP_VANITY_TRANSMOG_TEMPLATE_%s",
    TRANSMOGGED_TAG_PATTERN = "^PIP_VANITY_TRANSMOG_TEMPLATE_(.+)$",
    WEAPON_ANIMATION_OVERRIDE_TAG = "Features.Vanity.Transmog.WeaponAnimationOverride.%s",
    WEAPON_ANIMATION_OVERRIDE_TAG_PATTERN = "^Features%.Vanity%.Transmog%.WeaponAnimationOverride%.(.+)$",

    favoritedTemplates = {}, ---@type set<GUID.ItemTemplate>
    activeCharacterTemplates = {},

    TranslatedStrings = {
        VanityTabName = {
            Handle = "h4528e43cga37bg40cdg9c6eg6b6144813c87",
            Text = "Transmog",
            ContextDescription = [[Vanity tab name]],
        },
        WeaponAnimationType_OneHanded = {
            Handle = "h411fbda4gdfe0g4fb5gb79eg3f7f99a347d7",
            Text = "One-handed",
            ContextDescription = [[Weapon animation type]],
        },
        WeaponAnimationType_TwoHanded = {
            Handle = "ha29f6a6fg7c7eg48f9g858bg2a05317ccff9",
            Text = "Two-handed",
            ContextDescription = [[Weapon animation type]],
        },
        WeaponAnimationType_Bow = {
            Handle = "hee8f9fa0ged91g48e3gb8cbg70b241a61685",
            Text = "Bow",
            ContextDescription = [[Weapon animation type]],
        },
        WeaponAnimationType_DualWielding = {
            Handle = "hcc4b1748ged00g450bg8a5ag3f884691e55a",
            Text = "Dual-wielding",
            ContextDescription = [[Weapon animation type]],
        },
        WeaponAnimationType_SmallWeapons = {
            Handle = "h4690f681g9d16g4ff4gbe5dg2b6c977843d1",
            Text = "Small Weapons",
            ContextDescription = [[Weapon animation type]],
        },
    },

    Events = {},
    Hooks = {},
}
-- Excludes NONE.
---@type Features.Vanity.Transmog.WeaponAnimationOverride[]
Transmog.WEAPON_ANIMATION_OVERRIDE_OPTIONS = {
    {
        Name = CommonStrings.OneHanded,
        AnimType = Character.WEAPON_ANIMATION_TYPES.OneHanded,
    },
    {
        Name = CommonStrings.TwoHanded,
        AnimType = Character.WEAPON_ANIMATION_TYPES.TwoHanded,
    },
    {
        Name = CommonStrings.Bow,
        AnimType = Character.WEAPON_ANIMATION_TYPES.Bow,
    },
    {
        Name = CommonStrings.DualWielding,
        AnimType = Character.WEAPON_ANIMATION_TYPES.DualWielding,
    },
    {
        Name = CommonStrings.Shield,
        AnimType = Character.WEAPON_ANIMATION_TYPES.Shield,
    },
    {
        Name = CommonStrings.SmallWeapon,
        AnimType = Character.WEAPON_ANIMATION_TYPES.SmallWeapons,
    },
    {
        Name = CommonStrings.Spear,
        AnimType = Character.WEAPON_ANIMATION_TYPES.PoleArms,
    },
    {
        Name = CommonStrings.Crossbow,
        AnimType = Character.WEAPON_ANIMATION_TYPES.CrossBow,
    },
    {
        Name = CommonStrings.TwoHandedSword,
        AnimType = Character.WEAPON_ANIMATION_TYPES.TwoHanded_Sword,
    },
    {
        Name = CommonStrings.DualWieldingSmall,
        AnimType = Character.WEAPON_ANIMATION_TYPES.DualWieldingSmall,
    },
    {
        Name = CommonStrings.Staff,
        AnimType = Character.WEAPON_ANIMATION_TYPES.Staves,
    },
    {
        Name = CommonStrings.Wand,
        AnimType = Character.WEAPON_ANIMATION_TYPES.Wands,
    },
    {
        Name = CommonStrings.DualWieldingWands,
        AnimType = Character.WEAPON_ANIMATION_TYPES.DualWieldingWands,
    },
    {
        Name = CommonStrings.WandAndShield,
        AnimType = Character.WEAPON_ANIMATION_TYPES.ShieldWands,
    },
}
Transmog._WEAPON_ANIM_TYPE_TO_OPTION_INDEX = {}
for i,v in ipairs(Transmog.WEAPON_ANIMATION_OVERRIDE_OPTIONS) do
    Transmog._WEAPON_ANIM_TYPE_TO_OPTION_INDEX[v.AnimType] = i
end
Epip.RegisterFeature("Vanity_Transmog", Transmog)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_Vanity_Transmog_NetMessage_IconOverrideRemoved : NetLib_Message_Item

---@class EPIPENCOUNTERS_Vanity_Transmog_ToggleVisibility : NetLib_Message_State, NetLib_Message_Item, NetLib_Message_Character

---@class Feature_Vanity_Transmog_NetMsg_SetIcon : NetLib_Message_Item, NetLib_Message_Character
---@field Icon icon

---@class Features.Vanity.Transmog.NetMsgs.RevertAppearance : NetLib_Message_Character, NetLib_Message_Item

---@class Features.Vanity.Transmog.SetWeaponAnimationOverride : NetLib_Message_Character
---@field AnimType CharacterLib.WeaponAnimationType

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Vanity.Transmog.SaveData : Features.Vanity.SaveData
---@field Favorites set<GUID.ItemTemplate>

---@class Features.Vanity.Transmog.WeaponAnimationOverride
---@field Name TextLib_TranslatedString
---@field AnimType CharacterLib.WeaponAnimationType

---------------------------------------------
-- METHODS
---------------------------------------------

---@param item Item
---@return string?
function Transmog.GetIconOverride(item)
    return Entity.GetParameterTagValue(item, Transmog.KEEP_ICON_PATTERN)
end

---Returns the template an item has been transmogged into, if any.
---@param item Item
---@return GUID?
function Transmog.GetTransmoggedTemplate(item)
    return Entity.GetParameterTagValue(item, Transmog.TRANSMOGGED_TAG_PATTERN)
end

---Returns whether weapon animation overrides are supported.
function Transmog._SupportsWeaponAnimationOverrides()
    return Epip.IsPipFork() and Epip.GetPipForkVersion() >= 2
end
