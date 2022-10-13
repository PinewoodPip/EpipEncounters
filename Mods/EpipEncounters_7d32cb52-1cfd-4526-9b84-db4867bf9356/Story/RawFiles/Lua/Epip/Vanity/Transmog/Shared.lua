
---@class Feature_Vanity_Transmog : Feature
local Transmog = {
    favoritedTemplates = {},
    activeCharacterTemplates = {},
    KEEP_APPEARANCE_TAG_PREFIX = "PIP_Vanity_Transmog_KeepAppearance_",
    INVISIBLE_TAG = "PIP_VANITY_INVISIBLE",
    KEEP_ICON_TAG = "PIP_VANITY_TRANSMOG_ICON_%s",
    KEEP_ICON_PATTERN = "^PIP_VANITY_TRANSMOG_ICON_(.+)$",
    TRANSMOGGED_TAG = "PIP_VANITY_TRANSMOG_TEMPLATE_%s",
    TRANSMOGGED_TAG_PATTERN = "^PIP_VANITY_TRANSMOG_TEMPLATE_(.+)$",

    BLOCKED_TEMPLATES = {
        -- Captain
        ["79aee656-f5e5-4db8-9c7c-ffc7bcd8b59e"] = true,
        ["820dab86-4afe-4b17-9ccc-79e381bf59cd"] = true,
        ["a0920371-9f1f-4285-a1d0-e7dead1b7398"] = true,

        -- Contamination
        ["791205be-2432-4acb-bcdb-01a5b6bd391b"] = true,
        ["12956e00-7efe-47d9-a659-60f9fabbaaf9"] = true,
        ["ac2a6202-246c-4e90-9d11-7c55bcb6193b"] = true,
        ["fc06302c-dad9-4691-953a-5f5a19ba9881"] = true,
        ["0abd081e-3cc0-4f1d-863e-e3b34e56dfe8"] = true,
        ["88d9f9ac-96fb-4ca7-a241-c61a3f662050"] = true,
        ["b894ae2c-a2d5-46da-9050-1e50a7edec63"] = true,
        ["419de8e7-c7d5-4bce-93b1-3da03565ab70"] = true,
        ["7a3fe2b8-5881-45ba-be33-d34e8e48c852"] = true,

        -- Vulture
        ["dff85e5f-c72a-40ed-9036-5b08f8ae2b2f"] = true,
        ["99b04103-ba96-4517-86f6-50cba862220f"] = true,
        ["8a1b807d-9865-4fbd-9d98-b0904445761e"] = true,
        ["b9453748-d153-4709-9d50-2790a3fa2578"] = true,
        ["8b1bf641-28d3-4ec3-a1ab-d697c4ebfa85"] = true,
        ["698a3588-e9e7-4ffb-9c85-1056a27ac611"] = true,
        ["9db3d6b2-86c2-490c-8fbf-2a14b9ba774a"] = true,
        ["72f2197b-e366-4298-8bf4-0d99508e9f86"] = true,
        ["4476e95e-dc38-4fad-aa83-05053d7a908a"] = true,
        ["84dac3eb-65c0-4085-8521-4142c50b893d"] = true,
        ["f89552b1-2780-48c0-8836-278146ae1b51"] = true,
        ["6d9bd692-db47-4c1d-aa68-001b69bd1c5d"] = true,

        -- Devourer
        ["e3141a3f-7e33-419a-bb11-ee47b3c86e8a"] = true,
        ["64799c69-9eca-41bc-854b-3178c4192bcf"] = true,
        ["62190ebb-943e-4640-bb35-f6688418060c"] = true,
        ["327918c7-804e-42fa-9ec4-c53d711876b8"] = true,
        ["a18a346d-30eb-45b7-852b-37cbe7d20f68"] = true,
    },

    Events = {},
    Hooks = {},
}
Epip.RegisterFeature("Vanity_Transmog", Transmog)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param item Item
---@return string?
function Transmog.GetIconOverride(item)
    return Entity.GetParameterTagValue(item, Transmog.KEEP_ICON_PATTERN)
end

---Returns the template an item has been transmogged into, if any.
---@param item Item
---@return GUID?
function Transmog.GetTransmoggedTemplate(item)
    return Entity.GetParameterTagValue(item, Transmog.TRANSMOGGED_TAG_PATTERN)
end