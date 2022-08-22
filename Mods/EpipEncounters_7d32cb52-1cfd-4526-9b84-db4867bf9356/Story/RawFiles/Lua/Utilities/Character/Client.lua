
---@class CharacterLib
local Character = Game.Character

---Returns a list of party members of char's party. Char must be a player.
---Depends on PlayerInfo.
---@param char EclCharacter
---@return EclCharacter[] Includes the char passed per param.
function Character.GetPartyMembers(char)
    local members = {}

    if char.IsPlayer then
        members = Client.UI.PlayerInfo.GetCharacters()

        local hasChar = false
        for _,member in ipairs(members) do
            if member.Handle == char.Handle then
                hasChar = true
            end
        end

        -- If char is not in the client's party, we cannot fetch its members.
        if not hasChar then
            Character:LogWarning(char.DisplayName .. " is not in the client's party; cannot fetch their party members on the client.")

            members = {}
        end
    end

    return members
end

---@param char Character
---@return CharacterLib_StatusFromItem[]
function Character.GetStatusesFromItems(char)
    local items = Character.GetEquippedItems(char)
    local statuses = {}

    for _,item in ipairs(items) do
        local props = item.Stats.PropertyLists
        local extraProps = props.ExtraProperties

        -- Check SelfOnEquip properties
        if extraProps and table.contains(extraProps.AllPropertyContexts, "SelfOnEquip") then
            local name = extraProps.Name
            name = string.sub(name, 1, string.len(name)//2)
            name = name:gsub("_ExtraProperties$", "") -- Boost name

            -- Examine boost stat to find the status name
            local stat = Stats.Get("Boost", name)
            if stat then
                local statProps = stat.ExtraProperties

                for _,statProp in ipairs(statProps) do
                    if statProp.Type == "Status" then
                        local status = char:GetStatus(statProp.Action)
    
                        if status then
                            table.insert(statuses, {Status = status, ItemSource = item})
                        end
                    end
                end
            end
        end
    end

    return statuses
end