
local Assprite = Epip.GetFeature("Features.Assprite")
local ContextMenu = Client.UI.ContextMenu
local MsgBox = Client.UI.MessageBox
local PlayerInfo = Client.UI.PlayerInfo
local CharacterSheet = Client.UI.CharacterSheet
local CombatTurn = Client.UI.CombatTurn

---@class Features.CustomPortraits : Feature
local CustomPortraits = Epip.GetFeature("Features.CustomPortraits")
local TSK = CustomPortraits.TranslatedStrings
CustomPortraits.REQUESTID_ASSPRITE = "Features.CustomPortraits.AsspriteRequest"
CustomPortraits.MSGBOXID_REQUIRES_EXTENDER_FORK = "Features.CustomPortraits.MsgBox.ExtenderForkRequired"
CustomPortraits.CONTEXTMENU_ENTRY_ID_SET_PORTRAIT = "Features.CustomPortraits.SetPortrait"

-- UIs to refresh when a portrait is set. This will re-show the UI, if it was visible.
---@type UI[]
CustomPortraits.REFRESHED_UIS = {
    PlayerInfo,
    CharacterSheet,
    -- Hotbar, -- More reliable to update via a GameMenu toggle.
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
---@param char EclCharacter? If provided and char has a PlayerData portrait, the image will be the char's PlayerData portrait.
---@return ImageLib_Image
function CustomPortraits.CreateDefaultImage(char)
    if char then -- Use char's portrait. TODO check if PlayerData is initialized
        local dds = Ext.Entity.GetPortrait(char.Handle)
        return Image.GetDecoder("ImageLib.Decoders.DDS"):Decode(dds)
    else
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
end

---Sets a character's portrait client-side and refreshes relevant UIs.
---@param char EclCharacter
---@param img ImageLib_Image
function CustomPortraits._SetPortrait(char, img)
    local dds = Image.ToDDS(img)
    local charHandle = char.Handle

    local success = Ext.Entity.SetPortrait(charHandle, img.Width, img.Height, dds)
    if success then
        -- Refresh commonly-used UIs that display portraits
        Ext.OnNextTick(function (_)
            for _,ui in ipairs(CustomPortraits.REFRESHED_UIS) do
                if ui:IsVisible() then -- Avoid showing UIs that may currently be hidden.
                    ui:Show()
                end
            end

            -- TODO hide Fade UI as well
            Client.UI.GameMenu:Show()
            Client.UI.GameMenu:GetRoot().visible = false -- Necessary to prevent the UI from flashing visible.
            Timer.StartTickTimer(3, function ()
                Client.UI.GameMenu:Hide()
                Client.UI.GameMenu:GetRoot().visible = true
            end)
        end)
    end
end

---Saves a character's portrait to disk, if they have a custom portrait.
---@param char EclCharacter
---@param suffix string?
function CustomPortraits._BackupPortrait(char, suffix)
    local portrait = Ext.Entity.GetPortrait(char.Handle)
    if portrait then
        local path = string.format("Epip/PortraitBackups/%s_%s%s.dds", char.DisplayName, char.MyGuid, suffix and "_" .. suffix or "")
        IO.SaveFile(path, portrait, true)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to set portraits by the server.
Net.RegisterListener(CustomPortraits.NETMSG_SET_PORTRAIT, function (payload)
    local char = payload:GetCharacter()
    local img = Client.Image.CreateFromRawData(payload.ImageRawData)

    -- Save a copy of the portrait to user storage first
    CustomPortraits._BackupPortrait(char, "old")

    CustomPortraits._SetPortrait(char, img)

    -- Save copy of new portrait
    CustomPortraits._BackupPortrait(char)
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
    -- Only show the option for controlled characters.
    local element = ev.Character and PlayerInfo.GetPlayerElement(ev.Character) or nil
    if element and element.controlled then
        table.insert(ev.Entries, {
            id = CustomPortraits.CONTEXTMENU_ENTRY_ID_SET_PORTRAIT,
            type = "button",
            text = CustomPortraits.TranslatedStrings.Label_SetPortrait:GetString(),
            faded = not CustomPortraits.IsSupported(), -- The option is still selectable to inform the user about the fork requirement.
        })
    end
end)

-- Handle requests to open the portrait editor.
ContextMenu.RegisterElementListener(CustomPortraits.CONTEXTMENU_ENTRY_ID_SET_PORTRAIT, "buttonPressed", function (character, _)
    if CustomPortraits.IsSupported() then
        if character.PlayerData.CustomData.Initialized then
            character = character ---@type EclCharacter
            local img = CustomPortraits.CreateDefaultImage(character)
            CustomPortraits._CurrentCharacterHandle = character.Handle
            Assprite.RequestEditor(CustomPortraits.REQUESTID_ASSPRITE, img, TSK.Label_ApplyPortrait)
        else
            MsgBox.Open({
                ID = CustomPortraits.MSGBOXID_REQUIRES_EXTENDER_FORK,
                Header = TSK.MsgBox_NotInitialized_Title:GetString(),
                Message = TSK.MsgBox_NotInitialized_Body:GetString(),
            })
        end
    else
        MsgBox.Open({
            ID = CustomPortraits.MSGBOXID_REQUIRES_EXTENDER_FORK,
            Header = TSK.MsgBox_NoFork_Title:GetString(),
            Message = TSK.MsgBox_NoFork_Body:Format(Epip.EXTENDER_FORK_DOWNLOAD_URL),
            Buttons = {
                {ID = 1, Text = Text.CommonStrings.CopyToClipboard:GetString()},
                {ID = 2, Text = Text.CommonStrings.Close:GetString()},
            },
        })
    end
end)
-- Copy fork download URL to clipboard when requested so from the message box.
MsgBox.RegisterMessageListener(CustomPortraits.MSGBOXID_REQUIRES_EXTENDER_FORK, MsgBox.Events.ButtonPressed, function(buttonId, _)
    if buttonId == 1 then
        Client.CopyToClipboard(Epip.EXTENDER_FORK_DOWNLOAD_URL)
    end
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
