
local Assprite = Epip.GetFeature("Features.Assprite")
local ContextMenu = Client.UI.ContextMenu
local PlayerInfo = Client.UI.PlayerInfo
local CharacterSheet = Client.UI.CharacterSheet
local CombatTurn = Client.UI.CombatTurn
local Hotbar = Client.UI.Hotbar

---@class Features.CustomPortraits : Feature
local CustomPortraits = Epip.GetFeature("Features.CustomPortraits")
local TSK = CustomPortraits.TranslatedStrings
CustomPortraits.REQUESTID_ASSPRITE = "Features.CustomPortraits.AsspriteRequest"
CustomPortraits.CONTEXTMENU_ENTRY_ID_SET_PORTRAIT = "Features.CustomPortraits.SetPortrait"

-- UIs to refresh when a portrait is set. This will re-show the UI, if it was visible.
---@type UI[]
CustomPortraits.REFRESHED_UIS = {
    PlayerInfo,
    CharacterSheet,
    Hotbar,
    CombatTurn, -- Just in case someone spends their round painting in multiplayer, I guess?
}

CustomPortraits._CurrentCharacterHandle = nil ---@type CharacterHandle? The character that the Assprite instance is currently customizing the portrait for.

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests to set the portrait for a character.
---@param char EclCharacter
---@param portrait ImageLib_Image
function CustomPortraits.RequestSetPortrait(char, portrait)
    Net.PostToServer(CustomPortraits.NETMSG_SET_PORTRAIT, {
        CharacterNetID = char.NetID,
        ImageRawData = portrait:ToRawData(),
    })
end

---Returns the default image to use when requesting Assprite.
---@return ImageLib_Image
function CustomPortraits.CreateDefaultImage()
    local PORTRAIT_SIZE = CustomPortraits.PORTRAIT_SIZE
    local img = Client.Image.CreateImage(PORTRAIT_SIZE:unpack())
    -- Fill with white
    for _=1,PORTRAIT_SIZE[2],1 do
        for _=1,PORTRAIT_SIZE[1],1 do
            img:AddPixel(Color.CreateFromHex(Color.WHITE))
        end
    end
    return img
end

---Sets a character's portrait client-side and refreshes relevant UIs.
---@param char EclCharacter
---@param img ImageLib_Image
function CustomPortraits._SetPortrait(char, img)
    local bct1Stream = Client.Image.ToBCT1Stream(img)
    Ext.Entity.SetPortrait(char.Handle, img.Width, img.Height, bct1Stream)

    -- Refresh commonly-used UIs that display portraits
    Ext.OnNextTick(function (_)
        for _,ui in ipairs(CustomPortraits.REFRESHED_UIS) do
            if ui:IsVisible() then -- Avoid showing UIs that may currently be hidden.
                ui:Hide() -- Necessary for the Hotbar UI.
                ui:Show()
            end
        end
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to set portraits by the server.
Net.RegisterListener(CustomPortraits.NETMSG_SET_PORTRAIT, function (payload)
    local char = payload:GetCharacter()
    local img = Client.Image.CreateFromRawData(payload.ImageRawData)
    CustomPortraits._SetPortrait(char, img)
end)

-- Handle applying portraits from Assprite.
Assprite.Events.RequestCompleted:Subscribe(function (ev)
    if ev.RequestID == CustomPortraits.REQUESTID_ASSPRITE then
        if ev.Image then
            local char = Character.Get(CustomPortraits._CurrentCharacterHandle)
            CustomPortraits.RequestSetPortrait(char, ev.Image)
        end
        CustomPortraits._CurrentCharacterHandle = nil
    end
end)

-- Append entries to PlayerInfo context menu.
PlayerInfo.Hooks.GetContextMenuEntries:Subscribe(function (ev)
    table.insert(ev.Entries, {
        id = CustomPortraits.CONTEXTMENU_ENTRY_ID_SET_PORTRAIT,
        type = "button",
        text = CustomPortraits.TranslatedStrings.Label_SetPortrait:GetString(),
    })
end, {EnabledFunctor = function ()
    return Epip.IsPipFork() and Epip.GetPipForkVersion() >= 4 -- TODO show the option grayed out if unavaiable?
end})

-- Handle requests to open the portrait editor.
ContextMenu.RegisterElementListener(CustomPortraits.CONTEXTMENU_ENTRY_ID_SET_PORTRAIT, "buttonPressed", function (character, _)
    local img = CustomPortraits.CreateDefaultImage()
    CustomPortraits._CurrentCharacterHandle = character.Handle
    Assprite.RequestEditor(CustomPortraits.REQUESTID_ASSPRITE, img)
end)

-- Prevent loading images of wrong size.
Assprite.Hooks.IsImageValid:Subscribe(function (ev)
    local context = Assprite.GetContext()
    if context.RequestID == CustomPortraits.REQUESTID_ASSPRITE then
        local img = ev.Image
        local expectedSize = CustomPortraits.PORTRAIT_SIZE
        if img.Width ~= expectedSize[1] or img.Height ~= expectedSize[2] then
            ev.InvalidReason = TSK.Notification_Load_Error_WrongResolution:Format(expectedSize:unpack())
        end
    end
end)
