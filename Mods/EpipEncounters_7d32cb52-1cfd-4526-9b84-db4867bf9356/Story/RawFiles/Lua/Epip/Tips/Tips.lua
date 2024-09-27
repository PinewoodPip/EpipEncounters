
---------------------------------------------
-- Registers Epip tips.
---------------------------------------------

local HotbarTweaks = Epip.GetFeature("Features.HotbarTweaks")
local QuickFind = Epip.GetFeature("Feature_QuickInventory")
local StatusesDisplay = Epip.GetFeature("Feature_StatusesDisplay")
local QuickLoot = Epip.GetFeature("Features.QuickLoot")
local InventoryMultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")
local InventoryTooltips = Epip.GetFeature("Features.TooltipAdjustments.InventoryTooltipsRepositioning")
local CameraControls = Epip.GetFeature("Features.CameraControls")
local Codex = Epip.GetFeature("Feature_Codex")
local Input = Client.Input

local Tips = Epip.GetFeature("Features.Tips")
local SettingParamContextHint = "Param is the relevant setting name"
local InputActionParamContextHint = "Param is the relevant setting name"

---@param entry TextLib_TranslatedString|{RelevantSetting:SettingsLib_Setting, RelevantInputAction:InputLib_Action}
local TSK = function(entry)
    if entry.RelevantSetting or entry.RelevantInputAction then
        -- Allow manual overrides of these fields.
        entry.ContextDescription = entry.ContextDescription or (entry.RelevantSetting and SettingParamContextHint or InputActionParamContextHint)
        entry.FormatOptions = entry.FormatOptions or {FormatArgs = {(entry.RelevantSetting or entry.RelevantInputAction):GetName()}}
    end
    return Tips:RegisterTranslatedString(entry)
end

