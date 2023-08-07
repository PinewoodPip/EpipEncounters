
---@class Features.EpipInfoCodex
local EpipInfo = Epip.GetFeature("Features.EpipInfoCodex")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the patch notes from the update notification message box.
Osiris.RegisterSymbolListener("MessageBoxChoiceClosed", 3, "after", function(char, _, result)
    if result == EpipInfo.MSGBOX_OPEN_PATCHNOTES then -- TODO unhardcode; a bit complicated since there is no language on server
        Net.PostToCharacter(char, EpipInfo.NETMSG_OPEN_CHANGELOG)
    end
end)