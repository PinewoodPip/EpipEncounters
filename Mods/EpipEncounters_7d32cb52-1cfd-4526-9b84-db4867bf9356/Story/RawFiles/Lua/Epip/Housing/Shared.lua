
---@class Feature_Housing : Feature
local Housing = {
    Furniture = {}, ---@type table<GUID, Feature_Housing_Furniture>

    ---@type table<Feature_Housing_FurnitureType, string>
    FURNITURE_TYPE_NAMES = {
        Chair = "Chairs",
        Table = "Tables",
        Bed = "Beds",
        Container = "Containers",
        Light = "Lights",
        Facility = "Facilities",
        Trinket = "Trinkets",
        Painting = "Paintings",
        Door = "Doors",
        Statue = "Statues",
        Interactable = "Interactables",
        Item = "Items",
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetFurnitureTypeName = {}, ---@type SubscribableEvent<Feature_Housing_Hook_GetFurnitureTypeName>
    },
}
Epip.RegisterFeature("Housing", Housing)

---@alias Feature_Housing_FurnitureType string|"Chair"|"Table"|"Bed"|"Container"|"Light"|"Facility"|"Trinket"|"Painting"|"Door"|"Clutter"|"Hangable"|"Statue"|"Decor"|"Interactables"|"Item"|"Other"

---@class Feature_Housing_Furniture
---@field TemplateGUID GUID
---@field Name string
---@field Type Feature_Housing_FurnitureType
local _Furniture = {}

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_Housing_Hook_GetFurnitureTypeName
---@field Type Feature_Housing_FurnitureType
---@field Name string Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---@return Feature_Housing_Furniture?
function Housing.GetFurniture(templateGUID)
    return Housing.Furniture[templateGUID]
end

---Returns a table of furnitures, sorted by type.
---@return table<Feature_Housing_FurnitureType, table<GUID, Feature_Housing_Furniture>>
function Housing.GetFurnitureTable()
    local furniture = {}

    for guid,data in pairs(Housing.Furniture) do
        local objType = data.Type
        if not furniture[objType] then furniture[objType] = {} end

        furniture[objType][guid] = data
    end

    return furniture
end

---@param data Feature_Housing_Furniture
function Housing.RegisterFurniture(data)
    Inherit(data, _Furniture)

    Housing.Furniture[data.TemplateGUID] = data
end

---@param furnitureType Feature_Housing_FurnitureType
function Housing.GetfurnitureTypeName(furnitureType)
    ---@type Feature_Housing_Hook_GetFurnitureTypeName
    local hook = {
        Type = furnitureType,
        Name = Housing.FURNITURE_TYPE_NAMES[furnitureType] or furnitureType,
    }

    Housing.Hooks.GetFurnitureTypeName:Throw(hook)

    return hook.Name
end