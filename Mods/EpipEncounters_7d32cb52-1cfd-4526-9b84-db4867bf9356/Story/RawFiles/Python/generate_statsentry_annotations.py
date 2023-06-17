import re, sys

MODIFIERS_PATH = sys.argv[1]

MODIFIER_TYPE_REGEX = re.compile('modifier type "(.+)"')
MODIFIER_FIELD_REGEX = re.compile('modifier "([^,]+)","([^,]+)"')

MODIFIER_FIELD_TYPE_TO_LUA = {
    "ConstantInt": "integer",
    "FixedString": "string",
    "YesNo": '"Yes"|"No"',
    "ActPart": "StatsLib_Enum_ActPart",
    "Penalty Qualifier": "StatsLib_Enum_PenaltyQualifier",
    "Penalty PreciseQualifier": "StatsLib_Enum_PenaltyPreciseQualifer",
    "Act": "1",
    "AnimType": "StatsLib_Enum_AnimType",
    "Itemslot": "ItemSlot",
    "BigQualifier": "StatsLib_Enum_BigQualifier",
    "Qualifier": "StatsLib_Enum_Qualifier",
    "Damage Type": "StatsLib_Enum_DamageType",
    "Requirements": "StatsLib_StatsEntryField_Requirements",
    "SkillAbility": "StatsLib_Enum_SkillAbility",
    "SkillRequirement": "StatsLib_Enum_SkillRequirement",
    "ArmorType": "StatsLib_Enum_ArmorType",
    "AttributeFlags": "StatsLib_Enum_AttributeFlags",
    "AttributeFlag": "StatsLib_Enum_AttributeFlags",
    "InventoryTabs": "StatsLib_Enum_InventoryTabs",
    "ModifierType": "StatsLib_Enum_ModifierType",
    "SavingThrow": "StatsLib_Enum_SavingThrow",
    "Handedness": "StatsLib_Enum_Handedness",
    "WeaponType": "StatsLib_Enum_WeaponType",
    "PreciseQualifier": "StatsLib_Enum_PreciseQualifier",
    "Death Type": "StatsLib_Enum_DeathType",
    "DamageSourceType": "StatsLib_Enum_DamageSourceType",
    "Surface Type": "StatsLib_Enum_SurfaceType",
    "AtmosphereType": "StatsLib_Enum_AtmosphereType",
    "SkillTier": "StatsLib_Enum_SkillTier",
    "Ability": "StatsLib_Enum_Ability",
    "ProjectileDistribution": "StatsLib_Enum_ProjectileDistribution",
    "ProjectileType": "StatsLib_Enum_ProjectileType",
    "FormatStringColor": "StatsLib_Enum_FormatStringColor",
    "MaterialType": "StatsLib_Enum_MaterialType",
    "HealValueType": "StatsLib_Enum_HealValueType",
    "StatusEvent": "StatsLib_Enum_StatusEvent",
    "VampirismType": "StatsLib_Enum_VampirismType",
    "CastCheckType": "StatsLib_Enum_CastCheckType",
    "StepsType": "StatsLib_Enum_StepsType",

    "Conditions": "unknown TODO",
    "Properties": "unknown TODO",
    "MemorizationRequirements": "table[] TODO",
    "SurfaceCollisionFlags": "unknown TODO",
    "SkillElement": "\"None\"",
}

class ModifierField:
    def __init__(self, modType:str, name:str):
        self.type = modType
        self.name = name

    def get_annotation_type(self)->str:
        return MODIFIER_FIELD_TYPE_TO_LUA[self.type] if self.type in MODIFIER_FIELD_TYPE_TO_LUA else self.type

    def name_contains_spaces(self)->bool:
        return " " in self.name

    def export(self)->str:
        return f"---@field {self.name} {self.get_annotation_type()}"

class Modifier:
    def __init__(self, name):
        self.name = name
        self.fields:list[ModifierField] = []

    def add_field(self, field:ModifierField):
        self.fields.append(field)

    def export(self)->str:
        annotation = ["---@class StatsLib_StatsEntry_" + self.name]
        fields_with_spaces:list[ModifierField] = []

        for field in self.fields:
            if field.name_contains_spaces():
                fields_with_spaces.append(field)
            else:
                annotation.append(field.export())

        # Create table declaration
        annotation.append(f"local {self.name} = {{}}")

        # Put fields with spaces into the table declaration
        for field in fields_with_spaces:
            annotation.append(f"{self.name}[\"{field.name}\"] = nil ---@type {field.get_annotation_type()}")

        return "\n".join(annotation)

mods:list[Modifier] = []
current_mod = None
with open(MODIFIERS_PATH, "r") as f:
    for line in f.readlines():
        modDeclaration = MODIFIER_TYPE_REGEX.match(line)
        fieldDeclaration = MODIFIER_FIELD_REGEX.match(line)

        if modDeclaration:
            mod = Modifier(modDeclaration.groups()[0])
            mods.append(mod)

            current_mod = mod
        elif fieldDeclaration:
            groups = fieldDeclaration.groups()
            field = ModifierField(groups[1], groups[0])
            current_mod.add_field(field)

with open("output.lua", "w") as f:
    for mod in mods:
        f.write(mod.export())
        f.write("\n\n")
