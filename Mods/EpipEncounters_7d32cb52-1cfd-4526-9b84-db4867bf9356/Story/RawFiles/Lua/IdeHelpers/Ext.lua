--- @diagnostic disable

--- Special global value that contains the current mod UUID during load
--- @type FixedString
ModuleUUID = "UUID"

--- Using a DB like a function will allow inserting new values into the database (ex. `Osi.DB_IsPlayer("02a77f1f-872b-49ca-91ab-32098c443beb")`  
--- @overload fun(...:string|number|nil)
--- @class OsiDatabase
local OsiDatabase = {}
--- Databases can be read using the Get method. The method checks its parameters against the database and only returns rows that match the query.  
--- The number of parameters passed to Get must be equivalent to the number of columns in the target database.  
--- Each parameter defines an (optional) filter on the corresponding column.  
--- If the parameter is nil, the column is not filtered (equivalent to passing _ in Osiris). If the parameter is not nil, only rows with matching values will be returned.
--- @vararg string|number|nil
--- @return table<integer,table<integer,string|number>>
function OsiDatabase:Get(...) end
--- The Delete method can be used to delete rows from databases.  
--- The number of parameters passed to Delete must be equivalent to the number of columns in the target database.  
--- Each parameter defines an (optional) filter on the corresponding column.  
--- If the parameter is nil, the column is not filtered (equivalent to passing _ in Osiris). If the parameter is not nil, only rows with matching values will be deleted. 
--- @vararg string|number|nil
function OsiDatabase:Delete(...) end

--- @class Osi
--- @field DB_IsPlayer OsiDatabase|fun(GUID:string) All player characters
--- @field DB_Origins OsiDatabase|fun(GUID:string) All origin characters
--- @field DB_Avatars OsiDatabase|fun(GUID:string) All player characters that were created in character creation, or that have an `AVATAR` tag
--- @field DB_CombatObjects OsiDatabase|fun(GUID:string, combatID:integer) All objects in combat
--- @field DB_CombatCharacters OsiDatabase|fun(GUID:string, combatID:integer) All characters in combat
--- @field DB_Dialogs OsiDatabase|fun(GUID:string, dialog:string)|fun(GUID1:string, GUID2:string, dialog:string)|fun(GUID1:string, GUID2:string, GUID3:string, dialog:string)|fun(GUID1:string, GUID2:string, GUID3:string, GUID4:string, dialog:string) All registered dialogs for objects, the most common being the version with a single character
Osi = {}

--- @alias CString string
--- @alias ComponentHandle number
--- @alias EntityHandle number
--- @alias FixedString string
--- @alias Guid string
--- @alias IggyInvokeDataValue any
--- @alias NetId number
--- @alias Path string
--- @alias STDString string
--- @alias STDWString string
--- @alias TemplateHandle number
--- @alias UserId number
--- @alias bool boolean
--- @alias double number
--- @alias float number
--- @alias int16 number
--- @alias int32 number
--- @alias int64 number
--- @alias int8 number
--- @alias uint16 number
--- @alias uint32 number
--- @alias uint64 number
--- @alias uint8 number
--- @alias Version int32[]
--- @alias ivec2 int32[]
--- @alias mat3 float[]
--- @alias mat4 float[]
--- @alias vec2 float[]
--- @alias vec3 float[]
--- @alias vec4 float[]


--- @alias AIFlags string|"StatusIsSecondary"|"CanNotTargetFrozen"|"CanNotUse"|"IgnoreSelf"|"IgnoreDebuff"|"IgnoreBuff"|"IgnoreControl"
--- @alias ActionDataType string|"DestroyParameters"|"StoryUse"|"CreatePuddle"|"Book"|"UseSkill"|"SkillBook"|"Sit"|"Identify"|"Recipe"|"Equip"|"DisarmTrap"|"KickstarterMessageInABottle"|"Ladder"|"SpawnCharacter"|"Consume"|"Repair"|"Constrain"|"StoryUseInInventory"|"Destroy"|"PlaySound"|"ShowStoryElementUI"|"Sticky"|"Craft"|"Lying"|"Door"|"Pyramid"|"StoryUseInInventoryOnly"|"OpenClose"|"Teleport"|"Lockpick"|"Unknown"|"CreateSurface"
--- @alias AiActionStep string|"CollectPossibleActions"|"CalculateFutureScores"|"CalculateSkills"|"CalculateItems"|"SortActions"|"ScoreActionsBehavior"|"ScoreActions"|"Init"|"CalculateStandardAttack"|"ScoreActionsFallback"|"CalculatePositionScores"|"ReevaluateActions"|"ScoreActionsAPSaving"
--- @alias AiActionType string|"StandardAttack"|"FallbackCommand"|"Skill"|"Consume"|"None"
--- @alias AiModifier string|"MULTIPLIER_HEAL_SELF_POS"|"MULTIPLIER_BOOST_NEUTRAL_NEG"|"MULTIPLIER_BONUS_WEAPON_BOOST"|"MULTIPLIER_SURFACE_STATUS_ON_MOVE"|"MULTIPLIER_BLIND"|"MULTIPLIER_CONTACT_BOOST"|"MULTIPLIER_DOT_NEUTRAL_NEG"|"MULTIPLIER_TARGET_MY_HOSTILE"|"MULTIPLIER_DAMAGE_ON_MOVE"|"MULTIPLIER_DEATH_RESIST"|"MULTIPLIER_COMBO_SCORE_POSITIONING"|"MULTIPLIER_HOT_ALLY_POS"|"MULTIPLIER_CONTROL_NEUTRAL_POS"|"MULTIPLIER_ENDPOS_NOT_IN_AIHINT"|"MULTIPLIER_RESISTANCE"|"MULTIPLIER_HEAL_ENEMY_POS"|"MULTIPLIER_ARMOR_SELF_NEG"|"MAX_SCORE_ON_NEUTRAL"|"MULTIPLIER_KILL_ALLY_SUMMON"|"MULTIPLIER_MAIN_ATTRIB"|"TURNS_REPLACEMENT_INFINITE"|"MULTIPLIER_HOT_ENEMY_NEG"|"MULTIPLIER_LOW_ITEM_AMOUNT_MULTIPLIER"|"MULTIPLIER_TARGET_AGGRO_MARKED"|"MULTIPLIER_INCAPACITATE"|"SKILL_TELEPORT_MINIMUM_DISTANCE"|"MULTIPLIER_DAMAGE_SELF_NEG"|"MULTIPLIER_BOOST_SELF_POS"|"MULTIPLIER_ENDPOS_ENEMIES_NEARBY"|"FALLBACK_WANTED_ENEMY_DISTANCE"|"MULTIPLIER_DISARMED"|"MULTIPLIER_HEAL_ALLY_POS"|"MULTIPLIER_DOT_ALLY_NEG"|"MULTIPLIER_ARMOR_ENEMY_NEG"|"MULTIPLIER_EXPLOSION_DISTANCE_MIN"|"MULTIPLIER_STATUS_REMOVE"|"MULTIPLIER_CRITICAL"|"MULTIPLIER_POSITION_LEAVE"|"SCORE_MOD"|"MULTIPLIER_HOT_NEUTRAL_NEG"|"MULTIPLIER_TARGET_INCAPACITATED"|"DANGEROUS_ITEM_NEARBY"|"MULTIPLIER_REMOVE_MAGIC_ARMOR"|"MULTIPLIER_AP_COSTBOOST"|"MULTIPLIER_COMBO_SCORE_INTERACTION"|"MULTIPLIER_DAMAGE_ENEMY_NEG"|"MULTIPLIER_BOOST_ENEMY_POS"|"MULTIPLIER_SCORE_ON_NEUTRAL"|"MULTIPLIER_KILL_ENEMY"|"MULTIPLIER_FEAR"|"UNSTABLE_BOMB_RADIUS"|"MULTIPLIER_HEAL_NEUTRAL_POS"|"MULTIPLIER_ARMOR_ALLY_NEG"|"MULTIPLIER_STATUS_OVERWRITE"|"MULTIPLIER_INVISIBLE"|"MULTIPLIER_MUTE"|"ENABLE_SAVING_ACTION_POINTS"|"CHARMED_MAX_CONSUMABLES_PER_TURN"|"MULTIPLIER_DOT_SELF_POS"|"MULTIPLIER_CONTROL_SELF_NEG"|"MULTIPLIER_SOURCE_COST_MULTIPLIER"|"MULTIPLIER_TARGET_PREFERRED"|"MULTIPLIER_RESURRECT"|"BUFF_DIST_MAX"|"MULTIPLIER_DAMAGE_ALLY_NEG"|"MULTIPLIER_HOT_ALLY_NEG"|"MULTIPLIER_BOOST_ALLY_POS"|"MULTIPLIER_TARGET_HOSTILE_COUNT_TWO_OR_"|"MULTIPLIER_SCORE_OUT_OF_COMBAT"|"MULTIPLIER_SURFACE_REMOVE"|"MULTIPLIER_AP_RECOVERY"|"BUFF_DIST_MIN"|"MULTIPLIER_DOT_ENEMY_POS"|"MULTIPLIER_ARMOR_NEUTRAL_NEG"|"MOVESKILL_ITEM_AP_DIFF_REQUIREMENT"|"MAX_HEAL_MULTIPLIER"|"MULTIPLIER_DECAYING_TOUCH"|"MULTIPLIER_GROUNDED"|"MULTIPLIER_MAGICAL_SULFUR"|"MULTIPLIER_CONTROL_ENEMY_NEG"|"MULTIPLIER_ENDPOS_ALLIES_NEARBY"|"MULTIPLIER_KNOCKDOWN"|"MULTIPLIER_DESTROY_INTERESTING_ITEM"|"MULTIPLIER_DAMAGE_NEUTRAL_NEG"|"MULTIPLIER_BOOST_NEUTRAL_POS"|"MULTIPLIER_VITALITYBOOST"|"MULTIPLIER_WINDWALKER"|"MULTIPLIER_SECONDARY_ATTRIB"|"MULTIPLIER_DOT_NEUTRAL_POS"|"MULTIPLIER_HOT_SELF_POS"|"MULTIPLIER_ACTION_COST_MULTIPLIER"|"MULTIPLIER_TARGET_MY_ENEMY"|"MULTIPLIER_ACTIVE_DEFENSE"|"MULTIPLIER_ACC_BOOST"|"MULTIPLIER_MAGICAL_SULFUR_CURRENTLY_DAM"|"AVENGE_ME_VITALITY_LEVEL"|"MULTIPLIER_CONTROL_ALLY_NEG"|"MULTIPLIER_INVISIBLE_MOVEMENT_COST_MULT"|"MULTIPLIER_ENDPOS_FLANKED"|"FALLBACK_ALLIES_NEARBY"|"MULTIPLIER_SOURCE_POINT"|"MULTIPLIER_HEAL_SELF_NEG"|"MULTIPLIER_ARMOR_SELF_POS"|"MULTIPLIER_TARGET_HOSTILE_COUNT_ONE"|"MULTIPLIER_KILL_ENEMY_SUMMON"|"MULTIPLIER_KILL_ALLY"|"MIN_TURNS_SCORE_EXISTING_STATUS"|"TARGET_WEAK_ALLY"|"MULTIPLIER_HOT_ENEMY_POS"|"MULTIPLIER_TARGET_SUMMON"|"MULTIPLIER_ENDPOS_NOT_IN_DANGEROUS_SURF"|"MULTIPLIER_SOURCE_MUTE"|"SKILL_JUMP_MINIMUM_DISTANCE"|"MULTIPLIER_DAMAGE_SELF_POS"|"MULTIPLIER_DOT_SELF_NEG"|"MULTIPLIER_CONTROL_NEUTRAL_NEG"|"MULTIPLIER_ENDPOS_NOT_IN_SMOKE"|"MULTIPLIER_STATUS_CANCEL_SLEEPING"|"MULTIPLIER_ADD_ARMOR"|"MULTIPLIER_HEAL_ENEMY_NEG"|"MULTIPLIER_ARMOR_ENEMY_POS"|"MULTIPLIER_FREE_ACTION"|"SURFACE_DAMAGE_MAX_TURNS"|"MULTIPLIER_AP_BOOST"|"MULTIPLIER_PUDDLE_RADIUS"|"MULTIPLIER_HOT_NEUTRAL_POS"|"MULTIPLIER_TARGET_IN_SIGHT"|"MULTIPLIER_DAMAGEBOOST"|"MULTIPLIER_ADD_MAGIC_ARMOR"|"ENABLE_ACTIVE_DEFENSE_OFFENSIVE_USE"|"MULTIPLIER_SHIELD_BLOCK"|"MULTIPLIER_DAMAGE_ENEMY_POS"|"MULTIPLIER_BOOST_SELF_NEG"|"MULTIPLIER_MOVEMENT_COST_MULTPLIER"|"MOVESKILL_AP_DIFF_REQUIREMENT"|"MULTIPLIER_CHARMED"|"MULTIPLIER_HEAL_ALLY_NEG"|"MULTIPLIER_ARMOR_ALLY_POS"|"MULTIPLIER_CANNOT_EXECUTE_THIS_TURN"|"MULTIPLIER_STATUS_FAILED"|"MULTIPLIER_SPARK"|"MULTIPLIER_DEFLECT_PROJECTILES"|"MULTIPLIER_HOT_SELF_NEG"|"MULTIPLIER_CONTROL_SELF_POS"|"MULTIPLIER_TARGET_KNOCKED_DOWN"|"MULTIPLIER_ENDPOS_TURNED_INVISIBLE"|"MULTIPLIER_DODGE_BOOST"|"MULTIPLIER_DAMAGE_ALLY_POS"|"MULTIPLIER_BOOST_ENEMY_NEG"|"FALLBACK_ENEMIES_NEARBY"|"MULTIPLIER_SCORE_ON_ALLY"|"MULTIPLIER_STATUS_CANCEL_INVISIBILITY"|"MULTIPLIER_SP_COSTBOOST"|"MULTIPLIER_HEAL_NEUTRAL_NEG"|"MULTIPLIER_ARMOR_NEUTRAL_POS"|"MULTIPLIER_LOSE_CONTROL"|"MULTIPLIER_SHACKLES_OF_PAIN"|"MULTIPLIER_SUMMON_PATH_INFLUENCES"|"MULTIPLIER_REFLECT_DAMAGE"|"AVENGE_ME_RADIUS"|"MULTIPLIER_CONTROL_ENEMY_POS"|"MULTIPLIER_TARGET_UNPREFERRED"|"MULTIPLIER_HEAL_SHARING"|"MULTIPLIER_POS_SECONDARY_SURFACE"|"MULTIPLIER_DAMAGE_NEUTRAL_POS"|"MULTIPLIER_DOT_ALLY_POS"|"MULTIPLIER_BOOST_ALLY_NEG"|"MAX_HEAL_SELF_MULTIPLIER"|"MULTIPLIER_REMOVE_ARMOR"|"MULTIPLIER_MOVEMENT_BOOST"|"MULTIPLIER_DOT_ENEMY_NEG"|"MULTIPLIER_COOLDOWN_MULTIPLIER"|"MULTIPLIER_HIGH_ITEM_AMOUNT_MULTIPLIER"|"ENDPOS_NEARBY_DISTANCE"|"MULTIPLIER_GUARDIAN_ANGEL"|"MULTIPLIER_AP_MAX"|"MULTIPLIER_FIRST_ACTION_BUFF"|"MULTIPLIER_CONTROL_ALLY_POS"|"MULTIPLIER_ENDPOS_STENCH"|"MULTIPLIER_ENDPOS_HEIGHT_DIFFERENCE"|"MULTIPLIER_ARMORBOOST"|"UNSTABLE_BOMB_NEARBY"
--- @alias AiScoreReasonFlags string|"TooFar"|"NoMovement"|"ResurrectByCharmedPlayer"|"TargetBlocked"|"RemoveMadnessSelf"|"BreakInvisibility"|"CannotTargetFrozen"|"BreakInvisibilityForNoEnemies"|"StupidInvisibility"|"ResurrectOutOfCombat"|"MustStayInAiHint"|"KillSelf"|"ScoreTooLow"|"TooComplex"|"MoveSkillCannotExecute"
--- @alias CauseType string|"None"|"GM"|"SurfaceMove"|"SurfaceCreate"|"SurfaceStatus"|"StatusEnter"|"StatusTick"|"Offhand"|"Attack"
--- @alias CraftingStationType string|"Oven"|"None"|"Misc2"|"Wetstone"|"Well"|"BoilingPot"|"SpinningWheel"|"Misc4"|"Cauldron"|"Anvil"|"Beehive"|"Misc1"|"Misc3"
--- @alias ESurfaceFlag string|"SurfaceExclude"|"Sulfurium"|"CloudBlessed"|"CloudCursed"|"CloudPurified"|"IrreplaceableCloud"|"SomeDecay"|"Cursed"|"Irreplaceable"|"CloudSurfaceBlock"|"Lava"|"Source"|"Water"|"FireCloud"|"WaterCloud"|"Blessed"|"BloodCloud"|"PoisonCloud"|"Fire"|"SmokeCloud"|"ExplosionCloud"|"CloudElectrified"|"FrostCloud"|"Blood"|"Purified"|"Web"|"Electrified"|"HasInteractableObject"|"Poison"|"HasItem"|"Deathfog"|"ShockwaveCloud"|"Oil"|"Deepwater"|"ElectrifiedDecay"|"MovementBlock"|"ProjectileBlock"|"HasCharacter"|"GroundSurfaceBlock"|"Occupied"|"Frozen"
--- @alias ExtComponentType string|"ServerCharacter"|"ServerProjectile"|"ServerItem"|"ServerCustomStatDefinition"|"Max"|"Combat"|"ClientCharacter"|"ClientItem"
--- @alias GameActionType string|"GameObjectMoveAction"|"StatusDomeAction"|"RainAction"|"StormAction"|"WallAction"|"TornadoAction"|"PathAction"
--- @alias GameObjectTemplateFlags string|"IsCustom"
--- @alias HealEffect string|"ResistDeath"|"Sitting"|"Behavior"|"Unknown4"|"Heal"|"Lifesteal"|"Script"|"NegativeDamage"|"None"|"Unknown9"|"HealSharing"|"HealSharingReflected"|"Surface"|"Necromantic"
--- @alias IngredientTransformType string|"Transform"|"Consume"|"None"|"Poison"|"Boost"
--- @alias IngredientType string|"Category"|"None"|"Object"|"Property"
--- @alias InputModifier string|"Ctrl"|"Gui"|"Alt"|"Shift"
--- @alias InputRawType string|"pagedown"|"k"|"f16"|"left"|"kp_1"|"rshift"|"controller_x"|"semicolon"|"num0"|"v"|"controller_y"|"item11"|"leftbracket"|"b"|"f7"|"guide"|"leftstick"|"backslash"|"m"|"f18"|"kp_3"|"rgui"|"rightstick"|"item2"|"insert"|"rightbracket"|"num2"|"x"|"leftshoulder"|"tab"|"apostrophe"|"d"|"f9"|"rightshoulder"|"o"|"f20"|"kp_divide"|"kp_5"|"left2"|"dpad_down"|"item4"|"pageup"|"num4"|"z"|"up"|"kp_multiply"|"dpad_left"|"f"|"f11"|"kp_minus"|"lctrl"|"dpad_up"|"dpad_right"|"enter"|"q"|"f22"|"kp_enter"|"kp_7"|"right2"|"touch_tap"|"item6"|"num6"|"f2"|"kp_period"|"touch_hold"|"h"|"f13"|"lalt"|"motion_xneg"|"touch_pinch_in"|"s"|"f24"|"kp_9"|"x2"|"motion_ypos"|"touch_pinch_out"|"item8"|"dash"|"num8"|"f4"|"motion_xpos"|"touch_rotate"|"j"|"f15"|"right"|"rctrl"|"motion_yneg"|"touch_flick"|"space"|"u"|"down"|"wheel_xpos"|"touch_press"|"item10"|"slash"|"a"|"f6"|"wheel_xneg"|"back"|"end"|"l"|"f17"|"kp_2"|"ralt"|"wheel_ypos"|"item1"|"pause"|"num1"|"w"|"wheel_yneg"|"c"|"f8"|"leftstick_xneg"|"start"|"n"|"f19"|"kp_4"|"mode"|"leftstick_ypos"|"item3"|"home"|"num3"|"y"|"kp_plus"|"leftstick_xpos"|"tilde"|"e"|"f10"|"leftstick_yneg"|"p"|"f21"|"kp_6"|"middle"|"rightstick_xneg"|"item5"|"num5"|"f1"|"rightstick_ypos"|"g"|"f12"|"numlock"|"lshift"|"rightstick_xpos"|"escape"|"backspace"|"equals"|"r"|"f23"|"kp_8"|"x1"|"rightstick_yneg"|"item7"|"capslock"|"comma"|"num7"|"f3"|"lefttrigger"|"printscreen"|"i"|"f14"|"lgui"|"righttrigger"|"scrolllock"|"t"|"kp_0"|"motion"|"controller_a"|"item9"|"delete_key"|"dot"|"num9"|"f5"|"controller_b"
--- @alias InputState string|"Pressed"|"Released"
--- @alias InputType string|"AcceleratedRepeat"|"Repeat"|"Release"|"Hold"|"ValueChange"|"Press"|"Unknown"
--- @alias ItemDataRarity string|"Epic"|"Rare"|"Unique"|"Common"|"Divine"|"Uncommon"|"Legendary"|"Sentinel"
--- @alias LuaTypeId string|"Any"|"Set"|"Boolean"|"Float"|"Tuple"|"Function"|"String"|"Array"|"Void"|"Enumeration"|"Nullable"|"Map"|"Integer"|"Object"|"Module"|"Unknown"
--- @alias MultiEffectHandlerFlags string|"Beam"|"Detach"|"FaceSource"|"FollowScale"|"EffectAttached"|"KeepRot"
--- @alias NetMessage string|"NETMSG_CHARACTER_ASSIGN"|"NETMSG_CHARACTER_SET_STORY_NAME"|"NETMSG_PROJECTILE_EXPLOSION"|"NETMSG_ALIGNMENT_CREATE"|"NETMSG_GM_SPAWN"|"NETMSG_GM_REQUEST_ROLL"|"NETMSG_GM_UI_OPEN_STICKY"|"NETMSG_PARTY_NPC_DATA"|"NETMSG_CHARACTER_ANIMATION_SET_UPDATE"|"NETMSG_AITEST_UPDATE"|"NETMSG_CHARACTER_BOOST"|"NETMSG_CHARACTER_ITEM_USED"|"NETMSG_INVENTORY_CREATE"|"NETMSG_SCREEN_FADE_DONE"|"NETMSG_OPEN_WAYPOINT_UI_MESSAGE"|"NETMSG_DIALOG_HISTORY_MESSAGE"|"NETMSG_GM_HEAL"|"NETMSG_GM_CAMPAIGN_SAVE"|"NETMSG_LEVEL_LOAD"|"NETMSG_JOURNALDIALOGLOG_UPDATE"|"NETMSG_ACHIEVEMENT_PROGRESS_MESSAGE"|"NETMSG_TRIGGER_CREATE"|"NETMSG_HOST_WELCOME"|"NETMSG_CHARACTER_DESTROY"|"NETMSG_SHROUD_UPDATE"|"NETMSG_ITEM_CONFIRMATION"|"NETMSG_PEER_ACTIVATE"|"NETMSG_MARKER_UI_CREATE"|"NETMSG_GM_ROLL"|"NETMSG_GM_SET_START_POINT"|"NETMSG_GM_ITEM_USE"|"NETMSG_ITEM_ENGRAVE"|"NETMSG_SET_CHARACTER_ARCHETYPE"|"NETMSG_MULTIPLE_TARGET_OPERATION"|"NETMSG_DLC_UPDATE"|"NETMSG_PLAYER_CONNECT"|"NETMSG_CHARACTER_UPGRADE"|"NETMSG_CHARACTER_CORPSE_LOOTABLE"|"NETMSG_TURNBASED_SETTEAM"|"NETMSG_SKILL_ACTIVATE"|"NETMSG_JOURNALRECIPE_UPDATE"|"NETMSG_PARTYFORMATION"|"NETMSG_GM_HOST"|"NETMSG_GM_EDIT_ITEM"|"NETMSG_GM_SET_REPUTATION"|"NETMSG_DIALOG_LISTEN"|"NETMSG_SURFACE_META"|"NETMSG_COMBAT_TURN_TIMER"|"NETMSG_PLAYMOVIE"|"NETMSG_OPEN_KICKSTARTER_BOOK_UI_MESSAGE"|"NETMSG_GM_TOGGLE_VIGNETTE"|"NETMSG_GM_DAMAGE"|"NETMSG_CAMERA_TARGET"|"NETMSG_CHAT"|"NETMSG_SAVEGAME_LOAD_FAIL"|"NETMSG_LOBBY_SURRENDER"|"NETMSG_CHARACTER_ACTIVATE"|"NETMSG_CHARACTER_DIALOG"|"NETMSG_ITEM_TRANSFORM"|"NETMSG_INVENTORY_DESTROY"|"NETMSG_OVERHEADTEXT"|"NETMSG_DIALOG_ANSWER_HIGHLIGHT_MESSAGE"|"NETMSG_GM_CHANGE_LEVEL"|"NETMSG_GM_REQUEST_CAMPAIGN_DATA"|"NETMSG_SAVEGAME"|"NETMSG_MODULES_DOWNLOAD"|"NETMSG_CAMERA_SPLINE"|"NETMSG_CUSTOM_STATS_UPDATE"|"NETMSG_CHARACTER_CUSTOMIZATION"|"NETMSG_PARTYORDER"|"NETMSG_TURNBASED_STOP"|"NETMSG_NET_ENTITY_DESTROY"|"NETMSG_QUEST_STATE"|"NETMSG_PARTY_CONSUMED_ITEMS"|"NETMSG_GM_POSSESS"|"NETMSG_GM_REQUEST_CHARACTERS_REROLL"|"NETMSG_SAVEGAMEHANDSHAKE"|"NETMSG_LEVEL_START"|"NETMSG_PAUSE"|"NETMSG_GIVE_REWARD"|"NETMSG_CLIENT_ACCEPT"|"NETMSG_CHARACTER_ACTION_REQUEST_RESULT"|"NETMSG_UPDATE_COMBAT_GROUP_INFO"|"NETMSG_ITEM_DEACTIVATE"|"NETMSG_SKILL_UPDATE"|"NETMSG_UI_QUESTSELECTED"|"NETMSG_GM_ADD_EXPERIENCE"|"NETMSG_GM_SET_STATUS"|"NETMSG_NOTIFY_COMBINE_FAILED_MESSAGE"|"NETMSG_OPEN_CRAFT_UI_MESSAGE"|"NETMSG_CRAFT_RESULT"|"NETMSG_UNPAUSE"|"NETMSG_VOICEDATA"|"NETMSG_CHARACTER_POSITION"|"NETMSG_INVENTORY_VIEW_DESTROY"|"NETMSG_EFFECT_DESTROY"|"NETMSG_GM_DELETE"|"NETMSG_GM_SET_ATMOSPHERE"|"NETMSG_TRADE_ACTION"|"NETMSG_LOBBY_USERUPDATE"|"NETMSG_LOAD_GAME_WITH_ADDONS_FAIL"|"NETMSG_CLIENT_GAME_SETTINGS"|"NETMSG_CHARACTER_ACTION"|"NETMSG_CHARACTER_SELECTEDSKILLSET"|"NETMSG_CHARACTER_TELEPORT"|"NETMSG_GAMECONTROL_UPDATE_C2S"|"NETMSG_ALIGNMENT_SET"|"NETMSG_PARTY_SPLIT_NOTIFICATION"|"NETMSG_GM_PASS_ROLL"|"NETMSG_REQUESTAUTOSAVE"|"NETMSG_LEVEL_SWAP_COMPLETE"|"NETMSG_TELEPORT_ACK"|"NETMSG_PARTY_CREATE"|"NETMSG_SECRET_REGION_UNLOCK"|"NETMSG_EGG_CREATE"|"NETMSG_TURNBASED_FLEECOMBATRESULT"|"NETMSG_CLOSE_CUSTOM_BOOK_UI_MESSAGE"|"NETMSG_CLOSE_UI_MESSAGE"|"NETMSG_GM_TRAVEL_TO_DESTINATION"|"NETMSG_GM_SYNC_SCENES"|"NETMSG_LEVEL_LOADED"|"NETMSG_TELEPORT_WAYPOINT"|"NETMSG_TRIGGER_DESTROY"|"NETMSG_HOST_REFUSE"|"NETMSG_CHARACTER_STEERING"|"NETMSG_ITEM_CREATE"|"NETMSG_INVENTORY_ITEM_UPDATE"|"NETMSG_PEER_DEACTIVATE"|"NETMSG_MARKER_UI_UPDATE"|"NETMSG_GM_TOGGLE_PEACE"|"NETMSG_GM_CHANGE_SCENE_NAME"|"NETMSG_STORY_ELEMENT_UI"|"NETMSG_MUTATORS_ENABLED"|"NETMSG_HACK_TELL_BUILDNAME"|"NETMSG_PLAYER_ACCEPT"|"NETMSG_CHARACTER_OFFSTAGE"|"NETMSG_SKILL_REMOVED"|"NETMSG_ALIGNMENT_RELATION"|"NETMSG_STOP_FOLLOW"|"NETMSG_DIALOG_STATE_MESSAGE"|"NETMSG_GM_SET_INTERESTED_CHARACTER"|"NETMSG_GM_SYNC_NOTES"|"NETMSG_CHARACTERCREATION_READY"|"NETMSG_MUSIC_STATE"|"NETMSG_GAMEACTION"|"NETMSG_ITEM_MOVE_TO_WORLD"|"NETMSG_PLAY_HUD_SOUND"|"NETMSG_GM_EXPORT"|"NETMSG_GM_SYNC_OVERVIEW_MAPS"|"NETMSG_CAMERA_MODE"|"NETMSG_ACHIEVEMENT_UNLOCKED_MESSAGE"|"NETMSG_LOBBY_SPECTATORUPDATE"|"NETMSG_LOBBY_RETURN"|"NETMSG_CHARACTER_CONTROL"|"NETMSG_CHARACTER_USE_AP"|"NETMSG_ITEM_OFFSTAGE"|"NETMSG_PROJECTILE_CREATE"|"NETMSG_COMBATLOG"|"NETMSG_GM_POSITION_SYNC"|"NETMSG_GM_EDIT_CHARACTER"|"NETMSG_SESSION_LOAD"|"NETMSG_READYCHECK"|"NETMSG_CUSTOM_STATS_DEFINITION_UPDATE"|"NETMSG_CHARACTER_LOOT_CORPSE"|"NETMSG_PARTYUPDATE"|"NETMSG_TURNBASED_ROUND"|"NETMSG_OPEN_MESSAGE_BOX_MESSAGE"|"NETMSG_SECRET_UPDATE"|"NETMSG_DIALOG_ANSWER_MESSAGE"|"NETMSG_GM_CHANGE_NAME"|"NETMSG_DIFFICULTY_CHANGED"|"NETMSG_RUNECRAFT"|"NETMSG_CHARACTER_COMPANION_CUSTOMIZATION"|"NETMSG_SHOW_ERROR"|"NETMSG_CLIENT_JOINED"|"NETMSG_PLAYER_DISCONNECT"|"NETMSG_ITEM_DESTINATION"|"NETMSG_ITEM_STATUS_LIFETIME"|"NETMSG_INVENTORY_VIEW_UPDATE_PARENTS"|"NETMSG_SKILL_LEARN"|"NETMSG_OPEN_CUSTOM_BOOK_UI_MESSAGE"|"NETMSG_MYSTERY_STATE"|"NETMSG_GM_REORDER_ELEMENTS"|"NETMSG_GM_REMOVE_STATUS"|"NETMSG_UNLOCK_ITEM"|"NETMSG_UPDATE_CHARACTER_TAGS"|"NETMSG_SKIPMOVIE_RESULT"|"NETMSG_CHARACTER_SKILLBAR"|"NETMSG_TURNBASED_SUMMONS"|"NETMSG_FORCE_SHEATH"|"NETMSG_GM_ITEM_CHANGE"|"NETMSG_GM_INVENTORY_OPERATION"|"NETMSG_CAMERA_ACTIVATE"|"NETMSG_LOBBY_COMMAND"|"NETMSG_CHARACTER_STATUS"|"NETMSG_CHARACTER_IN_DIALOG"|"NETMSG_ITEM_ACTION"|"NETMSG_ALIGNMENT_CLEAR"|"NETMSG_QUEST_CATEGORY_UPDATE"|"NETMSG_GM_TOGGLE_OVERVIEWMAP"|"NETMSG_GM_REMOVE_ROLL"|"NETMSG_GM_ASSETS_PENDING_SYNCS_INFO"|"NETMSG_MODULE_LOAD"|"NETMSG_SHOW_TUTORIAL_MESSAGE"|"NETMSG_PARTYCREATEGROUP"|"NETMSG_CHARACTER_CONFIRMATION"|"NETMSG_PARTY_DESTROY"|"NETMSG_ITEM_MOVED_INFORM"|"NETMSG_EGG_DESTROY"|"NETMSG_JOURNAL_RESET"|"NETMSG_GM_SYNC_ASSETS"|"NETMSG_GM_CONFIGURE_CAMPAIGN"|"NETMSG_LOAD_START"|"NETMSG_CHARACTER_CHANGE_OWNERSHIP"|"NETMSG_TRIGGER_UPDATE"|"NETMSG_CUSTOM_STATS_CREATE"|"NETMSG_HOST_LEFT"|"NETMSG_CHARACTER_STATS_UPDATE"|"NETMSG_ITEM_DESTROY"|"NETMSG_NET_ENTITY_CREATE"|"NETMSG_SKILL_CREATE"|"NETMSG_QUEST_TRACK"|"NETMSG_REGISTER_WAYPOINT"|"NETMSG_GM_MAKE_TRADER"|"NETMSG_ATMOSPHERE_OVERRIDE"|"NETMSG_UNLOCK_WAYPOINT"|"NETMSG_CUSTOM_STATS_DEFINITION_REMOVE"|"NETMSG_SCRIPT_EXTENDER"|"NETMSG_PLAYER_JOINED"|"NETMSG_COMBAT_COMPONENT_SYNC"|"NETMSG_EFFECT_CREATE"|"NETMSG_NOTIFICATION"|"NETMSG_GM_REMOVE_EXPORTED"|"NETMSG_GM_MAKE_FOLLOWER"|"NETMSG_SERVER_NOTIFICATION"|"NETMSG_MUSIC_EVENT"|"NETMSG_CHARACTER_CREATE"|"NETMSG_CHARACTER_DEACTIVATE"|"NETMSG_INVENTORY_VIEW_CREATE"|"NETMSG_INVENTORY_VIEW_UPDATE_ITEMS"|"NETMSG_CHARACTER_ERROR"|"NETMSG_GM_TOGGLE_PAUSE"|"NETMSG_GM_CLEAR_STATUSES"|"NETMSG_GAMETIME_SYNC"|"NETMSG_UPDATE_ITEM_TAGS"|"NETMSG_LOAD_GAME_WITH_ADDONS"|"NETMSG_CHARACTER_AOO"|"NETMSG_CHARACTER_TRANSFORM"|"NETMSG_ITEM_MOVE_UUID"|"NETMSG_GAMECONTROL_UPDATE_S2C"|"NETMSG_SCREEN_FADE"|"NETMSG_SHOW_ENTER_REGION_UI_MESSAGE"|"NETMSG_PARTY_UNLOCKED_RECIPE"|"NETMSG_GM_TELEPORT"|"NETMSG_SESSION_LOADED"|"NETMSG_LEVEL_INSTANTIATE_SWAP"|"NETMSG_DIPLOMACY"|"NETMSG_PARTYUSER"|"NETMSG_SHROUD_FRUSTUM_UPDATE"|"NETMSG_TURNBASED_ORDER"|"NETMSG_TROPHY_UPDATE"|"NETMSG_DIALOG_ACTORLEAVES_MESSAGE"|"NETMSG_GM_VIGNETTE_ANSWER"|"NETMSG_GM_DUPLICATE"|"NETMSG_SERVER_COMMAND"|"NETMSG_DISCOVERED_PORTALS"|"NETMSG_STORY_VERSION"|"NETMSG_CLIENT_LEFT"|"NETMSG_CHARACTER_POSITION_SYNC"|"NETMSG_ITEM_UPDATE"|"NETMSG_INVENTORY_VIEW_SORT"|"NETMSG_SKILL_UNLEARN"|"NETMSG_MYSTERY_UPDATE"|"NETMSG_GM_CREATE_ITEM"|"NETMSG_GM_SOUND_PLAYBACK"|"NETMSG_CHARACTERCREATION_NOT_READY"|"NETMSG_TELEPORT_PYRAMID"|"NETMSG_GM_JOURNAL_UPDATE"|"NETMSG_SURFACE_CREATE"|"NETMSG_CHARACTER_STATUS_LIFETIME"|"NETMSG_CHARACTER_PICKPOCKET"|"NETMSG_GAMECONTROL_PRICETAG"|"NETMSG_PLAYSOUND"|"NETMSG_PARTY_MERGE_NOTIFICATION"|"NETMSG_GM_DRAW_SURFACE"|"NETMSG_CAMERA_ROTATE"|"NETMSG_CHARACTERCREATION_DONE"|"NETMSG_LOBBY_STARTGAME"|"NETMSG_CUSTOM_STATS_DEFINITION_CREATE"|"NETMSG_CHARACTER_UPDATE"|"NETMSG_ITEM_USE_REMOTELY"|"NETMSG_ITEM_STATUS"|"NETMSG_CACHETEMPLATE"|"NETMSG_GM_TICK_ROLLS"|"NETMSG_GM_STOP_TRAVELING"|"NETMSG_MODULE_LOADED"|"NETMSG_REALTIME_MULTIPLAY"|"NETMSG_ARENA_RESULTS"|"NETMSG_CHARACTER_ACTION_DATA"|"NETMSG_PARTYGROUP"|"NETMSG_INVENTORY_CREATE_AND_OPEN"|"NETMSG_INVENTORY_LOCKSTATE_SYNC"|"NETMSG_TURNBASED_START"|"NETMSG_QUEST_UPDATE"|"NETMSG_GM_LOAD_CAMPAIGN"|"NETMSG_GM_CHANGE_SCENE_PATH"|"NETMSG_LEVEL_SWAP_READY"|"NETMSG_PING_BEACON"|"NETMSG_CLIENT_CONNECT"|"NETMSG_CHARACTER_LOCK_ABILITY"|"NETMSG_ITEM_ACTIVATE"|"NETMSG_SKILL_DESTROY"|"NETMSG_COMBATLOGITEMINTERACTION"|"NETMSG_CLOSED_MESSAGE_BOX_MESSAGE"|"NETMSG_QUEST_POSTPONE"|"NETMSG_DIALOG_NODE_MESSAGE"|"NETMSG_GM_GIVE_REWARD"|"NETMSG_CHANGE_COMBAT_FORMATION"|"NETMSG_LOCK_WAYPOINT"|"NETMSG_HOST_REFUSEPLAYER"|"NETMSG_PLAYER_LEFT"|"NETMSG_ITEM_MOVE_TO_INVENTORY"|"NETMSG_EFFECT_FORGET"|"NETMSG_GAMEOVER"|"NETMSG_FLAG_UPDATE"|"NETMSG_DIALOG_ACTORJOINS_MESSAGE"|"NETMSG_GM_SYNC_VIGNETTES"|"NETMSG_GM_DEACTIVATE"|"NETMSG_LOBBY_DATAUPDATE"|"NETMSG_LOBBY_CHARACTER_SELECT"
--- @alias ObjectHandleType string|"ClientParty"|"ClientSpectatorTrigger"|"ClientVignette"|"ServerSurfaceAction"|"Effect"|"ClientNote"|"ServerAtmosphereTrigger"|"ClientWallIntersection"|"ClientSurface"|"ClientCameraLockTrigger"|"ServerEgg"|"ServerSoundVolumeTrigger"|"ServerCharacter"|"ServerProjectile"|"ServerItem"|"ServerTeleportTrigger"|"ContainerComponent"|"ServerInventory"|"Texture"|"TextureRemoveData"|"ClientOverviewMap"|"ServerParty"|"Visual"|"ClientSecretRegionTrigger"|"ClientAtmosphereTrigger"|"ServerVignette"|"ServerNote"|"ServerEocPointTrigger"|"ServerAIHintAreaTrigger"|"IndexBuffer"|"Light"|"ClientInventoryView"|"ClientPointSoundTriggerDummy"|"VertexBuffer"|"ClientRegionTrigger"|"ServerCustomStatDefinitionComponent"|"VertexFormat"|"Reference"|"ServerInventoryView"|"SamplerState"|"ServerEventTrigger"|"ServerMusicVolumeTrigger"|"BlendState"|"SRV"|"Scene"|"ClientProjectile"|"Shader"|"DepthState"|"StructuredBuffer"|"Dummy"|"ClientPointTrigger"|"RasterizerState"|"UIObject"|"ClientAiSeederTrigger"|"ServerSecretRegionTrigger"|"Constant"|"Decal"|"Trigger"|"TerrainObject"|"ServerEocAreaTrigger"|"ConstantBuffer"|"GrannyFile"|"CombatComponent"|"ServerStatsAreaTrigger"|"CompiledShader"|"MeshProxy"|"GMJournalNode"|"ClientAlignmentData"|"ServerExplorationTrigger"|"TexturedFont"|"ClientEgg"|"ClientPointSoundTrigger"|"Text3D"|"SoundVolumeTrigger"|"ContainerElementComponent"|"ClientCharacter"|"ServerOverviewMap"|"ClientItem"|"ServerCrimeAreaTrigger"|"ClientCustomStatDefinitionComponent"|"ClientScenery"|"ClientWallConstruction"|"ExtenderClientVisual"|"ClientWallBase"|"ClientCullTrigger"|"ClientSoundVolumeTrigger"|"ClientInventory"|"ClientDummyGameObject"|"ClientAlignment"|"ServerStartTrigger"|"CustomStatsComponent"|"ClientSkill"|"ServerCrimeRegionTrigger"|"ServerRegionTrigger"|"Unknown"|"ClientGameAction"|"ClientStatus"
--- @alias PathRootType string|"Data"|"Root"|"MyDocuments"|"GameStorage"|"Public"
--- @alias PlayerUpgradeAttribute string|"Wits"|"Memory"|"Finesse"|"Strength"|"Intelligence"|"Constitution"
--- @alias RecipeCategory string|"Armour"|"Potions"|"Weapons"|"Grimoire"|"Grenades"|"Runes"|"Objects"|"Food"|"Common"|"Arrows"
--- @alias ResourceType string|"Effect"|"Texture"|"Script"|"Visual"|"MaterialSet"|"Animation"|"MeshProxy"|"AnimationBlueprint"|"AnimationSet"|"Material"|"Sound"|"VisualSet"|"Atmosphere"|"Physics"
--- @alias ScriptCheckType string|"Operator"|"Variable"
--- @alias ScriptOperatorType string|"Not"|"None"|"Or"|"And"
--- @alias ShroudType string|"Sight"|"Sneak"|"RegionMask"|"Shroud"
--- @alias SkillType string|"Wall"|"ProjectileStrike"|"Quake"|"Jump"|"Shout"|"Tornado"|"Rush"|"MultiStrike"|"Teleportation"|"Target"|"Summon"|"Projectile"|"Storm"|"Rain"|"SkillHeal"|"Dome"|"Path"|"Zone"
--- @alias StatAttributeFlags string|"WarmImmunity"|"BleedingImmunity"|"WetImmunity"|"InfectiousDiseasedImmunity"|"RegeneratingImmunity"|"BlindImmunity"|"EntangledContact"|"CursedImmunity"|"WeakImmunity"|"LoseDurabilityOnCharacterHit"|"SlowedImmunity"|"SlippingImmunity"|"DrunkImmunity"|"ProtectFromSummon"|"FreezeContact"|"BurnContact"|"Floating"|"CrippledImmunity"|"StunContact"|"PoisonContact"|"DisarmedImmunity"|"ChillContact"|"ShacklesOfPainImmunity"|"Torch"|"Unbreakable"|"Unrepairable"|"Unstorable"|"SleepingImmunity"|"Grounded"|"DeflectProjectiles"|"HastedImmunity"|"TauntedImmunity"|"DiseasedImmunity"|"AcidImmunity"|"PickpocketableWhenEquipped"|"Arrow"|"DecayingImmunity"|"EnragedImmunity"|"BlessedImmunity"|"InvisibilityImmunity"|"IgnoreClouds"|"KnockdownImmunity"|"MadnessImmunity"|"FreezeImmunity"|"SuffocatingImmunity"|"ChickenImmunity"|"BurnImmunity"|"IgnoreCursedOil"|"LootableWhenEquipped"|"StunImmunity"|"ShockedImmunity"|"PoisonImmunity"|"WebImmunity"|"CharmImmunity"|"PetrifiedImmunity"|"MagicalSulfur"|"FearImmunity"|"ClairvoyantImmunity"|"ThrownImmunity"|"MuteImmunity"|"ChilledImmunity"
--- @alias StatusHealType string|"None"|"Source"|"All"|"PhysicalArmor"|"Vitality"|"MagicArmor"|"AllArmor"
--- @alias StatusMaterialApplyFlags string|"ApplyOnBody"|"ApplyOnArmor"|"ApplyOnWeapon"|"ApplyOnWings"|"ApplyOnHorns"|"ApplyOnOverhead"
--- @alias StatusType string|"HEAL"|"KNOCKED_DOWN"|"CLEAN"|"SUMMONING"|"FLOATING"|"STORY_FROZEN"|"UNLOCK"|"EXTRA_TURN"|"SHACKLES_OF_PAIN"|"ACTIVE_DEFENSE"|"SNEAKING"|"CHALLENGE"|"SITTING"|"DECAYING_TOUCH"|"DAMAGE_ON_MOVE"|"SPARK"|"THROWN"|"UNHEALABLE"|"SPIRIT"|"DEMONIC_BARGAIN"|"DYING"|"SMELLY"|"CHANNELING"|"GUARDIAN_ANGEL"|"SPIRIT_VISION"|"COMBAT"|"UNSHEATHED"|"FORCE_MOVE"|"REMORSE"|"CLIMBING"|"DISARMED"|"INCAPACITATED"|"PLAY_DEAD"|"STANCE"|"SHACKLES_OF_PAIN_CASTER"|"INSURFACE"|"CONSTRAINED"|"HEALING"|"INFUSED"|"HIT"|"BLIND"|"DEACTIVATED"|"EFFECT"|"TUTORIAL_BED"|"TELEPORT_FALLING"|"CONSUME"|"OVERPOWER"|"EXPLODE"|"COMBUSTION"|"REPAIR"|"POLYMORPHED"|"BOOST"|"HEAL_SHARING"|"CHARMED"|"DRAIN"|"DAMAGE"|"LINGERING_WOUNDS"|"AOO"|"INVISIBLE"|"ROTATE"|"INFECTIOUS_DISEASED"|"ENCUMBERED"|"FEAR"|"MATERIAL"|"MUTED"|"IDENTIFY"|"LEADERSHIP"|"FLANKED"|"ADRENALINE"|"LYING"|"WIND_WALKER"|"DARK_AVENGER"|"SOURCE_MUTED"|"HEAL_SHARING_CASTER"
--- @alias SurfaceActionType string|"ChangeSurfaceOnPathAction"|"PolygonSurfaceAction"|"ExtinguishFireAction"|"SwapSurfaceAction"|"TransformSurfaceAction"|"CreateSurfaceAction"|"RectangleSurfaceAction"|"ZoneAction"|"CreatePuddleAction"
--- @alias SurfaceLayer string|"None"|"Cloud"|"Ground"
--- @alias SurfaceTransformActionType string|"Purify"|"Oilify"|"Bless"|"Electrify"|"Condense"|"None"|"Vaporize"|"Freeze"|"Bloodify"|"Contaminate"|"Ignite"|"Melt"|"Curse"|"Shatter"
--- @alias SurfaceType string|"FireCursed"|"WaterCloudElectrified"|"FirePurified"|"BloodCloudPurified"|"WaterFrozen"|"WaterBlessed"|"WaterFrozenCursed"|"WaterCursed"|"BloodFrozenPurified"|"WaterPurified"|"BloodCloudElectrified"|"BloodFrozen"|"SmokeCloudBlessed"|"WaterElectrifiedBlessed"|"BloodBlessed"|"BloodElectrifiedPurified"|"BloodFrozenBlessed"|"BloodCursed"|"Lava"|"BloodPurified"|"Source"|"WaterCloudBlessed"|"PoisonBlessed"|"WaterCloudElectrifiedCursed"|"PoisonCloudBlessed"|"PoisonCursed"|"Water"|"WaterFrozenPurified"|"PoisonPurified"|"FireCloud"|"OilBlessed"|"FireCloudBlessed"|"WaterCloud"|"BloodCloudElectrifiedBlessed"|"OilCursed"|"BloodCloud"|"BloodCloudBlessed"|"OilPurified"|"PoisonCloud"|"SmokeCloudCursed"|"Fire"|"WaterFrozenBlessed"|"WebBlessed"|"BloodCloudElectrifiedPurified"|"SmokeCloud"|"BloodElectrifiedCursed"|"WebCursed"|"ExplosionCloud"|"WebPurified"|"WaterCloudCursed"|"FrostCloud"|"Blood"|"CustomBlessed"|"PoisonCloudCursed"|"Web"|"CustomCursed"|"WaterElectrifiedPurified"|"BloodElectrified"|"Poison"|"CustomPurified"|"FireCloudCursed"|"FireCloudPurified"|"Custom"|"BloodCloudCursed"|"Deathfog"|"WaterCloudElectrifiedBlessed"|"SmokeCloudPurified"|"ShockwaveCloud"|"WaterElectrifiedCursed"|"BloodFrozenCursed"|"Oil"|"Deepwater"|"WaterCloudPurified"|"WaterCloudElectrifiedPurified"|"PoisonCloudPurified"|"WaterElectrified"|"Sentinel"|"FireBlessed"|"BloodElectrifiedBlessed"|"BloodCloudElectrifiedCursed"
--- @alias TemplateType string|"GlobalCacheTemplate"|"LevelCacheTemplate"|"RootTemplate"|"GlobalTemplate"|"LocalTemplate"
--- @alias TriggerTypeId string|"AIHintAreaTrigger"|"SpectatorTrigger"|"AtmosphereTrigger"|"MusicVolumeTrigger"|"PointTrigger"|"CameraLockTrigger"|"RegionTrigger"|"StatsAreaTrigger"|"AISeederTrigger"|"AreaTrigger"|"SecretRegionTrigger"|"CullTrigger"|"EventTrigger"|"PointSoundTriggerDummy"|"StartTrigger"|"TeleportTrigger"|"CrimeAreaTrigger"|"ExplorationTrigger"|"SoundVolumeTrigger"|"PointSoundTrigger"|"CrimeRegionTrigger"
--- @alias UIObjectFlags string|"OF_DeleteOnChildDestroy"|"OF_PreventCameraMove"|"OF_PlayerTextInput4"|"OF_Loaded"|"OF_Visible"|"OF_Activated"|"OF_PlayerTextInput1"|"OF_PlayerInput1"|"OF_PlayerInput2"|"OF_PlayerInput3"|"OF_RequestDelete"|"OF_PlayerInput4"|"OF_PlayerModal1"|"OF_DontHideOnDelete"|"OF_PlayerModal2"|"OF_PlayerModal3"|"OF_PlayerModal4"|"OF_KeepInScreen"|"OF_PlayerTextInput2"|"OF_PauseRequest"|"OF_SortOnAdd"|"OF_FullScreen"|"OF_KeepCustomInScreen"|"OF_PrecacheUIData"|"OF_PlayerTextInput3"|"OF_Load"
--- @alias VisualAttachmentFlags string|"InheritAnimations"|"ParticleSystem"|"DestroyWithParent"|"Horns"|"ExcludeFromBounds"|"Armor"|"KeepScale"|"DoNotUpdate"|"KeepRot"|"Overhead"|"Weapon"|"WeaponFX"|"UseLocalTransform"|"BonusWeaponFX"|"WeaponOverlayFX"|"Wings"
--- @alias VisualComponentFlags string|"ForceUseAnimationBlueprint"|"VisualSetLoaded"
--- @alias VisualFlags string|"AllowReceiveDecalWhenAnimated"|"ReceiveDecal"|"Reflecting"|"CastShadow"|"IsShadowProxy"
--- @alias VisualTemplateColorIndex string|"Hair"|"Cloth"|"Skin"
--- @alias VisualTemplateVisualIndex string|"Visual9"|"Torso"|"HairHelmet"|"Trousers"|"Visual8"|"Head"|"Boots"|"Arms"|"Beard"
--- @alias EclCharacterFlags string|"VisualsUpdated"|"IsRunning"|"WeaponSheathed"|"IsPlayer"|"HasInventory"|"DisableSneaking"|"CanShootThrough"|"MovementUpdated"|"HasSkillTargetEffect"|"GMControl"|"ReservedForDialog"|"Floating"|"WalkThrough"|"Activated"|"Global"|"SpotSneakers"|"OffStage"|"Dead"|"Multiplayer"|"NoCover"|"HasOwner"|"IsHuge"|"InParty"|"InDialog"|"UseOverlayMaterials"|"Summon"|"VisionGridInvisible"|"CharCreationInProgress"|"StoryNPC"|"CannotMove"|"HasCustomVisualIndices"|"Invisible"|"PartyFollower"|"CharacterCreationFinished"|"VisionGridInvisible2"|"InCombat"|"NoRotate"
--- @alias EclEntityComponentIndex string|"ContainerElement"|"Scenery"|"GameMaster"|"Effect"|"SpectatorTrigger"|"Egg"|"AtmosphereTrigger"|"Visual"|"PublishingRequest"|"OverviewMap"|"Vignette"|"PointTrigger"|"CameraLockTrigger"|"Net"|"RegionTrigger"|"Spline"|"Light"|"CullTrigger"|"SecretRegionTrigger"|"Container"|"PointSoundTriggerDummy"|"Note"|"CustomStatDefinition"|"Item"|"Decal"|"Combat"|"Projectile"|"GMJournalNode"|"AnimationBlueprint"|"SoundVolumeTrigger"|"PointSoundTrigger"|"Sound"|"CustomStats"|"LightProbe"|"Character"|"EquipmentVisualsComponent"|"ParentEntity"|"AiSeederTrigger"|"PingBeacon"
--- @alias EclEntitySystemIndex string|"LightProbeManager"|"EncounterManager"|"CharacterManager"|"AnimationBlueprintSystem"|"AtmosphereManager"|"GameMasterCampaignManager"|"MusicManager"|"PublishingSystem"|"VisualSystem"|"PingBeaconManager"|"LightManager"|"DecalManager"|"SoundSystem"|"GrannySystem"|"SeeThroughManager"|"TurnManager"|"SceneryManager"|"ProjectileManager"|"TriggerManager"|"PickingHelperManager"|"ItemManager"|"EggManager"|"EquipmentVisualsSystem"|"ContainerElementComponent"|"PhysXScene"|"ContainerComponentSystem"|"SurfaceManager"|"LEDSystem"|"CameraSplineSystem"|"GMJournalSystem"|"GameActionManager"|"GameMasterManager"|"CustomStatsSystem"
--- @alias EclGameState string|"UnloadLevel"|"UnloadModule"|"Join"|"UnloadSession"|"PrepareRunning"|"Disconnect"|"StartLoading"|"Exit"|"StopLoading"|"StartServer"|"Installation"|"Init"|"GameMasterPause"|"Idle"|"ModReceiving"|"Lobby"|"BuildStory"|"LoadLoca"|"Movie"|"Save"|"Menu"|"Paused"|"InitMenu"|"InitNetwork"|"InitConnection"|"LoadMenu"|"Running"|"SwapLevel"|"LoadLevel"|"LoadModule"|"LoadSession"|"Unknown"|"LoadGMCampaign"
--- @alias EclItemFlags string|"CanBePickedUp"|"Known"|"CanBeMoved"|"IsDoor"|"CoverAmount"|"CanShootThrough"|"MovementUpdated"|"EnableHighlights"|"Floating"|"Activated"|"Walkable"|"Global"|"HideHP"|"FreezeGravity"|"CanWalkThrough"|"StoryItem"|"DontAddToBottomBar"|"WasOpened"|"IsSourceContainer"|"PhysicsFlag1"|"Fade"|"PhysicsFlag2"|"InteractionDisabled"|"JoinedDialog"|"Registered"|"FoldDynamicStats"|"PhysicsFlag3"|"Destroyed"|"IsLadder"|"Hostile"|"Sticky"|"HasPendingNetUpdate"|"Unimportant"|"Invulnerable"|"CanUse"|"IsSecretDoor"|"Invisible"|"TeleportOnUse"|"Wadable"|"PinnedContainer"|"IsCraftingIngredient"
--- @alias EclItemFlags2 string|"IsKey"|"UnEquipLocked"|"UseSoundsLoaded"|"Stolen"|"Consumable"|"CanUseRemotely"
--- @alias EclItemPhysicsFlags string|"RequestWakeNeighbours"|"PhysicsDisabled"|"RequestRaycast"
--- @alias EclSceneryFlags string|"CanShootThrough"|"Fadeable"|"SeeThrough"|"Walkable"|"Fade"|"IsWall"|"Destroyed"|"UnknownFlag80"|"UnknownFlag100"|"Invisible"|"Wadable"
--- @alias EclSceneryRenderFlags string|"UnknownRenderFlag20"|"AllowReceiveDecalWhenAnimated"|"ForceUseAnimationBlueprint"|"ReceiveDecals"|"CastShadow"|"UnknownRenderFlag1"|"IsReflecting"|"IsShadowProxy"
--- @alias EclStatusFlags string|"Started"|"HasVisuals"|"KeepAlive"|"RequestDelete"
--- @alias EocCombatComponentFlags string|"CanFight"|"TurnEnded"|"CanJoinCombat"|"RequestTakeExtraTurn"|"CanGuard"|"IsInspector"|"IsTicking"|"RequestEndTurn"|"Guarded"|"CanForceEndTurn"|"FleeOnEndTurn"|"GuardOnEndTurn"|"EnteredCombat"|"TookExtraTurn"|"DelayDeathCount"|"CounterAttacked"|"RequestEnterCombat"|"IsBoss"|"InArena"
--- @alias EocSkillBarItemType string|"Skill"|"None"|"ItemTemplate"|"Action"|"Item"
--- @alias EsvActionStateType string|"PrepareSkill"|"PickUp"|"MoveItem"|"UseSkill"|"KnockedDown"|"Polymorphing"|"CombineItem"|"Identify"|"TeleportFall"|"DisarmTrap"|"UseItem"|"Unsheath"|"Die"|"Repair"|"Incapacitated"|"JumpFlight"|"Sheath"|"Idle"|"Drop"|"Animation"|"Attack"|"Summoning"|"Hit"|"Lockpick"
--- @alias EsvCharacterFlags string|"GMReroll"|"Passthrough"|"IsPlayer"|"DeferredRemoveEscapist"|"CoverAmount"|"CanShootThrough"|"Loaded"|"ReservedForDialog"|"Floating"|"WalkThrough"|"Activated"|"SpotSneakers"|"OffStage"|"FindValidPositionOnActivate"|"Multiplayer"|"Dead"|"ForceNonzeroSpeed"|"Totem"|"CustomLookEnabled"|"HostControl"|"LevelTransitionPending"|"HasOwner"|"IsHuge"|"RegisteredForAutomatedDialog"|"InParty"|"InDialog"|"Deactivated"|"NeedsMakePlayerUpdate"|"Summon"|"Invulnerable"|"CharCreationInProgress"|"CannotDie"|"StoryNPC"|"FightMode"|"CannotMove"|"CannotRun"|"RequestStartTurn"|"PartyFollower"|"CharacterCreationFinished"|"DisableFlee_M"|"CharacterControl"|"IgnoresTriggers"|"Temporary"|"DontCacheTemplate"|"IsCompanion_M"|"InArena"|"NoRotate"|"DisableCulling"
--- @alias EsvCharacterFlags2 string|"Resurrected"|"HasDefaultDialog"|"TreasureGeneratedForTrader"|"Global"|"HasOsirisDialog"|"Trader"
--- @alias EsvCharacterFlags3 string|"HasRunSpeedOverride"|"ManuallyLeveled"|"IsPet"|"IsGameMaster"|"IsPossessed"|"NoReptuationEffects"|"IsSpectating"|"HasWalkSpeedOverride"
--- @alias EsvCharacterTransformFlags string|"ReplaceInventory"|"ReplaceScripts"|"ReplaceCustomLooks"|"ReplaceStats"|"ReplaceOriginalTemplate"|"Immediate"|"ReplaceTags"|"ReplaceScale"|"ReplaceCustomNameIcon"|"ReplaceSkills"|"ReplaceVoiceSet"|"ImmediateSync"|"ReplaceCurrentTemplate"|"DontCheckRootTemplate"|"ReleasePlayerData"|"SaveOriginalDisplayName"|"DontReplaceCombatState"|"ReplaceEquipment"|"DiscardOriginalDisplayName"
--- @alias EsvCharacterTransformType string|"TransformToCharacter"|"TransformToTemplate"
--- @alias EsvEntityComponentIndex string|"ContainerElement"|"GameMaster"|"AIHintAreaTrigger"|"Effect"|"Egg"|"AtmosphereTrigger"|"MusicVolumeTrigger"|"OverviewMap"|"Vignette"|"Net"|"StatsAreaTrigger"|"RegionTrigger"|"Spline"|"SecretRegionTrigger"|"Container"|"EventTrigger"|"StartTrigger"|"Note"|"CustomStatDefinition"|"TeleportTrigger"|"Item"|"CrimeAreaTrigger"|"Combat"|"Projectile"|"ExplorationTrigger"|"GMJournalNode"|"AnimationBlueprint"|"SoundVolumeTrigger"|"CustomStats"|"Character"|"EoCPointTrigger"|"CrimeRegionTrigger"|"EoCAreaTrigger"
--- @alias EsvEntitySystemIndex string|"CharacterManager"|"AnimationBlueprintSystem"|"GameMasterCampaignManager"|"NetEntityManager"|"ShroudManager"|"TurnManager"|"ProjectileManager"|"TriggerManager"|"ItemManager"|"EggManager"|"EnvironmentalStatusManager"|"ContainerElementComponent"|"ContainerComponentSystem"|"SurfaceManager"|"CharacterSplineSystem"|"SightManager"|"EffectManager"|"CameraSplineSystem"|"GMJournalSystem"|"GameActionManager"|"RewardManager"|"GameMasterManager"|"CustomStatsSystem"
--- @alias EsvGameState string|"UnloadLevel"|"UnloadModule"|"UnloadSession"|"Disconnect"|"Exit"|"Installation"|"Init"|"GameMasterPause"|"Idle"|"BuildStory"|"Save"|"Paused"|"Uninitialized"|"Running"|"ReloadStory"|"LoadLevel"|"LoadModule"|"LoadSession"|"Sync"|"Unknown"|"LoadGMCampaign"
--- @alias EsvItemFlags string|"CanBePickedUp"|"Known"|"CanBeMoved"|"CanOnlyBeUsedByOwner"|"IsDoor"|"WalkOn"|"CanShootThrough"|"ReservedForDialog"|"WalkThrough"|"Floating"|"Activated"|"HideHP"|"FreezeGravity"|"IsSurfaceBlocker"|"OffStage"|"StoryItem"|"InAutomatedDialog"|"NoCover"|"Totem"|"LoadedTemplate"|"ClientSync1"|"InteractionDisabled"|"IsContainer"|"ForceSync"|"Invisible2"|"Destroy"|"DisableSync"|"Destroyed"|"Summon"|"IsLadder"|"IsSurfaceCloudBlocker"|"DontAddToHotbar"|"Sticky"|"Invulnerable"|"PositionChanged"|"CanUse"|"GMFolding"|"IsSecretDoor"|"TransformChanged"|"Invulnerable2"|"WakePhysics"|"ForceClientSync"|"Invisible"|"ClientSync2"|"SourceContainer"|"TeleportOnUse"|"PinnedContainer"|"Frozen"
--- @alias EsvItemFlags2 string|"IsKey"|"UnsoldGenerated"|"UnEquipLocked"|"Global"|"UseRemotely"|"TreasureGenerated"|"CanConsume"
--- @alias EsvItemTransformFlags string|"ReplaceScripts"|"ReplaceStats"|"Immediate"
--- @alias EsvMovementStateType string|"MoveTo"|"Movement"
--- @alias EsvStatusControllerFlags string|"CancelCurrentAction"|"Dying"|"KnockedDown"|"Polymorphing"|"EndTurn"|"PlayHitAnimation"|"CancelCurrentAction2"|"Incapacitated"|"JumpFlight"|"HitAnimationFlag1"|"PlayHitStillAnimation"|"TeleportFalling"|"CombatReady"|"HitAnimationFlag2"|"SheathWeapon"|"UnsheathWeapon"|"SteerToEnemy"|"HitAnimationFlag3"|"CancelSkill"|"Summoning"|"PlayingDeathAnimation"|"HitAnimationFlag2b"
--- @alias EsvStatusFlags0 string|"IsFromItem"|"InitiateCombat"|"Channeled"|"IsLifeTimeSet"|"KeepAlive"|"Influence"|"IsOnSourceSurface"
--- @alias EsvStatusFlags1 string|"IsHostileAct"|"BringIntoCombat"|"IsInvulnerable"|"IsResistingDeath"
--- @alias EsvStatusFlags2 string|"ForceFailStatus"|"Started"|"RequestClientSync2"|"RequestDeleteAtTurnEnd"|"RequestClientSync"|"RequestDelete"|"ForceStatus"
--- @alias EsvTaskType string|"Wander"|"MoveItem"|"UseSkill"|"UseItem"|"MoveToLocation"|"MoveToObject"|"MoveInRange"|"Disappear"|"FollowNPC"|"PlayAnimation"|"PickupItem"|"Resurrect"|"Steer"|"Drop"|"MoveToAndTalk"|"TeleportToLocation"|"Flee"|"Attack"|"Appear"
--- @alias StatsAbilityType string|"Barter"|"Sourcery"|"Crafting"|"Thievery"|"Wand"|"Loremaster"|"Reflexes"|"Repair"|"Sneaking"|"RangerLore"|"RogueLore"|"Reason"|"Persuasion"|"Intimidate"|"Leadership"|"Pickpocket"|"DualWielding"|"Perseverance"|"PhysicalArmorMastery"|"VitalityMastery"|"Shield"|"Luck"|"SingleHanded"|"TwoHanded"|"WarriorLore"|"AirSpecialist"|"EarthSpecialist"|"Brewmaster"|"MagicArmorMastery"|"FireSpecialist"|"Charm"|"Runecrafting"|"Necromancy"|"Summoning"|"Ranged"|"Polymorph"|"PainReflection"|"Telekinesis"|"Sentinel"|"WaterSpecialist"|"Sulfurology"
--- @alias StatsArmorType string|"None"|"Cloth"|"Plate"|"Leather"|"Mail"|"Robe"|"Sentinel"
--- @alias StatsCharacterFlags string|"IsPlayer"|"InParty"|"EquipmentValidated"|"IsSneaking"|"Invisible"|"Blind"|"DrinkedPotion"
--- @alias StatsCharacterStatGetterType string|"CorrosiveResistance"|"Sight"|"PoisonResistance"|"LifeSteal"|"ChanceToHitBoost"|"Initiative"|"APMaximum"|"BlockChance"|"APRecovery"|"ShadowResistance"|"Wits"|"Accuracy"|"Movement"|"PiercingResistance"|"FireResistance"|"EarthResistance"|"MaxMp"|"WaterResistance"|"CustomResistance"|"Memory"|"AirResistance"|"MagicResistance"|"DamageBoost"|"CriticalChance"|"PhysicalResistance"|"Dodge"|"Hearing"|"Finesse"|"Strength"|"APStart"|"Intelligence"|"Constitution"
--- @alias StatsCriticalRoll string|"Critical"|"NotCritical"|"Roll"
--- @alias StatsDamageType string|"Earth"|"Magic"|"None"|"Water"|"Fire"|"Poison"|"Sulfuric"|"Air"|"Piercing"|"Physical"|"Corrosive"|"Chaos"|"Shadow"|"Sentinel"
--- @alias StatsDeathType string|"KnockedDown"|"DoT"|"None"|"Explode"|"Acid"|"Incinerate"|"Electrocution"|"Arrow"|"FrozenShatter"|"Surrender"|"Hang"|"Lifetime"|"PetrifiedShatter"|"Sulfur"|"Piercing"|"Physical"|"Sentinel"
--- @alias StatsEquipmentStatsType string|"Shield"|"Armor"|"Weapon"
--- @alias StatsHandednessType string|"One"|"Any"|"Two"
--- @alias StatsHighGroundBonus string|"EvenGround"|"LowGround"|"HighGround"|"Unknown"
--- @alias StatsHitFlag string|"CounterAttack"|"Missed"|"DontCreateBloodSurface"|"Poisoned"|"Bleeding"|"Reflection"|"NoEvents"|"DoT"|"ProcWindWalker"|"PropagatedFromOwner"|"FromShacklesOfPain"|"Blocked"|"Dodged"|"Surface"|"DamagedMagicArmor"|"Burning"|"CriticalHit"|"Flanking"|"Backstab"|"FromSetHP"|"DamagedPhysicalArmor"|"Hit"|"NoDamageOnOwner"|"DamagedVitality"
--- @alias StatsHitType string|"DoT"|"Magic"|"Surface"|"Melee"|"WeaponDamage"|"Reflected"|"Ranged"
--- @alias StatsItemSlot string|"Ring"|"Breast"|"Ring2"|"Horns"|"Shield"|"Leggings"|"Boots"|"Overhead"|"Weapon"|"Gloves"|"Belt"|"Helmet"|"Amulet"|"Wings"|"Sentinel"
--- @alias StatsItemSlot32 string|"Ring"|"Breast"|"Ring2"|"Horns"|"Shield"|"Leggings"|"Boots"|"Overhead"|"Weapon"|"Gloves"|"Belt"|"Helmet"|"Amulet"|"Wings"|"Sentinel"
--- @alias StatsPropertyContext string|"AoE"|"SelfOnHit"|"SelfOnEquip"|"Target"|"Self"
--- @alias StatsPropertyType string|"Sabotage"|"OsirisTask"|"GameAction"|"Extender"|"SurfaceChange"|"Summon"|"CustomDescription"|"Custom"|"Status"|"Force"
--- @alias StatsRequirementType string|"Barter"|"TALENT_ExtraSkillPoints"|"TALENT_ResurrectToFullHealth"|"TALENT_Bully"|"TALENT_Human_Inventive"|"TALENT_Soulcatcher"|"Sourcery"|"TALENT_Intimidate"|"TALENT_LoneWolf"|"TALENT_RogueLoreHoldResistance"|"TALENT_ViolentMagic"|"Tag"|"Crafting"|"TALENT_LightStep"|"TALENT_Zombie"|"TRAIT_Independent"|"Thievery"|"Wand"|"TALENT_ActionPoints2"|"TALENT_FiveStarRestaurant"|"TALENT_Politician"|"TALENT_Demon"|"Loremaster"|"TALENT_ResistSilence"|"TALENT_IceKing"|"TALENT_Kickstarter"|"TALENT_WarriorLoreGrenadeRange"|"TALENT_Gladiator"|"TALENT_WaterSpells"|"TALENT_Stench"|"TALENT_Perfectionist"|"Reflexes"|"TALENT_AnimalEmpathy"|"TALENT_WarriorLoreNaturalHealth"|"TALENT_Elf_Lore"|"TRAIT_Vindictive"|"Repair"|"Sneaking"|"TALENT_ItemCreation"|"TALENT_FaroutDude"|"TALENT_Lizard_Persuasion"|"TALENT_Memory"|"RangerLore"|"TALENT_ResistKnockdown"|"TALENT_WalkItOff"|"TALENT_Torturer"|"None"|"RogueLore"|"TALENT_Durability"|"TALENT_RangerLoreEvasionBonus"|"TALENT_Dwarf_Sneaking"|"TALENT_Unstable"|"TALENT_MasterThief"|"Reason"|"Persuasion"|"TALENT_Initiative"|"TALENT_LivingArmor"|"TRAIT_Forgiving"|"Intimidate"|"TALENT_Scientist"|"TRAIT_Bold"|"TRAIT_Materialistic"|"Wits"|"Leadership"|"TALENT_Criticals"|"TALENT_WeatherProof"|"TALENT_RogueLoreDaggerAPBonus"|"TRAIT_Timid"|"Pickpocket"|"DualWielding"|"TALENT_ResistDead"|"TALENT_ExtraWandCharge"|"TRAIT_Obedient"|"TALENT_Indomitable"|"Perseverance"|"TALENT_Flanking"|"TALENT_ChanceToHitRanged"|"TALENT_AirSpells"|"TALENT_Executioner"|"TRAIT_Pragmatic"|"PhysicalArmorMastery"|"TALENT_Backstab"|"TALENT_StandYourGround"|"TALENT_RogueLoreMovementBonus"|"TRAIT_Altruistic"|"TRAIT_Romantic"|"TALENT_Trade"|"TALENT_ChanceToHitMelee"|"TALENT_ElementalRanger"|"TRAIT_Spiritual"|"Shield"|"Luck"|"TALENT_Lockpick"|"TALENT_ResistStun"|"TALENT_ElementalAffinity"|"TALENT_FolkDancer"|"TRAIT_Righteous"|"TALENT_Damage"|"TALENT_Awareness"|"TALENT_NoAttackOfOpportunity"|"TALENT_Dwarf_Sturdy"|"TRAIT_Renegade"|"TALENT_GreedyVessel"|"Memory"|"SingleHanded"|"TALENT_Sight"|"TALENT_InventoryAccess"|"TALENT_Ambidextrous"|"TRAIT_Blunt"|"Level"|"TwoHanded"|"TALENT_Carry"|"TALENT_MrKnowItAll"|"TALENT_WarriorLoreNaturalArmor"|"TRAIT_Considerate"|"TRAIT_Heartless"|"Combat"|"WarriorLore"|"TALENT_IncreasedArmor"|"TALENT_Kinetics"|"TALENT_Courageous"|"TALENT_RogueLoreGrenadePrecision"|"TALENT_DualWieldingDodging"|"MinKarma"|"AirSpecialist"|"TALENT_Repair"|"TALENT_ExtraStatPoints"|"TALENT_Human_Civil"|"MaxKarma"|"TALENT_Jitterbug"|"EarthSpecialist"|"TALENT_ExpGain"|"TALENT_EarthSpells"|"TALENT_RangerLoreArrowRecover"|"TALENT_QuickStep"|"Immobile"|"MagicArmorMastery"|"Vitality"|"FireSpecialist"|"Charm"|"TALENT_Vitality"|"TALENT_SurpriseAttack"|"TALENT_Lizard_Resistance"|"TRAIT_Egotistical"|"TALENT_Sadist"|"Necromancy"|"TALENT_ActionPoints"|"TALENT_Charm"|"TALENT_LightningRod"|"Finesse"|"Summoning"|"TALENT_ResistPoison"|"TALENT_Reason"|"TALENT_SpillNoBlood"|"TALENT_RangerLoreRangedAPBonus"|"TALENT_Elementalist"|"Ranged"|"Polymorph"|"TALENT_FireSpells"|"TALENT_Luck"|"TALENT_WarriorLoreNaturalResistance"|"TALENT_Elf_CorpseEater"|"TALENT_Haymaker"|"TALENT_MagicCycles"|"Strength"|"PainReflection"|"TALENT_AttackOfOpportunity"|"TALENT_AvoidDetection"|"TALENT_Escapist"|"TALENT_Sourcerer"|"TALENT_WildMag"|"Intelligence"|"Telekinesis"|"TALENT_ItemMovement"|"TALENT_Raistlin"|"TALENT_WhatARush"|"TALENT_RogueLoreDaggerBackStab"|"TRAIT_Compassionate"|"Constitution"|"WaterSpecialist"|"TALENT_ResistFear"|"TALENT_Leech"|"TALENT_GoldenMage"
--- @alias StatsTalentType string|"Criticals"|"Durability"|"LightningRod"|"WarriorLoreGrenadeRange"|"Dwarf_Sturdy"|"IncreasedArmor"|"Sight"|"Politician"|"Elf_Lore"|"Quest_SpidersKiss_Per"|"ResistFear"|"WeatherProof"|"Demon"|"Perfectionist"|"ResistKnockdown"|"FiveStarRestaurant"|"LoneWolf"|"Executioner"|"ResistStun"|"RogueLoreMovementBonus"|"ViolentMagic"|"ActionPoints"|"ResistPoison"|"Lizard_Resistance"|"QuickStep"|"Sadist"|"ResistSilence"|"Carry"|"Initiative"|"BeastMaster"|"NaturalConductor"|"ResistDead"|"Repair"|"ExtraSkillPoints"|"Quest_GhostTree"|"Throwing"|"WarriorLoreNaturalResistance"|"RangerLoreRangedAPBonus"|"LivingArmor"|"None"|"Zombie"|"DualWieldingDodging"|"Torturer"|"Reason"|"Quest_SpidersKiss_Null"|"Ambidextrous"|"ItemMovement"|"AttackOfOpportunity"|"ExtraStatPoints"|"Intimidate"|"Unstable"|"AnimalEmpathy"|"WarriorLoreNaturalArmor"|"Quest_Rooted"|"Rager"|"Trade"|"Awareness"|"RogueLoreHoldResistance"|"PainDrinker"|"Max"|"Escapist"|"Quest_SpidersKiss_Str"|"Sourcerer"|"Damage"|"FireSpells"|"DeathfogResistant"|"Elementalist"|"WaterSpells"|"ResurrectToFullHealth"|"Bully"|"Haymaker"|"AirSpells"|"Luck"|"RogueLoreDaggerAPBonus"|"Gladiator"|"EarthSpells"|"Elf_CorpseEating"|"Indomitable"|"InventoryAccess"|"Stench"|"Memory"|"Quest_TradeSecrets"|"Jitterbug"|"ChanceToHitRanged"|"AvoidDetection"|"Soulcatcher"|"Kickstarter"|"RangerLoreArrowRecover"|"MasterThief"|"StandYourGround"|"Courageous"|"WarriorLoreNaturalHealth"|"NoAttackOfOpportunity"|"GreedyVessel"|"SurpriseAttack"|"Leech"|"GoldenMage"|"Quest_SpidersKiss_Int"|"MagicCycles"|"Vitality"|"Charm"|"LightStep"|"WalkItOff"|"Scientist"|"ElementalAffinity"|"FolkDancer"|"RogueLoreGrenadePrecision"|"ItemCreation"|"Raistlin"|"IceKing"|"SpillNoBlood"|"RogueLoreDaggerBackStab"|"Flanking"|"MrKnowItAll"|"Lizard_Persuasion"|"Backstab"|"WhatARush"|"Human_Inventive"|"ResurrectExtraHealth"|"Lockpick"|"ChanceToHitMelee"|"FaroutDude"|"WandCharge"|"Human_Civil"|"WildMag"|"ActionPoints2"|"ExpGain"|"ElementalRanger"|"RangerLoreEvasionBonus"|"Dwarf_Sneaking"
--- @alias StatsWeaponType string|"Wand"|"Rifle"|"None"|"Knife"|"Sword"|"Crossbow"|"Axe"|"Staff"|"Arrow"|"Spear"|"Club"|"Sentinel"|"Bow"


--- @class ActivePersistentLevelTemplate
--- @field Area AreaTrigger
--- @field Template LevelTemplate


--- @class Actor
--- @field MeshBindings MeshBinding[]
--- @field PhysicsRagdoll PhysicsRagdoll
--- @field Skeleton Skeleton
--- @field TextKeyPrepareFlags uint8
--- @field Time GameTime
--- @field Visual Visual


--- @class AiHintAreaTriggerData : ITriggerData
--- @field IsAnchor bool


--- @class AnimatableObject : RenderableObject
--- @field MeshBinding MeshBinding


--- @class AnimationSet
--- @field AnimationSubSets table<int32, table<FixedString, AnimationSetAnimationDescriptor>>
--- @field Type FixedString


--- @class AnimationSetAnimationDescriptor
--- @field ID FixedString
--- @field Name FixedString


--- @class AppliedMaterial
--- @field BlendState uint8
--- @field DefaultShaderHandle ComponentHandle
--- @field DefaultShaderType int32
--- @field DefaultVertexFormatHandle ComponentHandle
--- @field DepthShaderHandle ComponentHandle
--- @field DepthShaderType int32
--- @field DepthVertexFormatHandle ComponentHandle
--- @field ForceForwardShading bool
--- @field ForcePostRefractionAlpha bool
--- @field ForwardShaderHandle ComponentHandle
--- @field ForwardShaderType int32
--- @field ForwardVertexFormatHandle ComponentHandle
--- @field HasDebugMaterial bool
--- @field IsOverlay bool
--- @field Material Material
--- @field MaterialParameters MaterialParameters
--- @field OverlayOffset float
--- @field Renderable RenderableObject
--- @field ShadowShaderHandle ComponentHandle
--- @field ShadowShaderType int32
--- @field ShadowVertexFormatHandle ComponentHandle


--- @class AreaTrigger : Trigger
--- @field ObjectsInTrigger ComponentHandle[]
--- @field Physics AreaTriggerPhysics


--- @class AreaTriggerPhysics
--- @field AreaTypeId int32


--- @class AtmosphereTrigger : AreaTrigger
--- @field AtmosphereResourceIds FixedString[]
--- @field CurrentAtmosphere FixedString
--- @field FadeTime float


--- @class AtmosphereTriggerData : ITriggerData
--- @field Atmospheres FixedString[]
--- @field FadeTime float


--- @class BaseComponent
--- @field Component ComponentHandleWithType
--- @field Entity EntityHandle


--- @class BookActionData : IActionData
--- @field BookId FixedString


--- @class Bound
--- @field Center vec3
--- @field IsCenterSet bool
--- @field Max vec3
--- @field Min vec3
--- @field Radius float


--- @class CDivinityStatsCharacter : StatsObjectInstance
--- @field APMaximum int32
--- @field APRecovery int32
--- @field APStart int32
--- @field Accuracy int32
--- @field AcidImmunity bool
--- @field AirResistance int32
--- @field AirSpecialist int32
--- @field ArmorAfterHitCooldownMultiplier int32
--- @field Arrow bool
--- @field AttributeFlags StatAttributeFlags
--- @field AttributeFlagsUpdated bool
--- @field Barter int32
--- @field BaseAPMaximum int32
--- @field BaseAPRecovery int32
--- @field BaseAPStart int32
--- @field BaseAccuracy int32
--- @field BaseAirResistance int32
--- @field BaseAirSpecialist int32
--- @field BaseAttributeFlags StatAttributeFlags
--- @field BaseBarter int32
--- @field BaseBlockChance int32
--- @field BaseBrewmaster int32
--- @field BaseChanceToHitBoost int32
--- @field BaseCharm int32
--- @field BaseConstitution int32
--- @field BaseCorrosiveResistance int32
--- @field BaseCrafting int32
--- @field BaseCriticalChance int32
--- @field BaseCustomResistance int32
--- @field BaseDamageBoost int32
--- @field BaseDodge int32
--- @field BaseDualWielding int32
--- @field BaseEarthResistance int32
--- @field BaseEarthSpecialist int32
--- @field BaseFinesse int32
--- @field BaseFireResistance int32
--- @field BaseFireSpecialist int32
--- @field BaseHearing int32
--- @field BaseInitiative int32
--- @field BaseIntelligence int32
--- @field BaseIntimidate int32
--- @field BaseLeadership int32
--- @field BaseLifeSteal int32
--- @field BaseLoremaster int32
--- @field BaseLuck int32
--- @field BaseMagicArmorMastery int32
--- @field BaseMagicResistance int32
--- @field BaseMaxArmor int32
--- @field BaseMaxMagicArmor int32
--- @field BaseMaxMp int32
--- @field BaseMaxSummons int32
--- @field BaseMaxVitality int32
--- @field BaseMemory int32
--- @field BaseMovement int32
--- @field BaseNecromancy int32
--- @field BasePainReflection int32
--- @field BasePerseverance int32
--- @field BasePersuasion int32
--- @field BasePhysicalArmorMastery int32
--- @field BasePhysicalResistance int32
--- @field BasePickpocket int32
--- @field BasePiercingResistance int32
--- @field BasePoisonResistance int32
--- @field BasePolymorph int32
--- @field BaseRanged int32
--- @field BaseRangerLore int32
--- @field BaseReason int32
--- @field BaseReflexes int32
--- @field BaseRepair int32
--- @field BaseRogueLore int32
--- @field BaseRunecrafting int32
--- @field BaseSentinel int32
--- @field BaseShadowResistance int32
--- @field BaseShield int32
--- @field BaseSight int32
--- @field BaseSingleHanded int32
--- @field BaseSneaking int32
--- @field BaseSourcery int32
--- @field BaseStrength int32
--- @field BaseSulfurology int32
--- @field BaseSummoning int32
--- @field BaseTelekinesis int32
--- @field BaseThievery int32
--- @field BaseTwoHanded int32
--- @field BaseVitalityMastery int32
--- @field BaseWand int32
--- @field BaseWarriorLore int32
--- @field BaseWaterResistance int32
--- @field BaseWaterSpecialist int32
--- @field BaseWits int32
--- @field BleedingImmunity bool
--- @field BlessedImmunity bool
--- @field Blind bool
--- @field BlindImmunity bool
--- @field BlockChance int32
--- @field BonusActionPoints int32
--- @field Brewmaster int32
--- @field BurnContact bool
--- @field BurnImmunity bool
--- @field ChanceToHitBoost int32
--- @field Character IGameObject
--- @field Charm int32
--- @field CharmImmunity bool
--- @field ChickenImmunity bool
--- @field ChillContact bool
--- @field ChilledImmunity bool
--- @field ClairvoyantImmunity bool
--- @field Constitution int32
--- @field CorrosiveResistance int32
--- @field Crafting int32
--- @field CrippledImmunity bool
--- @field CriticalChance int32
--- @field CurrentAP int32
--- @field CurrentArmor int32
--- @field CurrentMagicArmor int32
--- @field CurrentVitality int32
--- @field CursedImmunity bool
--- @field CustomResistance int32
--- @field DamageBoost int32
--- @field DecayingImmunity bool
--- @field DeflectProjectiles bool
--- @field DisarmedImmunity bool
--- @field DiseasedImmunity bool
--- @field Dodge int32
--- @field DrinkedPotion bool
--- @field DrunkImmunity bool
--- @field DualWielding int32
--- @field DynamicStats StatsCharacterDynamicStat[]
--- @field EarthResistance int32
--- @field EarthSpecialist int32
--- @field EnragedImmunity bool
--- @field EntangledContact bool
--- @field EquipmentValidated bool
--- @field Experience int32
--- @field FearImmunity bool
--- @field Finesse int32
--- @field FireResistance int32
--- @field FireSpecialist int32
--- @field Flags StatsCharacterFlags
--- @field Flanked uint8
--- @field Floating bool
--- @field FreezeContact bool
--- @field FreezeImmunity bool
--- @field Grounded bool
--- @field HasTwoHandedWeapon int32
--- @field HastedImmunity bool
--- @field Hearing int32
--- @field IgnoreClouds bool
--- @field IgnoreCursedOil bool
--- @field InParty bool
--- @field InfectiousDiseasedImmunity bool
--- @field Initiative int32
--- @field Intelligence int32
--- @field Intimidate int32
--- @field InvisibilityImmunity bool
--- @field Invisible bool
--- @field IsIncapacitatedRefCount int32
--- @field IsPlayer bool
--- @field IsSneaking bool
--- @field ItemBoostedAttributeFlags StatAttributeFlags
--- @field Karma int32
--- @field KnockdownImmunity bool
--- @field Leadership int32
--- @field LifeSteal int32
--- @field LootableWhenEquipped bool
--- @field Loremaster int32
--- @field LoseDurabilityOnCharacterHit bool
--- @field Luck int32
--- @field MPStart int32
--- @field MadnessImmunity bool
--- @field MagicArmorAfterHitCooldownMultiplier int32
--- @field MagicArmorMastery int32
--- @field MagicResistance int32
--- @field MagicalSulfur bool
--- @field MainWeapon CDivinityStatsItem
--- @field MaxArmor int32
--- @field MaxMagicArmor int32
--- @field MaxMp int32
--- @field MaxMpOverride int32
--- @field MaxResistance int32
--- @field MaxSummons int32
--- @field MaxVitality int32
--- @field Memory int32
--- @field Movement int32
--- @field MuteImmunity bool
--- @field MyGuid FixedString
--- @field Necromancy int32
--- @field NetID NetId
--- @field OffHandWeapon CDivinityStatsItem
--- @field PainReflection int32
--- @field Perseverance int32
--- @field Persuasion int32
--- @field PetrifiedImmunity bool
--- @field PhysicalArmorMastery int32
--- @field PhysicalResistance int32
--- @field Pickpocket int32
--- @field PickpocketableWhenEquipped bool
--- @field PiercingResistance int32
--- @field PoisonContact bool
--- @field PoisonImmunity bool
--- @field PoisonResistance int32
--- @field Polymorph int32
--- @field Position vec3
--- @field ProtectFromSummon bool
--- @field Ranged int32
--- @field RangerLore int32
--- @field Reason int32
--- @field Reflexes int32
--- @field RegeneratingImmunity bool
--- @field Repair int32
--- @field Reputation int32
--- @field RogueLore int32
--- @field Runecrafting int32
--- @field Sentinel int32
--- @field ShacklesOfPainImmunity bool
--- @field ShadowResistance int32
--- @field Shield int32
--- @field ShockedImmunity bool
--- @field Sight int32
--- @field SingleHanded int32
--- @field SleepingImmunity bool
--- @field SlippingImmunity bool
--- @field SlowedImmunity bool
--- @field Sneaking int32
--- @field Sourcery int32
--- @field StatsFromStatsEntry StatsCharacterDynamicStat
--- @field Strength int32
--- @field StunContact bool
--- @field StunImmunity bool
--- @field SuffocatingImmunity bool
--- @field Sulfurology int32
--- @field Summoning int32
--- @field SurfacePathInfluences SurfacePathInfluence[]
--- @field TALENT_ActionPoints bool
--- @field TALENT_ActionPoints2 bool
--- @field TALENT_AirSpells bool
--- @field TALENT_Ambidextrous bool
--- @field TALENT_AnimalEmpathy bool
--- @field TALENT_AttackOfOpportunity bool
--- @field TALENT_AvoidDetection bool
--- @field TALENT_Awareness bool
--- @field TALENT_Backstab bool
--- @field TALENT_BeastMaster bool
--- @field TALENT_Bully bool
--- @field TALENT_Carry bool
--- @field TALENT_ChanceToHitMelee bool
--- @field TALENT_ChanceToHitRanged bool
--- @field TALENT_Charm bool
--- @field TALENT_Courageous bool
--- @field TALENT_Criticals bool
--- @field TALENT_Damage bool
--- @field TALENT_DeathfogResistant bool
--- @field TALENT_Demon bool
--- @field TALENT_DualWieldingDodging bool
--- @field TALENT_Durability bool
--- @field TALENT_Dwarf_Sneaking bool
--- @field TALENT_Dwarf_Sturdy bool
--- @field TALENT_EarthSpells bool
--- @field TALENT_ElementalAffinity bool
--- @field TALENT_ElementalRanger bool
--- @field TALENT_Elementalist bool
--- @field TALENT_Elf_CorpseEating bool
--- @field TALENT_Elf_Lore bool
--- @field TALENT_Escapist bool
--- @field TALENT_Executioner bool
--- @field TALENT_ExpGain bool
--- @field TALENT_ExtraSkillPoints bool
--- @field TALENT_ExtraStatPoints bool
--- @field TALENT_FaroutDude bool
--- @field TALENT_FireSpells bool
--- @field TALENT_FiveStarRestaurant bool
--- @field TALENT_Flanking bool
--- @field TALENT_FolkDancer bool
--- @field TALENT_Gladiator bool
--- @field TALENT_GoldenMage bool
--- @field TALENT_GreedyVessel bool
--- @field TALENT_Haymaker bool
--- @field TALENT_Human_Civil bool
--- @field TALENT_Human_Inventive bool
--- @field TALENT_IceKing bool
--- @field TALENT_IncreasedArmor bool
--- @field TALENT_Indomitable bool
--- @field TALENT_Initiative bool
--- @field TALENT_Intimidate bool
--- @field TALENT_InventoryAccess bool
--- @field TALENT_ItemCreation bool
--- @field TALENT_ItemMovement bool
--- @field TALENT_Jitterbug bool
--- @field TALENT_Kickstarter bool
--- @field TALENT_Leech bool
--- @field TALENT_LightStep bool
--- @field TALENT_LightningRod bool
--- @field TALENT_LivingArmor bool
--- @field TALENT_Lizard_Persuasion bool
--- @field TALENT_Lizard_Resistance bool
--- @field TALENT_Lockpick bool
--- @field TALENT_LoneWolf bool
--- @field TALENT_Luck bool
--- @field TALENT_MagicCycles bool
--- @field TALENT_MasterThief bool
--- @field TALENT_Max bool
--- @field TALENT_Memory bool
--- @field TALENT_MrKnowItAll bool
--- @field TALENT_NaturalConductor bool
--- @field TALENT_NoAttackOfOpportunity bool
--- @field TALENT_None bool
--- @field TALENT_PainDrinker bool
--- @field TALENT_Perfectionist bool
--- @field TALENT_Politician bool
--- @field TALENT_Quest_GhostTree bool
--- @field TALENT_Quest_Rooted bool
--- @field TALENT_Quest_SpidersKiss_Int bool
--- @field TALENT_Quest_SpidersKiss_Null bool
--- @field TALENT_Quest_SpidersKiss_Per bool
--- @field TALENT_Quest_SpidersKiss_Str bool
--- @field TALENT_Quest_TradeSecrets bool
--- @field TALENT_QuickStep bool
--- @field TALENT_Rager bool
--- @field TALENT_Raistlin bool
--- @field TALENT_RangerLoreArrowRecover bool
--- @field TALENT_RangerLoreEvasionBonus bool
--- @field TALENT_RangerLoreRangedAPBonus bool
--- @field TALENT_Reason bool
--- @field TALENT_Repair bool
--- @field TALENT_ResistDead bool
--- @field TALENT_ResistFear bool
--- @field TALENT_ResistKnockdown bool
--- @field TALENT_ResistPoison bool
--- @field TALENT_ResistSilence bool
--- @field TALENT_ResistStun bool
--- @field TALENT_ResurrectExtraHealth bool
--- @field TALENT_ResurrectToFullHealth bool
--- @field TALENT_RogueLoreDaggerAPBonus bool
--- @field TALENT_RogueLoreDaggerBackStab bool
--- @field TALENT_RogueLoreGrenadePrecision bool
--- @field TALENT_RogueLoreHoldResistance bool
--- @field TALENT_RogueLoreMovementBonus bool
--- @field TALENT_Sadist bool
--- @field TALENT_Scientist bool
--- @field TALENT_Sight bool
--- @field TALENT_Soulcatcher bool
--- @field TALENT_Sourcerer bool
--- @field TALENT_SpillNoBlood bool
--- @field TALENT_StandYourGround bool
--- @field TALENT_Stench bool
--- @field TALENT_SurpriseAttack bool
--- @field TALENT_Throwing bool
--- @field TALENT_Torturer bool
--- @field TALENT_Trade bool
--- @field TALENT_Unstable bool
--- @field TALENT_ViolentMagic bool
--- @field TALENT_Vitality bool
--- @field TALENT_WalkItOff bool
--- @field TALENT_WandCharge bool
--- @field TALENT_WarriorLoreGrenadeRange bool
--- @field TALENT_WarriorLoreNaturalArmor bool
--- @field TALENT_WarriorLoreNaturalHealth bool
--- @field TALENT_WarriorLoreNaturalResistance bool
--- @field TALENT_WaterSpells bool
--- @field TALENT_WeatherProof bool
--- @field TALENT_WhatARush bool
--- @field TALENT_WildMag bool
--- @field TALENT_Zombie bool
--- @field TauntedImmunity bool
--- @field Telekinesis int32
--- @field Thievery int32
--- @field ThrownImmunity bool
--- @field Torch bool
--- @field TraitOrder int32[]
--- @field TwoHanded int32
--- @field Unbreakable bool
--- @field Unrepairable bool
--- @field Unstorable bool
--- @field VitalityMastery int32
--- @field Wand int32
--- @field WarmImmunity bool
--- @field WarriorLore int32
--- @field WaterResistance int32
--- @field WaterSpecialist int32
--- @field WeakImmunity bool
--- @field WebImmunity bool
--- @field WetImmunity bool
--- @field Wits int32
--- @field GetItemBySlot fun(self: CDivinityStatsCharacter, slot: StatsItemSlot, mustBeEquipped: bool|nil):CDivinityStatsItem


--- @class CDivinityStatsEquipmentAttributes
--- @field APRecovery int32
--- @field AccuracyBoost int32
--- @field AcidImmunity bool
--- @field AirResistance int32
--- @field AirSpecialist int32
--- @field Arrow bool
--- @field Barter int32
--- @field BleedingImmunity bool
--- @field BlessedImmunity bool
--- @field BlindImmunity bool
--- @field Bodybuilding int32
--- @field BoostName FixedString
--- @field Brewmaster int32
--- @field BurnContact bool
--- @field BurnImmunity bool
--- @field ChanceToHitBoost int32
--- @field Charm int32
--- @field CharmImmunity bool
--- @field ChickenImmunity bool
--- @field ChillContact bool
--- @field ChilledImmunity bool
--- @field ClairvoyantImmunity bool
--- @field ConstitutionBoost int32
--- @field CorrosiveResistance int32
--- @field Crafting int32
--- @field CrippledImmunity bool
--- @field CriticalChance int32
--- @field CursedImmunity bool
--- @field CustomResistance int32
--- @field DecayingImmunity bool
--- @field DeflectProjectiles bool
--- @field DisarmedImmunity bool
--- @field DiseasedImmunity bool
--- @field DodgeBoost int32
--- @field DrunkImmunity bool
--- @field DualWielding int32
--- @field Durability int32
--- @field DurabilityDegradeSpeed int32
--- @field EarthResistance int32
--- @field EarthSpecialist int32
--- @field EnragedImmunity bool
--- @field EntangledContact bool
--- @field FearImmunity bool
--- @field FinesseBoost int32
--- @field FireResistance int32
--- @field FireSpecialist int32
--- @field Floating bool
--- @field FreezeContact bool
--- @field FreezeImmunity bool
--- @field Grounded bool
--- @field HastedImmunity bool
--- @field HearingBoost int32
--- @field IgnoreClouds bool
--- @field IgnoreCursedOil bool
--- @field InfectiousDiseasedImmunity bool
--- @field Initiative int32
--- @field IntelligenceBoost int32
--- @field Intimidate int32
--- @field InvisibilityImmunity bool
--- @field ItemColor FixedString
--- @field KnockdownImmunity bool
--- @field Leadership int32
--- @field LifeSteal int32
--- @field LootableWhenEquipped bool
--- @field Loremaster int32
--- @field LoseDurabilityOnCharacterHit bool
--- @field Luck int32
--- @field MadnessImmunity bool
--- @field MagicArmorMastery int32
--- @field MagicResistance int32
--- @field MagicalSulfur bool
--- @field MaxAP int32
--- @field MaxSummons int32
--- @field MemoryBoost int32
--- @field ModifierType uint32
--- @field Movement int32
--- @field MovementSpeedBoost int32
--- @field MuteImmunity bool
--- @field Necromancy int32
--- @field ObjectInstanceName FixedString
--- @field PainReflection int32
--- @field Perseverance int32
--- @field Persuasion int32
--- @field PetrifiedImmunity bool
--- @field PhysicalArmorMastery int32
--- @field PhysicalResistance int32
--- @field Pickpocket int32
--- @field PickpocketableWhenEquipped bool
--- @field PiercingResistance int32
--- @field PoisonContact bool
--- @field PoisonImmunity bool
--- @field PoisonResistance int32
--- @field Polymorph int32
--- @field ProtectFromSummon bool
--- @field Ranged int32
--- @field RangerLore int32
--- @field Reason int32
--- @field Reflection StatsReflectionSet
--- @field Reflexes int32
--- @field RegeneratingImmunity bool
--- @field Repair int32
--- @field RogueLore int32
--- @field RuneSlots int32
--- @field RuneSlots_V1 int32
--- @field Runecrafting int32
--- @field Sentinel int32
--- @field ShacklesOfPainImmunity bool
--- @field ShadowResistance int32
--- @field Shield int32
--- @field ShockedImmunity bool
--- @field SightBoost int32
--- @field SingleHanded int32
--- @field Skills FixedString
--- @field SleepingImmunity bool
--- @field SlippingImmunity bool
--- @field SlowedImmunity bool
--- @field Sneaking int32
--- @field SourcePointsBoost int32
--- @field Sourcery int32
--- @field StartAP int32
--- @field StatsType StatsEquipmentStatsType
--- @field StrengthBoost int32
--- @field StunContact bool
--- @field StunImmunity bool
--- @field SuffocatingImmunity bool
--- @field Sulfurology int32
--- @field Summoning int32
--- @field TALENT_ActionPoints bool
--- @field TALENT_ActionPoints2 bool
--- @field TALENT_AirSpells bool
--- @field TALENT_Ambidextrous bool
--- @field TALENT_AnimalEmpathy bool
--- @field TALENT_AttackOfOpportunity bool
--- @field TALENT_AvoidDetection bool
--- @field TALENT_Awareness bool
--- @field TALENT_Backstab bool
--- @field TALENT_BeastMaster bool
--- @field TALENT_Bully bool
--- @field TALENT_Carry bool
--- @field TALENT_ChanceToHitMelee bool
--- @field TALENT_ChanceToHitRanged bool
--- @field TALENT_Charm bool
--- @field TALENT_Courageous bool
--- @field TALENT_Criticals bool
--- @field TALENT_Damage bool
--- @field TALENT_DeathfogResistant bool
--- @field TALENT_Demon bool
--- @field TALENT_DualWieldingDodging bool
--- @field TALENT_Durability bool
--- @field TALENT_Dwarf_Sneaking bool
--- @field TALENT_Dwarf_Sturdy bool
--- @field TALENT_EarthSpells bool
--- @field TALENT_ElementalAffinity bool
--- @field TALENT_ElementalRanger bool
--- @field TALENT_Elementalist bool
--- @field TALENT_Elf_CorpseEating bool
--- @field TALENT_Elf_Lore bool
--- @field TALENT_Escapist bool
--- @field TALENT_Executioner bool
--- @field TALENT_ExpGain bool
--- @field TALENT_ExtraSkillPoints bool
--- @field TALENT_ExtraStatPoints bool
--- @field TALENT_FaroutDude bool
--- @field TALENT_FireSpells bool
--- @field TALENT_FiveStarRestaurant bool
--- @field TALENT_Flanking bool
--- @field TALENT_FolkDancer bool
--- @field TALENT_Gladiator bool
--- @field TALENT_GoldenMage bool
--- @field TALENT_GreedyVessel bool
--- @field TALENT_Haymaker bool
--- @field TALENT_Human_Civil bool
--- @field TALENT_Human_Inventive bool
--- @field TALENT_IceKing bool
--- @field TALENT_IncreasedArmor bool
--- @field TALENT_Indomitable bool
--- @field TALENT_Initiative bool
--- @field TALENT_Intimidate bool
--- @field TALENT_InventoryAccess bool
--- @field TALENT_ItemCreation bool
--- @field TALENT_ItemMovement bool
--- @field TALENT_Jitterbug bool
--- @field TALENT_Kickstarter bool
--- @field TALENT_Leech bool
--- @field TALENT_LightStep bool
--- @field TALENT_LightningRod bool
--- @field TALENT_LivingArmor bool
--- @field TALENT_Lizard_Persuasion bool
--- @field TALENT_Lizard_Resistance bool
--- @field TALENT_Lockpick bool
--- @field TALENT_LoneWolf bool
--- @field TALENT_Luck bool
--- @field TALENT_MagicCycles bool
--- @field TALENT_MasterThief bool
--- @field TALENT_Max bool
--- @field TALENT_Memory bool
--- @field TALENT_MrKnowItAll bool
--- @field TALENT_NaturalConductor bool
--- @field TALENT_NoAttackOfOpportunity bool
--- @field TALENT_None bool
--- @field TALENT_PainDrinker bool
--- @field TALENT_Perfectionist bool
--- @field TALENT_Politician bool
--- @field TALENT_Quest_GhostTree bool
--- @field TALENT_Quest_Rooted bool
--- @field TALENT_Quest_SpidersKiss_Int bool
--- @field TALENT_Quest_SpidersKiss_Null bool
--- @field TALENT_Quest_SpidersKiss_Per bool
--- @field TALENT_Quest_SpidersKiss_Str bool
--- @field TALENT_Quest_TradeSecrets bool
--- @field TALENT_QuickStep bool
--- @field TALENT_Rager bool
--- @field TALENT_Raistlin bool
--- @field TALENT_RangerLoreArrowRecover bool
--- @field TALENT_RangerLoreEvasionBonus bool
--- @field TALENT_RangerLoreRangedAPBonus bool
--- @field TALENT_Reason bool
--- @field TALENT_Repair bool
--- @field TALENT_ResistDead bool
--- @field TALENT_ResistFear bool
--- @field TALENT_ResistKnockdown bool
--- @field TALENT_ResistPoison bool
--- @field TALENT_ResistSilence bool
--- @field TALENT_ResistStun bool
--- @field TALENT_ResurrectExtraHealth bool
--- @field TALENT_ResurrectToFullHealth bool
--- @field TALENT_RogueLoreDaggerAPBonus bool
--- @field TALENT_RogueLoreDaggerBackStab bool
--- @field TALENT_RogueLoreGrenadePrecision bool
--- @field TALENT_RogueLoreHoldResistance bool
--- @field TALENT_RogueLoreMovementBonus bool
--- @field TALENT_Sadist bool
--- @field TALENT_Scientist bool
--- @field TALENT_Sight bool
--- @field TALENT_Soulcatcher bool
--- @field TALENT_Sourcerer bool
--- @field TALENT_SpillNoBlood bool
--- @field TALENT_StandYourGround bool
--- @field TALENT_Stench bool
--- @field TALENT_SurpriseAttack bool
--- @field TALENT_Throwing bool
--- @field TALENT_Torturer bool
--- @field TALENT_Trade bool
--- @field TALENT_Unstable bool
--- @field TALENT_ViolentMagic bool
--- @field TALENT_Vitality bool
--- @field TALENT_WalkItOff bool
--- @field TALENT_WandCharge bool
--- @field TALENT_WarriorLoreGrenadeRange bool
--- @field TALENT_WarriorLoreNaturalArmor bool
--- @field TALENT_WarriorLoreNaturalHealth bool
--- @field TALENT_WarriorLoreNaturalResistance bool
--- @field TALENT_WaterSpells bool
--- @field TALENT_WeatherProof bool
--- @field TALENT_WhatARush bool
--- @field TALENT_WildMag bool
--- @field TALENT_Zombie bool
--- @field TauntedImmunity bool
--- @field Telekinesis int32
--- @field Thievery int32
--- @field ThrownImmunity bool
--- @field Torch bool
--- @field TwoHanded int32
--- @field Unbreakable bool
--- @field Unrepairable bool
--- @field Unstorable bool
--- @field Value int32
--- @field VitalityBoost int32
--- @field VitalityMastery int32
--- @field Wand int32
--- @field WarmImmunity bool
--- @field WarriorLore int32
--- @field WaterResistance int32
--- @field WaterSpecialist int32
--- @field WeakImmunity bool
--- @field WebImmunity bool
--- @field Weight int32
--- @field WetImmunity bool
--- @field Willpower int32
--- @field WitsBoost int32


--- @class CDivinityStatsEquipmentAttributesArmor : CDivinityStatsEquipmentAttributes
--- @field ArmorBoost int32
--- @field ArmorValue int32
--- @field MagicArmorBoost int32
--- @field MagicArmorValue int32


--- @class CDivinityStatsEquipmentAttributesShield : CDivinityStatsEquipmentAttributes
--- @field ArmorBoost int32
--- @field ArmorValue int32
--- @field Blocking int32
--- @field MagicArmorBoost int32
--- @field MagicArmorValue int32


--- @class CDivinityStatsEquipmentAttributesWeapon : CDivinityStatsEquipmentAttributes
--- @field AttackAPCost int32
--- @field CleaveAngle int32
--- @field CleavePercentage float
--- @field CriticalDamage int32
--- @field DamageBoost int32
--- @field DamageFromBase int32
--- @field DamageType StatsDamageType
--- @field MaxDamage int32
--- @field MinDamage int32
--- @field Projectile FixedString
--- @field WeaponRange float


--- @class CDivinityStatsItem : StatsObjectInstance
--- @field AcidImmunity bool
--- @field AirSpecialist int32
--- @field AnimType int32
--- @field Arrow bool
--- @field AttributeFlags StatAttributeFlags
--- @field Barter int32
--- @field BaseAirSpecialist int32
--- @field BaseBarter int32
--- @field BaseBrewmaster int32
--- @field BaseCharm int32
--- @field BaseCrafting int32
--- @field BaseDualWielding int32
--- @field BaseEarthSpecialist int32
--- @field BaseFireSpecialist int32
--- @field BaseIntimidate int32
--- @field BaseLeadership int32
--- @field BaseLoremaster int32
--- @field BaseLuck int32
--- @field BaseMagicArmorMastery int32
--- @field BaseNecromancy int32
--- @field BasePainReflection int32
--- @field BasePerseverance int32
--- @field BasePersuasion int32
--- @field BasePhysicalArmorMastery int32
--- @field BasePickpocket int32
--- @field BasePolymorph int32
--- @field BaseRanged int32
--- @field BaseRangerLore int32
--- @field BaseReason int32
--- @field BaseReflexes int32
--- @field BaseRepair int32
--- @field BaseRogueLore int32
--- @field BaseRunecrafting int32
--- @field BaseSentinel int32
--- @field BaseShield int32
--- @field BaseSingleHanded int32
--- @field BaseSneaking int32
--- @field BaseSourcery int32
--- @field BaseSulfurology int32
--- @field BaseSummoning int32
--- @field BaseTelekinesis int32
--- @field BaseThievery int32
--- @field BaseTwoHanded int32
--- @field BaseVitalityMastery int32
--- @field BaseWand int32
--- @field BaseWarriorLore int32
--- @field BaseWaterSpecialist int32
--- @field BleedingImmunity bool
--- @field BlessedImmunity bool
--- @field BlindImmunity bool
--- @field Brewmaster int32
--- @field BurnContact bool
--- @field BurnImmunity bool
--- @field Charges int32
--- @field Charm int32
--- @field CharmImmunity bool
--- @field ChickenImmunity bool
--- @field ChillContact bool
--- @field ChilledImmunity bool
--- @field ClairvoyantImmunity bool
--- @field Crafting int32
--- @field CrippledImmunity bool
--- @field CursedImmunity bool
--- @field DamageTypeOverwrite StatsDamageType
--- @field DecayingImmunity bool
--- @field DeflectProjectiles bool
--- @field DeltaMods FixedString[]
--- @field DisarmedImmunity bool
--- @field DiseasedImmunity bool
--- @field DrunkImmunity bool
--- @field DualWielding int32
--- @field Durability uint32
--- @field DurabilityCounter uint32
--- @field DynamicStats CDivinityStatsEquipmentAttributes[]
--- @field EarthSpecialist int32
--- @field EnragedImmunity bool
--- @field EntangledContact bool
--- @field EquipmentType StatsEquipmentStatsType
--- @field FearImmunity bool
--- @field FireSpecialist int32
--- @field Floating bool
--- @field FreezeContact bool
--- @field FreezeImmunity bool
--- @field GameObject IGameObject
--- @field Grounded bool
--- @field HasModifiedSkills bool
--- @field HastedImmunity bool
--- @field IgnoreClouds bool
--- @field IgnoreCursedOil bool
--- @field InfectiousDiseasedImmunity bool
--- @field Intimidate int32
--- @field InvisibilityImmunity bool
--- @field IsIdentified uint32
--- @field IsTwoHanded bool
--- @field ItemSlot StatsItemSlot32
--- @field ItemType StatsEquipmentStatsType
--- @field ItemTypeReal FixedString
--- @field KnockdownImmunity bool
--- @field Leadership int32
--- @field LevelGroupIndex uint8
--- @field LootableWhenEquipped bool
--- @field Loremaster int32
--- @field LoseDurabilityOnCharacterHit bool
--- @field Luck int32
--- @field MadnessImmunity bool
--- @field MagicArmorMastery int32
--- @field MagicalSulfur bool
--- @field MaxCharges int32
--- @field MuteImmunity bool
--- @field NameCool uint32
--- @field NameGroupIndex uint8
--- @field NameIndex uint8
--- @field Necromancy int32
--- @field PainReflection int32
--- @field Perseverance int32
--- @field Persuasion int32
--- @field PetrifiedImmunity bool
--- @field PhysicalArmorMastery int32
--- @field Pickpocket int32
--- @field PickpocketableWhenEquipped bool
--- @field PoisonContact bool
--- @field PoisonImmunity bool
--- @field Polymorph int32
--- @field ProtectFromSummon bool
--- @field Ranged int32
--- @field RangerLore int32
--- @field Rarity FixedString
--- @field Reason int32
--- @field Reflexes int32
--- @field RegeneratingImmunity bool
--- @field Repair int32
--- @field RogueLore int32
--- @field RootGroupIndex uint8
--- @field Runecrafting int32
--- @field Sentinel int32
--- @field ShacklesOfPainImmunity bool
--- @field Shield int32
--- @field ShockedImmunity bool
--- @field ShouldSyncStats bool
--- @field SingleHanded int32
--- @field Skills FixedString
--- @field SleepingImmunity bool
--- @field SlippingImmunity bool
--- @field SlowedImmunity bool
--- @field Sneaking int32
--- @field Sourcery int32
--- @field StunContact bool
--- @field StunImmunity bool
--- @field SuffocatingImmunity bool
--- @field Sulfurology int32
--- @field Summoning int32
--- @field TALENT_ActionPoints bool
--- @field TALENT_ActionPoints2 bool
--- @field TALENT_AirSpells bool
--- @field TALENT_Ambidextrous bool
--- @field TALENT_AnimalEmpathy bool
--- @field TALENT_AttackOfOpportunity bool
--- @field TALENT_AvoidDetection bool
--- @field TALENT_Awareness bool
--- @field TALENT_Backstab bool
--- @field TALENT_BeastMaster bool
--- @field TALENT_Bully bool
--- @field TALENT_Carry bool
--- @field TALENT_ChanceToHitMelee bool
--- @field TALENT_ChanceToHitRanged bool
--- @field TALENT_Charm bool
--- @field TALENT_Courageous bool
--- @field TALENT_Criticals bool
--- @field TALENT_Damage bool
--- @field TALENT_DeathfogResistant bool
--- @field TALENT_Demon bool
--- @field TALENT_DualWieldingDodging bool
--- @field TALENT_Durability bool
--- @field TALENT_Dwarf_Sneaking bool
--- @field TALENT_Dwarf_Sturdy bool
--- @field TALENT_EarthSpells bool
--- @field TALENT_ElementalAffinity bool
--- @field TALENT_ElementalRanger bool
--- @field TALENT_Elementalist bool
--- @field TALENT_Elf_CorpseEating bool
--- @field TALENT_Elf_Lore bool
--- @field TALENT_Escapist bool
--- @field TALENT_Executioner bool
--- @field TALENT_ExpGain bool
--- @field TALENT_ExtraSkillPoints bool
--- @field TALENT_ExtraStatPoints bool
--- @field TALENT_FaroutDude bool
--- @field TALENT_FireSpells bool
--- @field TALENT_FiveStarRestaurant bool
--- @field TALENT_Flanking bool
--- @field TALENT_FolkDancer bool
--- @field TALENT_Gladiator bool
--- @field TALENT_GoldenMage bool
--- @field TALENT_GreedyVessel bool
--- @field TALENT_Haymaker bool
--- @field TALENT_Human_Civil bool
--- @field TALENT_Human_Inventive bool
--- @field TALENT_IceKing bool
--- @field TALENT_IncreasedArmor bool
--- @field TALENT_Indomitable bool
--- @field TALENT_Initiative bool
--- @field TALENT_Intimidate bool
--- @field TALENT_InventoryAccess bool
--- @field TALENT_ItemCreation bool
--- @field TALENT_ItemMovement bool
--- @field TALENT_Jitterbug bool
--- @field TALENT_Kickstarter bool
--- @field TALENT_Leech bool
--- @field TALENT_LightStep bool
--- @field TALENT_LightningRod bool
--- @field TALENT_LivingArmor bool
--- @field TALENT_Lizard_Persuasion bool
--- @field TALENT_Lizard_Resistance bool
--- @field TALENT_Lockpick bool
--- @field TALENT_LoneWolf bool
--- @field TALENT_Luck bool
--- @field TALENT_MagicCycles bool
--- @field TALENT_MasterThief bool
--- @field TALENT_Max bool
--- @field TALENT_Memory bool
--- @field TALENT_MrKnowItAll bool
--- @field TALENT_NaturalConductor bool
--- @field TALENT_NoAttackOfOpportunity bool
--- @field TALENT_None bool
--- @field TALENT_PainDrinker bool
--- @field TALENT_Perfectionist bool
--- @field TALENT_Politician bool
--- @field TALENT_Quest_GhostTree bool
--- @field TALENT_Quest_Rooted bool
--- @field TALENT_Quest_SpidersKiss_Int bool
--- @field TALENT_Quest_SpidersKiss_Null bool
--- @field TALENT_Quest_SpidersKiss_Per bool
--- @field TALENT_Quest_SpidersKiss_Str bool
--- @field TALENT_Quest_TradeSecrets bool
--- @field TALENT_QuickStep bool
--- @field TALENT_Rager bool
--- @field TALENT_Raistlin bool
--- @field TALENT_RangerLoreArrowRecover bool
--- @field TALENT_RangerLoreEvasionBonus bool
--- @field TALENT_RangerLoreRangedAPBonus bool
--- @field TALENT_Reason bool
--- @field TALENT_Repair bool
--- @field TALENT_ResistDead bool
--- @field TALENT_ResistFear bool
--- @field TALENT_ResistKnockdown bool
--- @field TALENT_ResistPoison bool
--- @field TALENT_ResistSilence bool
--- @field TALENT_ResistStun bool
--- @field TALENT_ResurrectExtraHealth bool
--- @field TALENT_ResurrectToFullHealth bool
--- @field TALENT_RogueLoreDaggerAPBonus bool
--- @field TALENT_RogueLoreDaggerBackStab bool
--- @field TALENT_RogueLoreGrenadePrecision bool
--- @field TALENT_RogueLoreHoldResistance bool
--- @field TALENT_RogueLoreMovementBonus bool
--- @field TALENT_Sadist bool
--- @field TALENT_Scientist bool
--- @field TALENT_Sight bool
--- @field TALENT_Soulcatcher bool
--- @field TALENT_Sourcerer bool
--- @field TALENT_SpillNoBlood bool
--- @field TALENT_StandYourGround bool
--- @field TALENT_Stench bool
--- @field TALENT_SurpriseAttack bool
--- @field TALENT_Throwing bool
--- @field TALENT_Torturer bool
--- @field TALENT_Trade bool
--- @field TALENT_Unstable bool
--- @field TALENT_ViolentMagic bool
--- @field TALENT_Vitality bool
--- @field TALENT_WalkItOff bool
--- @field TALENT_WandCharge bool
--- @field TALENT_WarriorLoreGrenadeRange bool
--- @field TALENT_WarriorLoreNaturalArmor bool
--- @field TALENT_WarriorLoreNaturalHealth bool
--- @field TALENT_WarriorLoreNaturalResistance bool
--- @field TALENT_WaterSpells bool
--- @field TALENT_WeatherProof bool
--- @field TALENT_WhatARush bool
--- @field TALENT_WildMag bool
--- @field TALENT_Zombie bool
--- @field TauntedImmunity bool
--- @field Telekinesis int32
--- @field Thievery int32
--- @field ThrownImmunity bool
--- @field Torch bool
--- @field TwoHanded int32
--- @field Unbreakable bool
--- @field Unrepairable bool
--- @field Unstorable bool
--- @field VitalityMastery int32
--- @field Wand int32
--- @field WarmImmunity bool
--- @field WarriorLore int32
--- @field WaterSpecialist int32
--- @field WeakImmunity bool
--- @field WeaponRange uint32
--- @field WeaponType StatsWeaponType
--- @field WebImmunity bool
--- @field WetImmunity bool


--- @class CacheTemplateManagerBase
--- @field NewTemplates GameObjectTemplate[]
--- @field RefCountsByHandle table<TemplateHandle, uint32>
--- @field TemplateManagerType TemplateType
--- @field Templates table<FixedString, GameObjectTemplate>
--- @field TemplatesByHandle table<TemplateHandle, GameObjectTemplate>


--- @class CharacterSkillData
--- @field AIParams SkillAIParams
--- @field SkillId FixedString


--- @class CharacterTemplate : EoCGameObjectTemplate
--- @field ActivationGroupId FixedString
--- @field AvoidTraps bool
--- @field BloodSurfaceType SurfaceType
--- @field CanBeTeleported bool
--- @field CanClimbLadders bool
--- @field CanOpenDoors bool
--- @field CanShootThrough bool
--- @field ClimbAttachSpeed float
--- @field ClimbDetachSpeed float
--- @field ClimbLoopSpeed float
--- @field CombatComponent CombatComponentTemplate
--- @field CombatTemplate CombatComponentTemplate
--- @field CoverAmount uint8
--- @field DefaultDialog FixedString
--- @field DefaultState uint32
--- @field EmptyVisualSet bool
--- @field Equipment FixedString
--- @field EquipmentClass uint32
--- @field ExplodedResourceID FixedString
--- @field ExplosionFX FixedString
--- @field Floating bool
--- @field FootstepWeight uint32
--- @field ForceUnsheathSkills bool
--- @field GeneratePortrait STDString
--- @field GhostTemplate FixedString
--- @field HardcoreOnly bool
--- @field HitFX FixedString
--- @field Icon FixedString
--- @field InfluenceTreasureLevel bool
--- @field InventoryType uint32
--- @field IsArenaChampion bool
--- @field IsEquipmentLootable bool
--- @field IsHuge bool
--- @field IsLootable bool
--- @field IsPlayer bool
--- @field ItemList InventoryItemData[]
--- @field JumpUpLadders bool
--- @field LevelOverride int32
--- @field LightID FixedString
--- @field NoRotate bool
--- @field NotHardcore bool
--- @field OnDeathActions IActionData[]
--- @field PickingPhysicsTemplates table<FixedString, FixedString>
--- @field RagdollTemplate FixedString
--- @field RunSpeed float
--- @field SkillList CharacterSkillData[]
--- @field SkillSet FixedString
--- @field SoftBodyCollisionTemplate FixedString
--- @field SoundAttachBone FixedString
--- @field SoundAttenuation int16
--- @field SoundInitEvent FixedString
--- @field SpeakerGroup STDString
--- @field SpotSneakers bool
--- @field Stats FixedString
--- @field TradeTreasures FixedString[]
--- @field Treasures FixedString[]
--- @field TrophyID FixedString
--- @field VisualSet VisualSet
--- @field VisualSetIndices uint64
--- @field VisualSetResourceID FixedString
--- @field WalkSpeed float
--- @field WalkThrough bool
--- @field GetColorChoices fun(self: CharacterTemplate, slot: VisualTemplateColorIndex):uint32[]
--- @field GetVisualChoices fun(self: CharacterTemplate, slot: VisualTemplateVisualIndex):FixedString[]


--- @class CombatComponentTemplate
--- @field Alignment FixedString
--- @field CanFight bool
--- @field CanJoinCombat bool
--- @field CombatGroupID FixedString
--- @field IsBoss bool
--- @field IsInspector bool
--- @field StartCombatRange float


--- @class ComponentHandleWithType
--- @field Handle ComponentHandle
--- @field TypeId int64


--- @class ConstrainActionData : IActionData
--- @field Damage float


--- @class ConsumeActionData : IActionData
--- @field Consume bool
--- @field StatsId FixedString


--- @class CraftActionData : IActionData
--- @field CraftingStationType CraftingStationType


--- @class CreatePuddleActionData : IActionData
--- @field CellAtGrow int32
--- @field ExternalCauseAsSurfaceOwner bool
--- @field GrowTimer float
--- @field LifeTime float
--- @field SurfaceType SurfaceType
--- @field Timeout float
--- @field TotalCells int32


--- @class CreateSurfaceActionData : IActionData
--- @field ExternalCauseAsSurfaceOwner bool
--- @field LifeTime float
--- @field Radius float
--- @field SurfaceType SurfaceType


--- @class CrimeAreaTriggerData : ITriggerData
--- @field CrimeArea int16


--- @class CrimeRegionTriggerData : ITriggerData
--- @field TriggerRegion FixedString


--- @class DefaultServerOnlyTriggerData : ITriggerData


--- @class DefaultSyncedTriggerData : ITriggerData


--- @class DeferredLoadableResource : Resource


--- @class DestroyParametersData : IActionData
--- @field ExplodeFX FixedString
--- @field TemplateAfterDestruction FixedString
--- @field VisualDestruction FixedString


--- @class DisarmTrapActionData : IActionData
--- @field Consume bool


--- @class DoorActionData : IActionData
--- @field SecretDoor bool


--- @class DragDropManager
--- @field PlayerDragDrops table<int16, DragDropManagerPlayerDragInfo>
--- @field StartDraggingName fun(self: DragDropManager, playerId: int16, objectId: FixedString):bool
--- @field StartDraggingObject fun(self: DragDropManager, playerId: int16, objectHandle: ComponentHandle):bool
--- @field StopDragging fun(self: DragDropManager, playerId: int16):bool


--- @class DragDropManagerPlayerDragInfo
--- @field DragId FixedString
--- @field DragObject ComponentHandle
--- @field IsActive bool
--- @field IsDragging bool
--- @field MousePos vec2


--- @class EoCGameObjectTemplate : GameObjectTemplate
--- @field AIBoundsAIType uint8
--- @field AIBoundsHeight float
--- @field AIBoundsMax vec3
--- @field AIBoundsMin vec3
--- @field AIBoundsRadius float
--- @field DisplayName TranslatedString
--- @field FadeGroup FixedString
--- @field FadeIn bool
--- @field Fadeable bool
--- @field GameMasterSpawnSection int32
--- @field GameMasterSpawnSubSection TranslatedString
--- @field Opacity float
--- @field SeeThrough bool


--- @class EventTriggerData : ITriggerData
--- @field EnterEvent FixedString
--- @field LeaveEvent FixedString


--- @class ExplorationTriggerData : ITriggerData
--- @field ExplorationReward int32


--- @class FireEventDesc
--- @field DeviceId int16
--- @field Event InputEvent
--- @field EventDesc InputEventDesc
--- @field PlayerIndex int32


--- @class GameObjectTemplate
--- @field AllowReceiveDecalWhenAnimated bool
--- @field CameraOffset vec3
--- @field CastShadow bool
--- @field FileName Path
--- @field Flags GameObjectTemplateFlags
--- @field GroupID uint32
--- @field Handle uint32
--- @field HasGameplayValue bool
--- @field HasParentModRelation bool
--- @field Id FixedString
--- @field IsDeleted bool
--- @field IsGlobal bool
--- @field IsReflecting bool
--- @field IsShadowProxy bool
--- @field LevelName FixedString
--- @field ModFolder FixedString
--- @field Name STDString
--- @field NonUniformScale bool
--- @field PhysicsTemplate FixedString
--- @field ReceiveDecal bool
--- @field RenderChannel uint8
--- @field RootTemplate FixedString
--- @field Tags FixedString[]
--- @field Transform Transform
--- @field Type TemplateType
--- @field VisualTemplate FixedString


--- @class GameTime
--- @field DeltaTime float
--- @field Ticks int32
--- @field Time double


--- @class GlobalCacheTemplateManager : CacheTemplateManagerBase


--- @class GlobalSwitches
--- @field AIBoundsSizeMultiplier float
--- @field AddGenericKeyWords bool
--- @field AddStoryKeyWords bool
--- @field AiLevelScaleScores bool
--- @field AiUsePositionScores bool
--- @field AllowMovementFreePointer bool
--- @field AllowXPGain bool
--- @field AlwaysShowSplitterInTrade bool
--- @field ArenaCharacterHighlightFlag bool
--- @field ArenaCharacterHighlightMode int32
--- @field AutoFillHotbarCategories uint8
--- @field AutoRemoveHotbarSkills bool
--- @field CacheDialogs bool
--- @field CameraSpeedMultiplier float
--- @field CanAutoSave bool
--- @field ChatLanguage STDString
--- @field CheckRequirements bool
--- @field Cleave_M bool
--- @field CombatCaracterHighlightFlag bool
--- @field CombatCharacterHighlightMode int32
--- @field ControllerCharacterRunThreshold float
--- @field ControllerCharacterWalkThreshold float
--- @field ControllerLayout uint32
--- @field ControllerMoveSweepCone float
--- @field ControllerSensitivity int32
--- @field ControllerStickDeadZone int32
--- @field ControllerStickPressDeadZone int32
--- @field ControllerTriggerDeadZone int32
--- @field DebugViewType int32
--- @field Difficulty uint8
--- @field DirectConnectAddress STDString
--- @field DisableArmorSavingThrows bool
--- @field DisableEdgePanning bool
--- @field DisableLocalMessagePassing bool
--- @field DisableStoryPatching bool
--- @field DoUnlearnCheck bool
--- @field DualDialogsEnabled bool
--- @field EnableAiThinking bool
--- @field EnableAngularCulling bool
--- @field EnableBlending bool
--- @field EnableGameOver bool
--- @field EnableGenome bool
--- @field EnableModuleHashing bool
--- @field EnablePortmapping bool
--- @field EnableSoundErrorLogging bool
--- @field EnableSteamP2P bool
--- @field EnableVoiceLogging bool
--- @field EscClosesAllUI bool
--- @field FadeCharacters bool
--- @field Fading bool
--- @field FileLoadingLog bool
--- @field FileSavingLog bool
--- @field Floats1 float[]
--- @field Floats2 float[]
--- @field Floats3 float[]
--- @field ForcePort uint16
--- @field ForceSplitscreen bool
--- @field ForceStoryPatching bool
--- @field GameCamAvoidScenery bool
--- @field GameCameraControllerMode bool
--- @field GameCameraEnableCloseUpDialog bool
--- @field GameCameraEnableDynamicCombatCamera bool
--- @field GameCameraRotation float
--- @field GameCameraRotationLocked bool
--- @field GameCameraShakeEnabled bool
--- @field GameMasterBind int32
--- @field GameMode uint8
--- @field GameVisibilityDirect int32
--- @field GameVisibilityLAN int32
--- @field GameVisibilityOnline int32
--- @field GodMode bool
--- @field ItemColorOverride FixedString
--- @field LoadAllEffectPools bool
--- @field LoadScenery bool
--- @field LoadTextShaders bool
--- @field LogSaveLoadErrors bool
--- @field MaxAmountDialogsInLog int32
--- @field MaxNrOfAutoSaves uint32
--- @field MaxNrOfQuickSaves uint32
--- @field MaxNrOfReloadSaves uint32
--- @field MaxRotateSpeed float
--- @field MouseLock bool
--- @field MouseScrollSensitivity int32
--- @field MouseSensitivity int32
--- @field MoveDirectionCount bool
--- @field MuteSoundWhenNotFocused bool
--- @field NextServerMode int32
--- @field NodeWaitTimeMultiplier float
--- @field NrOfAutoSaves uint32
--- @field NrOfQuickSaves uint32
--- @field NrOfReloadSaves uint32
--- @field Options2 GlobalSwitchesSomeOption[]
--- @field OverheadZoomEnabled bool
--- @field OverheadZoomModifier float
--- @field PeaceCharacterHighlightFlag bool
--- @field PeaceCharacterHighlightMode int32
--- @field PeaceMode bool
--- @field ResetTutorialsOnNewGame bool
--- @field RotateMinimap bool
--- @field RotateRampSpeed float
--- @field ScriptLog bool
--- @field ServerFrameCap uint32
--- @field ServerMode int32
--- @field ServerMonitor bool
--- @field ShorOriginIntroInCC bool
--- @field ShowBuildVersion bool
--- @field ShowCharacterCreation bool
--- @field ShowCloths bool
--- @field ShowDebugLines bool
--- @field ShowDrawStats bool
--- @field ShowFPS bool
--- @field ShowLocalizationMarkers bool
--- @field ShowOverheadDialog bool
--- @field ShowOverheadText bool
--- @field ShowPhysXBoxes bool
--- @field ShowPhysics bool
--- @field ShowRagdollInfo bool
--- @field ShowRaycasting bool
--- @field ShowSubtitles bool
--- @field ShowSubtitles2 bool
--- @field ShroudEnabled bool
--- @field SomeAiLogFlag bool
--- @field SomeConditionalStoryLogField bool
--- @field SomePhysXRagdollFlag bool
--- @field SoundPartyLosingThreshold int32
--- @field SoundPartyWinningThreshold int32
--- @field SoundQuality int32
--- @field SoundSettings GlobalSwitchesSoundSetting[]
--- @field StatsArgPassed bool
--- @field Story bool
--- @field StoryEvents bool
--- @field StoryLog bool
--- @field TacticalCharacterHighlightFlag bool
--- @field TacticalCharacterHighlightMode int32
--- @field TexelDensityExtreme float
--- @field TexelDensityIdeal float
--- @field TexelDensityMax float
--- @field TexelDensityMin float
--- @field TutorialBoxMode int32
--- @field UIScaling float
--- @field UpdateInvisibilityOverlayMaterials_M bool
--- @field UpdateOffstageOverlayMaterials_M bool
--- @field UpdatePhysXScene bool
--- @field UpdateScene bool
--- @field UseEndTurnFallback bool
--- @field UseLevelCache bool
--- @field UseRadialContextMenu bool
--- @field VisualizeTextures bool
--- @field WeaponRangeMultiplier float
--- @field YieldOnLostFocus bool
--- @field field_11 bool
--- @field field_14 bool
--- @field field_16 bool
--- @field field_19 bool
--- @field field_1B bool
--- @field field_1D bool
--- @field field_1E bool
--- @field field_1F bool
--- @field field_20 bool
--- @field field_21 bool
--- @field field_3D bool
--- @field field_63 bool
--- @field field_89 bool
--- @field field_B8E bool
--- @field field_B8F bool
--- @field field_BAA int16
--- @field field_BB0 float
--- @field field_BC9 bool
--- @field field_BCA bool
--- @field field_BCB bool
--- @field field_BCC bool
--- @field field_BCD bool
--- @field field_BCE bool
--- @field field_BCF bool
--- @field field_BF4 bool
--- @field field_BF5 bool
--- @field field_BF6 bool
--- @field field_BF7 bool
--- @field field_C0 int32
--- @field field_C1A bool
--- @field field_C1B bool
--- @field field_C8 bool
--- @field field_C9 bool
--- @field field_CC bool
--- @field field_CD bool
--- @field field_CE bool
--- @field field_CF bool
--- @field field_DD bool
--- @field field_DE bool
--- @field field_DF bool
--- @field field_E bool
--- @field field_E8 bool
--- @field field_E9 bool
--- @field field_EA bool
--- @field field_EB bool
--- @field field_EC bool
--- @field field_ED bool
--- @field field_EE bool
--- @field field_EF bool


--- @class GlobalSwitchesSomeOption
--- @field A float
--- @field B float
--- @field C float
--- @field D float


--- @class GlobalSwitchesSoundSetting
--- @field ConfigKey FixedString
--- @field Name TranslatedString
--- @field PreviewKeyName CString
--- @field RTPCKeyName CString
--- @field Value float
--- @field Value2 float
--- @field Value3 float


--- @class GraphicSettings
--- @field AnimationAllowedPixelError int32
--- @field AntiAliasing int32
--- @field BloomEnabled bool
--- @field ClothGPUAcceleration bool
--- @field DOFEnabled bool
--- @field EnableLightAssignmentStage bool
--- @field EnableSSR bool
--- @field EnableSpotLightsSMAA bool
--- @field FakeFullscreenEnabled bool
--- @field FrameCapEnabled bool
--- @field FrameCapFPS int16
--- @field Fullscreen bool
--- @field GammaCorrection float
--- @field GodRaysEnabled bool
--- @field HDRGamma float
--- @field HDRMaxNits float
--- @field HDRPaperWhite float
--- @field LensFlareEnabled bool
--- @field LightingDetail int32
--- @field MaxDrawDistance float
--- @field MaxDrawDistance2 float
--- @field ModelDetail int32
--- @field MonitorIndex int32
--- @field MotionBlurEnabled bool
--- @field PointLightShadowsEnabled bool
--- @field PostProcessingInjectTexture bool
--- @field RefreshRateDenominator int32
--- @field RefreshRateNumerator int32
--- @field RenderMT bool
--- @field SSAOEnabled bool
--- @field ScreenHeight int32
--- @field ScreenWidth int32
--- @field ShadowQuality int32
--- @field ShadowsEnabled bool
--- @field ShowHDRCalibration bool
--- @field TextureDetail int32
--- @field TextureFiltering int32
--- @field TextureStreamingEnabled bool
--- @field TripleBuffering bool
--- @field UseForwardRendering bool
--- @field VSync bool
--- @field VSyncDivider int32


--- @class HoldRepeatEventDesc
--- @field Event InputEvent
--- @field field_0 int64
--- @field field_10 int64
--- @field field_18 int32
--- @field field_20 int64
--- @field field_28 int32
--- @field field_58 int16
--- @field field_5C int32
--- @field field_8 int64


--- @class IActionData
--- @field Type ActionDataType


--- @class IEoCClientObject : IGameObject
--- @field Base BaseComponent
--- @field DisplayName STDWString|nil
--- @field GetStatus fun(self: IEoCClientObject, statusId: FixedString):EclStatus
--- @field GetStatusByType fun(self: IEoCClientObject, type: StatusType):EclStatus
--- @field GetStatusObjects fun(self: IEoCClientObject)
--- @field GetStatuses fun(self: IEoCClientObject):FixedString[]


--- @class IEoCClientReplicatedObject : IEoCClientObject
--- @field MyGuid FixedString
--- @field NetID NetId


--- @class IEoCServerObject : IGameObject
--- @field Base BaseComponent
--- @field DisplayName STDWString|nil
--- @field MyGuid FixedString
--- @field NetID NetId
--- @field CreateCacheTemplate fun(self: IEoCServerObject):GameObjectTemplate
--- @field ForceSyncToPeers fun(self: IEoCServerObject)
--- @field GetStatus fun(self: IEoCServerObject, statusId: FixedString):EsvStatus
--- @field GetStatusByHandle fun(self: IEoCServerObject, handle: ComponentHandle):EsvStatus
--- @field GetStatusByType fun(self: IEoCServerObject, type: StatusType):EsvStatus
--- @field GetStatusObjects fun(self: IEoCServerObject)
--- @field GetStatuses fun(self: IEoCServerObject):FixedString[]
--- @field TransformTemplate fun(self: IEoCServerObject, tmpl: GameObjectTemplate)


--- @class IGameObject
--- @field Handle ComponentHandle
--- @field Height float
--- @field Rotation mat3
--- @field Scale float
--- @field Translate vec3
--- @field Velocity vec3
--- @field Visual Visual
--- @field GetTags fun(self: IGameObject):FixedString[]
--- @field HasTag fun(self: IGameObject, a1: FixedString):bool
--- @field IsTagged fun(self: IGameObject, tag: FixedString):bool


--- @class ITriggerData


--- @class IdentifyActionData : IActionData
--- @field Consume bool


--- @class InjectDeviceEvent
--- @field DeviceId uint16
--- @field EventId uint32


--- @class InjectInputData : InputRawChange


--- @class InjectTextData
--- @field DeviceId int16


--- @class InputBinding : InputRaw
--- @field Alt bool
--- @field Ctrl bool
--- @field Gui bool
--- @field Modifiers InputModifier
--- @field Shift bool


--- @class InputBindingDesc
--- @field Binding InputBinding
--- @field PlayerIndex int32
--- @field field_14 int32
--- @field field_18 bool
--- @field field_4 int32


--- @class InputDevice
--- @field ControllerMapping int32
--- @field DeviceId int16
--- @field InputPlayerIndex int64
--- @field field_14 float[]
--- @field field_24 uint8
--- @field field_8 int32


--- @class InputEvent
--- @field AcceleratedRepeat bool
--- @field DeviceId FixedString
--- @field EventId int32
--- @field Hold bool
--- @field InputPlayerIndex int32
--- @field NewValue InputValue
--- @field OldValue InputValue
--- @field Press bool
--- @field Release bool
--- @field Repeat bool
--- @field Unknown bool
--- @field ValueChange bool
--- @field WasPreferred bool


--- @class InputEventDesc
--- @field CategoryName FixedString
--- @field EventDesc TranslatedString
--- @field EventID int32
--- @field EventName CString
--- @field Flags1 uint8
--- @field Flags2 int32
--- @field field_18 int64
--- @field field_20 int64
--- @field field_28 int64
--- @field field_30 int64
--- @field field_E8 int32


--- @class InputEventText
--- @field PlayerId int32
--- @field Text CString
--- @field TextLength uint64


--- @class InputManager
--- @field Alt bool
--- @field ControllerAllowKeyboardMouseInput bool
--- @field Ctrl bool
--- @field CurrentRemap InputSchemeBinding
--- @field DeviceEventInjects InjectDeviceEvent[]
--- @field Gui bool
--- @field InputDefinitions table<int32, InputEventDesc>
--- @field InputInjects InjectInputData[]
--- @field InputScheme InputScheme
--- @field InputStates InputSetState[]
--- @field LastUpdateTime double
--- @field PerDeviceData InputDevice[]
--- @field PerPlayerHoldRepeatEvents table<int32, InputManagerHoldRepeatEvent>
--- @field PlayerDeviceIDs int16[]
--- @field PlayerDevices int32[]
--- @field PressedModifiers InputModifier
--- @field RawInputs InputRaw[]
--- @field RawInputs2 InputRaw[]
--- @field Shift bool


--- @class InputManagerHoldRepeatEvent
--- @field FireEvents FireEventDesc[]
--- @field HoldEvents FireEventDesc[]
--- @field PressEvents HoldRepeatEventDesc[]
--- @field ReleaseEvents FireEventDesc[]
--- @field RepeatEvents FireEventDesc[]
--- @field ValueChangeEvents FireEventDesc[]


--- @class InputRaw
--- @field DeviceId FixedString
--- @field InputId InputRawType


--- @class InputRawChange
--- @field Input InputRaw
--- @field Value InputValue


--- @class InputScheme
--- @field Bindings InputSchemeBindingSet[]
--- @field DeviceIdToPlayerId table<uint16, int32>
--- @field PerPlayerBindings table<int32, InputBinding[]>[]


--- @class InputSchemeBinding
--- @field Binding InputBinding
--- @field PlayerId int32
--- @field field_8 int64


--- @class InputSchemeBindingSet
--- @field Bindings InputBindingDesc[]
--- @field Initialized bool


--- @class InputSetState
--- @field Initialized bool
--- @field Inputs InputValue[]


--- @class InputValue
--- @field State InputState
--- @field Value float
--- @field Value2 float


--- @class InventoryItemData
--- @field AIParams SkillAIParams
--- @field Amount int32
--- @field ItemName STDString
--- @field LevelName STDString
--- @field TemplateID FixedString
--- @field Type int32
--- @field UUID FixedString
--- @field field_10 STDString


--- @class ItemTemplate : EoCGameObjectTemplate
--- @field ActivationGroupId FixedString
--- @field AllowSummonTeleport bool
--- @field AltSpeaker FixedString
--- @field Amount int32
--- @field BloodSurfaceType int32
--- @field CanBeMoved bool
--- @field CanBePickedUp bool
--- @field CanClickThrough bool
--- @field CanShootThrough bool
--- @field CombatComponent CombatComponentTemplate
--- @field CoverAmount uint8
--- @field DefaultState FixedString
--- @field Description TranslatedString
--- @field Destroyed bool
--- @field DropSound FixedString
--- @field EquipSound FixedString
--- @field Equipment ItemTemplateEquipment
--- @field Floating bool
--- @field FreezeGravity bool
--- @field HardcoreOnly bool
--- @field HitFX FixedString
--- @field Hostile bool
--- @field Icon FixedString
--- @field InventoryMoveSound FixedString
--- @field IsBlocker bool
--- @field IsHuge bool
--- @field IsInteractionDisabled bool
--- @field IsKey bool
--- @field IsPinnedContainer bool
--- @field IsPointerBlocker bool
--- @field IsPublicDomain bool
--- @field IsSourceContainer bool
--- @field IsSurfaceBlocker bool
--- @field IsSurfaceCloudBlocker bool
--- @field IsTrap bool
--- @field IsWall bool
--- @field ItemList InventoryItemData[]
--- @field Key FixedString
--- @field LevelOverride int32
--- @field LockLevel int32
--- @field LoopSound FixedString
--- @field MaxStackAmount int32
--- @field MeshProxy FixedString
--- @field NotHardcore bool
--- @field OnDestroyActions IActionData[]
--- @field OnUseDescription TranslatedString
--- @field OnUsePeaceActions IActionData[]
--- @field Owner FixedString
--- @field PickupSound FixedString
--- @field PinnedContainerTags FixedString[]
--- @field Race uint32
--- @field SoundAttachBone FixedString
--- @field SoundAttenuation int16
--- @field SoundInitEvent FixedString
--- @field Speaker FixedString
--- @field SpeakerGroup STDWString
--- @field Stats FixedString
--- @field StoryItem bool
--- @field Tooltip uint32
--- @field TreasureLevel int32
--- @field TreasureOnDestroy bool
--- @field Treasures FixedString[]
--- @field UnequipSound FixedString
--- @field Unimportant bool
--- @field UnknownDescription TranslatedString
--- @field UnknownDisplayName TranslatedString
--- @field UseOnDistance bool
--- @field UsePartyLevelForTreasureLevel bool
--- @field UseRemotely bool
--- @field UseSound FixedString
--- @field Wadable bool
--- @field WalkOn bool
--- @field WalkThrough bool


--- @class ItemTemplateEquipment
--- @field EquipmentSlots uint32
--- @field SyncAnimationWithParent bool[]
--- @field VisualResources FixedString[]
--- @field VisualSetSlots uint32


--- @class Level
--- @field ActivePersistentLevelTemplates ActivePersistentLevelTemplate[]
--- @field GameObjects IGameObject[]
--- @field LevelDesc LevelDesc
--- @field LocalTemplateManager LocalTemplateManager
--- @field PhysicsScene PhysicsScene


--- @class LevelCacheTemplateManager : CacheTemplateManagerBase
--- @field LevelName FixedString


--- @class LevelDesc
--- @field CustomDisplayLevelName STDWString
--- @field LevelName FixedString
--- @field Paths Path[]
--- @field Type uint8
--- @field UniqueKey FixedString


--- @class LevelTemplate : GameObjectTemplate
--- @field IsPersistent bool
--- @field LevelBoundTrigger FixedString
--- @field LocalLevelBound Bound
--- @field SubLevelName FixedString
--- @field WorldLevelBound Bound


--- @class Light : MoveableObject
--- @field CastShadow bool
--- @field Color vec3
--- @field FlickerAmount float
--- @field FlickerSpeed float
--- @field Intensity float
--- @field IntensityOffset float
--- @field IsEnabled bool
--- @field IsFlickering bool
--- @field IsMoving bool
--- @field IsUpdateJobRunning bool
--- @field LightType int32
--- @field LightVolume bool
--- @field LightVolumeMapping int32
--- @field LightVolumeSamples int32
--- @field MovementAmount float
--- @field MovementSpeed float
--- @field Radius float
--- @field TranslateOffset vec3
--- @field TranslateOffset2 vec3
--- @field VolumetricLightCollisionProbability float
--- @field VolumetricLightIntensity float


--- @class LocalTemplateManager
--- @field Templates table<FixedString, GameObjectTemplate>
--- @field TemplatesByHandle table<TemplateHandle, GameObjectTemplate>
--- @field TemplatesByType table<uint16, GameObjectTemplate[]>


--- @class LockpickActionData : IActionData
--- @field Consume bool


--- @class LyingActionData : IActionData
--- @field Heal float


--- @class Material
--- @field BlendState uint8
--- @field DepthState uint8
--- @field Flags uint16
--- @field ForwardLightingMode int32
--- @field MaterialID FixedString
--- @field MaterialParameters MaterialParameters
--- @field MaterialPassHint uint8
--- @field MaterialType int32
--- @field RasterizerState uint8
--- @field ShaderDescs ShaderDesc[]
--- @field ShaderPaths Path[]
--- @field ShadingModel int32
--- @field StencilRef int32
--- @field UVCount int32


--- @class MaterialParameter
--- @field Enabled bool
--- @field Parameter FixedString
--- @field ShaderFlags uint16
--- @field UniformName FixedString


--- @class MaterialParameterWithValue_MaterialSamplerState : MaterialParameter
--- @field Value MaterialSamplerState


--- @class MaterialParameterWithValue_MaterialTexture2D : MaterialParameter
--- @field Value MaterialTexture2D


--- @class MaterialParameterWithValue_MaterialVector3 : MaterialParameter
--- @field Value MaterialVector3


--- @class MaterialParameterWithValue_MaterialVector4 : MaterialParameter
--- @field Value MaterialVector4


--- @class MaterialParameterWithValue_float : MaterialParameter
--- @field Value float


--- @class MaterialParameterWithValue_Glmvec2 : MaterialParameter
--- @field Value vec2


--- @class MaterialParameters
--- @field ParentAppliedMaterial AppliedMaterial
--- @field ParentMaterial Material
--- @field SamplerStates MaterialParameterWithValue_MaterialSamplerState[]
--- @field Scalars MaterialParameterWithValue_float[]
--- @field Texture2Ds MaterialParameterWithValue_MaterialTexture2D[]
--- @field Vector2s MaterialParameterWithValue_Glmvec2[]
--- @field Vector3s MaterialParameterWithValue_MaterialVector3[]
--- @field Vector4s MaterialParameterWithValue_MaterialVector4[]


--- @class MaterialSamplerState
--- @field TextureAddressMode uint8
--- @field TextureFilterOverride uint8


--- @class MaterialTexture2D
--- @field ID FixedString


--- @class MaterialVector3
--- @field IsColor bool
--- @field Value vec3


--- @class MaterialVector4
--- @field IsColor bool
--- @field Value vec4


--- @class MeshBinding
--- @field Bound Bound
--- @field Link AnimatableObject
--- @field Transform mat4


--- @class ModManager
--- @field AvailableMods Module[]
--- @field BaseModule Module
--- @field Flag uint8
--- @field Settings ModuleSettings


--- @class Module
--- @field AddonModules Module[]
--- @field BFSReset bool
--- @field ContainedModules Module[]
--- @field DependentModules Module[]
--- @field FinishedLoading bool
--- @field HasValidHash bool
--- @field Info ModuleInfo
--- @field LoadOrderedModules Module[]
--- @field UsesLsfFormat bool


--- @class ModuleInfo
--- @field Author STDWString
--- @field CharacterCreationLevel FixedString
--- @field Description STDWString
--- @field Directory STDWString
--- @field DisplayDescription TranslatedString
--- @field DisplayName TranslatedString
--- @field GMTemplate FixedString
--- @field Hash STDString
--- @field LobbyLevel FixedString
--- @field MenuLevel FixedString
--- @field ModVersion Version
--- @field ModuleType FixedString
--- @field ModuleUUID FixedString
--- @field Name STDWString
--- @field NumPlayers uint8
--- @field PhotoBoothLevel FixedString
--- @field PublishVersion Version
--- @field StartLevel FixedString
--- @field Tags STDWString[]
--- @field TargetModes FixedString[]


--- @class ModuleSettings
--- @field ModOrder FixedString[]
--- @field Mods ModuleShortDesc[]


--- @class ModuleShortDesc
--- @field Folder STDWString
--- @field MD5 STDString
--- @field ModuleUUID FixedString
--- @field Name STDWString
--- @field Version Version


--- @class MoveableObject
--- @field DirtyFlags uint8
--- @field LocalTransform Transform
--- @field ObjectFlags uint8
--- @field WorldTransform Transform


--- @class MusicVolumeTriggerData : ITriggerData
--- @field MusicEvents MusicVolumeTriggerDataMusicEvent[]


--- @class MusicVolumeTriggerDataMusicEvent
--- @field Bansuri FixedString
--- @field Cello FixedString
--- @field IsStinger bool
--- @field MusicEvent FixedString
--- @field OriginOnly FixedString
--- @field OriginTheme FixedString
--- @field OriginThemeAddInstrument bool
--- @field Tambura FixedString
--- @field TriggerOnEnter bool
--- @field TriggerOnlyOnce bool
--- @field Ud FixedString


--- @class PhysicsObject
--- @field CollidesWith uint32
--- @field GameObject IGameObject
--- @field ManagedScale float
--- @field PhysicsGroups uint32
--- @field Rotate mat3
--- @field Scale float
--- @field Shapes PhysicsShape[]
--- @field TemplateID FixedString
--- @field Translate vec3


--- @class PhysicsRagdoll


--- @class PhysicsScene
--- @field Objects PhysicsObject[]


--- @class PhysicsShape
--- @field Name FixedString
--- @field Rotate mat3
--- @field Scale float
--- @field Translate vec3


--- @class PlaySoundActionData : IActionData
--- @field ActivateSoundEvent FixedString
--- @field PlayOnHUD bool


--- @class PlayerManager
--- @field FreePlayerIds int16[]
--- @field InputPlayerIndexToPlayerId table<int32, int16>
--- @field NextPlayerId int16
--- @field PlayerIds int16[]
--- @field Players table<int16, PlayerManagerPlayerData>


--- @class PlayerManagerPlayerData
--- @field InputPlayerIndex int32


--- @class ProjectileTemplate : EoCGameObjectTemplate
--- @field Acceleration float
--- @field BeamFX FixedString
--- @field CastBone FixedString
--- @field DestroyTrailFXOnImpact bool
--- @field DetachBeam bool
--- @field IgnoreRoof bool
--- @field ImpactFX FixedString
--- @field ImpactFXSize float
--- @field LifeTime float
--- @field NeedsArrowImpactSFX bool
--- @field PathMaxArcDist float
--- @field PathMinArcDist float
--- @field PathRadius float
--- @field PathRepeat int32
--- @field PathShift float
--- @field PreviewPathImpactFX FixedString
--- @field PreviewPathMaterial FixedString
--- @field PreviewPathRadius float
--- @field ProjectilePath bool
--- @field RotateImpact bool
--- @field Speed float
--- @field TrailFX FixedString


--- @class RecipeActionData : IActionData
--- @field RecipeID FixedString


--- @class RegionTriggerData : ITriggerData
--- @field RegionCameraLock bool
--- @field RegionCameraLockPos bool
--- @field RegionShroudGen bool
--- @field RegionShroudVisibleInWorld bool


--- @class RenderableObject : MoveableObject
--- @field ActiveAppliedMaterial AppliedMaterial
--- @field AppliedMaterials AppliedMaterial[]
--- @field AppliedOverlayMaterials AppliedMaterial[]
--- @field ClothPhysicsShape PhysicsShape
--- @field HasPhysicsProxy bool
--- @field IsSimulatedCloth bool
--- @field LOD uint8
--- @field PropertyList DsePropertyList


--- @class RepairActionData : IActionData
--- @field Consume bool


--- @class Resource
--- @field IsActive bool
--- @field IsDirty bool
--- @field IsLocalized bool
--- @field IsOriginal bool
--- @field ModName FixedString
--- @field Name STDString
--- @field PackageName FixedString
--- @field SourceFile Path
--- @field UUID FixedString


--- @class RuntimeStringHandle
--- @field Handle FixedString
--- @field ReferenceString STDWString


--- @class SecretRegionTriggerData : ITriggerData
--- @field SecretRegionUnlocked bool


--- @class ShaderDesc
--- @field Flags uint16
--- @field PSHash FixedString
--- @field VSHash FixedString


--- @class ShowStoryElementUIActionData : IActionData
--- @field UIStoryInstance STDString
--- @field UIType int32


--- @class SitActionData : IActionData
--- @field Heal float


--- @class Skeleton


--- @class SkillAIConditions
--- @field HasNoMagicalArmor bool
--- @field HasNoPhysicalArmor bool
--- @field MaximumHealthPercentage int32
--- @field MinimumHealthPercentage int32
--- @field Tags FixedString[]


--- @class SkillAIParams
--- @field AIFlags uint8
--- @field CasualExplorer bool
--- @field Classic bool
--- @field HonorHardcore bool
--- @field MinimumImpact int32
--- @field OnlyCastOnSelf bool
--- @field ScoreModifier float
--- @field SourceConditions SkillAIConditions
--- @field StartRound int32
--- @field TacticianHardcore bool
--- @field TargetConditions SkillAIConditions


--- @class SkillBookActionData : IActionData
--- @field Consume bool
--- @field SkillID FixedString


--- @class SoundRTPCSync
--- @field RTPC FixedString
--- @field SyncNeeded bool
--- @field Value float


--- @class SoundStateSync
--- @field State FixedString
--- @field Switch FixedString
--- @field SyncNeeded bool


--- @class SoundVolumeTrigger : AreaTrigger
--- @field SoundRTPCSyncs SoundRTPCSync[]
--- @field SoundStateSyncs SoundStateSync[]


--- @class SoundVolumeTriggerData : ITriggerData
--- @field AmbientSound FixedString
--- @field AuxBus1 uint8
--- @field AuxBus2 uint8
--- @field AuxBus3 uint8
--- @field AuxBus4 uint8
--- @field Occlusion float


--- @class SpawnCharacterActionData : IActionData
--- @field LocalTemplate FixedString
--- @field RootTemplate FixedString
--- @field SpawnFX FixedString


--- @class StartTriggerData : ITriggerData
--- @field Angle float
--- @field Player uint8
--- @field Team uint8


--- @class StatsAreaTriggerData : ITriggerData
--- @field LevelOverride int32
--- @field ParentGuid Guid
--- @field TreasureLevelOverride int32


--- @class SurfacePathInfluence
--- @field Influence int32
--- @field MaskFlags ESurfaceFlag
--- @field MatchFlags ESurfaceFlag


--- @class SurfaceTemplate : GameObjectTemplate
--- @field AlwaysUseDefaultLifeTime bool
--- @field CanEnterCombat bool
--- @field CanSeeThrough bool
--- @field CanShootThrough bool
--- @field DamageCharacters bool
--- @field DamageItems bool
--- @field DamageTorches bool
--- @field DamageWeapon FixedString
--- @field DecalMaterial FixedString
--- @field DefaultLifeTime float
--- @field Description TranslatedString
--- @field DisplayName TranslatedString
--- @field FX SurfaceTemplateVisualData[]
--- @field FadeInSpeed float
--- @field FadeOutSpeed float
--- @field InstanceVisual SurfaceTemplateVisualData[]
--- @field IntroFX SurfaceTemplateVisualData[]
--- @field RemoveDestroyedItems bool
--- @field Seed int32
--- @field Statuses SurfaceTemplateStatusData[]
--- @field Summon FixedString
--- @field SurfaceGrowTimer float
--- @field SurfaceType FixedString
--- @field SurfaceTypeId int32


--- @class SurfaceTemplateStatusData
--- @field ApplyToCharacters bool
--- @field ApplyToItems bool
--- @field Chance float
--- @field Duration float
--- @field ForceStatus bool
--- @field KeepAlive bool
--- @field OnlyWhileMoving bool
--- @field RemoveStatus bool
--- @field StatusId FixedString
--- @field VanishOnReapply bool


--- @class SurfaceTemplateVisualData
--- @field GridSize float
--- @field Height float
--- @field RandomPlacement float
--- @field Rotation ivec2
--- @field Scale vec2
--- @field SpawnCell int32
--- @field SurfaceNeeded float
--- @field SurfaceRadiusMax float
--- @field Visual FixedString


--- @class TeleportActionData : IActionData
--- @field EventID FixedString
--- @field Source FixedString
--- @field SourceType uint8
--- @field Target FixedString
--- @field TargetType uint8
--- @field Visibility uint8


--- @class TeleportTriggerData : ITriggerData
--- @field Angle float
--- @field Zoom bool


--- @class Transform
--- @field Matrix mat4
--- @field Rotate mat3
--- @field Scale vec3
--- @field Translate vec3


--- @class TranslatedString
--- @field ArgumentString RuntimeStringHandle
--- @field Handle RuntimeStringHandle


--- @class Trigger : IGameObject
--- @field Flags uint16
--- @field IsGlobal bool
--- @field Level FixedString
--- @field SyncFlags uint16
--- @field Template TriggerTemplate
--- @field TriggerType FixedString


--- @class TriggerTemplate : GameObjectTemplate
--- @field Color4 vec4
--- @field PhysicsType uint32
--- @field TriggerGizmoOverride FixedString
--- @field TriggerType FixedString


--- @class TypeInformation
--- @field ElementType TypeInformationRef
--- @field EnumValues table<FixedString, uint64>
--- @field HasWildcardProperties bool
--- @field IsBuiltin bool
--- @field KeyType TypeInformationRef
--- @field Kind LuaTypeId
--- @field Members table<FixedString, TypeInformationRef>
--- @field Methods table<FixedString, TypeInformation>
--- @field ModuleRole FixedString
--- @field NativeName FixedString
--- @field Params TypeInformationRef[]
--- @field ParentType TypeInformationRef
--- @field ReturnValues TypeInformationRef[]
--- @field TypeName FixedString
--- @field VarargParams bool
--- @field VarargsReturn bool


--- @class TypeInformationRef : TypeInformation


--- @class UIObject
--- @field AnchorId STDString
--- @field AnchorObjectName FixedString
--- @field AnchorPos STDString
--- @field AnchorTPos STDString
--- @field AnchorTarget STDString
--- @field ChildUIHandle ComponentHandle
--- @field CustomScale float
--- @field Flags UIObjectFlags
--- @field FlashMovieSize vec2
--- @field FlashSize vec2
--- @field HasAnchorPos bool
--- @field InputFocused bool
--- @field IsDragging bool
--- @field IsDragging2 bool
--- @field IsMoving2 bool
--- @field IsUIMoving bool
--- @field Layer int32
--- @field Left float
--- @field MinSize vec2
--- @field MovieLayout int32
--- @field ParentUIHandle ComponentHandle
--- @field Path Path
--- @field PlayerId int16
--- @field RenderDataPrepared bool
--- @field RenderOrder int32
--- @field Right float
--- @field SysPanelPosition ivec2
--- @field SysPanelSize vec2
--- @field Top float
--- @field Type int32
--- @field UIObjectHandle ComponentHandle
--- @field UIScale float
--- @field UIScaling bool
--- @field CaptureExternalInterfaceCalls fun(self: UIObject)
--- @field CaptureInvokes fun(self: UIObject)
--- @field ClearCustomIcon fun(self: UIObject, element: STDWString)
--- @field Destroy fun(self: UIObject)
--- @field EnableCustomDraw fun(self: UIObject)
--- @field ExternalInterfaceCall fun(self: UIObject, method: STDString)
--- @field GetHandle fun(self: UIObject):ComponentHandle
--- @field GetPlayerHandle fun(self: UIObject):ComponentHandle|nil
--- @field GetPosition fun(self: UIObject):ivec2|nil
--- @field GetRoot fun(self: UIObject)
--- @field GetTypeId fun(self: UIObject):int32
--- @field GetUIScaleMultiplier fun(self: UIObject):float
--- @field GetValue fun(self: UIObject, path: STDString, typeName: STDString|nil, arrayIndex: int32|nil):IggyInvokeDataValue|nil
--- @field GotoFrame fun(self: UIObject, frame: int32, force: bool|nil)
--- @field Invoke fun(self: UIObject, method: STDString):bool
--- @field Resize fun(self: UIObject, a1: float, a2: float, a3: float|nil)
--- @field SetCustomIcon fun(self: UIObject, element: STDWString, icon: STDString, width: int32, height: int32, materialGuid: STDString|nil)
--- @field SetPosition fun(self: UIObject, x: int32, y: int32)
--- @field SetValue fun(self: UIObject, path: STDString, value: IggyInvokeDataValue, arrayIndex: int32|nil)
local UIObject = {}



--- Hides the UI element.
--- Location: Lua/Client/ClientUI.cpp:686
function UIObject:Hide() end

--- Displays the UI element.
--- Location: Lua/Client/ClientUI.cpp:678
function UIObject:Show() end



--- @class UseSkillActionData : IActionData
--- @field Consume bool
--- @field SkillID FixedString


--- @class Visual : MoveableObject
--- @field Actor Actor
--- @field AllowReceiveDecalWhenAnimated bool
--- @field Attachments VisualAttachment[]
--- @field CastShadow bool
--- @field ChildVisualHasCloth bool
--- @field CullFlags uint16
--- @field FadeOpacity float
--- @field GameObject IGameObject
--- @field Handle ComponentHandle
--- @field HasCloth bool
--- @field IsShadowProxy bool
--- @field LODDistances float[]
--- @field Parent Visual
--- @field PlayingAttachedEffects bool
--- @field ReceiveColorFromParent bool
--- @field ReceiveDecal bool
--- @field Reflecting bool
--- @field ShowMesh bool
--- @field Skeleton Skeleton
--- @field SubObjects VisualObjectDesc[]
--- @field TextKeyPrepareFlags uint8
--- @field VisualResource VisualResource
--- @field OverrideScalarMaterialParameter fun(self: Visual, a1: FixedString, a2: float)
--- @field OverrideTextureMaterialParameter fun(self: Visual, parameter: FixedString, textureId: FixedString)
--- @field OverrideVec2MaterialParameter fun(self: Visual, a1: FixedString, a2: vec2)
--- @field OverrideVec3MaterialParameter fun(self: Visual, parameter: FixedString, vec: vec3, isColor: bool)
--- @field OverrideVec4MaterialParameter fun(self: Visual, parameter: FixedString, vec: vec4, isColor: bool)


--- @class VisualAttachment
--- @field Armor bool
--- @field AttachmentBoneName FixedString
--- @field BoneIndex int16
--- @field BonusWeaponFX bool
--- @field DestroyWithParent bool
--- @field DoNotUpdate bool
--- @field DummyAttachmentBoneIndex int16
--- @field ExcludeFromBounds bool
--- @field Horns bool
--- @field InheritAnimations bool
--- @field KeepRot bool
--- @field KeepScale bool
--- @field Overhead bool
--- @field ParticleSystem bool
--- @field UseLocalTransform bool
--- @field Visual Visual
--- @field Weapon bool
--- @field WeaponFX bool
--- @field WeaponOverlayFX bool
--- @field Wings bool


--- @class VisualObjectDesc
--- @field Renderable RenderableObject
--- @field field_8 uint8


--- @class VisualResource
--- @field AnimationWaterfall FixedString[]
--- @field Attachments VisualResourceAttachment[]
--- @field BlueprintInstanceResourceID FixedString
--- @field Bones table<FixedString, VisualResourceBonePosRot>
--- @field ClothParams VisualResourceClothParam[]
--- @field CustomAnimationSet AnimationSet
--- @field KnownAnimationSetOverrides table<FixedString, FixedString>
--- @field LODDistances float[]
--- @field Objects VisualResourceObjectDesc[]
--- @field ResolvedAnimationSet AnimationSet
--- @field Template FixedString


--- @class VisualResourceAttachment
--- @field Name FixedString
--- @field UUID FixedString


--- @class VisualResourceBonePosRot
--- @field Position vec3
--- @field Rotation mat3


--- @class VisualResourceClothParam
--- @field AtmosphericWindEnabled bool
--- @field BendingStiffness float
--- @field Drag float
--- @field FrontalWindFrequency float
--- @field FrontalWindSpeed float
--- @field FrontalWindVariance float
--- @field Iterations int32
--- @field Lift float
--- @field LinearStiffness float
--- @field Margin float
--- @field MassPerMeterSqr float
--- @field PoseMatching float
--- @field UUID FixedString


--- @class VisualResourceObjectDesc
--- @field LOD uint8
--- @field MaterialID FixedString
--- @field ObjectID FixedString


--- @class VisualSet
--- @field Colors uint32[][]
--- @field Visuals FixedString[][]


--- @class CharacterCreationAbilityChange
--- @field Ability StatsAbilityType
--- @field AmountIncreased int32


--- @class CharacterCreationAiPersonalityDesc
--- @field ID FixedString
--- @field Name TranslatedString


--- @class CharacterCreationAttributeChange
--- @field AmountIncreased int32
--- @field Attribute PlayerUpgradeAttribute


--- @class CharacterCreationCharacterCreationManager
--- @field AiPersonalities CharacterCreationAiPersonalityDesc[]
--- @field ClassPresets CharacterCreationClassDesc[]
--- @field CompanionPresets CharacterCreationClassDesc[]
--- @field DefaultAiPersonality TranslatedString
--- @field DefaultOrigin CharacterCreationOriginDesc
--- @field DefaultRace CharacterCreationRaceDesc
--- @field DefaultVoice CharacterCreationVoiceDesc
--- @field GenericOriginPresets CharacterCreationOriginDesc[]
--- @field HenchmanPresets CharacterCreationClassDesc[]
--- @field OriginPresets CharacterCreationOriginDesc[]
--- @field RacePresets CharacterCreationRaceDesc[]
--- @field Tags table<uint32, FixedString[]>
--- @field Voices CharacterCreationVoiceDesc[]


--- @class CharacterCreationClassDesc
--- @field AbilityChanges CharacterCreationAbilityChange[]
--- @field AreStatsWeighted bool
--- @field AttributeChanges CharacterCreationAttributeChange[]
--- @field ClassDescription TranslatedString
--- @field ClassLongDescription TranslatedString
--- @field ClassName TranslatedString
--- @field ClassType FixedString
--- @field EquipmentProperties CharacterCreationEquipmentProperty[]
--- @field Icon int32
--- @field NumStartingAttributePoints int32
--- @field NumStartingCivilAbilityPoints int32
--- @field NumStartingCombatAbilityPoints int32
--- @field NumStartingTalentPoints int32
--- @field Price int32
--- @field SkillSet FixedString
--- @field TalentsAdded StatsTalentType[]
--- @field Voice int32


--- @class CharacterCreationColorDesc
--- @field ColorName TranslatedString
--- @field ID uint32
--- @field Value uint32


--- @class CharacterCreationEquipmentProperty
--- @field PreviewEquipmentSet FixedString
--- @field RaceName FixedString
--- @field StartingEquipmentSet FixedString


--- @class CharacterCreationOriginDesc
--- @field AbilityChanges CharacterCreationAbilityChange[]
--- @field AttributeChanges CharacterCreationAttributeChange[]
--- @field CharacterUUID FixedString
--- @field OriginDescription TranslatedString
--- @field OriginDisplayName TranslatedString
--- @field OriginLongDescription TranslatedString
--- @field OriginName FixedString
--- @field PreviewEquipmentSet FixedString
--- @field RootTemplateOverride FixedString
--- @field SkillSet FixedString
--- @field SupportedGenders uint32[]
--- @field SupportedRaces FixedString[]
--- @field TalentsAdded StatsTalentType[]
--- @field UserCanAlterTags bool


--- @class CharacterCreationRaceDesc
--- @field AbilityChanges CharacterCreationAbilityChange[]
--- @field AllowBald bool
--- @field AttributeChanges CharacterCreationAttributeChange[]
--- @field ClothColors CharacterCreationColorDesc[]
--- @field DefaultColor CharacterCreationColorDesc
--- @field FemaleDefaultHairColor uint32
--- @field FemaleDefaultPlayerNames TranslatedString[]
--- @field FemaleDefaultSkinColor uint32
--- @field FemaleIcons FixedString[]
--- @field FemaleRootTemplateIDs FixedString[]
--- @field HairColors CharacterCreationColorDesc[]
--- @field MaleDefaultHairColor uint32
--- @field MaleDefaultPlayerNames TranslatedString[]
--- @field MaleDefaultSkinColor uint32
--- @field MaleIcons FixedString[]
--- @field MaleRootTemplateIDs FixedString[]
--- @field RaceDescription TranslatedString
--- @field RaceDisplayName TranslatedString
--- @field RaceName FixedString
--- @field SkillSet FixedString
--- @field SkinColors CharacterCreationColorDesc[]
--- @field TagsAdded FixedString[]
--- @field TalentsAdded StatsTalentType[]


--- @class CharacterCreationVoiceDesc
--- @field FemaleSpeakerID FixedString
--- @field ID uint32
--- @field MaleSpeakerID FixedString
--- @field Name TranslatedString


--- @class DsePropertyList
--- @field AlphaChannel uint8
--- @field OpaqueChannel uint8
--- @field RenderPasses int32
--- @field TransformType int32
--- @field field_6 uint8
--- @field field_7 uint8


--- @class EclCharacter : IEoCClientReplicatedObject
--- @field AI EocAi
--- @field Activated bool
--- @field AnimationSetOverride FixedString
--- @field AnimationSpeed float
--- @field Archetype FixedString
--- @field CanShootThrough bool
--- @field CannotMove bool
--- @field CharCreationInProgress bool
--- @field CharacterCreationFinished bool
--- @field CorpseCharacterHandle ComponentHandle
--- @field CorpseLootable bool
--- @field CorpseOwnerHandle ComponentHandle
--- @field CurrentLevel FixedString
--- @field CurrentTemplate CharacterTemplate
--- @field Dead bool
--- @field DisableSneaking bool
--- @field DisplayNameOverride TranslatedString
--- @field Flags EclCharacterFlags
--- @field Floating bool
--- @field FollowCharacterHandle ComponentHandle
--- @field GMControl bool
--- @field Global bool
--- @field HasCustomVisualIndices bool
--- @field HasInventory bool
--- @field HasOwner bool
--- @field HasSkillTargetEffect bool
--- @field InCombat bool
--- @field InDialog bool
--- @field InParty bool
--- @field InventoryHandle ComponentHandle
--- @field Invisible bool
--- @field IsHuge bool
--- @field IsPlayer bool
--- @field IsRunning bool
--- @field ItemTags FixedString[]
--- @field LadderPosition vec3
--- @field LootedByHandle ComponentHandle
--- @field MovementStartPosition vec3
--- @field MovementUpdated bool
--- @field Multiplayer bool
--- @field NetID2 NetId
--- @field NetID3 NetId
--- @field NoCover bool
--- @field NoRotate bool
--- @field OffStage bool
--- @field OriginalDisplayName TranslatedString
--- @field OriginalTemplate CharacterTemplate
--- @field OwnerCharacterHandle ComponentHandle
--- @field PartyFollower bool
--- @field Physics PhysicsObject
--- @field PlayerCustomData EocPlayerCustomData
--- @field PlayerData EclPlayerData
--- @field PlayerUpgrade EocPlayerUpgrade
--- @field ReservedForDialog bool
--- @field ReservedForPlayerId int16
--- @field ReservedForPlayerId2 int16
--- @field RootTemplate CharacterTemplate
--- @field RunSpeedOverride float
--- @field SkillManager EclSkillManager
--- @field SpotSneakers bool
--- @field Stats CDivinityStatsCharacter
--- @field StatusMachine EclStatusMachine
--- @field StoryDisplayName TranslatedString
--- @field StoryNPC bool
--- @field Summon bool
--- @field SurfacePathInfluences SurfacePathInfluence[]
--- @field Tags FixedString[]
--- @field TalkingIconEffect ComponentHandle
--- @field UseOverlayMaterials bool
--- @field UserID UserId
--- @field VisionGridInvisible bool
--- @field VisionGridInvisible2 bool
--- @field VisualsUpdated bool
--- @field WalkSpeedOverride float
--- @field WalkThrough bool
--- @field WeaponSheathed bool
--- @field WorldPos vec3
--- @field GetCustomStat fun(self: EclCharacter, a1: FixedString):int32|nil
--- @field GetInventoryItems fun(self: EclCharacter):FixedString[]
--- @field GetItemBySlot fun(self: EclCharacter, slot: StatsItemSlot32):FixedString|nil
--- @field GetItemObjectBySlot fun(self: EclCharacter, a1: StatsItemSlot32):EclItem
--- @field SetScale fun(self: EclCharacter, a1: float)


--- @class EclCharacterConversionHelpers
--- @field ActivatedCharacters table<FixedString, EclCharacter[]>
--- @field RegisteredCharacters table<FixedString, EclCharacter[]>


--- @class EclEntityManager
--- @field CharacterConversionHelpers EclCharacterConversionHelpers
--- @field ItemConversionHelpers EclItemConversionHelpers
--- @field ProjectileConversionHelpers EclProjectileConversionHelpers
--- @field SceneryConversionHelpers EclSceneryConversionHelpers
--- @field TriggerConversionHelpers EclTriggerConversionHelpers


--- @class EclEoCUI : UIObject


--- @class EclInventory
--- @field EquipmentSlots uint8
--- @field Flags uint8
--- @field GUID FixedString
--- @field ItemsBySlot ComponentHandle[]
--- @field NetID NetId
--- @field OwnerCharacterHandleUI ComponentHandle
--- @field ParentHandle ComponentHandle
--- @field PinnedContainers ComponentHandle[]
--- @field UpdateViews ComponentHandle[]


--- @class EclInventoryView
--- @field Handle ComponentHandle
--- @field ItemHandles ComponentHandle[]
--- @field ItemNetIdToIndex table<NetId, int32>
--- @field NetID NetId
--- @field ParentInventories NetId[]
--- @field ParentNetId_M NetId


--- @class EclItem : IEoCClientReplicatedObject
--- @field AI EocAi
--- @field AIBoundSize float
--- @field Activated bool
--- @field Amount int32
--- @field BaseWeightOverwrite int32
--- @field CachedItemDescription STDWString
--- @field CanBeMoved bool
--- @field CanBePickedUp bool
--- @field CanShootThrough bool
--- @field CanUse bool
--- @field CanUseRemotely bool
--- @field CanWalkThrough bool
--- @field Consumable bool
--- @field CoverAmount bool
--- @field CurrentLevel FixedString
--- @field CurrentSlot int16
--- @field CurrentTemplate ItemTemplate
--- @field CustomBookContent TranslatedString
--- @field CustomDescription TranslatedString
--- @field CustomDisplayName TranslatedString
--- @field Destroyed bool
--- @field DontAddToBottomBar bool
--- @field EnableHighlights bool
--- @field Fade bool
--- @field FallTimer float
--- @field Flags EclItemFlags
--- @field Flags2 EclItemFlags2
--- @field Floating bool
--- @field FoldDynamicStats bool
--- @field FreezeGravity bool
--- @field Global bool
--- @field GoldValueOverride int32
--- @field GravityTimer float
--- @field HasPendingNetUpdate bool
--- @field HideHP bool
--- @field Hostile bool
--- @field Icon FixedString
--- @field InUseByCharacterHandle ComponentHandle
--- @field InUseByUserId int32
--- @field InteractionDisabled bool
--- @field InventoryHandle ComponentHandle
--- @field InventoryParentHandle ComponentHandle
--- @field Invisible bool
--- @field Invulnerable bool
--- @field IsCraftingIngredient bool
--- @field IsDoor bool
--- @field IsKey bool
--- @field IsLadder bool
--- @field IsSecretDoor bool
--- @field IsSourceContainer bool
--- @field ItemColorOverride FixedString
--- @field ItemType FixedString
--- @field JoinedDialog bool
--- @field KeyName FixedString
--- @field Known bool
--- @field Level int32
--- @field LockLevel int32
--- @field MovementUpdated bool
--- @field OwnerCharacterHandle ComponentHandle
--- @field Physics PhysicsObject
--- @field PhysicsDisabled bool
--- @field PhysicsFlag1 bool
--- @field PhysicsFlag2 bool
--- @field PhysicsFlag3 bool
--- @field PhysicsFlags EclItemPhysicsFlags
--- @field PinnedContainer bool
--- @field Registered bool
--- @field RequestRaycast bool
--- @field RequestWakeNeighbours bool
--- @field RootTemplate ItemTemplate
--- @field Stats CDivinityStatsItem
--- @field StatsFromName StatsObject
--- @field StatsId FixedString
--- @field StatusMachine EclStatusMachine
--- @field Sticky bool
--- @field Stolen bool
--- @field StoryItem bool
--- @field Tags FixedString[]
--- @field TeleportOnUse bool
--- @field UnEquipLocked bool
--- @field Unimportant bool
--- @field UnknownTimer float
--- @field UseSoundsLoaded bool
--- @field Vitality int32
--- @field Wadable bool
--- @field WakePosition vec3
--- @field Walkable bool
--- @field WasOpened bool
--- @field WorldPos vec3
--- @field GetDeltaMods fun(self: EclItem):FixedString[]
--- @field GetInventoryItems fun(self: EclItem):FixedString[]
--- @field GetOwnerCharacter fun(self: EclItem):FixedString|nil


--- @class EclItemConversionHelpers
--- @field ActivatedItems table<FixedString, EclItem[]>
--- @field RegisteredItems table<FixedString, EclItem[]>


--- @class EclLevel : Level
--- @field AiGrid EocAiGrid
--- @field EntityManager EclEntityManager
--- @field LevelCacheTemplateManager LevelCacheTemplateManager
--- @field SurfaceManager EclSurfaceManager


--- @class EclLevelManager
--- @field CurrentLevel EclLevel
--- @field LevelDescs LevelDesc[]
--- @field Levels table<FixedString, EclLevel>
--- @field Levels2 table<FixedString, EclLevel>


--- @class EclMultiEffectHandler
--- @field AttachedVisualComponents ComponentHandle[]
--- @field Effects ComponentHandle[]
--- @field ListenForTextKeysHandle ComponentHandle
--- @field ListeningOnTextKeys bool
--- @field Position vec3
--- @field TargetObjectHandle ComponentHandle
--- @field TextKeyEffects table<FixedString, EclMultiEffectHandlerEffectInfo[]>
--- @field Visuals EclMultiEffectHandlerMultiEffectVisual[]
--- @field WeaponAttachments EclMultiEffectHandlerWeaponAttachmentInfo[]
--- @field WeaponBones FixedString


--- @class EclMultiEffectHandlerEffectInfo
--- @field Beam bool
--- @field BoneNames FixedString[]
--- @field Detach bool
--- @field Effect FixedString
--- @field EffectAttached bool
--- @field FaceSource bool
--- @field FollowScale bool
--- @field KeepRot bool


--- @class EclMultiEffectHandlerMultiEffectVisual
--- @field MultiEffectHandler EclMultiEffectHandler
--- @field OS_FS FixedString[]


--- @class EclMultiEffectHandlerWeaponAttachmentInfo
--- @field BoneNames FixedString
--- @field EffectName FixedString
--- @field VisualId FixedString


--- @class EclPlayerCustomData : EocPlayerCustomData


--- @class EclPlayerData
--- @field ArmorOptionState bool
--- @field AttitudeOverrideMap table<ComponentHandle, int32>
--- @field CachedTension int32
--- @field CorpseLootTargetNetID NetId
--- @field CustomData EclPlayerCustomData
--- @field HelmetOptionState bool
--- @field LockedAbilities uint32[]
--- @field MemorisedSkills FixedString[]
--- @field OriginalTemplate FixedString
--- @field PickpocketTargetNetID NetId
--- @field QuestSelected FixedString
--- @field Region FixedString
--- @field SelectedSkillSet uint8
--- @field SkillBarItems EocSkillBarItem[]


--- @class EclPlayerManager : PlayerManager
--- @field ClientPlayerData table<int16, EclPlayerManagerClientPlayerInfo>
--- @field ConnectedPlayers int16[]
--- @field CurrentInputPlayerIndex int32
--- @field DebugLocalPlayerId int16
--- @field DebugPlayerIds int16[]
--- @field DebugPlayerProfileGuids FixedString[]
--- @field IsDisconnecting bool
--- @field LinkedDevices int32[]
--- @field NextLocalPlayerId uint64
--- @field PlayerIdToNetId table<int16, NetId>


--- @class EclPlayerManagerClientPlayerInfo
--- @field CameraControllerId FixedString
--- @field CharacterNetId NetId
--- @field ProfileGuid FixedString


--- @class EclProjectile : IEoCClientObject
--- @field Caster ComponentHandle
--- @field CurrentTemplate ProjectileTemplate
--- @field ExplodeRadius float
--- @field ImpactFX FixedString
--- @field IsGlobal bool
--- @field Level FixedString
--- @field LifeTime float
--- @field MovingObject ComponentHandle
--- @field RequestDelete bool
--- @field RotateImpact bool
--- @field SkillID FixedString
--- @field Source ComponentHandle
--- @field SourcePos vec3
--- @field SpawnEffect FixedString
--- @field SpawnFXOverridesImpactFX bool
--- @field TargetCharacter ComponentHandle
--- @field TargetPos vec3


--- @class EclProjectileConversionHelpers
--- @field RegisteredProjectiles table<FixedString, EclProjectile[]>


--- @class EclScenery : IEoCClientObject
--- @field AllowReceiveDecalWhenAnimated bool
--- @field CanShootThrough bool
--- @field CastShadow bool
--- @field CoverAmount uint8
--- @field DefaultState FixedString
--- @field Destroyed bool
--- @field Fade bool
--- @field FadeParams EclSceneryFadeSettings
--- @field Fadeable bool
--- @field Flags EclSceneryFlags
--- @field ForceUseAnimationBlueprint bool
--- @field GUID FixedString
--- @field Invisible bool
--- @field IsBlocker bool
--- @field IsReflecting bool
--- @field IsShadowProxy bool
--- @field IsWall bool
--- @field LevelName FixedString
--- @field Physics PhysicsObject
--- @field ReceiveDecals bool
--- @field RenderChannel uint8
--- @field RenderFlags EclSceneryRenderFlags
--- @field SeeThrough bool
--- @field SoundParams EclScenerySoundSettings
--- @field Template GameObjectTemplate
--- @field UnknownFlag100 bool
--- @field UnknownFlag80 bool
--- @field UnknownRenderFlag1 bool
--- @field UnknownRenderFlag20 bool
--- @field VisualResourceID FixedString
--- @field Wadable bool
--- @field Walkable bool


--- @class EclSceneryFadeSettings
--- @field FadeGroup FixedString
--- @field FadeIn bool
--- @field Opacity float


--- @class EclScenerySoundSettings
--- @field LoopSound FixedString
--- @field SoundAttenuation int16
--- @field SoundInitEvent FixedString


--- @class EclSceneryConversionHelpers
--- @field RegisteredScenery table<FixedString, EclScenery[]>


--- @class EclSkill
--- @field ActiveCooldown float
--- @field CanActivate bool
--- @field CauseListSize int32
--- @field Handle ComponentHandle
--- @field HasCooldown bool
--- @field IsActivated bool
--- @field IsLearned bool
--- @field MaxCharges int32
--- @field NetID NetId
--- @field NumCharges int32
--- @field OwnerHandle ComponentHandle
--- @field SkillId FixedString
--- @field Type SkillType
--- @field ZeroMemory bool


--- @class EclSkillManager
--- @field OwnerHandle ComponentHandle
--- @field Skills table<FixedString, EclSkill>


--- @class EclStatus
--- @field CurrentLifeTime float
--- @field Flags EclStatusFlags
--- @field LifeTime float
--- @field NetID NetId
--- @field OwnerHandle ComponentHandle
--- @field StatsMultiplier float
--- @field StatusId FixedString
--- @field StatusSourceHandle ComponentHandle
--- @field StatusType FixedString


--- @class EclStatusActiveDefense : EclStatusConsumeBase
--- @field Charges int32
--- @field EffectHandle ComponentHandle
--- @field TargetHandle ComponentHandle
--- @field TargetPos vec3
--- @field TargetSize int32


--- @class EclStatusAdrenaline : EclStatusConsumeBase
--- @field InitialAPMod int32
--- @field SecondaryAPMod int32


--- @class EclStatusAoO : EclStatus
--- @field ShowOverhead bool
--- @field SourceHandle ComponentHandle
--- @field TargetHandle ComponentHandle


--- @class EclStatusBoost : EclStatus
--- @field BoostId FixedString


--- @class EclStatusChallenge : EclStatusConsumeBase
--- @field SourceHandle ComponentHandle
--- @field Target bool


--- @class EclStatusCharmed : EclStatusConsumeBase
--- @field EffectHandle ComponentHandle
--- @field OriginalOwnerCharacterHandle ComponentHandle


--- @class EclStatusClean : EclStatus
--- @field EffectHandler EclMultiEffectHandler
--- @field OverlayMaterial FixedString


--- @class EclStatusClimbing : EclStatus
--- @field ClimbLoopDuration float
--- @field Direction bool
--- @field JumpUpLadders bool
--- @field LadderHandle ComponentHandle
--- @field NeedsCharacterUpdate bool
--- @field Started bool
--- @field UpdateTimer float


--- @class EclStatusCombat : EclStatus
--- @field CombatTeamId EocCombatTeamId


--- @class EclStatusConsumeBase : EclStatus
--- @field ApplyEffectHandler EclMultiEffectHandler
--- @field AttributeHandle int32
--- @field AuraFX FixedString
--- @field AuraFXHandle ComponentHandle
--- @field AuraRadius float
--- @field CurrentStatsMultiplier float
--- @field EffectHandler EclMultiEffectHandler
--- @field HasItemFlag0x200000000000 bool
--- @field Icon FixedString
--- @field Material FixedString
--- @field MaterialApplyFlags StatusMaterialApplyFlags
--- @field MaterialApplyNormalMap bool
--- @field MaterialFadeAmount float
--- @field MaterialOverlayOffset float
--- @field MaterialParams EclStatusConsumeBaseMaterialParam[]
--- @field MaterialType uint32
--- @field OriginalWeaponId FixedString
--- @field OverrideWeaponHandle ComponentHandle
--- @field OverrideWeaponId FixedString
--- @field SourceDirection vec3
--- @field StackId FixedString
--- @field StatsDataPerTurn EclStatusConsumeBaseStatsData[]
--- @field StatsId FixedString
--- @field StatusEffectOverrideForItems FixedString
--- @field TooltipText STDWString
--- @field TooltipTextNeedsUpdating bool
--- @field TooltipTexts STDWString[]
--- @field Turn int32


--- @class EclStatusConsumeBaseMaterialParam
--- @field Name FixedString
--- @field Value FixedString


--- @class EclStatusConsumeBaseStatsData
--- @field StatsId FixedString
--- @field TurnIndex int32


--- @class EclStatusDamage : EclStatusConsumeBase
--- @field DamageLevel int32
--- @field DamageStats FixedString


--- @class EclStatusDamageOnMove : EclStatusConsumeBase
--- @field DamageAmount int32
--- @field DistancePerDamage float


--- @class EclStatusDying : EclStatus
--- @field AttackDirection int32
--- @field CombatId bool
--- @field DeathType StatsDeathType
--- @field DieActionsCompleted bool
--- @field ImpactDirection vec3
--- @field InflicterNetId NetId
--- @field IsAlreadyDead bool
--- @field SkipAnimation bool


--- @class EclStatusEffect : EclStatus
--- @field Active bool
--- @field BeamEffect FixedString
--- @field EffectHandler EclMultiEffectHandler
--- @field Icon FixedString
--- @field PeaceOnly bool
--- @field PlayerHasTag FixedString
--- @field PlayerSameParty bool
--- @field StatusEffect FixedString


--- @class EclStatusEncumbered : EclStatusConsumeBase
--- @field NextMessageDelay float
--- @field State int32


--- @class EclStatusFloating : EclStatusConsumeBase
--- @field OnlyWhileMoving bool


--- @class EclStatusGuardianAngel : EclStatusConsumeBase
--- @field EffectHandle ComponentHandle


--- @class EclStatusHeal : EclStatus
--- @field EffectHandler EclMultiEffectHandler
--- @field EffectTime float
--- @field HealAmount int32
--- @field HealEffect uint32
--- @field HealEffectId FixedString
--- @field HealType int32
--- @field TargetDependentHeal bool
--- @field TargetDependentHealAmount int32[]


--- @class EclStatusHealing : EclStatusConsumeBase
--- @field HealAmount int32
--- @field HealStat int32


--- @class EclStatusHit : EclStatus
--- @field AllowInterruptAction_IsIdleAction bool
--- @field DamageInfo StatsHitDamageInfo
--- @field DeleteRequested bool
--- @field HitByHandle ComponentHandle
--- @field HitByType int32
--- @field HitReason int32
--- @field ImpactDirection vec3
--- @field ImpactPosition vec3
--- @field Interruption bool
--- @field TimeRemaining float
--- @field WeaponHandle ComponentHandle


--- @class EclStatusIdentify : EclStatus
--- @field Identifier ComponentHandle
--- @field Level int32


--- @class EclStatusIncapacitated : EclStatusConsumeBase
--- @field CurrentFreezeTime float
--- @field FreezeTime float


--- @class EclStatusKnockedDown : EclStatus
--- @field EffectHandler EclMultiEffectHandler
--- @field KnockedDownState int32


--- @class EclStatusLeadership : EclStatusConsumeBase
--- @field Strength float


--- @class EclStatusMachine
--- @field IsStatusMachineActive bool
--- @field OwnerObjectHandle ComponentHandle
--- @field PreventStatusApply bool
--- @field Statuses EclStatus[]


--- @class EclStatusMaterial : EclStatus
--- @field ApplyFlags StatusMaterialApplyFlags
--- @field ApplyNormalMap bool
--- @field Fading bool
--- @field Force bool
--- @field HasVisuals bool
--- @field IsOverlayMaterial bool
--- @field MaterialUUID FixedString


--- @class EclStatusPolymorphed : EclStatusConsumeBase
--- @field DisableInteractions bool
--- @field PolymorphResult FixedString


--- @class EclStatusRepair : EclStatus
--- @field Repaired int32
--- @field RepairerHandle ComponentHandle


--- @class EclStatusRotate : EclStatus
--- @field Yaw float


--- @class EclStatusSitting : EclStatus
--- @field Index int32
--- @field ItemHandle ComponentHandle
--- @field NetId int32
--- @field Position vec3


--- @class EclStatusSmelly : EclStatus
--- @field EffectHandler EclMultiEffectHandler
--- @field OverlayMaterial FixedString


--- @class EclStatusSneaking : EclStatus
--- @field ClientRequestStop bool
--- @field EffectHandler EclMultiEffectHandler
--- @field Failed bool


--- @class EclStatusSpark : EclStatusConsumeBase
--- @field Charges int32


--- @class EclStatusSpirit : EclStatus
--- @field Characters NetId[]


--- @class EclStatusSummoning : EclStatus
--- @field AnimationDuration float
--- @field SummonLevel int32


--- @class EclStatusTeleportFall : EclStatus
--- @field EffectHandler EclMultiEffectHandler
--- @field HasDamage bool
--- @field ReappearTime float
--- @field SkillId FixedString
--- @field Target vec3


--- @class EclStatusThrown : EclStatus
--- @field AnimationDuration float
--- @field IsThrowingSelf bool
--- @field Landed bool
--- @field LandingEstimate float
--- @field Level int32


--- @class EclStatusTutorialBed : EclStatus
--- @field AnimationDuration float
--- @field AnimationDuration2 float
--- @field BedHandle ComponentHandle


--- @class EclStatusUnlock : EclStatus
--- @field Unlocked int32


--- @class EclStatusUnsheathed : EclStatus
--- @field Force bool


--- @class EclSubSurface
--- @field Changes EclSubSurfaceChangingCell[]
--- @field FadeInSpeed float
--- @field FadeOutSpeed float
--- @field Layer SurfaceLayer
--- @field SoundPositions vec3[]
--- @field SoundSurfaceRegionList EclSubSurfaceCell[]
--- @field Surface EclSurface
--- @field SurfaceTypeId SurfaceType
--- @field X uint8
--- @field Y uint8


--- @class EclSubSurfaceChangingCell
--- @field X int16
--- @field Y int16
--- @field field_4 int32
--- @field field_8 bool


--- @class EclSubSurfaceCell
--- @field LayerIndex int16
--- @field SoundPositionIndex int16


--- @class EclSurface
--- @field AiGrid EocAiGrid
--- @field Cells i16vec2[]
--- @field Effects table<int32, ComponentHandle>[]
--- @field EntityHandle EntityHandle
--- @field FadeOut EclSurfaceFadeOutInstance[]
--- @field Flags uint8
--- @field Height int32
--- @field InstanceVisuals FixedString[]
--- @field NeedsSoundUpdate bool
--- @field NumIntroFXVisuals uint64
--- @field OS_Vec3f vec3[]
--- @field RandomSeed uint32
--- @field Regions EclSurfaceRegion[]
--- @field SubSurfaces EclSubSurface[]
--- @field SurfaceManager EclSurfaceManager
--- @field SurfaceTypeId SurfaceType
--- @field Template SurfaceTemplate
--- @field Width int32


--- @class EclSurfaceFadeOutInstance
--- @field Position vec3


--- @class EclSurfaceManager
--- @field Level EclLevel
--- @field MetaData EclSurfaceMetaData[]
--- @field NeedsVisualReload bool
--- @field Regions EclSurfaceRegion[]
--- @field ShouldReloadEffects bool
--- @field ShouldReloadInstances bool
--- @field SurfacesByType EclSurface[]


--- @class EclSurfaceMetaData
--- @field CombatTeamId EocCombatTeamId
--- @field OwnerHandle ComponentHandle
--- @field TimeElapsed float
--- @field field_14 bool


--- @class EclSurfaceRegion
--- @field X int8
--- @field Y int8


--- @class EclTriggerConversionHelpers
--- @field RegisteredTriggers table<FixedString, Trigger[]>


--- @class EclTurnManager
--- @field CameraControl bool
--- @field CombatGroups table<FixedString, EocCombatGroupInfo>
--- @field Combats table<uint8, EclTurnManagerCombat>
--- @field EntityHandles EntityHandle[]
--- @field PlayerIdToCombatantNetId table<int16, NetId>


--- @class EclTurnManagerCombat
--- @field CombatGroups ComponentHandleWithType[]
--- @field CurrentRoundTeams ComponentHandleWithType[]
--- @field InitialEnemyTeamId EocCombatTeamId
--- @field InitialPlayerTeamId EocCombatTeamId
--- @field LevelName FixedString
--- @field NextRoundTeams ComponentHandleWithType[]
--- @field OrderChanges EclTurnManagerCombatOrderChange[]
--- @field Teams table<uint32, ComponentHandleWithType>
--- @field TurnTimer float


--- @class EclTurnManagerCombatOrderChange
--- @field OrderIndex int32
--- @field TeamId uint32


--- @class EclCharacterCreationCharacterCreationManager
--- @field CharCreationUI1 EclEoCUI
--- @field CharCreationUI2 EclEoCUI
--- @field CharCreationUIHandle1 ComponentHandle
--- @field CharCreationUIHandle2 ComponentHandle
--- @field Customizations table<NetId, EclCharacterCreationCharacterCustomization>
--- @field RefCounts table<NetId, int32>


--- @class EclCharacterCreationCharacterCustomization
--- @field ArmorState uint8
--- @field CharacterHandle ComponentHandle
--- @field State EclCharacterCreationCharacterCustomizationState
--- @field State2 EclCharacterCreationCharacterCustomizationState


--- @class EclCharacterCreationCharacterCustomizationState
--- @field AiPersonality TranslatedString
--- @field AttributePointsAssigned int32
--- @field CivilAbilityPointsAssigned int32
--- @field Class CharacterCreationClassDesc
--- @field Color1 CharacterCreationColorDesc
--- @field Color2 CharacterCreationColorDesc
--- @field Color3 CharacterCreationColorDesc
--- @field CombatAbilityPointsAssigned int32
--- @field Equipment FixedString
--- @field HairColor CharacterCreationColorDesc
--- @field Icon FixedString
--- @field IsMale bool
--- @field MusicInstrumentID FixedString
--- @field Name STDWString
--- @field Origin FixedString
--- @field RootTemplate FixedString
--- @field Skills FixedString[]
--- @field SkinColor CharacterCreationColorDesc
--- @field TalentPointsAssigned int32
--- @field VerifiedName STDWString
--- @field VisualSetIndices uint64
--- @field VoiceId int32


--- @class EclCharacterCreationUICharacterCreationWizard : EclEoCUI
--- @field AssignedPoints EclCharacterCreationUICharacterCreationWizardPoints
--- @field AvailablePoints EclCharacterCreationUICharacterCreationWizardPoints
--- @field CCFlags uint8
--- @field CCFlags2 uint8
--- @field CharIconHeight int32
--- @field CharIconWidth int32
--- @field CharacterCreationManager EclCharacterCreationCharacterCreationManager
--- @field CharacterHandle ComponentHandle
--- @field CharacterNetId NetId
--- @field ChosenListCols uint16
--- @field ChosenListIconSize uint8
--- @field ChosenListSpacingH int32
--- @field ChosenListSpacingV int32
--- @field CurrentStep uint8
--- @field ExtraStatPointTalentFlags uint8
--- @field HelmetState uint8
--- @field IconSize float
--- @field IconSpacing float
--- @field IconSpacingH uint8
--- @field IconSpacingV uint8
--- @field IsMale bool
--- @field ListSpacing uint8
--- @field MousePos int32
--- @field NumberOfCols uint8
--- @field OriginIndex uint8
--- @field PlayerIndex int32
--- @field Position vec3
--- @field RotateFlag uint8
--- @field Rotation float
--- @field SkillIconSize uint8
--- @field UserIconHeight float
--- @field UserIconWidth float
--- @field Visuals Visual[]
--- @field Voices FixedString[]
--- @field Zoom float
--- @field ZoomCameraDistance float
--- @field field_460 STDWString


--- @class EclCharacterCreationUICharacterCreationWizardPoints
--- @field Ability uint8
--- @field Attribute uint8
--- @field Civil uint8
--- @field SkillSlots uint8
--- @field Talent uint8


--- @class EclLuaGameStateChangedEvent : LuaEventBase
--- @field FromState EclGameState
--- @field ToState EclGameState


--- @class EclLuaInputEvent : LuaEventBase
--- @field Event InputEvent


--- @class EclLuaRawInputEvent : LuaEventBase
--- @field Input InjectInputData


--- @class EclLuaSkillGetDescriptionParamEvent : LuaEventBase
--- @field Character CDivinityStatsCharacter
--- @field Description STDString
--- @field IsFromItem bool
--- @field Params STDString[]
--- @field Skill StatsSkillPrototype


--- @class EclLuaSkillGetPropertyDescriptionEvent : LuaEventBase
--- @field Description STDString
--- @field Property StatsPropertyExtender


--- @class EclLuaStatusGetDescriptionParamEvent : LuaEventBase
--- @field Description STDString
--- @field Owner StatsObjectInstance
--- @field Params STDString[]
--- @field Status StatsStatusPrototype
--- @field StatusSource StatsObjectInstance


--- @class EclLuaUICallEvent : LuaEventBase
--- @field Args IggyInvokeDataValue[]
--- @field Function STDString
--- @field UI UIObject
--- @field When CString


--- @class EclLuaUIObjectCreatedEvent : LuaEventBase
--- @field UI UIObject


--- @class EclLuaVisualClientMultiVisual : EclMultiEffectHandler
--- @field AttachedVisuals ComponentHandle[]
--- @field Handle ComponentHandle
--- @field AddVisual fun(self: EclLuaVisualClientMultiVisual, visualId: FixedString):Visual
--- @field Delete fun(self: EclLuaVisualClientMultiVisual)
--- @field ParseFromStats fun(self: EclLuaVisualClientMultiVisual, effect: CString, weaponBones: CString|nil)


--- @class EocAi
--- @field AIBoundsHeight float
--- @field AIBoundsMax vec3
--- @field AIBoundsMin vec3
--- @field AIBoundsRadius float
--- @field AIBoundsSize float
--- @field AiBoundType int32
--- @field AiFlags uint64
--- @field AiFlags2 uint16
--- @field AiGrid EocAiGrid
--- @field GameObject IGameObject
--- @field MyHandle ComponentHandle
--- @field Settings uint16
--- @field UseOnDistance bool
--- @field XZ vec2


--- @class EocAiGrid
--- @field GridScale float
--- @field Height uint32
--- @field OffsetX float
--- @field OffsetY float
--- @field OffsetZ float
--- @field Width uint32
--- @field FindCellsInRect fun(self: EocAiGrid, minX: float, minZ: float, maxX: float, maxZ: float, anyFlags: uint64, allFlags: uint64):vec2[]
--- @field GetAiFlags fun(self: EocAiGrid, x: float, z: float):uint64|nil
--- @field GetCellInfo fun(self: EocAiGrid, x: float, z: float)
--- @field GetHeight fun(self: EocAiGrid, x: float, z: float):float|nil
--- @field SearchForCell fun(self: EocAiGrid, x: float, z: float, radius: float, flags: ESurfaceFlag, bias: float):bool
--- @field SetAiFlags fun(self: EocAiGrid, x: float, z: float, aiFlags: uint64)
--- @field SetHeight fun(self: EocAiGrid, x: float, z: float, height: float)
--- @field UpdateAiFlagsInRect fun(self: EocAiGrid, minX: float, minZ: float, maxX: float, maxZ: float, setFlags: uint64, clearFlags: uint64):bool


--- @class EocAiPathCheckpoint
--- @field NetID NetId
--- @field X float
--- @field Y float


--- @class EocCombatComponent
--- @field Alignment1 FixedString
--- @field Alignment2 FixedString
--- @field Base BaseComponent
--- @field CanFight bool
--- @field CanForceEndTurn bool
--- @field CanGuard bool
--- @field CanJoinCombat bool
--- @field CombatAndTeamIndex EocCombatTeamId
--- @field CombatGroupId FixedString
--- @field CounterAttacked bool
--- @field DelayDeathCount bool
--- @field EnteredCombat bool
--- @field Flags EocCombatComponentFlags
--- @field FleeOnEndTurn bool
--- @field GuardOnEndTurn bool
--- @field Guarded bool
--- @field HasAttackOfOpportunity bool
--- @field InArena bool
--- @field Initiative uint16
--- @field IsBoss bool
--- @field IsInspector bool
--- @field IsTicking bool
--- @field RequestEndTurn bool
--- @field RequestEnterCombat bool
--- @field RequestTakeExtraTurn bool
--- @field TookExtraTurn bool
--- @field TurnEnded bool


--- @class EocCombatGroupInfo
--- @field Id FixedString
--- @field Name TranslatedString


--- @class EocCombatTeamId
--- @field CombatId uint8
--- @field CombinedId uint32
--- @field TeamId uint32


--- @class EocItemDefinition
--- @field Active bool
--- @field Amount uint32
--- @field CanBeMoved bool
--- @field CanBePickedUp bool
--- @field CanBeUsed bool
--- @field CanUseRemotely bool
--- @field CustomBookContent STDWString
--- @field CustomDescription STDWString
--- @field CustomDisplayName STDWString
--- @field CustomRequirements bool
--- @field DamageTypeOverwrite StatsDamageType
--- @field DeltaModSet FixedString[]
--- @field EquipmentStatsType uint32
--- @field Floating bool
--- @field GMFolding bool
--- @field GenerationBoostSet FixedString[]
--- @field GenerationItemType FixedString
--- @field GenerationLevel uint16
--- @field GenerationRandom uint32
--- @field GenerationStatsId FixedString
--- @field GoldValueOverwrite int32
--- @field HP int32
--- @field HasGeneratedStats bool
--- @field HasModifiedSkills bool
--- @field InventoryNetID NetId
--- @field InventorySubContainerNetID NetId
--- @field Invisible bool
--- @field IsGlobal bool
--- @field IsIdentified bool
--- @field IsPinnedContainer bool
--- @field ItemNetId NetId
--- @field ItemType FixedString
--- @field Key FixedString
--- @field Known bool
--- @field LevelGroupIndex int8
--- @field LockLevel uint32
--- @field NameCool uint8
--- @field NameIndex int8
--- @field NetID NetId
--- @field OriginalRootTemplate FixedString
--- @field OriginalRootTemplateType uint32
--- @field PinnedContainerTags FixedString[]
--- @field RootGroupIndex int16
--- @field RootTemplate FixedString
--- @field RootTemplateType uint32
--- @field RuneBoostSet FixedString[]
--- @field Scale_M float
--- @field Skills FixedString
--- @field Slot int16
--- @field StatsEntryName FixedString
--- @field StatsLevel uint32
--- @field Tags FixedString[]
--- @field UUID FixedString
--- @field Version uint32
--- @field WeightValueOverwrite int32
--- @field WorldRot mat3
--- @field ResetProgression fun(self: EocItemDefinition)


--- @class EocPathMover
--- @field DestinationPos vec3
--- @field PathAcceleration float
--- @field PathInterpolateValue float
--- @field PathMaxArcDist float
--- @field PathMinArcDist float
--- @field PathRadius float
--- @field PathRandom uint8
--- @field PathRepeat uint64
--- @field PathRotateOrig quat
--- @field PathRotateTarget quat
--- @field PathRotationType int32
--- @field PathShift float
--- @field PathSpeed float
--- @field PathSpeedSet float
--- @field PathType uint8
--- @field StartingPosition vec3


--- @class EocPathParams
--- @field AiGridFlag0x10 bool
--- @field AvoidTraps bool
--- @field GridRadius int32
--- @field NoSurfaceEffects bool
--- @field SurfacePathInfluences SurfacePathInfluence[]
--- @field XZ vec2
--- @field field_16 bool


--- @class EocPlayerCustomData
--- @field AiPersonality FixedString
--- @field ClassType FixedString
--- @field ClothColor1 uint32
--- @field ClothColor2 uint32
--- @field ClothColor3 uint32
--- @field CustomLookEnabled bool
--- @field HairColor uint32
--- @field Icon FixedString
--- @field IsMale bool
--- @field MusicInstrument FixedString
--- @field Name STDWString
--- @field NameTranslated TranslatedString
--- @field OriginName FixedString
--- @field OwnerProfileID FixedString
--- @field Race FixedString
--- @field ReservedProfileID FixedString
--- @field SkinColor uint32
--- @field Speaker FixedString


--- @class EocPlayerUpgrade
--- @field Abilities int32[]
--- @field AttributePoints uint32
--- @field Attributes int32[]
--- @field CivilAbilityPoints uint32
--- @field CombatAbilityPoints uint32
--- @field IsCustom bool
--- @field TalentPoints uint32
--- @field Traits uint16[]


--- @class EocSkillBarItem
--- @field ItemHandle ComponentHandle
--- @field SkillOrStatId FixedString
--- @field Type EocSkillBarItemType


--- @class EsvAIHintAreaTrigger : EsvAreaTriggerBase
--- @field IsAnchor bool


--- @class EsvASAttack : EsvActionState
--- @field AlwaysHit bool
--- @field AnimationFinished bool
--- @field DamageDurability bool
--- @field DelayDeathCharacterHandles ComponentHandle[]
--- @field HitCount int32
--- @field HitCountOffHand int32
--- @field HitObject1 EsvHitObject
--- @field HitObject2 EsvHitObject
--- @field IsFinished bool
--- @field MainHandHitType int32
--- @field MainWeaponDamageList table<ComponentHandle, StatsHitDamageInfo>
--- @field MainWeaponHandle ComponentHandle
--- @field OffHandDamageList table<ComponentHandle, StatsHitDamageInfo>
--- @field OffHandHitType int32
--- @field OffWeaponHandle ComponentHandle
--- @field ProjectileStartPosition vec3
--- @field ProjectileTargetPosition vec3
--- @field ProjectileUsesHitObject bool
--- @field ShootCount int32
--- @field ShootCountOffHand int32
--- @field TargetHandle ComponentHandle
--- @field TargetPosition vec3
--- @field TimeRemaining float
--- @field TotalHitOffHand int32
--- @field TotalHits int32
--- @field TotalShoots int32
--- @field TotalShootsOffHand int32


--- @class EsvASPrepareSkill : EsvActionState
--- @field IsEntered bool
--- @field IsFinished bool
--- @field PrepareAnimationInit FixedString
--- @field PrepareAnimationLoop FixedString
--- @field SkillId FixedString


--- @class EsvASUseSkill : EsvActionState
--- @field OriginalSkill EsvSkillState
--- @field Skill EsvSkillState


--- @class EsvActionMachine
--- @field CharacterHandle ComponentHandle
--- @field Layers EsvActionMachineLayer[]


--- @class EsvActionMachineLayer
--- @field State EsvActionState


--- @class EsvActionState
--- @field TransactionId uint32
--- @field Type EsvActionStateType


--- @class EsvAiAction
--- @field AIParams SkillAIParams
--- @field APCost int32
--- @field APCost2 int32
--- @field ActionFinalScore float
--- @field ActionType AiActionType
--- @field AiHandle ComponentHandle
--- @field CloseEnough float
--- @field CloseEnough2 float
--- @field CostModifier float
--- @field Distance float
--- @field EndPosition vec3
--- @field EndPosition2 vec3
--- @field FinalScore float
--- @field FreeActionMultiplier float
--- @field IgnoreMovementScore bool
--- @field IsFinished bool
--- @field IsPositionCalculated bool
--- @field LookAtPosition vec3
--- @field MagicCost int32
--- @field MovementFinalScore float
--- @field MovementSkillId FixedString
--- @field MovementSkillItem EsvItem
--- @field MovementSkillTargetPosition vec3
--- @field MovementType int32
--- @field PositionFinalScore float
--- @field SavingActionPoints bool
--- @field Score1 EsvAiScore
--- @field ScoreWithoutMovement EsvAiScore
--- @field SkillId FixedString
--- @field SkillItemHandle ComponentHandle
--- @field Target2Handle ComponentHandle
--- @field TargetHandle ComponentHandle
--- @field TargetPosition2 vec3
--- @field TauntedSourceHandle ComponentHandle
--- @field UseMovementSkill bool
--- @field field_94 int32
--- @field field_D8 bool
--- @field field_DA bool


--- @class EsvAiCombos
--- @field Combos EsvAiCombosCombo[]
--- @field DamageTypes StatsDamageType[]
--- @field SkillPrototypes FixedString[]
--- @field SurfaceComboIndices table<SurfaceType, uint64[]>


--- @class EsvAiCombosCombo
--- @field SurfaceType1 SurfaceType
--- @field SurfaceType2 SurfaceType
--- @field TransformType SurfaceTransformActionType
--- @field field_C uint8


--- @class EsvAiHelpers
--- @field AiFlagsStack uint8[]
--- @field AiTranslateOverrides table<ComponentHandle, EsvAiTranslateOverride>
--- @field AllyCharacters EsvCharacter[]
--- @field AllyCharacters2 EsvCharacter[]
--- @field CharacterAiRequests table<ComponentHandle, EsvAiRequest>
--- @field Combos EsvAiCombos
--- @field CurrentAiRequestObjects ComponentHandle[]
--- @field CurrentItem EsvItem
--- @field EnemyCharacters EsvCharacter[]
--- @field Flags uint8
--- @field HighestCharacterHP int32
--- @field Items EsvItem[]
--- @field KnownState EsvAiKnownStateSet
--- @field KnownStateStack EsvAiKnownStateSet[]
--- @field LowestCharacterHP int32
--- @field Modifiers EsvAiHelpersModifiers
--- @field NeutralCharacters EsvCharacter[]
--- @field OS_FixedString FixedString[]
--- @field OverrideTranslate vec3
--- @field PendingCharacters ComponentHandle[]
--- @field PreparingAiGrid EocAiGrid
--- @field PreparingCharacter EsvCharacter
--- @field PreparingLevel EsvLevel
--- @field SameCombatCharacters EsvCharacter[]
--- @field SameCombatEnemyCharacters EsvCharacter[]
--- @field SameCombatNeutralCharacters EsvCharacter[]
--- @field Surfaces EsvSurface[]


--- @class EsvAiHelpersModifiers
--- @field Modifiers float[]


--- @class EsvAiItemData
--- @field AIParams SkillAIParams
--- @field ItemHandle ComponentHandle


--- @class EsvAiKnownState
--- @field State EsvAiKnownStateImpl


--- @class EsvAiKnownStateImpl
--- @field States EsvAiKnownStateSet
--- @field States2 EsvAiKnownStateSet


--- @class EsvAiKnownStateSet
--- @field StatusInteractions EsvAiKnownStateSetStatusInteraction[]
--- @field SurfaceInteractions EsvAiKnownStateSetSurfaceInteraction[]
--- @field SurfaceOnObjectActions EsvAiKnownStateSetSurfaceOnObjectAction[]


--- @class EsvAiKnownStateSetStatusInteraction
--- @field HasLifeTime bool
--- @field StatusId FixedString
--- @field TargetHandle ComponentHandle


--- @class EsvAiKnownStateSetSurfaceInteraction
--- @field SurfaceHandle ComponentHandle
--- @field SurfaceTransform SurfaceTransformActionType
--- @field SurfaceTypeByLayer SurfaceType[]
--- @field field_14 int32


--- @class EsvAiKnownStateSetSurfaceOnObjectAction
--- @field HasLifeTime bool
--- @field SurfaceTypeId SurfaceType
--- @field TargetHandle ComponentHandle


--- @class EsvAiModifiers
--- @field ArchetypeNames FixedString[]
--- @field Archetypes table<FixedString, EsvAiHelpersModifiers>
--- @field BaseModifiers EsvAiHelpersModifiers


--- @class EsvAiRequest
--- @field ActionCount uint64
--- @field AiActionToExecute uint32
--- @field AiActions EsvAiAction[]
--- @field CalculationFinished bool
--- @field CanMove bool
--- @field CurrentAiActionIndex uint32
--- @field CurrentAiItemIndex uint32
--- @field CurrentAiSkill2Index uint32
--- @field CurrentAiSkillIndex uint32
--- @field HasAiOnPositionSkillData bool
--- @field HighestActionScore float
--- @field IsCalculating bool
--- @field Items EsvAiItemData[]
--- @field LastStep AiActionStep
--- @field OnPositionSkills EsvAiSkillData[]
--- @field Skills EsvAiSkillData[]
--- @field UnknownHandles ComponentHandle[]
--- @field UseBehaviorVariables bool


--- @class EsvAiScore
--- @field Score EsvAiScoreImpl


--- @class EsvAiScoreImpl
--- @field DamageAmounts table<ComponentHandle, EsvAiScoreImplDamageAmount>
--- @field FailScore float
--- @field Flags1 uint16
--- @field FutureScore float
--- @field Reason AiScoreReasonFlags
--- @field SoftReasonFlags2 uint32
--- @field field_4 int32


--- @class EsvAiScoreImplDamageAmount
--- @field ArmorDamage float
--- @field BoostAmount float
--- @field ControlAmount float
--- @field DamageAmount float
--- @field DoTAmount float
--- @field HealAmount float
--- @field HoTAmount float
--- @field MagicArmorDamage float
--- @field PositionScore float


--- @class EsvAiSkillData
--- @field AIParams SkillAIParams
--- @field ItemHandle ComponentHandle
--- @field SkillId FixedString


--- @class EsvAiTranslateOverride
--- @field NewTranslate vec3
--- @field OriginalTranslate vec3


--- @class EsvAlignment : EsvHasRelationsObject
--- @field Entities EsvAlignmentEntity[]
--- @field MatrixIndex int32
--- @field MatrixIndex2 int32


--- @class EsvAlignmentContainer
--- @field Get fun(self: EsvAlignmentContainer):EsvAlignmentData
--- @field GetAll fun(self: EsvAlignmentContainer):ComponentHandle[]
--- @field IsPermanentEnemy fun(self: EsvAlignmentContainer, source: ComponentHandle, target: ComponentHandle):bool
--- @field IsTemporaryEnemy fun(self: EsvAlignmentContainer, source: ComponentHandle, target: ComponentHandle):bool
--- @field SetAlly fun(self: EsvAlignmentContainer, source: ComponentHandle, target: ComponentHandle, enabled: bool)
--- @field SetPermanentEnemy fun(self: EsvAlignmentContainer, source: ComponentHandle, target: ComponentHandle, enabled: bool)
--- @field SetTemporaryEnemy fun(self: EsvAlignmentContainer, source: ComponentHandle, target: ComponentHandle, enabled: bool)


--- @class EsvAlignmentData
--- @field Alignment EsvAlignment
--- @field Handle ComponentHandle
--- @field HasOwnAlignment bool
--- @field MatrixIndex int32
--- @field Name FixedString
--- @field NetID NetId
--- @field ParentAlignment EsvAlignment


--- @class EsvAlignmentEntity : EsvHasRelationsObject


--- @class EsvAreaTriggerBase : AreaTrigger


--- @class EsvAtmosphereTrigger : AtmosphereTrigger


--- @class EsvAura
--- @field AppliedAuras table<ComponentHandle, EsvAuraAppliedAura>
--- @field AuraAllies FixedString[]
--- @field AuraEnemies FixedString[]
--- @field AuraItems FixedString[]
--- @field AuraNeutrals FixedString[]
--- @field AuraSelf FixedString[]
--- @field Owner ComponentHandle
--- @field SomeObjHandle ComponentHandle
--- @field TickTimer float


--- @class EsvAuraAppliedAura
--- @field AppliedStatuses ComponentHandle[]
--- @field LifeTime float


--- @class EsvBaseController
--- @field Character ComponentHandle
--- @field TypeId int32


--- @class EsvChangeSurfaceOnPathAction : EsvCreateSurfaceActionBase
--- @field CheckExistingSurfaces bool
--- @field FollowObject ComponentHandle
--- @field IgnoreIrreplacableSurfaces bool
--- @field IgnoreOwnerCells bool
--- @field IsFinished bool
--- @field Radius float
--- @field SurfaceCollisionFlags uint32
--- @field SurfaceCollisionNotOnFlags uint32


--- @class EsvCharacter : IEoCServerObject
--- @field AI EocAi
--- @field ActionMachine EsvActionMachine
--- @field Activated bool
--- @field AnimType uint8
--- @field AnimationOverride FixedString
--- @field AnimationSetOverride FixedString
--- @field Archetype FixedString
--- @field CanShootThrough bool
--- @field CannotDie bool
--- @field CannotMove bool
--- @field CannotRun bool
--- @field CharCreationInProgress bool
--- @field CharacterControl bool
--- @field CharacterCreationFinished bool
--- @field Color uint8
--- @field CorpseCharacterHandle ComponentHandle
--- @field CorpseLootable bool
--- @field CoverAmount bool
--- @field CreatedTemplateItems FixedString[]
--- @field CrimeHandle ComponentHandle
--- @field CrimeInterrogationEnabled bool
--- @field CrimeState uint32
--- @field CrimeWarningsEnabled bool
--- @field CurrentLevel FixedString
--- @field CurrentTemplate CharacterTemplate
--- @field CustomBloodSurface SurfaceType
--- @field CustomDisplayName STDWString
--- @field CustomLookEnabled bool
--- @field CustomTradeTreasure FixedString
--- @field DamageCounter uint64
--- @field Deactivated bool
--- @field Dead bool
--- @field DeferredRemoveEscapist bool
--- @field DelayDeathCount uint8
--- @field DelayedDyingStatus EsvStatus
--- @field Dialog uint32
--- @field DialogController EsvTaskController
--- @field DisableCulling bool
--- @field DisableFlee_M bool
--- @field DisabledCrime FixedString[]
--- @field DontCacheTemplate bool
--- @field EnemyCharacterHandle ComponentHandle
--- @field EnemyHandles ComponentHandle[]
--- @field EquipmentColor FixedString
--- @field FightMode bool
--- @field FindValidPositionOnActivate bool
--- @field Flags EsvCharacterFlags
--- @field Flags2 EsvCharacterFlags2
--- @field Flags3 EsvCharacterFlags3
--- @field FlagsEx uint8
--- @field Floating bool
--- @field FollowCharacterHandle ComponentHandle
--- @field ForceNonzeroSpeed bool
--- @field ForceSynchCount uint8
--- @field GMReroll bool
--- @field Global bool
--- @field HasDefaultDialog bool
--- @field HasOsirisDialog bool
--- @field HasOwner bool
--- @field HasRunSpeedOverride bool
--- @field HasWalkSpeedOverride bool
--- @field HealCounter uint64
--- @field HostControl bool
--- @field IgnoresTriggers bool
--- @field InArena bool
--- @field InDialog bool
--- @field InParty bool
--- @field InventoryHandle ComponentHandle
--- @field InvestigationTimer uint32
--- @field Invulnerable bool
--- @field IsAlarmed bool
--- @field IsCompanion_M bool
--- @field IsDialogAiControlled bool
--- @field IsGameMaster bool
--- @field IsHuge bool
--- @field IsPet bool
--- @field IsPlayer bool
--- @field IsPossessed bool
--- @field IsSpectating bool
--- @field KillCounter uint64
--- @field LevelTransitionPending bool
--- @field LifeTime float
--- @field Loaded bool
--- @field ManuallyLeveled bool
--- @field MovementMachine EsvMovementMachine
--- @field MovingCasterHandle ComponentHandle
--- @field Multiplayer bool
--- @field NeedsMakePlayerUpdate bool
--- @field NeedsUpdateCount uint8
--- @field NoReptuationEffects bool
--- @field NoRotate bool
--- @field NoiseTimer float
--- @field NumConsumables uint8
--- @field ObjectHandle6 ComponentHandle
--- @field OffStage bool
--- @field OriginalTemplate CharacterTemplate
--- @field OriginalTransformDisplayName TranslatedString
--- @field OsirisController EsvTaskController
--- @field OwnerHandle ComponentHandle
--- @field PartialAP float
--- @field PartyFollower bool
--- @field PartyHandle ComponentHandle
--- @field Passthrough bool
--- @field PlayerCustomData EocPlayerCustomData
--- @field PlayerData EsvPlayerData
--- @field PlayerUpgrade EocPlayerUpgrade
--- @field PreferredAiTarget FixedString[]
--- @field PreviousCrimeHandle ComponentHandle
--- @field PreviousCrimeState uint32
--- @field PreviousLevel FixedString
--- @field ProjectileTemplate FixedString
--- @field ReadyCheckBlocked bool
--- @field RegisteredForAutomatedDialog bool
--- @field RegisteredTriggerHandles ComponentHandle[]
--- @field RegisteredTriggers FixedString[]
--- @field RequestStartTurn bool
--- @field ReservedForDialog bool
--- @field ReservedUserID UserId
--- @field Resurrected bool
--- @field RootTemplate CharacterTemplate
--- @field RunSpeedOverride float
--- @field ScriptForceUpdateCount uint8
--- @field ServerControlRefCount uint32
--- @field SkillBeingPrepared FixedString
--- @field SkillManager EsvSkillManager
--- @field SpeedMultiplier float
--- @field SpiritCharacterHandle ComponentHandle
--- @field SpotSneakers bool
--- @field Stats CDivinityStatsCharacter
--- @field StatusController EsvStatusController
--- @field StatusMachine EsvStatusMachine
--- @field StatusesFromItems table<ComponentHandle, StatsPropertyStatus[]>
--- @field StoryNPC bool
--- @field Summon bool
--- @field SummonHandles ComponentHandle[]
--- @field SurfacePathInfluences SurfacePathInfluence[]
--- @field Tags FixedString[]
--- @field TagsFromItems FixedString[]
--- @field Team uint8
--- @field TemplateUsedForSkills CharacterTemplate
--- @field Temporary bool
--- @field TimeElapsed uint32
--- @field Totem bool
--- @field Trader bool
--- @field TreasureGeneratedForTrader bool
--- @field Treasures FixedString[]
--- @field TriggerTrapsTimer float
--- @field TurnTimer float
--- @field UserID UserId
--- @field VoiceSet FixedString[]
--- @field WalkSpeedOverride float
--- @field WalkThrough bool
--- @field WorldPos vec3
--- @field WorldRot mat3
--- @field GetCustomStat fun(self: EsvCharacter, a1: FixedString):int32|nil
--- @field GetInventoryItems fun(self: EsvCharacter):FixedString[]
--- @field GetSkillInfo fun(self: EsvCharacter, skill: FixedString):EsvSkill
--- @field GetSkills fun(self: EsvCharacter):FixedString[]
--- @field GetSummons fun(self: EsvCharacter):FixedString[]
--- @field SetCustomStat fun(self: EsvCharacter, a1: FixedString, a2: int32):bool
--- @field SetScale fun(self: EsvCharacter, a1: float)
local EsvCharacter = {}



--- Retrieves the GUID of all characters within the specified range.
--- Location: Lua/Server/ServerCharacter.inl:55
--- @param distance float Maximum character distance
--- @return FixedString[]
function EsvCharacter:GetNearbyCharacters(distance) end



--- @class EsvCharacterConversionHelpers
--- @field ActivatedCharacters table<FixedString, EsvCharacter[]>
--- @field RegisteredCharacters table<FixedString, EsvCharacter[]>


--- @class EsvCharacterManager
--- @field ActiveAnimationBlueprints EsvCharacterManagerAnimationBlueprintEntry[]
--- @field ActiveCharacters EsvCharacter[]
--- @field NetPendingTransforms EsvCharacterManagerTransformParams[]
--- @field PendingTransforms EsvCharacterManagerTransformParams[]
--- @field RegisteredCharacters EsvCharacter[]


--- @class EsvCharacterManagerAnimationBlueprintEntry
--- @field Character EsvCharacter


--- @class EsvCharacterManagerTransformParams
--- @field DiscardOriginalDisplayName bool
--- @field DontCheckRootTemplate bool
--- @field DontReplaceCombatState bool
--- @field EquipmentSetName FixedString
--- @field Flags EsvCharacterTransformFlags
--- @field Immediate bool
--- @field ImmediateSync bool
--- @field PeerID int32
--- @field ReleasePlayerData bool
--- @field ReplaceCurrentTemplate bool
--- @field ReplaceCustomLooks bool
--- @field ReplaceCustomNameIcon bool
--- @field ReplaceEquipment bool
--- @field ReplaceInventory bool
--- @field ReplaceOriginalTemplate bool
--- @field ReplaceScale bool
--- @field ReplaceScripts bool
--- @field ReplaceSkills bool
--- @field ReplaceStats bool
--- @field ReplaceTags bool
--- @field ReplaceVoiceSet bool
--- @field SaveOriginalDisplayName bool
--- @field TargetCharacterHandle ComponentHandle
--- @field Template TemplateHandle
--- @field TemplateCharacterHandle ComponentHandle
--- @field TransformType EsvCharacterTransformType


--- @class EsvCombatComponent : EocCombatComponent


--- @class EsvCreatePuddleAction : EsvCreateSurfaceActionBase
--- @field CellAtGrow EsvSurfaceCell[]
--- @field ClosedCells EsvSurfaceCell[]
--- @field GrowSpeed float
--- @field GrowTimer float
--- @field IgnoreIrreplacableSurfaces bool
--- @field IsFinished bool
--- @field Step int32
--- @field SurfaceCells int32


--- @class EsvCreateSurfaceAction : EsvCreateSurfaceActionBase
--- @field CheckExistingSurfaces bool
--- @field CurrentCellCount int32
--- @field ExcludeRadius float
--- @field GrowStep int32
--- @field GrowTimer float
--- @field IgnoreIrreplacableSurfaces bool
--- @field MaxHeight float
--- @field Radius float
--- @field SurfaceCells EsvSurfaceCell[]
--- @field SurfaceCollisionFlags uint64
--- @field SurfaceCollisionNotOnFlags uint64
--- @field SurfaceLayer SurfaceLayer
--- @field Timer float


--- @class EsvCreateSurfaceActionBase : EsvSurfaceAction
--- @field Duration float
--- @field OwnerHandle ComponentHandle
--- @field Position vec3
--- @field StatusChance float
--- @field SurfaceHandlesByType ComponentHandle[]
--- @field SurfaceType SurfaceType


--- @class EsvCrimeAreaTrigger : EsvAreaTriggerBase
--- @field CrimeArea int32


--- @class EsvCrimeRegionTrigger : EsvAreaTriggerBase
--- @field TriggerRegion FixedString


--- @class EsvDamageHelpers
--- @field CriticalRoll StatsCriticalRoll
--- @field DamageSourceType CauseType
--- @field ForceReduceDurability bool
--- @field HighGround StatsHighGroundBonus
--- @field HitReason uint32
--- @field HitType StatsHitType
--- @field NoHitRoll bool
--- @field ProcWindWalker bool
--- @field SimulateHit bool
--- @field Strength float


--- @class EsvDefaultProjectileHit
--- @field CasterHandle ComponentHandle
--- @field IsFromItem bool
--- @field Level int32
--- @field SkillId FixedString


--- @class EsvEffect : BaseComponent
--- @field BeamTarget ComponentHandle
--- @field BeamTargetBone FixedString
--- @field BeamTargetPos vec3
--- @field Bone FixedString
--- @field DetachBeam bool
--- @field Duration float
--- @field EffectName FixedString
--- @field ForgetEffect bool
--- @field IsDeleted bool
--- @field IsForgotten bool
--- @field Loop bool
--- @field NetID NetId
--- @field Position vec3
--- @field Rotation mat3
--- @field Scale float
--- @field Target ComponentHandle
--- @field Delete fun(self: EsvEffect)


--- @class EsvEffectManager
--- @field DeletedEffects EsvEffect[]
--- @field Effects EsvEffect[]
--- @field ForgottenEffects EsvEffect[]


--- @class EsvEntityManager
--- @field CharacterConversionHelpers EsvCharacterConversionHelpers
--- @field ItemConversionHelpers EsvItemConversionHelpers
--- @field ProjectileConversionHelpers EsvProjectileConversionHelpers
--- @field TriggerConversionHelpers EsvTriggerConversionHelpers


--- @class EsvEnvironmentalInfluences
--- @field HasWeatherProofTalent bool
--- @field OwnerHandle ComponentHandle
--- @field PermanentInfluences table<FixedString, EsvEnvironmentalInfluencesPermanentInfluence>
--- @field Statuses table<FixedString, EsvEnvironmentalInfluencesStatus>
--- @field TemporaryStatuses table<FixedString, EsvEnvironmentalInfluencesTemporaryStatus>
--- @field Unknown FixedString[]


--- @class EsvEnvironmentalInfluencesPermanentInfluence
--- @field Strength float
--- @field WeatherStrength float


--- @class EsvEnvironmentalInfluencesStatus
--- @field FirstAttempt bool
--- @field Handle ComponentHandle
--- @field IsForced bool


--- @class EsvEnvironmentalInfluencesTemporaryStatus
--- @field Handle ComponentHandle
--- @field IsForced bool
--- @field LifeTime float
--- @field Strength float
--- @field WeatherStrength float


--- @class EsvEnvironmentalStatusManager
--- @field EnvironmentalInfluences table<ComponentHandle, EsvEnvironmentalInfluences>
--- @field Timer float


--- @class EsvEocAreaTrigger : EsvAreaTriggerBase


--- @class EsvEocPointTrigger : EsvPointTriggerBase


--- @class EsvEventTrigger : EsvAreaTriggerBase
--- @field EnterEvent FixedString
--- @field LeaveEvent FixedString


--- @class EsvExplorationTrigger : EsvAreaTriggerBase
--- @field ExplorationReward int32
--- @field OS_FS FixedString[]


--- @class EsvExtinguishFireAction : EsvCreateSurfaceActionBase
--- @field ExtinguishPosition vec3
--- @field GrowTimer float
--- @field Percentage float
--- @field Radius float
--- @field Step float


--- @class EsvGameAction
--- @field ActionType GameActionType
--- @field ActivateTimer float
--- @field Active bool
--- @field Dirty bool
--- @field Handle ComponentHandle
--- @field NetID NetId


--- @class EsvGameActionManager
--- @field GameActions EsvGameAction[]


--- @class EsvGameObjectMoveAction : EsvGameAction
--- @field BeamEffectName FixedString
--- @field CasterCharacterHandle ComponentHandle
--- @field DoneMoving bool
--- @field Owner ComponentHandle
--- @field PathMover EocPathMover


--- @class EsvHasRelationsObject
--- @field Handle ComponentHandle
--- @field Name FixedString
--- @field NetID NetId
--- @field TemporaryRelations table<ComponentHandle, int32>
--- @field TemporaryRelations2 table<ComponentHandle, int32>


--- @class EsvHitObject
--- @field HitInterpolation int32
--- @field Position vec3
--- @field Target ComponentHandle


--- @class EsvInventory
--- @field BuyBackAmounts table<ComponentHandle, uint32>
--- @field CachedGoldAmount int32
--- @field CachedWeight int32
--- @field EquipmentSlots uint8
--- @field GUID FixedString
--- @field Handle ComponentHandle
--- @field IsGlobal bool
--- @field ItemsBySlot ComponentHandle[]
--- @field NetID NetId
--- @field ParentHandle ComponentHandle
--- @field PinnedContainers ComponentHandle[]
--- @field TimeItemAddedToInventory table<ComponentHandle, uint32>
--- @field UpdateViews ComponentHandle[]
--- @field Views table<int32, ComponentHandle>


--- @class EsvInventoryView
--- @field Handle ComponentHandle
--- @field ItemIndices table<ComponentHandle, int32>
--- @field Items ComponentHandle[]
--- @field NetID NetId
--- @field Owner ComponentHandle
--- @field ParentType uint32
--- @field Parents ComponentHandle[]
--- @field PinnedContainerTags ComponentHandle[]
--- @field ViewId uint32


--- @class EsvItem : IEoCServerObject
--- @field AI EocAi
--- @field Activated bool
--- @field Amount uint32
--- @field Armor uint32
--- @field CanBeMoved bool
--- @field CanBePickedUp bool
--- @field CanConsume bool
--- @field CanOnlyBeUsedByOwner bool
--- @field CanShootThrough bool
--- @field CanUse bool
--- @field ClientSync1 bool
--- @field ClientSync2 bool
--- @field ComputedVitality int32
--- @field CurrentLevel FixedString
--- @field CurrentTemplate ItemTemplate
--- @field CustomBookContent STDWString
--- @field CustomDescription STDWString
--- @field CustomDisplayName STDWString
--- @field Destroy bool
--- @field Destroyed bool
--- @field DisableSync bool
--- @field DontAddToHotbar bool
--- @field Flags EsvItemFlags
--- @field Flags2 EsvItemFlags2
--- @field Floating bool
--- @field ForceClientSync bool
--- @field ForceSync bool
--- @field ForceSynch bool
--- @field FreezeGravity bool
--- @field Frozen bool
--- @field GMFolding bool
--- @field Generation EsvItemGeneration
--- @field Global bool
--- @field GoldValueOverwrite int32
--- @field HideHP bool
--- @field InAutomatedDialog bool
--- @field InUseByCharacterHandle ComponentHandle
--- @field InteractionDisabled bool
--- @field InventoryHandle ComponentHandle
--- @field Invisible bool
--- @field Invisible2 bool
--- @field Invulnerable bool
--- @field Invulnerable2 bool
--- @field IsContainer bool
--- @field IsDoor bool
--- @field IsKey bool
--- @field IsLadder bool
--- @field IsSecretDoor bool
--- @field IsSurfaceBlocker bool
--- @field IsSurfaceCloudBlocker bool
--- @field Key FixedString
--- @field Known bool
--- @field LevelOverride int32
--- @field LoadedTemplate bool
--- @field LockLevel uint32
--- @field NoCover bool
--- @field OffStage bool
--- @field OriginalOwnerCharacter ComponentHandle
--- @field OriginalTemplateType uint64
--- @field OwnerHandle ComponentHandle
--- @field ParentInventoryHandle ComponentHandle
--- @field PinnedContainer bool
--- @field PositionChanged bool
--- @field PreviousLevel FixedString
--- @field Rarity FixedString
--- @field ReservedForDialog bool
--- @field RootTemplate ItemTemplate
--- @field Slot uint16
--- @field SourceContainer bool
--- @field Stats CDivinityStatsItem
--- @field StatsFromName StatsObject
--- @field StatsId FixedString
--- @field StatusMachine EsvStatusMachine
--- @field Sticky bool
--- @field StoryItem bool
--- @field Summon bool
--- @field Tags FixedString[]
--- @field TeleportOnUse bool
--- @field TeleportTargetOverride uint64
--- @field TeleportUseCount int32
--- @field Totem bool
--- @field TransformChanged bool
--- @field TreasureGenerated bool
--- @field TreasureLevel int32
--- @field UnEquipLocked bool
--- @field UnsoldGenerated bool
--- @field UseRemotely bool
--- @field UserId uint32
--- @field VisualResourceID FixedString
--- @field Vitality uint32
--- @field WakePhysics bool
--- @field WalkOn bool
--- @field WalkThrough bool
--- @field WeightValueOverwrite int32
--- @field WorldPos vec3
--- @field GetDeltaMods fun(self: EsvItem):FixedString[]
--- @field GetGeneratedBoosts fun(self: EsvItem):FixedString[]
--- @field GetInventoryItems fun(self: EsvItem):FixedString[]
--- @field GetNearbyCharacters fun(self: EsvItem, distance: float):FixedString[]
--- @field SetDeltaMods fun(self: EsvItem)
--- @field SetGeneratedBoosts fun(self: EsvItem)


--- @class EsvItemConversionHelpers
--- @field ActivatedItems table<FixedString, EsvItem[]>
--- @field GlobalItemHandles table<FixedString, ComponentHandle>
--- @field RegisteredItems table<FixedString, EsvItem[]>


--- @class EsvItemGeneration
--- @field Base FixedString
--- @field Boosts FixedString[]
--- @field ItemType FixedString
--- @field Level uint16
--- @field Random uint32


--- @class EsvItemManager
--- @field ActiveItems EsvItem[]
--- @field Items EsvItem[]
--- @field Mover EsvItemMover
--- @field NetPendingTransforms EsvItemManagerTransformParams[]
--- @field PendingTransforms EsvItemManagerTransformParams[]


--- @class EsvItemManagerTransformParams
--- @field Flags EsvItemTransformFlags
--- @field Immediate bool
--- @field ItemHandle ComponentHandle
--- @field ReplaceScripts bool
--- @field ReplaceStats bool
--- @field TemplateHandle TemplateHandle


--- @class EsvItemMovement
--- @field AiBounds vec3
--- @field DoHitTest bool
--- @field HeightForced bool
--- @field InventoryAdd EsvItemMovementInventoryAddParams
--- @field ItemHandle ComponentHandle
--- @field MoveEventName STDString
--- @field MoverHandle ComponentHandle
--- @field Moving bool
--- @field MovingInWorld bool
--- @field MovingToInventory bool
--- @field WakePhysics bool


--- @class EsvItemMovementInventoryAddParams
--- @field Flags uint32
--- @field InventoryNetId NetId
--- @field OwnerCharacterHandle ComponentHandle
--- @field Slot StatsItemSlot


--- @class EsvItemMover
--- @field Movements table<ComponentHandle, EsvItemMovement>


--- @class EsvLevel : Level
--- @field AiGrid EocAiGrid
--- @field CharacterManager EsvCharacterManager
--- @field EffectManager EsvEffectManager
--- @field EntityManager EsvEntityManager
--- @field EnvironmentalStatusManager EsvEnvironmentalStatusManager
--- @field GameActionManager EsvGameActionManager
--- @field ItemManager EsvItemManager
--- @field LevelCacheTemplateManager LevelCacheTemplateManager
--- @field ProjectileManager EsvProjectileManager
--- @field SurfaceManager EsvSurfaceManager


--- @class EsvLevelManager
--- @field CurrentLevel EsvLevel
--- @field LevelDescs LevelDesc[]
--- @field Levels table<FixedString, EsvLevel>
--- @field Levels2 table<FixedString, EsvLevel>


--- @class EsvMSMoveTo : EsvMovementState
--- @field AiBounds_M vec3
--- @field AiFlags uint64
--- @field AiFloodDone bool
--- @field AiHandle ComponentHandle
--- @field AiPathId int32
--- @field AutoFreeMovement bool
--- @field CanRun bool
--- @field CannotMove bool
--- @field CharCurrentPositionXY vec2
--- @field CharacterScale float
--- @field CloseEnoughDistMax float
--- @field CloseEnoughDistMin float
--- @field CurPosition vec3
--- @field CurPositionOld vec3
--- @field CurPositionOld2 vec3
--- @field FreeMovement bool
--- @field Horizon int16
--- @field IsPathfinding bool
--- @field MovementAP float
--- @field NextAiHandle ComponentHandle
--- @field NextCloseEnoughDistMax float
--- @field NextCloseEnoughDistMin float
--- @field NextHorizon int16
--- @field NextSurfaceNavigationType int32
--- @field NextTargetCheckType int32
--- @field NextUseCharacterRadius bool
--- @field Nextfield_46 uint8
--- @field PathParams EocPathParams
--- @field PathTimeout2 float
--- @field Paused bool
--- @field Position vec3
--- @field Position2 vec3
--- @field PositionUpdated bool
--- @field Speed float
--- @field SurfaceNavigationType int32
--- @field TargetAiGridFlag0x10 bool
--- @field TargetCheckType int32
--- @field TimeUntilNextPathfinding float
--- @field TimeUntilNextPathing float
--- @field UseCharacterRadius bool
--- @field field_D4 int32
--- @field field_DC bool
--- @field field_DD bool
--- @field field_E4 int32


--- @class EsvMSMovement : EsvMovementState


--- @class EsvMoveTask : EsvTask
--- @field ArriveEvent STDString
--- @field Checkpoints EocAiPathCheckpoint[]
--- @field CurrentTarget vec3
--- @field MoveTransactionId uint32
--- @field TimeSpent float
--- @field TimeTargetFound float


--- @class EsvMovementMachine
--- @field Active bool
--- @field CharacterHandle ComponentHandle
--- @field Layers EsvMovementState[]


--- @class EsvMovementState
--- @field TransactionId int32
--- @field Type EsvMovementStateType


--- @class EsvMusicVolumeTrigger : EsvAreaTriggerBase
--- @field MusicEvents MusicVolumeTriggerDataMusicEvent[]
--- @field TriggeredBy EsvMusicVolumeTriggerTriggered[]


--- @class EsvMusicVolumeTriggerTriggered
--- @field Index int16
--- @field Slot int16


--- @class EsvOsirisAppearTask : EsvTask
--- @field Angle float
--- @field Animation FixedString
--- @field FinishedEvent STDString
--- @field OnTrail bool
--- @field OutOfSight bool
--- @field PlayerSpawn bool
--- @field SpawnState uint32
--- @field Target ComponentHandle
--- @field TargetPos vec3


--- @class EsvOsirisAttackTask : EsvTask
--- @field AlwaysHit bool
--- @field ArriveEvent STDString
--- @field BehaviorTransactionId uint32
--- @field Target ComponentHandle
--- @field TargetPos vec3
--- @field WithoutMove bool


--- @class EsvOsirisDisappearTask : EsvTask
--- @field Angle float
--- @field DefaultSpeed float
--- @field DisappearCount int32
--- @field FinishedEvent STDString
--- @field IncreaseSpeed bool
--- @field OffStage bool
--- @field OutOfSight bool
--- @field Running bool
--- @field SpeedMultiplier float
--- @field Target ComponentHandle
--- @field TargetPos vec3
--- @field ValidTarget bool


--- @class EsvOsirisDropTask : EsvTask
--- @field Item ComponentHandle
--- @field TargetPos vec3


--- @class EsvOsirisFleeTask : EsvMoveTask
--- @field FleeFromRelation int32
--- @field FleeFromRelationRange float
--- @field FleeFromTileStates uint64
--- @field OutOfSight bool
--- @field StartPosition vec3
--- @field StartedMoving bool
--- @field SurfacePathInfluences SurfacePathInfluence[]


--- @class EsvOsirisFollowNPCTask : EsvTask
--- @field Target ComponentHandle


--- @class EsvOsirisMoveInRangeTask : EsvMoveTask
--- @field AttackMove bool
--- @field CachedCloseEnough float
--- @field CachedResult bool
--- @field CachedTarget vec3
--- @field CachedTargetPos vec3
--- @field FallbackMoveCloser bool
--- @field HintTriggers EsvAIHintAreaTrigger[]
--- @field MaxRange float
--- @field MinRange float
--- @field MustBeInTrigger bool
--- @field ProjectileTemplate GameObjectTemplate
--- @field Skill StatsSkillPrototype
--- @field Target ComponentHandle
--- @field TargetPos vec3
--- @field WantedRange float


--- @class EsvOsirisMoveItemTask : EsvTask
--- @field Amount int32
--- @field ArriveEvent STDString
--- @field BehaviorTransactionId uint32
--- @field Item ComponentHandle
--- @field Position vec3


--- @class EsvOsirisMoveToAndTalkTask : EsvTask
--- @field BehaviorTransactionId uint32
--- @field DialogInstanceID FixedString
--- @field IsAutomatedDialog bool
--- @field Movement FixedString
--- @field Target ComponentHandle
--- @field Timeout float


--- @class EsvOsirisMoveToLocationTask : EsvMoveTask
--- @field MaxDistance float
--- @field MinDistance float
--- @field TargetRotation float
--- @field TargetRotationSet bool
--- @field TargetToIgnore ComponentHandle


--- @class EsvOsirisMoveToObjectTask : EsvMoveTask
--- @field DefaultSpeed float
--- @field IncreaseSpeed bool
--- @field MaxDistance float
--- @field MinDistance float
--- @field SpeedMultiplier float
--- @field Target ComponentHandle


--- @class EsvOsirisPickupItemTask : EsvTask
--- @field ArriveEvent STDString
--- @field BehaviorTransactionId uint32
--- @field Item ComponentHandle


--- @class EsvOsirisPlayAnimationTask : EsvTask
--- @field ActionTransactionId uint32
--- @field Animation FixedString
--- @field AnimationDuration float
--- @field AnimationNames FixedString[]
--- @field CurrentTime float
--- @field EndAnimation FixedString
--- @field ExitOnFinish bool
--- @field FinishedEvent STDString
--- @field NoBlend bool
--- @field OriginalAnimation FixedString
--- @field Time float
--- @field Timer float
--- @field WaitForCompletion bool


--- @class EsvOsirisResurrectTask : EsvTask
--- @field Animation FixedString
--- @field HPPercentage int32
--- @field IsResurrected bool


--- @class EsvOsirisSteerTask : EsvTask
--- @field AngleTolerance float
--- @field LookAt bool
--- @field SnapToTarget bool
--- @field SteeringTransactionId uint32
--- @field Target ComponentHandle
--- @field TargetPos vec3


--- @class EsvOsirisTeleportToLocationTask : EsvTask
--- @field ArriveEvent STDString
--- @field Executed bool
--- @field FindFleePosition bool
--- @field FindPosition bool
--- @field LeaveCombat bool
--- @field Level FixedString
--- @field Position vec3
--- @field PreviousLevel FixedString
--- @field Rotation mat3
--- @field SetRotation bool
--- @field UnchainFollowers bool


--- @class EsvOsirisUseItemTask : EsvTask
--- @field ArriveEvent STDString
--- @field BehaviorTransactionId uint32
--- @field Item ComponentHandle


--- @class EsvOsirisUseSkillTask : EsvTask
--- @field BehaviorTransactionId uint32
--- @field Force bool
--- @field IgnoreChecks bool
--- @field IgnoreHasSkill bool
--- @field Skill FixedString
--- @field Success bool
--- @field Target ComponentHandle
--- @field TargetPos vec3


--- @class EsvOsirisWanderTask : EsvTask
--- @field Anchor ComponentHandle
--- @field Duration float
--- @field Range float
--- @field Running bool
--- @field Start vec3
--- @field Trigger ComponentHandle


--- @class EsvPathAction : EsvGameAction
--- @field Anchor uint64
--- @field Distance float
--- @field Finished bool
--- @field HitCharacters ComponentHandle[]
--- @field HitItems ComponentHandle[]
--- @field HitRadius float
--- @field Interpolation float
--- @field IsFromItem bool
--- @field Owner ComponentHandle
--- @field Position vec3
--- @field PreviousAnchor uint64
--- @field SkillId FixedString
--- @field SkillProperties StatsPropertyList
--- @field Speed float
--- @field SurfaceAction ComponentHandle
--- @field Target vec3
--- @field TurnTimer float
--- @field Waypoints vec3[]


--- @class EsvPendingHit
--- @field AttackerHandle ComponentHandle
--- @field CapturedCharacterHit bool
--- @field CharacterHit StatsHitDamageInfo
--- @field CharacterHitDamageList StatsDamagePairList
--- @field CharacterHitPointer StatsHitDamageInfo
--- @field CriticalRoll StatsCriticalRoll
--- @field ForceReduceDurability bool
--- @field HighGround StatsHighGroundBonus
--- @field HitType StatsHitType
--- @field Id uint32
--- @field NoHitRoll bool
--- @field ProcWindWalker bool
--- @field Status EsvStatusHit
--- @field TargetHandle ComponentHandle
--- @field WeaponStats CDivinityStatsItem


--- @class EsvPlayerCustomData : EocPlayerCustomData


--- @class EsvPlayerData
--- @field CachedTension uint32
--- @field CustomData EsvPlayerCustomData
--- @field HelmetOption bool
--- @field LevelUpMarker bool
--- @field LockedAbility uint32[]
--- @field OriginalTemplate FixedString
--- @field PickpocketTarget ComponentHandle
--- @field PreviousPickpocketTargets table<ComponentHandle, EsvPlayerDataPickpocketData>
--- @field PreviousPositionId uint32
--- @field PreviousPositions vec3[]
--- @field QuestSelected FixedString
--- @field RecruiterHandle ComponentHandle
--- @field Region FixedString
--- @field Renown uint32
--- @field SelectedSkillSetIndex uint8
--- @field ShouldReevaluateSkillBar bool
--- @field SkillBar EocSkillBarItem[]
--- @field SomeObjectHandle ComponentHandle


--- @class EsvPlayerDataPickpocketData
--- @field Value int64
--- @field Weight int64


--- @class EsvPointTriggerBase : Trigger


--- @class EsvPolygonSurfaceAction : EsvCreateSurfaceActionBase
--- @field Characters ComponentHandle[]
--- @field CurrentGrowTimer float
--- @field DamageList StatsDamagePairList
--- @field GrowStep int32
--- @field GrowTimer float
--- @field Items ComponentHandle[]
--- @field LastSurfaceCellCount int32
--- @field PolygonVertices vec2[]
--- @field PositionX float
--- @field PositionZ float
--- @field SurfaceCells EsvSurfaceCell[]


--- @class EsvProjectile : IEoCServerObject
--- @field AlwaysDamage bool
--- @field BoostConditions uint8
--- @field CanDeflect bool
--- @field CasterHandle ComponentHandle
--- @field CleanseStatuses FixedString
--- @field CurrentLevel FixedString
--- @field DamageList StatsDamagePairList
--- @field DamageSourceType CauseType
--- @field DamageType StatsDamageType
--- @field DeathType StatsDeathType
--- @field DivideDamage bool
--- @field EffectHandle ComponentHandle
--- @field ExplodeRadius0 float
--- @field ExplodeRadius1 float
--- @field ForceTarget bool
--- @field HitInterpolation float
--- @field HitObjectHandle ComponentHandle
--- @field IgnoreObjects bool
--- @field IgnoreRoof bool
--- @field IsFromItem bool
--- @field IsTrap bool
--- @field Launched bool
--- @field LifeTime float
--- @field MovingEffectHandle ComponentHandle
--- @field OnHitAction EsvDefaultProjectileHit
--- @field Position vec3
--- @field PrevPosition vec3
--- @field PropertyList StatsPropertyList
--- @field ReduceDurability bool
--- @field RequestDelete bool
--- @field RootTemplate ProjectileTemplate
--- @field SkillId FixedString
--- @field SourceHandle ComponentHandle
--- @field SourcePosition vec3
--- @field SpawnEffect FixedString
--- @field SpawnFXOverridesImpactFX bool
--- @field StatusClearChance float
--- @field TargetObjectHandle ComponentHandle
--- @field TargetPosition vec3
--- @field UseCharacterStats bool
--- @field WeaponHandle ComponentHandle


--- @class EsvProjectileConversionHelpers
--- @field RegisteredProjectiles table<FixedString, EsvProjectile[]>


--- @class EsvProjectileManager
--- @field ActiveProjectiles EsvProjectile[]
--- @field ProjectilesToDestroy EsvProjectile[]


--- @class EsvProjectileTargetDesc
--- @field Target ComponentHandle
--- @field TargetPosition vec3
--- @field TargetPosition2 vec3


--- @class EsvRainAction : EsvGameAction
--- @field AreaRadius float
--- @field ConsequencesStartTime float
--- @field Duration float
--- @field Finished bool
--- @field FirstTick bool
--- @field IsFromItem bool
--- @field LifeTime float
--- @field Owner ComponentHandle
--- @field Position vec3
--- @field SkillId FixedString
--- @field SkillProperties FixedString
--- @field TurnTimer float


--- @class EsvRectangleSurfaceAction : EsvCreateSurfaceActionBase
--- @field AiFlags uint64
--- @field Characters ComponentHandle[]
--- @field CurrentCellCount uint64
--- @field CurrentGrowTimer float
--- @field DamageList StatsDamagePairList
--- @field DeathType StatsDeathType
--- @field GrowStep int32
--- @field GrowTimer float
--- @field Items ComponentHandle[]
--- @field Length float
--- @field LineCheckBlock uint64
--- @field MaxHeight float
--- @field SkillProperties StatsPropertyList
--- @field SurfaceArea float
--- @field SurfaceCells EsvSurfaceCell[]
--- @field Target vec3
--- @field Width float


--- @class EsvRegionTrigger : EsvAreaTriggerBase


--- @class EsvSecretRegionTrigger : EsvAreaTriggerBase
--- @field SecretRegionUnlocked bool


--- @class EsvShootProjectileHelper
--- @field Caster ComponentHandle
--- @field CasterLevel int32
--- @field CleanseStatuses FixedString
--- @field DamageList StatsDamagePairList
--- @field EndPosition vec3
--- @field HitObject EsvHitObject
--- @field IgnoreObjects bool
--- @field IsFromItem bool
--- @field IsStealthed bool
--- @field IsTrap bool
--- @field Random uint8
--- @field SkillId FixedString
--- @field Source ComponentHandle
--- @field StartPosition vec3
--- @field StatusClearChance float
--- @field Target ComponentHandle
--- @field UnknownFlag1 bool


--- @class EsvSkill
--- @field AIParams SkillAIParams
--- @field ActiveCooldown float
--- @field CauseList ComponentHandle[]
--- @field IsActivated bool
--- @field IsLearned bool
--- @field MaxCharges int32
--- @field NetID NetId
--- @field NumCharges int32
--- @field OncePerCombat bool
--- @field OwnerHandle ComponentHandle
--- @field ShouldSyncCooldown bool
--- @field SkillId FixedString
--- @field ZeroMemory bool


--- @class EsvSkillManager
--- @field CurrentSkillState EsvSkillState
--- @field FreeMemorySlots uint32
--- @field IsLoading bool
--- @field OwnerHandle ComponentHandle
--- @field Skills table<FixedString, EsvSkill>
--- @field TimeItemAddedToSkillManager table<FixedString, uint32>


--- @class EsvSkillState
--- @field CanEnter bool
--- @field CharacterHandle ComponentHandle
--- @field CharacterHasSkill bool
--- @field CleanseStatuses FixedString
--- @field IgnoreChecks bool
--- @field IsFinished bool
--- @field IsStealthed bool
--- @field PrepareTimerRemaining float
--- @field ShouldExit bool
--- @field SkillId FixedString
--- @field SourceItemHandle ComponentHandle
--- @field StatusClearChance float


--- @class EsvSkillStatusAura : EsvAura
--- @field AreaRadius float
--- @field Position vec3


--- @class EsvSoundVolumeTrigger : SoundVolumeTrigger


--- @class EsvStartTrigger : EsvPointTriggerBase
--- @field Angle float
--- @field Player uint8
--- @field Team uint8


--- @class EsvStatsAreaTrigger : EsvAreaTriggerBase
--- @field LevelOverride int32
--- @field ParentGuid Guid
--- @field TreasureLevelOverride int32


--- @class EsvStatus
--- @field BringIntoCombat bool
--- @field CanEnterChance int32
--- @field Channeled bool
--- @field CleansedByHandle ComponentHandle
--- @field CurrentLifeTime float
--- @field DamageSourceType CauseType
--- @field Flags0 EsvStatusFlags0
--- @field Flags1 EsvStatusFlags1
--- @field Flags2 EsvStatusFlags2
--- @field ForceFailStatus bool
--- @field ForceStatus bool
--- @field Influence bool
--- @field InitiateCombat bool
--- @field IsFromItem bool
--- @field IsHostileAct bool
--- @field IsInvulnerable bool
--- @field IsLifeTimeSet bool
--- @field IsOnSourceSurface bool
--- @field IsResistingDeath bool
--- @field KeepAlive bool
--- @field LifeTime float
--- @field NetID NetId
--- @field OwnerHandle ComponentHandle
--- @field RequestClientSync bool
--- @field RequestClientSync2 bool
--- @field RequestDelete bool
--- @field RequestDeleteAtTurnEnd bool
--- @field StartTimer float
--- @field Started bool
--- @field StatsMultiplier float
--- @field StatusHandle ComponentHandle
--- @field StatusId FixedString
--- @field StatusOwner ComponentHandle[]
--- @field StatusSourceHandle ComponentHandle
--- @field StatusType FixedString
--- @field Strength float
--- @field TargetHandle ComponentHandle
--- @field TurnTimer float


--- @class EsvStatusActiveDefense : EsvStatusConsumeBase
--- @field Charges int32
--- @field PreviousTargets ComponentHandle[]
--- @field Projectile FixedString
--- @field Radius float
--- @field StatusTargetHandle ComponentHandle
--- @field TargetPos vec3


--- @class EsvStatusAdrenaline : EsvStatusConsumeBase
--- @field CombatTurn int32
--- @field InitialAPMod int32
--- @field SecondaryAPMod int32


--- @class EsvStatusAoO : EsvStatus
--- @field ActivateAoOBoost bool
--- @field AoOTargetHandle ComponentHandle
--- @field PartnerHandle ComponentHandle
--- @field ShowOverhead bool
--- @field SourceHandle ComponentHandle


--- @class EsvStatusBoost : EsvStatus
--- @field BoostId FixedString
--- @field EffectTime float


--- @class EsvStatusChallenge : EsvStatusConsumeBase
--- @field SourceHandle ComponentHandle
--- @field Target bool


--- @class EsvStatusCharmed : EsvStatusConsumeBase
--- @field OriginalOwnerCharacterHandle ComponentHandle
--- @field UserId uint32


--- @class EsvStatusClimbing : EsvStatus
--- @field Direction bool
--- @field JumpUpLadders bool
--- @field LadderHandle ComponentHandle
--- @field Level FixedString
--- @field MoveDirection vec3
--- @field Status int32


--- @class EsvStatusCombat : EsvStatus
--- @field OwnerTeamId EocCombatTeamId
--- @field ReadyForCombat bool


--- @class EsvStatusConsume : EsvStatusConsumeBase


--- @class EsvStatusConsumeBase : EsvStatus
--- @field ApplyStatusOnTick FixedString
--- @field EffectTime float
--- @field HealEffectOverride HealEffect
--- @field ItemHandles ComponentHandle[]
--- @field Items FixedString[]
--- @field LoseControl bool
--- @field OriginalWeaponStatsId FixedString
--- @field OverrideWeaponHandle ComponentHandle
--- @field OverrideWeaponStatsId FixedString
--- @field Poisoned bool
--- @field ResetAllCooldowns bool
--- @field ResetCooldownsAbilities uint32[]
--- @field ResetOncePerCombat bool
--- @field SavingThrow int32
--- @field ScaleWithVitality bool
--- @field Skill FixedString[]
--- @field SourceDirection vec3
--- @field StackId FixedString
--- @field StatsId FixedString
--- @field StatsIds EsvStatusConsumeBaseStatsData[]
--- @field SurfaceChanges SurfaceTransformActionType[]
--- @field Turn int32


--- @class EsvStatusConsumeBaseStatsData
--- @field StatsId FixedString
--- @field Turn int32


--- @class EsvStatusController : EsvBaseController
--- @field ActionTransactionId int32
--- @field CombatStartPosition vec3
--- @field CombatStartPositionFloodDone bool
--- @field DeathAnimationTransactionId int32
--- @field Flags EsvStatusControllerFlags
--- @field Flags2 uint32
--- @field KnockDownQueued bool
--- @field PolymorphingTransactionId int32
--- @field ResurrectedEvent FixedString
--- @field SteerToEnemyTransactionId int32
--- @field SummoningTransactionId int32
--- @field TeleportFallingTransactionId int32


--- @class EsvStatusDamage : EsvStatusConsumeBase
--- @field DamageEvent int32
--- @field DamageLevel int32
--- @field DamageStats FixedString
--- @field HitTimer float
--- @field SpawnBlood bool
--- @field TimeElapsed float


--- @class EsvStatusDamageOnMove : EsvStatusDamage
--- @field DistancePerDamage float
--- @field DistanceTraveled float


--- @class EsvStatusDomeAction : EsvGameAction
--- @field Finished bool
--- @field LifeTime float
--- @field Owner ComponentHandle
--- @field Position vec3
--- @field SkillId FixedString


--- @class EsvStatusDrain : EsvStatus
--- @field Infused int32


--- @class EsvStatusDying : EsvStatus
--- @field AttackDirection int32
--- @field CombatId uint8
--- @field DeathType StatsDeathType
--- @field DieActionsCompleted bool
--- @field DisputeTargetHandle ComponentHandle
--- @field DontThrowDeathEvent bool
--- @field ForceNoGhost bool
--- @field IgnoreGodMode bool
--- @field ImpactDirection vec3
--- @field InflicterHandle ComponentHandle
--- @field IsAlreadyDead bool
--- @field SkipAnimation bool
--- @field SourceHandle ComponentHandle
--- @field SourceType int32


--- @class EsvStatusExplode : EsvStatus
--- @field Projectile FixedString


--- @class EsvStatusHeal : EsvStatus
--- @field AbsorbSurfaceRange int32
--- @field AbsorbSurfaceTypes SurfaceType[]
--- @field EffectTime float
--- @field HealAmount int32
--- @field HealEffect HealEffect
--- @field HealEffectId FixedString
--- @field HealType StatusHealType
--- @field TargetDependentHeal bool
--- @field TargetDependentHealAmount int32[]
--- @field TargetDependentValue int32[]


--- @class EsvStatusHealSharing : EsvStatusConsumeBase
--- @field CasterHandle ComponentHandle


--- @class EsvStatusHealSharingCaster : EsvStatusConsumeBase
--- @field BeamEffects table<ComponentHandle, ComponentHandle>
--- @field StatusTargets ComponentHandle[]


--- @class EsvStatusHealing : EsvStatusConsumeBase
--- @field AbsorbSurfaceRange int32
--- @field HealAmount int32
--- @field HealEffect HealEffect
--- @field HealEffectId FixedString
--- @field HealStat StatusHealType
--- @field HealingEvent int32
--- @field SkipInitialEffect bool
--- @field TimeElapsed float


--- @class EsvStatusHit : EsvStatus
--- @field AllowInterruptAction bool
--- @field DecDelayDeathCount bool
--- @field ForceInterrupt bool
--- @field Hit StatsHitDamageInfo
--- @field HitByHandle ComponentHandle
--- @field HitReason uint32
--- @field HitWithHandle ComponentHandle
--- @field ImpactDirection vec3
--- @field ImpactOrigin vec3
--- @field ImpactPosition vec3
--- @field Interruption bool
--- @field PropertyList StatsPropertyList
--- @field SkillId FixedString
--- @field WeaponHandle ComponentHandle


--- @class EsvStatusIdentify : EsvStatus
--- @field Identified int32
--- @field IdentifierHandle ComponentHandle
--- @field Level int32


--- @class EsvStatusInSurface : EsvStatus
--- @field Force bool
--- @field Layers ESurfaceFlag
--- @field SurfaceDistanceCheck float
--- @field SurfaceTimerCheck float
--- @field Translate vec3


--- @class EsvStatusIncapacitated : EsvStatusConsumeBase
--- @field CurrentFreezeTime float
--- @field FreezeTime float
--- @field FrozenFlag uint8


--- @class EsvStatusInfectiousDiseased : EsvStatusConsumeBase
--- @field InfectTimer float
--- @field Infections int32
--- @field Radius float
--- @field StatusTargetHandle ComponentHandle


--- @class EsvStatusInvisible : EsvStatusConsumeBase
--- @field InvisiblePosition vec3


--- @class EsvStatusKnockedDown : EsvStatus
--- @field IsInstant bool
--- @field KnockedDownState int32


--- @class EsvStatusLying : EsvStatus
--- @field Heal float
--- @field Index int32
--- @field ItemHandle ComponentHandle
--- @field Position vec3
--- @field TimeElapsed float


--- @class EsvStatusMachine
--- @field IsStatusMachineActive bool
--- @field OwnerObjectHandle ComponentHandle
--- @field PreventStatusApply bool
--- @field Statuses EsvStatus[]


--- @class EsvStatusMaterial : EsvStatus
--- @field ApplyFlags StatusMaterialApplyFlags
--- @field ApplyNormalMap bool
--- @field Fading bool
--- @field Force bool
--- @field IsOverlayMaterial bool
--- @field MaterialUUID FixedString


--- @class EsvStatusPolymorphed : EsvStatusConsumeBase
--- @field DisableInteractions bool
--- @field OriginalTemplate FixedString
--- @field OriginalTemplateType int32
--- @field PolymorphResult FixedString
--- @field TransformedRace FixedString


--- @class EsvStatusRepair : EsvStatus
--- @field Level int32
--- @field Repaired int32
--- @field RepairerHandle ComponentHandle


--- @class EsvStatusRotate : EsvStatus
--- @field RotationSpeed float
--- @field Yaw float


--- @class EsvStatusShacklesOfPain : EsvStatusConsumeBase
--- @field CasterHandle ComponentHandle


--- @class EsvStatusShacklesOfPainCaster : EsvStatusConsumeBase
--- @field VictimHandle ComponentHandle


--- @class EsvStatusSneaking : EsvStatus
--- @field ClientRequestStop bool


--- @class EsvStatusSpark : EsvStatusConsumeBase
--- @field Charges int32
--- @field Projectile FixedString
--- @field Radius float


--- @class EsvStatusSpirit : EsvStatus
--- @field Characters ComponentHandle[]


--- @class EsvStatusSpiritVision : EsvStatusConsumeBase
--- @field SpiritVisionSkillId FixedString


--- @class EsvStatusStance : EsvStatusConsumeBase
--- @field SkillId FixedString


--- @class EsvStatusSummoning : EsvStatus
--- @field AnimationDuration float
--- @field SummonLevel int32


--- @class EsvStatusTeleportFall : EsvStatus
--- @field HasDamage bool
--- @field HasDamageBeenApplied bool
--- @field ReappearTime float
--- @field SkillId FixedString
--- @field Target vec3


--- @class EsvStatusThrown : EsvStatus
--- @field AnimationDuration float
--- @field CasterHandle ComponentHandle
--- @field IsThrowingSelf bool
--- @field Landed bool
--- @field LandingEstimate float
--- @field Level int32


--- @class EsvStatusUnlock : EsvStatus
--- @field Key FixedString
--- @field Level int32
--- @field SourceHandle ComponentHandle
--- @field Unlocked int32


--- @class EsvStatusUnsheathed : EsvStatus
--- @field Force bool


--- @class EsvStormAction : EsvGameAction
--- @field Finished bool
--- @field IsFromItem bool
--- @field LifeTime float
--- @field Owner ComponentHandle
--- @field Position vec3
--- @field ProjectileSkills FixedString[]
--- @field ProjectileTargets EsvProjectileTargetDesc[]
--- @field SkillId FixedString
--- @field StrikeTimer float
--- @field Strikes EsvStormActionStrike[]
--- @field TurnTimer float


--- @class EsvStormActionStrike
--- @field Object ComponentHandle
--- @field SkillId FixedString
--- @field Source vec3
--- @field Target vec3


--- @class EsvSurface
--- @field Flags uint8
--- @field Index uint16
--- @field LifeTime float
--- @field LifeTimeFromTemplate bool
--- @field MyHandle ComponentHandle
--- @field NeedsSplitEvaluation bool
--- @field NetID NetId
--- @field OwnerHandle ComponentHandle
--- @field OwnershipTimer float
--- @field RootTemplate SurfaceTemplate
--- @field StatusChance float
--- @field SurfaceType SurfaceType
--- @field TeamId EocCombatTeamId


--- @class EsvSurfaceAction
--- @field MyHandle ComponentHandle


--- @class EsvSurfaceCell
--- @field Position i16vec2


--- @class EsvSurfaceManager
--- @field SurfaceActions EsvSurfaceAction[]
--- @field SurfaceCellSetsByLayer EsvSurfaceCell[][]
--- @field SurfaceCells EsvSurfaceCell[]
--- @field Surfaces EsvSurface[]


--- @class EsvSwapSurfaceAction : EsvCreateSurfaceActionBase
--- @field CheckExistingSurfaces bool
--- @field CurrentCellCount int32
--- @field ExcludeRadius float
--- @field GrowStep int32
--- @field GrowTimer float
--- @field IgnoreIrreplacableSurfaces bool
--- @field LineCheckBlock uint64
--- @field MaxHeight float
--- @field Radius float
--- @field SurfaceCellMap table<SurfaceType, EsvSurfaceCell[]>
--- @field SurfaceCells EsvSurfaceCell[]
--- @field SurfaceCollisionFlags uint64
--- @field SurfaceCollisionNotOnFlags uint64
--- @field Target vec3
--- @field TargetCellMap table<SurfaceType, EsvSurfaceCell[]>
--- @field TargetCells EsvSurfaceCell[]
--- @field Timer float


--- @class EsvTask
--- @field Character ComponentHandle
--- @field Failed bool
--- @field Flags uint32
--- @field TaskState uint32
--- @field TaskTypeId EsvTaskType


--- @class EsvTaskController : EsvBaseController
--- @field FlushRequested bool
--- @field RemoveNextTask_M bool
--- @field Tasks EsvTask[]
--- @field UpdateInProgress bool


--- @class EsvTeleportTrigger : EsvPointTriggerBase
--- @field Angle float
--- @field Zoom bool


--- @class EsvTornadoAction : EsvGameAction
--- @field AnchorList vec3[]
--- @field CleanseStatuses FixedString
--- @field Finished bool
--- @field HitCharacterHandles ComponentHandle[]
--- @field HitItemHandles ComponentHandle[]
--- @field HitRadius float
--- @field Interpolation float
--- @field IsFromItem bool
--- @field Owner ComponentHandle
--- @field Position vec3
--- @field SkillId FixedString
--- @field SkillProperties StatsPropertyList
--- @field StatusClearChance float
--- @field SurfaceActionHandle ComponentHandle
--- @field Target vec3
--- @field TurnTimer float


--- @class EsvTransformSurfaceAction : EsvSurfaceAction
--- @field Finished bool
--- @field GrowCellPerSecond float
--- @field OriginSurface SurfaceType
--- @field OwnerHandle ComponentHandle
--- @field Position vec3
--- @field SurfaceCellMap table<SurfaceType, EsvSurfaceCell[]>
--- @field SurfaceLayer SurfaceLayer
--- @field SurfaceLifetime float
--- @field SurfaceMap table<SurfaceType, ComponentHandle>
--- @field SurfaceRemoveCloudCellMap EsvSurfaceCell[]
--- @field SurfaceRemoveGroundCellMap EsvSurfaceCell[]
--- @field SurfaceStatusChance float
--- @field SurfaceTransformAction SurfaceTransformActionType
--- @field Timer float


--- @class EsvTriggerConversionHelpers
--- @field RegisteredTriggers table<FixedString, Trigger[]>


--- @class EsvTurnManager
--- @field AttachedCombatComponents ComponentHandleWithType[]
--- @field CombatEntities EntityHandle[]
--- @field CombatEntities2 EntityHandle[]
--- @field CombatGroups table<FixedString, EsvTurnManagerCombatGroup>
--- @field CombatParticipants EsvCharacter[]
--- @field Combats table<uint8, EsvTurnManagerCombat>
--- @field EntitiesLeftCombat ComponentHandle[]
--- @field EntityWrappers EsvTurnManagerEntityWrapper[]
--- @field FreeCombatIds uint8[]
--- @field NextCombatId uint8
--- @field TeamMode int32
--- @field TimeoutOverrides table<uint8, EsvTurnManagerTimeoutOverride>


--- @class EsvTurnManagerCombat
--- @field CombatGroups EsvTurnManagerCombatGroup[]
--- @field CombatRound uint8
--- @field CombatStartEventSent bool
--- @field CurrentRoundTeams EsvTurnManagerCombatTeam[]
--- @field CurrentTurnChangeNotificationTeamIds EocCombatTeamId[]
--- @field HasParticipantSurfaces bool
--- @field HasParticipantSurfacesNumTicks uint8
--- @field InitialEnemyHandle ComponentHandle
--- @field InitialPlayerHandle ComponentHandle
--- @field IsActive bool
--- @field IsFightBetweenPlayers bool
--- @field LevelName FixedString
--- @field NewRound uint8
--- @field NextRoundTeams EsvTurnManagerCombatTeam[]
--- @field NextTeamId uint32
--- @field NextTurnChangeNotificationTeamIds EocCombatTeamId[]
--- @field Teams table<uint32, EsvTurnManagerCombatTeam>
--- @field TimeLeft_M float
--- @field TimeSpentInTurn float
--- @field TimeSpentTryingToEndTurn float
--- @field TurnTimer_M float
--- @field WaitingForCharComponents ComponentHandle[]
--- @field GetAllTeams fun(self: EsvTurnManagerCombat):table<uint32, EsvTurnManagerCombatTeam>
--- @field GetCurrentTurnOrder fun(self: EsvTurnManagerCombat):EsvTurnManagerCombatTeam[]
--- @field GetNextTurnOrder fun(self: EsvTurnManagerCombat):EsvTurnManagerCombatTeam[]
--- @field UpdateCurrentTurnOrder fun(self: EsvTurnManagerCombat)
--- @field UpdateNextTurnOrder fun(self: EsvTurnManagerCombat)


--- @class EsvTurnManagerCombatGroup
--- @field CombatTeamsOrdered EocCombatTeamId[]
--- @field Initiative uint16
--- @field LastAddedTeamIndex uint64
--- @field Party uint8


--- @class EsvTurnManagerCombatTeam
--- @field AddedNextTurnNotification bool
--- @field Character EsvCharacter
--- @field CombatGroup EsvTurnManagerCombatGroup
--- @field CombatId uint8
--- @field CombatTeamRound uint16
--- @field ComponentHandle ComponentHandleWithType
--- @field EntityWrapper EsvTurnManagerEntityWrapper
--- @field Id EocCombatTeamId
--- @field Initiative uint16
--- @field Item EsvItem
--- @field StillInCombat bool
--- @field TeamId uint32


--- @class EsvTurnManagerEntityWrapper
--- @field Character EsvCharacter
--- @field CombatComponentPtr EocCombatComponent
--- @field Handle EntityHandle
--- @field Item EsvItem


--- @class EsvTurnManagerTimeoutOverride
--- @field Handle ComponentHandleWithType
--- @field Timeout float


--- @class EsvWallAction : EsvGameAction
--- @field Finished bool
--- @field GrowTimePerWall float
--- @field GrowTimeout float
--- @field IsFromItem bool
--- @field LifeTime float
--- @field NumWallsGrown uint64
--- @field Owner ComponentHandle
--- @field SkillId FixedString
--- @field Source vec3
--- @field State int32
--- @field Target vec3
--- @field TimeSinceLastWall float
--- @field TurnTimer float
--- @field Walls ComponentHandle[]


--- @class EsvZoneAction : EsvCreateSurfaceActionBase
--- @field AiFlags uint64
--- @field AngleOrBase float
--- @field BackStart float
--- @field Characters ComponentHandle[]
--- @field CurrentCellCount uint64
--- @field DamageList StatsDamagePairList
--- @field DeathType StatsDeathType
--- @field FrontOffset float
--- @field GrowStep uint32
--- @field GrowTimer float
--- @field GrowTimerStart float
--- @field IsFromItem bool
--- @field Items ComponentHandle[]
--- @field MaxHeight float
--- @field Radius float
--- @field Shape int32
--- @field SkillId FixedString
--- @field SkillProperties StatsPropertyList
--- @field SurfaceCells EsvSurfaceCell[]
--- @field Target vec3


--- @class EsvLuaAfterCraftingExecuteCombinationEvent : LuaEventBase
--- @field Character EsvCharacter
--- @field CombinationId FixedString
--- @field CraftingStation CraftingStationType
--- @field Items EsvItem[]
--- @field Quantity uint8
--- @field Succeeded bool


--- @class EsvLuaAiRequestSortEvent : LuaEventBase
--- @field CharacterHandle ComponentHandle
--- @field Request EsvAiRequest


--- @class EsvLuaBeforeCharacterApplyDamageEvent : LuaEventBase
--- @field Attacker StatsObjectInstance
--- @field Cause CauseType
--- @field Context EsvPendingHit
--- @field Handled bool
--- @field Hit StatsHitDamageInfo
--- @field ImpactDirection vec3
--- @field Target EsvCharacter


--- @class EsvLuaBeforeCraftingExecuteCombinationEvent : LuaEventBase
--- @field Character EsvCharacter
--- @field CombinationId FixedString
--- @field CraftingStation CraftingStationType
--- @field Items EsvItem[]
--- @field Processed bool
--- @field Quantity uint8


--- @class EsvLuaBeforeShootProjectileEvent : LuaEventBase
--- @field Projectile EsvShootProjectileHelper


--- @class EsvLuaBeforeStatusApplyEvent : LuaEventBase
--- @field Owner IGameObject
--- @field PreventStatusApply bool
--- @field Status EsvStatus


--- @class EsvLuaCalculateTurnOrderEvent : LuaEventBase
--- @field Combat EsvTurnManagerCombat


--- @class EsvLuaComputeCharacterHitEvent : LuaEventBase
--- @field AlwaysBackstab bool
--- @field Attacker CDivinityStatsCharacter
--- @field CriticalRoll StatsCriticalRoll
--- @field DamageList StatsDamagePairList
--- @field ForceReduceDurability bool
--- @field Handled bool
--- @field HighGround StatsHighGroundBonus
--- @field Hit StatsHitDamageInfo
--- @field HitType StatsHitType
--- @field NoHitRoll bool
--- @field SkillProperties StatsPropertyList
--- @field Target CDivinityStatsCharacter
--- @field Weapon CDivinityStatsItem


--- @class EsvLuaGameStateChangedEvent : LuaEventBase
--- @field FromState EsvGameState
--- @field ToState EsvGameState


--- @class EsvLuaGroundHitEvent : LuaEventBase
--- @field Caster IGameObject
--- @field DamageList StatsDamagePairList
--- @field Position vec3


--- @class EsvLuaOnExecutePropertyDataOnPositionEvent : LuaEventBase
--- @field AreaRadius float
--- @field Attacker IGameObject
--- @field Hit StatsHitDamageInfo
--- @field IsFromItem bool
--- @field Position vec3
--- @field Property StatsPropertyExtender
--- @field Skill StatsSkillPrototype


--- @class EsvLuaOnExecutePropertyDataOnTargetEvent : LuaEventBase
--- @field Attacker IGameObject
--- @field Hit StatsHitDamageInfo
--- @field ImpactOrigin vec3
--- @field IsFromItem bool
--- @field Property StatsPropertyExtender
--- @field Skill StatsSkillPrototype
--- @field Target IGameObject


--- @class EsvLuaOnPeekAiActionEvent : LuaEventBase
--- @field ActionType AiActionType
--- @field CharacterHandle ComponentHandle
--- @field IsFinished bool
--- @field Request EsvAiRequest


--- @class EsvLuaProjectileHitEvent : LuaEventBase
--- @field HitObject IGameObject
--- @field Position vec3
--- @field Projectile EsvProjectile


--- @class EsvLuaShootProjectileEvent : LuaEventBase
--- @field Projectile EsvProjectile


--- @class EsvLuaStatusDeleteEvent : LuaEventBase
--- @field Status EsvStatus


--- @class EsvLuaStatusGetEnterChanceEvent : LuaEventBase
--- @field EnterChance int32|nil
--- @field IsEnterCheck bool
--- @field Status EsvStatus


--- @class EsvLuaStatusHitEnterEvent : LuaEventBase
--- @field Context EsvPendingHit
--- @field Hit EsvStatusHit


--- @class EsvLuaTreasureItemGeneratedEvent : LuaEventBase
--- @field Item EsvItem
--- @field ResultingItem EsvItem


--- @class LuaDoConsoleCommandEvent : LuaEventBase
--- @field Command STDString


--- @class LuaEmptyEvent : LuaEventBase


--- @class LuaEventBase
--- @field ActionPrevented bool
--- @field CanPreventAction bool
--- @field Name FixedString
--- @field Stopped bool
--- @field PreventAction fun(self: LuaEventBase)
--- @field StopPropagation fun(self: LuaEventBase)


--- @class LuaGetHitChanceEvent : LuaEventBase
--- @field Attacker CDivinityStatsCharacter
--- @field HitChance int32|nil
--- @field Target CDivinityStatsCharacter


--- @class LuaGetSkillAPCostEvent : LuaEventBase
--- @field AP int32|nil
--- @field AiGrid EocAiGrid
--- @field Character CDivinityStatsCharacter
--- @field ElementalAffinity bool|nil
--- @field Position vec3
--- @field Radius float
--- @field Skill StatsSkillPrototype


--- @class LuaGetSkillDamageEvent : LuaEventBase
--- @field Attacker StatsObjectInstance
--- @field AttackerPosition vec3
--- @field DamageList StatsDamagePairList
--- @field DeathType StatsDeathType|nil
--- @field IsFromItem bool
--- @field Level int32
--- @field NoRandomization bool
--- @field Skill StatsSkillPrototype
--- @field Stealthed bool
--- @field TargetPosition vec3


--- @class LuaNetMessageEvent : LuaEventBase
--- @field Channel STDString
--- @field Payload STDString
--- @field UserID UserId


--- @class LuaTickEvent : LuaEventBase
--- @field Time GameTime


--- @class StatsCharacterDynamicStat
--- @field APCostBoost int32
--- @field APMaximum int32
--- @field APRecovery int32
--- @field APStart int32
--- @field Accuracy int32
--- @field AcidImmunity bool
--- @field AirResistance int32
--- @field AirSpecialist int32
--- @field Armor int32
--- @field ArmorBoost int32
--- @field ArmorBoostGrowthPerLevel int32
--- @field Arrow bool
--- @field Barter int32
--- @field BleedingImmunity bool
--- @field BlessedImmunity bool
--- @field BlindImmunity bool
--- @field Bodybuilding int32
--- @field BonusWeapon FixedString
--- @field BonusWeaponDamageMultiplier int32
--- @field Brewmaster int32
--- @field BurnContact bool
--- @field BurnImmunity bool
--- @field ChanceToHitBoost int32
--- @field Charm int32
--- @field CharmImmunity bool
--- @field ChickenImmunity bool
--- @field ChillContact bool
--- @field ChilledImmunity bool
--- @field ClairvoyantImmunity bool
--- @field Constitution int32
--- @field CorrosiveResistance int32
--- @field Crafting int32
--- @field CrippledImmunity bool
--- @field CriticalChance int32
--- @field CursedImmunity bool
--- @field CustomResistance int32
--- @field DamageBoost int32
--- @field DamageBoostGrowthPerLevel int32
--- @field DecayingImmunity bool
--- @field DeflectProjectiles bool
--- @field DisarmedImmunity bool
--- @field DiseasedImmunity bool
--- @field Dodge int32
--- @field DrunkImmunity bool
--- @field DualWielding int32
--- @field EarthResistance int32
--- @field EarthSpecialist int32
--- @field EnragedImmunity bool
--- @field EntangledContact bool
--- @field FOV int32
--- @field FearImmunity bool
--- @field Finesse int32
--- @field FireResistance int32
--- @field FireSpecialist int32
--- @field Floating bool
--- @field FreezeContact bool
--- @field FreezeImmunity bool
--- @field Gain int32
--- @field Grounded bool
--- @field HastedImmunity bool
--- @field Hearing int32
--- @field IgnoreClouds bool
--- @field IgnoreCursedOil bool
--- @field InfectiousDiseasedImmunity bool
--- @field Initiative int32
--- @field Intelligence int32
--- @field Intimidate int32
--- @field InvisibilityImmunity bool
--- @field KnockdownImmunity bool
--- @field Leadership int32
--- @field Level int32
--- @field LifeSteal int32
--- @field LootableWhenEquipped bool
--- @field Loremaster int32
--- @field LoseDurabilityOnCharacterHit bool
--- @field Luck int32
--- @field MadnessImmunity bool
--- @field MagicArmor int32
--- @field MagicArmorBoost int32
--- @field MagicArmorBoostGrowthPerLevel int32
--- @field MagicArmorMastery int32
--- @field MagicPoints int32
--- @field MagicResistance int32
--- @field MagicalSulfur bool
--- @field MaxResistance int32
--- @field MaxSummons int32
--- @field Memory int32
--- @field Movement int32
--- @field MovementSpeedBoost int32
--- @field MuteImmunity bool
--- @field Necromancy int32
--- @field PainReflection int32
--- @field Perseverance int32
--- @field Persuasion int32
--- @field PetrifiedImmunity bool
--- @field PhysicalArmorMastery int32
--- @field PhysicalResistance int32
--- @field Pickpocket int32
--- @field PickpocketableWhenEquipped bool
--- @field PiercingResistance int32
--- @field PoisonContact bool
--- @field PoisonImmunity bool
--- @field PoisonResistance int32
--- @field Polymorph int32
--- @field ProtectFromSummon bool
--- @field RangeBoost int32
--- @field Ranged int32
--- @field RangerLore int32
--- @field Reason int32
--- @field Reflexes int32
--- @field RegeneratingImmunity bool
--- @field Repair int32
--- @field RogueLore int32
--- @field Runecrafting int32
--- @field SPCostBoost int32
--- @field Sentinel int32
--- @field ShacklesOfPainImmunity bool
--- @field ShadowResistance int32
--- @field Shield int32
--- @field ShockedImmunity bool
--- @field Sight int32
--- @field SingleHanded int32
--- @field SleepingImmunity bool
--- @field SlippingImmunity bool
--- @field SlowedImmunity bool
--- @field Sneaking int32
--- @field Sourcery int32
--- @field StepsType uint32
--- @field Strength int32
--- @field StunContact bool
--- @field StunImmunity bool
--- @field SuffocatingImmunity bool
--- @field Sulfurology int32
--- @field SummonLifelinkModifier int32
--- @field Summoning int32
--- @field TALENT_ActionPoints bool
--- @field TALENT_ActionPoints2 bool
--- @field TALENT_AirSpells bool
--- @field TALENT_Ambidextrous bool
--- @field TALENT_AnimalEmpathy bool
--- @field TALENT_AttackOfOpportunity bool
--- @field TALENT_AvoidDetection bool
--- @field TALENT_Awareness bool
--- @field TALENT_Backstab bool
--- @field TALENT_BeastMaster bool
--- @field TALENT_Bully bool
--- @field TALENT_Carry bool
--- @field TALENT_ChanceToHitMelee bool
--- @field TALENT_ChanceToHitRanged bool
--- @field TALENT_Charm bool
--- @field TALENT_Courageous bool
--- @field TALENT_Criticals bool
--- @field TALENT_Damage bool
--- @field TALENT_DeathfogResistant bool
--- @field TALENT_Demon bool
--- @field TALENT_DualWieldingDodging bool
--- @field TALENT_Durability bool
--- @field TALENT_Dwarf_Sneaking bool
--- @field TALENT_Dwarf_Sturdy bool
--- @field TALENT_EarthSpells bool
--- @field TALENT_ElementalAffinity bool
--- @field TALENT_ElementalRanger bool
--- @field TALENT_Elementalist bool
--- @field TALENT_Elf_CorpseEating bool
--- @field TALENT_Elf_Lore bool
--- @field TALENT_Escapist bool
--- @field TALENT_Executioner bool
--- @field TALENT_ExpGain bool
--- @field TALENT_ExtraSkillPoints bool
--- @field TALENT_ExtraStatPoints bool
--- @field TALENT_FaroutDude bool
--- @field TALENT_FireSpells bool
--- @field TALENT_FiveStarRestaurant bool
--- @field TALENT_Flanking bool
--- @field TALENT_FolkDancer bool
--- @field TALENT_Gladiator bool
--- @field TALENT_GoldenMage bool
--- @field TALENT_GreedyVessel bool
--- @field TALENT_Haymaker bool
--- @field TALENT_Human_Civil bool
--- @field TALENT_Human_Inventive bool
--- @field TALENT_IceKing bool
--- @field TALENT_IncreasedArmor bool
--- @field TALENT_Indomitable bool
--- @field TALENT_Initiative bool
--- @field TALENT_Intimidate bool
--- @field TALENT_InventoryAccess bool
--- @field TALENT_ItemCreation bool
--- @field TALENT_ItemMovement bool
--- @field TALENT_Jitterbug bool
--- @field TALENT_Kickstarter bool
--- @field TALENT_Leech bool
--- @field TALENT_LightStep bool
--- @field TALENT_LightningRod bool
--- @field TALENT_LivingArmor bool
--- @field TALENT_Lizard_Persuasion bool
--- @field TALENT_Lizard_Resistance bool
--- @field TALENT_Lockpick bool
--- @field TALENT_LoneWolf bool
--- @field TALENT_Luck bool
--- @field TALENT_MagicCycles bool
--- @field TALENT_MasterThief bool
--- @field TALENT_Max bool
--- @field TALENT_Memory bool
--- @field TALENT_MrKnowItAll bool
--- @field TALENT_NaturalConductor bool
--- @field TALENT_NoAttackOfOpportunity bool
--- @field TALENT_None bool
--- @field TALENT_PainDrinker bool
--- @field TALENT_Perfectionist bool
--- @field TALENT_Politician bool
--- @field TALENT_Quest_GhostTree bool
--- @field TALENT_Quest_Rooted bool
--- @field TALENT_Quest_SpidersKiss_Int bool
--- @field TALENT_Quest_SpidersKiss_Null bool
--- @field TALENT_Quest_SpidersKiss_Per bool
--- @field TALENT_Quest_SpidersKiss_Str bool
--- @field TALENT_Quest_TradeSecrets bool
--- @field TALENT_QuickStep bool
--- @field TALENT_Rager bool
--- @field TALENT_Raistlin bool
--- @field TALENT_RangerLoreArrowRecover bool
--- @field TALENT_RangerLoreEvasionBonus bool
--- @field TALENT_RangerLoreRangedAPBonus bool
--- @field TALENT_Reason bool
--- @field TALENT_Repair bool
--- @field TALENT_ResistDead bool
--- @field TALENT_ResistFear bool
--- @field TALENT_ResistKnockdown bool
--- @field TALENT_ResistPoison bool
--- @field TALENT_ResistSilence bool
--- @field TALENT_ResistStun bool
--- @field TALENT_ResurrectExtraHealth bool
--- @field TALENT_ResurrectToFullHealth bool
--- @field TALENT_RogueLoreDaggerAPBonus bool
--- @field TALENT_RogueLoreDaggerBackStab bool
--- @field TALENT_RogueLoreGrenadePrecision bool
--- @field TALENT_RogueLoreHoldResistance bool
--- @field TALENT_RogueLoreMovementBonus bool
--- @field TALENT_Sadist bool
--- @field TALENT_Scientist bool
--- @field TALENT_Sight bool
--- @field TALENT_Soulcatcher bool
--- @field TALENT_Sourcerer bool
--- @field TALENT_SpillNoBlood bool
--- @field TALENT_StandYourGround bool
--- @field TALENT_Stench bool
--- @field TALENT_SurpriseAttack bool
--- @field TALENT_Throwing bool
--- @field TALENT_Torturer bool
--- @field TALENT_Trade bool
--- @field TALENT_Unstable bool
--- @field TALENT_ViolentMagic bool
--- @field TALENT_Vitality bool
--- @field TALENT_WalkItOff bool
--- @field TALENT_WandCharge bool
--- @field TALENT_WarriorLoreGrenadeRange bool
--- @field TALENT_WarriorLoreNaturalArmor bool
--- @field TALENT_WarriorLoreNaturalHealth bool
--- @field TALENT_WarriorLoreNaturalResistance bool
--- @field TALENT_WaterSpells bool
--- @field TALENT_WeatherProof bool
--- @field TALENT_WhatARush bool
--- @field TALENT_WildMag bool
--- @field TALENT_Zombie bool
--- @field TauntedImmunity bool
--- @field Telekinesis int32
--- @field Thievery int32
--- @field ThrownImmunity bool
--- @field Torch bool
--- @field TranslationKey FixedString
--- @field TwoHanded int32
--- @field Unbreakable bool
--- @field Unrepairable bool
--- @field Unstorable bool
--- @field Vitality int32
--- @field VitalityBoost int32
--- @field VitalityMastery int32
--- @field Wand int32
--- @field WarmImmunity bool
--- @field WarriorLore int32
--- @field WaterResistance int32
--- @field WaterSpecialist int32
--- @field WeakImmunity bool
--- @field WebImmunity bool
--- @field Weight int32
--- @field WetImmunity bool
--- @field Willpower int32
--- @field Wits int32


--- @class StatsDamagePairList
--- @field Add fun(self: StatsDamagePairList, a1: StatsDamageType, a2: int32)
--- @field AggregateSameTypeDamages fun(self: StatsDamagePairList)
--- @field Clear fun(self: StatsDamagePairList, a1: StatsDamageType|nil)
--- @field ConvertDamageType fun(self: StatsDamagePairList, newType: StatsDamageType)
--- @field CopyFrom fun(self: StatsDamagePairList)
--- @field GetByType fun(self: StatsDamagePairList, damageType: StatsDamageType):int32
--- @field Merge fun(self: StatsDamagePairList)
--- @field Multiply fun(self: StatsDamagePairList, multiplier: float)
--- @field ToTable fun(self: StatsDamagePairList)


--- @class StatsHitDamageInfo
--- @field ArmorAbsorption int32
--- @field AttackDirection uint32
--- @field Backstab bool
--- @field Bleeding bool
--- @field Blocked bool
--- @field Burning bool
--- @field CounterAttack bool
--- @field CriticalHit bool
--- @field DamageDealt int32
--- @field DamageList StatsDamagePairList
--- @field DamageType StatsDamageType
--- @field DamagedMagicArmor bool
--- @field DamagedPhysicalArmor bool
--- @field DamagedVitality bool
--- @field DeathType StatsDeathType
--- @field DoT bool
--- @field Dodged bool
--- @field DontCreateBloodSurface bool
--- @field Equipment uint32
--- @field Flanking bool
--- @field FromSetHP bool
--- @field FromShacklesOfPain bool
--- @field Hit bool
--- @field HitWithWeapon bool
--- @field LifeSteal int32
--- @field Missed bool
--- @field NoDamageOnOwner bool
--- @field NoEvents bool
--- @field Poisoned bool
--- @field ProcWindWalker bool
--- @field PropagatedFromOwner bool
--- @field Reflection bool
--- @field Surface bool
--- @field TotalDamageDone int32


--- @class StatsItemColorDefinition
--- @field Color1 uint32
--- @field Color2 uint32
--- @field Color3 uint32


--- @class StatsObject
--- @field AIFlags FixedString
--- @field ComboCategories FixedString[]
--- @field DisplayName TranslatedString
--- @field FS2 FixedString
--- @field Handle int32
--- @field Level int32
--- @field MemorizationRequirements StatsRequirement[]
--- @field ModId FixedString
--- @field ModifierListIndex int32
--- @field Name FixedString
--- @field PropertyLists table<FixedString, StatsPropertyList>
--- @field Requirements StatsRequirement[]
--- @field StatsEntry StatsObject
--- @field StringProperties1 FixedString[]


--- @class StatsObjectInstance : StatsObject
--- @field InstanceId uint32


--- @class StatsPropertyData
--- @field Context StatsPropertyContext
--- @field Name FixedString
--- @field TypeId StatsPropertyType


--- @class StatsPropertyExtender : StatsPropertyData
--- @field Action FixedString
--- @field Arg1 float
--- @field Arg2 float
--- @field Arg3 FixedString
--- @field Arg4 int32
--- @field Arg5 int32
--- @field PropertyName FixedString


--- @class StatsPropertyList
--- @field AllPropertyContexts StatsPropertyContext
--- @field Name FixedString


--- @class StatsPropertyStatus : StatsPropertyData
--- @field Arg4 int32
--- @field Arg5 int32
--- @field Duration float
--- @field StatsId FixedString
--- @field Status FixedString
--- @field StatusChance float
--- @field SurfaceBoost bool
--- @field SurfaceBoosts SurfaceType[]


--- @class StatsReflection
--- @field DamageType StatsDamageType
--- @field MeleeOnly bool


--- @class StatsReflectionSet


--- @class StatsRequirement
--- @field Not bool
--- @field Param int32
--- @field Requirement StatsRequirementType
--- @field Tag FixedString


--- @class StatsSkillPrototype
--- @field Ability int16
--- @field ActionPoints int32
--- @field AiFlags AIFlags
--- @field ChargeDuration float
--- @field ChildPrototypes StatsSkillPrototype[]
--- @field Cooldown float
--- @field CooldownReduction float
--- @field DisplayName STDWString
--- @field Icon FixedString
--- @field Level int32
--- @field MagicCost int32
--- @field MemoryCost int32
--- @field Requirement int32
--- @field RootSkillPrototype StatsSkillPrototype
--- @field SkillId FixedString
--- @field SkillTypeId SkillType
--- @field StatsObject StatsObject
--- @field Tier int32


--- @class StatsStatusPrototype
--- @field AbsorbSurfaceTypes SurfaceType[]
--- @field DisplayName TranslatedString
--- @field HasStats bool
--- @field Icon FixedString
--- @field StatsObject StatsObject
--- @field StatusId StatusType
--- @field StatusName FixedString


--- @class Ext_ClientAudio
local Ext_ClientAudio = {}


--- @param soundObject uint64 
--- @param rtpcName CString 
--- @return float
function Ext_ClientAudio.GetRTPC(soundObject, rtpcName) end

function Ext_ClientAudio.PauseAllSounds() end

--- @param soundObject uint64 
--- @param eventName CString 
--- @param path CString 
--- @param codecId uint32 
--- @return bool
function Ext_ClientAudio.PlayExternalSound(soundObject, eventName, path, codecId) end

--- @param soundObject uint64 
--- @param eventName CString 
--- @param positionSec float|nil 
--- @return bool
function Ext_ClientAudio.PostEvent(soundObject, eventName, positionSec) end

--- @param soundObject uint64 
--- @param rtpcName CString 
--- @return bool
function Ext_ClientAudio.ResetRTPC(soundObject, rtpcName) end

function Ext_ClientAudio.ResumeAllSounds() end

--- @param soundObject uint64 
--- @param rtpcName CString 
--- @param value float 
--- @return bool
function Ext_ClientAudio.SetRTPC(soundObject, rtpcName, value) end

--- @param stateGroup CString 
--- @param state CString 
--- @return bool
function Ext_ClientAudio.SetState(stateGroup, state) end

--- @param soundObject uint64 
--- @param switchGroup CString 
--- @param state CString 
--- @return bool
function Ext_ClientAudio.SetSwitch(soundObject, switchGroup, state) end

--- @param soundObject uint64|nil 
function Ext_ClientAudio.Stop(soundObject) end



--- @class Ext_ClientClient
local Ext_ClientClient = {}


function Ext_ClientClient.GetGameState() end

--- @return ModManager
function Ext_ClientClient.GetModManager() end

--- Updates shroud data for a cell in the specified position.
--- Location: Lua/Libs/Client.inl:20
--- @param x float 
--- @param y float 
--- @param layer ShroudType 
--- @param value int32 
function Ext_ClientClient.UpdateShroud(x, y, layer, value) end



--- @class Ext_ClientEntity
--- @field GetCharacterLegacy fun()
--- @field GetItemLegacy fun()
--- @field GetPlayerManager fun():EclPlayerManager
--- @field GetTurnManager fun():EclTurnManager
local Ext_ClientEntity = {}


--- @return EocAiGrid
function Ext_ClientEntity.GetAiGrid() end

--- @return EclCharacter
function Ext_ClientEntity.GetCharacter() end

--- @return EclLevel
function Ext_ClientEntity.GetCurrentLevel() end

--- @return IEoCClientObject
function Ext_ClientEntity.GetGameObject() end

--- @param handle ComponentHandle 
--- @return EclInventory
function Ext_ClientEntity.GetInventory(handle) end

--- @return EclItem
function Ext_ClientEntity.GetItem() end

--- @return EclStatus
function Ext_ClientEntity.GetStatus() end

--- @return ComponentHandle
function Ext_ClientEntity.NullHandle() end



--- @class Ext_ClientInput
--- @field GetInputManager fun():InputManager
--- @field InjectInput fun(a1: FixedString, a2: InputRawType, a3: InputState, a4: float, a5: float, a6: bool|nil):bool
local Ext_ClientInput = {}




--- @class Ext_ClientNet
local Ext_ClientNet = {}


--- @param channel CString 
--- @param payload CString 
function Ext_ClientNet.PostMessageToServer(channel, payload) end



--- @class Ext_ClientTemplate
local Ext_ClientTemplate = {}


--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ClientTemplate.GetCacheTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ClientTemplate.GetLocalCacheTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ClientTemplate.GetLocalTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ClientTemplate.GetRootTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ClientTemplate.GetTemplate(templateId) end



--- @class Ext_ClientUI
local Ext_ClientUI = {}

--- @alias BuiltinUISWFName "actionProgression" | "addContent" | "addContent_c" | "areaInteract_c" | "arenaResult" | "book" | "bottomBar_c" | "buttonLayout_c" | "calibrationScreen" | "campaignManager" | "characterAssign" | "characterAssign_c" | "characterCreation" | "characterCreation_c" | "characterSheet" | "chatLog" | "combatLog" | "combatLog_c" | "combatTurn" | "connectionMenu" | "connectivity_c" | "containerInventory" | "containerInventoryGM" | "contextMenu" | "contextMenu_c" | "craftPanel_c" | "credits" | "dialog" | "dialog_c" | "dummyOverhead" | "encounterPanel" | "enemyHealthBar" | "engrave" | "equipmentPanel_c" | "examine" | "examine_c" | "feedback_c" | "formation" | "formation_c" | "fullScreenHUD" | "gameMenu" | "gameMenu_c" | "giftBagContent" | "giftBagsMenu" | "gmInventory" | "GMItemSheet" | "GMJournal" | "GMMetadataBox" | "GMMinimap" | "GMMoodPanel" | "GMPanelHUD" | "GMRewardPanel" | "GMSkills" | "hotBar" | "installScreen_c" | "inventorySkillPanel_c" | "itemAction" | "itemGenerator" | "itemSplitter" | "itemSplitter_c" | "journal" | "journal_c" | "journal_csp" | "loadingScreen" | "mainMenu" | "mainMenu_c" | "menuBG" | "minimap" | "minimap_c" | "mods" | "mods_c" | "monstersSelection" | "mouseIcon" | "msgBox" | "msgBox_c" | "notification" | "optionsInput" | "optionsSettings" | "optionsSettings_c" | "overhead" | "overviewMap" | "panelSelect_c" | "partyInventory" | "partyInventory_c" | "partyManagement_c" | "pause" | "peace" | "playerInfo" | "playerInfo_c" | "possessionBar" | "pyramid" | "pyramid_c" | "reputationPanel" | "reward" | "reward_c" | "roll" | "saveLoad" | "saveLoad_c" | "saving" | "serverlist" | "serverlist_c" | "skills" | "skillsSelection" | "sortBy_c" | "startTurnRequest" | "startTurnRequest_c" | "statsPanel_c" | "statusConsole" | "statusPanel" | "stickiesPanel" | "sticky" | "storyElement" | "surfacePainter" | "textDisplay" | "tooltip" | "trade" | "trade_c" | "tutorialBox" | "tutorialBox_c" | "uiCraft" | "uiFade" | "userProfile" | "vignette" | "voiceNotification_c" | "watermark" | "waypoints" | "waypoints_c" | "worldTooltip"

--- @overload fun(string:BuiltinUISWFName):integer
Ext_ClientUI.TypeID = {
	actionProgression = 0,
	addContent = 57,
	addContent_c = 81,
	areaInteract_c = 68,
	arenaResult = 125,
	book = 2,
	bottomBar_c = 59,
	buttonLayout_c = 95,
	calibrationScreen = 98,
	campaignManager = 124,
	characterAssign = 52,
	characterAssign_c = 92,
	characterCreation = 3,
	characterCreation_c = 4,
	characterSheet = 119,
	chatLog = 6,
	combatLog = 7,
	combatLog_c = 65,
	combatTurn = 8,
	connectionMenu = 33,
	connectivity_c = 34,
	containerInventory = { Default = 9, Pickpocket = 37 },
	containerInventoryGM = 143,
	contextMenu = { Default = 10, Object = 11 },
	contextMenu_c = { Default = 12, Object = 96 },
	craftPanel_c = 84,
	credits = 53,
	dialog = 14,
	dialog_c = 66,
	dummyOverhead = 15,
	encounterPanel = 105,
	enemyHealthBar = 42,
	engrave = 69,
	equipmentPanel_c = 64,
	examine = 104,
	examine_c = 67,
	feedback_c = 97,
	formation = 130,
	formation_c = 135,
	fullScreenHUD = 100,
	gameMenu = 19,
	gameMenu_c = 77,
	giftBagContent = 147,
	giftBagsMenu = 146,
	gmInventory = 126,
	GMItemSheet = 107,
	GMJournal = 139,
	GMMetadataBox = 109,
	GMMinimap = 113,
	GMMoodPanel = 108,
	GMPanelHUD = 120,
	GMRewardPanel = 131,
	GMSkills = 123,
	hotBar = 40,
	installScreen_c = 80,
	inventorySkillPanel_c = 62,
	itemAction = 86,
	itemGenerator = 106,
	itemSplitter = 21,
	itemSplitter_c = 85,
	journal = 22,
	journal_c = 70,
	journal_csp = 140,
	loadingScreen = 23,
	mainMenu = 28,
	mainMenu_c = 87, -- Still mainMenu.swf, but this is used for controllers after clicking "Options" in the gameMenu_c
	menuBG = 56,
	minimap = 30,
	minimap_c = 60,
	mods = 49,
	mods_c = 103,
	monstersSelection = 127,
	mouseIcon = 31,
	msgBox = 29,
	msgBox_c = 75,
	notification = 36,
	optionsInput = 13,
	optionsSettings = { Default = 45, Video = 45, Audio = 1, Game = 17 },
	optionsSettings_c = { Default = 91, Video = 91, Audio = 88, Game = 89 },
	overhead = 5,
	overviewMap = 112,
	panelSelect_c = 83,
	partyInventory = 116,
	partyInventory_c = 142,
	partyManagement_c = 82,
	pause = 121,
	peace = 122,
	playerInfo = 38,
	playerInfo_c = 61, --Still playerInfo.swf, but the ID is different.
	possessionBar = 110,
	pyramid = 129,
	pyramid_c = 134,
	reputationPanel = 138,
	reward = 136,
	reward_c = 137,
	roll = 118,
	saveLoad = 39,
	saveLoad_c = 74,
	saving = 99,
	serverlist = 26,
	serverlist_c = 27,
	skills = 41,
	skillsSelection = 54,
	sortBy_c = 79,
	startTurnRequest = 145,
	startTurnRequest_c = 144,
	statsPanel_c = 63,
	statusConsole = 117,
	statusPanel = 128,
	stickiesPanel = 133,
	sticky = 132,
	storyElement = 71,
	surfacePainter = 111,
	textDisplay = 43,
	tooltip = 44,
	trade = 46,
	trade_c = 73,
	tutorialBox = 55,
	tutorialBox_c = 94,
	uiCraft = 102,
	uiFade = 16,
	userProfile = 51,
	vignette = 114,
	voiceNotification_c = 93,
	watermark = 141,
	waypoints = 47,
	waypoints_c = 78,
	worldTooltip = 48,
}


--- Creates a new UI element. Returns the UI object on success and `nil` on failure.
--- Location: Lua/Libs/ClientUI.inl:15
--- @param name CString A user-defined unique name that identifies the UI element. To avoid name collisions, the name should always be prefixed with the mod name (e.g. `NRD_CraftingUI`)
--- @param path CString Path of the SWF file relative to the data directory (e.g. `"Public/ModName/GUI/CraftingUI.swf"`)
--- @param layer int32 Stack order of the UI element. Overlapping elements with a larger layer value cover those with a smaller one.
--- @return UIObject
function Ext_ClientUI.Create(name, path, layer) end

--- Destroys the specified UI element.
--- Location: Lua/Libs/ClientUI.inl:141
--- @param name CString Name passed to `Ext.UI.Create` when creating the UI element
function Ext_ClientUI.Destroy(name) end

--- double to int64 handle conversion hack for use in Flash external interface calls (Some of the builtin functions treat handles as double values)
--- Location: Lua/Libs/ClientUI.inl:209
--- @param dbl double Flash double value to convert
--- @return ComponentHandle
function Ext_ClientUI.DoubleToHandle(dbl) end

--- Toggles printing of Flash elements where the custom draw callback is being called. (i.e. icons where the image is supplied by engine code)
--- Location: Lua/Libs/ClientUI.inl:186
--- @param enabled bool 
function Ext_ClientUI.EnableCustomDrawCallDebugging(enabled) end

--- Retrieves a UI element with the specified name. If no such element exists, the function returns `nil`.
--- Location: Lua/Libs/ClientUI.inl:93
--- @param name CString Name passed to `Ext.UI.Create` when creating the UI element
--- @return UIObject
function Ext_ClientUI.GetByName(name) end

--- Retrieves a built-in UI element at the specified path. If no such element exists, the function returns `nil`.
--- Location: Lua/Libs/ClientUI.inl:121
--- @param path CString SWF path relative to data directory (e.g. `"Public/ModName/GUI/CraftingUI.swf"`)
--- @return UIObject
function Ext_ClientUI.GetByPath(path) end

--- Retrieves an engine UI element. If no such element exists, the function returns `nil`.
--- Location: Lua/Libs/ClientUI.inl:103
--- @param typeId int32 Engine UI ID
--- @return UIObject
function Ext_ClientUI.GetByType(typeId) end

--- Returns the character creation UI. (The object returned by this call can be used to access additional character creation-specific fields that are not available via `GetByPath()` etc.)
--- Location: Lua/Libs/ClientUI.inl:218
--- @return EclCharacterCreationUICharacterCreationWizard
function Ext_ClientUI.GetCharacterCreationWizard() end

--- @return DragDropManager
function Ext_ClientUI.GetDragDrop() end

--- @param playerIndex int32|nil 
function Ext_ClientUI.GetPickingState(playerIndex) end

--- Returns the size of the viewport (game window)
--- Location: Lua/Libs/ClientUI.inl:304
--- @return ivec2
function Ext_ClientUI.GetViewportSize() end

--- int64 handle to double conversion hack for use in Flash external interface calls (Some of the builtin functions treat handles as double values)
--- Location: Lua/Libs/ClientUI.inl:199
--- @param handle ComponentHandle Handle to convert
--- @return double
function Ext_ClientUI.HandleToDouble(handle) end

--- Loads a Flash library; other SWF files can import symbols from this library. Note: The game can load at most 7 additional libraries, so only use this feature when necessary!
--- Location: Lua/Libs/ClientUI.inl:292
--- @param moduleName STDString Library name
--- @param path STDString SWF path relative to data directory (e.g. `"Public/ModName/GUI/SomeLibrary.swf"`)
--- @return bool
function Ext_ClientUI.LoadFlashLibrary(moduleName, path) end

--- Experimental! Forces an UI refresh for the specified character. Supported flag values:
--- 
---  - 0x1 - AP
---  - 0x10 - Abilities
---  - 0x60 - Status icons
---  - 0x40000 - Health
---  - 0x80000 - Skill set
---  - 0x1000000 - Inventory
---  - 0x10000000 - Character transform
---  - 0x80000000 - Relations
--- Location: Lua/Libs/ClientUI.inl:166
--- @param handle ComponentHandle UI object handle
--- @param flags uint64 Dirty flags
function Ext_ClientUI.SetDirty(handle, flags) end



--- @class Ext_ClientVisual
--- @field GetVisual fun(a1: ComponentHandle):Visual
local Ext_ClientVisual = {}


--- @param position vec3 
--- @return EclLuaVisualClientMultiVisual
function Ext_ClientVisual.Create(position) end

--- @param position vec3 
--- @return EclLuaVisualClientMultiVisual
function Ext_ClientVisual.CreateOnCharacter(position) end

--- @param position vec3 
--- @return EclLuaVisualClientMultiVisual
function Ext_ClientVisual.CreateOnItem(position) end

--- @param handle ComponentHandle 
--- @return EclLuaVisualClientMultiVisual
function Ext_ClientVisual.Get(handle) end



--- @class Ext_Debug
--- @field DebugBreak fun()
local Ext_Debug = {}


function Ext_Debug.DebugDumpLifetimes() end

function Ext_Debug.DumpNetworking() end

function Ext_Debug.DumpStack() end

--- @param builtinOnly bool|nil 
function Ext_Debug.GenerateIdeHelpers(builtinOnly) end

--- @return bool
function Ext_Debug.IsDeveloperMode() end



--- @class Ext_IO
local Ext_IO = {}


--- @param path CString 
--- @param overridePath CString 
function Ext_IO.AddPathOverride(path, overridePath) end

--- @param path CString 
--- @return STDString|nil
function Ext_IO.GetPathOverride(path) end

--- @param path CString 
--- @param context FixedString|nil 
--- @return STDString|nil
function Ext_IO.LoadFile(path, context) end

--- @param path CString 
--- @param contents CString 
--- @return bool
function Ext_IO.SaveFile(path, contents) end



--- @class Ext_Json
local Ext_Json = {}


function Ext_Json.Parse() end

function Ext_Json.Stringify() end



--- @class Ext_L10N
local Ext_L10N = {}


--- @param keyStr CString 
--- @param value CString 
--- @return STDString|nil
function Ext_L10N.CreateTranslatedString(keyStr, value) end

--- @param handleStr CString 
--- @param value CString 
--- @return bool
function Ext_L10N.CreateTranslatedStringHandle(handleStr, value) end

--- @param keyStr CString 
--- @param handleStr CString 
--- @return bool
function Ext_L10N.CreateTranslatedStringKey(keyStr, handleStr) end

--- @param translatedStringKey CString 
--- @param fallbackText CString|nil 
--- @return STDString
function Ext_L10N.GetTranslatedString(translatedStringKey, fallbackText) end

--- @param key FixedString 
function Ext_L10N.GetTranslatedStringFromKey(key) end



--- @class Ext_Math
local Ext_Math = {}


--- Arc cosine. Returns an angle whose sine is x.
--- Location: Lua/Libs/Math.inl:810
--- @param x float 
--- @return float
function Ext_Math.Acos(x) end

function Ext_Math.Add() end

--- Returns the absolute angle between two vectors. Parameters need to be normalized.
--- Location: Lua/Libs/Math.inl:357
function Ext_Math.Angle() end

--- Arc sine. Returns an angle whose sine is x.
--- Location: Lua/Libs/Math.inl:818
--- @param x float 
--- @return float
function Ext_Math.Asin(x) end

--- Arc tangent. Returns an angle whose tangent is y_over_x.
--- Location: Lua/Libs/Math.inl:827
--- @param y_over_x float 
--- @return float
function Ext_Math.Atan(y_over_x) end

--- Arc tangent. Returns an angle whose tangent is y / x. The signs of x and y are used to determine what quadrant the angle is in.
--- Location: Lua/Libs/Math.inl:837
--- @param x float 
--- @param y float 
--- @return float
function Ext_Math.Atan2(x, y) end

--- Build a matrix from axis and angle.
--- Location: Lua/Libs/Math.inl:698
--- @param axis vec3 
--- @param angle float 
--- @return mat3
function Ext_Math.BuildFromAxisAngle3(axis, angle) end

--- Build a matrix from axis and angle.
--- Location: Lua/Libs/Math.inl:706
--- @param axis vec3 
--- @param angle float 
--- @return mat4
function Ext_Math.BuildFromAxisAngle4(axis, angle) end

--- Creates a 3D 3 * 3 homogeneous rotation matrix from euler angles `(X * Y * Z)`.
--- Location: Lua/Libs/Math.inl:639
--- @param angle vec3 
--- @return mat3
function Ext_Math.BuildFromEulerAngles3(angle) end

--- Creates a 3D 4 * 4 homogeneous rotation matrix from euler angles `(X * Y * Z)`.
--- Location: Lua/Libs/Math.inl:631
--- @param angle vec3 
--- @return mat4
function Ext_Math.BuildFromEulerAngles4(angle) end

--- Builds a rotation 3 * 3 matrix created from an axis of 3 scalars and an angle expressed in radians.
--- Location: Lua/Libs/Math.inl:581
--- @param v vec3 
--- @param angle float 
--- @return mat3
function Ext_Math.BuildRotation3(v, angle) end

--- Builds a rotation 4 * 4 matrix created from an axis of 3 scalars and an angle expressed in radians.
--- Location: Lua/Libs/Math.inl:573
--- @param v vec3 
--- @param angle float 
--- @return mat4
function Ext_Math.BuildRotation4(v, angle) end

--- Builds a scale 4 * 4 matrix created from 3 scalars.
--- Location: Lua/Libs/Math.inl:597
--- @param v vec3 
--- @return mat4
function Ext_Math.BuildScale(v) end

--- Builds a translation 4 * 4 matrix created from a vector of 3 components.
--- Location: Lua/Libs/Math.inl:589
--- @param v vec3 
--- @return mat4
function Ext_Math.BuildTranslation(v) end

--- Returns `min(max(x, minVal), maxVal)` for each component in x using the floating-point values minVal and maxVal.
--- Location: Lua/Libs/Math.inl:786
--- @param val float 
--- @param min float 
--- @param max float 
--- @return float
function Ext_Math.Clamp(val, min, max) end

--- Returns the cross product of x and y.
--- Location: Lua/Libs/Math.inl:366
--- @param x vec3 
--- @param y vec3 
function Ext_Math.Cross(x, y) end

--- Decomposes a model matrix to translations, rotation and scale components.
--- Location: Lua/Libs/Math.inl:647
--- @param m mat4 
--- @param scale_ vec3 
--- @param yawPitchRoll vec3 
--- @param translation_ vec3 
function Ext_Math.Decompose(m, scale_, yawPitchRoll, translation_) end

--- Return the determinant of a mat3/mat4 matrix.
--- Location: Lua/Libs/Math.inl:450
function Ext_Math.Determinant() end

--- Returns the distance between p0 and p1, i.e., `length(p0 - p1)`.
--- Location: Lua/Libs/Math.inl:381
--- @param p0 vec3 
--- @param p1 vec3 
--- @return float
function Ext_Math.Distance(p0, p1) end

function Ext_Math.Div() end

--- Returns the dot product of x and y, i.e., `result = x * y`.
--- Location: Lua/Libs/Math.inl:390
--- @param x vec3 
--- @param y vec3 
--- @return float
function Ext_Math.Dot(x, y) end

--- Get the axis and angle of the rotation from a matrix.
--- Location: Lua/Libs/Math.inl:666
--- @return float
function Ext_Math.ExtractAxisAngle() end

--- Extracts the `(X * Y * Z)` Euler angles from the rotation matrix M.
--- Location: Lua/Libs/Math.inl:605
--- @return vec3
function Ext_Math.ExtractEulerAngles() end

--- Return x - floor(x).
--- Location: Lua/Libs/Math.inl:762
--- @param val float 
--- @return float
function Ext_Math.Fract(val) end

--- Return the inverse of a mat3/mat4 matrix.
--- Location: Lua/Libs/Math.inl:474
function Ext_Math.Inverse() end

--- Returns true if x holds a positive infinity or negative infinity representation.
--- Location: Lua/Libs/Math.inl:853
--- @param x double 
--- @return bool
function Ext_Math.IsInf(x) end

--- Returns true if x holds a NaN (not a number) representation.
--- Location: Lua/Libs/Math.inl:845
--- @param x double 
--- @return bool
function Ext_Math.IsNaN(x) end

--- Returns the length of x, i.e., `sqrt(x * x)`.
--- Location: Lua/Libs/Math.inl:408
function Ext_Math.Length() end

--- Returns x * (1.0 - a) + y * a, i.e., the linear blend of x and y using the floating-point value a.
--- Location: Lua/Libs/Math.inl:802
--- @param x float 
--- @param y float 
--- @param a float 
--- @return float
function Ext_Math.Lerp(x, y, a) end

function Ext_Math.Mul() end

--- Returns a vector in the same direction as x but with length of 1.
--- Location: Lua/Libs/Math.inl:432
function Ext_Math.Normalize() end

--- Treats the first parameter `c` as a column vector and the second parameter `r` as a row vector and does a linear algebraic matrix multiply `c * r`.
--- Location: Lua/Libs/Math.inl:522
function Ext_Math.OuterProduct() end

--- Projects `x` on a perpendicular axis of `normal`.
--- Location: Lua/Libs/Math.inl:730
function Ext_Math.Perpendicular() end

--- Projects `x` on `normal`.
--- Location: Lua/Libs/Math.inl:754
function Ext_Math.Project() end

--- For the incident vector `I` and surface orientation `N`, returns the reflection direction: `result = I - 2.0 * dot(N, I) * N`.
--- Location: Lua/Libs/Math.inl:331
function Ext_Math.Reflect() end

--- Builds a rotation matrix created from an axis of 3 scalars and an angle expressed in radians.
--- Location: Lua/Libs/Math.inl:530
function Ext_Math.Rotate() end

--- Transforms a matrix with a scale 4 * 4 matrix created from 3 scalars.
--- Location: Lua/Libs/Math.inl:564
--- @param m mat4 
--- @param scale vec3 
function Ext_Math.Scale(m, scale) end

--- Returns 1.0 if x > 0, 0.0 if x == 0, or -1.0 if x < 0.
--- Location: Lua/Libs/Math.inl:778
--- @param x float 
--- @return float
function Ext_Math.Sign(x) end

--- Returns 0.0 if x <= edge0 and 1.0 if x >= edge1 and performs smooth Hermite interpolation between 0 and 1 when edge0 < x < edge1.
--- Location: Lua/Libs/Math.inl:794
--- @param edge0 float 
--- @param edge1 float 
--- @param x float 
--- @return float
function Ext_Math.Smoothstep(edge0, edge1, x) end

function Ext_Math.Sub() end

--- Transforms a matrix with a translation 4 * 4 matrix created from a vector of 3 components.
--- Location: Lua/Libs/Math.inl:555
--- @param m mat4 
--- @param translation vec3 
function Ext_Math.Translate(m, translation) end

--- Returns the transposed matrix of `x`.
--- Location: Lua/Libs/Math.inl:498
function Ext_Math.Transpose() end

--- Returns a value equal to the nearest integer to x whose absolute value is not larger than the absolute value of x.
--- Location: Lua/Libs/Math.inl:770
--- @param val float 
--- @return float
function Ext_Math.Trunc(val) end



--- @class Ext_Mod
local Ext_Mod = {}


--- @return Module
function Ext_Mod.GetBaseMod() end

--- Returns the list of loaded module UUIDs in the order they're loaded in.
--- Location: Lua/Libs/Mod.inl:38
--- @return FixedString[]
function Ext_Mod.GetLoadOrder() end

--- Returns detailed information about the specified (loaded) module.
--- Location: Lua/Libs/Mod.inl:108
--- @param modNameGuid CString Mod UUID to query
--- @return Module
function Ext_Mod.GetMod(modNameGuid) end

--- Returns detailed information about the specified (loaded) module. This function is deprecated; use `Ext.Mod.GetMod()` instead.
---         Example:
--- ```lua
--- local loadOrder = Ext.Mods.GetLoadOrder()
--- for k, uuid in pairs(loadOrder) do
---     local mod = Ext.GetModInfo(uuid)
---     Ext.Dump(mod)
--- end
--- ```
--- Location: Lua/Libs/Mod.inl:64
--- @param modNameGuid CString Mod UUID to query
function Ext_Mod.GetModInfo(modNameGuid) end

--- Returns whether the module with the specified GUID is loaded. This is equivalent to Osiris `NRD_IsModLoaded`, but is callable when the Osiris scripting runtime is not yet available (i.e. `ModuleLoading˙, etc events).
---         Example:
--- ```lua
--- if (Ext.IsModLoaded("5cc23efe-f451-c414-117d-b68fbc53d32d")) then
---     Ext.Print("Mod loaded")
--- end
--- ```
--- Location: Lua/Libs/Mod.inl:19
--- @param modNameGuid CString UUID of mod to check
--- @return bool
function Ext_Mod.IsModLoaded(modNameGuid) end



--- @class Ext_Resource
local Ext_Resource = {}


--- @param type ResourceType 
--- @param templateId FixedString 
--- @return Resource
function Ext_Resource.Get(type, templateId) end



--- @class Ext_ServerAction
--- @field CreateGameAction fun(a1: GameActionType, a2: FixedString, a3: EsvCharacter):EsvGameAction
--- @field CreateOsirisTask fun(a1: EsvTaskType, a2: EsvCharacter):EsvTask
--- @field DestroyGameAction fun(a1: EsvGameAction)
--- @field ExecuteGameAction fun(a1: EsvGameAction)
--- @field QueueOsirisTask fun(a1: EsvTask)
local Ext_ServerAction = {}




--- @class Ext_ServerAi
local Ext_ServerAi = {}


--- @return EsvAiHelpers
function Ext_ServerAi.GetAiHelpers() end

--- @return EsvAiModifiers
function Ext_ServerAi.GetArchetypes() end



--- @class Ext_ServerCombat
--- @field GetTurnManager fun():EsvTurnManager
local Ext_ServerCombat = {}




--- @class Ext_ServerCustomStat
local Ext_ServerCustomStat = {}


--- @param name CString 
--- @param description CString 
--- @return FixedString|nil
function Ext_ServerCustomStat.Create(name, description) end

function Ext_ServerCustomStat.GetAll() end

--- @param statId CString 
function Ext_ServerCustomStat.GetById(statId) end

--- @param statName CString 
function Ext_ServerCustomStat.GetByName(statName) end



--- @class Ext_ServerEffect
local Ext_ServerEffect = {}


--- @param effectName FixedString 
--- @param sourceHandle ComponentHandle 
--- @param castBone FixedString|nil 
--- @return EsvEffect
function Ext_ServerEffect.CreateEffect(effectName, sourceHandle, castBone) end

--- @return ComponentHandle[]
function Ext_ServerEffect.GetAllEffectHandles() end

--- @param handle ComponentHandle 
--- @return EsvEffect
function Ext_ServerEffect.GetEffect(handle) end



--- @class Ext_ServerEntity
--- @field GetCharacterLegacy fun()
local Ext_ServerEntity = {}


--- @return EocAiGrid
function Ext_ServerEntity.GetAiGrid() end

--- @return EsvAlignmentContainer
function Ext_ServerEntity.GetAlignmentManager() end

--- @param levelName FixedString|nil 
--- @return FixedString[]
function Ext_ServerEntity.GetAllCharacterGuids(levelName) end

--- @param levelName FixedString|nil 
--- @return FixedString[]
function Ext_ServerEntity.GetAllItemGuids(levelName) end

--- @param levelName FixedString|nil 
--- @return FixedString[]
function Ext_ServerEntity.GetAllTriggerGuids(levelName) end

--- @return EsvCharacter
function Ext_ServerEntity.GetCharacter() end

--- Returns the UUID of all characters within a radius around the specified point.
--- Location: Lua/Libs/ServerEntity.inl:309
--- @param x float Surface action type
--- @param y float Surface action type
--- @param z float Surface action type
--- @param distance float Surface action type
--- @return FixedString[]
function Ext_ServerEntity.GetCharacterGuidsAroundPosition(x, y, z, distance) end

--- @param combatId uint32 
--- @return EsvTurnManagerCombat
function Ext_ServerEntity.GetCombat(combatId) end

--- @return EsvLevel
function Ext_ServerEntity.GetCurrentLevel() end

function Ext_ServerEntity.GetCurrentLevelData() end

--- @return IGameObject
function Ext_ServerEntity.GetGameObject() end

--- @param handle ComponentHandle 
--- @return EsvInventory
function Ext_ServerEntity.GetInventory(handle) end

--- @return EsvItem
function Ext_ServerEntity.GetItem() end

--- @param x float 
--- @param y float 
--- @param z float 
--- @param distance float 
--- @return FixedString[]
function Ext_ServerEntity.GetItemGuidsAroundPosition(x, y, z, distance) end

--- @return EsvStatus
function Ext_ServerEntity.GetStatus() end

--- @param handle ComponentHandle 
--- @return EsvSurface
function Ext_ServerEntity.GetSurface(handle) end

--- @return Trigger
function Ext_ServerEntity.GetTrigger() end

--- @return ComponentHandle
function Ext_ServerEntity.NullHandle() end



--- @class Ext_ServerNet
local Ext_ServerNet = {}


--- @param channel CString 
--- @param payload CString 
--- @param excludeCharacterGuid CString|nil 
function Ext_ServerNet.BroadcastMessage(channel, payload, excludeCharacterGuid) end

--- @param characterGuid CString 
--- @return bool|nil
function Ext_ServerNet.PlayerHasExtender(characterGuid) end

--- @param characterGuid CString 
--- @param channel CString 
--- @param payload CString 
function Ext_ServerNet.PostMessageToClient(characterGuid, channel, payload) end

--- @param userId int32 
--- @param channel CString 
--- @param payload CString 
function Ext_ServerNet.PostMessageToUser(userId, channel, payload) end



--- @class Ext_ServerOsiris
local Ext_ServerOsiris = {}


--- @return bool
function Ext_ServerOsiris.IsCallable() end

function Ext_ServerOsiris.NewCall() end

function Ext_ServerOsiris.NewEvent() end

function Ext_ServerOsiris.NewQuery() end

--- @param name CString 
--- @param arity int32 
--- @param typeName CString 
function Ext_ServerOsiris.RegisterListener(name, arity, typeName) end



--- @class Ext_ServerPropertyList
local Ext_ServerPropertyList = {}


--- @param statsEntryName FixedString 
--- @param propertyName FixedString 
--- @param attacker EsvCharacter 
--- @param position vec3 
--- @param radius float 
--- @param propertyContext StatsPropertyContext 
--- @param isFromItem bool 
--- @param skillId FixedString|nil 
function Ext_ServerPropertyList.ExecuteExtraPropertiesOnPosition(statsEntryName, propertyName, attacker, position, radius, propertyContext, isFromItem, skillId) end

--- @param statsEntryName FixedString 
--- @param propertyName FixedString 
--- @param attacker EsvCharacter 
--- @param target EsvCharacter 
--- @param position vec3 
--- @param propertyContext StatsPropertyContext 
--- @param isFromItem bool 
--- @param skillId FixedString|nil 
function Ext_ServerPropertyList.ExecuteExtraPropertiesOnTarget(statsEntryName, propertyName, attacker, target, position, propertyContext, isFromItem, skillId) end

function Ext_ServerPropertyList.ExecuteSkillPropertiesOnPosition() end

function Ext_ServerPropertyList.ExecuteSkillPropertiesOnTarget() end



--- @class Ext_ServerServer
--- @field GetLevelManager fun():EsvLevelManager
local Ext_ServerServer = {}


function Ext_ServerServer.GetGameState() end

--- @return ModManager
function Ext_ServerServer.GetModManager() end



--- @class Ext_ServerSurfaceAction
local Ext_ServerSurfaceAction = {}


--- @param actionHandle ComponentHandle 
function Ext_ServerSurfaceAction.Cancel(actionHandle) end

--- Prepares a new surface action for execution
--- Location: Lua/Libs/ServerSurfaceAction.inl:16
--- @param type SurfaceActionType Surface action type
--- @return EsvSurfaceAction
function Ext_ServerSurfaceAction.Create(type) end

--- @param action EsvSurfaceAction 
function Ext_ServerSurfaceAction.Execute(action) end



--- @class Ext_ServerTemplate
local Ext_ServerTemplate = {}


--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ServerTemplate.CreateCacheTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ServerTemplate.GetCacheTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ServerTemplate.GetLocalCacheTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ServerTemplate.GetLocalTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ServerTemplate.GetRootTemplate(templateId) end

--- @param templateId FixedString 
--- @return GameObjectTemplate
function Ext_ServerTemplate.GetTemplate(templateId) end



--- @class Ext_Stats
local Ext_Stats = {}


--- Adds a custom property description to the specified stat entry. (The blue text in the skill description tooltip). This function can only be called from a `ModuleLoading` listener.
---         Example:
--- ```lua
--- Ext.Stats.AddCustomDescription("Dome_CircleOfProtection", "SkillProperties", "Custom desc one")
--- ```
--- Location: Lua/Libs/Stats.inl:762
--- @param statName CString Stats name to fetch
--- @param attributeName CString Property list to expand (SkillProperties or ExtraProperties)
--- @param description CString Description text
function Ext_Stats.AddCustomDescription(statName, attributeName, description) end

--- @param speakerGuid FixedString 
--- @param translatedStringKey FixedString 
--- @param source CString 
--- @param length float 
--- @param priority int32|nil 
function Ext_Stats.AddVoiceMetaData(speakerGuid, translatedStringKey, source, length, priority) end

--- Creates a new stats entry. If a stat object with the same name already exists, the specified modifier type is invalid or the specified template doesn't exist, the function returns `nil`. After all stat properties were initialized, the stats entry must be synchronized by calling `SyncStat()`.
--- 
---  - If the entry was created on the server, `SyncStat()` will replicate the stats entry to all clients.If the entry was created on the client, `SyncStat()` will only update it locally. Example:
--- ```lua
--- local stat = Ext.Stats.Create("NRD_Dynamic_Skill", "SkillData", "Rain_Water")
--- stat.RainEffect = "RS3_FX_Environment_Rain_Fire_01"
--- stat.SurfaceType = "Fire"
--- Ext.Stats.Sync("NRD_Dynamic_Skill")
--- ```
--- Location: Lua/Libs/Stats.inl:955
--- @param statName FixedString Name of stats entry to create; it should be globally unique
--- @param modifierList FixedString Stats entry type (eg. `SkillData`, `StatusData`, `Weapon`, etc.)
--- @param copyFromTemplate FixedString|nil If this parameter is not `nil`, stats properties are copied from the specified stats entry to the newly created entry
--- @param byRef bool|nil Specifies whether the created object should use by-value or by-ref properties (default: by-value)
function Ext_Stats.Create(statName, modifierList, copyFromTemplate, byRef) end

--- @param enumName FixedString 
--- @param index int32 
function Ext_Stats.EnumIndexToLabel(enumName, index) end

--- @param enumName FixedString 
--- @param label FixedString 
function Ext_Stats.EnumLabelToIndex(enumName, label) end

--- Returns the specified stats entry as an object for easier manipulation. If the `level` argument is not specified or is `nil`, the table will contain stat values as specified in the stat entry. If the `level` argument is not `nil`, the table will contain level - scaled values for the specified level. A `level` value of `-1` will use the level specified in the stat entry.
---         The behavior of getting a table entry is identical to that of `StatGetAttribute` and setting a table entry is identical to `StatSetAttribute`.
--- The `StatSetAttribute` example rewritten using `GetStat`:
--- ```lua
--- -- Swap DamageType from Poison to Air on all skills
--- for i, name in pairs(Ext.Stats.GetEntries("SkillData")) do
---     local stat = Ext.Stats.Get(name)
---     if stat.DamageType == "Poison" then
---         stat.DamageType = "Air"
---     end
--- end
--- ```
--- Location: Lua/Libs/Stats.inl:881
--- @param statName CString Stats name to fetch
--- @param level int32|nil Specify `nil` to return raw (unscaled) stat values, `-1` to return values scaled to the stats level, or a specific level value to scale returned stats to that level
--- @param warnOnError bool|nil Log a warning in the console if the stats object could not be found?
--- @param byRef bool|nil Specifies whether the returned object should use by-value or by-ref properties (default: by-value)
function Ext_Stats.Get(statName, level, warnOnError, byRef) end

--- Returns the specified `attribute` of the stat entry. If the stat entry does not exist, the stat entry doesn't have an attribute named `attribute`, or the attribute is not supported, the function returns `nil`.
---         ** Notes: **
---  - For enumerations, the function will return the enumeration label(eg. `Corrosive`). See `ModifierLists.txt` or `Enumerations.xml` for a list of enumerationsand enumeration labels.
---  - The following fields are not supported: `AoEConditions`, `TargetConditions`, `ForkingConditions`, `CycleConditions` `Requirements` and `MemorizationRequirements` are returned in the following format :
--- ```lua
--- [
---     {
---         "Not" : false, // Negated condition?
---         "Param" : 1, // Parameter; number for ability/attribute level, string for Tag
---         "Requirement" : "FireSpecialist" // Requirement name
---     },
---     {
---         "Not" : false,
---         "Param" : 1,
---         "Requirement" : "Necromancy"
---     }
--- ]
--- ```
--- Location: Lua/Libs/Stats.inl:678
--- @param statName CString 
--- @param attributeName FixedString 
function Ext_Stats.GetAttribute(statName, attributeName) end

--- @return CharacterCreationCharacterCreationManager
function Ext_Stats.GetCharacterCreation() end

--- Returns a table with the names of all stat entries. When the optional parameter `statType` is specified, it'll only return stats with the specified type. (The type of a stat entry is specified in the stat .txt file itself (eg. `type "StatusData"`). The following types are supported: `StatusData`, `SkillData`, `Armor`, `Shield`, `Weapon`, `Potion`, `Character`, `Object`, `SkillSet`, `EquipmentSet`, `TreasureTable`, `ItemCombination`, `ItemComboProperty`, `CraftingPreviewData`, `ItemGroup`, `NameGroup`, `DeltaMod`
--- Location: Lua/Libs/Stats.inl:348
--- @param statType FixedString|nil Type of stat to fetch
function Ext_Stats.GetStats(statType) end

--- Returns a table with the names of all stat entries that were loaded before the specified mod. This function is useful for retrieving stats that can be overridden by a mod according to the module load order. When the optional parameter `statType` is specified, it'll only return stats with the specified type. (The type of a stat entry is specified in the stat .txt file itself (eg. `type "StatusData"`).
--- Location: Lua/Libs/Stats.inl:401
--- @param modUuid FixedString Return stats entries declared before this module was loaded
--- @param statType FixedString|nil Type of stat to fetch
--- @return FixedString[]
function Ext_Stats.GetStatsLoadedBefore(modUuid, statType) end

function Ext_Stats.NewDamageList() end

--- Updates the specified `attribute` of the stat entry. This essentially allows on-the-fly patching of stat .txt files from script without having to override the while stat entry. If the function is called while the module is loading (i.e. from a `ModuleLoading`/`StatsLoaded` listener) no additional calls are needed. If the function is called after module load, the stats entry must be synchronized with the client via the `Sync` call. ** Notes: **
--- 
---  - For enumerations, the function accepts both the enumeration label (a string value, eg. `Corrosive`) and the enumeration index (an integer value, eg, `7`). See `ModifierLists.txt` or `Enumerations.xml` for a list of enumerations and enumeration labels.
---  - Be aware that a lot of number-like attributes are in fact enums; eg. the `Strength`, `Finesse`, `Intelligence`, etc. attributes of `Potion` are enumerations and setting them by passing an integer value to this function will yield unexpected results. For example, calling `SetAttribute("SomePotion", "Strength", 5)` will set the `Strength` value to `-9.6`! The proper way to set these values is by passing the enumeration label as string, eg. `SetAttribute("SomePotion", "Strength", "5")`
--- Example:
--- ```lua
--- -- Swap DamageType from Poison to Air on all skills
--- for i,name in pairs(Ext.Stats.GetEntries("SkillData")) do
---     local damageType = Ext.Stats.GetAttribute(name, "DamageType")
---     if damageType == "Poison" then
---         Ext.Stats.SetAttribute(name, "DamageType", "Air")
---     end
--- end
--- ```
--- When modifying stat attributes that contain tables (i.e. `Requirements`, `TargetConditions`, `SkillProperties` etc.) it is not sufficient to just modify the table, the modified table must be reassigned to the property:
--- ```lua
--- local requirements = Ext.Stats.GetAttribute(name, "MemorizationRequirements")
--- table.insert(requirements, {Name = "Intelligence", Param = 10, Not = false})
--- Ext.Stats.SetAttribute(name, "Requirements", requirements)
--- ```
--- Stat entries that are modified on the fly (i.e. after `ModuleLoading`/`StatsLoaded`) must be synchronized via `SyncStat()`. Neglecting to do this will cause the stat entry to be different on the client and the server.
--- ```lua
--- local stat = Ext.Stats.Get(name)
--- stat.DamageType = "Air"
--- stat.Damage = 10
--- Ext.Stats.Sync(name)
--- ```
--- Location: Lua/Libs/Stats.inl:738
--- @param statName CString 
--- @param attributeName FixedString 
--- @return bool
function Ext_Stats.SetAttribute(statName, attributeName) end

--- Replaces level scaling formula for the specified stat. This function can only be called from a `ModuleLoading` listener.
---         `func` must satisfy the following requirements :
---  - Must be a Lua function that receives two arguments `(attributeValue, level)`and returns the integer level scaled value.
---  - Must have no side effects(i.e.can't set external variables, call external functions, etc)
---  - Must always returns the same result when given the same argument values
---  - Since the function is called very frequently (up to 50, 000 calls during a level load), it should execute as quickly as possible
--- Location: Lua/Libs/Stats.inl:806
--- @param modifierListName FixedString Stat attribute to override (`Strength`, `Constitution`, ...)
--- @param modifierName FixedString 
function Ext_Stats.SetLevelScaling(modifierListName, modifierName) end

--- Toggles whether the specified stats entry should be persisted to savegames. Changes made to non - persistent stats will be lost the next time a game is reloaded. If a dynamically created stats entry is marked as non - persistent, the entry will be deleted completely after the next reload.Make sure that you don't delete entries that are still in use as it could break the game in various ways.
--- Location: Lua/Libs/Stats.inl:1028
--- @param statName FixedString Name of stats entry to update
--- @param persist bool Is the stats entry persistent, i.e. if it will be written to savegames
function Ext_Stats.SetPersistence(statName, persist) end

--- Synchronizes the changes made to the specified stats entry to each client. `Sync` must be called each time a stats entry is modified dynamically (after `ModuleLoading`/`StatsLoaded`) to ensure that the hostand all clients see the same properties.
--- Location: Lua/Libs/Stats.inl:998
--- @param statName FixedString Name of stats entry to sync
--- @param persist bool|nil Is the stats entry persistent, i.e. if it will be written to savegames. (default `true`)
function Ext_Stats.Sync(statName, persist) end



--- @class Ext_StatsDeltaMod
--- @field GetLegacy fun(a1: FixedString, a2: FixedString)
--- @field Update fun()
local Ext_StatsDeltaMod = {}




--- @class Ext_StatsEquipmentSet
--- @field GetLegacy fun(a1: FixedString)
--- @field Update fun()
local Ext_StatsEquipmentSet = {}




--- @class Ext_StatsItemColor
--- @field Get fun(a1: FixedString):StatsItemColorDefinition
--- @field GetAll fun()
--- @field Update fun()
local Ext_StatsItemColor = {}




--- @class Ext_StatsItemCombo
--- @field GetLegacy fun(a1: FixedString)
--- @field Update fun()
local Ext_StatsItemCombo = {}




--- @class Ext_StatsItemComboPreview
--- @field GetLegacy fun(a1: FixedString)
--- @field Update fun()
local Ext_StatsItemComboPreview = {}




--- @class Ext_StatsItemComboProperty
--- @field GetLegacy fun(a1: FixedString)
--- @field Update fun()
local Ext_StatsItemComboProperty = {}




--- @class Ext_StatsItemGroup
--- @field GetLegacy fun(a1: FixedString)
local Ext_StatsItemGroup = {}




--- @class Ext_StatsItemSet
--- @field GetLegacy fun(a1: FixedString)
--- @field Update fun()
local Ext_StatsItemSet = {}




--- @class Ext_StatsNameGroup
--- @field GetLegacy fun(a1: FixedString)
local Ext_StatsNameGroup = {}




--- @class Ext_StatsSkillSet
--- @field GetLegacy fun(a1: CString)
--- @field Update fun()
local Ext_StatsSkillSet = {}




--- @class Ext_StatsTreasureCategory
--- @field GetLegacy fun(a1: FixedString)
--- @field Update fun(a1: FixedString)
local Ext_StatsTreasureCategory = {}




--- @class Ext_StatsTreasureTable
--- @field GetLegacy fun(a1: FixedString)
--- @field Update fun()
local Ext_StatsTreasureTable = {}




--- @class Ext_Surface
local Ext_Surface = {}


--- @param type SurfaceType 
--- @return SurfaceTemplate
function Ext_Surface.GetTemplate(type) end

function Ext_Surface.GetTransformRules() end

function Ext_Surface.UpdateTransformRules() end



--- @class Ext_Types
local Ext_Types = {}

--- Generate an ExtIdeHelpers file  
--- @param outputPath string|nil Optional path to save the generated helper file, relative to the `Documents\Larian Studios\Divinity Original Sin 2 Definitive Edition\Osiris Data` folder  
--- @param addOsi boolean|nil If true, all Osiris functions will be included in the Osi global table. This is optional, due to the possible performance cost of having so many functions  
--- @return string fileContents Returns the file contents, for use with Ext.IO.SaveFile
function Ext_Types.GenerateIdeHelpers(outputPath, addOsi) end



--- @return FixedString[]
function Ext_Types.GetAllTypes() end

function Ext_Types.GetObjectType() end

--- @param typeName FixedString 
--- @return TypeInformation
function Ext_Types.GetTypeInfo(typeName) end



--- @class Ext_Utils
--- @field Version fun():int32
local Ext_Utils = {}


--- @return STDString|nil
function Ext_Utils.GameVersion() end

--- @return uint32
function Ext_Utils.GetDifficulty() end

--- @return STDString
function Ext_Utils.GetGameMode() end

--- @return GlobalSwitches
function Ext_Utils.GetGlobalSwitches() end

--- @return GraphicSettings
function Ext_Utils.GetGraphicSettings() end

--- @return FixedString|nil
function Ext_Utils.GetHandleType() end

--- @return STDString
function Ext_Utils.GetValueType() end

--- Converts a handle to an integer value for serialization purposes.
--- Location: Lua/Libs/Utils.inl:184
--- @param handle ComponentHandle Handle to convert
--- @return int64
function Ext_Utils.HandleToInteger(handle) end

--- @overload fun(modGUID:string|nil, path:string, replaceGlobals:table|nil):any
--- @param path string The path to the script, relative to the Lua folder
--- @param modGUID string|nil The ModuleUUID value
--- @param replaceGlobals table|nil If set, the global environment of the script is replaced with this table
--- @return any returnedValue Whatever the script returned, if anything
function Ext_Utils.Include() end

--- Converts an integer value to a handle for serialization purposes.
--- Location: Lua/Libs/Utils.inl:193
--- @param i int64 Integer value to convert
--- @return ComponentHandle
function Ext_Utils.IntegerToHandle(i) end

--- @return bool
function Ext_Utils.IsValidHandle() end

function Ext_Utils.MakeHandleObject() end

--- @return int64
function Ext_Utils.MonotonicTime() end

function Ext_Utils.Print() end

function Ext_Utils.PrintError() end

function Ext_Utils.PrintWarning() end

function Ext_Utils.Random() end

--- @param val double 
--- @return int64
function Ext_Utils.Round(val) end

--- @param message STDWString 
function Ext_Utils.ShowErrorAndExitGame(message) end



--- @class ExtClient
--- @field Audio Ext_ClientAudio
--- @field ClientAudio Ext_ClientAudio
--- @field Client Ext_ClientClient
--- @field ClientClient Ext_ClientClient
--- @field Entity Ext_ClientEntity
--- @field ClientEntity Ext_ClientEntity
--- @field Input Ext_ClientInput
--- @field ClientInput Ext_ClientInput
--- @field Net Ext_ClientNet
--- @field ClientNet Ext_ClientNet
--- @field Template Ext_ClientTemplate
--- @field ClientTemplate Ext_ClientTemplate
--- @field UI Ext_ClientUI
--- @field ClientUI Ext_ClientUI
--- @field Visual Ext_ClientVisual
--- @field ClientVisual Ext_ClientVisual
--- @field Debug Ext_Debug
--- @field IO Ext_IO
--- @field Json Ext_Json
--- @field L10N Ext_L10N
--- @field Math Ext_Math
--- @field Mod Ext_Mod
--- @field Resource Ext_Resource
--- @field Stats Ext_Stats
--- @field Stats.DeltaMod Ext_StatsDeltaMod
--- @field Stats.EquipmentSet Ext_StatsEquipmentSet
--- @field Stats.ItemColor Ext_StatsItemColor
--- @field Stats.ItemCombo Ext_StatsItemCombo
--- @field Stats.ItemComboPreview Ext_StatsItemComboPreview
--- @field Stats.ItemComboProperty Ext_StatsItemComboProperty
--- @field Stats.ItemGroup Ext_StatsItemGroup
--- @field Stats.ItemSet Ext_StatsItemSet
--- @field Stats.NameGroup Ext_StatsNameGroup
--- @field Stats.SkillSet Ext_StatsSkillSet
--- @field Stats.TreasureCategory Ext_StatsTreasureCategory
--- @field Stats.TreasureTable Ext_StatsTreasureTable
--- @field Surface Ext_Surface
--- @field Types Ext_Types
--- @field Utils Ext_Utils

--- @class ExtServer
--- @field Debug Ext_Debug
--- @field IO Ext_IO
--- @field Json Ext_Json
--- @field L10N Ext_L10N
--- @field Math Ext_Math
--- @field Mod Ext_Mod
--- @field Resource Ext_Resource
--- @field Action Ext_ServerAction
--- @field ServerAction Ext_ServerAction
--- @field Ai Ext_ServerAi
--- @field ServerAi Ext_ServerAi
--- @field Combat Ext_ServerCombat
--- @field ServerCombat Ext_ServerCombat
--- @field CustomStat Ext_ServerCustomStat
--- @field ServerCustomStat Ext_ServerCustomStat
--- @field Effect Ext_ServerEffect
--- @field ServerEffect Ext_ServerEffect
--- @field Entity Ext_ServerEntity
--- @field ServerEntity Ext_ServerEntity
--- @field Net Ext_ServerNet
--- @field ServerNet Ext_ServerNet
--- @field Osiris Ext_ServerOsiris
--- @field ServerOsiris Ext_ServerOsiris
--- @field PropertyList Ext_ServerPropertyList
--- @field ServerPropertyList Ext_ServerPropertyList
--- @field Server Ext_ServerServer
--- @field ServerServer Ext_ServerServer
--- @field Surface.Action Ext_ServerSurfaceAction
--- @field ServerSurface.Action Ext_ServerSurfaceAction
--- @field Template Ext_ServerTemplate
--- @field ServerTemplate Ext_ServerTemplate
--- @field Stats Ext_Stats
--- @field Stats.DeltaMod Ext_StatsDeltaMod
--- @field Stats.EquipmentSet Ext_StatsEquipmentSet
--- @field Stats.ItemColor Ext_StatsItemColor
--- @field Stats.ItemCombo Ext_StatsItemCombo
--- @field Stats.ItemComboPreview Ext_StatsItemComboPreview
--- @field Stats.ItemComboProperty Ext_StatsItemComboProperty
--- @field Stats.ItemGroup Ext_StatsItemGroup
--- @field Stats.ItemSet Ext_StatsItemSet
--- @field Stats.NameGroup Ext_StatsNameGroup
--- @field Stats.SkillSet Ext_StatsSkillSet
--- @field Stats.TreasureCategory Ext_StatsTreasureCategory
--- @field Stats.TreasureTable Ext_StatsTreasureTable
--- @field Surface Ext_Surface
--- @field Types Ext_Types
--- @field Utils Ext_Utils

--- @class Ext
--- @field Audio Ext_ClientAudio
--- @field ClientAudio Ext_ClientAudio
--- @field Client Ext_ClientClient
--- @field ClientClient Ext_ClientClient
--- @field Entity Ext_ClientEntity|Ext_ServerEntity
--- @field ClientEntity Ext_ClientEntity
--- @field Input Ext_ClientInput
--- @field ClientInput Ext_ClientInput
--- @field Net Ext_ClientNet|Ext_ServerNet
--- @field ClientNet Ext_ClientNet
--- @field Template Ext_ClientTemplate|Ext_ServerTemplate
--- @field ClientTemplate Ext_ClientTemplate
--- @field UI Ext_ClientUI
--- @field ClientUI Ext_ClientUI
--- @field Visual Ext_ClientVisual
--- @field ClientVisual Ext_ClientVisual
--- @field Debug Ext_Debug
--- @field IO Ext_IO
--- @field Json Ext_Json
--- @field L10N Ext_L10N
--- @field Math Ext_Math
--- @field Mod Ext_Mod
--- @field Resource Ext_Resource
--- @field Action Ext_ServerAction
--- @field ServerAction Ext_ServerAction
--- @field Ai Ext_ServerAi
--- @field ServerAi Ext_ServerAi
--- @field Combat Ext_ServerCombat
--- @field ServerCombat Ext_ServerCombat
--- @field CustomStat Ext_ServerCustomStat
--- @field ServerCustomStat Ext_ServerCustomStat
--- @field Effect Ext_ServerEffect
--- @field ServerEffect Ext_ServerEffect
--- @field ServerEntity Ext_ServerEntity
--- @field ServerNet Ext_ServerNet
--- @field Osiris Ext_ServerOsiris
--- @field ServerOsiris Ext_ServerOsiris
--- @field PropertyList Ext_ServerPropertyList
--- @field ServerPropertyList Ext_ServerPropertyList
--- @field Server Ext_ServerServer
--- @field ServerServer Ext_ServerServer
--- @field Surface.Action Ext_ServerSurfaceAction
--- @field ServerSurface.Action Ext_ServerSurfaceAction
--- @field ServerTemplate Ext_ServerTemplate
--- @field Stats Ext_Stats
--- @field Stats.DeltaMod Ext_StatsDeltaMod
--- @field Stats.EquipmentSet Ext_StatsEquipmentSet
--- @field Stats.ItemColor Ext_StatsItemColor
--- @field Stats.ItemCombo Ext_StatsItemCombo
--- @field Stats.ItemComboPreview Ext_StatsItemComboPreview
--- @field Stats.ItemComboProperty Ext_StatsItemComboProperty
--- @field Stats.ItemGroup Ext_StatsItemGroup
--- @field Stats.ItemSet Ext_StatsItemSet
--- @field Stats.NameGroup Ext_StatsNameGroup
--- @field Stats.SkillSet Ext_StatsSkillSet
--- @field Stats.TreasureCategory Ext_StatsTreasureCategory
--- @field Stats.TreasureTable Ext_StatsTreasureTable
--- @field Surface Ext_Surface
--- @field Types Ext_Types
--- @field Utils Ext_Utils
Ext = {Events = {}}



--- @class SubscribableEvent<T>:{ (Subscribe:fun(self:SubscribableEvent, callback:fun(e:T|SubscribableEventParams), opts:{Priority:integer, Once:boolean}|nil):integer), (Unsubscribe:fun(self:SubscribableEvent, index:integer))}

--- @class SubscribableEventParams
--- @field StopPropagation fun(self:SubscribableEventParams) Stop the event from continuing on to other registered listeners.

--#region Extender Events

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.DoConsoleCommand = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.GameStateChanged = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.ModuleLoadStarted = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.ModuleLoading = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.ModuleResume = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.ResetCompleted = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.SessionLoaded = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.SessionLoading = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.StatsLoaded = {}

--- 🔨🔧**Server/Client**🔧🔨  
--- @type SubscribableEvent<LuaEmptyEventParams>  
Ext.Events.Tick = {}

--#endregion



--#region Deprecated Functions (moved to Ext modules)

--- @deprecated
--- Returns the version number of the Osiris Extender
--- @return integer
function Ext.Version() end

--- @deprecated
--- Returns the version number of the game
--- @return string
function Ext.GameVersion() end

--- @deprecated
--- Loads the specified Lua file
--- @param fileName string|nil Path of Lua file, relative to Mods/<Mod>/Story/RawFiles/Lua
--- @see Ext_Utils#Include
function Ext.Require(fileName) end

--- @alias ExtEngineEvent string|"SessionLoading"|"SessionLoaded"|"ModuleLoading"|"ModuleLoadStarted"|"ModuleResume"|"StatsLoaded"|"GameStateChanged"|"SkillGetDescriptionParam"|"StatusGetDescriptionParam"|"GetSkillDamage"|"GetSkillAPCost"|"ComputeCharacterHit"|"CalculateTurnOrder"|"GetHitChance"|"StatusGetEnterChance"|"StatusHitEnter"|"BeforeCharacterApplyDamage"|"UIInvoke"|"UICall"|"AfterUIInvoke"|"AfterUICall"|"BeforeShootProjectile"|"ShootProjectile"|"ProjectileHit"|"GroundHit"|"InputEvent"|"TreasureItemGenerated"

--- @deprecated
--- Registers a function to call when an extender event is thrown
--- @param event ExtEngineEvent Event to listen for
--- @param callback function Lua function to run when the event fires
function Ext.RegisterListener(event, callback) end

--- @alias OsirisEventType string|"before"|"after"|"beforeDelete"|"afterDelete"

--- @deprecated
--- Registers a function that is called when certain Osiris functions are called.
--- Supports events, built-in queries, DBs, PROCs, QRYs (user queries).
--- @param name string Osiris function/database name
--- @param arity number Number of columns for DBs or the number of parameters (both IN and OUT) for functions
--- @param event OsirisEventType Event type ('before' - triggered before Osiris call; 'after' - after Osiris call; 'beforeDelete'/'afterDelete' - before/after delete from DB)
--- @param handler function Lua function to run when the event fires
function Ext.RegisterOsirisListener(name, arity, event, handler) end

--- @deprecated
--- Registers a new call in Osiris
--- @param func function Function to register
--- @param funcName string Name of call to register
--- @param arguments string Call argument list
function Ext.NewCall(func, funcName, arguments) end

--- @deprecated
--- Registers a new query in Osiris
--- @param func function Function to register
--- @param funcName string Name of query to register
--- @param arguments string Query argument list
function Ext.NewQuery(func, funcName, arguments) end

--- @deprecated
--- Registers a new event in Osiris
--- @param funcName string Name of event to register
--- @param arguments string Event argument list
function Ext.NewEvent(funcName, arguments) end

--- @deprecated
--- Print to console window and editor messages pane
--- @vararg any
function Ext.Print(...) end

--- @deprecated
--- Print warning to console window and editor messages pane
--- @vararg any
function Ext.PrintWarning(...) end

--- @deprecated
--- Print error to console window and editor messages pane
--- @vararg any
function Ext.PrintError(...) end

--- @deprecated
--- Parse a JSON document into a Lua object
--- @param json string JSON string to parse
--- @return any
function Ext.JsonParse(json) end

--- @deprecated
--- Converts a Lua value into a JSON document
--- @param val any Value to serialize
--- @return string JSON document
function Ext.JsonStringify(val) end

--- @deprecated
--- Returns whether the specified mod is loaded
--- @param modGuid string UUID of the module
--- @return boolean
function Ext.IsModLoaded(modGuid) end

--- @deprecated
--- Returns the list of loaded modules in load order
--- @return string[]
function Ext.GetModLoadOrder() end

--- @deprecated
--- Returns detailed information about the specified (loaded) module
--- @param modGuid string UUID of the module
--- @return ModInfo
function Ext.GetModInfo(modGuid) end

--- @alias StatType string|"SkillData"|"Potion"|"StatusData"|"Weapon"|"Armor"|"Shield"|"DeltaMod"|"Object"

--- @deprecated
--- Returns the list of loaded stat entries
--- @param type string|nil Type of stat entry to fetch (StatusData, SkillData, ...)
--- @return string[]
function Ext.GetStatEntries(type) end

--- @deprecated
--- Returns the list of stat entries that were loaded before the specified mod
--- @param modId string Mod UUID to check
--- @param type string|nil Type of stat entry to fetch (StatusData, SkillData, ...)
--- @return string[]
function Ext.GetStatEntriesLoadedBefore(modId, type) end

--- @deprecated
--- Returns an attribute of the specified stat entry
--- @param stat string Stat entry name
--- @param attribute string Stat attribute name
--- @return any
function Ext.StatGetAttribute(stat, attribute) end

--- @deprecated
--- Updates an attribute of the specified stat entry
--- @param stat string Stat entry name
--- @param attribute string Stat attribute name
--- @param value any New stat value
function Ext.StatSetAttribute(stat, attribute, value) end

--- @deprecated
--- Adds a property description to the specified stat entry
--- @param stat string Stat entry name
--- @param attribute string Property list attribute name
--- @param description any Description to add
function Ext.StatAddCustomDescription(stat, attribute, description) end

--- @deprecated
--- Returns all skills from the specified skill set
--- @param name string Name of skill set entry
--- @return StatSkillSet|nil
function Ext.GetSkillSet(name) end

--- @deprecated
--- Updates all properties of the specified skill set.
--- The function expects a table in the same format as the one returned by GetSkillSet.
--- @param skillSet StatSkillSet
function Ext.UpdateSkillSet(skillSet) end

--- @deprecated
--- Returns all equipment from the specified equipment set
--- @param name string Name of equipment set entry
--- @return StatEquipmentSet|nil
function Ext.GetEquipmentSet(name) end

--- @deprecated
--- Updates all properties of the specified equipment set.
--- The function expects a table in the same format as the one returned by GetEquipmentSet.
--- @param equipmentSet StatEquipmentSet
function Ext.UpdateEquipmentSet(equipmentSet) end

--- @deprecated
--- Returns the specified DeltaMod or nil on failure
--- @param name string Name of delta mod
--- @param modifierType string Modifier type (Armor/Weapon)
--- @return DeltaMod
function Ext.GetDeltaMod(name, modifierType) end

--- @deprecated
--- Updates all properties of the specified DeltaMod.
--- The function expects a table in the same format as the one returned by GetDeltaMod.
--- @param deltaMod DeltaMod Name of delta mod
function Ext.UpdateDeltaMod(deltaMod) end

--- @deprecated
--- Returns the specified crafting item combination or nil on failure
--- @param name string Name of item combo
--- @return ItemCombo|nil
function Ext.GetItemCombo(name) end

--- @deprecated
--- Updates all properties of the specified item combination.
--- The function expects a table in the same format as the one returned by GetItemCombo.
--- @param itemCombo ItemCombo
function Ext.UpdateItemCombo(itemCombo) end

--- @deprecated
--- Returns the specified crafting preview data or nil on failure
--- @param name string Name of item combo preview data
--- @return ItemComboPreviewData|nil
function Ext.GetItemComboPreviewData(name) end

--- Updates all properties of the specified item combo preview.
--- The function expects a table in the same format as the one returned by GetItemComboPreviewData.
--- @param previewData ItemComboPreviewData
function Ext.UpdateItemComboPreviewData(previewData) end

--- @deprecated
--- Returns the specified crafting property or nil on failure
--- @param name string Name of item combo property
--- @return ItemComboProperty|nil
function Ext.GetItemComboProperty(name) end

--- @deprecated
--- Updates all properties of the specified item combo property.
--- The function expects a table in the same format as the one returned by GetItemComboProperty.
--- @param itemComboProperty ItemComboProperty
function Ext.UpdateItemComboProperty(itemComboProperty) end

--- @deprecated
--- Returns the specified treasure table or nil on failure
--- @param name string Name of treasure table
--- @return StatTreasureTable|nil
function Ext.GetTreasureTable(name) end

--- @deprecated
--- Updates all properties of the specified treasure table.
--- The function expects a table in the same format as the one returned by GetTreasureTable.
--- @param treasureTable StatTreasureTable
function Ext.UpdateTreasureTable(treasureTable) end

--- @deprecated
--- Returns the specified treasure category or nil on failure
--- @param name string Name of treasure category
--- @return StatTreasureCategory|nil
function Ext.GetTreasureCategory(name) end

--- @deprecated
--- Updates all properties of the specified treasure category.
--- The function expects a table in the same format as the one returned by GetTreasureCategory.
--- @param name string Name of treasure category
--- @param treasureCategory StatTreasureCategory
function Ext.UpdateTreasureCategory(name, treasureCategory) end

--- @deprecated
--- Returns the specified item progression item group or nil on failure
--- @param name string Name of item group
--- @return ItemGroup|nil
function Ext.GetItemGroup(name) end

--- @deprecated
--- Returns the specified item progression name group or nil on failure
--- @param name string Name of name group
--- @return ItemNameGroup|nil
function Ext.GetNameGroup(name) end

--- @class CustomSkillProperty
--- @field GetDescription fun(property:StatsPropertyExtender):string|nil
--- @field ExecuteOnPosition fun(property:StatsPropertyExtender, attacker: EsvCharacter|EsvItem, position: vec3, areaRadius: number, isFromItem: boolean, skill: StatEntrySkillData|nil, hit: StatsHitDamageInfo|nil)
--- @field ExecuteOnTarget fun(property:StatsPropertyExtender, attacker: EsvCharacter|EsvItem, target: EsvCharacter|EsvItem, position: vec3, isFromItem: boolean, skill: StatEntrySkillData|nil, hit: StatsHitDamageInfo|nil)

--- @deprecated
--- Registers a new skill property that can be triggered via SkillProperties
--- Stat syntax: data"SkillProperties""EXT:<PROPERTY_NAME>[,<int>,<int>,<string>,<int>,<int>]"
--- The property name must always be preceded by the string "EXT:". 
--- Target contexts (SELF:, TARGET:, ...) and useing multiple actions in the same SkillProperties are supported.
--- Conditions for EXT: properties (i.e. "IF(COND):") are _NOT YET_ supported.
--- @param name string Skill property name
--- @param defn CustomSkillProperty Event handlers for the skill property
function Ext.RegisterSkillProperty(name, defn) end

--- @deprecated
--- Replaces level scaling formula for the specified stat
--- @param statType string Stat entry type
--- @param attribute string Stat attribute name
--- @param func function Replacement scaling function
function Ext.StatSetLevelScaling(statType, attribute, func) end

--- @deprecated
--- Returns the property proxy of the specified stats entry
--- Returns level scaled values if the level parameter is not nil.
--- @param stat string Stat entry name
--- @param level integer|nil Level scaling level
--- @return StatEntryArmor|StatEntryCharacter|StatEntryObject|StatEntryPotion|StatEntryShield|StatEntrySkillData|StatEntryStatusData|StatEntryWeapon
function Ext.GetStat(stat, level) end

--- @alias StatEntryType StatEntryArmor|StatEntryCharacter|StatEntryObject|StatEntryPotion|StatEntryShield|StatEntrySkillData|StatEntryStatusData|StatEntryWeapon

--- @deprecated
--- Creates a new stats entry on the server
--- @param name string Stat entry name
--- @param type string Stat entry type (i.e. SkillData, StatusData, etc.)
--- @param template string|nil When not nil, all properties are copied from the specified stats entry
--- @return StatEntryType
function Ext.CreateStat(name, type, template) end

--- @deprecated
--- Synchronizes all modifications of the specified stat to all clients
--- @param name string Stat entry name
--- @param persist boolean|nil Persist stats entry to savegame?
function Ext.SyncStat(name, persist) end

--- @deprecated
--- Toggles whether the specified stats entry should be persisted to savegames
--- @param name string Stat entry name
--- @param persist boolean Persist stats entry to savegame?
function Ext.StatSetPersistence(name, persist) end

--- @deprecated
--- Returns the textual label assigned to the specified enumeration value
--- @param enum string Engine enumeration name
--- @param index number Value index to look up
--- @return string|nil
function Ext.EnumIndexToLabel(enum, index) end

--- @deprecated
--- Returns the numeric index assigned to the specified enumeration label
--- @param enum string Engine enumeration name
--- @param label string Value name to look for
--- @return number|nil
function Ext.EnumLabelToIndex(enum, label) end

--- @deprecated
--- Execute the SkillProperties of the specified skill on a target character.
--- @param skillId string Stats skill ID
--- @param attacker ObjectHandle|number|string Attacker character handle/NetID/UUID
--- @param target ObjectHandle|number|string Target character handle/NetID/UUID
--- @param position number[]
--- @param propertyContext string Target|AoE|Self|SelfOnHit|SelfOnEquip
--- @param isFromItem boolean
function Ext.ExecuteSkillPropertiesOnTarget(skillId, attacker, target, position, propertyContext, isFromItem) end

--- @deprecated
--- Execute the SkillProperties of the specified skill on a position.
--- @param skillId string Stats skill ID
--- @param attacker ObjectHandle|number|string Attacker character handle/NetID/UUID
--- @param position number[]
--- @param radius number
--- @param propertyContext string Target|AoE|Self|SelfOnHit|SelfOnEquip
--- @param isFromItem boolean
function Ext.ExecuteSkillPropertiesOnPosition(skillId, attacker, position, radius, propertyContext, isFromItem) end

--- @deprecated
--- Returns the transformation rules that are applied when two neighbouring surfaces interact.
--- @return SurfaceInteractionSet[][]
function Ext.GetSurfaceTransformRules() end

--- @deprecated
--- Returns the surface template for the specified surface type
--- @param type string See SurfaceType enumeration
--- @return SurfaceTemplate
function Ext.GetSurfaceTemplate(type) end

--- @deprecated
--- Updates the transformation rules that are applied when two neighbouring surfaces interact.
--- @param rules SurfaceInteractionSet[][] New rules to apply
function Ext.UpdateSurfaceTransformRules(rules) end

--- @deprecated
--- Prepares a new surface action for execution
--- @param type string Surface action type
--- @return EsvSurfaceAction
function Ext.CreateSurfaceAction(type) end

--- @deprecated
--- Executes a surface action
--- @param action EsvSurfaceAction Action to execute
function Ext.ExecuteSurfaceAction(action) end

--- @deprecated
--- Cancels a surface action
--- @param actionHandle integer Action to cancel
function Ext.CancelSurfaceAction(actionHandle) end

--- Starts creating a new item using template UUID or cloning an existing item.
--- @param from EsvItem|string Template UUID or item to clone
--- @param recursive boolean|nil Copy items in container? (cloning only)
--- @return ItemConstructor
function Ext.CreateItemConstructor(from, recursive) end

--- Begin applying a status on the specified character or item.
--- @param target string|ObjectHandle Target character/item
--- @param statusId string Status ID to apply
--- @param lifeTime number Status lifetime (-1 = infinite, -2 = keep alive)
--- @return EsvStatus|nil
function Ext.PrepareStatus(target, statusId, lifeTime) end

--- Finish applying a status on the specified character or item.
--- @param status EsvStatus Status to apply
function Ext.ApplyStatus(status) end

--- @see Ext_ServerCustomStat#GetAll
--- @deprecated
--- Returns a table containing the UUID of all registered custom stat definitions
--- @return string[]
function Ext.GetAllCustomStats() end

--- @deprecated
--- Retrieve a custom stat definition by name
--- @param statName string Custom stat name to look for
--- @return CustomStatDefinition|nil
function Ext.GetCustomStatByName(statName) end

--- @deprecated
--- Retrieve a custom stat definition by id
--- @param statId string Custom stat UUID to look for
--- @return CustomStatDefinition|nil
function Ext.GetCustomStatById(statId) end

--- @deprecated
--- Create a new custom stat definition
--- @param name string Custom stat name
--- @param description string Custom stat description
--- @return string|nil Custom stat UUID
function Ext.CreateCustomStat(name, description) end

--- @deprecated
--- Returns the UUID of all characters on the specified level. 
--- Uses the current level if no level name was specified.
--- @param level string|nil Optional level name
--- @return string[]
function Ext.GetAllCharacters(level) end

--- @deprecated
--- Returns the UUID of all characters within a radius around the specified point.
--- @param x number
--- @param y number
--- @param z number
--- @param distance number
--- @return string[]
function Ext.GetCharactersAroundPosition(x, y, z, distance) end

--- @deprecated
--- Returns the UUID of all items on the specified level. 
--- Uses the current level if no level name was specified.
--- @param level string|nil Optional level name
--- @return string[]
function Ext.GetAllItems(level) end

--- @deprecated
--- Returns the UUID of all items within a radius around the specified point.
--- @param x number
--- @param y number
--- @param z number
--- @param distance number
--- @return string[]
function Ext.GetItemsAroundPosition(x, y, z, distance) end

--- @deprecated
--- Returns the UUID of all triggers on the specified level. 
--- Uses the current level if no level name was specified.
--- @param level string|nil Optional level name
--- @return string[]
function Ext.GetAllTriggers(level) end

--- @deprecated
--- Returns the property proxy of the specified character
--- @param id string|integer|ObjectHandle Character UUID or handle or NetID
--- @return EsvCharacter|EclCharacter
function Ext.GetCharacter(id) end

--- @deprecated
--- Returns the property proxy of the specified item
--- @param id string|integer|ObjectHandle Item UUID or handle or NetID
--- @return EsvItem|EclItem
function Ext.GetItem(id) end

--- @deprecated
--- Returns the property proxy of the specified trigger (server only)
--- @param id string|ObjectHandle Trigger UUID or handle
--- @return EsvTrigger
function Ext.GetTrigger(id) end

--- @deprecated
--- Returns the property proxy of the specified character, item, projectile or trigger
--- @param handle ObjectHandle|string Game object handle or UUID. NetID will fail since it has no type information (an item and a character could have the same NetID).
--- @return EsvGameObject|EclGameObject
function Ext.GetGameObject(handle) end

--- @deprecated
--- Returns the property proxy of the specified surface
--- @param handle ObjectHandle Surface handle
--- @return EsvSurface
function Ext.GetSurface(handle) end

--- @deprecated
--- Returns the property proxy of the specified status
--- @param character string|integer|ObjectHandle Character UUID or handle or NetID
--- @param handle integer|StatusHandle Status handle or NetID
--- @return EsvStatus
function Ext.GetStatus(character, handle) end

--- @deprecated
--- Returns the specified turn-based combat
--- @param combatId integer Combat ID
--- @return EsvCombat
function Ext.GetCombat(combatId) end

--- @deprecated
--- Returns the AI grid for the currently active level
--- @return AiGrid
function Ext.GetAiGrid() end

--- @deprecated
--- Returns information about the currently active level
--- @return LevelDesc
function Ext.GetCurrentLevelData() end

--- @deprecated
--- Creates a new damage list object
--- @return DamageList
function Ext.NewDamageList() end

--- @deprecated
--- Returns whether Osiris is currently accessible or not.
--- @return boolean
function Ext.OsirisIsCallable() end

--- @deprecated
--- Returns a random number; equivalent to Lua random
--- @param low integer
--- @param up integer
--- @return integer|number
function Ext.Random(low, up) end

--- @deprecated
--- Rounds the specified number
--- @param n number
--- @return number
function Ext.Round(n) end

--- @deprecated
--- Generate Lua IDE helpers for the currently loaded module
--- @param builtin boolean|nil Only export built-in functions and names exported by Lua?
function Ext.GenerateIdeHelpers(builtin) end

--- @deprecated
--- Returns whether the code is executing in a client context
--- @return boolean
function Ext.IsClient() end

--- @deprecated
--- Returns whether the code is executing in a server context
--- @return boolean
function Ext.IsServer() end

--- @deprecated
--- Returns whether the Developer Mode switch is enabled
--- @return boolean
function Ext.IsDeveloperMode() end

--- @deprecated
--- Returns the current client/server game state machine state.
--- @return string
function Ext.GetGameState() end

--- @alias GameMode string|"Campaign"|"GameMaster"|"Arena"

--- @deprecated
--- Returns the current gamemode.
--- @return GameMode
function Ext.GetGameMode() end

--- @deprecated
--- Returns the current difficulty (0-3). 0 = Story, 1 = Explorer, 2 = Classic, 3 = Tactician, 4 = Honour
--- @return integer
function Ext.GetDifficulty() end

--- @deprecated
--- Broadcast a message to all peers
--- @param channel string Channel that will receive the message
--- @param payload string Message payload
--- @param excludeCharacter string|nil Optional peer to exclude from broadcast
function Ext.BroadcastMessage(channel, payload, excludeCharacter) end

--- @deprecated
--- Sends a message to the peer that controls the specified character
--- @param characterGuid string Character that will receive the message
--- @param channel string Channel that will receive the message
--- @param payload string Message payload
function Ext.PostMessageToClient(characterGuid, channel, payload) end

--- @deprecated
--- Sends a message to the specified peer
--- @param userId number User that will receive the message
--- @param channel string Channel that will receive the message
--- @param payload string Message payload
function Ext.PostMessageToUser(userId, channel, payload) end

--- @deprecated
--- Sends a message to the server
--- @param channel string Channel that will receive the message
--- @param payload string Message payload
function Ext.PostMessageToServer(channel, payload) end

--- @alias NetListenerCallback fun(channel:string, payload:string, user:integer|nil)

--- Registers a listener that is called when a network message is received on the specified channel
--- @param channel string Network channel name
--- @param handler NetListenerCallback Lua handler
function Ext.RegisterNetListener(channel, handler) end

--- @deprecated
--- Registers a new dialog voice line for the specified speaker.
--- @param speakerGuid string Speaker character UUID
--- @param textKey string Translated string key of text line
--- @param path string Path to audio .WEM
--- @param length number Length of audio in seconds
function Ext.AddVoiceMetaData(speakerGuid, textKey, path, length) end

--- @deprecated
--- @param handle string Translated string handle
--- @param fallback string Fallback string if the specified handle is not found
--- @return string Translated string
function Ext.GetTranslatedString(handle, fallback) end

--- @deprecated
--- @param key string Translated string key
--- @return string,string Translated string and handle
function Ext.GetTranslatedStringFromKey(key) end

--- @deprecated
--- @param key string Translated string key
--- @param handle string Translated string handle
--- @return boolean
function Ext.CreateTranslatedStringKey(key, handle) end

--- @deprecated
--- @param handle string Translated string handle
--- @param text string Display text
--- @return boolean
function Ext.CreateTranslatedStringHandle(handle, text) end

--- @deprecated
--- @param key string Translated string key
--- @param text string Display text
--- @return string|nil Created string handle
function Ext.CreateTranslatedString(key, text) end

--- @deprecated
--- Redirects all file accesses to the specified path to another file.
--- @param path string Original path
--- @param newPath string New (redirected) path
function Ext.AddPathOverride(path, newPath) end

--- @deprecated
--- Returns whether the specified path is currently redirected to another path.
--- @param path string Original path
--- @return string|nil Overridden path
function Ext.GetPathOverride(path) end

--- @deprecated
--- Constructs a new Flash UI element
--- @param name string User-defined unique name that identifies the UI element
--- @param path string Path of the SWF file relative to the data directory
--- @param layer integer Stack order of the UI element
--- @param flags integer Optional UI flags to test (experimental).
--- @return UIObject|nil
function Ext.CreateUI(name, path, layer, flags) end

--- @deprecated
--- Retrieves an UI element with the specified name
--- @param name string User-defined unique name that identifies the UI element
--- @return UIObject|nil
function Ext.GetUI(name) end

--- @deprecated
--- Retrieves a built-in UI element at the specified path.
--- If no such element exists, the function returns nil.
--- @param path string UI SWF path relative to Data\
--- @return UIObject|nil
function Ext.GetBuiltinUI(path) end

--- @deprecated
--- Retrieves an engine UI element with the specified engine type ID.
--- If no such element exists, the function returns nil.
--- @param typeId number Engine UI element type ID
--- @return UIObject|nil
function Ext.GetUIByType(typeId) end

--- @deprecated
--- Destroys the specified UI element
--- @param name string User-defined unique name that identifies the UI element
function Ext.DestroyUI(name) end

--- @deprecated
--- Refresh the UI of the specified character
--- @param character ObjectHandle Handle of character
--- @param flags integer UI elements to refresh
function Ext.UISetDirty(character, flags) end

--- @deprecated
--- Enable/disable debug prints on Flash custom draw callbacks. Useful if you need to see what icon names a UI is handling, for usage with UIObject:SetCustomIcon.
--- @param enable boolean
function Ext.UIEnableCustomDrawCallDebugging(enable) end

--- @alias UICallbackHandler fun(ui:UIObject, event:string, ...:string|boolean|number)
--- @alias UICallbackEventType string|"Before"|"After"

--- Registers a listener that is called when the specified function is called from Flash
--- @param object UIObject UI object returned from Ext.CreateUI, Ext.GetUI or Ext.GetBuiltinUI
--- @param name string ExternalInterface function name
--- @param handler UICallbackHandler Lua handler
--- @param type UICallbackEventType|nil Event type - 'Before' or 'After'
function Ext.RegisterUICall(object, name, handler, type) end

--- Registers a listener that is called when the specified function is called from Flash.
--- The event is triggered for every UI element with the specified type ID.
--- @param typeId number Engine UI element type ID
--- @param name string ExternalInterface function name
--- @param handler UICallbackHandler Lua handler
--- @param type UICallbackEventType|nil Event type - 'Before' or 'After'
function Ext.RegisterUITypeCall(typeId, name, handler, type) end

--- Registers a listener that is called when the specified function is called from Flash.
--- The event is triggered regardless of which UI element it was called on.
--- (Function call capture must be enabled for every element type that needs to monitored!)
--- @param name string ExternalInterface function name
--- @param handler UICallbackHandler Lua handler
--- @param type UICallbackEventType|nil Event type - 'Before' or 'After'
function Ext.RegisterUINameCall(name, handler, type) end

--- Registers a listener that is called when the specified method is called on the main timeline of the Flash object
--- @param object UIObject UI object returned from Ext.CreateUI, Ext.GetUI or Ext.GetBuiltinUI
--- @param name string Flash method name
--- @param handler UICallbackHandler Lua handler
--- @param type UICallbackEventType|nil Event type - 'Before' or 'After'
function Ext.RegisterUIInvokeListener(object, name, handler, type) end

--- Registers a listener that is called when the specified method is called on the main timeline of the Flash object
--- The event is triggered for every UI element with the specified type ID.
--- @param typeId number Engine UI element type ID
--- @param name string Flash method name
--- @param handler UICallbackHandler Lua handler
--- @param type UICallbackEventType|nil Event type - 'Before' or 'After'
function Ext.RegisterUITypeInvokeListener(typeId, name, handler, type) end

--- Registers a listener that is called when the specified method is called on the main timeline of the Flash object
--- The event is triggered regardless of which UI element it was called on.
--- @param name string Flash method name
--- @param handler UICallbackHandler Lua handler
--- @param type UICallbackEventType|nil Event type - 'Before' or 'After'
function Ext.RegisterUINameInvokeListener(name, handler, type) end

--- Registers a listener that is called when a console command is entered in the dev console
--- @param cmd string Console command
--- @param handler fun(cmd:string, ...:string)
function Ext.RegisterConsoleCommand(cmd, handler) end

--- @deprecated
--- Write data to an external (persistent) file
--- @param path string File path relative to Documents\Larian Studios\Divinity Original Sin 2 Definitive Edition\Osiris Data
--- @param contents string File contents to write
function Ext.SaveFile(path, contents) end

--- @deprecated
--- Read data from an external (persistent) file
--- @param path string File path relative to Documents\Larian Studios\Divinity Original Sin 2 Definitive Edition\Osiris Data
--- @param context string|nil Path context (nil or"user"means relative to the Osiris Data directory;"data"means relative to game data path)
--- @return string File contents
function Ext.LoadFile(path, context) end

--- @deprecated
--- Returns a monotonic value representing the current time in milliseconds.
--- Useful for performance measurements / measuring real world time.
--- (Note: This value is not synchronized between peers and different clients may report different time values!)
--- @return number Time
function Ext.MonotonicTime() end

--- @deprecated
--- Returns whether the player has a compatible Script Extender version installed
--- @param playerGuid string UUID of player character
--- @return boolean
function Ext.PlayerHasExtender(playerGuid) end

--- @deprecated
--- Returns information about current mouse position and hovered objects
--- @return EclPickingState
function Ext.GetPickingState() end

--- @deprecated
--- Triggers a breakpoint in the Lua debugger.
--- If no debugger is connected, the function does nothing.
function Ext.DebugBreak() end

--- @deprecated
--- Handle to double conversion hack for use in Flash external interface calls
--- (Some of the builtin functions treat handles as double values)
--- @param handle ObjectHandle|StatusHandle Handle to cast
--- @return number Double handle
function Ext.HandleToDouble(handle) end

--- @deprecated
--- Double to handle conversion hack for use in Flash external interface calls
--- (Some of the builtin functions treat handles as double values)
--- @param handle number Double handle to cast
--- @return ObjectHandle|StatusHandle
function Ext.DoubleToHandle(handle) end

--#endregion



--#region Flash Types

--- Represents an object in Flash.
--- Implements the __index and __newindex metamethods using string keys (i.e. allows table-like behavior):
--- obj.field = 123 -- Can assign values to any object property
--- Ext.Print(obj.field) -- Can read any object property
--- Field values are returned using the appropriate Lua type;
--- Flash Boolean/Number/string = Lua boolean/number/string
--- Flash Object = Lua engine class FlashObject
--- Flash array = Lua engine class FlashArray
--- Flash function = Lua engine class FlashFunction
--- @class FlashObject

--- Represents an array in Flash that begins at index 0.
--- Implements the __index, __newindex and __len metamethods using integer keys (i.e. allows table-like behavior):
--- arr[2] = 123 -- Can assign values to any array index
--- Ext.Print(arr[2]) -- Can read any array index
--- Ext.Print(#arr) -- Can query length of array
--- @class FlashArray<T>: { [integer]: T }

--- Represents a function or method in Flash.
--- Implements the __call metamethod (i.e. can be called).
--- The passed arguments are forwarded to the Flash method and the return value of the Flash method is returned.
--- @class FlashFunction

--- @class FlashEventDispatcher:FlashObject

--- Currently unsupported type 12.
--- @class FlashDisplayObject:FlashEventDispatcher

--- @class FlashInteractiveObject:FlashDisplayObject
--- @field doubleClickEnabled boolean Specifies whether the object receives doubleClick events.
--- @field mouseEnabled boolean Specifies whether this object receives mouse, or other user input, messages.
--- @field tabEnabled boolean Specifies whether this object is in the tab order.
--- @field tabIndex integer Specifies the tab ordering of objects in a SWF file.

--- @class FlashBitmapData
--- @class FlashMatrix
--- @class FlashVector
--- @class FlashTextSnapshot
--- @class FlashPoint
--- @class FlashEvent
--- @class FlashMouseEvent

--- @class FlashGraphics:FlashObject
--- @field beginBitmapFill fun(bitmap:FlashBitmapData, matrix:FlashMatrix, repeat:boolean, smooth:boolean) Fills a drawing area with a bitmap image.
--- @field beginFill fun(color:integer, alpha:number) Specifies a simple one-color fill that subsequent calls to other Graphics methods (such as lineTo or drawCircle) use when drawing.
--- @field beginGradientFill fun(type:string, colors:FlashArray, alphas:FlashArray, ratios:FlashArray, matrix:FlashMatrix, spreadMethod:string, interpolationMethod:string, focalPointRatio:number) Specifies a gradient fill used by subsequent calls to other Graphics methods (such as lineTo or drawCircle) for the object.
--- @field clear function Clears the graphics that were drawn to this Graphics object, and resets fill and line style settings.
--- @field curveTo fun(controlX:number, controlY:number, anchorX:number, anchorY:number) Draws a quadratic Bezier curve using the current line style from the current drawing position to the control point specified.
--- @field drawCircle fun(x:number, y:number, radius:number) Draws a circle.
--- @field drawEllipse fun(x:number, y:number, width:number, height:number) Draws an ellipse.
--- @field drawPath fun(commands:FlashVector, data:FlashVector, winding:string) Submits a series of commands for drawing.
--- @field drawRect fun(x:number, y:number, width:number, height:number) Draws a rectangle.
--- @field drawRoundRect fun(x:number, y:number, width:number, height:number, ellipseWidth:number, ellipseHeight:number) Draws a rounded rectangle.
--- @field endFill function Applies a fill to the lines and curves that were added since the last call to beginFill, beginGradientFill, or beginBitmapFill methods.
--- @field lineGradientStyle fun(type:string, colors:FlashArray, alphas:FlashArray, ratios:FlashArray, matrix:FlashMatrix, spreadMethod:string, interpolationMethod:string, focalPointRatio:number) Specifies a gradient to use for the stroke when drawing lines.
--- @field lineStyle fun(thickness:number, color:integer, alpha:number, pixelHinting:boolean, scaleMode:string, caps:string, joints:string, miterLimit:number) Specifies a line style used for subsequent calls to Graphics methods such as the lineTo method or the drawCircle method.
--- @field lineTo fun(x:number, y:number) Draws a line using the current line style from the current drawing position.
--- @field moveTo fun(x:number, y:number) Moves the current drawing position,

--- @class FlashDisplayObjectContainer:FlashInteractiveObject
--- @field mouseChildren boolean Determines whether or not the children of the object are mouse, or user input device, enabled.
--- @field numChildren integer Returns the number of children of this object. [read-only]
--- @field tabChildren boolean Determines whether the children of the object are tab enabled.
--- @field textSnapshot FlashTextSnapshot Returns a TextSnapshot object for this DisplayObjectContainer instance. [read-only]
--- @field addChild fun(child:FlashDisplayObject):FlashDisplayObject Adds a child DisplayObject instance to this DisplayObjectContainer instance.
--- @field addChildAt fun(child:FlashDisplayObject, index:integer):FlashDisplayObject Adds a child DisplayObject instance to this DisplayObjectContainer instance.
--- @field areInaccessibleObjectsUnderPoint fun(point:FlashPoint):boolean Indicates whether the security restrictions would cause any display objects to be omitted from the list returned by calling the DisplayObjectContainer.getObjectsUnderPoint() method with the specified point point.
--- @field contains fun(child:FlashDisplayObject):boolean Determines whether the specified display object is a child of the DisplayObjectContainer instance or the instance itself.
--- @field getChildAt fun(index:integer):FlashDisplayObject Returns the child display object instance that exists at the specified index.
--- @field getChildByName fun(name:string):FlashDisplayObject Returns the child display object that exists with the specified name.
--- @field getChildIndex fun(child:FlashDisplayObject):integer Returns the index position of a child DisplayObject instance.
--- @field getObjectsUnderPoint fun(point:FlashPoint):table Returns an array of objects that lie under the specified point and are children (or grandchildren, and so on) of this DisplayObjectContainer instance.
--- @field removeChild fun(child:FlashDisplayObject):FlashDisplayObject Removes the specified child DisplayObject instance from the child list of the DisplayObjectContainer instance.
--- @field removeChildAt fun(index:integer):FlashDisplayObject Removes a child DisplayObject from the specified index position in the child list of the DisplayObjectContainer.
--- @field removeChildren fun(beginIndex:integer, endIndex:integer) Removes all child DisplayObject instances from the child list of the DisplayObjectContainer instance.
--- @field setChildIndex fun(child:FlashDisplayObject, index:integer) Changes the position of an existing child in the display object container.
--- @field swapChildren fun(child1:FlashDisplayObject, child2:FlashDisplayObject) Swaps the z-order (front-to-back order) of the two specified child objects.
--- @field swapChildrenAt fun(index1:integer, index2:integer) Swaps the z-order (front-to-back order) of the child objects at the two specified index positions in the child list.

--- @class FlashSprite:FlashDisplayObjectContainer
--- @field buttonMode boolean Specifies the button mode of this sprite.
--- @field graphics FlashGraphics Specifies the Graphics object that belongs to this sprite where vector drawing commands can occur. [read-only]
--- @field soundTransform number Controls sound within this sprite.
--- @field useHandCursor boolean A value that indicates whether the pointing hand (hand cursor) appears when the pointer rolls over a sprite in which the buttonMode property is set to true.

--- @class FlashMovieClip:FlashSprite
--- @field currentFrame integer Specifies the number of the frame in which the playhead is located in the timeline of the MovieClip instance. [read-only]
--- @field currentFrameLabel string The label at the current frame in the timeline of the MovieClip instance. [read-only]
--- @field currentLabel string The current label in which the playhead is located in the timeline of the MovieClip instance. [read-only]
--- @field currentLabels string[] Returns an array of FrameLabel objects from the current scene. [read-only]
--- @field currentScene FlashObject The current scene in which the playhead is located in the timeline of the MovieClip instance. [read-only]
--- @field scenes FlashArray[] An array of Scene objects, each listing the name, the number of frames, and the frame labels for a scene in the MovieClip instance. [read-only]
--- @field enabled boolean A Boolean value that indicates whether a movie clip is enabled.
--- @field framesLoaded integer The number of frames that are loaded from a streaming SWF file. [read-only]
--- @field isPlaying boolean A Boolean value that indicates whether a movie clip is curently playing. [read-only]
--- @field totalFrames integer The total number of frames in the MovieClip instance. [read-only]
--- @field trackAsMenu boolean Indicates whether other display objects that are SimpleButton or MovieClip objects can receive mouse release events or other user input release events.
--- @field gotoAndPlay fun(frame:string|integer, scene:string|nil) Starts playing the SWF file at the specified frame.
--- @field gotoAndStop fun(frame:string|integer, scene:string|nil) Brings the playhead to the specified frame of the movie clip and stops it there.
--- @field nextFrame function Sends the playhead to the next frame and stops it.
--- @field nextScene function Moves the playhead to the next scene of the MovieClip instance.
--- @field play function Moves the playhead in the timeline of the movie clip.
--- @field prevFrame function Sends the playhead to the previous frame and stops it.
--- @field prevScene function Moves the playhead to the previous scene of the MovieClip instance.
--- @field stop function Stops the playhead in the movie clip.
--- @field hitTest fun(x:number, y:number, shapeFlag:boolean|nil):boolean

--- @class FlashMainTimeline:FlashMovieClip
--- @field events string[] An array of input keys this UI should listen for, in the form of 'IE Name', such as 'IE UICreationTabPrev'. The engine will invoke onEventDown/onEventUp when these keys are pressed, if they haven't been handled.
--- @field onEventDown fun(id:number):boolean Invoked by the engine when a valid input key in this.events is pressed. If true is returned, the key is"handled"and won't send events to other UI objects.
--- @field onEventUp fun(id:number):boolean Invoked by the engine when a valid input key in this.events is released. If true is returned, the key is"handled"and won't send events to other UI objects.
--- @field onEventResolution fun(width:number, height:number) Invoked by the engine when the screen is resized.
--- @field onEventInit function Invoked by the engine. Typically used to register the anchor id and layout with ExternalInterface.call.

--#endregion



--#region Osiris Calls

--- @param Character string
--- @param Talent string
function Osi.CharacterAddTalent(Character, Talent) end
	
--- @param Character string
--- @param Talent string
function Osi.CharacterRemoveTalent(Character, Talent) end
	
--- @param Character string
function Osi.CharacterFreeze(Character) end
	
--- @param Character string
function Osi.CharacterUnfreeze(Character) end
	
--- @param Trigger string
--- @param TemplateId string
--- @param PlaySpawn integer
function Osi.CharacterCreateAtTrigger(Trigger, TemplateId, PlaySpawn) end
	
--- @param Trigger string
--- @param TemplateId string
--- @param PlaySpawn integer
function Osi.TemporaryCharacterCreateAtTrigger(Trigger, TemplateId, PlaySpawn) end
	
--- @param Character string
--- @param Message string
function Osi.OpenMessageBox(Character, Message) end
	
--- @param Character string
--- @param Message string
function Osi.OpenMessageBoxYesNo(Character, Message) end
	
--- @param Character string
--- @param Message string
--- @param Choice_1 string
--- @param Choice_2 string
function Osi.OpenMessageBoxChoice(Character, Message, Choice_1, Choice_2) end
	
--- @param Character string
function Osi.ShowCredits(Character) end
	
--- @param Character string
--- @param MaxRange number
--- @param Event string
function Osi.TeleportToRandomPosition(Character, MaxRange, Event) end
	
--- @param SourceObject string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Event string
--- @param TeleportLinkedCharacters integer
--- @param ExcludePartyFollowers integer
function Osi.TeleportToPosition(SourceObject, X, Y, Z, Event, TeleportLinkedCharacters, ExcludePartyFollowers) end
	
--- @param SourceObject string
--- @param TargetObject string
--- @param Event string
--- @param TeleportLinkedCharacters integer
--- @param ExcludePartyFollowers integer
--- @param LeaveCombat integer
function Osi.TeleportTo(SourceObject, TargetObject, Event, TeleportLinkedCharacters, ExcludePartyFollowers, LeaveCombat) end
	
--- @param Character string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Running integer
--- @param Event string
function Osi.CharacterMoveToPosition(Character, X, Y, Z, Running, Event) end
	
--- @param Character string
--- @param Target string
--- @param Running integer
--- @param Event string
--- @param IncreaseSpeed integer
function Osi.CharacterMoveTo(Character, Target, Running, Event, IncreaseSpeed) end
	
--- @param Character string
--- @param Trigger string
--- @param SnapToTarget integer
function Osi.CharacterLookFromTrigger(Character, Trigger, SnapToTarget) end
	
--- @param Character string
--- @param Item string
function Osi.CharacterEquipItem(Character, Item) end
	
--- @param Character string
--- @param ToCharacter string
function Osi.TransferItemsToCharacter(Character, ToCharacter) end
	
--- @param Character string
function Osi.TransferItemsToParty(Character) end
	
--- @param Character string
function Osi.TransferItemsToUser(Character) end
	
--- @param Character string
--- @param Item string
function Osi.CharacterUnequipItem(Character, Item) end
	
--- @param Character string
--- @param ToCharacter string
function Osi.CharacterFollowCharacter(Character, ToCharacter) end
	
--- @param Character string
function Osi.CharacterStopFollow(Character) end
	
--- @param Character string
function Osi.CharacterClearFollow(Character) end
	
--- @param Trigger string
--- @param Event string
--- @param Movie string
function Osi.CharacterTeleportPartiesToTriggerWithMovie(Trigger, Event, Movie) end
	
--- @param Trigger string
--- @param Event string
function Osi.CharacterTeleportPartiesToTriggerWithMovieRequestCallback(Trigger, Event) end
	
--- @param UserId integer
--- @param Movie string
function Osi.CharacterSetTeleportMovie(UserId, Movie) end
	
--- @param Trigger string
--- @param Event string
function Osi.CharacterTeleportPartiesToTrigger(Trigger, Event) end
	
--- @param Character string
function Osi.CharacterClearTradeGeneratedItems(Character) end
	
--- @param Character string
--- @param Treasure string
function Osi.CharacterSetCustomTradeTreasure(Character, Treasure) end
	
--- @param Player string
--- @param Trader string
function Osi.GenerateItems(Player, Trader) end
	
--- @param Player string
--- @param Treasure string
--- @param Identified integer
function Osi.CharacterGiveReward(Player, Treasure, Identified) end
	
--- @param Player string
--- @param Quest string
--- @param RewardState string
function Osi.CharacterGiveQuestReward(Player, Quest, RewardState) end
	
--- @param Character string
--- @param GenerateTreasure integer
--- @param DeathType string
--- @param Source string
function Osi.CharacterDie(Character, GenerateTreasure, DeathType, Source) end
	
--- @param Character string
--- @param GenerateTreasure integer
--- @param DeathType string
--- @param Source string
function Osi.CharacterDieImmediate(Character, GenerateTreasure, DeathType, Source) end
	
--- @param Character string
--- @param SurfaceType string
function Osi.CharacterSetCustomBloodSurface(Character, SurfaceType) end
	
--- @param Character string
--- @param Skill string
--- @param ShowNotification integer
function Osi.CharacterAddSkill(Character, Skill, ShowNotification) end
	
--- @param Character string
--- @param Skill string
function Osi.CharacterRemoveSkill(Character, Skill) end
	
--- @param Character string
--- @param Amount integer
function Osi.CharacterAddAttributePoint(Character, Amount) end
	
--- @param Character string
--- @param Amount integer
function Osi.CharacterAddAbilityPoint(Character, Amount) end
	
--- @param Character string
--- @param Amount integer
function Osi.CharacterAddCivilAbilityPoint(Character, Amount) end
	
--- @param Character string
--- @param Amount integer
function Osi.CharacterAddActionPoints(Character, Amount) end
	
--- @param Character string
--- @param Amount integer
function Osi.CharacterAddTalentPoint(Character, Amount) end
	
--- @param Character string
function Osi.CharacterResurrect(Character) end
	
--- @param Character string
function Osi.CharacterResurrectAndResetXPReward(Character) end
	
--- @param Character string
--- @param ResurrectAnimation string
function Osi.CharacterResurrectCustom(Character, ResurrectAnimation) end
	
--- @param Character string
--- @param Count integer
function Osi.CharacterAddGold(Character, Count) end
	
--- @param Character string
--- @param Count integer
function Osi.PartyAddGold(Character, Count) end
	
--- @param Character string
--- @param Count integer
function Osi.UserAddGold(Character, Count) end
	
--- @param Character string
--- @param Id string
function Osi.CharacterIncreaseSocialStat(Character, Id) end
	
--- @param Character string
--- @param Id string
function Osi.CharacterDecreaseSocialStat(Character, Id) end
	
--- @param Character string
--- @param Spectating integer
function Osi.CharacterSetSpectating(Character, Spectating) end
	
--- @param Character string
--- @param Text string
function Osi.CharacterSetCustomName(Character, Text) end
	
--- @param Character string
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppear(Character, PlaySpawn, Event) end
	
--- @param Character string
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearCustom(Character, Animation, Event) end
	
--- @param Character string
--- @param Target string
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppearAt(Character, Target, PlaySpawn, Event) end
	
--- @param Character string
--- @param Target string
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearAtCustom(Character, Target, Animation, Event) end
	
--- @param Character string
--- @param X number
--- @param Y number
--- @param Z number
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppearAtPosition(Character, X, Y, Z, PlaySpawn, Event) end
	
--- @param Character string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearAtPositionCustom(Character, X, Y, Z, Animation, Event) end
	
--- @param Character string
--- @param Target string
--- @param Angle integer
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppearOutOfSightTo(Character, Target, Angle, PlaySpawn, Event) end
	
--- @param Character string
--- @param Target string
--- @param Angle integer
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearOutOfSightToCustom(Character, Target, Angle, Animation, Event) end
	
--- @param Character string
--- @param Target string
--- @param Object string
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppearOutOfSightToObject(Character, Target, Object, PlaySpawn, Event) end
	
--- @param Character string
--- @param Target string
--- @param Object string
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearOutOfSightToObjectCustom(Character, Target, Object, Animation, Event) end
	
--- @param Character string
--- @param Target string
--- @param Angle integer
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppearOnTrailOutOfSightTo(Character, Target, Angle, PlaySpawn, Event) end
	
--- @param Character string
--- @param Target string
--- @param Angle integer
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearOnTrailOutOfSightToCustom(Character, Target, Angle, Animation, Event) end
	
--- @param Character string
--- @param Target string
--- @param Object string
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppearOnTrailOutOfSightToObject(Character, Target, Object, PlaySpawn, Event) end
	
--- @param Character string
--- @param Target string
--- @param Object string
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearOnTrailOutOfSightToObjectCustom(Character, Target, Object, Animation, Event) end
	
--- @param Character string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Angle integer
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppearAtPositionOutOfSightTo(Character, X, Y, Z, Angle, PlaySpawn, Event) end
	
--- @param Character string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Angle integer
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearAtPositionOutOfSightToCustom(Character, X, Y, Z, Angle, Animation, Event) end
	
--- @param Character string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Object string
--- @param PlaySpawn integer
--- @param Event string
function Osi.CharacterAppearAtPositionOutOfSightToObject(Character, X, Y, Z, Object, PlaySpawn, Event) end
	
--- @param Character string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Object string
--- @param Animation string
--- @param Event string
function Osi.CharacterAppearAtPositionOutOfSightToObjectCustom(Character, X, Y, Z, Object, Animation, Event) end
	
--- @param Character string
--- @param Angle integer
--- @param Running integer
--- @param Event string
--- @param IncreaseSpeed integer
function Osi.CharacterDisappearOutOfSight(Character, Angle, Running, Event, IncreaseSpeed) end
	
--- @param Character string
--- @param Object string
--- @param Running integer
--- @param Event string
--- @param IncreaseSpeed integer
function Osi.CharacterDisappearOutOfSightToObject(Character, Object, Running, Event, IncreaseSpeed) end
	
--- @param Character string
--- @param Event string
function Osi.CharacterFleeOutOfSight(Character, Event) end
	
--- @param Character string
--- @param Target string
function Osi.CharacterAttack(Character, Target) end
	
--- @param TargetCharacter string
--- @param OwnerCharacter string
function Osi.CharacterMakePlayer(TargetCharacter, OwnerCharacter) end
	
--- @param Character string
--- @param Character2 string
function Osi.CharacterRecruitCharacter(Character, Character2) end
	
--- @param UserID integer
function Osi.CharacterAssign(UserID) end
	
--- @param UserID integer
--- @param Character string
function Osi.CharacterAssignToUser(UserID, Character) end
	
--- @param Character string
--- @param Character2 string
function Osi.CharacterMakeCompanion(Character, Character2) end
	
--- @param Character string
function Osi.CharacterMakeNPC(Character) end
	
--- @param Character string
--- @param Character2 string
function Osi.CharacterAddToParty(Character, Character2) end
	
--- @param Character string
function Osi.CharacterRemoveFromParty(Character) end
	
--- @param Character string
--- @param Owner string
function Osi.CharacterAddToPlayerCharacter(Character, Owner) end
	
--- @param Character string
--- @param Owner string
function Osi.CharacterRemoveFromPlayerCharacter(Character, Owner) end
	
--- @param Character string
function Osi.CharacterRemoveAllPartyFollowers(Character) end
	
--- @param Character string
--- @param OtherCharacter string
--- @param Relation integer
function Osi.CharacterSetRelationIndivFactionToIndivFaction(Character, OtherCharacter, Relation) end
	
--- @param Character string
--- @param OtherFaction string
--- @param Relation integer
function Osi.CharacterSetRelationIndivFactionToFaction(Character, OtherFaction, Relation) end
	
--- @param Faction string
--- @param OtherCharacter string
--- @param Relation integer
function Osi.CharacterSetRelationFactionToIndivFaction(Faction, OtherCharacter, Relation) end
	
--- @param Faction string
--- @param otherFaction string
--- @param Relation integer
function Osi.CharacterSetRelationFactionToFaction(Faction, otherFaction, Relation) end
	
--- @param Character string
--- @param OtherCharacter string
function Osi.CharacterSetTemporaryHostileRelation(Character, OtherCharacter) end
	
--- @param Character string
--- @param Reaction string
--- @param Priority integer
function Osi.CharacterSetReactionPriority(Character, Reaction, Priority) end
	
--- @param Character string
--- @param Percentage number
function Osi.CharacterSetHitpointsPercentage(Character, Percentage) end
	
--- @param Character string
--- @param Percentage number
function Osi.CharacterSetArmorPercentage(Character, Percentage) end
	
--- @param Character string
--- @param Percentage number
function Osi.CharacterSetMagicArmorPercentage(Character, Percentage) end
	
--- @param Character string
--- @param Target string
--- @param SnapToTarget integer
function Osi.CharacterLookAt(Character, Target, SnapToTarget) end
	
--- @param Character string
function Osi.CharacterLevelUp(Character) end
	
--- @param Character string
--- @param Level integer
function Osi.CharacterLevelUpTo(Character, Level) end
	
--- @param Character string
--- @param XP integer
function Osi.PartyAddActualExperience(Character, XP) end
	
--- @param Character string
--- @param Act integer
--- @param ActPart integer
--- @param Gain integer
function Osi.PartyAddExperience(Character, Act, ActPart, Gain) end
	
--- @param Character string
--- @param Act integer
--- @param ActPart integer
--- @param Gain integer
function Osi.PartyAddExplorationExperience(Character, Act, ActPart, Gain) end
	
--- @param Character string
--- @param Act integer
--- @param ActPart integer
--- @param Gain integer
function Osi.CharacterAddExplorationExperience(Character, Act, ActPart, Gain) end
	
--- @param Character string
--- @param Act integer
--- @param ActPart integer
--- @param Gain integer
function Osi.PartyAddCharismaExperience(Character, Act, ActPart, Gain) end
	
--- @param Character string
--- @param Text string
function Osi.CharacterStatusText(Character, Text) end
	
--- @param Character string
--- @param Text string
function Osi.CharacterEnteredSubRegion(Character, Text) end
	
--- @param Character string
--- @param Text string
--- @param Parameter integer
function Osi.CharacterDisplayTextWithParam(Character, Text, Parameter) end
	
--- @param Character string
--- @param Bool integer
function Osi.CharacterSetImmortal(Character, Bool) end
	
--- @param Character string
function Osi.CharacterFlushQueue(Character) end
	
--- @param Character string
function Osi.CharacterPurgeQueue(Character) end
	
--- @param Event string
function Osi.CharacterLaunchIterator(Event) end
	
--- @param Center string
--- @param Radius number
--- @param Event string
function Osi.CharacterLaunchIteratorAroundObject(Center, Radius, Event) end
	
--- @param Event string
function Osi.CharacterLaunchOsirisOnlyIterator(Event) end
	
--- @param Trader string
--- @param Bool integer
function Osi.CharacterSetCanTrade(Trader, Bool) end
	
--- @param Character string
function Osi.CharacterSetStill(Character) end
	
--- @param Character string
--- @param Enabled integer
--- @param Immediately integer
function Osi.CharacterSetFightMode(Character, Enabled, Immediately) end
	
--- @param Character string
--- @param Bool integer
function Osi.CharacterMakeStoryNpc(Character, Bool) end
	
--- @param Character string
--- @param FxName string
function Osi.CharacterStopAllEffectsWithName(Character, FxName) end
	
--- @param Character string
--- @param Item string
--- @param Event string
function Osi.CharacterPickupItem(Character, Item, Event) end
	
--- @param Character string
--- @param Item string
--- @param Event string
function Osi.CharacterItemSetEvent(Character, Item, Event) end
	
--- @param Character string
--- @param Character2 string
--- @param Event string
function Osi.CharacterCharacterSetEvent(Character, Character2, Event) end
	
--- @param Character string
--- @param Item string
--- @param Event string
function Osi.CharacterUseItem(Character, Item, Event) end
	
--- @param Character string
--- @param Item string
--- @param Trigger string
--- @param Amount integer
--- @param Event string
function Osi.CharacterMoveItemToTrigger(Character, Item, Trigger, Amount, Event) end
	
--- @param Character string
--- @param ConsumeHandle integer
function Osi.CharacterUnconsume(Character, ConsumeHandle) end
	
--- @param Character string
--- @param Attribute string
--- @param Value integer
function Osi.CharacterAddAttribute(Character, Attribute, Value) end
	
--- @param Character string
--- @param Attribute string
--- @param Value integer
function Osi.CharacterRemoveAttribute(Character, Attribute, Value) end
	
--- @param Character string
--- @param Ability string
--- @param Value integer
function Osi.CharacterAddAbility(Character, Ability, Value) end
	
--- @param Character string
--- @param Ability string
--- @param Value integer
function Osi.CharacterRemoveAbility(Character, Ability, Value) end
	
--- @param Player string
--- @param Trader string
--- @param CanRepair integer
--- @param CanIdentify integer
--- @param CanSell integer
function Osi.ActivateTrade(Player, Trader, CanRepair, CanIdentify, CanSell) end
	
--- @param Player string
--- @param NPC string
--- @param Success integer
function Osi.StartPickpocket(Player, NPC, Success) end
	
--- @param Character string
--- @param Deal integer
--- @param AttitudeDiff integer
function Osi.ExecuteDeal(Character, Deal, AttitudeDiff) end
	
--- @param Character string
--- @param CharacterToFollow string
function Osi.CharacterSetFollowCharacter(Character, CharacterToFollow) end
	
--- @param Src string
--- @param Target string
function Osi.CharacterAttachToGroup(Src, Target) end
	
--- @param Character string
function Osi.CharacterDetachFromGroup(Character) end
	
--- @param Character string
--- @param Player string
--- @param Delta integer
function Osi.CharacterAddAttitudeTowardsPlayer(Character, Player, Delta) end
	
--- @param Character string
--- @param CanSpotSneakers integer
function Osi.CharacterSetCanSpotSneakers(Character, CanSpotSneakers) end
	
--- @param Character string
--- @param Container string
function Osi.CharacterMoveWeaponsToContainer(Character, Container) end
	
--- @param Character string
--- @param Ability string
function Osi.CharacterLockAbility(Character, Ability) end
	
--- @param Character string
--- @param Ability string
function Osi.CharacterUnlockAbility(Character, Ability) end
	
--- @param Character string
--- @param RecipeID string
--- @param ShowNotification integer
function Osi.CharacterUnlockRecipe(Character, RecipeID, ShowNotification) end
	
--- @param Character string
--- @param Animation string
function Osi.CharacterSetAnimationOverride(Character, Animation) end
	
--- @param Character string
--- @param AnimationSetResource string
function Osi.CharacterSetAnimationSetOverride(Character, AnimationSetResource) end
	
--- @param Character string
--- @param PartyMember string
--- @param Modifier integer
function Osi.PartySetIdentifyPriceModifier(Character, PartyMember, Modifier) end
	
--- @param Character string
--- @param PartyMember string
--- @param Modifier integer
function Osi.PartySetRepairPriceModifier(Character, PartyMember, Modifier) end
	
--- @param Character string
--- @param PartyMember string
--- @param Modifier integer
function Osi.PartySetShopPriceModifier(Character, PartyMember, Modifier) end
	
--- @param Character string
--- @param Tag string
--- @param Modifier integer
function Osi.SetTagPriceModifier(Character, Tag, Modifier) end
	
--- @param Character string
function Osi.CharacterResetCooldowns(Character) end
	
--- @param Character string
--- @param VisualSlot integer
--- @param ElementName string
function Osi.CharacterSetVisualElement(Character, VisualSlot, ElementName) end
	
--- @param Character string
--- @param Type integer
--- @param UIInstance string
function Osi.CharacterShowStoryElementUI(Character, Type, UIInstance) end
	
--- @param Character string
--- @param Type integer
--- @param UIInstance string
function Osi.CharacterCloseStoryElementUI(Character, Type, UIInstance) end
	
--- @param Character string
--- @param Turn integer
function Osi.CharacterSendGlobalCombatCounter(Character, Turn) end
	
--- @param Character string
--- @param Sound string
function Osi.CharacterPlayHUDSound(Character, Sound) end
	
--- @param Character string
--- @param SoundResource string
function Osi.CharacterPlayHUDSoundResource(Character, SoundResource) end
	
--- @param Player string
--- @param CrimeType string
--- @param Evidence string
--- @param Witness string
--- @param CrimeID integer
function Osi.CharacterRegisterCrime(Player, CrimeType, Evidence, Witness, CrimeID) end
	
--- @param Player string
--- @param CrimeType string
--- @param Evidence string
--- @param Witness string
--- @param X number
--- @param Y number
--- @param Z number
--- @param CrimeID integer
function Osi.CharacterRegisterCrimeWithPosition(Player, CrimeType, Evidence, Witness, X, Y, Z, CrimeID) end
	
--- @param Player string
--- @param CrimeType string
--- @param Evidence string
function Osi.CharacterStopCrime(Player, CrimeType, Evidence) end
	
--- @param Player string
--- @param Crime integer
function Osi.CharacterStopCrimeWithID(Player, Crime) end
	
--- @param Character string
--- @param Player string
--- @param Timer number
function Osi.CharacterIgnoreCharacterActiveCrimes(Character, Player, Timer) end
	
--- @param Character string
--- @param Die integer
function Osi.CharacterRemoveSummons(Character, Die) end
	
--- @param Character string
--- @param Ghost string
function Osi.CharacterLinkGhost(Character, Ghost) end
	
--- @param Character string
--- @param Ghost string
function Osi.CharacterUnlinkGhost(Character, Ghost) end
	
--- @param Ghost string
function Osi.DestroyGhost(Ghost) end
	
--- @param Character string
--- @param SkillID string
--- @param Target string
--- @param ForceResetCooldown integer
--- @param IgnoreHasSkill integer
--- @param IgnoreChecks integer
function Osi.CharacterUseSkill(Character, SkillID, Target, ForceResetCooldown, IgnoreHasSkill, IgnoreChecks) end
	
--- @param Character string
--- @param SkillID string
--- @param X number
--- @param Y number
--- @param Z number
--- @param ForceResetCooldown integer
--- @param IgnoreHasSkill integer
function Osi.CharacterUseSkillAtPosition(Character, SkillID, X, Y, Z, ForceResetCooldown, IgnoreHasSkill) end
	
--- @param Character string
--- @param Crime string
function Osi.CharacterDisableCrime(Character, Crime) end
	
--- @param Character string
--- @param Crime string
function Osi.CharacterEnableCrime(Character, Crime) end
	
--- @param Character string
function Osi.CharacterDisableAllCrimes(Character) end
	
--- @param Character string
function Osi.CharacterEnableAllCrimes(Character) end
	
--- @param Character string
--- @param Enable integer
function Osi.CharacterEnableCrimeWarnings(Character, Enable) end
	
--- @param Player string
function Osi.CharacterRemoveTension(Player) end
	
--- @param Character string
--- @param Amount integer
function Osi.CharacterAddSourcePoints(Character, Amount) end
	
--- @param Character string
--- @param Amount integer
function Osi.CharacterOverrideMaxSourcePoints(Character, Amount) end
	
--- @param Character string
function Osi.CharacterRemoveMaxSourcePointsOverride(Character) end
	
--- @param Character string
--- @param Preset string
function Osi.CharacterApplyPreset(Character, Preset) end
	
--- @param Character string
--- @param Preset string
function Osi.CharacterApplyHenchmanPreset(Character, Preset) end
	
--- @param Character string
--- @param Preset string
function Osi.CharacterApplyRacePreset(Character, Preset) end
	
--- @param Character string
--- @param Target string
--- @param DialogID string
--- @param IsAutomated integer
--- @param MoveID string
--- @param Running integer
--- @param Timeout number
function Osi.CharacterMoveToAndTalk(Character, Target, DialogID, IsAutomated, MoveID, Running, Timeout) end
	
--- @param Character string
--- @param Target string
--- @param MoveId string
function Osi.CharacterMoveToAndTalkRequestDialogFailed(Character, Target, MoveId) end
	
--- @param Character string
--- @param Bool integer
function Osi.CharacterEnableWaypointUsage(Character, Bool) end
	
--- @param Character string
--- @param Race string
function Osi.CharacterReservePolymorphShape(Character, Race) end
	
--- @param Character string
--- @param Bool integer
function Osi.CharacterSetForceSynch(Character, Bool) end
	
--- @param Character string
--- @param Bool integer
function Osi.CharacterSetForceUpdate(Character, Bool) end
	
--- @param Character string
--- @param ObjectTemplate string
--- @param ReplaceScripts integer
--- @param ReplaceScale integer
--- @param ReplaceStats integer
--- @param ReplaceEquipment integer
--- @param ReplaceSkills integer
--- @param UseCustomLooks integer
--- @param ReleasePlayerData integer
function Osi.CharacterTransform(Character, ObjectTemplate, ReplaceScripts, ReplaceScale, ReplaceStats, ReplaceEquipment, ReplaceSkills, UseCustomLooks, ReleasePlayerData) end
	
--- @param Target string
--- @param Source string
--- @param ReplaceScripts integer
--- @param ReplaceScale integer
--- @param ReplaceStats integer
--- @param ReplaceEquipment integer
--- @param ReplaceSkills integer
--- @param UseCustomLooks integer
--- @param ReleasePlayerData integer
function Osi.CharacterTransformFromCharacter(Target, Source, ReplaceScripts, ReplaceScale, ReplaceStats, ReplaceEquipment, ReplaceSkills, UseCustomLooks, ReleasePlayerData) end
	
--- @param Character string
--- @param Target string
--- @param CopyEquipment integer
--- @param CopyDisplayNameAndIcon integer
function Osi.CharacterTransformAppearanceTo(Character, Target, CopyEquipment, CopyDisplayNameAndIcon) end
	
--- @param Character string
--- @param Target string
--- @param EquipmentSet string
--- @param CopyDisplayNameAndIcon integer
function Osi.CharacterTransformAppearanceToWithEquipmentSet(Character, Target, EquipmentSet, CopyDisplayNameAndIcon) end
	
--- @param Character string
--- @param Tag string
function Osi.CharacterReceivedTag(Character, Tag) end
	
--- @param Character string
--- @param Tag string
function Osi.CharacterAddPreferredAiTargetTag(Character, Tag) end
	
--- @param Character string
--- @param Tag string
function Osi.CharacterRemovePreferredAiTargetTag(Character, Tag) end
	
--- @param Character string
function Osi.CharacterOriginIntroStopped(Character) end
	
--- @param Character string
--- @param Value integer
function Osi.CharacterSetDoNotFaceFlag(Character, Value) end
	
--- @param Character string
--- @param Value integer
function Osi.CharacterSetReadyCheckBlocked(Character, Value) end
	
--- @param Character string
--- @param Value integer
function Osi.CharacterSetCorpseLootable(Character, Value) end
	
--- @param Character string
--- @param Value integer
function Osi.CharacterSetDetached(Character, Value) end
	
--- @param From string
--- @param To string
--- @param MemorizedOnly integer
function Osi.CharacterCloneSkillsTo(From, To, MemorizedOnly) end
	
--- @param Attacker string
--- @param Attacked string
--- @param MinDistance number
--- @param MaxDistance number
function Osi.CharacterJitterbugTeleport(Attacker, Attacked, MinDistance, MaxDistance) end
	
--- @param Character string
function Osi.RemoveTemporaryCharacter(Character) end
	
--- @param Target string
--- @param Owner string
function Osi.CharacterChangeToSummon(Target, Owner) end
	
--- @param Target string
--- @param Turns integer
function Osi.CharacterSetSummonLifetime(Target, Turns) end
	
--- @param Item string
--- @param Trigger string
function Osi.ItemDragToTrigger(Item, Trigger) end
	
--- @param Item string
--- @param X number
--- @param Y number
--- @param Z number
function Osi.ItemDragToPosition(Item, X, Y, Z) end
	
--- @param Item string
--- @param Trigger string
--- @param Speed number
--- @param Acceleration number
--- @param UseRotation integer
--- @param Event string
--- @param DoHits integer
function Osi.ItemMoveToTrigger(Item, Trigger, Speed, Acceleration, UseRotation, Event, DoHits) end
	
--- @param Item string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Speed number
--- @param Acceleration number
--- @param Event string
--- @param DoHits integer
function Osi.ItemMoveToPosition(Item, X, Y, Z, Speed, Acceleration, Event, DoHits) end
	
--- @param string string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Pitch number
--- @param Yaw number
--- @param Roll number
--- @param Amount integer
--- @param OwnerCharacter string
function Osi.ItemToTransform(string, X, Y, Z, Pitch, Yaw, Roll, Amount, OwnerCharacter) end
	
--- @param Item string
--- @param TargetObject string
--- @param Amount integer
--- @param ShowNotification integer
--- @param ClearOriginalOwner integer
function Osi.ItemToInventory(Item, TargetObject, Amount, ShowNotification, ClearOriginalOwner) end
	
--- @param ItemTemplate string
--- @param Character string
--- @param Count integer
function Osi.ItemTemplateDropFromCharacter(ItemTemplate, Character, Count) end
	
--- @param Item string
--- @param X number
--- @param Y number
--- @param Z number
function Osi.ItemScatterAt(Item, X, Y, Z) end
	
--- @param ItemTemplate string
--- @param Object string
--- @param Count integer
function Osi.ItemTemplateRemoveFrom(ItemTemplate, Object, Count) end
	
--- @param ItemTemplate string
--- @param Character string
--- @param Count integer
function Osi.ItemTemplateRemoveFromParty(ItemTemplate, Character, Count) end
	
--- @param ItemTemplate string
--- @param Character string
--- @param Count integer
function Osi.ItemTemplateRemoveFromUser(ItemTemplate, Character, Count) end
	
--- @param ItemTemplate string
--- @param Object string
--- @param Count integer
--- @param ShowNotification integer
function Osi.ItemTemplateAddTo(ItemTemplate, Object, Count, ShowNotification) end
	
--- @param Item string
function Osi.ItemDrop(Item) end
	
--- @param Item string
function Osi.ItemRemove(Item) end
	
--- @param FromObject string
--- @param ToObject string
--- @param MoveEquippedArmor integer
--- @param MoveEquippedWeapons integer
--- @param ClearOriginalOwner integer
function Osi.MoveAllItemsTo(FromObject, ToObject, MoveEquippedArmor, MoveEquippedWeapons, ClearOriginalOwner) end
	
--- @param FromContainer string
function Osi.ContainerIdentifyAll(FromContainer) end
	
--- @param Item string
--- @param Key string
function Osi.ItemLock(Item, Key) end
	
--- @param Item string
function Osi.ItemUnLock(Item) end
	
--- @param Item string
--- @param lock integer
function Osi.ItemLockUnEquip(Item, lock) end
	
--- @param Item string
--- @param IsPoisoned integer
function Osi.ItemIsPoisoned(Item, IsPoisoned) end
	
--- @param Item string
function Osi.ItemOpen(Item) end
	
--- @param Item string
function Osi.ItemClose(Item) end
	
--- @param Item string
function Osi.ItemDestroy(Item) end
	
--- @param Item string
function Osi.ItemClearOwner(Item) end
	
--- @param Item string
--- @param bool integer
function Osi.ItemSetCanInteract(Item, bool) end
	
--- @param Item string
--- @param bool integer
function Osi.ItemSetUseRemotely(Item, bool) end
	
--- @param Item string
--- @param bool integer
function Osi.ItemSetCanPickUp(Item, bool) end
	
--- @param Item string
--- @param bool integer
function Osi.ItemSetCanMove(Item, bool) end
	
--- @param Item string
--- @param NewOwner string
function Osi.ItemSetOwner(Item, NewOwner) end
	
--- @param Item string
--- @param NewOwner string
function Osi.ItemSetOriginalOwner(Item, NewOwner) end
	
--- @param Item string
--- @param bool integer
function Osi.ItemSetOnlyOwnerCanUse(Item, bool) end
	
--- @param Item string
--- @param bool integer
function Osi.ItemSetStoryItem(Item, bool) end
	
--- @param Event string
function Osi.ItemLaunchIterator(Event) end
	
--- @param Trigger string
--- @param TemplateId string
function Osi.ItemCreateAtTrigger(Trigger, TemplateId) end
	
--- @param Trigger string
--- @param TemplateId string
function Osi.CreateKickstarterMessageInABottleItemAtTrigger(Trigger, TemplateId) end
	
--- @param Item string
--- @param Angle number
--- @param Speed number
function Osi.ItemRotateY(Item, Angle, Speed) end
	
--- @param Item string
--- @param Angle number
--- @param Speed number
function Osi.ItemRotateToAngleY(Item, Angle, Speed) end
	
--- @param Item string
--- @param Angle number
--- @param Speed number
--- @param Animation string
--- @param Event string
function Osi.ItemRotateToAngleY_Animate(Item, Angle, Speed, Animation, Event) end
	
--- @param Item string
--- @param Charges integer
function Osi.ItemAddCharges(Item, Charges) end
	
--- @param Item string
function Osi.ItemResetChargesToMax(Item) end
	
--- @param Item string
--- @param Durability integer
function Osi.ItemSetDurability(Item, Durability) end
	
--- @param Item string
--- @param Bool integer
function Osi.ItemSetForceSynch(Item, Bool) end
	
--- @param Item string
--- @param Bool integer
function Osi.ItemSetKnown(Item, Bool) end
	
--- @param Item string
function Osi.ItemLevelUp(Item) end
	
--- @param Item string
--- @param Level integer
function Osi.ItemLevelUpTo(Item, Level) end
	
--- @param Character string
--- @param Item string
--- @param RuneTemplate string
--- @param Slot integer
function Osi.ItemInsertRune(Character, Item, RuneTemplate, Slot) end
	
--- @param Item string
--- @param Boost string
function Osi.ItemAddDeltaModifier(Item, Boost) end
	
--- @param Dialog string
--- @param Speaker string
function Osi.DialogRequestStopForDialog(Dialog, Speaker) end
	
--- @param Speaker string
function Osi.DialogRequestStop(Speaker) end
	
--- @param Flag string
function Osi.GlobalSetFlag(Flag) end
	
--- @param Flag string
function Osi.GlobalClearFlag(Flag) end
	
--- @param Target string
--- @param Flag string
--- @param DialogInstance integer
function Osi.ObjectSetFlag(Target, Flag, DialogInstance) end
	
--- @param Target string
--- @param Flag string
function Osi.ObjectShareFlag(Target, Flag) end
	
--- @param Flag string
function Osi.GlobalShareFlag(Flag) end
	
--- @param Target string
--- @param Flag string
--- @param DialogInstance integer
function Osi.ObjectClearFlag(Target, Flag, DialogInstance) end
	
--- @param Target string
--- @param Flag string
--- @param DialogInstance integer
function Osi.ObjectSetDialogFlag(Target, Flag, DialogInstance) end
	
--- @param Target string
--- @param Flag string
--- @param DialogInstance integer
function Osi.ObjectClearDialogFlag(Target, Flag, DialogInstance) end
	
--- @param Character string
--- @param Flag string
--- @param DialogInstance integer
function Osi.UserSetFlag(Character, Flag, DialogInstance) end
	
--- @param Character string
--- @param Flag string
--- @param DialogInstance integer
function Osi.UserClearFlag(Character, Flag, DialogInstance) end
	
--- @param Character string
--- @param Flag string
--- @param DialogInstance integer
function Osi.PartySetFlag(Character, Flag, DialogInstance) end
	
--- @param Character string
--- @param Flag string
--- @param DialogInstance integer
function Osi.PartyClearFlag(Character, Flag, DialogInstance) end
	
--- @param Character string
--- @param Location string
--- @param Question string
--- @param Answer string
function Osi.AddFeedbackString(Character, Location, Question, Answer) end
	

function Osi.SaveFeedback() end
	
--- @param Object string
--- @param FxName string
--- @param Bone string
function Osi.PlayEffect(Object, FxName, Bone) end
	
--- @param Object string
--- @param Target string
--- @param FxName string
--- @param SourceBone string
--- @param TargetBone string
function Osi.PlayBeamEffect(Object, Target, FxName, SourceBone, TargetBone) end
	
--- @param Object string
--- @param SoundEvent string
function Osi.PlaySound(Object, SoundEvent) end
	
--- @param Object string
--- @param SoundResource string
function Osi.PlaySoundResource(Object, SoundResource) end
	
--- @param Object string
--- @param Text string
function Osi.DebugText(Object, Text) end
	
--- @param Object string
--- @param Text string
function Osi.DisplayText(Object, Text) end
	
--- @param Object string
--- @param Bool integer
function Osi.SetOnStage(Object, Bool) end
	
--- @param Object string
--- @param Bool integer
function Osi.SetVisible(Object, Bool) end
	
--- @param Character string
--- @param MarkerID string
--- @param Show integer
function Osi.ShowMapMarker(Character, MarkerID, Show) end
	
--- @param MarkerID string
--- @param NewRegionID string
function Osi.MapMarkerChangeLevel(MarkerID, NewRegionID) end
	
--- @param Distance number
function Osi.SetCameraDistanceOverride(Distance) end
	
--- @param Timer string
--- @param Time2 integer
function Osi.TimerLaunch(Timer, Time2) end
	
--- @param Timer string
function Osi.TimerCancel(Timer) end
	
--- @param Timer string
function Osi.TimerPause(Timer) end
	
--- @param Timer string
function Osi.TimerUnpause(Timer) end
	
--- @param Character string
--- @param EventName string
function Osi.MusicPlayForPeer(Character, EventName) end
	
--- @param Character string
--- @param Character2 string
--- @param EventName string
function Osi.MusicPlayForPeerWithInstrument(Character, Character2, EventName) end
	
--- @param Character string
--- @param EventName string
function Osi.MusicPlayOnCharacter(Character, EventName) end
	
--- @param EventName string
function Osi.MusicPlayGeneral(EventName) end
	
--- @param Character string
--- @param Event string
function Osi.MoviePlay(Character, Event) end
	
--- @param Character string
--- @param DialogName string
--- @param NodePrefix string
function Osi.PlayMovieForDialog(Character, DialogName, NodePrefix) end
	
--- @param Character string
--- @param Name string
--- @param Time number
--- @param HideUI integer
--- @param Smooth integer
--- @param HideShroud integer
function Osi.CameraActivate(Character, Name, Time, HideUI, Smooth, HideShroud) end
	
--- @param Character string
--- @param Bool integer
function Osi.SetSelectorCameraMode(Character, Bool) end
	
--- @param Character string
--- @param Quest string
--- @param Status string
function Osi.QuestUpdate(Character, Quest, Status) end
	
--- @param SrcCharacter string
--- @param Character2 string
--- @param Quest string
--- @param Status string
function Osi.QuestReceiveSharedUpdate(SrcCharacter, Character2, Quest, Status) end
	
--- @param Character string
--- @param Quest string
function Osi.QuestAdd(Character, Quest) end
	
--- @param Character string
--- @param Quest string
function Osi.QuestClose(Character, Quest) end
	
--- @param Quest string
function Osi.QuestCloseAll(Quest) end
	
--- @param Character string
--- @param SubquestID string
--- @param ParentQuestID string
function Osi.QuestAddSubquest(Character, SubquestID, ParentQuestID) end
	
--- @param Target string
--- @param InArena integer
function Osi.SetInArena(Target, InArena) end
	
--- @param NotificationType integer
--- @param StringParam string
--- @param InNumberOfRounds integer
function Osi.SendArenaNotification(NotificationType, StringParam, InNumberOfRounds) end
	
--- @param Quest string
--- @param CategoryID string
function Osi.QuestSetCategory(Quest, CategoryID) end
	
--- @param Character string
--- @param Quest string
--- @param DoArchive integer
function Osi.QuestArchive(Character, Quest, DoArchive) end
	
--- @param Character string
--- @param CategoryID string
--- @param DoArchive integer
function Osi.QuestArchiveCategory(Character, CategoryID, DoArchive) end
	
--- @param Character string
--- @param Secret string
function Osi.AddSecret(Character, Secret) end
	
--- @param RecipeID string
function Osi.UnlockJournalRecipe(RecipeID) end
	
--- @param Character string
--- @param MysteryID string
function Osi.UnlockJournalMystery(Character, MysteryID) end
	
--- @param Character string
--- @param MysteryID string
function Osi.CloseJournalMystery(Character, MysteryID) end
	

function Osi.GameEnd() end
	
--- @param Movie string
function Osi.GameEndWithMovie(Movie) end
	
--- @param CallbackID string
function Osi.GameEndWithMovieRequestCallback(CallbackID) end
	
--- @param UserID integer
--- @param Movie string
--- @param Music string
function Osi.EnqueueGameEndMovie(UserID, Movie, Music) end
	
--- @param Character string
--- @param DialogName string
--- @param PlaylistId string
--- @param Music string
function Osi.EnqueueGameEndDialogMovie(Character, DialogName, PlaylistId, Music) end
	
--- @param UserID integer
function Osi.FinalizeGameEndMovieQueue(UserID) end
	
--- @param UserID integer
--- @param Movie string
function Osi.SetGameEndMovie(UserID, Movie) end
	
--- @param Enable integer
function Osi.ShroudRender(Enable) end
	
--- @param Message string
function Osi.DebugBreak(Message) end
	
--- @param Character string
--- @param Seconds number
--- @param ToBlack integer
--- @param FadeID string
function Osi.FadeToBlack(Character, Seconds, ToBlack, FadeID) end
	
--- @param Character string
--- @param Seconds number
--- @param ToWhite integer
--- @param FadeID string
function Osi.FadeToWhite(Character, Seconds, ToWhite, FadeID) end
	
--- @param Character string
--- @param Seconds number
--- @param FadeID string
function Osi.FadeOutBlack(Character, Seconds, FadeID) end
	
--- @param Character string
--- @param Seconds number
--- @param FadeID string
function Osi.FadeOutWhite(Character, Seconds, FadeID) end
	
--- @param Character string
--- @param Seconds number
--- @param FadeID string
function Osi.FadeIn(Character, Seconds, FadeID) end
	
--- @param Character string
--- @param Bookname string
function Osi.OpenCustomBookUI(Character, Bookname) end
	
--- @param Bookname string
--- @param Entryname string
function Osi.AddEntryToCustomBook(Bookname, Entryname) end
	
--- @param Bookname string
--- @param Entryname string
function Osi.RemoveEntryFromCustomBook(Bookname, Entryname) end
	
--- @param Character string
--- @param CurrentWaypoint string
--- @param Item string
--- @param IsFleeing integer
function Osi.OpenWaypointUI(Character, CurrentWaypoint, Item, IsFleeing) end
	
--- @param Character string
--- @param UIName string
function Osi.CloseUI(Character, UIName) end
	
--- @param Character string
--- @param Item string
function Osi.OpenCraftUI(Character, Item) end
	
--- @param WaypointName string
--- @param Trigger string
--- @param Character string
function Osi.UnlockWaypoint(WaypointName, Trigger, Character) end
	
--- @param WaypointName string
--- @param Character string
function Osi.LockWaypoint(WaypointName, Character) end
	
--- @param WaypointName string
--- @param Item string
function Osi.RegisterWaypoint(WaypointName, Item) end
	
--- @param SecretRegionTrigger string
function Osi.UnlockSecretRegion(SecretRegionTrigger) end
	
--- @param SecretRegionTrigger string
function Osi.LockSecretRegion(SecretRegionTrigger) end
	
--- @param Source string
--- @param SurfaceType string
--- @param Radius number
--- @param Lifetime number
function Osi.CreateSurface(Source, SurfaceType, Radius, Lifetime) end
	
--- @param x number
--- @param Y number
--- @param Z number
--- @param SurfaceType string
--- @param Radius number
--- @param Lifetime number
function Osi.CreateSurfaceAtPosition(x, Y, Z, SurfaceType, Radius, Lifetime) end
	
--- @param Source string
--- @param SurfaceLayer integer
--- @param Radius number
function Osi.RemoveSurfaceLayer(Source, SurfaceLayer, Radius) end
	
--- @param x number
--- @param Y number
--- @param Z number
--- @param SurfaceLayer integer
--- @param Radius number
function Osi.RemoveSurfaceLayerAtPosition(x, Y, Z, SurfaceLayer, Radius) end
	
--- @param Source string
--- @param SurfaceType string
--- @param CellAmountMin integer
--- @param CellAmountMax integer
--- @param GrowAmountMin integer
--- @param GrowAmountMax integer
--- @param GrowTime number
function Osi.CreatePuddle(Source, SurfaceType, CellAmountMin, CellAmountMax, GrowAmountMin, GrowAmountMax, GrowTime) end
	
--- @param Source string
--- @param TransformType string
--- @param TransformLayer string
--- @param Radius number
--- @param Lifetime number
--- @param Owner string
function Osi.TransformSurface(Source, TransformType, TransformLayer, Radius, Lifetime, Owner) end
	
--- @param X number
--- @param Y number
--- @param Z number
--- @param TransformType string
--- @param TransformLayer string
--- @param Radius number
--- @param Lifetime number
--- @param Owner string
function Osi.TransformSurfaceAtPosition(X, Y, Z, TransformType, TransformLayer, Radius, Lifetime, Owner) end
	
--- @param SurfaceActionHandle integer
function Osi.StopDrawSurfaceOnPath(SurfaceActionHandle) end
	
--- @param FxName string
--- @param X number
--- @param Y number
--- @param Z number
function Osi.PlayEffectAtPosition(FxName, X, Y, Z) end
	
--- @param FxName string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Yangle number
function Osi.PlayEffectAtPositionAndRotation(FxName, X, Y, Z, Yangle) end
	
--- @param FxName string
--- @param Scale number
--- @param X number
--- @param Y number
--- @param Z number
function Osi.PlayScaledEffectAtPosition(FxName, Scale, X, Y, Z) end
	
--- @param CombatID integer
function Osi.EndCombat(CombatID) end
	
--- @param FxHandle integer
function Osi.StopLoopEffect(FxHandle) end
	
--- @param Target string
function Osi.MakePlayerActive(Target) end
	
--- @param Target string
--- @param SkillID string
--- @param CasterLevel integer
function Osi.CreateExplosion(Target, SkillID, CasterLevel) end
	
--- @param X number
--- @param Y number
--- @param Z number
--- @param SkillID string
--- @param CasterLevel integer
function Osi.CreateExplosionAtPosition(X, Y, Z, SkillID, CasterLevel) end
	
--- @param Target string
--- @param SkillID string
--- @param CasterLevel integer
function Osi.CreateProjectileStrikeAt(Target, SkillID, CasterLevel) end
	
--- @param X number
--- @param Y number
--- @param Z number
--- @param SkillID string
--- @param CasterLevel integer
function Osi.CreateProjectileStrikeAtPosition(X, Y, Z, SkillID, CasterLevel) end
	
--- @param SkillID string
--- @param Source string
--- @param MinAngle number
--- @param MaxAngle number
--- @param Distance number
function Osi.LaunchProjectileAtCone(SkillID, Source, MinAngle, MaxAngle, Distance) end
	

function Osi.AutoSave() end
	

function Osi.ShowGameOverMenu() end
	
--- @param Character string
function Osi.OnCompanionDismissed(Character) end
	
--- @param Character string
--- @param Text string
function Osi.ShowNotification(Character, Text) end
	
--- @param Character string
--- @param Error string
function Osi.ShowError(Character, Error) end
	
--- @param Character string
--- @param Text string
--- @param Category string
--- @param Title string
--- @param ControllerType integer
--- @param ModalType integer
--- @param Duration integer
--- @param Priority integer
--- @param Flags integer
--- @param MinimumPlaytimeInMinutes integer
function Osi.ShowTutorial(Character, Text, Category, Title, ControllerType, ModalType, Duration, Priority, Flags, MinimumPlaytimeInMinutes) end
	
--- @param Character string
--- @param Text string
function Osi.CompleteTutorial(Character, Text) end
	
--- @param AchievementID string
--- @param Character string
function Osi.UnlockAchievement(AchievementID, Character) end
	
--- @param AchievementID string
--- @param Character string
--- @param Progress integer
function Osi.ProgressAchievement(AchievementID, Character, Progress) end
	
--- @param AchievementID string
--- @param Value integer
function Osi.SetAchievementProgress(AchievementID, Value) end
	
--- @param State integer
--- @param Character string
function Osi.SetHomesteadKeyState(State, Character) end
	
--- @param Bool integer
function Osi.EnableSendToHomestead(Bool) end
	
--- @param Character string
function Osi.KillCombatFor(Character) end
	
--- @param Item string
--- @param TreasureID string
--- @param Level integer
--- @param Character string
function Osi.GenerateTreasure(Item, TreasureID, Level, Character) end
	
--- @param SourceObject string
--- @param Animation string
--- @param Event string
function Osi.PlayAnimation(SourceObject, Animation, Event) end
	
--- @param Source string
--- @param VarName string
--- @param Object string
function Osi.SetVarObject(Source, VarName, Object) end
	
--- @param Source string
--- @param VarName string
function Osi.ClearVarObject(Source, VarName) end
	
--- @param Target string
--- @param Scriptframe string
function Osi.SetScriptframe(Target, Scriptframe) end
	
--- @param Target string
function Osi.ClearScriptframe(Target) end
	
--- @param Source string
--- @param Tag string
function Osi.SetTag(Source, Tag) end
	
--- @param Source string
--- @param Tag string
function Osi.ClearTag(Source, Tag) end
	
--- @param Target string
--- @param VarName string
--- @param VarValue integer
function Osi.SetVarInteger(Target, VarName, VarValue) end
	
--- @param Target string
--- @param VarName string
--- @param VarValue number
function Osi.SetVarFloat(Target, VarName, VarValue) end
	
--- @param Target string
--- @param VarName string
--- @param VarValue string
function Osi.SetVarString(Target, VarName, VarValue) end
	
--- @param Target string
--- @param VarName string
--- @param VarValue string
function Osi.SetVarFixedString(Target, VarName, VarValue) end
	
--- @param Target string
--- @param VarName string
--- @param X number
--- @param Y number
--- @param Z number
function Osi.SetVarFloat3(Target, VarName, X, Y, Z) end
	
--- @param Target string
--- @param Status string
function Osi.RemoveStatus(Target, Status) end
	
--- @param Target string
function Osi.RemoveHarmfulStatuses(Target) end
	
--- @param Object string
--- @param ObjectTemplate string
--- @param ReplaceScripts integer
--- @param ReplaceScale integer
--- @param ReplaceStats integer
function Osi.Transform(Object, ObjectTemplate, ReplaceScripts, ReplaceScale, ReplaceStats) end
	
--- @param Object string
--- @param Status string
--- @param Duration number
--- @param Force integer
--- @param Source string
function Osi.ApplyStatus(Object, Status, Duration, Force, Source) end
	
--- @param Object string
--- @param Event string
function Osi.SetStoryEvent(Object, Event) end
	
--- @param Character string
--- @param RequestId integer
--- @param RequestAccepted integer
function Osi.RequestProcessed(Character, RequestId, RequestAccepted) end
	
--- @param Character string
--- @param Event string
function Osi.IterateParty(Character, Event) end
	
--- @param Event string
function Osi.IterateParties(Event) end
	
--- @param Event string
function Osi.IterateUsers(Event) end
	
--- @param Savegame string
function Osi.LoadGame(Savegame) end
	
--- @param UserId integer
function Osi.LeaveParty(UserId) end
	
--- @param Source integer
--- @param Target integer
function Osi.AddToParty(Source, Target) end
	
--- @param Preset string
--- @param TeleportToTarget string
function Osi.LoadPartyPreset(Preset, TeleportToTarget) end
	

function Osi.CrimeClearAll() end
	
--- @param CrimeID integer
--- @param Interrogator string
--- @param FoundEvidence integer
--- @param Criminal1 string
--- @param Criminal2 string
--- @param Criminal3 string
--- @param Criminal4 string
function Osi.CrimeInterrogationDone(CrimeID, Interrogator, FoundEvidence, Criminal1, Criminal2, Criminal3, Criminal4) end
	
--- @param CrimeID integer
--- @param Interrogator string
function Osi.CrimeConfrontationDone(CrimeID, Interrogator) end
	
--- @param Target string
--- @param Enabled integer
function Osi.SetCanFight(Target, Enabled) end
	
--- @param Target string
--- @param Enabled integer
function Osi.SetCanJoinCombat(Target, Enabled) end
	
--- @param InventoryHolder string
--- @param Event string
--- @param CompletionEvent string
function Osi.InventoryLaunchIterator(InventoryHolder, Event, CompletionEvent) end
	
--- @param InventoryHolder string
--- @param TagA string
--- @param OptionalTagB string
--- @param Event string
--- @param CompletionEvent string
function Osi.InventoryLaunchTagIterator(InventoryHolder, TagA, OptionalTagB, Event, CompletionEvent) end
	
--- @param InventoryHolder string
--- @param Template string
--- @param Event string
--- @param CompletionEvent string
function Osi.InventoryLaunchTemplateIterator(InventoryHolder, Template, Event, CompletionEvent) end
	
--- @param Target string
--- @param Enabled integer
function Osi.SetIsBoss(Target, Enabled) end
	
--- @param Target string
--- @param GroupID string
function Osi.SetCombatGroupID(Target, GroupID) end
	
--- @param Target string
function Osi.EndTurn(Target) end
	
--- @param CrimeArea string
--- @param Modifier integer
function Osi.CrimeAreaSetTensionModifier(CrimeArea, Modifier) end
	
--- @param CrimeArea string
function Osi.CrimeAreaResetTensionModifier(CrimeArea) end
	
--- @param CrimeID integer
--- @param Target string
function Osi.CrimeTransferEvidenceTo(CrimeID, Target) end
	

function Osi.ShutdownCrimeSystem() end
	
--- @param NPC string
--- @param Bool integer
function Osi.CrimeEnableInterrogation(NPC, Bool) end
	
--- @param Criminal string
--- @param NPC string
--- @param IgnoreDuration integer
function Osi.CrimeIgnoreAllCrimesForCriminal(Criminal, NPC, IgnoreDuration) end
	
--- @param CrimeID integer
--- @param Criminal1 string
--- @param Criminal2 string
--- @param Criminal3 string
--- @param Criminal4 string
function Osi.CrimeResetInterrogationForCriminals(CrimeID, Criminal1, Criminal2, Criminal3, Criminal4) end
	
--- @param Target string
function Osi.JumpToTurn(Target) end
	
--- @param CrimeID integer
--- @param NPC string
function Osi.CrimeIgnoreCrime(CrimeID, NPC) end
	

function Osi.NotifyCharacterCreationFinished() end
	
--- @param Speaker string
--- @param Dialog integer
function Osi.SetHasDialog(Speaker, Dialog) end
	
--- @param WinnerTeamId integer
function Osi.ShowArenaResult(WinnerTeamId) end
	
--- @param Source string
--- @param Target string
function Osi.EnterCombat(Source, Target) end
	
--- @param Target string
function Osi.LeaveCombat(Target) end
	
--- @param Target string
--- @param Faction string
function Osi.SetFaction(Target, Faction) end
	
--- @param Target string
--- @param Bool integer
function Osi.SetInvulnerable_UseProcSetInvulnerable(Target, Bool) end
	
--- @param Character string
--- @param Restconsumable string
--- @param PartyRadius number
--- @param MinSafeDistance number
function Osi.UserRest(Character, Restconsumable, PartyRadius, MinSafeDistance) end
	

function Osi.FireOsirisEvents() end
	
--- @param Spline string
--- @param Character string
--- @param FadeTime number
--- @param HideUI integer
--- @param Freeze integer
--- @param StartIndex integer
function Osi.StartCameraSpline(Spline, Character, FadeTime, HideUI, Freeze, StartIndex) end
	
--- @param Spline string
--- @param Character string
function Osi.StopCameraSpline(Spline, Character) end
	
--- @param Object string
--- @param Damage integer
--- @param DamageType string
--- @param Source string
function Osi.ApplyDamage(Object, Damage, DamageType, Source) end
	
--- @param Source string
--- @param Target string
--- @param IgnoreVote integer
function Osi.MakePeace(Source, Target, IgnoreVote) end
	
--- @param Source string
--- @param Target string
--- @param IgnoreVote integer
function Osi.MakeWar(Source, Target, IgnoreVote) end
	
--- @param LevelTemplate string
function Osi.ActivatePersistentLevelTemplateWithCombat(LevelTemplate) end
	
--- @param LevelTemplate string
function Osi.ActivatePersistentLevelTemplate(LevelTemplate) end
	
--- @param Player string
--- @param Id string
function Osi.ReadyCheckStart(Player, Id) end
	
--- @param Modifier integer
function Osi.SetGlobalPriceModifier(Modifier) end
	
--- @param Character string
--- @param EventName string
function Osi.SonyRealtimeMultiplayerEvent(Character, EventName) end
	
--- @param Trigger string
--- @param Event string
function Osi.TriggerLaunchIterator(Trigger, Event) end
	
--- @param Trigger string
--- @param ItemTemplate string
function Osi.TriggerRemoveAllItemTemplates(Trigger, ItemTemplate) end
	
--- @param Trigger string
--- @param Character string
function Osi.TriggerRegisterForCharacter(Trigger, Character) end
	
--- @param Trigger string
--- @param Character string
function Osi.TriggerUnregisterForCharacter(Trigger, Character) end
	
--- @param Trigger string
function Osi.TriggerRegisterForPlayers(Trigger) end
	
--- @param Trigger string
function Osi.TriggerUnregisterForPlayers(Trigger) end
	
--- @param Trigger string
function Osi.TriggerRegisterForItems(Trigger) end
	
--- @param Trigger string
function Osi.TriggerUnregisterForItems(Trigger) end
	
--- @param Trigger string
--- @param Atmospherestring string
function Osi.TriggerSetAtmosphere(Trigger, Atmospherestring) end
	
--- @param Trigger string
function Osi.TriggerResetAtmosphere(Trigger) end
	
--- @param Trigger string
--- @param StateGroup string
--- @param State2 string
--- @param Recursive integer
function Osi.TriggerSetSoundState(Trigger, StateGroup, State2, Recursive) end
	
--- @param Trigger string
--- @param Name string
--- @param Value number
--- @param Recursive integer
function Osi.TriggerSetSoundRTPC(Trigger, Name, Value, Recursive) end
	
--- @param AreaTrigger string
--- @param Owner string
function Osi.TriggerSetItemOwner(AreaTrigger, Owner) end
	
--- @param AreaTrigger string
function Osi.TriggerClearItemOwner(AreaTrigger) end
	
--- @param Trigger string
--- @param ItemTemplate string
function Osi.TriggerClearItemTemplateOwners(Trigger, ItemTemplate) end
	
--- @param InstanceID integer
--- @param Actor string
function Osi.DialogAddActor(InstanceID, Actor) end
	
--- @param InstanceID integer
--- @param Actor string
--- @param Index integer
function Osi.DialogAddActorAt(InstanceID, Actor, Index) end
	
--- @param InstanceID integer
function Osi.DialogResume(InstanceID) end
	
--- @param Bark string
--- @param Source string
function Osi.StartVoiceBark(Bark, Source) end
	
--- @param Dialog string
--- @param Variable string
--- @param Value string
function Osi.DialogSetVariableString(Dialog, Variable, Value) end
	
--- @param Dialog string
--- @param Variable string
--- @param Value integer
function Osi.DialogSetVariableInt(Dialog, Variable, Value) end
	
--- @param Dialog string
--- @param Variable string
--- @param Value number
function Osi.DialogSetVariableFloat(Dialog, Variable, Value) end
	
--- @param Dialog string
--- @param Variable string
--- @param Value string
function Osi.DialogSetVariableFixedString(Dialog, Variable, Value) end
	
--- @param Dialog string
--- @param Variable string
--- @param StringHandleValue string
--- @param ReferenceStringValue string
function Osi.DialogSetVariableTranslatedString(Dialog, Variable, StringHandleValue, ReferenceStringValue) end
	
--- @param InstanceID integer
--- @param Variable string
--- @param Value string
function Osi.DialogSetVariableStringForInstance(InstanceID, Variable, Value) end
	
--- @param InstanceID integer
--- @param Variable string
--- @param Value integer
function Osi.DialogSetVariableIntForInstance(InstanceID, Variable, Value) end
	
--- @param InstanceID integer
--- @param Variable string
--- @param Value number
function Osi.DialogSetVariableFloatForInstance(InstanceID, Variable, Value) end
	
--- @param InstanceID integer
--- @param Variable string
--- @param Value string
function Osi.DialogSetVariableFixedStringForInstance(InstanceID, Variable, Value) end
	
--- @param InstanceID integer
--- @param Variable string
--- @param StringHandleValue string
--- @param ReferenceStringValue string
function Osi.DialogSetVariableTranslatedStringForInstance(InstanceID, Variable, StringHandleValue, ReferenceStringValue) end

--- @param object string
--- @param template string
--- @param replaceScripts boolean
--- @param replaceScale boolean
--- @param replaceStats boolean
function Osi.TransformKeepIcon(object, template, replaceScripts, replaceScale, replaceStats) end

--- @param skill string
--- @param source string
--- @param angleVariationDegrees number
--- @param distance number
function Osi.LaunchProjectileFromCharacterInCone(skill, source, angleVariationDegrees, distance) end

--#endregion

--#region Osiris Queries

--- @param GoalTitle string
--- @return integer Status
function Osi.SysStatus(GoalTitle) end
	
--- @param GoalTitle string
function Osi.SysIsCompleted(GoalTitle) end
	
--- @param GoalTitle string
function Osi.SysIsActive(GoalTitle) end
	
--- @param GoalTitle string
function Osi.SysIsSleeping(GoalTitle) end
	
--- @param GoalTitle string
function Osi.SysWasCompleted(GoalTitle) end
	
--- @param GoalTitle string
function Osi.SysWasActive(GoalTitle) end
	
--- @param GoalTitle string
function Osi.SysWasSleeping(GoalTitle) end
	
--- @param GoalTitle string
function Osi.SysWasDefined(GoalTitle) end
	
--- @param Predicate string
--- @param Arity integer
--- @return integer Count
function Osi.SysCount(Predicate, Arity) end
	
--- @return integer Major
--- @return integer Minor
--- @return integer V3
--- @return integer V4
function Osi.SysStoryVersion() end
	
--- @param A integer
--- @param B integer
--- @return integer Sum
function Osi.IntegerSum(A, B) end
	
--- @param A integer
--- @param B integer
--- @return integer Result
function Osi.IntegerSubtract(A, B) end
	
--- @param A integer
--- @param B integer
--- @return integer Product
function Osi.IntegerProduct(A, B) end
	
--- @param A integer
--- @param B integer
--- @return integer Quotient
function Osi.IntegerDivide(A, B) end
	
--- @param A integer
--- @param B integer
--- @return integer Minimum
function Osi.IntegerMin(A, B) end
	
--- @param A integer
--- @param B integer
--- @return integer Maximum
function Osi.IntegerMax(A, B) end
	
--- @param Num integer
--- @param Mod integer
--- @return integer Return
function Osi.IntegerModulo(Num, Mod) end
	
--- @param A number
--- @param B number
--- @return number Sum
function Osi.RealSum(A, B) end
	
--- @param A number
--- @param B number
--- @return number Result
function Osi.RealSubtract(A, B) end
	
--- @param A number
--- @param B number
--- @return number Product
function Osi.RealProduct(A, B) end
	
--- @param A number
--- @param B number
--- @return number Quotient
function Osi.RealDivide(A, B) end
	
--- @param A number
--- @param B number
--- @return number Minimum
function Osi.RealMin(A, B) end
	
--- @param A number
--- @param B number
--- @return number Maximum
function Osi.RealMax(A, B) end
	
--- @param R number
--- @return integer I
function Osi.Integer(R) end
	
--- @param I integer
--- @return number R
function Osi.Real(I) end
	
--- @param Modulo integer
--- @return integer Random
function Osi.Random(Modulo) end
	
--- @param Character string
--- @param Talent string
--- @return integer Bool
function Osi.CharacterHasTalent(Character, Talent) end
	
--- @param Character string
--- @return integer Level
function Osi.CharacterGetLevel(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterCanFight(Character) end
	
--- @param X number
--- @param Y number
--- @param Z number
--- @param TemplateId string
--- @param PlaySpawn integer
--- @return string Created
function Osi.CharacterCreateAtPosition(X, Y, Z, TemplateId, PlaySpawn) end
	
--- @param X number
--- @param Y number
--- @param Z number
--- @param TemplateId string
--- @param PlaySpawn integer
--- @return string Created
function Osi.TemporaryCharacterCreateAtPosition(X, Y, Z, TemplateId, PlaySpawn) end
	
--- @param Caster string
--- @param SummonTemplateId string
--- @param X number
--- @param Y number
--- @param Z number
--- @param SummonLifetime number
--- @param SummonCharacterLevel integer
--- @param SummoningAbilityLevel integer
--- @return string SummonedCharacter
function Osi.CharacterSummonAtPosition(Caster, SummonTemplateId, X, Y, Z, SummonLifetime, SummonCharacterLevel, SummoningAbilityLevel) end
	
--- @param X number
--- @param Y number
--- @param Z number
--- @param TemplateId string
--- @param Angle integer
--- @param PlaySpawn integer
--- @param Event string
--- @return string Created
function Osi.CharacterCreateAtPositionOutOfSightTo(X, Y, Z, TemplateId, Angle, PlaySpawn, Event) end
	
--- @param X number
--- @param Y number
--- @param Z number
--- @param TemplateId string
--- @param Angle integer
--- @param PlaySpawn integer
--- @param Event string
--- @return string Created
function Osi.TemporaryCharacterCreateAtPositionOutOfSightTo(X, Y, Z, TemplateId, Angle, PlaySpawn, Event) end
	
--- @param TemplateId string
--- @param ToTarget string
--- @param FromObject string
--- @param PlaySpawn integer
--- @param Event string
--- @return string Created
function Osi.CharacterCreateOutOfSightToObject(TemplateId, ToTarget, FromObject, PlaySpawn, Event) end
	
--- @param TemplateId string
--- @param ToTarget string
--- @param FromObject string
--- @param PlaySpawn integer
--- @param Event string
--- @return string Created
function Osi.TemporaryCharacterCreateOutOfSightToObject(TemplateId, ToTarget, FromObject, PlaySpawn, Event) end
	
--- @param Character string
--- @param Skill string
--- @return integer Bool
function Osi.CharacterHasSkill(Character, Skill) end
	
--- @param Character string
--- @return integer Amount
function Osi.CharacterGetAttributePoints(Character) end
	
--- @param Character string
--- @return integer Amount
function Osi.CharacterGetAbilityPoints(Character) end
	
--- @param Character string
--- @return integer Amount
function Osi.CharacterGetCivilAbilityPoints(Character) end
	
--- @param Character string
--- @return integer Amount
function Osi.CharacterGetTalentPoints(Character) end
	
--- @param Character string
--- @return integer Amount
function Osi.CharacterGetBaseSourcePoints(Character) end
	
--- @param Character string
--- @return integer Amount
function Osi.CharacterGetSourcePoints(Character) end
	
--- @param Character string
--- @return integer Amount
function Osi.CharacterGetMaxSourcePoints(Character) end
	
--- @param Character string
--- @return integer User
function Osi.CharacterGetReservedUserID(Character) end
	
--- @param User integer
--- @return string Character
function Osi.GetCurrentCharacter(User) end
	
--- @param Character string
--- @return integer IsControlled
function Osi.CharacterIsControlled(Character) end
	
--- @param Character string
--- @return integer Count
function Osi.CharacterGetGold(Character) end
	
--- @param Character string
--- @return integer Gold
function Osi.PartyGetGold(Character) end
	
--- @param Character string
--- @return integer Gold
function Osi.UserGetGold(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsSpectating(Character) end
	
--- @param Character string
--- @param Target string
--- @return integer Bool
function Osi.CharacterCanSee(Character, Target) end
	
--- @param Character string
--- @param Respec integer
--- @return integer Success
function Osi.CharacterAddToCharacterCreation(Character, Respec) end
	
--- @param Character string
--- @param Respec integer
--- @return integer Success
function Osi.GameMasterAddToCharacterCreation(Character, Respec) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsPartyMember(Character) end
	
--- @param Character string
--- @param Target string
--- @return integer Bool
function Osi.CharacterIsInPartyWith(Character, Target) end
	
--- @param Character string
--- @param OtherCharacter string
--- @return integer Relation
function Osi.CharacterGetRelationToCharacter(Character, OtherCharacter) end
	
--- @param Character string
--- @param Player string
--- @return integer Attitude
function Osi.CharacterGetAttitudeTowardsPlayer(Character, Player) end
	
--- @param Character string
--- @return number Percentage
function Osi.CharacterGetHitpointsPercentage(Character) end
	
--- @param Character string
--- @return number Percentage
function Osi.CharacterGetArmorPercentage(Character) end
	
--- @param Character string
--- @return number Percentage
function Osi.CharacterGetMagicArmorPercentage(Character) end
	
--- @return string Character
function Osi.CharacterGetHostCharacter() end
	
--- @param Character string
--- @return string stringHandle
--- @return string referenceString
function Osi.CharacterGetDisplayName(Character) end
	
--- @param Trader string
--- @return integer Bool
function Osi.CharacterCanTrade(Trader) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsInCombat(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsMoving(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsInFightMode(Character) end
	
--- @param Character string
--- @param Potion string
--- @return integer ConsumeHandle
function Osi.CharacterConsume(Character, Potion) end
	
--- @param Character string
--- @param Attribute string
--- @return integer Value
function Osi.CharacterGetBaseAttribute(Character, Attribute) end
	
--- @param Character string
--- @param Attribute string
--- @return integer Value
function Osi.CharacterGetAttribute(Character, Attribute) end
	
--- @param Character string
--- @return integer Incapacitated
function Osi.CharacterIsIncapacitated(Character) end
	
--- @param Character string
--- @param Ability string
--- @return integer Value
function Osi.CharacterGetAbility(Character, Ability) end
	
--- @param Character string
--- @param Ability string
--- @return integer Value
function Osi.CharacterGetBaseAbility(Character, Ability) end
	
--- @param Character string
--- @return string Owner
function Osi.CharacterGetOwner(Character) end
	
--- @param Character string
--- @return string ItemGUID
function Osi.CharacterGetEquippedWeapon(Character) end
	
--- @param Character string
--- @return string ItemGUID
function Osi.CharacterGetEquippedShield(Character) end
	
--- @param Character string
--- @param Slotname string
--- @return string ItemGUID
function Osi.CharacterGetEquippedItem(Character, Slotname) end
	
--- @param Character1 string
--- @param Character2 string
--- @return integer Bool
function Osi.CharactersAreGrouped(Character1, Character2) end
	
--- @param Character string
--- @return integer Value
function Osi.CharacterGetInventoryGoldValue(Character) end
	
--- @param Character string
--- @param ItemTemplate string
--- @return integer Value
function Osi.CharacterGetItemTemplateCount(Character, ItemTemplate) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsFemale(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterCanSpotSneakers(Character) end
	
--- @param Character string
--- @param RecipeID string
--- @return integer Bool
function Osi.CharacterHasRecipeUnlocked(Character, RecipeID) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsDead(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsDeadOrFeign(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterCanIgnoreActiveCrimes(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIgnoreActiveCrimes(Character) end
	
--- @param Character string
--- @param Crime string
--- @return integer Bool
function Osi.CharacterIsCrimeEnabled(Character, Crime) end
	
--- @param Character string
--- @return string Region
function Osi.CharacterGetCrimeRegion(Character) end
	
--- @param Character string
--- @return integer InstanceID
function Osi.CharacterGetCrimeDialog(Character) end
	
--- @param Character string
--- @param OtherCharacter string
--- @return integer Bool
function Osi.CharacterIsEnemy(Character, OtherCharacter) end
	
--- @param Character string
--- @param OtherCharacter string
--- @return integer Bool
function Osi.CharacterIsAlly(Character, OtherCharacter) end
	
--- @param Character string
--- @param OtherCharacter string
--- @return integer Bool
function Osi.CharacterIsNeutral(Character, OtherCharacter) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterCanUseWaypoints(Character) end
	
--- @param Character string
--- @param Ghost string
--- @return integer Bool
function Osi.CharacterCanSeeGhost(Character, Ghost) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsSummon(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsPartyFollower(Character) end
	
--- @param Character string
--- @param TargetRace string
--- @return integer Bool
function Osi.CharacterIsPolymorphedInto(Character, TargetRace) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsPolymorphInteractionDisabled(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterGameMaster(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterIsPlayer(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterHasLinkedGhost(Character) end
	
--- @param Character string
--- @return integer Bool
function Osi.CharacterCanSpotCrimes(Character) end
	
--- @param Character string
--- @param CrimeType string
--- @return integer Bool
function Osi.CharacterCanReactToCrime(Character, CrimeType) end
	
--- @param Player string
--- @param CanPolymorphOverride integer
--- @return string Race
function Osi.CharacterGetRace(Player, CanPolymorphOverride) end
	
--- @param Player string
--- @param CanPolymorphOverride integer
--- @return string Origin
function Osi.CharacterGetOrigin(Player, CanPolymorphOverride) end
	
--- @param Player string
--- @return string Instrument
function Osi.CharacterGetInstrument(Player) end
	
--- @param Owner string
--- @param Preset string
--- @return integer Price
function Osi.CharacterGetHenchmanPresetPrice(Owner, Preset) end
	
--- @param ItemTemplate string
--- @param X number
--- @param Y number
--- @param Z number
--- @return string Item
function Osi.CreateItemTemplateAtPosition(ItemTemplate, X, Y, Z) end
	
--- @param Index integer
--- @return string Template
function Osi.GetDebugItem(Index) end
	
--- @param Item string
--- @param Character string
--- @return integer Bool
function Osi.ItemIsInCharacterInventory(Item, Character) end
	
--- @param Item string
--- @param Character string
--- @param MoveAndReport integer
--- @return integer Bool
function Osi.ItemIsInPartyInventory(Item, Character, MoveAndReport) end
	
--- @param Item string
--- @param Character string
--- @param MoveAndReport integer
--- @return integer Bool
function Osi.ItemIsInUserInventory(Item, Character, MoveAndReport) end
	
--- @param Item string
--- @return integer Bool
function Osi.ItemIsInInventory(Item) end
	
--- @param Character string
--- @param Template string
--- @return integer Count
function Osi.ItemTemplateIsInCharacterInventory(Character, Template) end
	
--- @param Character string
--- @param Tag string
--- @return integer Count
function Osi.ItemTagIsInCharacterInventory(Character, Tag) end
	
--- @param Character string
--- @param Template string
--- @param Tag string
--- @return integer Count
function Osi.ItemTemplateTagIsInCharacterInventory(Character, Template, Tag) end
	
--- @param Character string
--- @param Template string
--- @param MoveAndReport integer
--- @return integer Count
function Osi.ItemTemplateIsInPartyInventory(Character, Template, MoveAndReport) end
	
--- @param Character string
--- @param Template string
--- @param MoveAndReport integer
--- @return integer Count
function Osi.ItemTemplateIsInUserInventory(Character, Template, MoveAndReport) end
	
--- @param Template string
--- @return string stringHandle
--- @return string referenceString
function Osi.ItemTemplateGetDisplayString(Template) end
	
--- @param Item string
--- @param Template string
--- @return integer Count
function Osi.ItemTemplateIsInContainer(Item, Template) end
	
--- @param Item string
--- @return integer Opened
function Osi.ItemIsOpened(Item) end
	
--- @param Door string
--- @return integer Opening
function Osi.DoorIsOpening(Door) end
	
--- @param Item string
--- @return integer Closed
function Osi.ItemIsClosed(Item) end
	
--- @param Door string
--- @return integer Closing
function Osi.DoorIsClosing(Door) end
	
--- @param Item string
--- @return integer Locked
function Osi.ItemIsLocked(Item) end
	
--- @param Item string
--- @return integer IsContainer
function Osi.ItemIsContainer(Item) end
	
--- @param Item string
--- @param OnUse string
--- @return integer Bool
function Osi.ItemHasOnUse(Item, OnUse) end
	
--- @param Item string
--- @return integer Bool
function Osi.ItemIsTorch(Item) end
	
--- @param Item string
--- @return integer Bool
function Osi.ItemIsEquipable(Item) end
	
--- @param Item string
--- @return string SlotName
function Osi.ItemGetEquipmentSlot(Item) end
	
--- @param Item string
--- @return integer Destroyed
function Osi.ItemIsDestroyed(Item) end
	
--- @param Item string
--- @return string Character
function Osi.ItemGetOwner(Item) end
	
--- @param Item string
--- @return string Character
function Osi.ItemGetOriginalOwner(Item) end
	
--- @param Item string
--- @return string Owner
function Osi.GetInventoryOwner(Item) end
	
--- @param Item string
--- @return integer bool
function Osi.ItemGetUseRemotely(Item) end
	
--- @param Item string
--- @return integer Bool
function Osi.ItemIsStoryItem(Item) end
	
--- @param Item string
--- @return integer Charges
function Osi.ItemGetCharges(Item) end
	
--- @param Item string
--- @return integer InitialCharges
function Osi.ItemGetMaxCharges(Item) end
	
--- @param Item string
--- @return integer Durability
function Osi.ItemGetDurability(Item) end
	
--- @param Item string
--- @return integer Amount
function Osi.ItemGetAmount(Item) end
	
--- @param Item string
--- @return integer HP
function Osi.ItemGetHealthPoints(Item) end
	
--- @param Item string
--- @return integer Bool
function Osi.ItemIsDestructible(Item) end
	
--- @param Item string
--- @return integer Bool
function Osi.ItemCanSitOn(Item) end
	
--- @param Item string
--- @return integer Bool
function Osi.ItemIsLadder(Item) end
	
--- @param Template string
--- @return integer Bool
function Osi.ItemTemplateCanSitOn(Template) end
	
--- @param Container string
--- @return integer Value
function Osi.ContainerGetGoldValue(Container) end
	
--- @param Item string
--- @return integer Value
function Osi.ItemGetGoldValue(Item) end
	
--- @param Character string
--- @param Template string
--- @return string Item
function Osi.GetItemForItemTemplateInInventory(Character, Template) end
	
--- @param Character string
--- @param Template string
--- @return string Item
function Osi.GetItemForItemTemplateInPartyInventory(Character, Template) end
	
--- @param Character string
--- @param Tag string
--- @return string Item
function Osi.CharacterFindTaggedItem(Character, Tag) end
	
--- @param Character string
--- @param Tag string
--- @param MoveAndReport integer
--- @return string Item
function Osi.PartyFindTaggedItem(Character, Tag, MoveAndReport) end
	
--- @param Character string
--- @param Tag string
--- @param MoveAndReport integer
--- @return string Item
function Osi.UserFindTaggedItem(Character, Tag, MoveAndReport) end
	
--- @param Character string
--- @param Tag string
--- @param Amount integer
--- @return integer AmountRemoved
function Osi.CharacterRemoveTaggedLocalItems(Character, Tag, Amount) end
	
--- @param Character string
--- @param Tag string
--- @param Amount integer
--- @return integer AmountRemoved
function Osi.PartyRemoveTaggedLocalItems(Character, Tag, Amount) end
	
--- @param Character string
--- @param Tag string
--- @param Amount integer
--- @return integer AmountRemoved
function Osi.UserRemoveTaggedLocalItems(Character, Tag, Amount) end
	
--- @param Character string
--- @param ToObject string
--- @param Tag string
--- @param Amount integer
--- @return integer AmountTransfered
function Osi.UserTransferTaggedLocalItems(Character, ToObject, Tag, Amount) end
	
--- @param Item string
--- @return integer Bool
function Osi.ItemIsPublicDomain(Item) end
	
--- @param Item string
--- @param Slot integer
--- @return string Template
function Osi.ItemGetRuneItemTemplate(Item, Slot) end
	
--- @param Character string
--- @param Item string
--- @param Slot integer
--- @return string Rune
function Osi.ItemRemoveRune(Character, Item, Slot) end
	
--- @param Item string
--- @param Boost string
--- @return integer Count
function Osi.ItemHasDeltaModifier(Item, Boost) end
	
--- @param InstanceID integer
--- @return integer Count
function Osi.DialogGetNumberOfInvolvedPlayers(InstanceID) end
	
--- @param InstanceID integer
--- @param Index integer
--- @return string Player
function Osi.DialogGetInvolvedPlayer(InstanceID, Index) end
	
--- @param InstanceID integer
--- @return string Category
function Osi.DialogGetCategory(InstanceID) end
	
--- @param InstanceID integer
--- @return integer NumberOfNPCs
function Osi.DialogGetNumberOfInvolvedNPCs(InstanceID) end
	
--- @param InstanceID integer
--- @param Index integer
--- @return string NPC
function Osi.DialogGetInvolvedNPC(InstanceID, Index) end
	
--- @param Flag string
--- @return integer FlagState
function Osi.GlobalGetFlag(Flag) end
	
--- @param Target string
--- @param Flag string
--- @return integer FlagState
function Osi.ObjectGetFlag(Target, Flag) end
	
--- @param Target string
--- @param Flag string
--- @return integer FlagState
function Osi.ObjectGetDialogFlag(Target, Flag) end
	
--- @param Character string
--- @param Flag string
--- @return integer FlagState
function Osi.UserGetFlag(Character, Flag) end
	
--- @param Character string
--- @param Flag string
--- @return integer FlagState
function Osi.PartyGetFlag(Character, Flag) end
	
--- @param DialogInstance integer
--- @param LocalEvent string
--- @return integer Value
function Osi.DialogGetLocalFlag(DialogInstance, LocalEvent) end
	
--- @param Object string
--- @return integer Bool
function Osi.ObjectIsCharacter(Object) end
	
--- @param Object string
--- @return string Statname
function Osi.GetStatString(Object) end
	
--- @param Object string
--- @return integer Exists
function Osi.ObjectExists(Object) end
	
--- @param Object string
--- @return integer IsGlobal
function Osi.ObjectIsGlobal(Object) end
	
--- @param Object string
--- @return integer Bool
function Osi.ObjectIsItem(Object) end
	
--- @param Object string
--- @param Trigger string
--- @return integer Bool
function Osi.ObjectIsInTrigger(Object, Trigger) end
	
--- @param x number
--- @param Y number
--- @param Z number
--- @param Trigger string
--- @return integer Bool
function Osi.PositionIsInTrigger(x, Y, Z, Trigger) end
	
--- @param Object string
--- @return integer Bool
function Osi.ObjectIsOnStage(Object) end
	
--- @param SourceX number
--- @param SourceY number
--- @param SourceZ number
--- @param Radius number
--- @param Object string
--- @return number ValidPositionX
--- @return number ValidPositionY
--- @return number ValidPositionZ
function Osi.FindValidPosition(SourceX, SourceY, SourceZ, Radius, Object) end
	
--- @param Source string
--- @param Target string
--- @return integer Bool
function Osi.HasLineOfSight(Source, Target) end
	
--- @param Object string
--- @param FxName string
--- @param BoneName string
--- @return integer FxHandle
function Osi.PlayLoopEffect(Object, FxName, BoneName) end
	
--- @param Object string
--- @param Target string
--- @param FxName string
--- @param SourceBone string
--- @param TargetBone string
--- @return integer FxHandle
function Osi.PlayLoopBeamEffect(Object, Target, FxName, SourceBone, TargetBone) end
	
--- @return number Distance
function Osi.GetMaxCameraDistance() end
	
--- @param Quest string
--- @param Status string
--- @return integer Result
function Osi.QuestUpdateExists(Quest, Status) end
	
--- @param Character string
--- @param Quest string
--- @return integer Bool
function Osi.QuestAccepted(Character, Quest) end
	
--- @param Character string
--- @param Quest string
--- @return integer Bool
function Osi.QuestIsShared(Character, Quest) end
	
--- @param QuestID string
--- @param StateID string
--- @return integer Bool
function Osi.QuestIsSubquestEntry(QuestID, StateID) end
	
--- @param QuestID string
--- @param StateID string
--- @return integer Bool
function Osi.QuestIsMysteryEntry(QuestID, StateID) end
	
--- @param Target string
--- @return integer Bool
function Osi.IsInArena(Target) end
	
--- @param Character string
--- @param Quest string
--- @return integer Bool
function Osi.QuestIsClosed(Character, Quest) end
	
--- @param Quest string
--- @return string Level
function Osi.QuestGetBroadcastLevel(Quest) end
	
--- @param Character string
--- @param Quest string
--- @param Update string
--- @return integer Bool
function Osi.QuestHasUpdate(Character, Quest, Update) end
	
--- @param X number
--- @param Z number
--- @param Threshold number
--- @return integer Bool
function Osi.IsShrouded(X, Z, Threshold) end
	
--- @param Target string
--- @return string Surface
function Osi.GetSurfaceGroundAt(Target) end
	
--- @param Target string
--- @return string Surface
function Osi.GetSurfaceCloudAt(Target) end
	
--- @param Target string
--- @return string OwnerCharacter
--- @return string OwnerItem
function Osi.GetSurfaceGroundOwnerAt(Target) end
	
--- @param Target string
--- @return string OwnerCharacter
--- @return string OwnerItem
function Osi.GetSurfaceCloudOwnerAt(Target) end
	
--- @param Surface string
--- @return integer Index
function Osi.GetSurfaceTypeIndex(Surface) end
	
--- @param SurfaceIndex integer
--- @return string SurfaceName
function Osi.GetSurfaceNameByTypeIndex(SurfaceIndex) end
	
--- @param OwnerObject string
--- @param FollowObject string
--- @param SurfaceType string
--- @param Radius number
--- @param LifeTime number
--- @return integer SurfaceActionHandle
function Osi.DrawSurfaceOnPath(OwnerObject, FollowObject, SurfaceType, Radius, LifeTime) end
	
--- @param Target string
--- @param SurfaceLayer integer
--- @return integer SurfaceSize
function Osi.GetSurfaceSize(Target, SurfaceLayer) end
	
--- @param Target string
--- @param SurfaceLayer integer
--- @return integer SurfaceTurns
function Osi.GetSurfaceTurns(Target, SurfaceLayer) end
	
--- @param FxName string
--- @param X number
--- @param Y number
--- @param Z number
--- @return integer FxHandle
function Osi.PlayLoopEffectAtPosition(FxName, X, Y, Z) end
	
--- @param FxName string
--- @param Scale number
--- @param X number
--- @param Y number
--- @param Z number
--- @return integer FxHandle
function Osi.PlayScaledLoopEffectAtPosition(FxName, Scale, X, Y, Z) end
	
--- @param CombatID integer
--- @return integer NumPlayers
function Osi.CombatGetNumberOfInvolvedPlayers(CombatID) end
	
--- @param CombatID integer
--- @return integer NumPartyMembers
function Osi.CombatGetNumberOfInvolvedPartyMembers(CombatID) end
	
--- @param CombatID integer
--- @param PlayerIndex integer
--- @return string Player
function Osi.CombatGetInvolvedPlayer(CombatID, PlayerIndex) end
	
--- @param CombatID integer
--- @param PartyMemberIndex integer
--- @return string PartyMember
function Osi.CombatGetInvolvedPartyMember(CombatID, PartyMemberIndex) end
	
--- @param Player string
--- @return integer CombatID
function Osi.CombatGetIDForCharacter(Player) end
	
--- @param CombatID integer
--- @return integer Active
function Osi.IsCombatActive(CombatID) end
	
--- @param CombatID integer
--- @return string CurrentEntity
function Osi.CombatGetActiveEntity(CombatID) end
	
--- @param Character string
--- @return string MultiplayerCharacter
function Osi.GetMultiplayerCharacter(Character) end
	
--- @return integer Bool
function Osi.HasKickstarterDialogReward() end
	
--- @return integer Bool
function Osi.IsHardcoreMode() end
	
--- @param Character string
--- @param DLCName string
--- @return integer HasDLC
function Osi.CharacterHasDLC(Character, DLCName) end
	
--- @return integer UserCount
function Osi.GetUserCount() end
	
--- @param Source string
--- @param VarName string
--- @return string UUID
function Osi.GetVarObject(Source, VarName) end
	
--- @param Source string
--- @param VarName string
--- @return integer VarValue
function Osi.GetVarInteger(Source, VarName) end
	
--- @param Source string
--- @param VarName string
--- @return number VarValue
function Osi.GetVarFloat(Source, VarName) end
	
--- @param Source string
--- @param VarName string
--- @return string VarValue
function Osi.GetVarString(Source, VarName) end
	
--- @param Source string
--- @param VarName string
--- @return string VarValue
function Osi.GetVarFixedString(Source, VarName) end
	
--- @param Target string
--- @param VarName string
--- @return number X
--- @return number Y
--- @return number Z
function Osi.GetVarFloat3(Target, VarName) end
	
--- @param Target string
--- @param Tag string
--- @return integer Bool
function Osi.IsTagged(Target, Tag) end
	
--- @param Target string
--- @param Status string
--- @return integer Bool
function Osi.HasActiveStatus(Target, Status) end
	
--- @param Target string
--- @param Status string
--- @return integer Bool
function Osi.HasAppliedStatus(Target, Status) end
	
--- @param Target string
--- @return string UUID
function Osi.GetUUID(Target) end
	
--- @param Target string
--- @return number X
--- @return number Y
--- @return number Z
function Osi.GetPosition(Target) end
	
--- @param Target string
--- @return number X
--- @return number Y
--- @return number Z
function Osi.GetRotation(Target) end
	
--- @param Target string
--- @return string Player
--- @return number Distance
function Osi.GetClosestPlayer(Target) end
	
--- @param Target string
--- @param Talent string
--- @return string Player
--- @return number Distance
function Osi.GetClosestPlayerWithTalent(Target, Talent) end
	
--- @param Target string
--- @return string Player
--- @return number Distance
function Osi.GetClosestAlivePlayer(Target) end
	
--- @param Target string
--- @param UserID integer
--- @return string Player
--- @return number Distance
function Osi.GetClosestAliveUserPlayer(Target, UserID) end
	
--- @param X number
--- @param Y number
--- @param Z number
--- @return string Player
--- @return number Distance
function Osi.GetClosestPlayerToPosition(X, Y, Z) end
	
--- @param Object string
--- @return string Region
function Osi.GetRegion(Object) end
	
--- @param UserId integer
--- @return string UserName
function Osi.GetUserName(UserId) end
	
--- @param UserId integer
--- @return string UserProfileID
function Osi.GetUserProfileID(UserId) end
	
--- @param CrimeID integer
--- @return string Type
function Osi.CrimeGetType(CrimeID) end
	
--- @param CrimeID integer
--- @return number Range
function Osi.CrimeGetDetectionRange(CrimeID) end
	
--- @param CrimeID integer
--- @return integer Tension
function Osi.CrimeGetTension(CrimeID) end
	
--- @return integer CrimeID
function Osi.CrimeGetNewID() end
	
--- @param Character string
--- @return integer Bool
function Osi.CrimeIsTensionOverWarningTreshold(Character) end
	
--- @param CrimeID integer
--- @param Searcher string
--- @param Criminal1 string
--- @param Criminal2 string
--- @param Criminal3 string
--- @param Criminal4 string
--- @return integer EvidenceFoundForCurrentCrime
--- @return integer EvidenceFound2
--- @return integer GuiltyFound
function Osi.CrimeFindEvidence(CrimeID, Searcher, Criminal1, Criminal2, Criminal3, Criminal4) end
	
--- @param CrimeID integer
--- @return string LeadInvestigator
function Osi.CrimeGetLeadInvestigator(CrimeID) end
	
--- @param Target string
--- @return integer Bool
function Osi.IsBoss(Target) end
	
--- @param object1 string
--- @param object2 string
--- @return number Dist
function Osi.GetDistanceTo(object1, object2) end
	
--- @param Object string
--- @param X number
--- @param Y number
--- @param Z number
--- @return number Dist
function Osi.GetDistanceToPosition(Object, X, Y, Z) end
	
--- @param x0 number
--- @param z0 number
--- @param x1 number
--- @param z1 number
--- @return integer Angle
function Osi.GetAngleTo(x0, z0, x1, z1) end
	
--- @param Object string
--- @param LocX number
--- @param LocY number
--- @param LocZ number
--- @param LocRotX number
--- @param LocRotY number
--- @param LocRotZ number
--- @return number WorldX
--- @return number WorldY
--- @return number WorldZ
--- @return number WorldRotX
--- @return number WorldRotY
--- @return number WorldRotZ
function Osi.GetWorldTransformFromLocal(Object, LocX, LocY, LocZ, LocRotX, LocRotY, LocRotZ) end
	
--- @param CrimeArea string
--- @return integer Modifier
function Osi.CrimeAreaGetTensionModifier(CrimeArea) end
	
--- @param CrimeID integer
--- @return string CrimeVictim
function Osi.CrimeGetVictim(CrimeID) end
	
--- @param CrimeID integer
--- @param Index integer
--- @return string Evidence
function Osi.CrimeGetEvidence(CrimeID, Index) end
	
--- @param CrimeID integer
--- @return integer NumEvidence
function Osi.CrimeGetNumberOfEvidence(CrimeID) end
	
--- @param CrimeID integer
--- @return integer Bool
function Osi.CrimeIsContinuous(CrimeID) end
	
--- @param CrimeID integer
--- @return string Criminal1
--- @return string Criminal2
--- @return string Criminal3
--- @return string Criminal4
function Osi.CrimeGetCriminals(CrimeID) end
	
--- @param Criminal string
--- @param CrimeType string
--- @param Victim string
--- @param X number
--- @param Y number
--- @param Z number
--- @return integer Bool
function Osi.CrimeIsAnyNPCGoingToReact(Criminal, CrimeType, Victim, X, Y, Z) end
	
--- @param OldLead string
--- @param CrimeID integer
--- @param NewLead string
--- @return integer Bool
function Osi.CrimeTransferLeadershipTo(OldLead, CrimeID, NewLead) end
	
--- @param CrimeID integer
--- @param Criminal string
--- @return integer Bool
function Osi.CrimeAddCriminal(CrimeID, Criminal) end
	
--- @param Target string
--- @return string Faction
function Osi.GetFaction(Target) end
	
--- @param Target string
--- @return string Template
function Osi.GetTemplate(Target) end
	
--- @param Character string
--- @param MinSafeDistance number
--- @return integer Bool
function Osi.HasEnemyInRange(Character, MinSafeDistance) end
	
--- @param Character string
--- @param Restconsumable string
--- @param PartyRadius number
--- @param MinSafeDistance number
--- @return integer Bool
function Osi.CanUserRest(Character, Restconsumable, PartyRadius, MinSafeDistance) end
	
--- @param Character string
--- @param SkillID string
--- @return integer Bool
function Osi.IsSkillActive(Character, SkillID) end
	
--- @param SkillID string
--- @return integer Bool
function Osi.IsSourceSkill(SkillID) end
	
--- @param StatusID string
--- @return string StatusType
function Osi.GetStatusType(StatusID) end
	
--- @param Source string
--- @param StatusID string
--- @return integer Turns
function Osi.GetStatusTurns(Source, StatusID) end
	
--- @param StatusID string
--- @return string HealStat
function Osi.GetHealStat(StatusID) end
	
--- @param LevelName string
--- @return integer Bool
function Osi.IsGameLevel(LevelName) end
	
--- @param LevelName string
--- @return integer Bool
function Osi.IsCharacterCreationLevel(LevelName) end
	
--- @param Player string
--- @param ItemTemplate string
--- @return integer Bool
function Osi.HasRecipeUnlockedWithIngredient(Player, ItemTemplate) end
	
--- @return integer Modifier
function Osi.GetGlobalPriceModifier() end
	
--- @param Difficulty string
--- @param Level integer
--- @return integer AttributeValue
function Osi.AttributeGetDifficultyLevelMappedValue(Difficulty, Level) end
	
--- @param Template string
--- @param Trigger string
--- @return integer Count
function Osi.CharacterTemplatesInTrigger(Template, Trigger) end
	
--- @param Trigger string
--- @return number X
--- @return number Y
--- @return number Z
function Osi.GetRandomPositionInTrigger(Trigger) end
	
--- @param StringA string
--- @param StringB string
--- @return string Result
function Osi.StringConcatenate(StringA, StringB) end
	
--- @param StringA string
--- @param StringB string
--- @return integer Bool
function Osi.StringContains(StringA, StringB) end
	
--- @param String string
--- @param Start integer
--- @param Count integer
--- @return string Result
function Osi.StringSub(String, Start, Count) end
	
--- @param Integer integer
--- @return string Result
function Osi.IntegertoString(Integer) end
	
--- @param GUIDstring string
--- @return string Result
function Osi.String(GUIDstring) end
	
--- @return integer Bool
function Osi.IsSwitch() end
	
--- @param Dialog string
--- @param MarkForInteractiveDialog integer
--- @param Speaker1 string
--- @param Speaker2 string
--- @param Speaker3 string
--- @param Speaker4 string
--- @param Speaker5 string
--- @param Speaker6 string
--- @return integer Success
function Osi.StartDialog_Internal(Dialog, MarkForInteractiveDialog, Speaker1, Speaker2, Speaker3, Speaker4, Speaker5, Speaker6) end
	
--- @param Dialog string
--- @param MarkForInteractiveDialog integer
--- @param Speaker1 string
--- @param Speaker2 string
--- @param Speaker3 string
--- @param Speaker4 string
--- @param Speaker5 string
--- @param Speaker6 string
--- @return integer Success
function Osi.StartDialog_Internal_NoDeadCheck(Dialog, MarkForInteractiveDialog, Speaker1, Speaker2, Speaker3, Speaker4, Speaker5, Speaker6) end
	
--- @param CrimeID integer
--- @param Dialog string
--- @param MarkForInteractiveDialog integer
--- @param NPC string
--- @param Criminal1 string
--- @param Criminal2 string
--- @param Criminal3 string
--- @param Criminal4 string
--- @return integer success
function Osi.DialogStartCrimeDialog(CrimeID, Dialog, MarkForInteractiveDialog, NPC, Criminal1, Criminal2, Criminal3, Criminal4) end
	
--- @param InstanceID integer
--- @return integer IsCrimeDialog
function Osi.DialogIsCrimeDialog(InstanceID) end
	
--- @param InstanceID integer
--- @param Actor string
--- @return integer success
function Osi.DialogRemoveActorFromDialog(InstanceID, Actor) end
	
--- @param Dialog string
--- @param ParentInstanceID integer
--- @param NewInstanceID integer
--- @param Player1 string
--- @param Player2 string
--- @param Player3 string
--- @param Player4 string
--- @return integer success
function Osi.DialogStartPartyDialog(Dialog, ParentInstanceID, NewInstanceID, Player1, Player2, Player3, Player4) end
	
--- @param Dialog string
--- @param ParentInstanceID integer
--- @param NewInstanceID integer
--- @param Player1 string
--- @param Player2 string
--- @param Player3 string
--- @param Player4 string
--- @return integer success
function Osi.DialogStartChildDialog(Dialog, ParentInstanceID, NewInstanceID, Player1, Player2, Player3, Player4) end
	
--- @param Speaker string
--- @return integer success
function Osi.IsSpeakerReserved(Speaker) end
	
--- @param Character string
--- @return integer HasDefaultDialog
function Osi.HasDefaultDialog(Character) end
	
--- @param Character string
--- @param Player string
--- @return string Dialog
--- @return integer Automated
function Osi.StartDefaultDialog(Character, Player) end
	
--- @param Number integer
--- @return string Value
function Osi.GetTextEventParamString(Number) end
	
--- @param Number integer
--- @return integer Value
function Osi.GetTextEventParamInteger(Number) end
	
--- @param Number integer
--- @return number Value
function Osi.GetTextEventParamReal(Number) end
	
--- @param Number integer
--- @return string Value
function Osi.GetTextEventParamUUID(Number) end

--- @param item string
--- @return integer
function Osi.ItemGetLevel(item) end

--#endregion

--#region Extender Calls/Queries

--- @param Message string
function Osi.NRD_DebugLog(Message) end
	
--- @param Event string
--- @param Count integer
function Osi.NRD_ForLoop(Event, Count) end
	
--- @param Object string
--- @param Event string
--- @param Count integer
function Osi.NRD_ForLoop(Object, Event, Count) end
	
--- @param ObjectGuid string
--- @param Event string
function Osi.NRD_IterateStatuses(ObjectGuid, Event) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @param Value integer
function Osi.NRD_StatusSetInt(Object, StatusHandle, Attribute, Value) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @param Value number
function Osi.NRD_StatusSetReal(Object, StatusHandle, Attribute, Value) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @param Value string
function Osi.NRD_StatusSetString(Object, StatusHandle, Attribute, Value) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @param Value string
function Osi.NRD_StatusSetGuidString(Object, StatusHandle, Attribute, Value) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @param X number
--- @param Y number
--- @param Z number
function Osi.NRD_StatusSetVector3(Object, StatusHandle, Attribute, X, Y, Z) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param PreventApply integer
function Osi.NRD_StatusPreventApply(Object, StatusHandle, PreventApply) end
	
--- @param GameActionHandle integer
function Osi.NRD_GameActionDestroy(GameActionHandle) end
	
--- @param GameActionHandle integer
--- @param LifeTime number
function Osi.NRD_GameActionSetLifeTime(GameActionHandle, LifeTime) end
	

function Osi.NRD_ProjectilePrepareLaunch() end
	

function Osi.NRD_ProjectileLaunch() end
	
--- @param Property string
--- @param Value integer
function Osi.NRD_ProjectileSetInt(Property, Value) end
	
--- @param Property string
--- @param Value string
function Osi.NRD_ProjectileSetString(Property, Value) end
	
--- @param Property string
--- @param X number
--- @param Y number
--- @param Z number
function Osi.NRD_ProjectileSetVector3(Property, X, Y, Z) end
	
--- @param Property string
--- @param Value string
function Osi.NRD_ProjectileSetGuidString(Property, Value) end
	
--- @param DamageType string
--- @param Amount integer
function Osi.NRD_ProjectileAddDamage(DamageType, Amount) end
	
--- @param HitHandle integer
function Osi.NRD_HitExecute(HitHandle) end
	
--- @param HitHandle integer
--- @param Property string
--- @param Value integer
function Osi.NRD_HitSetInt(HitHandle, Property, Value) end
	
--- @param HitHandle integer
--- @param Property string
--- @param Value string
function Osi.NRD_HitSetString(HitHandle, Property, Value) end
	
--- @param HitHandle integer
--- @param Property string
--- @param X number
--- @param Y number
--- @param Z number
function Osi.NRD_HitSetVector3(HitHandle, Property, X, Y, Z) end
	
--- @param HitHandle integer
function Osi.NRD_HitClearAllDamage(HitHandle) end
	
--- @param HitHandle integer
--- @param DamageType string
function Osi.NRD_HitClearDamage(HitHandle, DamageType) end
	
--- @param HitHandle integer
--- @param DamageType string
--- @param Amount integer
function Osi.NRD_HitAddDamage(HitHandle, DamageType, Amount) end
	
--- @param Object string
--- @param StatusHandle integer
function Osi.NRD_HitStatusClearAllDamage(Object, StatusHandle) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param DamageType string
function Osi.NRD_HitStatusClearDamage(Object, StatusHandle, DamageType) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param DamageType string
--- @param Amount integer
function Osi.NRD_HitStatusAddDamage(Object, StatusHandle, DamageType, Amount) end
	
--- @param Character string
--- @param SkillId string
--- @param Cooldown number
function Osi.NRD_SkillSetCooldown(Character, SkillId, Cooldown) end
	
--- @param Character string
--- @param Slot integer
--- @param SkillId string
function Osi.NRD_SkillBarSetSkill(Character, Slot, SkillId) end
	
--- @param Character string
--- @param Slot integer
--- @param Item string
function Osi.NRD_SkillBarSetItem(Character, Slot, Item) end
	
--- @param Character string
--- @param Slot integer
function Osi.NRD_SkillBarClear(Character, Slot) end
	
--- @param Player string
--- @param Attribute string
--- @param Value integer
function Osi.NRD_PlayerSetBaseAttribute(Player, Attribute, Value) end
	
--- @param Player string
--- @param Ability string
--- @param Value integer
function Osi.NRD_PlayerSetBaseAbility(Player, Ability, Value) end
	
--- @param Player string
--- @param Talent string
--- @param HasTalent integer
function Osi.NRD_PlayerSetBaseTalent(Player, Talent, HasTalent) end
	
--- @param Player string
--- @param Property string
--- @param Value integer
function Osi.NRD_PlayerSetCustomDataInt(Player, Property, Value) end
	
--- @param Player string
--- @param Property string
--- @param Value string
function Osi.NRD_PlayerSetCustomDataString(Player, Property, Value) end
	
--- @param Item string
--- @param EventName string
function Osi.NRD_ItemIterateDeltaModifiers(Item, EventName) end
	
--- @param Item string
--- @param IsIdentified integer
function Osi.NRD_ItemSetIdentified(Item, IsIdentified) end
	
--- @param Item string
--- @param Stat string
--- @param Value integer
function Osi.NRD_ItemSetPermanentBoostInt(Item, Stat, Value) end
	
--- @param Item string
--- @param Stat string
--- @param Value number
function Osi.NRD_ItemSetPermanentBoostReal(Item, Stat, Value) end
	
--- @param Item string
--- @param Stat string
--- @param Value string
function Osi.NRD_ItemSetPermanentBoostString(Item, Stat, Value) end
	
--- @param Item string
--- @param Ability string
--- @param Points integer
function Osi.NRD_ItemSetPermanentBoostAbility(Item, Ability, Points) end
	
--- @param Item string
--- @param Talent string
--- @param HasTalent integer
function Osi.NRD_ItemSetPermanentBoostTalent(Item, Talent, HasTalent) end
	
--- @param TemplateGuid string
function Osi.NRD_ItemConstructBegin(TemplateGuid) end
	
--- @param Item string
function Osi.NRD_ItemCloneBegin(Item) end
	
--- @param Property string
--- @param Value integer
function Osi.NRD_ItemCloneSetInt(Property, Value) end
	
--- @param Property string
--- @param Value string
function Osi.NRD_ItemCloneSetString(Property, Value) end
	

function Osi.NRD_ItemCloneResetProgression() end
	
--- @param BoostType string
--- @param Boost2 string
function Osi.NRD_ItemCloneAddBoost(BoostType, Boost2) end
	
--- @param Character string
--- @param Stat string
--- @param Value integer
function Osi.NRD_CharacterSetStatInt(Character, Stat, Value) end
	
--- @param Character string
--- @param Stat string
--- @param Value integer
function Osi.NRD_CharacterSetPermanentBoostInt(Character, Stat, Value) end
	
--- @param Character string
--- @param Talent string
--- @param HasTalent integer
function Osi.NRD_CharacterSetPermanentBoostTalent(Character, Talent, HasTalent) end
	
--- @param Character string
--- @param Talent string
--- @param IsDisabled integer
function Osi.NRD_CharacterDisableTalent(Character, Talent, IsDisabled) end
	
--- @param Character string
--- @param IsGlobal integer
function Osi.NRD_CharacterSetGlobal(Character, IsGlobal) end
	
--- @param Character string
--- @param Event string
function Osi.NRD_CharacterIterateSkills(Character, Event) end
	
--- @param Character string
--- @param Item string
--- @param Slot string
--- @param ConsumeAP integer
--- @param CheckRequirements integer
--- @param UpdateVitality integer
--- @param UseWeaponAnimType integer
function Osi.NRD_CharacterEquipItem(Character, Item, Slot, ConsumeAP, CheckRequirements, UpdateVitality, UseWeaponAnimType) end
	
--- @param Object string
--- @param Flag integer
--- @param Value integer
function Osi.NRD_ObjectSetInternalFlag(Object, Flag, Value) end
	
--- @param Character string
--- @param StatId string
--- @param Value integer
function Osi.NRD_CharacterSetCustomStat(Character, StatId, Value) end
	
--- @param BootstrapMods integer
function Osi.NRD_LuaReset(BootstrapMods) end
	
--- @param BootstrapMods integer
--- @param ResetServer integer
--- @param ResetClient integer
function Osi.NRD_LuaReset(BootstrapMods, ResetServer, ResetClient) end
	
--- @param ModNameGuid string
--- @param FileName string
function Osi.NRD_LuaLoad(ModNameGuid, FileName) end
	
--- @param Func string
function Osi.NRD_LuaCall(Func) end
	
--- @param Func string
--- @param Arg1 string
function Osi.NRD_LuaCall(Func, Arg1) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2, Arg3) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
function Osi.NRD_LuaCall(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Mod string
--- @param Func string
function Osi.NRD_ModCall(Mod, Func) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
function Osi.NRD_ModCall(Mod, Func, Arg1) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2, Arg3) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
function Osi.NRD_ModCall(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Character string
function Osi.NRD_BreakOnCharacter(Character) end
	
--- @param Item string
function Osi.NRD_BreakOnItem(Item) end
	
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
function Osi.NRD_Experiment(Arg1, Arg2, Arg3) end
	
--- @param Message string
function Osi.NRD_ShowErrorMessage(Message) end
	
--- @param Path string
--- @param Contents string
function Osi.NRD_SaveFile(Path, Contents) end
	
--- @param A string
--- @param B string
--- @return integer Result
function Osi.NRD_StringCompare(A, B) end
	
--- @param String string
--- @return integer Length
function Osi.NRD_StringLength(String) end
	
--- @param Format string
--- @return string Result
function Osi.NRD_StringFormat(Format) end
	
--- @param Format string
--- @param Arg1 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2, Arg3) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Format string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Result
function Osi.NRD_StringFormat(Format, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param String string
--- @param From integer
--- @param Length integer
--- @return string Result
function Osi.NRD_Substring(String, From, Length) end
	
--- @param String string
--- @param Regex string
--- @param FullMatch integer
--- @return integer Matched
function Osi.NRD_RegexMatch(String, Regex, FullMatch) end
	
--- @param String string
--- @param Regex string
--- @param Replacement string
--- @return string Result
function Osi.NRD_RegexReplace(String, Regex, Replacement) end
	
--- @param String string
--- @return integer Result
function Osi.NRD_StringToInt(String) end
	
--- @param String string
--- @return number Result
function Osi.NRD_StringToReal(String) end
	
--- @param String string
--- @return string Result
function Osi.NRD_GuidString(String) end
	
--- @param Real number
--- @return string Result
function Osi.NRD_RealToString(Real) end
	
--- @param Integer integer
--- @return string Result
function Osi.NRD_IntegerToString(Integer) end
	
--- @param Min number
--- @param Max number
--- @return number Result
function Osi.NRD_RandomReal(Min, Max) end
	
--- @param In integer
--- @return integer Out
function Osi.NRD_Factorial(In) end
	
--- @param Base number
--- @param Exp integer
--- @return number Out
function Osi.NRD_Pow(Base, Exp) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Sin(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Cos(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Tan(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Round(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Ceil(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Floor(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Abs(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Sqrt(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Exp(In) end
	
--- @param In number
--- @return number Out
function Osi.NRD_Log(In) end
	
--- @param Numerator integer
--- @param Denominator integer
--- @return integer Divisible
function Osi.NRD_IsDivisible(Numerator, Denominator) end
	
--- @param StatsId string
function Osi.NRD_StatExists(StatsId) end
	
--- @param StatsId string
--- @param Attribute string
function Osi.NRD_StatAttributeExists(StatsId, Attribute) end
	
--- @param StatsId string
--- @param Attribute string
--- @return integer Value
function Osi.NRD_StatGetInt(StatsId, Attribute) end
	
--- @param StatsId string
--- @param Attribute string
--- @return string Value
function Osi.NRD_StatGetString(StatsId, Attribute) end
	
--- @param StatsId string
--- @return string Type
function Osi.NRD_StatGetType(StatsId) end
	
--- @param Key string
--- @return number Value
function Osi.NRD_StatGetExtraData(Key) end
	
--- @param Object string
--- @param StatusType string
--- @return integer HasStatus
function Osi.NRD_ObjectHasStatusType(Object, StatusType) end
	
--- @param Object string
--- @param StatusId string
--- @return integer StatusHandle
function Osi.NRD_StatusGetHandle(Object, StatusId) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @return integer Value
function Osi.NRD_StatusGetInt(Object, StatusHandle, Attribute) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @return number Value
function Osi.NRD_StatusGetReal(Object, StatusHandle, Attribute) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @return string Value
function Osi.NRD_StatusGetString(Object, StatusHandle, Attribute) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param Attribute string
--- @return string Value
function Osi.NRD_StatusGetGuidString(Object, StatusHandle, Attribute) end
	
--- @param Character string
--- @param StatusId string
--- @param LifeTime number
--- @return integer StatusHandle
function Osi.NRD_ApplyActiveDefense(Character, StatusId, LifeTime) end
	
--- @param Character string
--- @param StatusId string
--- @param SourceCharacter string
--- @param LifeTime number
--- @param DistancePerDamage number
--- @return integer StatusHandle
function Osi.NRD_ApplyDamageOnMove(Character, StatusId, SourceCharacter, LifeTime, DistancePerDamage) end
	
--- @param Character string
--- @return string Action
function Osi.NRD_CharacterGetCurrentAction(Character) end
	
--- @param Character string
--- @param Property string
--- @return string Value
function Osi.NRD_ActionStateGetString(Character, Property) end
	
--- @param OwnerCharacter string
--- @param SkillId string
--- @param X number
--- @param Y number
--- @param Z number
--- @return integer GameActionHandle
function Osi.NRD_CreateRain(OwnerCharacter, SkillId, X, Y, Z) end
	
--- @param OwnerCharacter string
--- @param SkillId string
--- @param X number
--- @param Y number
--- @param Z number
--- @return integer GameActionHandle
function Osi.NRD_CreateStorm(OwnerCharacter, SkillId, X, Y, Z) end
	
--- @param OwnerCharacter string
--- @param SkillId string
--- @param SourceX number
--- @param SourceY number
--- @param SourceZ number
--- @param TargetX number
--- @param TargetY number
--- @param TargetZ number
--- @return integer GameActionHandle
function Osi.NRD_CreateWall(OwnerCharacter, SkillId, SourceX, SourceY, SourceZ, TargetX, TargetY, TargetZ) end
	
--- @param OwnerCharacter string
--- @param SkillId string
--- @param PositionX number
--- @param PositionY number
--- @param PositionZ number
--- @param TargetX number
--- @param TargetY number
--- @param TargetZ number
--- @return integer GameActionHandle
function Osi.NRD_CreateTornado(OwnerCharacter, SkillId, PositionX, PositionY, PositionZ, TargetX, TargetY, TargetZ) end
	
--- @param OwnerCharacter string
--- @param SkillId string
--- @param X number
--- @param Y number
--- @param Z number
--- @return integer GameActionHandle
function Osi.NRD_CreateDome(OwnerCharacter, SkillId, X, Y, Z) end
	
--- @param TargetObject string
--- @param X number
--- @param Y number
--- @param Z number
--- @param BeamEffectName string
--- @param CasterCharacter string
--- @return integer GameActionHandle
function Osi.NRD_CreateGameObjectMove(TargetObject, X, Y, Z, BeamEffectName, CasterCharacter) end
	
--- @param GameActionHandle integer
--- @return number LifeTime
function Osi.NRD_GameActionGetLifeTime(GameActionHandle) end
	
--- @param OwnerCharacter string
--- @param Template string
--- @param X number
--- @param Y number
--- @param Z number
--- @param Lifetime number
--- @param Level integer
--- @param IsTotem integer
--- @param MapToAiGrid integer
--- @return string Summon
function Osi.NRD_Summon(OwnerCharacter, Template, X, Y, Z, Lifetime, Level, IsTotem, MapToAiGrid) end
	
--- @param Target string
--- @param Source string
--- @return integer HitHandle
function Osi.NRD_HitPrepare(Target, Source) end
	
--- @param HitHandle integer
--- @return integer StatusHandle
function Osi.NRD_HitQryExecute(HitHandle) end
	
--- @param HitHandle integer
--- @param Property string
--- @return integer Value
function Osi.NRD_HitGetInt(HitHandle, Property) end
	
--- @param HitHandle integer
--- @param Property string
--- @return string Value
function Osi.NRD_HitGetString(HitHandle, Property) end
	
--- @param HitHandle integer
--- @param DamageType string
--- @return integer Amount
function Osi.NRD_HitGetDamage(HitHandle, DamageType) end
	
--- @param Object string
--- @param StatusHandle integer
--- @param DamageType string
--- @return integer Amount
function Osi.NRD_HitStatusGetDamage(Object, StatusHandle, DamageType) end
	
--- @param Character string
--- @param SkillId string
--- @return number Cooldown
function Osi.NRD_SkillGetCooldown(Character, SkillId) end
	
--- @param Character string
--- @param SkillId string
--- @param Property string
--- @return integer Value
function Osi.NRD_SkillGetInt(Character, SkillId, Property) end
	
--- @param Character string
--- @param Slot integer
--- @return string Item
function Osi.NRD_SkillBarGetItem(Character, Slot) end
	
--- @param Character string
--- @param Slot integer
--- @return string Skill
function Osi.NRD_SkillBarGetSkill(Character, Slot) end
	
--- @param Character string
--- @param Skill string
--- @return integer Slot
function Osi.NRD_SkillBarFindSkill(Character, Skill) end
	
--- @param Character string
--- @param Item string
--- @return integer Slot
function Osi.NRD_SkillBarFindItem(Character, Item) end
	
--- @param Player string
--- @param Property string
--- @return integer Value
function Osi.NRD_PlayerGetCustomDataInt(Player, Property) end
	
--- @param Player string
--- @param Property string
--- @return string Value
function Osi.NRD_PlayerGetCustomDataString(Player, Property) end
	
--- @param Item string
--- @return string StatsId
function Osi.NRD_ItemGetStatsId(Item) end
	
--- @param Item string
--- @return string Base
--- @return string ItemType
--- @return integer Level
function Osi.NRD_ItemGetGenerationParams(Item) end
	
--- @param Item string
--- @return string Base
--- @return string ItemType
--- @return integer Level
--- @return integer Random
function Osi.NRD_ItemGetGenerationParams(Item) end
	
--- @param Item string
--- @return string DeltaMod
--- @return integer Count
function Osi.NRD_ItemHasDeltaModifier(Item) end
	
--- @param Item string
--- @return string Parent
function Osi.NRD_ItemGetParent(Item) end
	
--- @param Item string
--- @param Property string
--- @return integer Value
function Osi.NRD_ItemGetInt(Item, Property) end
	
--- @param Item string
--- @param Property string
--- @return string Value
function Osi.NRD_ItemGetString(Item, Property) end
	
--- @param Item string
--- @param Property string
--- @return string Value
function Osi.NRD_ItemGetGuidString(Item, Property) end
	
--- @param Item string
--- @param Stat string
--- @return integer Value
function Osi.NRD_ItemGetPermanentBoostInt(Item, Stat) end
	
--- @param Item string
--- @param Stat string
--- @return number Value
function Osi.NRD_ItemGetPermanentBoostReal(Item, Stat) end
	
--- @param Item string
--- @param Stat string
--- @return string Value
function Osi.NRD_ItemGetPermanentBoostString(Item, Stat) end
	
--- @param Item string
--- @param Ability string
--- @return integer Points
function Osi.NRD_ItemGetPermanentBoostAbility(Item, Ability) end
	
--- @param Item string
--- @param Talent string
--- @return integer HasTalent
function Osi.NRD_ItemGetPermanentBoostTalent(Item, Talent) end
	
--- @return string NewItem
function Osi.NRD_ItemClone() end
	
--- @param Character string
--- @param Stat string
--- @param ExcludeBoosts integer
--- @return integer Value
function Osi.NRD_CharacterGetComputedStat(Character, Stat, ExcludeBoosts) end
	
--- @param Attacker string
--- @param Target string
--- @return integer HitChance
function Osi.NRD_CharacterGetHitChance(Attacker, Target) end
	
--- @param Character string
--- @param Stat string
--- @return integer Value
function Osi.NRD_CharacterGetStatInt(Character, Stat) end
	
--- @param Character string
--- @param Stat string
--- @return string Value
function Osi.NRD_CharacterGetStatString(Character, Stat) end
	
--- @param Character string
--- @param Stat string
--- @return integer Value
function Osi.NRD_CharacterGetPermanentBoostInt(Character, Stat) end
	
--- @param Character string
--- @param Talent string
--- @return integer IsDisabled
function Osi.NRD_CharacterIsTalentDisabled(Character, Talent) end
	
--- @param Character string
--- @param Attribute string
--- @return integer Value
function Osi.NRD_CharacterGetInt(Character, Attribute) end
	
--- @param Character string
--- @param Attribute string
--- @return number Value
function Osi.NRD_CharacterGetReal(Character, Attribute) end
	
--- @param Character string
--- @param Attribute string
--- @return string Value
function Osi.NRD_CharacterGetString(Character, Attribute) end
	
--- @param Object string
--- @param Flag integer
--- @return integer Value
function Osi.NRD_ObjectGetInternalFlag(Object, Flag) end
	
--- @param Character string
--- @param StatId string
--- @return integer Value
function Osi.NRD_CharacterGetCustomStat(Character, StatId) end
	
--- @param Name string
--- @param Description string
--- @return string StatId
function Osi.NRD_CreateCustomStat(Name, Description) end
	
--- @param Name string
--- @return string StatId
function Osi.NRD_GetCustomStat(Name) end
	
--- @param Func string
function Osi.NRD_LuaQuery0(Func) end
	
--- @param Func string
--- @return string Out1
function Osi.NRD_LuaQuery0(Func) end
	
--- @param Func string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery0(Func) end
	
--- @param Func string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery0(Func) end
	
--- @param Func string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery0(Func) end
	
--- @param Func string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery0(Func) end
	
--- @param Func string
--- @param Arg1 string
function Osi.NRD_LuaQuery1(Func, Arg1) end
	
--- @param Func string
--- @param Arg1 string
--- @return string Out1
function Osi.NRD_LuaQuery1(Func, Arg1) end
	
--- @param Func string
--- @param Arg1 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery1(Func, Arg1) end
	
--- @param Func string
--- @param Arg1 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery1(Func, Arg1) end
	
--- @param Func string
--- @param Arg1 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery1(Func, Arg1) end
	
--- @param Func string
--- @param Arg1 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery1(Func, Arg1) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
function Osi.NRD_LuaQuery2(Func, Arg1, Arg2) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
function Osi.NRD_LuaQuery2(Func, Arg1, Arg2) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery2(Func, Arg1, Arg2) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery2(Func, Arg1, Arg2) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery2(Func, Arg1, Arg2) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery2(Func, Arg1, Arg2) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
function Osi.NRD_LuaQuery3(Func, Arg1, Arg2, Arg3) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
function Osi.NRD_LuaQuery3(Func, Arg1, Arg2, Arg3) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery3(Func, Arg1, Arg2, Arg3) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery3(Func, Arg1, Arg2, Arg3) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery3(Func, Arg1, Arg2, Arg3) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery3(Func, Arg1, Arg2, Arg3) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
function Osi.NRD_LuaQuery4(Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
function Osi.NRD_LuaQuery4(Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery4(Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery4(Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery4(Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery4(Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
function Osi.NRD_LuaQuery5(Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
function Osi.NRD_LuaQuery5(Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery5(Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery5(Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery5(Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery5(Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
function Osi.NRD_LuaQuery6(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
function Osi.NRD_LuaQuery6(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery6(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery6(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery6(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery6(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
function Osi.NRD_LuaQuery7(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
function Osi.NRD_LuaQuery7(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery7(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery7(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery7(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery7(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
function Osi.NRD_LuaQuery8(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
function Osi.NRD_LuaQuery8(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery8(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery8(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery8(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery8(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
function Osi.NRD_LuaQuery9(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
function Osi.NRD_LuaQuery9(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery9(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery9(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery9(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery9(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
function Osi.NRD_LuaQuery10(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
function Osi.NRD_LuaQuery10(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_LuaQuery10(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_LuaQuery10(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_LuaQuery10(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_LuaQuery10(Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Mod string
--- @param Func string
function Osi.NRD_ModQuery0(Mod, Func) end
	
--- @param Mod string
--- @param Func string
--- @return string Out1
function Osi.NRD_ModQuery0(Mod, Func) end
	
--- @param Mod string
--- @param Func string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery0(Mod, Func) end
	
--- @param Mod string
--- @param Func string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery0(Mod, Func) end
	
--- @param Mod string
--- @param Func string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery0(Mod, Func) end
	
--- @param Mod string
--- @param Func string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery0(Mod, Func) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
function Osi.NRD_ModQuery1(Mod, Func, Arg1) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @return string Out1
function Osi.NRD_ModQuery1(Mod, Func, Arg1) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery1(Mod, Func, Arg1) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery1(Mod, Func, Arg1) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery1(Mod, Func, Arg1) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery1(Mod, Func, Arg1) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
function Osi.NRD_ModQuery2(Mod, Func, Arg1, Arg2) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
function Osi.NRD_ModQuery2(Mod, Func, Arg1, Arg2) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery2(Mod, Func, Arg1, Arg2) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery2(Mod, Func, Arg1, Arg2) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery2(Mod, Func, Arg1, Arg2) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery2(Mod, Func, Arg1, Arg2) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
function Osi.NRD_ModQuery3(Mod, Func, Arg1, Arg2, Arg3) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
function Osi.NRD_ModQuery3(Mod, Func, Arg1, Arg2, Arg3) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery3(Mod, Func, Arg1, Arg2, Arg3) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery3(Mod, Func, Arg1, Arg2, Arg3) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery3(Mod, Func, Arg1, Arg2, Arg3) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery3(Mod, Func, Arg1, Arg2, Arg3) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
function Osi.NRD_ModQuery4(Mod, Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
function Osi.NRD_ModQuery4(Mod, Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery4(Mod, Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery4(Mod, Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery4(Mod, Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery4(Mod, Func, Arg1, Arg2, Arg3, Arg4) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
function Osi.NRD_ModQuery5(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
function Osi.NRD_ModQuery5(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery5(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery5(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery5(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery5(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
function Osi.NRD_ModQuery6(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
function Osi.NRD_ModQuery6(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery6(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery6(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery6(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery6(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
function Osi.NRD_ModQuery7(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
function Osi.NRD_ModQuery7(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery7(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery7(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery7(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery7(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
function Osi.NRD_ModQuery8(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
function Osi.NRD_ModQuery8(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery8(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery8(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery8(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery8(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
function Osi.NRD_ModQuery9(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
function Osi.NRD_ModQuery9(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery9(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery9(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery9(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery9(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
function Osi.NRD_ModQuery10(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
function Osi.NRD_ModQuery10(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
--- @return string Out2
function Osi.NRD_ModQuery10(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
function Osi.NRD_ModQuery10(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
function Osi.NRD_ModQuery10(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param Mod string
--- @param Func string
--- @param Arg1 string
--- @param Arg2 string
--- @param Arg3 string
--- @param Arg4 string
--- @param Arg5 string
--- @param Arg6 string
--- @param Arg7 string
--- @param Arg8 string
--- @param Arg9 string
--- @param Arg10 string
--- @return string Out1
--- @return string Out2
--- @return string Out3
--- @return string Out4
--- @return string Out5
function Osi.NRD_ModQuery10(Mod, Func, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10) end
	
--- @param ModGUID string
--- @return integer IsLoaded
function Osi.NRD_IsModLoaded(ModGUID) end
	
--- @return integer Version
function Osi.NRD_GetVersion() end
	
--- @param Path string
--- @return string Contents
function Osi.NRD_LoadFile(Path) end

--#endregion

