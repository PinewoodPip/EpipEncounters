---------------------------------------------
-- Allows scrolling the character list in the "Party Management" UI, to allow assigning characters beyond the 4th.
-- Note: the UI changes required for 5th+ members to show are handled by CharacterAssign UI overrides
---------------------------------------------

local CharacterAssign = Client.UI.CharacterAssign

---@type Feature
local Scrolling = {
    _BaseListX = nil, ---@type number
    _SlotsScrolled = 0,

    ---@type table<InputRawType, integer>
    _ScrollWheelToDir = {
        ["wheel_ypos"] = -1,
        ["wheel_yneg"] = 1,
    }
}
Epip.RegisterFeature("Features.CharacterAssignScrolling", Scrolling)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Allow scrolling characters with shift + scroll wheel.
Client.Input.Events.KeyPressed:Subscribe(function (ev)
    local moveDir = Scrolling._ScrollWheelToDir[ev.InputID]

    local partyMembers = #Character.GetPartyMembers(Client.GetCharacter())
    Scrolling._SlotsScrolled = math.clamp(Scrolling._SlotsScrolled + moveDir, 0, math.max(partyMembers - 4, 0)) -- Allow scrolling until the right-most character slot is visible.
    local root = CharacterAssign:GetRoot()
    local userList = root.assign_mc.userList
    for i=0,#userList.content_array-1,1 do
        local charList = userList.content_array[i].characterSlotList

        -- Scroll list
        Scrolling._BaseListX = Scrolling._BaseListX or charList.x
        charList.x = Scrolling._BaseListX - Scrolling._SlotsScrolled * (charList.content_array[0].width + charList.EL_SPACING)

        -- Hide slots that would overflow through the left
        for j=0,#charList.content_array-1,1 do
            local element = charList.content_array[j]
            element.visible = j >= Scrolling._SlotsScrolled
        end
    end
    if not moveDir or not CharacterAssign:Exists() then return end
end)

