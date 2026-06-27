---------------------------------------------
-- Allows scrolling the character list in the "Party Management" UI, to allow assigning characters beyond the 4th.
-- Note: the UI changes required for 5th+ members to show are handled by CharacterAssign UI overrides
---------------------------------------------

local Generic = Client.UI.Generic
local Button = Generic.GetPrefab("GenericUI_Prefab_Button")
local CharacterAssign = Client.UI.CharacterAssign
local V = Vector.Create

---@type Feature
local Scrolling = {
    _BaseListX = nil, ---@type number
    _SlotsScrolled = 0,

    ---@type table<InputRawType, integer>
    _ScrollWheelToDir = {
        ["wheel_ypos"] = -1,
        ["wheel_yneg"] = 1,
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Scrolled = {}, ---@type Event<{Delta: integer}>
    },
}
Epip.RegisterFeature("Features.CharacterAssignScrolling", Scrolling)

local Overlay = Generic.Create("Features.CharacterAssignScrolling")
Overlay._Buttons = {} ---@type {LeftButton: GenericUI_Prefab_Button, RightButton: GenericUI_Prefab_Button}[]

---------------------------------------------
-- METHODS
---------------------------------------------

---Scrolls the character slots.
---@param delta integer Slots to move; positive values will scroll to the right.
function Scrolling.Scroll(delta)
    local partyMembers = #Character.GetPartyMembers(Client.GetCharacter())
    Scrolling._SlotsScrolled = math.clamp(Scrolling._SlotsScrolled + delta, 0, math.max(partyMembers - 4, 0)) -- Allow scrolling until the right-most character slot is visible.

    -- Scroll the character slots
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

    Scrolling.Events.Scrolled:Throw({
        Delta = delta,
    })
end

---Shows the scroll buttons overlay.
function Overlay.Setup()
    local uiRoot = Overlay:CreateElement("Root", "GenericUI_Element_Empty")

    -- Reset state
    Scrolling._SlotsScrolled = 0

    local uiObject = Overlay:GetUI()
    local characterAssignUI = CharacterAssign:GetUI()
    local partyMembers = #Character.GetPartyMembers(Client.GetCharacter())

    Overlay:SetPanelSize(characterAssignUI.SysPanelSize)
    uiObject:ExternalInterfaceCall("setPosition", "center", "screen", "center")
    uiObject.Layer = characterAssignUI.Layer + 1

    -- Hide old buttons in case player count was reduced.
    for _,buttons in ipairs(Overlay._Buttons) do
        buttons.LeftButton:SetVisible(false)
        buttons.RightButton:SetVisible(false)
    end

    -- Create scrolling buttons for each user.
    local root = CharacterAssign:GetRoot()
    local userList = root.assign_mc.userList
    for i=0,#userList.content_array-1,1 do
        local user = userList.content_array[i]
        local existingButtons = Overlay._Buttons[i + 1]
        local leftButton, rightButton
        if existingButtons then
            leftButton, rightButton = existingButtons.LeftButton, existingButtons.RightButton
            leftButton:SetVisible(true)
            rightButton:SetVisible(true)
        else
            leftButton = Button.Create(Overlay, "User.ScrollLeft." .. i, uiRoot, Button.STYLES.ScrollLeft)
            rightButton = Button.Create(Overlay, "User.ScrollRight." .. i, uiRoot, Button.STYLES.ScrollRight)
            Overlay._Buttons[i + 1] = {
                LeftButton = leftButton,
                RightButton = rightButton,
            }

            -- Position buttons
            local buttonsY = i * (user.height + userList.EL_SPACING) + 175
            leftButton:SetPosition(760, buttonsY)
            rightButton:SetPosition(1260, buttonsY)

            leftButton:SetScale(V(1.5, 1.5))
            rightButton:SetScale(V(1.5, 1.5))

            -- Scroll on click
            leftButton.Events.Pressed:Subscribe(function (_)
                Scrolling.Scroll(-1)
            end)
            rightButton.Events.Pressed:Subscribe(function (_)
                Scrolling.Scroll(1)
            end)
        end

        -- Update enabled state when scrolling.
        local function UpdateButtons()
            leftButton:SetEnabled(Scrolling._SlotsScrolled > 0)
            rightButton:SetEnabled(Scrolling._SlotsScrolled < partyMembers - 4)
        end
        UpdateButtons()
        Scrolling.Events.Scrolled:Subscribe(UpdateButtons, {StringID = "Overlay.ScrollButtons"}) -- Unsubscribed when the UI is hidden.
    end

    Overlay:Show()
end

---@override
function Overlay:Hide()
    Scrolling.Events.Scrolled:Unsubscribe("Overlay.ScrollButtons")
    Client.UI._BaseUITable.Hide(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Allow scrolling characters with shift + scroll wheel.
Client.Input.Events.KeyPressed:Subscribe(function (ev)
    local moveDir = Scrolling._ScrollWheelToDir[ev.InputID]
    if not moveDir or not CharacterAssign:Exists() then return end

    Scrolling.Scroll(moveDir)
end)

-- Show the overlay when the UI is shown.
local synching = false
CharacterAssign:RegisterInvokeListener("syncUsers", function (_)
    if synching then return end
    Ext.OnNextTick(function ()
        Overlay.Setup()

        -- Hide the overlay when the UI is closed.
        GameState.Events.Tick:Subscribe(function (_)
            if not CharacterAssign:Exists() then
                Overlay:Hide()
                GameState.Events.Tick:Unsubscribe("Features.CharacterAssignScrolling")
            end
        end, {StringID = "Features.CharacterAssignScrolling"})
    end)
end)
