
---------------------------------------------
-- Handler for skill cast messages ("X used Y [on Z]").
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Skill : UI.CombatLog.Messages.Character
---@field Skill string
---@field SkillColor htmlcolor
---@field Target UI.CombatLog.Messages.Skill.Type
---@field TargetCharacter string?
---@field TargetCharacterColor string?
local _Skill = {
    USED_TSKHANDLE = "h3e89b00fg3d68g40a3ga8ceg5c12abc6fd96", -- "[1] used [2]"; it's unknown how the game determines whether to use "used" or "cast"
    CAST_TSKHANDLE = "h93860484g5c06g41d9g8c3bg0075658ca472", -- "[1] cast [2]"
    CAST_ON_GROUND_TSKHANDLE = "h17edbbb2g9444g4c79g9409gdb8eb5731c7c", -- "[1] cast [2] on the ground"
    SUMMONED_TSKHANDLE = "h74a3e975g6db6g4343g88aag6922bcb6759f", -- "[1] summoned [3] onto the battlefield"
    CAST_TELEPORT_TSKHANDLE = "hb3e77c55g92dag4c41ga533ge417faa88efc", -- "[1] cast [2], teleporting [3] into the air."
    CAST_RAIN_TSKHANDLE = "h6a2be935g6033g4252gaf9cg54d4c299938e", -- "[1] cast [2], making targets in range [3]"
    CAST_WALL_TSKHANDLE = "he842af67ga9aag49d2g9863g1a0223b74764", -- "[1] cast [2], creating a protective wall"; unused? Wall skills use the regular "used" message.
    -- FAILED_CAST_TSKHANDLE = "h0a47f708g0ca9g4d22g8268g82ef62af3458", -- "[1] failed to cast [2], because [3] is no longer a valid target!"; this is technically used, but the conditions for it are unknown. TODO support?

    ON_TSKHANDLE = "hb553e776ga2f8g43bbg91e6g9b43715794b4", -- "[1] on [2]"; used for ex. "X used <skill> on Y"

    ---@enum UI.CombatLog.Messages.Skill.Type
    TARGET_TYPES = {
        CHARACTER = "Character",
        GROUND = "Ground",
        SELF = "Self",
        TELEPORT = "Teleport",
        WALL = "Wall",
        RAIN = "Rain",
        SUMMON = "Summon", -- TODO handle this case more gracefully; skill name is not included in this message, only the summon name.
    }
}
Log:RegisterClass("UI.CombatLog.Messages.Skill", _Skill, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(_Skill)

---@type {Pattern: pattern, SkillType: UI.CombatLog.Messages.Skill.Type}
_Skill.PATTERNS = {
    {Pattern = _Skill.CAST_ON_GROUND_TSKHANDLE, SkillType = _Skill.TARGET_TYPES.GROUND},
    {Pattern = _Skill.CAST_TELEPORT_TSKHANDLE, SkillType = _Skill.TARGET_TYPES.CHARACTER},
    {Pattern = _Skill.SUMMONED_TSKHANDLE, SkillType = _Skill.TARGET_TYPES.SUMMON},
    {Pattern = _Skill.CAST_RAIN_TSKHANDLE, SkillType = _Skill.TARGET_TYPES.GROUND},
    {Pattern = _Skill.CAST_WALL_TSKHANDLE, SkillType = _Skill.TARGET_TYPES.GROUND},

    -- These should be last so that types with more trailing text can match first.
    {Pattern = _Skill.CAST_TSKHANDLE, SkillType = _Skill.TARGET_TYPES.SELF},
    {Pattern = _Skill.USED_TSKHANDLE, SkillType = _Skill.TARGET_TYPES.SELF},
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a skill message.
---@param charName string
---@param charColor htmlcolor
---@param skillName string
---@param skillColor htmlcolor
---@param targetType UI.CombatLog.Messages.Skill.Type
---@param targetName string?
---@param targetColor htmlcolor?
function _Skill:Create(charName, charColor, skillName, skillColor, targetType, targetName, targetColor)
    ---@type UI.CombatLog.Messages.Skill
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,

        Skill = skillName,
        SkillColor = skillColor,
        Target = targetType,
        TargetCharacter = targetName,
        TargetCharacterColor = targetColor,
    })