---@type Features.Tips.Tip[]
local tips = {
    -- General
    {
        ID = "SettingsMenu.Shortcut",
        Tip = TSK({
            Handle = "h89864b53g6c80g4beegbef4g525cda3cbef0",
            Text = [[Hold shift while clicking on "Options" in the pause menu to open the Epip settings menu directly.]],
        }),
    },
    {
        ID = "AnimationCancelling",
        Tip = TSK({
            Handle = "ha3abcdafg29a5g4c62gb0dbg3522263cb2a6",
            Text = "Skill animations taking too long? Try the Animation Cancelling feature!",
        }),
    },
    {
        ID = "Keybinds",
        Tip = TSK({
            Handle = "he0ec379ag6bdag4d69gac0eg9d487a5ef12c",
            Text = [[The "Keybinds" settings menu tab contains numerous new shortcuts, including an Examine keybind.]],
        }),
    },
    {
        ID = "Website",
        Tip = TSK({
            Handle = "h714d5863g1a8bg4d35gb4e2gfcdc35be3cb8",
            Text = [[Visit the website for overviews and demostrations of major features.]],
        }),
    },
    {
        ID = "MinimapToggle",
        Tip = TSK({
            Handle = "he4f29d95gf861g434ega840g813a9dddffc7",
            Text = [[You can disable the minimap UI in the "Miscellaneous UI" settings tab.]],
        }),
    },
    {
        ID = "Camera.Controls",
        Tip = TSK({
            Handle = "hb7782218gea9cg44beg893dg6127d8f00a3d",
            Text = [[Use the "%s" keybind to quickly adjust the camera angle.]],
            RelevantInputAction = CameraControls.InputActions.AdjustPitch,
        }),
    },
    {
        ID = "Camera.FasterKeyboardControls",
        Tip = TSK({
            Handle = "h79c8cb89g33c7g48cagaac3ge0bae06d585e",
            Text = [[Adjust the "%s" setting to rotate the camera faster with the keyboard.]],
            RelevantSetting = CameraControls.Settings.KeybindRotationRate,
        }),
    },

    -- Hotbar
    {
        ID = "Hotbar.ContextMenu",
        Tip = TSK({
            Handle = "hb57564f8g68bag4e0bgaa33g15e2f6635231",
            Text = [[Right-click a Hotbar row to save & load loadouts, clear rows, or shift groups of slots around.]],
        }),
    },
    {
        ID = "Hotbar.UnlearntSkillDragging",
        Tip = TSK({
            Handle = "h1803b4d7gfc22g4c70gbb02g9c0c55af30ed",
            Text = [[You may drag & drop skills from the Codex to your Hotbar. Enable "%s" to be able to do so even for unlearnt ones.]],
            RelevantSetting = HotbarTweaks.Settings.AllowDraggingUnlearntSkills,
        }),
    },
    {
        ID = "Hotbar.SelectUpperBars",
        Tip = TSK({
            Handle = "h416a48e6g2251g468agba4aga11aaf8ae546",
            Text = [[Enable "%s" to be able to use slots from higher bars with keybinds.]],
            RelevantSetting = HotbarTweaks.Settings.SlotKeyboardModifiers,
        }),
    },
    {
        ID = "Hotbar.ActionsDrawer",
        Tip = TSK({
            Handle = "h1495fbfeg9e3dg4d12gbf4fg417e821ab9a0",
            Text = [[Right-click the buttons at the bottom left of the Hotbar or use the "^" button to view all actions.]],
        }),
    },
    {
        ID = "Hotbar.ReassignActions",
        Tip = TSK({
            Handle = "h73e142a6gd7aeg4239g8aa2g33f2d4b20e0f",
            Text = [[While the Hotbar is unlocked, you can drag-and-drop buttons at the bottom left to reorder them.]],
        }),
    },
    {
        ID = "HotbarGroups",
        Tip = TSK({
            Handle = "hfc643ff3g4eacg493agb7e1gb680f2712c58",
            Text = [[Right-click a Hotbar row and select "Create group..." to create additional detached slot groups.]],
        }),
    },
    {
        ID = "HotbarGroups.Edit",
        Tip = TSK({
            Handle = "hf6bd74e0g8002g45d9gbb61g4678876368c9",
            Text = [[Right-click a Hotbar Group to edit its size or delete it.]],
        }),
    },

    -- Inventory
    {
        ID = "QuickFind.QuickSwap",
        Tip = TSK({
            Handle = "h388c53d5g04b6g4f6cg9a05gdd6c3439f55c",
            Text = [[Right-click an equipped item in the character sheet and select "%s" to browse items that can go in that slot.]],
            ContextDescription = "Param is context menu option",
            FormatOptions = {
                FormatArgs = {QuickFind.TranslatedStrings.ContextMenuButtonLabel}
            },
        }),
    },
    {
        ID = "QuickFind.Search",
        Tip = TSK({
            Handle = "hbde30424g74b4g4524gb1c8g0ff0425c2e64",
            Text = [[You can use the "%s" search bar in Quick Find to search for party equipment with specific stat boosts.]],
            RelevantSetting = QuickFind.Settings.DynamicStat,
        }),
    },
    {
        ID = "InventoryMultiSelect.GeneralUsage",
        Tip = TSK({
            Handle = "hdcfcacdeg3e21g4b37g80bcg813c80877f98",
            Text = [[Enable "%s" and bind its respective keybinds to quickly move groups of items in inventories, including bags.]],
            RelevantSetting = InventoryMultiSelect.Settings.Enabled,
        }),
    },
    {
        ID = "InventoryMultiSelect.ValidTargets",
        Tip = TSK({
            Handle = "h73ae2206ga122g46d7gab18g83db9069fc4c",
            Text = [[While multi-selecting items, you may drop them onto inventory cells, container items or player bag headers.]],
        }),
    },

    -- Statuses
    {
        ID = "Statuses.GoToSource",
        Tip = TSK({
            Handle = "h0fe8cd11g4b93g4109gbf60g284b84d78eb7",
            Text = [[Click on statuses to focus the camera on the character that applied them.]],
        }),
    },
    {
        ID = "Statuses.AlternativeStatusDisplay",
        Tip = TSK({
            Handle = "hf14fc0f2gf02dg4ef2g9ac3g91d04fd179b0",
            Text = [[Enable "%s" to be able to filter and reorder statuses by the player portraits by right-clicking them.]],
            RelevantSetting = StatusesDisplay.Settings.Enabled,
        }),
    },
    {
        ID = "Statuses.TempFilterToggle",
        Tip = TSK({
            Handle = "hd6bf50e5g1bf2g48acg9406g3ceacee06365",
            Text = [[If "%s" is enabled, holding shift will temporarily disable your status filters.]],
            RelevantSetting = StatusesDisplay.Settings.Enabled,
        }),
        InputDevice = "KeyboardAndMouse",
    },
    {
        ID = "Statuses.TempFilterToggle.Controller",
        Tip = TSK({
            Handle = "he466b5b5g84f1g42c5g913cg6eeec2ce54d4",
            Text = [[If "%s" is enabled, pressing right-stick will toggle your status filters.]],
            RelevantSetting = StatusesDisplay.Settings.Enabled,
        }),
        InputDevice = "Controller",
    },

    -- Epic Encounters
    {
        ID = "EpicEncounters.SourceInfusionTooltips",
        Tip = TSK({
            Handle = "heb1b963bg108fg4cf7ga4d0g8e3424fc3891",
            Text = [[Hold shift while viewing a skill tooltip to quickly reference your relevant ability score and check unlocked Source Infusions.]],
        }),
        RequiresEE = true,
    },
    {
       ID = "EpicEncounters.DeltamodsTooltip",
       Tip = TSK({
           Handle = "h4d828efdg6de7g4617gb367ga1e3e3005010",
           Text = [[Hold shift while viewing an equipment tooltip to see its Epic Encounters gear modifier tiers.]],
        }),
        RequiresEE = true,
    },
    {
        ID = "EpicEncounters.GreatforgeDragDrop",
        Tip = TSK({
            Handle = "h78c3cb94g6af7g4cd4g822agafb87add26be",
            Text = [[Drag-and-drop items into the Greatforge socket to work with them.]],
        }),
        RequiresEE = true,
    },
    {
        ID = "EpicEncounters.MassDismantle",
        Tip = TSK({
            Handle = "hc72f22a1g462cg4932g961eg531e228a8a8c",
            Text = [[Right-click containers in your inventory and select "Mass Dismantle" to dismantle all non-unique equipment within.]],
        }),
        RequiresEE = true,
    },
    {
        ID = "EpicEncounters.Dismantle",
        Tip = TSK({
            Handle = "hf23c6ab7gd9afg4086g9dc8g3f13c5ceb3b4",
            Text = [[Right-click items and select "Dismantle" to quickly dismantle items without going to the Greatforge.]],
        }),
        RequiresEE = true,
    },
    {
        ID = "EpicEncounters.ExtractRunes",
        Tip = TSK({
            Handle = "h319a6617geab6g42efg943dgf6086e1f4b5f",
            Text = [[Right-click items and select "Extract Runes" to recover the runes as if doing so through the Greatforge.]],
        }),
        RequiresEE = true,
    },

    -- Vanity
    {
        ID = "Vanity.Open",
        Tip = TSK({
            Handle = "h115197c6g73d3g48f6g8f80g6152dacab766",
            Text = [[Right-click an equipped item in the character sheet and select "Vanity" to access vast appearance customization options.]],
        }),
    },
    {
        ID = "Vanity.Outfits",
        Tip = TSK({
            Handle = "h143b716bg5c94g40b1g98f9gd9000ce95e3c",
            Text = [[Use the "Outfits" tab in the Vanity UI to save the appearance of all your equipped items to re-use across playthroughs or share outfits with other players.]],
        }),
    },

    -- Tooltips
    {
        ID = "Tooltips.ToggleWorldTooltips",
        Tip = TSK({
            Handle = "ha4a8e067g039ag4295g8c98g710cee3611cf",
            Text = [[Tired of holding "%s"? Try the "%s" Epip keybind!]],
            ContextDescription = [[Params are names of "Show World Tooltips" vanilla keybind and "Toggle World Tooltips" Epip keybind. "Holding" refers to pressing down a keybind.]],
            RelevantInputAction = Input.GetAction("EpipEncounters_ToggleWorldTooltips"),
            FormatOptions = {
                FormatArgs = {
                    Input.GetInputEventDefinition("ShowWorldTooltips"):GetName(),
                    Input.GetAction("EpipEncounters_ToggleWorldTooltips"):GetName(),
                },
            },
        }),
    },
    {
        ID = "Tooltips.MovementCost",
        Tip = TSK({
            Handle = "hb08d946dgc24dg41f6gab0ega2906c48dbd7",
            Text = [[Hold shift while moving in combat to see precise AP costs.]],
        }),
    },
    {
        ID = "Tooltips.WorldTooltipsSettings",
        Tip = TSK({
            Handle = "h5e9bbf2fga329g4284g8cfegb1a6005e2c4d",
            Text = [[Browse the "Tooltips" settings tab to configure extensive filters for world tooltips, such as hiding empty containers.]],
        }),
    },
    {
        ID = "Tooltips.InventoryPositioning",
        Tip = TSK({
            Handle = "h901fdfa6gb1d0g4190g9f4cg6d6adeefb841",
            Text = [[You may configure the "%s" setting to have tooltips appear by the side of the UI rather than by the cursor.]],
            RelevantSetting = InventoryTooltips.Settings.Position,
        }),
    },

    -- Misc UI
    {
        ID = "EnemyHealthBar.AlternativeDisplay",
        Tip = TSK({
            Handle = "h0383a7b3gbc16g48afg932ag2e5de1b7b526",
            Text = [[Hold shift while viewing a character's healthbar to show their AP, SP, initiative and other information.]],
            ContextDescription = [[AP and SP are short for Action Points and Source Points respectively]],
        }),
    },
    {
        ID = "Codex.Keybind",
        Tip = TSK({
            Handle = "hdc31c891ge5bdg40f5gb098geb0b0e961a81",
            Text = [[Use the "%s" keybind to open an encyclopedia-style UI with a list of all skills and Epic Encounters Artifacts.]],
            RelevantInputAction = Codex.InputActions.Open,
        }),
    },
    {
        ID = "Skillbook.Unlearn",
        Tip = TSK({
            Handle = "h8c888787g3010g44cbg8665g209abca084f7",
            Text = [[Right-click skills in the skillbook UI to unlearn them.]],
        }),
    },
    {
        ID = "QuickExamine.Skills",
        Tip = TSK({
            Handle = "h39aeaf1cga7f6g418ag8954g6c7b8fd1c5e3",
            Text = [[You can use the Quick Examine UI to check the skills, cooldowns and equipment of other players in multiplayer.]],
        }),
    },
    {
        ID = "QuickLoot.DefaultRadius",
        Tip = TSK({
            Handle = "hf9c292ccga0c3g48fbgbaa5gb26ff6115fa1",
            Text = [[Adjust the Quick Loot "%s" setting to select containers further away with quick taps of the keybind.]],
            RelevantInputAction = QuickLoot.InputActions.Search,
        }),
    },

    -- Controller tips
    {
        ID = "Controller.TargetExtraInfo",
        Tip = TSK({
            Handle = "h22455277g5301g4695gb5adg6ccf414797d0",
            Text = [[Open the context menu for characters in combat to quickly check their AP, SP and initiative.]],
            ContextDescription = [[AP and SP are short for Action Points and Source Points respectively]],
        }),
        InputDevice = "Controller",
    },

    -- Meme tips
    {
        ID = "Meme.Anniversary",
        Tip = TSK({
            Handle = "ha5eb7b58g616bg419fgaa8bg7e4a0731c261",
            Text = [[Epip's anniversary is celebrated on the 1st of April with various special features.]],
        }),
    },
}

for _,tip in ipairs(tips) do
    Tips.RegisterTip(tip)
end
