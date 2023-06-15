
---@class EpicEncounters_DeltaModsLib
local DeltaMods = EpicEncounters.DeltaMods

---Returns the EE deltamods of an item.
---@param item EclItem
---@param modifierType ("Any"|"Implicit"|"NonImplicit")? Defaults to `"NonImplicit"`
---@return EpicEncounters_DeltaModsLib_DeltaMod[]
function DeltaMods.GetItemDeltaMods(item, modifierType)
    local itemDeltaMods = item:GetDeltaMods()
    local eeDeltaMods = {} ---@type EpicEncounters_DeltaModsLib_DeltaMod[]

    for _,modName in ipairs(itemDeltaMods) do
        local group, level = DeltaMods.GetGroupDefinitionForMod(item, modName)

        if group then
            local isValid = true
            if modifierType == "Implicit" then
                isValid = group.Type == "Implicit"
            elseif modifierType == "NonImplicit" then
                isValid = group.Type == "Normal"
            end

            if isValid then
                local childModName = DeltaMods._GetChildModID(modName, group)

                ---@type EpicEncounters_DeltaModsLib_DeltaMod
                local modEntry = {
                    GroupDefinition = group,
                    Tier = level,
                    ChildModID = childModName,
                }

                -- Override previous group if we found the same deltamod with a higher tier
                local canBeAdded = true
                for i,eeMod in ipairs(eeDeltaMods) do
                    if eeMod.GroupDefinition == group and eeMod.ChildModID == childModName then
                        if eeMod.Tier < level then
                            table.remove(eeDeltaMods, i) -- remove is used instead of a set to preserve deltamod order
                            break
                        else
                            canBeAdded = false
                        end
                    end
                end

                if canBeAdded then
                    table.insert(eeDeltaMods, modEntry)
                end
            end
        end
    end

    return eeDeltaMods
end