end

---@override
function _Skill:ToString()
    local message = ""
    local skillLabel = Text.Format(self.Skill, {Color = self.SkillColor})

    if self.Target == self.TARGET_TYPES.SUMMON then
        message = Text.FormatLarianTranslatedString(_Skill.SUMMONED_TSKHANDLE,
            Text.Format(self.CharacterName, {Color = self.CharacterColor})
        )
        message = Text.Replace(message, "[3]", Text.Format(self.TargetCharacter, {Color = self.TargetCharacterColor}), 1) -- This TSK has params [1] & [3], thus the previous call cannot handle it properly.
    elseif self.Target == self.TARGET_TYPES.GROUND then
        message = Text.FormatLarianTranslatedString(_Skill.CAST_ON_GROUND_TSKHANDLE,
            self:GetCharacterLabel(),
            skillLabel
        )
    elseif self.Target == self.TARGET_TYPES.CHARACTER then
        message = Text.FormatLarianTranslatedString(_Skill.ON_TSKHANDLE,
            Text.FormatLarianTranslatedString(_Skill.USED_TSKHANDLE,
                self:GetCharacterLabel(),
                skillLabel
            ),
            Text.Format(self.TargetCharacter, {Color = self.TargetCharacterColor})
        )
    elseif self.Target == self.TARGET_TYPES.TELEPORT then
        message = Text.FormatLarianTranslatedString(_Skill.CAST_TELEPORT_TSKHANDLE,
            self:GetCharacterLabel(),
            skillLabel,
            Text.Format(self.TargetCharacter, {Color = self.TargetCharacterColor})
        )
    else -- Wall, Rain, and Self cases.
        message = Text.FormatLarianTranslatedString(_Skill.CAST_TSKHANDLE,
            self:GetCharacterLabel(),
            skillLabel
        )
    end

    return message
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    -- Check for every skill pattern
    for _,basePattern in ipairs(_Skill.PATTERNS) do
        local hasSkillName = true

        -- Build the pattern
        local pattern
        if basePattern.Pattern == _Skill.SUMMONED_TSKHANDLE then -- Annoying edgecase: this TSK has params [1] & [3], skipping [2], thus our format function is inapplicable.
            pattern = Text.FormatLarianTranslatedString(basePattern.Pattern,
                _Skill.KEYWORD_PATTERN
            )
            pattern = Text.Replace(pattern, "[3]", _Skill.KEYWORD_PATTERN) -- Target character
            hasSkillName = false
        else
            pattern = Text.FormatLarianTranslatedString(basePattern.Pattern,
            _Skill.KEYWORD_PATTERN, -- Caster character
            _Skill.KEYWORD_PATTERN, -- Skill color & name
            _Skill.KEYWORD_PATTERN -- Used by teleport and rain skills.
        )
        end

        -- Parse message
        local charColor, charName, skillColor, skillName, targetColor, targetName
        local params = {message:match(pattern)}
        if hasSkillName then
            charColor, charName, skillColor, skillName, targetColor, targetName = table.unpack(params)
        else -- Not all skill casts include skill name.
            charColor, charName, skillColor, skillName, targetColor, targetName = params[1], params[2], nil, nil, params[3], params[4]
        end
        if charColor then -- Note: not all skill types have the targetColor and targetName params.
            obj = _Skill:Create(charName, charColor, skillName, skillColor, basePattern.SkillType, targetName, targetColor)
            break
        end
    end
    return obj
end)

-- Construct additonal patterns dynamically;
-- these cannot be added during bootstrap as fetching TSKs is unreliable at that time.
GameState.Events.ClientReady:Subscribe(function ()
    -- Add pattern for "X used Y on Z"
    table.insert(_Skill.PATTERNS, 1, {
        Pattern = Text.FormatLarianTranslatedString(_Skill.ON_TSKHANDLE,
            Text.FormatLarianTranslatedString(_Skill.USED_TSKHANDLE,
                _Skill.KEYWORD_PATTERN,
                _Skill.KEYWORD_PATTERN
            ),
            _Skill.KEYWORD_PATTERN -- Target character
        ),
        SkillType = _Skill.TARGET_TYPES.CHARACTER
    })
end)