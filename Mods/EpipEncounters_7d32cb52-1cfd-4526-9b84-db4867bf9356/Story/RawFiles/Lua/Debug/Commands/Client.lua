
local function DumpUIInstances()
    print("Finding UIs...")
    for i=0,4000,1 do
        local ui = Ext.UI.GetByType(i)

        if ui then
            print("Found UI: " .. ui:GetTypeId() .. " " .. ui.Path)
        end
    end
end

local function GenerateTSKHandle()
    local handle = Text.GenerateTranslatedStringHandle()
    Client.CopyToClipboard(handle)
    print(handle, "copied to clipboard")
end

local function GenerateGUID()
    local guid = Text.GenerateGUID()
    Client.CopyToClipboard(guid)
    print(guid, "copied to clipboard")
end

local function GenerateLocalizationTemplate(_, modTable, existingLocalization, filename)
    filename = filename or "Epip/localization_template.json"
    local patch

    print("Dummy language xml created in Osiris Data/" .. filename)

    if existingLocalization then
        print("Patching from " .. existingLocalization)

        patch = IO.LoadFile(existingLocalization, "data")
    end

    local template, newStrings, outdatedStrings = Text.GenerateLocalizationTemplate(modTable, patch)

    if patch then
        print("New/untranslated strings:")
        _D(newStrings)
        print("Outdated/removed strings:")
        _D(outdatedStrings)
    end

    -- IO.SaveFile(filename, template, nil, true)

    -- Write the JSON manually to get around encoding limitations
    local rawStrings = {}
    for handle,data in pairs(template.TranslatedStrings) do
        local context = ""
        ---@diagnostic disable-next-line: undefined-field
        local featureID = data.FeatureID and string.format([["FeatureID" : "%s",]], data.FeatureID) or ""
        local referenceText = data.ReferenceText:gsub("\"", "\\\""):gsub("\n", "\\n")
        local translatedText = data.TranslatedText:gsub("\"", "\\\""):gsub("\n", "\\n")
        if data.ContextDescription then
            local desc = data.ContextDescription
            desc = desc:gsub("\"", "\\\""):gsub("\n", "\\n")
            context = string.format([["ContextDescription" : "%s",]], desc)
        end
        table.insert(rawStrings, string.format([[
"%s" : 
{
    %s
    %s
    "ReferenceText" : "%s",
    "TranslatedText" : "%s"
}]], handle, context, featureID, referenceText, translatedText))
    end

    local rawFile = string.format([[
{
    "FileFormatVersion": 0,
    "ModTable": "%s",
    "TranslatedStrings":
    {
        %s
    }
}]], modTable, Text.Join(rawStrings, ",\n"))

    IO.SaveFile(filename, rawFile, true)
end

local function GenerateLocalizationTemplates()
    local languages = {
        "Spanish",
        "Russian",
        "Traditional Chinese",
        "Simplified Chinese",
        "Portuguesebrazil",
        "French",
    }

    for _,language in ipairs(languages) do
        GenerateLocalizationTemplate(nil, "EpipEncounters", "Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Localization/Epip/" .. language .. "/EpipEncounters.json", "Epip/LocalizationExports/" .. language .. ".json")
    end
end

local function GenerateInputEventAlias()
    local alias = "---@alias InputLib_InputEventStringID "

    for _,entry in pairs(Client.Input.INPUT_EVENTS) do
        alias = alias .. "\"" .. entry.StringID .. "\"|"
    end

    print(alias:sub(1, string.len(alias) - 1))
end

local commands = {
    ["bruteforceuitypes"] = DumpUIInstances,
    ["generateinputeventalias"] = GenerateInputEventAlias,
    ["tskhandle"] = GenerateTSKHandle,
    ["guid"] = GenerateGUID,
    ["generatelocalizationtemplate"] = GenerateLocalizationTemplate,
    ["generatelocalizationtemplates"] = GenerateLocalizationTemplates,
}

for name,command in pairs(commands) do
    Ext.RegisterConsoleCommand(name, command)
end