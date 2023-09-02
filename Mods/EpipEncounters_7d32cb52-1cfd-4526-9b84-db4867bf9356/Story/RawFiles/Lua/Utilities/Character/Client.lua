
---@class CharacterLib
local Character = Character

---------------------------------------------
-- EVENTS
---------------------------------------------

Character.Hooks.CreateEquipmentVisuals = Character:AddSubscribableHook("CreateEquipmentVisuals") ---@type Event<CharacterLib_Hook_CreateEquipmentVisuals>

---Wrapper for Ext.Events.CreateEquipmentVisualsRequest.
---@class CharacterLib_Hook_CreateEquipmentVisuals
---@field Character EclCharacter
---@field Item EclItem
---@field Request EclEquipmentVisualSystemSetParam Hookable.
---@field RawEvent EclLuaCreateEquipmentVisualsRequestEvent

---------------------------------------------
-- METHODS
---------------------------------------------

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

            -- Return the request character anyways.
            members = {char}
        end
    end

    return members
end

---Returns a list of statuses the character has from its equipped items.
---@param char Character
---@return CharacterLib_StatusFromItem[]
function Character.GetStatusesFromItems(char)
    local items = Character.GetEquippedItems(char)
    local statuses = {} ---@type CharacterLib_StatusFromItem[]

    for _,item in pairs(items) do
        local props = item.Stats.PropertyLists
        local extraProps = props.ExtraProperties

        -- Check SelfOnEquip properties
        if extraProps and table.contains(extraProps.AllPropertyContexts, "SelfOnEquip") then
            for _,prop in ipairs(extraProps.Properties.Elements) do
                if prop.TypeId == "Status" then
                    ---@cast prop StatsPropertyStatus
                    local statusID = prop.Status
                    local status = char:GetStatus(statusID)

                    if status then
                        table.insert(statuses, {Status = status, ItemSource = item})
                    end
                end
            end
        end
    end

    return statuses
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward equipment visual events.
Ext.Events.CreateEquipmentVisualsRequest:Subscribe(function (ev)
    ev = ev ---@type EclLuaCreateEquipmentVisualsRequestEvent
    local char = ev.Character or Client.GetCharacter() -- If character is nil, then we are rendering the sheet paperdoll
    local item = char:GetItemBySlot(ev.Params.Slot)
    ---@diagnostic disable-next-line: cast-local-type
    item = item and Item.Get(item)

    Character.Hooks.CreateEquipmentVisuals:Throw({
        Character = char,
        Request = ev.Params,
        RawEvent = ev,
        Item = item,
    })
end)

-- Listen for status application events from server.
Net.RegisterListener("EPIP_CharacterLib_StatusApplied", function (payload)
    local entity = Character.Get(payload.OwnerNetID) or Item.Get(payload.OwnerNetID) ---@type IGameObject
    if entity then
        local status = Character.GetStatusByNetID(entity, payload.StatusNetID)
    
        -- This is not reliable for statuses that are quickly deleted(?)
        if status then
            Character.Events.StatusApplied:Throw({
                Status = status,
                SourceHandle = status.StatusSourceHandle,
                Victim = entity,
            })
        end
    end
end)

-- Forward item equip events.
Net.RegisterListener("EPIP_CharacterLib_ItemEquipped", function (payload)
    local char, item = Character.Get(payload.CharacterNetID), Item.Get(payload.ItemNetID)
    
    Character._ThrowItemEquippedEvent(char, item)
end)