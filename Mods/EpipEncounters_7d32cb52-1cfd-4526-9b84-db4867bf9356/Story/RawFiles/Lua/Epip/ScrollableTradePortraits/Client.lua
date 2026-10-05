
---------------------------------------------
-- Allows scrolling the player portraits in the trade UI to access portraits that might overflow.
-- ex. When using expanded party size mods
---------------------------------------------

local Trade = Client.UI.Trade
local Input = Client.Input

---@class Features.ScrollableTradePortraits : Feature
local Scrolling = {
    DEFAULT_PORTRAITS_CONTAINER_X = 83,
    VISIBLE_PARTY_MEMBERS = 4, -- Amount of player portraits that can be visible at once.

    ---@type table<InputRawType, integer>
    _ScrollWheelToDir = {
        ["wheel_ypos"] = -1,
        ["wheel_yneg"] = 1,
    },

    _ScrollOffset = 0,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Scrolled = {}, ---@type Event<{Delta: number}>
    },
}
Epip.RegisterFeature("Features.ScrollableTradePortraits", Scrolling)

---------------------------------------------
-- METHODS
---------------------------------------------

---Scrolls the player portraits.
---@param dir 1|-1 Positive values scroll to the right (ie. make portraits on the right visible).
---@return boolean -- Whether portraits were scrolled.
function Scrolling.Scroll(dir)
    local offset = Scrolling._ScrollOffset
    local newOffset = math.clamp(offset + dir, 0, Scrolling.GetMaxScrollOffset())

    local scrolled = newOffset ~= offset
    if scrolled then
        Scrolling.SetScroll(newOffset)
    end

    return scrolled
end

---Sets how many portraits slots have been scrolled.
---Ex. 1 = scrolled one slot to the right (so 1st slot becomes out-of-view)
---@param scrollOffset integer
function Scrolling.SetScroll(scrollOffset)
    local delta = scrollOffset - Scrolling._ScrollOffset
    Scrolling._ScrollOffset = scrollOffset
    Scrolling._UpdatePortraits()

    Scrolling.Events.Scrolled:Throw({
        Delta = delta,
    })
end

---Scrolls the portraits until char's portrait is visible.
---@param char EclCharacter
function Scrolling.ScrollToCharacter(char)
    local charactersArray = Scrolling.GetPartyMembersList().content_array
    local flashHandle = Ext.UI.HandleToDouble(char.Handle)
    for i=0,#charactersArray-1,1 do
        if charactersArray[i].id == flashHandle then
            local offset = Scrolling._ScrollOffset
            if i < offset then -- Portrait is to the left of the visible ones
                Scrolling.SetScroll(i)
            elseif i >= offset + Scrolling.VISIBLE_PARTY_MEMBERS then -- Portrait is to the right of the visible ones
                Scrolling.SetScroll(i - Scrolling.VISIBLE_PARTY_MEMBERS + 1)
            end
        end
    end
end

---Returns how many portrait slots have been scrolled.
---@return integer
function Scrolling.GetScrollOffset()
    return Scrolling._ScrollOffset
end

---Returns the maximum amount of portrait slots that can be scrolled.
---@return integer -- `0` if all portraits fit within the visible area.
function Scrolling.GetMaxScrollOffset()
    local charactersArray = Scrolling.GetPartyMembersList().content_array
    return math.max(0, #charactersArray - Scrolling.VISIBLE_PARTY_MEMBERS)
end

---Returns whether the mouse is hovering over the player portraits area of the Trade UI.
---@return boolean
function Scrolling.IsMouseWithinScrollArea()
    if not Trade:IsVisible() then return false end
    local portraitsContainer = Scrolling.GetPortraitsContainer()
    local mouseX, mouseY = portraitsContainer.mouseX, portraitsContainer.mouseY
    local w, h = portraitsContainer.width, portraitsContainer.height
    return mouseX > 0 and mouseX < w and mouseY > 0 and mouseY < h
end

---Returns the list display of player portraits.
---@return FlashMovieClip
function Scrolling.GetPartyMembersList()
    local root = Trade:GetRoot()
    local tradeMC = root.trade_mc
    local charactersList = tradeMC.charList
    return charactersList
end

---Returns the parent element of the player portraits list.
---@return FlashMovieClip
function Scrolling.GetPortraitsContainer()
    local root = Trade:GetRoot()
    local tradeMC = root.trade_mc
    local portraitsContainer = tradeMC.characterList_mc
    return portraitsContainer
end

---Updates portrait visibility based on scroll amount.
function Scrolling._UpdatePortraits()
    local charactersList = Scrolling.GetPartyMembersList()
    local scrollOffset = Scrolling._ScrollOffset
    local charactersArray = charactersList.content_array
    local portraitsContainer = Scrolling.GetPortraitsContainer()
    local portraitWidth = charactersArray[0].width

    -- Show/hide portraits based on whether they are within the visible slots
    for i=0,#charactersList.content_array-1,1 do
        local portrait = charactersList.content_array[i]
        portrait.visible = i >= scrollOffset and i < (scrollOffset + Scrolling.VISIBLE_PARTY_MEMBERS)
    end

    -- Reposition portraits container
    local newPos = Scrolling.DEFAULT_PORTRAITS_CONTAINER_X - scrollOffset * (portraitWidth + charactersList.EL_SPACING)
    portraitsContainer.x = newPos
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Scroll portraits when mouse wheel is scrolled while hovering over them.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    local moveDir = Scrolling._ScrollWheelToDir[ev.InputID]
    if moveDir and Scrolling.IsMouseWithinScrollArea() then
        if Scrolling.Scroll(moveDir) then
            Trade:PlaySound("UI_Generic_Click")
        end
        ev:Prevent()
    end
end, {EnabledFunctor = Client.IsUsingKeyboardAndMouse})

-- Update portrait masking and scroll to bring the active character into view when the UI is opened.
Trade:RegisterCallListener("setAnchor", function (_, _, _, _)
    Ext.OnNextTick(function ()
        Scrolling.SetScroll(0) -- Reset to left-most portrait first
        Scrolling.ScrollToCharacter(Client.GetCharacter())
        Scrolling._UpdatePortraits()
    end)
end)
