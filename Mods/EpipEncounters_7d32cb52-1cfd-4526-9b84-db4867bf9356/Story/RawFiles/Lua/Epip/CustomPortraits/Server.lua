
---@class Features.CustomPortraits : Feature
local CustomPortraits = Epip.GetFeature("Features.CustomPortraits")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to set portraits.
Net.RegisterListener(CustomPortraits.NETMSG_SET_PORTRAIT, function (payload)
    -- Set portrait server-side
    local char = payload:GetCharacter()
    local img = Image.CreateFromRawData(payload.ImageRawData)
    local bct1Stream = Image.ToBCT1Stream(img)
    Ext.Entity.SetPortrait(char.Handle, img.Width, img.Height, bct1Stream)

    -- Send portrait to clients
    Net.Broadcast(CustomPortraits.NETMSG_SET_PORTRAIT, payload)
end)
