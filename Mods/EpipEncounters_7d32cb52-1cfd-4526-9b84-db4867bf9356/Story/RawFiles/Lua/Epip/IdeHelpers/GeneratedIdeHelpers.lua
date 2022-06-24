--- @alias CString string
--- @alias ComponentHandle number
--- @alias EntityHandle number
--- @alias FixedString string
--- @alias IggyInvokeDataValue any
--- @alias NetId number
--- @alias Path string
--- @alias STDString string
--- @alias STDWString string
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
--- @alias ivec2 int32[]
--- @alias vec2 float[]
--- @alias vec3 float[]
--- @alias vec4 float[]


--- @alias AIFlags string | "'StatusIsSecondary'" | "'CanNotUse'" | "'CanNotTargetFrozen'" | "'IgnoreSelf'" | "'IgnoreDebuff'" | "'IgnoreBuff'" | "'IgnoreControl'"
--- @alias ActionDataType string | "'Lockpick'" | "'Sticky'" | "'Unknown'" | "'Craft'" | "'Lying'" | "'StoryUseInInventoryOnly'" | "'Door'" | "'Pyramid'" | "'DestroyParameters'" | "'Recipe'" | "'Equip'" | "'Consume'" | "'Repair'" | "'OpenClose'" | "'Teleport'" | "'CreateSurface'" | "'Book'" | "'StoryUse'" | "'KickstarterMessageInABottle'" | "'CreatePuddle'" | "'StoryUseInInventory'" | "'UseSkill'" | "'Sit'" | "'SkillBook'" | "'Identify'" | "'Ladder'" | "'PlaySound'" | "'DisarmTrap'" | "'SpawnCharacter'" | "'Constrain'" | "'ShowStoryElementUI'" | "'Destroy'"
--- @alias AiActionStep string | "'CollectPossibleActions'" | "'CalculateFutureScores'" | "'CalculateSkills'" | "'ScoreActionsBehavior'" | "'CalculateItems'" | "'SortActions'" | "'CalculateStandardAttack'" | "'ScoreActions'" | "'Init'" | "'ScoreActionsFallback'" | "'CalculatePositionScores'" | "'ReevaluateActions'" | "'ScoreActionsAPSaving'"
--- @alias AiActionType string | "'StandardAttack'" | "'FallbackCommand'" | "'Skill'" | "'Consume'" | "'None'"
--- @alias AiModifier string | "'MULTIPLIER_DAMAGE_NEUTRAL_POS'" | "'MULTIPLIER_BOOST_ALLY_NEG'" | "'MULTIPLIER_SCORE_ON_NEUTRAL'" | "'MULTIPLIER_SURFACE_STATUS_ON_MOVE'" | "'MULTIPLIER_BLIND'" | "'MULTIPLIER_FIRST_ACTION_BUFF'" | "'MULTIPLIER_DOT_ENEMY_NEG'" | "'MULTIPLIER_COOLDOWN_MULTIPLIER'" | "'MULTIPLIER_DECAYING_TOUCH'" | "'MULTIPLIER_DEATH_RESIST'" | "'MULTIPLIER_COMBO_SCORE_POSITIONING'" | "'MULTIPLIER_HOT_ALLY_POS'" | "'MULTIPLIER_CONTROL_ALLY_POS'" | "'MULTIPLIER_ENDPOS_STENCH'" | "'MULTIPLIER_RESISTANCE'" | "'MULTIPLIER_CONTACT_BOOST'" | "'CHARMED_MAX_CONSUMABLES_PER_TURN'" | "'MULTIPLIER_HEAL_SELF_POS'" | "'MULTIPLIER_BOOST_NEUTRAL_NEG'" | "'MAX_SCORE_ON_NEUTRAL'" | "'MULTIPLIER_MAIN_ATTRIB'" | "'MULTIPLIER_DOT_NEUTRAL_NEG'" | "'MULTIPLIER_LOW_ITEM_AMOUNT_MULTIPLIER'" | "'MULTIPLIER_TARGET_MY_HOSTILE'" | "'MULTIPLIER_SCORE_OUT_OF_COMBAT'" | "'MULTIPLIER_INCAPACITATE'" | "'MULTIPLIER_ACTIVE_DEFENSE'" | "'MULTIPLIER_CONTROL_NEUTRAL_POS'" | "'MULTIPLIER_ENDPOS_ENEMIES_NEARBY'" | "'MULTIPLIER_ENDPOS_NOT_IN_AIHINT'" | "'MULTIPLIER_DISARMED'" | "'TURNS_REPLACEMENT_INFINITE'" | "'MULTIPLIER_HEAL_ENEMY_POS'" | "'MULTIPLIER_DOT_ALLY_NEG'" | "'MULTIPLIER_ARMOR_SELF_NEG'" | "'MULTIPLIER_EXPLOSION_DISTANCE_MIN'" | "'MULTIPLIER_CRITICAL'" | "'MULTIPLIER_HOT_ENEMY_NEG'" | "'MULTIPLIER_TARGET_AGGRO_MARKED'" | "'DANGEROUS_ITEM_NEARBY'" | "'MULTIPLIER_VITALITYBOOST'" | "'SKILL_JUMP_MINIMUM_DISTANCE'" | "'MULTIPLIER_AP_COSTBOOST'" | "'MULTIPLIER_COMBO_SCORE_INTERACTION'" | "'MULTIPLIER_DAMAGE_SELF_NEG'" | "'MULTIPLIER_BOOST_SELF_POS'" | "'FALLBACK_WANTED_ENEMY_DISTANCE'" | "'MULTIPLIER_KILL_ENEMY'" | "'MULTIPLIER_POSITION_LEAVE'" | "'MULTIPLIER_MAGICAL_SULFUR_CURRENTLY_DAM'" | "'UNSTABLE_BOMB_RADIUS'" | "'MULTIPLIER_HEAL_ALLY_POS'" | "'MULTIPLIER_ARMOR_ENEMY_NEG'" | "'MULTIPLIER_SCORE_ON_ALLY'" | "'SURFACE_DAMAGE_MAX_TURNS'" | "'MULTIPLIER_INVISIBLE'" | "'SCORE_MOD'" | "'MULTIPLIER_DOT_SELF_POS'" | "'MULTIPLIER_HOT_NEUTRAL_NEG'" | "'MULTIPLIER_SOURCE_COST_MULTIPLIER'" | "'MULTIPLIER_TARGET_INCAPACITATED'" | "'MULTIPLIER_RESURRECT'" | "'MULTIPLIER_ADD_MAGIC_ARMOR'" | "'MULTIPLIER_DAMAGE_ENEMY_NEG'" | "'MULTIPLIER_HOT_ALLY_NEG'" | "'MULTIPLIER_BOOST_ENEMY_POS'" | "'MULTIPLIER_TARGET_HOSTILE_COUNT_TWO_OR_'" | "'MULTIPLIER_FEAR'" | "'MULTIPLIER_AP_RECOVERY'" | "'ENABLE_SAVING_ACTION_POINTS'" | "'MULTIPLIER_HEAL_NEUTRAL_POS'" | "'MULTIPLIER_ARMOR_ALLY_NEG'" | "'MOVESKILL_ITEM_AP_DIFF_REQUIREMENT'" | "'MAX_HEAL_MULTIPLIER'" | "'MULTIPLIER_STATUS_FAILED'" | "'MULTIPLIER_MUTE'" | "'MULTIPLIER_GROUNDED'" | "'MULTIPLIER_CONTROL_SELF_NEG'" | "'MULTIPLIER_TARGET_PREFERRED'" | "'MULTIPLIER_KILL_ENEMY_SUMMON'" | "'MULTIPLIER_KNOCKDOWN'" | "'MULTIPLIER_SURFACE_REMOVE'" | "'MULTIPLIER_DESTROY_INTERESTING_ITEM'" | "'BUFF_DIST_MAX'" | "'MULTIPLIER_DAMAGE_ALLY_NEG'" | "'MULTIPLIER_BOOST_ALLY_POS'" | "'MULTIPLIER_WINDWALKER'" | "'BUFF_DIST_MIN'" | "'ENABLE_ACTIVE_DEFENSE_OFFENSIVE_USE'" | "'MULTIPLIER_MAGICAL_SULFUR'" | "'MULTIPLIER_DOT_ENEMY_POS'" | "'MULTIPLIER_HOT_SELF_POS'" | "'MULTIPLIER_ARMOR_NEUTRAL_NEG'" | "'MULTIPLIER_SHACKLES_OF_PAIN'" | "'MULTIPLIER_ACC_BOOST'" | "'MULTIPLIER_CONTROL_ENEMY_NEG'" | "'MULTIPLIER_INVISIBLE_MOVEMENT_COST_MULT'" | "'MULTIPLIER_ENDPOS_ALLIES_NEARBY'" | "'FALLBACK_ALLIES_NEARBY'" | "'MULTIPLIER_SOURCE_POINT'" | "'MULTIPLIER_SECONDARY_ATTRIB'" | "'MULTIPLIER_DAMAGE_NEUTRAL_NEG'" | "'MULTIPLIER_BOOST_NEUTRAL_POS'" | "'MULTIPLIER_TARGET_HOSTILE_COUNT_ONE'" | "'MULTIPLIER_KILL_ALLY'" | "'TARGET_WEAK_ALLY'" | "'AVENGE_ME_VITALITY_LEVEL'" | "'MULTIPLIER_DOT_NEUTRAL_POS'" | "'MULTIPLIER_TARGET_MY_ENEMY'" | "'MULTIPLIER_ENDPOS_NOT_IN_DANGEROUS_SURF'" | "'MULTIPLIER_SOURCE_MUTE'" | "'MULTIPLIER_GUARDIAN_ANGEL'" | "'MULTIPLIER_DOT_SELF_NEG'" | "'MULTIPLIER_CONTROL_ALLY_NEG'" | "'MULTIPLIER_ENDPOS_FLANKED'" | "'MULTIPLIER_STATUS_CANCEL_SLEEPING'" | "'MULTIPLIER_ADD_ARMOR'" | "'MIN_TURNS_SCORE_EXISTING_STATUS'" | "'MULTIPLIER_HEAL_SELF_NEG'" | "'MULTIPLIER_ARMOR_SELF_POS'" | "'MULTIPLIER_FREE_ACTION'" | "'MULTIPLIER_AP_BOOST'" | "'MULTIPLIER_POS_SECONDARY_SURFACE'" | "'MULTIPLIER_HOT_ENEMY_POS'" | "'MULTIPLIER_TARGET_SUMMON'" | "'MAX_HEAL_SELF_MULTIPLIER'" | "'MULTIPLIER_DAMAGEBOOST'" | "'MULTIPLIER_DAMAGE_ON_MOVE'" | "'MULTIPLIER_SHIELD_BLOCK'" | "'MULTIPLIER_DAMAGE_SELF_POS'" | "'MULTIPLIER_CONTROL_NEUTRAL_NEG'" | "'MULTIPLIER_ENDPOS_NOT_IN_SMOKE'" | "'MULTIPLIER_CHARMED'" | "'MULTIPLIER_PUDDLE_RADIUS'" | "'MULTIPLIER_HEAL_ENEMY_NEG'" | "'MULTIPLIER_ARMOR_ENEMY_POS'" | "'MULTIPLIER_ACTION_COST_MULTIPLIER'" | "'MULTIPLIER_CANNOT_EXECUTE_THIS_TURN'" | "'MULTIPLIER_SPARK'" | "'MULTIPLIER_HOT_SELF_NEG'" | "'MULTIPLIER_HOT_NEUTRAL_POS'" | "'MULTIPLIER_TARGET_IN_SIGHT'" | "'MULTIPLIER_ENDPOS_TURNED_INVISIBLE'" | "'SKILL_TELEPORT_MINIMUM_DISTANCE'" | "'MULTIPLIER_DODGE_BOOST'" | "'MULTIPLIER_DAMAGE_ENEMY_POS'" | "'MULTIPLIER_BOOST_SELF_NEG'" | "'MULTIPLIER_MOVEMENT_COST_MULTPLIER'" | "'FALLBACK_ENEMIES_NEARBY'" | "'MOVESKILL_AP_DIFF_REQUIREMENT'" | "'MULTIPLIER_STATUS_CANCEL_INVISIBILITY'" | "'MULTIPLIER_SP_COSTBOOST'" | "'MULTIPLIER_DEFLECT_PROJECTILES'" | "'MULTIPLIER_HEAL_ALLY_NEG'" | "'MULTIPLIER_ARMOR_ALLY_POS'" | "'MULTIPLIER_STATUS_REMOVE'" | "'MULTIPLIER_LOSE_CONTROL'" | "'MULTIPLIER_SUMMON_PATH_INFLUENCES'" | "'AVENGE_ME_RADIUS'" | "'MULTIPLIER_CONTROL_SELF_POS'" | "'MULTIPLIER_TARGET_KNOCKED_DOWN'" | "'MULTIPLIER_BONUS_WEAPON_BOOST'" | "'MULTIPLIER_HEAL_SHARING'" | "'MULTIPLIER_REMOVE_MAGIC_ARMOR'" | "'MULTIPLIER_DAMAGE_ALLY_POS'" | "'MULTIPLIER_DOT_ALLY_POS'" | "'MULTIPLIER_BOOST_ENEMY_NEG'" | "'MULTIPLIER_REMOVE_ARMOR'" | "'MULTIPLIER_REFLECT_DAMAGE'" | "'MULTIPLIER_HEAL_NEUTRAL_NEG'" | "'MULTIPLIER_ARMOR_NEUTRAL_POS'" | "'MULTIPLIER_HIGH_ITEM_AMOUNT_MULTIPLIER'" | "'ENDPOS_NEARBY_DISTANCE'" | "'MULTIPLIER_STATUS_OVERWRITE'" | "'MULTIPLIER_AP_MAX'" | "'MULTIPLIER_CONTROL_ENEMY_POS'" | "'MULTIPLIER_TARGET_UNPREFERRED'" | "'MULTIPLIER_ENDPOS_HEIGHT_DIFFERENCE'" | "'MULTIPLIER_ARMORBOOST'" | "'MULTIPLIER_KILL_ALLY_SUMMON'" | "'MULTIPLIER_MOVEMENT_BOOST'" | "'UNSTABLE_BOMB_NEARBY'"
--- @alias AiScoreReasonFlags string | "'ScoreTooLow'" | "'TooComplex'" | "'TooFar'" | "'NoMovement'" | "'RemoveMadnessSelf'" | "'TargetBlocked'" | "'BreakInvisibility'" | "'CannotTargetFrozen'" | "'ResurrectByCharmedPlayer'" | "'StupidInvisibility'" | "'ResurrectOutOfCombat'" | "'MustStayInAiHint'" | "'KillSelf'" | "'MoveSkillCannotExecute'" | "'BreakInvisibilityForNoEnemies'"
--- @alias CauseType string | "'SurfaceMove'" | "'SurfaceCreate'" | "'SurfaceStatus'" | "'StatusEnter'" | "'StatusTick'" | "'None'" | "'GM'" | "'Offhand'" | "'Attack'"
--- @alias CraftingStationType string | "'Oven'" | "'Misc2'" | "'Well'" | "'None'" | "'Misc4'" | "'Anvil'" | "'Wetstone'" | "'BoilingPot'" | "'SpinningWheel'" | "'Cauldron'" | "'Beehive'" | "'Misc1'" | "'Misc3'"
--- @alias ESurfaceFlag string | "'SomeDecay'" | "'Frozen'" | "'Irreplaceable'" | "'IrreplaceableCloud'" | "'CloudSurfaceBlock'" | "'Cursed'" | "'Lava'" | "'Source'" | "'Water'" | "'FireCloud'" | "'WaterCloud'" | "'Blessed'" | "'BloodCloud'" | "'PoisonCloud'" | "'CloudElectrified'" | "'Fire'" | "'SmokeCloud'" | "'Deathfog'" | "'ExplosionCloud'" | "'ShockwaveCloud'" | "'FrostCloud'" | "'HasItem'" | "'HasInteractableObject'" | "'Blood'" | "'Purified'" | "'MovementBlock'" | "'Web'" | "'Electrified'" | "'ProjectileBlock'" | "'Poison'" | "'HasCharacter'" | "'Occupied'" | "'SurfaceExclude'" | "'ElectrifiedDecay'" | "'Sulfurium'" | "'Oil'" | "'Deepwater'" | "'CloudBlessed'" | "'CloudCursed'" | "'GroundSurfaceBlock'" | "'CloudPurified'"
--- @alias ExtComponentType string | "'ServerCharacter'" | "'ClientItem'" | "'ServerItem'" | "'Max'" | "'Combat'" | "'ClientCharacter'" | "'ServerProjectile'" | "'ServerCustomStatDefinition'"
--- @alias GameActionType string | "'WallAction'" | "'TornadoAction'" | "'PathAction'" | "'GameObjectMoveAction'" | "'StatusDomeAction'" | "'RainAction'" | "'StormAction'"
--- @alias GameObjectTemplateFlags string | "'IsCustom'"
--- @alias HealEffect string | "'ResistDeath'" | "'Behavior'" | "'Unknown4'" | "'Lifesteal'" | "'NegativeDamage'" | "'Unknown9'" | "'Heal'" | "'Script'" | "'HealSharing'" | "'None'" | "'HealSharingReflected'" | "'Surface'" | "'Necromantic'" | "'Sitting'"
--- @alias IngredientTransformType string | "'Transform'" | "'Consume'" | "'None'" | "'Poison'" | "'Boost'"
--- @alias IngredientType string | "'Category'" | "'None'" | "'Object'" | "'Property'"
--- @alias InputType string | "'Press'" | "'Unknown'" | "'Repeat'" | "'AcceleratedRepeat'" | "'Release'" | "'Hold'" | "'ValueChange'"
--- @alias ItemDataRarity string | "'Epic'" | "'Rare'" | "'Unique'" | "'Sentinel'" | "'Common'" | "'Divine'" | "'Uncommon'" | "'Legendary'"
--- @alias LuaTypeId string | "'Unknown'" | "'Any'" | "'Float'" | "'Set'" | "'Boolean'" | "'Tuple'" | "'Function'" | "'String'" | "'Enumeration'" | "'Object'" | "'Array'" | "'Nullable'" | "'Void'" | "'Map'" | "'Module'" | "'Integer'"
--- @alias MultiEffectHandlerFlags string | "'FaceSource'" | "'FollowScale'" | "'EffectAttached'" | "'KeepRot'" | "'Detach'" | "'Beam'"
--- @alias NetMessage string | "'NETMSG_SURFACE_CREATE'" | "'NETMSG_CHARACTER_CONTROL'" | "'NETMSG_ITEM_DESTROY'" | "'NETMSG_GAMECONTROL_UPDATE_C2S'" | "'NETMSG_PLAYMOVIE'" | "'NETMSG_ALIGNMENT_SET'" | "'NETMSG_GM_ITEM_CHANGE'" | "'NETMSG_GM_SYNC_VIGNETTES'" | "'NETMSG_GM_ITEM_USE'" | "'NETMSG_CHAT'" | "'NETMSG_LEVEL_SWAP_READY'" | "'NETMSG_PING_BEACON'" | "'NETMSG_CHARACTER_STATS_UPDATE'" | "'NETMSG_ITEM_STATUS_LIFETIME'" | "'NETMSG_ITEM_TRANSFORM'" | "'NETMSG_COMBATLOG'" | "'NETMSG_PARTY_CONSUMED_ITEMS'" | "'NETMSG_GM_REMOVE_ROLL'" | "'NETMSG_GM_ASSETS_PENDING_SYNCS_INFO'" | "'NETMSG_GM_EDIT_ITEM'" | "'NETMSG_SAVEGAME'" | "'NETMSG_DIFFICULTY_CHANGED'" | "'NETMSG_LOCK_WAYPOINT'" | "'NETMSG_PLAYER_DISCONNECT'" | "'NETMSG_CHARACTER_IN_DIALOG'" | "'NETMSG_INVENTORY_CREATE_AND_OPEN'" | "'NETMSG_PROJECTILE_EXPLOSION'" | "'NETMSG_TURNBASED_STOP'" | "'NETMSG_QUEST_STATE'" | "'NETMSG_GM_ADD_EXPERIENCE'" | "'NETMSG_GM_SYNC_ASSETS'" | "'NETMSG_GM_SET_INTERESTED_CHARACTER'" | "'NETMSG_CAMERA_TARGET'" | "'NETMSG_LOBBY_DATAUPDATE'" | "'NETMSG_CHARACTER_SKILLBAR'" | "'NETMSG_CHARACTER_AOO'" | "'NETMSG_TURNBASED_FLEECOMBATRESULT'" | "'NETMSG_SKILL_UPDATE'" | "'NETMSG_ALIGNMENT_RELATION'" | "'NETMSG_QUEST_TRACK'" | "'NETMSG_GM_SET_START_POINT'" | "'NETMSG_MODULE_LOAD'" | "'NETMSG_AITEST_UPDATE'" | "'NETMSG_HOST_REFUSE'" | "'NETMSG_CLIENT_CONNECT'" | "'NETMSG_CHARACTER_CUSTOMIZATION'" | "'NETMSG_PARTYUSER'" | "'NETMSG_ITEM_MOVED_INFORM'" | "'NETMSG_EFFECT_DESTROY'" | "'NETMSG_NOTIFICATION'" | "'NETMSG_PARTY_SPLIT_NOTIFICATION'" | "'NETMSG_GM_INVENTORY_OPERATION'" | "'NETMSG_LEVEL_LOAD'" | "'NETMSG_CHARACTER_CHANGE_OWNERSHIP'" | "'NETMSG_SHOW_TUTORIAL_MESSAGE'" | "'NETMSG_TRIGGER_CREATE'" | "'NETMSG_CLIENT_ACCEPT'" | "'NETMSG_CHARACTER_CONFIRMATION'" | "'NETMSG_COMBAT_TURN_TIMER'" | "'NETMSG_ITEM_UPDATE'" | "'NETMSG_GM_SPAWN'" | "'NETMSG_GM_TOGGLE_PAUSE'" | "'NETMSG_GM_SET_STATUS'" | "'NETMSG_LEVEL_SWAP_COMPLETE'" | "'NETMSG_ITEM_ENGRAVE'" | "'NETMSG_PAUSE'" | "'NETMSG_CUSTOM_STATS_DEFINITION_REMOVE'" | "'NETMSG_DLC_UPDATE'" | "'NETMSG_EGG_CREATE'" | "'NETMSG_COMBATLOGITEMINTERACTION'" | "'NETMSG_CLOSE_UI_MESSAGE'" | "'NETMSG_GM_HEAL'" | "'NETMSG_GM_TELEPORT'" | "'NETMSG_GM_REQUEST_CAMPAIGN_DATA'" | "'NETMSG_TRADE_ACTION'" | "'NETMSG_DIALOG_LISTEN'" | "'NETMSG_UNPAUSE'" | "'NETMSG_SET_CHARACTER_ARCHETYPE'" | "'NETMSG_CLIENT_JOINED'" | "'NETMSG_CHARACTER_UPDATE'" | "'NETMSG_CHARACTER_TELEPORT'" | "'NETMSG_INVENTORY_VIEW_CREATE'" | "'NETMSG_PEER_DEACTIVATE'" | "'NETMSG_TROPHY_UPDATE'" | "'NETMSG_DIALOG_STATE_MESSAGE'" | "'NETMSG_GM_ROLL'" | "'NETMSG_GM_DUPLICATE'" | "'NETMSG_ATMOSPHERE_OVERRIDE'" | "'NETMSG_REQUESTAUTOSAVE'" | "'NETMSG_SERVER_NOTIFICATION'" | "'NETMSG_LOBBY_SURRENDER'" | "'NETMSG_HOST_WELCOME'" | "'NETMSG_PLAYER_LEFT'" | "'NETMSG_CHARACTER_DEACTIVATE'" | "'NETMSG_PARTYGROUP'" | "'NETMSG_SKILL_REMOVED'" | "'NETMSG_MYSTERY_UPDATE'" | "'NETMSG_GM_VIGNETTE_ANSWER'" | "'NETMSG_GM_HOST'" | "'NETMSG_TELEPORT_WAYPOINT'" | "'NETMSG_CAMERA_SPLINE'" | "'NETMSG_CHARACTER_COMPANION_CUSTOMIZATION'" | "'NETMSG_SURFACE_META'" | "'NETMSG_SHROUD_FRUSTUM_UPDATE'" | "'NETMSG_ITEM_ACTIVATE'" | "'NETMSG_PLAY_HUD_SOUND'" | "'NETMSG_ALIGNMENT_CLEAR'" | "'NETMSG_OPEN_WAYPOINT_UI_MESSAGE'" | "'NETMSG_SHOW_ENTER_REGION_UI_MESSAGE'" | "'NETMSG_GM_DRAW_SURFACE'" | "'NETMSG_GM_TOGGLE_PEACE'" | "'NETMSG_GM_SOUND_PLAYBACK'" | "'NETMSG_LEVEL_START'" | "'NETMSG_GIVE_REWARD'" | "'NETMSG_CHARACTER_OFFSTAGE'" | "'NETMSG_ITEM_OFFSTAGE'" | "'NETMSG_SCREEN_FADE'" | "'NETMSG_DIALOG_ANSWER_MESSAGE'" | "'NETMSG_GM_TICK_ROLLS'" | "'NETMSG_GM_SYNC_NOTES'" | "'NETMSG_CHARACTERCREATION_NOT_READY'" | "'NETMSG_CRAFT_RESULT'" | "'NETMSG_CHARACTER_ASSIGN'" | "'NETMSG_CHARACTER_POSITION_SYNC'" | "'NETMSG_TURNBASED_ROUND'" | "'NETMSG_NET_ENTITY_CREATE'" | "'NETMSG_SECRET_UPDATE'" | "'NETMSG_GM_TRAVEL_TO_DESTINATION'" | "'NETMSG_GM_LOAD_CAMPAIGN'" | "'NETMSG_CAMERA_MODE'" | "'NETMSG_CHARACTERCREATION_READY'" | "'NETMSG_REALTIME_MULTIPLAY'" | "'NETMSG_LOBBY_USERUPDATE'" | "'NETMSG_CUSTOM_STATS_DEFINITION_CREATE'" | "'NETMSG_CHARACTER_BOOST'" | "'NETMSG_ITEM_USE_REMOTELY'" | "'NETMSG_SKILL_LEARN'" | "'NETMSG_CLOSED_MESSAGE_BOX_MESSAGE'" | "'NETMSG_JOURNALRECIPE_UPDATE'" | "'NETMSG_QUEST_POSTPONE'" | "'NETMSG_GM_CHANGE_SCENE_PATH'" | "'NETMSG_TELEPORT_ACK'" | "'NETMSG_LOAD_GAME_WITH_ADDONS'" | "'NETMSG_VOICEDATA'" | "'NETMSG_CHARACTER_LOOT_CORPSE'" | "'NETMSG_SHROUD_UPDATE'" | "'NETMSG_INVENTORY_ITEM_UPDATE'" | "'NETMSG_FORCE_SHEATH'" | "'NETMSG_FLAG_UPDATE'" | "'NETMSG_DIALOG_ACTORLEAVES_MESSAGE'" | "'NETMSG_GM_TOGGLE_OVERVIEWMAP'" | "'NETMSG_LEVEL_LOADED'" | "'NETMSG_DISCOVERED_PORTALS'" | "'NETMSG_TRIGGER_DESTROY'" | "'NETMSG_GAMEACTION'" | "'NETMSG_CHARACTER_ACTION_DATA'" | "'NETMSG_CHARACTER_STATUS_LIFETIME'" | "'NETMSG_ITEM_ACTION'" | "'NETMSG_GAMECONTROL_UPDATE_S2C'" | "'NETMSG_GM_REQUEST_ROLL'" | "'NETMSG_GM_SYNC_OVERVIEW_MAPS'" | "'NETMSG_GM_REMOVE_STATUS'" | "'NETMSG_STORY_ELEMENT_UI'" | "'NETMSG_LOBBY_CHARACTER_SELECT'" | "'NETMSG_MUTATORS_ENABLED'" | "'NETMSG_ITEM_MOVE_TO_INVENTORY'" | "'NETMSG_EGG_DESTROY'" | "'NETMSG_JOURNAL_RESET'" | "'NETMSG_GM_CAMPAIGN_SAVE'" | "'NETMSG_GM_EDIT_CHARACTER'" | "'NETMSG_CAMERA_ACTIVATE'" | "'NETMSG_CHANGE_COMBAT_FORMATION'" | "'NETMSG_MUSIC_STATE'" | "'NETMSG_GM_JOURNAL_UPDATE'" | "'NETMSG_HOST_REFUSEPLAYER'" | "'NETMSG_CLIENT_LEFT'" | "'NETMSG_CHARACTER_DIALOG'" | "'NETMSG_CHARACTER_CORPSE_LOOTABLE'" | "'NETMSG_PROJECTILE_CREATE'" | "'NETMSG_SKILL_CREATE'" | "'NETMSG_MARKER_UI_CREATE'" | "'NETMSG_GM_REMOVE_EXPORTED'" | "'NETMSG_CHARACTER_ANIMATION_SET_UPDATE'" | "'NETMSG_LOBBY_RETURN'" | "'NETMSG_CHARACTER_SET_STORY_NAME'" | "'NETMSG_PARTYORDER'" | "'NETMSG_EFFECT_CREATE'" | "'NETMSG_GAMECONTROL_PRICETAG'" | "'NETMSG_PARTYFORMATION'" | "'NETMSG_GM_REORDER_ELEMENTS'" | "'NETMSG_SESSION_LOAD'" | "'NETMSG_ACHIEVEMENT_PROGRESS_MESSAGE'" | "'NETMSG_READYCHECK'" | "'NETMSG_ITEM_DEACTIVATE'" | "'NETMSG_ITEM_CONFIRMATION'" | "'NETMSG_CHARACTER_ERROR'" | "'NETMSG_CACHETEMPLATE'" | "'NETMSG_OPEN_KICKSTARTER_BOOK_UI_MESSAGE'" | "'NETMSG_PARTY_UNLOCKED_RECIPE'" | "'NETMSG_GM_DAMAGE'" | "'NETMSG_GM_MAKE_TRADER'" | "'NETMSG_GM_UI_OPEN_STICKY'" | "'NETMSG_RUNECRAFT'" | "'NETMSG_JOURNALDIALOGLOG_UPDATE'" | "'NETMSG_SHOW_ERROR'" | "'NETMSG_HACK_TELL_BUILDNAME'" | "'NETMSG_CHARACTER_DESTROY'" | "'NETMSG_ITEM_MOVE_UUID'" | "'NETMSG_TURNBASED_SUMMONS'" | "'NETMSG_SCREEN_FADE_DONE'" | "'NETMSG_DIALOG_ACTORJOINS_MESSAGE'" | "'NETMSG_GM_CHANGE_LEVEL'" | "'NETMSG_GM_MAKE_FOLLOWER'" | "'NETMSG_UNLOCK_ITEM'" | "'NETMSG_CHARACTER_ACTION'" | "'NETMSG_CHARACTER_ACTION_REQUEST_RESULT'" | "'NETMSG_CHARACTER_UPGRADE'" | "'NETMSG_TURNBASED_ORDER'" | "'NETMSG_GM_CONFIGURE_CAMPAIGN'" | "'NETMSG_GM_POSSESS'" | "'NETMSG_GAMETIME_SYNC'" | "'NETMSG_LOBBY_COMMAND'" | "'NETMSG_UPDATE_CHARACTER_TAGS'" | "'NETMSG_PLAYER_ACCEPT'" | "'NETMSG_CHARACTER_TRANSFORM'" | "'NETMSG_PARTY_CREATE'" | "'NETMSG_INVENTORY_DESTROY'" | "'NETMSG_SKILL_UNLEARN'" | "'NETMSG_UI_QUESTSELECTED'" | "'NETMSG_PARTY_MERGE_NOTIFICATION'" | "'NETMSG_GM_SET_REPUTATION'" | "'NETMSG_MODULE_LOADED'" | "'NETMSG_SAVEGAME_LOAD_FAIL'" | "'NETMSG_PARTYCREATEGROUP'" | "'NETMSG_SKIPMOVIE_RESULT'" | "'NETMSG_CHARACTER_ACTIVATE'" | "'NETMSG_CHARACTER_SELECTEDSKILLSET'" | "'NETMSG_COMBAT_COMPONENT_SYNC'" | "'NETMSG_ITEM_CREATE'" | "'NETMSG_INVENTORY_VIEW_UPDATE_ITEMS'" | "'NETMSG_PLAYSOUND'" | "'NETMSG_CLOSE_CUSTOM_BOOK_UI_MESSAGE'" | "'NETMSG_GM_DELETE'" | "'NETMSG_GM_REQUEST_CHARACTERS_REROLL'" | "'NETMSG_LOAD_START'" | "'NETMSG_CHARACTERCREATION_DONE'" | "'NETMSG_TRIGGER_UPDATE'" | "'NETMSG_MULTIPLE_TARGET_OPERATION'" | "'NETMSG_CHARACTER_CREATE'" | "'NETMSG_UPDATE_COMBAT_GROUP_INFO'" | "'NETMSG_ITEM_STATUS'" | "'NETMSG_OVERHEADTEXT'" | "'NETMSG_OPEN_MESSAGE_BOX_MESSAGE'" | "'NETMSG_GM_PASS_ROLL'" | "'NETMSG_GM_CLEAR_STATUSES'" | "'NETMSG_GM_CREATE_ITEM'" | "'NETMSG_NOTIFY_COMBINE_FAILED_MESSAGE'" | "'NETMSG_UNLOCK_WAYPOINT'" | "'NETMSG_CUSTOM_STATS_CREATE'" | "'NETMSG_SCRIPT_EXTENDER'" | "'NETMSG_CHARACTER_PICKPOCKET'" | "'NETMSG_INVENTORY_VIEW_DESTROY'" | "'NETMSG_TURNBASED_START'" | "'NETMSG_QUEST_UPDATE'" | "'NETMSG_DIALOG_NODE_MESSAGE'" | "'NETMSG_GM_SYNC_SCENES'" | "'NETMSG_CAMERA_ROTATE'" | "'NETMSG_SAVEGAMEHANDSHAKE'" | "'NETMSG_OPEN_CRAFT_UI_MESSAGE'" | "'NETMSG_MUSIC_EVENT'" | "'NETMSG_PLAYER_CONNECT'" | "'NETMSG_CHARACTER_POSITION'" | "'NETMSG_CHARACTER_USE_AP'" | "'NETMSG_TURNBASED_SETTEAM'" | "'NETMSG_SKILL_DESTROY'" | "'NETMSG_MARKER_UI_UPDATE'" | "'NETMSG_UPDATE_ITEM_TAGS'" | "'NETMSG_HOST_LEFT'" | "'NETMSG_PARTYUPDATE'" | "'NETMSG_SECRET_REGION_UNLOCK'" | "'NETMSG_EFFECT_FORGET'" | "'NETMSG_QUEST_CATEGORY_UPDATE'" | "'NETMSG_STOP_FOLLOW'" | "'NETMSG_GM_CHANGE_SCENE_NAME'" | "'NETMSG_SESSION_LOADED'" | "'NETMSG_DIPLOMACY'" | "'NETMSG_CUSTOM_STATS_UPDATE'" | "'NETMSG_LOAD_GAME_WITH_ADDONS_FAIL'" | "'NETMSG_CHARACTER_LOCK_ABILITY'" | "'NETMSG_ITEM_DESTINATION'" | "'NETMSG_INVENTORY_VIEW_SORT'" | "'NETMSG_ALIGNMENT_CREATE'" | "'NETMSG_DIALOG_HISTORY_MESSAGE'" | "'NETMSG_GM_EXPORT'" | "'NETMSG_GM_GIVE_REWARD'" | "'NETMSG_SERVER_COMMAND'" | "'NETMSG_STORY_VERSION'" | "'NETMSG_CHARACTER_STEERING'" | "'NETMSG_INVENTORY_CREATE'" | "'NETMSG_NET_ENTITY_DESTROY'" | "'NETMSG_OPEN_CUSTOM_BOOK_UI_MESSAGE'" | "'NETMSG_GAMEOVER'" | "'NETMSG_GM_POSITION_SYNC'" | "'NETMSG_GM_STOP_TRAVELING'" | "'NETMSG_GM_SET_ATMOSPHERE'" | "'NETMSG_GM_DEACTIVATE'" | "'NETMSG_TELEPORT_PYRAMID'" | "'NETMSG_LOBBY_SPECTATORUPDATE'" | "'NETMSG_CHARACTER_STATUS'" | "'NETMSG_ITEM_MOVE_TO_WORLD'" | "'NETMSG_PEER_ACTIVATE'" | "'NETMSG_REGISTER_WAYPOINT'" | "'NETMSG_DIALOG_ANSWER_HIGHLIGHT_MESSAGE'" | "'NETMSG_GM_CHANGE_NAME'" | "'NETMSG_PARTY_NPC_DATA'" | "'NETMSG_ACHIEVEMENT_UNLOCKED_MESSAGE'" | "'NETMSG_LOBBY_STARTGAME'" | "'NETMSG_CLIENT_GAME_SETTINGS'" | "'NETMSG_PLAYER_JOINED'" | "'NETMSG_CHARACTER_ITEM_USED'" | "'NETMSG_PARTY_DESTROY'" | "'NETMSG_INVENTORY_VIEW_UPDATE_PARENTS'" | "'NETMSG_INVENTORY_LOCKSTATE_SYNC'" | "'NETMSG_SKILL_ACTIVATE'" | "'NETMSG_MYSTERY_STATE'" | "'NETMSG_GM_TOGGLE_VIGNETTE'" | "'NETMSG_MODULES_DOWNLOAD'" | "'NETMSG_LEVEL_INSTANTIATE_SWAP'" | "'NETMSG_ARENA_RESULTS'" | "'NETMSG_CUSTOM_STATS_DEFINITION_UPDATE'"
--- @alias ObjectHandleType string | "'ContainerElementComponent'" | "'ClientParty'" | "'ClientAtmosphereTrigger'" | "'Unknown'" | "'ClientVignette'" | "'ServerEocPointTrigger'" | "'SRV'" | "'ClientNote'" | "'ServerCustomStatDefinitionComponent'" | "'Shader'" | "'ClientInventoryView'" | "'ClientSurface'" | "'Effect'" | "'ClientRegionTrigger'" | "'ServerEgg'" | "'ServerRegionTrigger'" | "'ClientItem'" | "'ServerCharacter'" | "'ServerInventoryView'" | "'ClientSoundVolumeTrigger'" | "'ServerItem'" | "'ServerEventTrigger'" | "'ClientProjectile'" | "'ServerInventory'" | "'ServerAIHintAreaTrigger'" | "'ClientScenery'" | "'ClientPointTrigger'" | "'ServerParty'" | "'ClientWallBase'" | "'ClientAiSeederTrigger'" | "'ServerVignette'" | "'ServerCrimeRegionTrigger'" | "'Texture'" | "'ServerNote'" | "'ServerEocAreaTrigger'" | "'Visual'" | "'SoundVolumeTrigger'" | "'IndexBuffer'" | "'ClientAlignmentData'" | "'ServerMusicVolumeTrigger'" | "'VertexBuffer'" | "'ClientPointSoundTrigger'" | "'VertexFormat'" | "'TextureRemoveData'" | "'Light'" | "'ServerOverviewMap'" | "'SamplerState'" | "'ClientCustomStatDefinitionComponent'" | "'ServerSoundVolumeTrigger'" | "'BlendState'" | "'Reference'" | "'ClientWallConstruction'" | "'DepthState'" | "'TerrainObject'" | "'ClientCullTrigger'" | "'RasterizerState'" | "'ClientDummyGameObject'" | "'ServerExplorationTrigger'" | "'Constant'" | "'ServerStartTrigger'" | "'ConstantBuffer'" | "'Scene'" | "'CustomStatsComponent'" | "'ClientSecretRegionTrigger'" | "'ServerCrimeAreaTrigger'" | "'Decal'" | "'Dummy'" | "'Trigger'" | "'ClientGameAction'" | "'CombatComponent'" | "'GMJournalNode'" | "'ClientSpectatorTrigger'" | "'StructuredBuffer'" | "'CompiledShader'" | "'MeshProxy'" | "'ClientEgg'" | "'ClientPointSoundTriggerDummy'" | "'ServerSurfaceAction'" | "'TexturedFont'" | "'UIObject'" | "'ClientCharacter'" | "'Text3D'" | "'ClientWallIntersection'" | "'ClientCameraLockTrigger'" | "'ServerAtmosphereTrigger'" | "'ServerStatsAreaTrigger'" | "'ClientInventory'" | "'ServerProjectile'" | "'ClientAlignment'" | "'ServerTeleportTrigger'" | "'ContainerComponent'" | "'ClientSkill'" | "'ServerSecretRegionTrigger'" | "'GrannyFile'" | "'ClientStatus'" | "'ClientOverviewMap'"
--- @alias PathRootType string | "'Public'" | "'Data'" | "'Root'" | "'MyDocuments'" | "'GameStorage'"
--- @alias PlayerUpgradeAttribute string | "'Intelligence'" | "'Constitution'" | "'Wits'" | "'Memory'" | "'Finesse'" | "'Strength'"
--- @alias RecipeCategory string | "'Armour'" | "'Potions'" | "'Runes'" | "'Weapons'" | "'Grenades'" | "'Grimoire'" | "'Objects'" | "'Food'" | "'Common'" | "'Arrows'"
--- @alias ResourceType string | "'Physics'" | "'Effect'" | "'Texture'" | "'Script'" | "'Visual'" | "'MaterialSet'" | "'Animation'" | "'MeshProxy'" | "'AnimationSet'" | "'Material'" | "'Sound'" | "'AnimationBlueprint'" | "'VisualSet'" | "'Atmosphere'"
--- @alias ScriptCheckType string | "'Operator'" | "'Variable'"
--- @alias ScriptOperatorType string | "'And'" | "'Not'" | "'None'" | "'Or'"
--- @alias ShroudType string | "'Sight'" | "'Sneak'" | "'RegionMask'" | "'Shroud'"
--- @alias SkillType string | "'Wall'" | "'ProjectileStrike'" | "'Quake'" | "'SkillHeal'" | "'Jump'" | "'Shout'" | "'Tornado'" | "'Rush'" | "'MultiStrike'" | "'Teleportation'" | "'Target'" | "'Summon'" | "'Projectile'" | "'Storm'" | "'Rain'" | "'Dome'" | "'Path'" | "'Zone'"
--- @alias StatAttributeFlags string | "'BleedingImmunity'" | "'FreezeContact'" | "'BurnContact'" | "'RegeneratingImmunity'" | "'StunContact'" | "'EntangledContact'" | "'InfectiousDiseasedImmunity'" | "'PoisonContact'" | "'ChillContact'" | "'SlippingImmunity'" | "'Arrow'" | "'Unbreakable'" | "'Unrepairable'" | "'ProtectFromSummon'" | "'LoseDurabilityOnCharacterHit'" | "'Unstorable'" | "'Grounded'" | "'CrippledImmunity'" | "'Torch'" | "'HastedImmunity'" | "'FreezeImmunity'" | "'DisarmedImmunity'" | "'Floating'" | "'BurnImmunity'" | "'ShacklesOfPainImmunity'" | "'StunImmunity'" | "'TauntedImmunity'" | "'AcidImmunity'" | "'SleepingImmunity'" | "'EnragedImmunity'" | "'PoisonImmunity'" | "'BlessedImmunity'" | "'DeflectProjectiles'" | "'IgnoreClouds'" | "'MadnessImmunity'" | "'DiseasedImmunity'" | "'ChickenImmunity'" | "'DecayingImmunity'" | "'IgnoreCursedOil'" | "'CharmImmunity'" | "'ShockedImmunity'" | "'PickpocketableWhenEquipped'" | "'InvisibilityImmunity'" | "'FearImmunity'" | "'WebImmunity'" | "'KnockdownImmunity'" | "'MuteImmunity'" | "'MagicalSulfur'" | "'ChilledImmunity'" | "'SuffocatingImmunity'" | "'ThrownImmunity'" | "'WarmImmunity'" | "'LootableWhenEquipped'" | "'WetImmunity'" | "'BlindImmunity'" | "'CursedImmunity'" | "'PetrifiedImmunity'" | "'WeakImmunity'" | "'ClairvoyantImmunity'" | "'SlowedImmunity'" | "'DrunkImmunity'"
--- @alias StatusHealType string | "'None'" | "'Source'" | "'All'" | "'PhysicalArmor'" | "'Vitality'" | "'MagicArmor'" | "'AllArmor'"
--- @alias StatusType string | "'LYING'" | "'WIND_WALKER'" | "'DARK_AVENGER'" | "'SOURCE_MUTED'" | "'HEAL_SHARING_CASTER'" | "'HEAL'" | "'KNOCKED_DOWN'" | "'CLEAN'" | "'SUMMONING'" | "'FLOATING'" | "'STORY_FROZEN'" | "'UNLOCK'" | "'EXTRA_TURN'" | "'SHACKLES_OF_PAIN'" | "'ACTIVE_DEFENSE'" | "'SNEAKING'" | "'CHALLENGE'" | "'SITTING'" | "'DECAYING_TOUCH'" | "'DAMAGE_ON_MOVE'" | "'SPARK'" | "'THROWN'" | "'UNHEALABLE'" | "'SPIRIT'" | "'DEMONIC_BARGAIN'" | "'DYING'" | "'SMELLY'" | "'CHANNELING'" | "'GUARDIAN_ANGEL'" | "'SPIRIT_VISION'" | "'COMBAT'" | "'UNSHEATHED'" | "'FORCE_MOVE'" | "'REMORSE'" | "'CLIMBING'" | "'DISARMED'" | "'INCAPACITATED'" | "'PLAY_DEAD'" | "'STANCE'" | "'SHACKLES_OF_PAIN_CASTER'" | "'INSURFACE'" | "'CONSTRAINED'" | "'HEALING'" | "'INFUSED'" | "'HIT'" | "'BLIND'" | "'DEACTIVATED'" | "'EFFECT'" | "'TUTORIAL_BED'" | "'TELEPORT_FALLING'" | "'CONSUME'" | "'OVERPOWER'" | "'EXPLODE'" | "'COMBUSTION'" | "'REPAIR'" | "'POLYMORPHED'" | "'BOOST'" | "'HEAL_SHARING'" | "'CHARMED'" | "'DRAIN'" | "'DAMAGE'" | "'LINGERING_WOUNDS'" | "'AOO'" | "'INVISIBLE'" | "'ROTATE'" | "'INFECTIOUS_DISEASED'" | "'ENCUMBERED'" | "'FEAR'" | "'MATERIAL'" | "'MUTED'" | "'IDENTIFY'" | "'LEADERSHIP'" | "'FLANKED'" | "'ADRENALINE'"
--- @alias SurfaceActionType string | "'PolygonSurfaceAction'" | "'ChangeSurfaceOnPathAction'" | "'ExtinguishFireAction'" | "'SwapSurfaceAction'" | "'TransformSurfaceAction'" | "'CreateSurfaceAction'" | "'ZoneAction'" | "'RectangleSurfaceAction'" | "'CreatePuddleAction'"
--- @alias SurfaceLayer string | "'None'" | "'Cloud'" | "'Ground'"
--- @alias SurfaceTransformActionType string | "'Purify'" | "'Oilify'" | "'Bless'" | "'Electrify'" | "'Condense'" | "'None'" | "'Vaporize'" | "'Freeze'" | "'Bloodify'" | "'Contaminate'" | "'Ignite'" | "'Melt'" | "'Curse'" | "'Shatter'"
--- @alias SurfaceType string | "'WaterPurified'" | "'WaterCloudElectrified'" | "'BloodFrozen'" | "'BloodCloudElectrifiedCursed'" | "'BloodCloudPurified'" | "'BloodBlessed'" | "'WaterFrozenCursed'" | "'BloodCursed'" | "'BloodPurified'" | "'BloodFrozenPurified'" | "'PoisonBlessed'" | "'BloodCloudElectrified'" | "'PoisonCursed'" | "'SmokeCloudBlessed'" | "'WaterElectrifiedBlessed'" | "'PoisonPurified'" | "'BloodFrozenBlessed'" | "'OilBlessed'" | "'BloodElectrifiedPurified'" | "'OilCursed'" | "'WaterCloudBlessed'" | "'OilPurified'" | "'Lava'" | "'PoisonCloudBlessed'" | "'Source'" | "'WebBlessed'" | "'WaterFrozenPurified'" | "'WebCursed'" | "'WaterCloudElectrifiedCursed'" | "'WebPurified'" | "'FireCloudBlessed'" | "'Water'" | "'CustomBlessed'" | "'FireCloud'" | "'BloodCloudBlessed'" | "'CustomCursed'" | "'WaterCloud'" | "'BloodCloudElectrifiedBlessed'" | "'SmokeCloudCursed'" | "'WaterFrozenBlessed'" | "'CustomPurified'" | "'BloodCloud'" | "'BloodElectrifiedCursed'" | "'FireCloudCursed'" | "'PoisonCloud'" | "'Fire'" | "'WaterCloudCursed'" | "'SmokeCloud'" | "'Deathfog'" | "'PoisonCloudCursed'" | "'ExplosionCloud'" | "'ShockwaveCloud'" | "'BloodCloudElectrifiedPurified'" | "'FrostCloud'" | "'Blood'" | "'BloodElectrified'" | "'Sentinel'" | "'Web'" | "'FireCloudPurified'" | "'WaterElectrifiedPurified'" | "'Poison'" | "'BloodCloudCursed'" | "'SmokeCloudPurified'" | "'FireBlessed'" | "'WaterElectrifiedCursed'" | "'Custom'" | "'FireCursed'" | "'BloodFrozenCursed'" | "'WaterCloudElectrifiedBlessed'" | "'FirePurified'" | "'WaterCloudPurified'" | "'WaterFrozen'" | "'Oil'" | "'Deepwater'" | "'PoisonCloudPurified'" | "'WaterElectrified'" | "'WaterBlessed'" | "'WaterCloudElectrifiedPurified'" | "'WaterCursed'" | "'BloodElectrifiedBlessed'"
--- @alias TemplateType string | "'GlobalCacheTemplate'" | "'LevelCacheTemplate'" | "'GlobalTemplate'" | "'RootTemplate'" | "'LocalTemplate'"
--- @alias UIObjectFlags string | "'OF_DeleteOnChildDestroy'" | "'OF_PreventCameraMove'" | "'OF_Loaded'" | "'OF_Visible'" | "'OF_Activated'" | "'OF_PlayerInput1'" | "'OF_PlayerTextInput4'" | "'OF_PlayerInput2'" | "'OF_PlayerInput3'" | "'OF_PlayerInput4'" | "'OF_PlayerModal1'" | "'OF_PlayerTextInput1'" | "'OF_PlayerModal2'" | "'OF_PlayerModal3'" | "'OF_PlayerModal4'" | "'OF_RequestDelete'" | "'OF_KeepInScreen'" | "'OF_PauseRequest'" | "'OF_DontHideOnDelete'" | "'OF_SortOnAdd'" | "'OF_FullScreen'" | "'OF_PlayerTextInput2'" | "'OF_KeepCustomInScreen'" | "'OF_PrecacheUIData'" | "'OF_Load'" | "'OF_PlayerTextInput3'"
--- @alias VisualAttachmentFlags string | "'UseLocalTransform'" | "'KeepRot'" | "'KeepScale'" | "'DoNotUpdate'" | "'Overhead'" | "'WeaponFX'" | "'BonusWeaponFX'" | "'InheritAnimations'" | "'Wings'" | "'WeaponOverlayFX'" | "'ParticleSystem'" | "'DestroyWithParent'" | "'Armor'" | "'ExcludeFromBounds'" | "'Weapon'" | "'Horns'"
--- @alias VisualComponentFlags string | "'VisualSetLoaded'" | "'ForceUseAnimationBlueprint'"
--- @alias VisualFlags string | "'AllowReceiveDecalWhenAnimated'" | "'CastShadow'" | "'ReceiveDecal'" | "'IsShadowProxy'" | "'Reflecting'"
--- @alias VisualTemplateColorIndex string | "'Cloth'" | "'Hair'" | "'Skin'"
--- @alias VisualTemplateVisualIndex string | "'Beard'" | "'Visual9'" | "'Torso'" | "'Boots'" | "'Arms'" | "'HairHelmet'" | "'Trousers'" | "'Visual8'" | "'Head'"
--- @alias EclEntityComponentIndex string | "'ContainerElement'" | "'CullTrigger'" | "'RegionTrigger'" | "'PointSoundTriggerDummy'" | "'Scenery'" | "'AiSeederTrigger'" | "'GameMaster'" | "'CameraLockTrigger'" | "'PingBeacon'" | "'Effect'" | "'Egg'" | "'SecretRegionTrigger'" | "'SpectatorTrigger'" | "'Visual'" | "'OverviewMap'" | "'SoundVolumeTrigger'" | "'Vignette'" | "'Net'" | "'EquipmentVisualsComponent'" | "'Spline'" | "'Light'" | "'Container'" | "'PointSoundTrigger'" | "'Note'" | "'CustomStatDefinition'" | "'AtmosphereTrigger'" | "'Item'" | "'Decal'" | "'Combat'" | "'GMJournalNode'" | "'Projectile'" | "'PublishingRequest'" | "'AnimationBlueprint'" | "'LightProbe'" | "'Sound'" | "'CustomStats'" | "'ParentEntity'" | "'Character'" | "'PointTrigger'"
--- @alias EclEntitySystemIndex string | "'ContainerElementComponent'" | "'ContainerElement'" | "'PingBeaconManager'" | "'GameMaster'" | "'AnimationBlueprintSystem'" | "'CustomStatsSystem'" | "'CameraSplineSystem'" | "'CharacterManager'" | "'LightProbeManager'" | "'ContainerComponentSystem'" | "'EquipmentVisualsSystem'" | "'MusicManager'" | "'VisualSystem'" | "'AtmosphereManager'" | "'LightManager'" | "'DecalManager'" | "'Container'" | "'SoundSystem'" | "'SeeThroughManager'" | "'PublishingSystem'" | "'GrannySystem'" | "'TurnManager'" | "'EncounterManager'" | "'SceneryManager'" | "'TriggerManager'" | "'GMJournalNode'" | "'ProjectileManager'" | "'ItemManager'" | "'EggManager'" | "'PhysXScene'" | "'SurfaceManager'" | "'LEDSystem'" | "'PickingHelperManager'" | "'GameMasterCampaignManager'" | "'GMJournalSystem'" | "'CustomStats'" | "'GameActionManager'" | "'GameMasterManager'"
--- @alias EclGameState string | "'Unknown'" | "'LoadModule'" | "'Idle'" | "'Lobby'" | "'Disconnect'" | "'StartLoading'" | "'StopLoading'" | "'Movie'" | "'LoadSession'" | "'StartServer'" | "'LoadGMCampaign'" | "'Installation'" | "'UnloadLevel'" | "'GameMasterPause'" | "'Init'" | "'Save'" | "'ModReceiving'" | "'BuildStory'" | "'Menu'" | "'LoadLoca'" | "'UnloadModule'" | "'UnloadSession'" | "'PrepareRunning'" | "'Paused'" | "'InitMenu'" | "'Join'" | "'InitNetwork'" | "'InitConnection'" | "'Running'" | "'LoadMenu'" | "'SwapLevel'" | "'Exit'" | "'LoadLevel'"
--- @alias EclItemFlags string | "'Sticky'" | "'CanBePickedUp'" | "'Known'" | "'CanBeMoved'" | "'FoldDynamicStats'" | "'IsSecretDoor'" | "'CoverAmount'" | "'CanShootThrough'" | "'IsCraftingIngredient'" | "'TeleportOnUse'" | "'PinnedContainer'" | "'Floating'" | "'Global'" | "'Activated'" | "'Walkable'" | "'CanWalkThrough'" | "'IsSourceContainer'" | "'TickPhysics'" | "'IsInventory_M'" | "'EnableHighlights'" | "'DisableGravity'" | "'Invulnerable'" | "'Invisible'" | "'Destroyed'" | "'Hostile'" | "'CanUse'" | "'Unimportant'" | "'PositionUpdatePending'" | "'IsLadder'" | "'InteractionDisabled'" | "'Wadable'"
--- @alias EclItemFlags2 string | "'IsKey'" | "'Stolen'" | "'UnEquipLocked'" | "'UseSoundsLoaded'" | "'Consumable'" | "'CanUseRemotely'"
--- @alias EclItemPhysicsFlags string | "'Awake'" | "'WakeFlag1'" | "'WakeNeighbours'"
--- @alias EclStatusFlags string | "'Started'" | "'KeepAlive'" | "'RequestDelete'" | "'HasVisuals'"
--- @alias EocSkillBarItemType string | "'Skill'" | "'None'" | "'ItemTemplate'" | "'Action'" | "'Item'"
--- @alias EsvCharacterFlags string | "'Temporary'" | "'InArena'" | "'NoRotate'" | "'IsPlayer'" | "'CoverAmount'" | "'CanShootThrough'" | "'CannotDie'" | "'CharacterCreationFinished'" | "'Floating'" | "'WalkThrough'" | "'CharacterControl'" | "'SpotSneakers'" | "'CannotMove'" | "'Activated'" | "'PartyFollower'" | "'OffStage'" | "'Totem'" | "'Multiplayer'" | "'HostControl'" | "'IsHuge'" | "'InParty'" | "'Dead'" | "'HasOwner'" | "'InDialog'" | "'Deactivated'" | "'MadePlayer'" | "'Summon'" | "'LevelTransitionPending'" | "'RegisteredForAutomatedDialog'" | "'Loaded'"
--- @alias EsvCharacterFlags2 string | "'HasDefaultDialog'" | "'Global'" | "'Resurrected'" | "'HasOsirisDialog'" | "'Trader'" | "'TreasureGeneratedForTrader'"
--- @alias EsvCharacterFlags3 string | "'NoReptuationEffects'" | "'HasRunSpeedOverride'" | "'IsPet'" | "'IsGameMaster'" | "'ManuallyLeveled'" | "'IsPossessed'" | "'IsSpectating'" | "'HasWalkSpeedOverride'"
--- @alias EsvCharacterTransformFlags string | "'DontCheckRootTemplate'" | "'ReleasePlayerData'" | "'SaveOriginalDisplayName'" | "'DontReplaceCombatState'" | "'ReplaceEquipment'" | "'DiscardOriginalDisplayName'" | "'ReplaceScripts'" | "'ReplaceInventory'" | "'ReplaceStats'" | "'Immediate'" | "'ReplaceTags'" | "'ReplaceCustomLooks'" | "'ReplaceScale'" | "'ReplaceSkills'" | "'ReplaceOriginalTemplate'" | "'ReplaceVoiceSet'" | "'ImmediateSync'" | "'ReplaceCustomNameIcon'" | "'ReplaceCurrentTemplate'"
--- @alias EsvCharacterTransformType string | "'TransformToTemplate'" | "'TransformToCharacter'"
--- @alias EsvEntityComponentIndex string | "'ContainerElement'" | "'RegionTrigger'" | "'MusicVolumeTrigger'" | "'GameMaster'" | "'Effect'" | "'Egg'" | "'CrimeAreaTrigger'" | "'TeleportTrigger'" | "'SecretRegionTrigger'" | "'EoCPointTrigger'" | "'EventTrigger'" | "'OverviewMap'" | "'StatsAreaTrigger'" | "'SoundVolumeTrigger'" | "'Vignette'" | "'Net'" | "'Spline'" | "'CrimeRegionTrigger'" | "'Container'" | "'Note'" | "'CustomStatDefinition'" | "'AtmosphereTrigger'" | "'Item'" | "'ExplorationTrigger'" | "'Combat'" | "'GMJournalNode'" | "'Projectile'" | "'StartTrigger'" | "'AIHintAreaTrigger'" | "'AnimationBlueprint'" | "'CustomStats'" | "'Character'" | "'EoCAreaTrigger'"
--- @alias EsvEntitySystemIndex string | "'ContainerElementComponent'" | "'ContainerElement'" | "'GameMaster'" | "'AnimationBlueprintSystem'" | "'CustomStatsSystem'" | "'CameraSplineSystem'" | "'EnvironmentalStatusManager'" | "'CharacterManager'" | "'EffectManager'" | "'LightProbeManager'" | "'RewardManager'" | "'ContainerComponentSystem'" | "'VisualSystem'" | "'LightManager'" | "'DecalManager'" | "'Container'" | "'SoundSystem'" | "'PublishingSystem'" | "'TurnManager'" | "'ShroudManager'" | "'TriggerManager'" | "'GMJournalNode'" | "'ProjectileManager'" | "'ItemManager'" | "'EggManager'" | "'SurfaceManager'" | "'GameMasterCampaignManager'" | "'GMJournalSystem'" | "'SightManager'" | "'NetEntityManager'" | "'CharacterSplineSystem'" | "'CustomStats'" | "'GameActionManager'" | "'GameMasterManager'"
--- @alias EsvGameState string | "'Unknown'" | "'LoadModule'" | "'Idle'" | "'Uninitialized'" | "'Disconnect'" | "'ReloadStory'" | "'LoadSession'" | "'LoadGMCampaign'" | "'Installation'" | "'UnloadLevel'" | "'GameMasterPause'" | "'Init'" | "'Save'" | "'BuildStory'" | "'UnloadModule'" | "'UnloadSession'" | "'Paused'" | "'Sync'" | "'Running'" | "'Exit'" | "'LoadLevel'"
--- @alias EsvItemFlags string | "'Sticky'" | "'Frozen'" | "'CanBePickedUp'" | "'Known'" | "'CanBeMoved'" | "'GMFolding'" | "'IsSecretDoor'" | "'WalkOn'" | "'SourceContainer'" | "'CanShootThrough'" | "'TeleportOnUse'" | "'PinnedContainer'" | "'WalkThrough'" | "'Floating'" | "'FreezeGravity'" | "'IsSurfaceBlocker'" | "'Activated'" | "'NoCover'" | "'StoryItem'" | "'OffStage'" | "'Totem'" | "'IsDoor'" | "'Invisible'" | "'Destroyed'" | "'Summon'" | "'IsSurfaceCloudBlocker'" | "'CanUse'" | "'LoadedTemplate'" | "'ForceSync'" | "'IsLadder'" | "'PositionChanged'" | "'Destroy'" | "'InteractionDisabled'"
--- @alias EsvItemFlags2 string | "'IsKey'" | "'UnsoldGenerated'" | "'UnEquipLocked'" | "'CanConsume'" | "'Global'" | "'UseRemotely'" | "'TreasureGenerated'"
--- @alias EsvItemTransformFlags string | "'ReplaceScripts'" | "'ReplaceStats'" | "'Immediate'"
--- @alias EsvStatusFlags0 string | "'IsFromItem'" | "'InitiateCombat'" | "'IsLifeTimeSet'" | "'KeepAlive'" | "'Influence'" | "'IsOnSourceSurface'" | "'Channeled'"
--- @alias EsvStatusFlags1 string | "'IsHostileAct'" | "'BringIntoCombat'" | "'IsInvulnerable'" | "'IsResistingDeath'"
--- @alias EsvStatusFlags2 string | "'ForceStatus'" | "'ForceFailStatus'" | "'Started'" | "'RequestClientSync2'" | "'RequestDeleteAtTurnEnd'" | "'RequestClientSync'" | "'RequestDelete'"
--- @alias EsvStatusMaterialApplyFlags string | "'ApplyOnWeapon'" | "'ApplyOnWings'" | "'ApplyOnHorns'" | "'ApplyOnOverhead'" | "'ApplyOnBody'" | "'ApplyOnArmor'"
--- @alias EsvSystemType string | "'ContainerElement'" | "'Effect'" | "'Egg'" | "'GM'" | "'GameAction'" | "'Container'" | "'NetEntity'" | "'TurnManager'" | "'Surface'" | "'CharacterSpline'" | "'Item'" | "'Trigger'" | "'GMCampaign'" | "'Projectile'" | "'CameraSpline'" | "'Reward'" | "'Shroud'" | "'GMJournal'" | "'AnimationBlueprint'" | "'SightManager'" | "'Character'" | "'EnvironmentalStatus'" | "'CustomStat'"
--- @alias StatsAbilityType string | "'Telekinesis'" | "'WaterSpecialist'" | "'Barter'" | "'Sourcery'" | "'Crafting'" | "'Thievery'" | "'Wand'" | "'Loremaster'" | "'Reflexes'" | "'Repair'" | "'Sneaking'" | "'RangerLore'" | "'RogueLore'" | "'Reason'" | "'Persuasion'" | "'Intimidate'" | "'Leadership'" | "'DualWielding'" | "'Perseverance'" | "'PhysicalArmorMastery'" | "'VitalityMastery'" | "'Shield'" | "'Luck'" | "'SingleHanded'" | "'Sentinel'" | "'TwoHanded'" | "'Sulfurology'" | "'WarriorLore'" | "'AirSpecialist'" | "'EarthSpecialist'" | "'Brewmaster'" | "'MagicArmorMastery'" | "'FireSpecialist'" | "'Charm'" | "'Runecrafting'" | "'Necromancy'" | "'Summoning'" | "'Ranged'" | "'Polymorph'" | "'Pickpocket'" | "'PainReflection'"
--- @alias StatsArmorType string | "'None'" | "'Cloth'" | "'Mail'" | "'Robe'" | "'Leather'" | "'Sentinel'" | "'Plate'"
--- @alias StatsCharacterFlags string | "'IsPlayer'" | "'InParty'" | "'IsSneaking'" | "'Invisible'" | "'DrinkedPotion'" | "'Blind'" | "'EquipmentValidated'"
--- @alias StatsCharacterStatGetterType string | "'APStart'" | "'Intelligence'" | "'Constitution'" | "'CorrosiveResistance'" | "'Sight'" | "'PoisonResistance'" | "'LifeSteal'" | "'BlockChance'" | "'ChanceToHitBoost'" | "'Initiative'" | "'APMaximum'" | "'APRecovery'" | "'ShadowResistance'" | "'Wits'" | "'Accuracy'" | "'Movement'" | "'PiercingResistance'" | "'FireResistance'" | "'EarthResistance'" | "'WaterResistance'" | "'CustomResistance'" | "'Memory'" | "'AirResistance'" | "'MaxMp'" | "'MagicResistance'" | "'DamageBoost'" | "'CriticalChance'" | "'PhysicalResistance'" | "'Dodge'" | "'Hearing'" | "'Finesse'" | "'Strength'"
--- @alias StatsCriticalRoll string | "'Critical'" | "'NotCritical'" | "'Roll'"
--- @alias StatsDamageType string | "'Corrosive'" | "'Shadow'" | "'Earth'" | "'Magic'" | "'None'" | "'Water'" | "'Sulfuric'" | "'Fire'" | "'Sentinel'" | "'Chaos'" | "'Poison'" | "'Air'" | "'Piercing'" | "'Physical'"
--- @alias StatsDeathType string | "'Explode'" | "'Arrow'" | "'Acid'" | "'Incinerate'" | "'Electrocution'" | "'None'" | "'FrozenShatter'" | "'Surrender'" | "'KnockedDown'" | "'Hang'" | "'Sulfur'" | "'Sentinel'" | "'Lifetime'" | "'PetrifiedShatter'" | "'Piercing'" | "'DoT'" | "'Physical'"
--- @alias StatsEquipmentStatsType string | "'Shield'" | "'Armor'" | "'Weapon'"
--- @alias StatsHandednessType string | "'Any'" | "'Two'" | "'One'"
--- @alias StatsHighGroundBonus string | "'Unknown'" | "'HighGround'" | "'EvenGround'" | "'LowGround'"
--- @alias StatsHitFlag string | "'Hit'" | "'DamagedPhysicalArmor'" | "'Bleeding'" | "'NoEvents'" | "'DontCreateBloodSurface'" | "'Reflection'" | "'Dodged'" | "'PropagatedFromOwner'" | "'FromShacklesOfPain'" | "'ProcWindWalker'" | "'Blocked'" | "'Burning'" | "'Surface'" | "'CriticalHit'" | "'FromSetHP'" | "'NoDamageOnOwner'" | "'DamagedMagicArmor'" | "'DamagedVitality'" | "'CounterAttack'" | "'Poisoned'" | "'Missed'" | "'Flanking'" | "'DoT'" | "'Backstab'"
--- @alias StatsHitType string | "'Magic'" | "'Melee'" | "'WeaponDamage'" | "'Reflected'" | "'Surface'" | "'Ranged'" | "'DoT'"
--- @alias StatsItemSlot string | "'Ring'" | "'Breast'" | "'Overhead'" | "'Ring2'" | "'Wings'" | "'Shield'" | "'Leggings'" | "'Belt'" | "'Boots'" | "'Helmet'" | "'Sentinel'" | "'Amulet'" | "'Weapon'" | "'Gloves'" | "'Horns'"
--- @alias StatsItemSlot32 string | "'Ring'" | "'Breast'" | "'Overhead'" | "'Ring2'" | "'Wings'" | "'Shield'" | "'Leggings'" | "'Belt'" | "'Boots'" | "'Helmet'" | "'Sentinel'" | "'Amulet'" | "'Weapon'" | "'Gloves'" | "'Horns'"
--- @alias StatsPropertyContext string | "'Self'" | "'SelfOnHit'" | "'SelfOnEquip'" | "'Target'" | "'AoE'"
--- @alias StatsPropertyType string | "'Force'" | "'Sabotage'" | "'GameAction'" | "'OsirisTask'" | "'Extender'" | "'SurfaceChange'" | "'Summon'" | "'CustomDescription'" | "'Custom'" | "'Status'"
--- @alias StatsRequirementType string | "'Intelligence'" | "'Telekinesis'" | "'TALENT_AvoidDetection'" | "'TALENT_ElementalAffinity'" | "'TALENT_Sourcerer'" | "'Constitution'" | "'WaterSpecialist'" | "'TALENT_ItemMovement'" | "'TALENT_WhatARush'" | "'TALENT_NoAttackOfOpportunity'" | "'TRAIT_Compassionate'" | "'Barter'" | "'TALENT_ResistFear'" | "'TALENT_GoldenMage'" | "'TALENT_GreedyVessel'" | "'Sourcery'" | "'TALENT_ExtraSkillPoints'" | "'TALENT_Charm'" | "'TALENT_WarriorLoreNaturalArmor'" | "'TALENT_Human_Inventive'" | "'Tag'" | "'Crafting'" | "'TALENT_Intimidate'" | "'TALENT_Reason'" | "'TALENT_DualWieldingDodging'" | "'TALENT_ViolentMagic'" | "'Thievery'" | "'Wand'" | "'TALENT_LightStep'" | "'TRAIT_Independent'" | "'Loremaster'" | "'TALENT_Flanking'" | "'TALENT_ActionPoints2'" | "'TALENT_Luck'" | "'TALENT_Politician'" | "'TALENT_RangerLoreArrowRecover'" | "'TRAIT_Timid'" | "'TALENT_Jitterbug'" | "'TALENT_Backstab'" | "'TALENT_ResistSilence'" | "'TALENT_Escapist'" | "'TALENT_Kickstarter'" | "'TRAIT_Obedient'" | "'Reflexes'" | "'TALENT_WaterSpells'" | "'TALENT_Raistlin'" | "'TALENT_Perfectionist'" | "'TRAIT_Pragmatic'" | "'Repair'" | "'Sneaking'" | "'TALENT_AnimalEmpathy'" | "'TALENT_Leech'" | "'TALENT_RangerLoreRangedAPBonus'" | "'TRAIT_Vindictive'" | "'TRAIT_Romantic'" | "'RangerLore'" | "'TALENT_ItemCreation'" | "'TALENT_FaroutDude'" | "'TALENT_Bully'" | "'TRAIT_Spiritual'" | "'TALENT_Elementalist'" | "'None'" | "'RogueLore'" | "'TALENT_ResistKnockdown'" | "'TALENT_LoneWolf'" | "'TALENT_WalkItOff'" | "'TRAIT_Righteous'" | "'TALENT_MagicCycles'" | "'Reason'" | "'Persuasion'" | "'TALENT_Durability'" | "'TALENT_RogueLoreDaggerBackStab'" | "'TALENT_Dwarf_Sneaking'" | "'TRAIT_Renegade'" | "'Intimidate'" | "'TALENT_Initiative'" | "'TALENT_LivingArmor'" | "'TRAIT_Blunt'" | "'Wits'" | "'Leadership'" | "'TALENT_ResurrectToFullHealth'" | "'TALENT_Scientist'" | "'TRAIT_Materialistic'" | "'TRAIT_Heartless'" | "'DualWielding'" | "'TALENT_Criticals'" | "'TALENT_WeatherProof'" | "'TALENT_RogueLoreHoldResistance'" | "'MinKarma'" | "'TALENT_Soulcatcher'" | "'Perseverance'" | "'TALENT_ResistDead'" | "'TALENT_WarriorLoreNaturalResistance'" | "'TALENT_ExtraWandCharge'" | "'MaxKarma'" | "'PhysicalArmorMastery'" | "'TALENT_Trade'" | "'TALENT_AirSpells'" | "'TALENT_FiveStarRestaurant'" | "'TALENT_Zombie'" | "'TALENT_Executioner'" | "'Immobile'" | "'TALENT_StandYourGround'" | "'TALENT_Demon'" | "'TALENT_WarriorLoreGrenadeRange'" | "'TRAIT_Altruistic'" | "'TALENT_Sadist'" | "'Shield'" | "'Luck'" | "'TALENT_Lockpick'" | "'TALENT_ChanceToHitMelee'" | "'TALENT_ElementalRanger'" | "'TALENT_IceKing'" | "'TALENT_Haymaker'" | "'TALENT_Gladiator'" | "'TALENT_Damage'" | "'TALENT_ResistStun'" | "'TALENT_ExpGain'" | "'TALENT_FolkDancer'" | "'TALENT_Stench'" | "'TALENT_WarriorLoreNaturalHealth'" | "'TALENT_WildMag'" | "'Memory'" | "'SingleHanded'" | "'TALENT_AttackOfOpportunity'" | "'TALENT_Awareness'" | "'TALENT_Vitality'" | "'TALENT_Dwarf_Sturdy'" | "'TALENT_Elf_Lore'" | "'TALENT_Lizard_Persuasion'" | "'Level'" | "'TwoHanded'" | "'TALENT_InventoryAccess'" | "'TALENT_Memory'" | "'TALENT_Ambidextrous'" | "'Combat'" | "'WarriorLore'" | "'TALENT_Sight'" | "'TALENT_MrKnowItAll'" | "'TALENT_RangerLoreEvasionBonus'" | "'TALENT_Torturer'" | "'TRAIT_Considerate'" | "'AirSpecialist'" | "'TALENT_IncreasedArmor'" | "'TALENT_Carry'" | "'TALENT_Courageous'" | "'TALENT_Lizard_Resistance'" | "'TALENT_Unstable'" | "'TALENT_MasterThief'" | "'EarthSpecialist'" | "'TALENT_ExtraStatPoints'" | "'TALENT_Human_Civil'" | "'TRAIT_Forgiving'" | "'MagicArmorMastery'" | "'Vitality'" | "'FireSpecialist'" | "'Charm'" | "'TALENT_EarthSpells'" | "'TALENT_RogueLoreDaggerAPBonus'" | "'TALENT_QuickStep'" | "'TRAIT_Bold'" | "'Necromancy'" | "'TALENT_SurpriseAttack'" | "'TRAIT_Egotistical'" | "'Finesse'" | "'Summoning'" | "'TALENT_ChanceToHitRanged'" | "'TALENT_ActionPoints'" | "'TALENT_Kinetics'" | "'TALENT_LightningRod'" | "'TALENT_Indomitable'" | "'Ranged'" | "'Polymorph'" | "'Pickpocket'" | "'TALENT_ResistPoison'" | "'TALENT_Repair'" | "'TALENT_SpillNoBlood'" | "'TALENT_RogueLoreMovementBonus'" | "'TALENT_RogueLoreGrenadePrecision'" | "'Strength'" | "'PainReflection'" | "'TALENT_FireSpells'" | "'TALENT_Elf_CorpseEater'"
--- @alias StatsTalentType string | "'Lockpick'" | "'ChanceToHitMelee'" | "'FaroutDude'" | "'Human_Civil'" | "'WildMag'" | "'ActionPoints2'" | "'ExpGain'" | "'ElementalRanger'" | "'RangerLoreEvasionBonus'" | "'Dwarf_Sneaking'" | "'Criticals'" | "'Durability'" | "'LightningRod'" | "'WarriorLoreGrenadeRange'" | "'Dwarf_Sturdy'" | "'IncreasedArmor'" | "'Sight'" | "'Politician'" | "'Elf_Lore'" | "'Quest_SpidersKiss_Per'" | "'ResistFear'" | "'WeatherProof'" | "'Demon'" | "'Perfectionist'" | "'ResistKnockdown'" | "'FiveStarRestaurant'" | "'LoneWolf'" | "'Executioner'" | "'ResistStun'" | "'RogueLoreMovementBonus'" | "'ViolentMagic'" | "'ActionPoints'" | "'ResistPoison'" | "'WarriorLoreNaturalHealth'" | "'Lizard_Resistance'" | "'QuickStep'" | "'Sadist'" | "'ResistSilence'" | "'Carry'" | "'Initiative'" | "'BeastMaster'" | "'NaturalConductor'" | "'ResistDead'" | "'Repair'" | "'ExtraSkillPoints'" | "'Quest_GhostTree'" | "'Throwing'" | "'RangerLoreRangedAPBonus'" | "'RogueLoreGrenadePrecision'" | "'LivingArmor'" | "'None'" | "'Zombie'" | "'DualWieldingDodging'" | "'Torturer'" | "'Reason'" | "'Quest_SpidersKiss_Null'" | "'Ambidextrous'" | "'ItemMovement'" | "'AttackOfOpportunity'" | "'ExtraStatPoints'" | "'Intimidate'" | "'Unstable'" | "'AnimalEmpathy'" | "'WarriorLoreNaturalArmor'" | "'Quest_Rooted'" | "'Rager'" | "'Trade'" | "'Awareness'" | "'RogueLoreHoldResistance'" | "'PainDrinker'" | "'Max'" | "'Escapist'" | "'Quest_SpidersKiss_Str'" | "'Sourcerer'" | "'Damage'" | "'FireSpells'" | "'DeathfogResistant'" | "'Elementalist'" | "'WaterSpells'" | "'ResurrectToFullHealth'" | "'Bully'" | "'Haymaker'" | "'AirSpells'" | "'Luck'" | "'RogueLoreDaggerAPBonus'" | "'Gladiator'" | "'EarthSpells'" | "'Elf_CorpseEating'" | "'Indomitable'" | "'InventoryAccess'" | "'Stench'" | "'Memory'" | "'Quest_TradeSecrets'" | "'Jitterbug'" | "'ChanceToHitRanged'" | "'AvoidDetection'" | "'Soulcatcher'" | "'Kickstarter'" | "'RangerLoreArrowRecover'" | "'MasterThief'" | "'StandYourGround'" | "'Courageous'" | "'WarriorLoreNaturalResistance'" | "'NoAttackOfOpportunity'" | "'WandCharge'" | "'GreedyVessel'" | "'SurpriseAttack'" | "'Leech'" | "'GoldenMage'" | "'Quest_SpidersKiss_Int'" | "'MagicCycles'" | "'Vitality'" | "'Charm'" | "'LightStep'" | "'WalkItOff'" | "'Scientist'" | "'ElementalAffinity'" | "'FolkDancer'" | "'ItemCreation'" | "'Raistlin'" | "'IceKing'" | "'SpillNoBlood'" | "'RogueLoreDaggerBackStab'" | "'Flanking'" | "'MrKnowItAll'" | "'Lizard_Persuasion'" | "'Backstab'" | "'WhatARush'" | "'Human_Inventive'" | "'ResurrectExtraHealth'"
--- @alias StatsWeaponType string | "'Bow'" | "'Wand'" | "'Arrow'" | "'None'" | "'Knife'" | "'Club'" | "'Crossbow'" | "'Staff'" | "'Sentinel'" | "'Rifle'" | "'Sword'" | "'Spear'" | "'Axe'"


--- @class Actor
--- @field MeshBindings MeshBinding[]
--- @field PhysicsRagdoll PhysicsRagdoll
--- @field Skeleton Skeleton
--- @field TextKeyPrepareFlags uint8
--- @field Time GameTime
--- @field Visual Visual


--- @class AnimatableObject:RenderableObject
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


--- @class BaseComponent
--- @field Component ComponentHandleWithType


--- @class BookActionData:IActionData
--- @field BookId FixedString


--- @class Bound
--- @field Center vec3
--- @field IsCenterSet bool
--- @field Max vec3
--- @field Min vec3
--- @field Radius float


--- @class CDivinityStatsCharacter:StatsObjectInstance
--- @field GetItemBySlot fun(self:CDivinityStatsCharacter, a1:StatsItemSlot, a2:bool|nil):CDivinityStatsItem
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


--- @class CDivinityStatsEquipmentAttributesArmor:CDivinityStatsEquipmentAttributes
--- @field ArmorBoost int32
--- @field ArmorValue int32
--- @field MagicArmorBoost int32
--- @field MagicArmorValue int32


--- @class CDivinityStatsEquipmentAttributesShield:CDivinityStatsEquipmentAttributes
--- @field ArmorBoost int32
--- @field ArmorValue int32
--- @field Blocking int32
--- @field MagicArmorBoost int32
--- @field MagicArmorValue int32


--- @class CDivinityStatsEquipmentAttributesWeapon:CDivinityStatsEquipmentAttributes
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


--- @class CDivinityStatsItem:StatsObjectInstance
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
--- @field LootableWhenEquipped bool
--- @field Loremaster int32
--- @field LoseDurabilityOnCharacterHit bool
--- @field Luck int32
--- @field MadnessImmunity bool
--- @field MagicArmorMastery int32
--- @field MagicalSulfur bool
--- @field MaxCharges int32
--- @field MuteImmunity bool
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


--- @class CharacterSkillData
--- @field AIParams SkillAIParams
--- @field SkillId FixedString


--- @class CharacterTemplate:EoCGameObjectTemplate
--- @field GetColorChoices fun(self:CharacterTemplate, a1:VisualTemplateColorIndex):uint32[]
--- @field GetVisualChoices fun(self:CharacterTemplate, a1:VisualTemplateVisualIndex):FixedString[]
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


--- @class ConstrainActionData:IActionData
--- @field Damage float


--- @class ConsumeActionData:IActionData
--- @field Consume bool
--- @field StatsId FixedString


--- @class CraftActionData:IActionData
--- @field CraftingStationType CraftingStationType


--- @class CreatePuddleActionData:IActionData
--- @field CellAtGrow int32
--- @field ExternalCauseAsSurfaceOwner bool
--- @field GrowTimer float
--- @field LifeTime float
--- @field SurfaceType SurfaceType
--- @field Timeout float
--- @field TotalCells int32


--- @class CreateSurfaceActionData:IActionData
--- @field ExternalCauseAsSurfaceOwner bool
--- @field LifeTime float
--- @field Radius float
--- @field SurfaceType SurfaceType


--- @class DeferredLoadableResource:Resource


--- @class DestroyParametersData:IActionData
--- @field ExplodeFX FixedString
--- @field TemplateAfterDestruction FixedString
--- @field VisualDestruction FixedString


--- @class DisarmTrapActionData:IActionData
--- @field Consume bool


--- @class DoorActionData:IActionData
--- @field SecretDoor bool


--- @class DragDropManager
--- @field StartDraggingName fun(self:DragDropManager, a1:int16, a2:FixedString):bool
--- @field StartDraggingObject fun(self:DragDropManager, a1:int16, a2:ComponentHandle):bool
--- @field StopDragging fun(self:DragDropManager, a1:int16):bool
--- @field PlayerDragDrops table<int16, DragDropManagerPlayerDragInfo>


--- @class DragDropManagerPlayerDragInfo
--- @field DragId FixedString
--- @field DragObject ComponentHandle
--- @field IsActive bool
--- @field IsDragging bool
--- @field MousePos vec2


--- @class EoCGameObjectTemplate:GameObjectTemplate
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


--- @class GlobalSwitches
--- @field AIBoundsSizeMultiplier float
--- @field AddGenericKeyWords bool
--- @field AddStoryKeyWords bool
--- @field AllowMovementFreePointer bool
--- @field AllowXPGain bool
--- @field AlwaysShowSplitterInTrade bool
--- @field ArenaCharacterHighlightFlag bool
--- @field ArenaCharacterHighlightMode int32
--- @field AutoFillHotbarCategories uint8
--- @field AutoIdentifyItems bool
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
--- @field field_BD2 bool
--- @field field_BD3 bool
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


--- @class IActionData
--- @field Type ActionDataType


--- @class IEoCClientObject:IGameObject
--- @field GetStatus fun(self:IEoCClientObject, a1:FixedString):EclStatus
--- @field GetStatusByType fun(self:IEoCClientObject, a1:StatusType):EclStatus
--- @field GetStatusObjects fun(self:IEoCClientObject)
--- @field GetStatuses fun(self:IEoCClientObject):FixedString[]
--- @field DisplayName STDWString|nil


--- @class IEoCServerObject:IGameObject
--- @field CreateCacheTemplate fun(self:IEoCServerObject):GameObjectTemplate
--- @field ForceSyncToPeers fun(self:IEoCServerObject)
--- @field GetStatus fun(self:IEoCServerObject, a1:FixedString):EsvStatus
--- @field GetStatusByHandle fun(self:IEoCServerObject, a1:ComponentHandle):EsvStatus
--- @field GetStatusByType fun(self:IEoCServerObject, a1:StatusType):EsvStatus
--- @field GetStatusObjects fun(self:IEoCServerObject)
--- @field GetStatuses fun(self:IEoCServerObject):FixedString[]
--- @field TransformTemplate fun(self:IEoCServerObject, a1:GameObjectTemplate)
--- @field DisplayName STDWString|nil


--- @class IGameObject
--- @field GetTags fun(self:IGameObject):FixedString[]
--- @field HasTag fun(self:IGameObject, a1:FixedString):bool
--- @field IsTagged fun(self:IGameObject, a1:FixedString):bool
--- @field Base BaseComponent
--- @field Handle ComponentHandle
--- @field Height float
--- @field MyGuid FixedString
--- @field NetID NetId
--- @field Scale float
--- @field Translate vec3
--- @field Velocity vec3
--- @field Visual Visual


--- @class IdentifyActionData:IActionData
--- @field Consume bool


--- @class InputEvent
--- @field AcceleratedRepeat bool
--- @field EventId int32
--- @field Hold bool
--- @field InputDeviceId int16
--- @field InputPlayerIndex int32
--- @field Press bool
--- @field Release bool
--- @field Repeat bool
--- @field Unknown bool
--- @field ValueChange bool
--- @field WasPreferred bool


--- @class InventoryItemData
--- @field AIParams SkillAIParams
--- @field Amount int32
--- @field ItemName STDString
--- @field LevelName STDString
--- @field TemplateID FixedString
--- @field Type int32
--- @field UUID FixedString
--- @field field_10 STDString


--- @class ItemTemplate:EoCGameObjectTemplate
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


--- @class Level
--- @field LevelDesc LevelDesc


--- @class LevelDesc
--- @field CustomDisplayLevelName STDWString
--- @field LevelName FixedString
--- @field Paths Path[]
--- @field Type uint8
--- @field UniqueKey FixedString


--- @class LevelTemplate:GameObjectTemplate
--- @field IsPersistent bool
--- @field LevelBoundTrigger FixedString
--- @field LocalLevelBound Bound
--- @field SubLevelName FixedString
--- @field WorldLevelBound Bound


--- @class Light:MoveableObject
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


--- @class LockpickActionData:IActionData
--- @field Consume bool


--- @class LyingActionData:IActionData
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


--- @class MaterialParameterWithValue<MaterialSamplerState>:MaterialParameter
--- @field Value MaterialSamplerState


--- @class MaterialParameterWithValue<MaterialTexture2D>:MaterialParameter
--- @field Value MaterialTexture2D


--- @class MaterialParameterWithValue<MaterialVector3>:MaterialParameter
--- @field Value MaterialVector3


--- @class MaterialParameterWithValue<MaterialVector4>:MaterialParameter
--- @field Value MaterialVector4


--- @class MaterialParameterWithValue<float>:MaterialParameter
--- @field Value float


--- @class MaterialParameterWithValue<Glmvec2>:MaterialParameter
--- @field Value vec2


--- @class MaterialParameters
--- @field ParentAppliedMaterial AppliedMaterial
--- @field ParentMaterial Material
--- @field SamplerStates MaterialParameterWithValue<MaterialSamplerState>[]
--- @field Scalars MaterialParameterWithValue<float>[]
--- @field Texture2Ds MaterialParameterWithValue<MaterialTexture2D>[]
--- @field Vector2s MaterialParameterWithValue<Glmvec2>[]
--- @field Vector3s MaterialParameterWithValue<MaterialVector3>[]
--- @field Vector4s MaterialParameterWithValue<MaterialVector4>[]


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


--- @class PhysicsRagdoll


--- @class PhysicsShape
--- @field Name FixedString
--- @field Rotate mat3
--- @field Scale float
--- @field Translate vec3


--- @class PlaySoundActionData:IActionData
--- @field ActivateSoundEvent FixedString
--- @field PlayOnHUD bool


--- @class ProjectileTemplate:EoCGameObjectTemplate
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


--- @class RecipeActionData:IActionData
--- @field RecipeID FixedString


--- @class RenderableObject:MoveableObject
--- @field ActiveAppliedMaterial AppliedMaterial
--- @field AppliedMaterials AppliedMaterial[]
--- @field AppliedOverlayMaterials AppliedMaterial[]
--- @field ClothPhysicsShape PhysicsShape
--- @field HasPhysicsProxy bool
--- @field IsSimulatedCloth bool
--- @field LOD uint8
--- @field PropertyList DsePropertyList


--- @class RepairActionData:IActionData
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


--- @class ShaderDesc
--- @field Flags uint16
--- @field PSHash FixedString
--- @field VSHash FixedString


--- @class ShowStoryElementUIActionData:IActionData
--- @field UIStoryInstance STDString
--- @field UIType int32


--- @class SitActionData:IActionData
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


--- @class SkillBookActionData:IActionData
--- @field Consume bool
--- @field SkillID FixedString


--- @class SoundVolumeTriggerData
--- @field AmbientSound FixedString
--- @field AuxBus1 uint8
--- @field AuxBus2 uint8
--- @field AuxBus3 uint8
--- @field AuxBus4 uint8
--- @field Occlusion float


--- @class SpawnCharacterActionData:IActionData
--- @field LocalTemplate FixedString
--- @field RootTemplate FixedString
--- @field SpawnFX FixedString


--- @class SurfacePathInfluence
--- @field Influence int32
--- @field MaskFlags ESurfaceFlag
--- @field MatchFlags ESurfaceFlag


--- @class SurfaceTemplate:GameObjectTemplate
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


--- @class TeleportActionData:IActionData
--- @field EventID FixedString
--- @field Source FixedString
--- @field SourceType uint8
--- @field Target FixedString
--- @field TargetType uint8
--- @field Visibility uint8


--- @class Transform
--- @field Matrix mat4
--- @field Rotate mat3
--- @field Scale vec3
--- @field Translate vec3


--- @class TranslatedString
--- @field ArgumentString RuntimeStringHandle
--- @field Handle RuntimeStringHandle


--- @class Trigger
--- @field IsGlobal bool
--- @field Level FixedString
--- @field SyncFlags uint16
--- @field Translate vec3
--- @field TriggerType FixedString


--- @class TriggerTemplate:GameObjectTemplate
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
--- @field Params TypeInformationRef[]
--- @field ParentType TypeInformationRef
--- @field ReturnValues TypeInformationRef[]
--- @field TypeName FixedString
--- @field VarargParams bool
--- @field VarargsReturn bool


--- @class TypeInformationRef:TypeInformation


--- @class UIObject
--- @field CaptureExternalInterfaceCalls fun(self:UIObject)
--- @field CaptureInvokes fun(self:UIObject)
--- @field ClearCustomIcon fun(self:UIObject, a1:STDWString)
--- @field Destroy fun(self:UIObject)
--- @field EnableCustomDraw fun(self:UIObject)
--- @field ExternalInterfaceCall fun(self:UIObject, a1:STDString)
--- @field GetHandle fun(self:UIObject):ComponentHandle
--- @field GetPlayerHandle fun(self:UIObject):ComponentHandle|nil
--- @field GetPosition fun(self:UIObject):ivec2|nil
--- @field GetRoot fun(self:UIObject)
--- @field GetTypeId fun(self:UIObject):int32
--- @field GetUIScaleMultiplier fun(self:UIObject):float
--- @field GetValue fun(self:UIObject, a1:STDString, a2:STDString|nil, a3:int32|nil):IggyInvokeDataValue|nil
--- @field GotoFrame fun(self:UIObject, a1:int32, a2:bool|nil)
--- @field Hide fun(self:UIObject)
--- @field Invoke fun(self:UIObject, a1:STDString):bool
--- @field Resize fun(self:UIObject, a1:float, a2:float, a3:float|nil)
--- @field SetCustomIcon fun(self:UIObject, a1:STDWString, a2:STDString, a3:int32, a4:int32, a5:STDString|nil)
--- @field SetPosition fun(self:UIObject, a1:int32, a2:int32)
--- @field SetValue fun(self:UIObject, a1:STDString, a2:IggyInvokeDataValue, a3:int32|nil)
--- @field Show fun(self:UIObject)
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


--- @class UseSkillActionData:IActionData
--- @field Consume bool
--- @field SkillID FixedString


--- @class Visual:MoveableObject
--- @field OverrideScalarMaterialParameter fun(self:Visual, a1:FixedString, a2:float)
--- @field OverrideTextureMaterialParameter fun(self:Visual, a1:FixedString, a2:FixedString)
--- @field OverrideVec2MaterialParameter fun(self:Visual, a1:FixedString, a2:vec2)
--- @field OverrideVec3MaterialParameter fun(self:Visual, a1:FixedString, a2:vec3, a3:bool)
--- @field OverrideVec4MaterialParameter fun(self:Visual, a1:FixedString, a2:vec4, a3:bool)
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


--- @class EclCharacter:IEoCClientObject
--- @field GetCustomStat fun(self:EclCharacter, a1:FixedString):int32|nil
--- @field GetInventoryItems fun(self:EclCharacter):FixedString[]
--- @field GetItemBySlot fun(self:EclCharacter, a1:StatsItemSlot32):FixedString|nil
--- @field GetItemObjectBySlot fun(self:EclCharacter, a1:StatsItemSlot32):EclItem
--- @field SetScale fun(self:EclCharacter, a1:float)
--- @field AnimationSetOverride FixedString
--- @field AnimationSpeed float
--- @field Archetype FixedString
--- @field CorpseCharacterHandle ComponentHandle
--- @field CorpseLootable bool
--- @field CurrentLevel FixedString
--- @field CurrentTemplate CharacterTemplate
--- @field DisplayNameOverride TranslatedString
--- @field Flags uint64
--- @field FollowCharacterHandle ComponentHandle
--- @field InventoryHandle ComponentHandle
--- @field ItemTags FixedString[]
--- @field OriginalDisplayName TranslatedString
--- @field OriginalTemplate CharacterTemplate
--- @field OwnerCharacterHandle ComponentHandle
--- @field PlayerCustomData EocPlayerCustomData
--- @field PlayerData EclPlayerData
--- @field PlayerUpgrade EocPlayerUpgrade
--- @field RootTemplate CharacterTemplate
--- @field RunSpeedOverride float
--- @field SkillManager EclSkillManager
--- @field Stats CDivinityStatsCharacter
--- @field StatusMachine EclStatusMachine
--- @field StoryDisplayName TranslatedString
--- @field SurfacePathInfluences SurfacePathInfluence[]
--- @field Tags FixedString[]
--- @field TalkingIconEffect ComponentHandle
--- @field UserID UserId
--- @field WalkSpeedOverride float
--- @field WorldPos vec3


--- @class EclEoCUI:UIObject


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


--- @class EclItem:IEoCClientObject
--- @field GetDeltaMods fun(self:EclItem):FixedString[]
--- @field GetInventoryItems fun(self:EclItem):FixedString[]
--- @field GetOwnerCharacter fun(self:EclItem):FixedString|nil
--- @field AIBoundSize float
--- @field Activated bool
--- @field Amount int32
--- @field Awake bool
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
--- @field DisableGravity bool
--- @field EnableHighlights bool
--- @field FallTimer float
--- @field Flags EclItemFlags
--- @field Flags2 EclItemFlags2
--- @field Floating bool
--- @field FoldDynamicStats bool
--- @field Global bool
--- @field GoldValueOverride int32
--- @field GravityTimer float
--- @field Hostile bool
--- @field InUseByCharacterHandle ComponentHandle
--- @field InUseByUserId int32
--- @field InteractionDisabled bool
--- @field InventoryHandle ComponentHandle
--- @field InventoryParentHandle ComponentHandle
--- @field Invisible bool
--- @field Invulnerable bool
--- @field IsCraftingIngredient bool
--- @field IsInventory_M bool
--- @field IsKey bool
--- @field IsLadder bool
--- @field IsSecretDoor bool
--- @field IsSourceContainer bool
--- @field ItemColorOverride FixedString
--- @field ItemType FixedString
--- @field KeyName FixedString
--- @field Known bool
--- @field Level int32
--- @field LockLevel int32
--- @field OwnerCharacterHandle ComponentHandle
--- @field PhysicsFlags EclItemPhysicsFlags
--- @field PinnedContainer bool
--- @field PositionUpdatePending bool
--- @field RootTemplate ItemTemplate
--- @field Stats CDivinityStatsItem
--- @field StatsFromName StatsObject
--- @field StatsId FixedString
--- @field StatusMachine EclStatusMachine
--- @field Sticky bool
--- @field Stolen bool
--- @field Tags FixedString[]
--- @field TeleportOnUse bool
--- @field TickPhysics bool
--- @field UnEquipLocked bool
--- @field Unimportant bool
--- @field UnknownTimer float
--- @field UseSoundsLoaded bool
--- @field Vitality int32
--- @field Wadable bool
--- @field WakeFlag1 bool
--- @field WakeNeighbours bool
--- @field WakePosition vec3
--- @field Walkable bool
--- @field WorldPos vec3


--- @class EclLevel:Level
--- @field AiGrid EocAiGrid


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


--- @class EclPlayerCustomData:EocPlayerCustomData


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


--- @class EclStatusMachine
--- @field IsStatusMachineActive bool
--- @field OwnerObjectHandle ComponentHandle
--- @field PreventStatusApply bool
--- @field Statuses EclStatus[]


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


--- @class EclCharacterCreationUICharacterCreationWizard:EclEoCUI
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


--- @class EclLuaGameStateChangeEventParams
--- @field FromState EclGameState
--- @field ToState EclGameState


--- @class EclLuaInputEventParams
--- @field Event InputEvent


--- @class EclLuaSkillGetDescriptionEventParams
--- @field Character CDivinityStatsCharacter
--- @field Description STDString
--- @field IsFromItem bool
--- @field Params STDString[]
--- @field Skill StatsSkillPrototype


--- @class EclLuaSkillGetPropertyDescriptionEventParams
--- @field Description STDString
--- @field Property StatsPropertyExtender


--- @class EclLuaStatusGetDescriptionEventParams
--- @field Description STDString
--- @field Owner StatsObjectInstance
--- @field Params STDString[]
--- @field Status StatsStatusPrototype
--- @field StatusSource StatsObjectInstance


--- @class EclLuaUICallEventParams
--- @field Args IggyInvokeDataValue[]
--- @field Function STDString
--- @field UI UIObject
--- @field When CString


--- @class EclLuaUIObjectCreatedEventParams
--- @field UI UIObject


--- @class EclLuaVisualClientMultiVisual:EclMultiEffectHandler
--- @field AddVisual fun(self:EclLuaVisualClientMultiVisual, a1:FixedString):Visual
--- @field Delete fun(self:EclLuaVisualClientMultiVisual)
--- @field ParseFromStats fun(self:EclLuaVisualClientMultiVisual, a1:CString, a2:CString|nil)
--- @field AttachedVisuals ComponentHandle[]
--- @field Handle ComponentHandle


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
--- @field GetAiFlags fun(self:EocAiGrid, a1:float, a2:float):uint64|nil
--- @field GetCellInfo fun(self:EocAiGrid, a1:float, a2:float)
--- @field GetHeight fun(self:EocAiGrid, a1:float, a2:float):float|nil
--- @field SearchForCell fun(self:EocAiGrid, a1:float, a2:float, a3:float, a4:ESurfaceFlag, a5:float):bool
--- @field SetAiFlags fun(self:EocAiGrid, a1:float, a2:float, a3:uint64)
--- @field SetHeight fun(self:EocAiGrid, a1:float, a2:float, a3:float)
--- @field GridScale float
--- @field Height uint32
--- @field OffsetX float
--- @field OffsetY float
--- @field OffsetZ float
--- @field Width uint32


--- @class EocItemDefinition
--- @field ResetProgression fun(self:EocItemDefinition)
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
--- @field Skills FixedString
--- @field Slot int16
--- @field StatsEntryName FixedString
--- @field StatsLevel uint32
--- @field Tags FixedString[]
--- @field UUID FixedString
--- @field Version uint32
--- @field WeightValueOverwrite int32


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


--- @class EsvASAttack
--- @field AlwaysHit bool
--- @field AnimationFinished bool
--- @field DamageDurability bool
--- @field HitCount int32
--- @field HitCountOffHand int32
--- @field IsFinished bool
--- @field MainHandHitType int32
--- @field MainWeaponHandle ComponentHandle
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


--- @class EsvASPrepareSkill
--- @field IsEntered bool
--- @field IsFinished bool
--- @field PrepareAnimationInit FixedString
--- @field PrepareAnimationLoop FixedString
--- @field SkillId FixedString


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


--- @class EsvAlignment:EsvHasRelationsObject
--- @field Entities EsvAlignmentEntity[]
--- @field MatrixIndex int32
--- @field MatrixIndex2 int32


--- @class EsvAlignmentContainer
--- @field Get fun(self:EsvAlignmentContainer):EsvAlignmentData
--- @field GetAll fun(self:EsvAlignmentContainer):ComponentHandle[]
--- @field IsPermanentEnemy fun(self:EsvAlignmentContainer, a1:ComponentHandle, a2:ComponentHandle):bool
--- @field IsTemporaryEnemy fun(self:EsvAlignmentContainer, a1:ComponentHandle, a2:ComponentHandle):bool
--- @field SetAlly fun(self:EsvAlignmentContainer, a1:ComponentHandle, a2:ComponentHandle, a3:bool)
--- @field SetPermanentEnemy fun(self:EsvAlignmentContainer, a1:ComponentHandle, a2:ComponentHandle, a3:bool)
--- @field SetTemporaryEnemy fun(self:EsvAlignmentContainer, a1:ComponentHandle, a2:ComponentHandle, a3:bool)


--- @class EsvAlignmentData
--- @field Alignment EsvAlignment
--- @field Handle ComponentHandle
--- @field HasOwnAlignment bool
--- @field MatrixIndex int32
--- @field Name FixedString
--- @field NetID NetId
--- @field ParentAlignment EsvAlignment


--- @class EsvAlignmentEntity:EsvHasRelationsObject


--- @class EsvAtmosphereTrigger


--- @class EsvChangeSurfaceOnPathAction:EsvCreateSurfaceActionBase
--- @field CheckExistingSurfaces bool
--- @field FollowObject ComponentHandle
--- @field IgnoreIrreplacableSurfaces bool
--- @field IgnoreOwnerCells bool
--- @field IsFinished bool
--- @field Radius float
--- @field SurfaceCollisionFlags uint32
--- @field SurfaceCollisionNotOnFlags uint32


--- @class EsvCharacter:IEoCServerObject
--- @field GetCustomStat fun(self:EsvCharacter, a1:FixedString):int32|nil
--- @field GetInventoryItems fun(self:EsvCharacter):FixedString[]
--- @field GetNearbyCharacters fun(self:EsvCharacter, a1:float):FixedString[]
--- @field GetSkillInfo fun(self:EsvCharacter, a1:FixedString):EsvSkill
--- @field GetSkills fun(self:EsvCharacter):FixedString[]
--- @field GetSummons fun(self:EsvCharacter):FixedString[]
--- @field SetCustomStat fun(self:EsvCharacter, a1:FixedString, a2:int32):bool
--- @field SetScale fun(self:EsvCharacter, a1:float)
--- @field AI EocAi
--- @field Activated bool
--- @field AnimType uint8
--- @field AnimationOverride FixedString
--- @field AnimationSetOverride FixedString
--- @field Archetype FixedString
--- @field CanShootThrough bool
--- @field CannotDie bool
--- @field CannotMove bool
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
--- @field CustomTradeTreasure FixedString
--- @field DamageCounter uint64
--- @field Deactivated bool
--- @field Dead bool
--- @field DelayDeathCount uint8
--- @field DelayedDyingStatus EsvStatus
--- @field Dialog uint32
--- @field DisabledCrime FixedString[]
--- @field EnemyCharacterHandle ComponentHandle
--- @field EnemyHandles ComponentHandle[]
--- @field EquipmentColor FixedString
--- @field Flags EsvCharacterFlags
--- @field Flags2 EsvCharacterFlags2
--- @field Flags3 EsvCharacterFlags3
--- @field FlagsEx uint8
--- @field Floating bool
--- @field FollowCharacterHandle ComponentHandle
--- @field ForceSynchCount uint8
--- @field Global bool
--- @field HasDefaultDialog bool
--- @field HasOsirisDialog bool
--- @field HasOwner bool
--- @field HasRunSpeedOverride bool
--- @field HasWalkSpeedOverride bool
--- @field HealCounter uint64
--- @field HostControl bool
--- @field InArena bool
--- @field InDialog bool
--- @field InParty bool
--- @field InventoryHandle ComponentHandle
--- @field InvestigationTimer uint32
--- @field IsAlarmed bool
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
--- @field MadePlayer bool
--- @field ManuallyLeveled bool
--- @field MovingCasterHandle ComponentHandle
--- @field Multiplayer bool
--- @field NeedsUpdateCount uint8
--- @field NoReptuationEffects bool
--- @field NoRotate bool
--- @field NoiseTimer float
--- @field NumConsumables uint8
--- @field ObjectHandle6 ComponentHandle
--- @field OffStage bool
--- @field OriginalTemplate CharacterTemplate
--- @field OriginalTransformDisplayName TranslatedString
--- @field OwnerHandle ComponentHandle
--- @field PartialAP float
--- @field PartyFollower bool
--- @field PartyHandle ComponentHandle
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
--- @field ReservedUserID UserId
--- @field Resurrected bool
--- @field RootTemplate CharacterTemplate
--- @field RunSpeedOverride float
--- @field ScriptForceUpdateCount uint8
--- @field ServerControlRefCount uint32
--- @field SkillBeingPrepared FixedString
--- @field SkillManager EsvSkillManager
--- @field SpiritCharacterHandle ComponentHandle
--- @field SpotSneakers bool
--- @field Stats CDivinityStatsCharacter
--- @field StatusMachine EsvStatusMachine
--- @field StatusesFromItems table<ComponentHandle, StatsPropertyStatus[]>
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


--- @class EsvCreatePuddleAction:EsvCreateSurfaceActionBase
--- @field GrowSpeed float
--- @field GrowTimer float
--- @field IgnoreIrreplacableSurfaces bool
--- @field IsFinished bool
--- @field Step int32
--- @field SurfaceCells int32


--- @class EsvCreateSurfaceAction:EsvCreateSurfaceActionBase
--- @field CheckExistingSurfaces bool
--- @field CurrentCellCount int32
--- @field ExcludeRadius float
--- @field GrowStep int32
--- @field GrowTimer float
--- @field IgnoreIrreplacableSurfaces bool
--- @field MaxHeight float
--- @field Radius float
--- @field SurfaceCollisionFlags uint64
--- @field SurfaceCollisionNotOnFlags uint64
--- @field SurfaceLayer SurfaceLayer
--- @field Timer float


--- @class EsvCreateSurfaceActionBase:EsvSurfaceAction
--- @field Duration float
--- @field OwnerHandle ComponentHandle
--- @field Position vec3
--- @field StatusChance float
--- @field SurfaceType SurfaceType


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


--- @class EsvEffect:BaseComponent
--- @field Delete fun(self:EsvEffect)
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


--- @class EsvEnvironmentalInfluences
--- @field HasWeatherProofTalent bool
--- @field OwnerHandle ComponentHandle
--- @field PermanetInfluences table<FixedString, EsvEnvironmentalInfluencesPermanentInfluence>
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


--- @class EsvExtinguishFireAction:EsvCreateSurfaceActionBase
--- @field ExtinguishPosition vec3
--- @field GrowTimer float
--- @field Percentage float
--- @field Radius float
--- @field Step float


--- @class EsvHasRelationsObject
--- @field Handle ComponentHandle
--- @field Name FixedString
--- @field NetID NetId
--- @field TemporaryRelations table<ComponentHandle, int32>
--- @field TemporaryRelations2 table<ComponentHandle, int32>


--- @class EsvInventory
--- @field BuyBackAmounts table<FixedString, uint32>
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
--- @field TimeItemAddedToInventory table<FixedString, uint32>
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


--- @class EsvItem:IEoCServerObject
--- @field GetDeltaMods fun(self:EsvItem):FixedString[]
--- @field GetGeneratedBoosts fun(self:EsvItem):FixedString[]
--- @field GetInventoryItems fun(self:EsvItem):FixedString[]
--- @field GetNearbyCharacters fun(self:EsvItem, a1:float):FixedString[]
--- @field SetDeltaMods fun(self:EsvItem)
--- @field SetGeneratedBoosts fun(self:EsvItem)
--- @field AI EocAi
--- @field Activated bool
--- @field Amount uint32
--- @field Armor uint32
--- @field CanBeMoved bool
--- @field CanBePickedUp bool
--- @field CanConsume bool
--- @field CanShootThrough bool
--- @field CanUse bool
--- @field ComputedVitality int32
--- @field CurrentLevel FixedString
--- @field CurrentTemplate ItemTemplate
--- @field CustomBookContent STDWString
--- @field CustomDescription STDWString
--- @field CustomDisplayName STDWString
--- @field Destroy bool
--- @field Destroyed bool
--- @field Flags EsvItemFlags
--- @field Flags2 EsvItemFlags2
--- @field Floating bool
--- @field ForceSync bool
--- @field ForceSynch bool
--- @field FreezeGravity bool
--- @field Frozen bool
--- @field GMFolding bool
--- @field Generation EsvItemGeneration
--- @field Global bool
--- @field GoldValueOverwrite int32
--- @field InUseByCharacterHandle ComponentHandle
--- @field InteractionDisabled bool
--- @field InventoryHandle ComponentHandle
--- @field Invisible bool
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
--- @field TreasureGenerated bool
--- @field TreasureLevel int32
--- @field UnEquipLocked bool
--- @field UnsoldGenerated bool
--- @field UseRemotely bool
--- @field UserId uint32
--- @field VisualResourceID FixedString
--- @field Vitality uint32
--- @field WalkOn bool
--- @field WalkThrough bool
--- @field WeightValueOverwrite int32
--- @field WorldPos vec3


--- @class EsvItemGeneration
--- @field Base FixedString
--- @field Boosts FixedString[]
--- @field ItemType FixedString
--- @field Level uint16
--- @field Random uint32


--- @class EsvLevel:Level
--- @field AiGrid EocAiGrid
--- @field EnvironmentalStatusManager EsvEnvironmentalStatusManager


--- @class EsvLevelManager
--- @field CurrentLevel EsvLevel
--- @field LevelDescs LevelDesc[]
--- @field Levels table<FixedString, EsvLevel>
--- @field Levels2 table<FixedString, EsvLevel>


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


--- @class EsvPlayerCustomData:EocPlayerCustomData


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


--- @class EsvPolygonSurfaceAction:EsvCreateSurfaceActionBase
--- @field CurrentGrowTimer float
--- @field GrowStep int32
--- @field GrowTimer float
--- @field PositionX float
--- @field PositionZ float


--- @class EsvProjectile:IEoCServerObject
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


--- @class EsvRectangleSurfaceAction:EsvCreateSurfaceActionBase
--- @field AiFlags uint64
--- @field CurrentGrowTimer float
--- @field DeathType StatsDeathType
--- @field GrowStep int32
--- @field GrowTimer float
--- @field Length float
--- @field LineCheckBlock uint64
--- @field MaxHeight float
--- @field SurfaceArea float
--- @field Target vec3
--- @field Width float


--- @class EsvShootProjectileHelper
--- @field Caster ComponentHandle
--- @field CasterLevel int32
--- @field CleanseStatuses FixedString
--- @field DamageList StatsDamagePairList
--- @field EndPosition vec3
--- @field HitObject EsvShootProjectileHelperHitObject
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


--- @class EsvShootProjectileHelperHitObject
--- @field HitInterpolation int32
--- @field Position vec3
--- @field Target ComponentHandle


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


--- @class EsvStatus
--- @field BringIntoCombat bool
--- @field CanEnterChance uint32
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


--- @class EsvStatusActiveDefense:EsvStatusConsumeBase
--- @field Charges int32
--- @field PreviousTargets ComponentHandle[]
--- @field Projectile FixedString
--- @field Radius float
--- @field StatusTargetHandle ComponentHandle
--- @field TargetPos vec3


--- @class EsvStatusAdrenaline:EsvStatusConsumeBase
--- @field CombatTurn int32
--- @field InitialAPMod int32
--- @field SecondaryAPMod int32


--- @class EsvStatusAoO:EsvStatus
--- @field ActivateAoOBoost bool
--- @field AoOTargetHandle ComponentHandle
--- @field PartnerHandle ComponentHandle
--- @field ShowOverhead bool
--- @field SourceHandle ComponentHandle


--- @class EsvStatusBoost:EsvStatus
--- @field BoostId FixedString
--- @field EffectTime float


--- @class EsvStatusChallenge:EsvStatusConsumeBase
--- @field SourceHandle ComponentHandle
--- @field Target bool


--- @class EsvStatusCharmed:EsvStatusConsumeBase
--- @field OriginalOwnerCharacterHandle ComponentHandle
--- @field UserId uint32


--- @class EsvStatusClimbing:EsvStatus
--- @field Direction bool
--- @field JumpUpLadders bool
--- @field LadderHandle ComponentHandle
--- @field Level FixedString
--- @field MoveDirection vec3
--- @field Status int32


--- @class EsvStatusCombat:EsvStatus
--- @field OwnerTeamId int32
--- @field ReadyForCombat bool


--- @class EsvStatusConsume:EsvStatusConsumeBase


--- @class EsvStatusConsumeBase:EsvStatus
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


--- @class EsvStatusDamage:EsvStatusConsumeBase
--- @field DamageEvent int32
--- @field DamageLevel int32
--- @field DamageStats FixedString
--- @field HitTimer float
--- @field SpawnBlood bool
--- @field TimeElapsed float


--- @class EsvStatusDamageOnMove:EsvStatusDamage
--- @field DistancePerDamage float
--- @field DistanceTraveled float


--- @class EsvStatusDrain:EsvStatus
--- @field Infused int32


--- @class EsvStatusDying:EsvStatus
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


--- @class EsvStatusExplode:EsvStatus
--- @field Projectile FixedString


--- @class EsvStatusHeal:EsvStatus
--- @field AbsorbSurfaceRange uint32
--- @field AbsorbSurfaceTypes SurfaceType[]
--- @field EffectTime float
--- @field HealAmount uint32
--- @field HealEffect HealEffect
--- @field HealEffectId FixedString
--- @field HealType StatusHealType
--- @field TargetDependentHeal bool
--- @field TargetDependentHealAmount int32[]
--- @field TargetDependentValue int32[]


--- @class EsvStatusHealSharing:EsvStatusConsumeBase
--- @field CasterHandle ComponentHandle


--- @class EsvStatusHealSharingCaster:EsvStatusConsumeBase
--- @field StatusTargetHandle ComponentHandle


--- @class EsvStatusHealing:EsvStatusConsumeBase
--- @field AbsorbSurfaceRange uint32
--- @field HealAmount uint32
--- @field HealEffect HealEffect
--- @field HealEffectId FixedString
--- @field HealStat StatusHealType
--- @field HealingEvent uint32
--- @field SkipInitialEffect bool
--- @field TimeElapsed float


--- @class EsvStatusHit:EsvStatus
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


--- @class EsvStatusIdentify:EsvStatus
--- @field Identified int32
--- @field IdentifierHandle ComponentHandle
--- @field Level int32


--- @class EsvStatusInSurface:EsvStatus
--- @field Force bool
--- @field Layers ESurfaceFlag
--- @field SurfaceDistanceCheck float
--- @field SurfaceTimerCheck float
--- @field Translate vec3


--- @class EsvStatusIncapacitated:EsvStatusConsumeBase
--- @field CurrentFreezeTime float
--- @field FreezeTime float
--- @field FrozenFlag uint8


--- @class EsvStatusInfectiousDiseased:EsvStatusConsumeBase
--- @field InfectTimer float
--- @field Infections int32
--- @field Radius float
--- @field StatusTargetHandle ComponentHandle


--- @class EsvStatusInvisible:EsvStatusConsumeBase
--- @field InvisiblePosition vec3


--- @class EsvStatusKnockedDown:EsvStatus
--- @field IsInstant bool
--- @field KnockedDownState int32


--- @class EsvStatusLying:EsvStatus
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


--- @class EsvStatusMaterial:EsvStatus
--- @field ApplyFlags EsvStatusMaterialApplyFlags
--- @field ApplyNormalMap bool
--- @field Fading bool
--- @field Force bool
--- @field IsOverlayMaterial bool
--- @field MaterialUUID FixedString


--- @class EsvStatusPolymorphed:EsvStatusConsumeBase
--- @field DisableInteractions bool
--- @field OriginalTemplate FixedString
--- @field OriginalTemplateType int32
--- @field PolymorphResult FixedString
--- @field TransformedRace FixedString


--- @class EsvStatusRepair:EsvStatus
--- @field Level int32
--- @field Repaired int32
--- @field RepairerHandle ComponentHandle


--- @class EsvStatusRotate:EsvStatus
--- @field RotationSpeed float
--- @field Yaw float


--- @class EsvStatusShacklesOfPain:EsvStatusConsumeBase
--- @field CasterHandle ComponentHandle


--- @class EsvStatusShacklesOfPainCaster:EsvStatusConsumeBase
--- @field VictimHandle ComponentHandle


--- @class EsvStatusSneaking:EsvStatus
--- @field ClientRequestStop bool


--- @class EsvStatusSpark:EsvStatusConsumeBase
--- @field Charges int32
--- @field Projectile FixedString
--- @field Radius float


--- @class EsvStatusSpirit:EsvStatus
--- @field Characters ComponentHandle[]


--- @class EsvStatusSpiritVision:EsvStatusConsumeBase
--- @field SpiritVisionSkillId FixedString


--- @class EsvStatusStance:EsvStatusConsumeBase
--- @field SkillId FixedString


--- @class EsvStatusSummoning:EsvStatus
--- @field AnimationDuration float
--- @field SummonLevel int32


--- @class EsvStatusTeleportFall:EsvStatus
--- @field HasDamage bool
--- @field HasDamageBeenApplied bool
--- @field ReappearTime float
--- @field SkillId FixedString
--- @field Target vec3


--- @class EsvStatusThrown:EsvStatus
--- @field AnimationDuration float
--- @field CasterHandle ComponentHandle
--- @field IsThrowingSelf bool
--- @field Landed bool
--- @field LandingEstimate float
--- @field Level int32


--- @class EsvStatusUnlock:EsvStatus
--- @field Key FixedString
--- @field Level int32
--- @field SourceHandle ComponentHandle
--- @field Unlocked int32


--- @class EsvStatusUnsheathed:EsvStatus
--- @field Force bool


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
--- @field TeamId int32


--- @class EsvSurfaceAction
--- @field MyHandle ComponentHandle


--- @class EsvSwapSurfaceAction:EsvCreateSurfaceActionBase
--- @field CheckExistingSurfaces bool
--- @field CurrentCellCount int32
--- @field ExcludeRadius float
--- @field GrowStep int32
--- @field GrowTimer float
--- @field IgnoreIrreplacableSurfaces bool
--- @field LineCheckBlock uint64
--- @field MaxHeight float
--- @field Radius float
--- @field SurfaceCollisionFlags uint64
--- @field SurfaceCollisionNotOnFlags uint64
--- @field Target vec3
--- @field Timer float


--- @class EsvTransformSurfaceAction:EsvSurfaceAction
--- @field Finished bool
--- @field GrowCellPerSecond float
--- @field OriginSurface SurfaceType
--- @field OwnerHandle ComponentHandle
--- @field Position vec3
--- @field SurfaceLayer SurfaceLayer
--- @field SurfaceLifetime float
--- @field SurfaceStatusChance float
--- @field SurfaceTransformAction SurfaceTransformActionType
--- @field Timer float


--- @class EsvTrigger


--- @class EsvZoneAction:EsvCreateSurfaceActionBase
--- @field AiFlags uint64
--- @field AngleOrBase float
--- @field BackStart float
--- @field DeathType StatsDeathType
--- @field FrontOffset float
--- @field GrowStep uint32
--- @field GrowTimer float
--- @field GrowTimerStart float
--- @field IsFromItem bool
--- @field MaxHeight float
--- @field Radius float
--- @field Shape int32
--- @field SkillId FixedString
--- @field Target vec3


--- @class EsvLuaAfterCraftingExecuteCombinationEventParams
--- @field Character EsvCharacter
--- @field CombinationId FixedString
--- @field CraftingStation CraftingStationType
--- @field Items EsvItem[]
--- @field Quantity uint8
--- @field Succeeded bool


--- @class EsvLuaAiRequestPeekEventParams
--- @field ActionType AiActionType
--- @field CharacterHandle ComponentHandle
--- @field IsFinished bool
--- @field Request EsvAiRequest


--- @class EsvLuaAiRequestSortEventParams
--- @field CharacterHandle ComponentHandle
--- @field Request EsvAiRequest


--- @class EsvLuaBeforeCharacterApplyDamageEventParams
--- @field Attacker StatsObjectInstance
--- @field Cause CauseType
--- @field Context EsvPendingHit
--- @field Handled bool
--- @field Hit StatsHitDamageInfo
--- @field ImpactDirection vec3
--- @field Target EsvCharacter


--- @class EsvLuaBeforeCraftingExecuteCombinationEventParams
--- @field Character EsvCharacter
--- @field CombinationId FixedString
--- @field CraftingStation CraftingStationType
--- @field Items EsvItem[]
--- @field Processed bool
--- @field Quantity uint8


--- @class EsvLuaBeforeShootProjectileEventParams
--- @field Projectile EsvShootProjectileHelper


--- @class EsvLuaBeforeStatusApplyEventParams
--- @field Owner IEoCServerObject
--- @field PreventStatusApply bool
--- @field Status EsvStatus


--- @class EsvLuaComputeCharacterHitEventParams
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


--- @class EsvLuaExecutePropertyDataOnGroundHitEventParams
--- @field Caster IEoCServerObject
--- @field DamageList StatsDamagePairList
--- @field Position vec3


--- @class EsvLuaExecutePropertyDataOnPositionEventParams
--- @field AreaRadius float
--- @field Attacker IEoCServerObject
--- @field Hit StatsHitDamageInfo
--- @field IsFromItem bool
--- @field Position vec3
--- @field Property StatsPropertyExtender
--- @field Skill StatsSkillPrototype


--- @class EsvLuaExecutePropertyDataOnTargetEventParams
--- @field Attacker IEoCServerObject
--- @field Hit StatsHitDamageInfo
--- @field ImpactOrigin vec3
--- @field IsFromItem bool
--- @field Property StatsPropertyExtender
--- @field Skill StatsSkillPrototype
--- @field Target IEoCServerObject


--- @class EsvLuaGameStateChangeEventParams
--- @field FromState EsvGameState
--- @field ToState EsvGameState


--- @class EsvLuaProjectileHitEventParams
--- @field HitObject IEoCServerObject
--- @field Position vec3
--- @field Projectile EsvProjectile


--- @class EsvLuaShootProjectileEventParams
--- @field Projectile EsvProjectile


--- @class EsvLuaStatusDeleteEventParams
--- @field Status EsvStatus


--- @class EsvLuaStatusGetEnterChanceEventParams
--- @field EnterChance int32|nil
--- @field IsEnterCheck bool
--- @field Status EsvStatus


--- @class EsvLuaStatusHitEnterEventParams
--- @field Context EsvPendingHit
--- @field Hit EsvStatusHit


--- @class EsvLuaTreasureItemGeneratedEventParams
--- @field Item EsvItem
--- @field ResultingItem EsvItem


--- @class LuaConsoleEventParams
--- @field Command STDString


--- @class LuaEmptyEventParams


--- @class LuaGetHitChanceEventParams
--- @field Attacker CDivinityStatsCharacter
--- @field HitChance int32|nil
--- @field Target CDivinityStatsCharacter


--- @class LuaGetSkillAPCostEventParams
--- @field AP int32|nil
--- @field AiGrid EocAiGrid
--- @field Character CDivinityStatsCharacter
--- @field ElementalAffinity bool|nil
--- @field Position vec3
--- @field Radius float
--- @field Skill StatsSkillPrototype


--- @class LuaGetSkillDamageEventParams
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


--- @class LuaNetMessageEventParams
--- @field Channel STDString
--- @field Payload STDString
--- @field UserID UserId


--- @class LuaTickEventParams
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
--- @field Add fun(self:StatsDamagePairList, a1:StatsDamageType, a2:int32)
--- @field AggregateSameTypeDamages fun(self:StatsDamagePairList)
--- @field Clear fun(self:StatsDamagePairList, a1:StatsDamageType|nil)
--- @field ConvertDamageType fun(self:StatsDamagePairList, a1:StatsDamageType)
--- @field CopyFrom fun(self:StatsDamagePairList)
--- @field GetByType fun(self:StatsDamagePairList, a1:StatsDamageType):int32
--- @field Merge fun(self:StatsDamagePairList)
--- @field Multiply fun(self:StatsDamagePairList, a1:float)
--- @field ToTable fun(self:StatsDamagePairList)


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


--- @class StatsObjectInstance:StatsObject
--- @field InstanceId uint32


--- @class StatsPropertyData
--- @field Context StatsPropertyContext
--- @field Name FixedString
--- @field TypeId StatsPropertyType


--- @class StatsPropertyExtender:StatsPropertyData
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


--- @class StatsPropertyStatus:StatsPropertyData
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


--- @class Ext.Debug
--- @field DebugBreak fun()
--- @field DebugDumpLifetimes fun()
--- @field DumpNetworking fun()
--- @field DumpStack fun()
--- @field GenerateIdeHelpers fun(a1:bool|nil)
--- @field IsDeveloperMode fun():bool


--- @class Ext.IO
--- @field AddPathOverride fun(a1:CString, a2:CString)
--- @field GetPathOverride fun(a1:CString):STDString|nil
--- @field LoadFile fun(a1:CString, a2:FixedString|nil):STDString|nil
--- @field SaveFile fun(a1:CString, a2:CString):bool


--- @class Ext.Json
--- @field Parse fun()
--- @field Stringify fun()


--- @class Ext.L10N
--- @field CreateTranslatedString fun(a1:CString, a2:CString):STDString|nil
--- @field CreateTranslatedStringHandle fun(a1:CString, a2:CString):bool
--- @field CreateTranslatedStringKey fun(a1:CString, a2:CString):bool
--- @field GetTranslatedString fun(a1:CString, a2:CString|nil):STDString
--- @field GetTranslatedStringFromKey fun(a1:FixedString)


--- @class Ext.Mod
--- @field GetBaseMod fun():Module
--- @field GetLoadOrder fun():FixedString[]
--- @field GetMod fun(a1:CString):Module
--- @field GetModInfo fun(a1:CString)
--- @field IsModLoaded fun(a1:CString):bool


--- @class Ext.Resource
--- @field Get fun(a1:ResourceType, a2:FixedString):Resource


--- @class Ext.Stats
--- @field AddCustomDescription fun(a1:CString, a2:CString, a3:CString)
--- @field AddVoiceMetaData fun(a1:FixedString, a2:FixedString, a3:CString, a4:float, a5:int32|nil)
--- @field Create fun(a1:FixedString, a2:FixedString, a3:FixedString|nil, a4:bool|nil)
--- @field EnumIndexToLabel fun(a1:FixedString, a2:int32)
--- @field EnumLabelToIndex fun(a1:FixedString, a2:FixedString)
--- @field Get fun(a1:CString, a2:int32|nil, a3:bool|nil, a4:bool|nil)
--- @field GetAttribute fun(a1:CString, a2:FixedString)
--- @field GetCharacterCreation fun():CharacterCreationCharacterCreationManager
--- @field GetStats fun(a1:FixedString|nil)
--- @field GetStatsLoadedBefore fun(a1:FixedString, a2:FixedString|nil):FixedString[]
--- @field NewDamageList fun()
--- @field SetAttribute fun(a1:CString, a2:FixedString):bool
--- @field SetLevelScaling fun(a1:FixedString, a2:FixedString)
--- @field SetPersistence fun(a1:FixedString, a2:bool)
--- @field Sync fun(a1:FixedString, a2:bool|nil)


--- @class Ext.Stats.DeltaMod
--- @field GetLegacy fun(a1:FixedString, a2:FixedString)
--- @field Update fun()


--- @class Ext.Stats.EquipmentSet
--- @field GetLegacy fun(a1:FixedString)
--- @field Update fun()


--- @class Ext.Stats.ItemColor
--- @field Get fun(a1:FixedString):StatsItemColorDefinition
--- @field GetAll fun()
--- @field Update fun()


--- @class Ext.Stats.ItemCombo
--- @field GetLegacy fun(a1:FixedString)
--- @field Update fun()


--- @class Ext.Stats.ItemComboPreview
--- @field GetLegacy fun(a1:FixedString)
--- @field Update fun()


--- @class Ext.Stats.ItemComboProperty
--- @field GetLegacy fun(a1:FixedString)
--- @field Update fun()


--- @class Ext.Stats.ItemGroup
--- @field GetLegacy fun(a1:FixedString)


--- @class Ext.Stats.ItemSet
--- @field GetLegacy fun(a1:FixedString)
--- @field Update fun()


--- @class Ext.Stats.NameGroup
--- @field GetLegacy fun(a1:FixedString)


--- @class Ext.Stats.SkillSet
--- @field GetLegacy fun(a1:CString)
--- @field Update fun()


--- @class Ext.Stats.TreasureCategory
--- @field GetLegacy fun(a1:FixedString)
--- @field Update fun(a1:FixedString)


--- @class Ext.Stats.TreasureTable
--- @field GetLegacy fun(a1:FixedString)
--- @field Update fun()


--- @class Ext.Surface
--- @field GetTemplate fun(a1:SurfaceType):SurfaceTemplate
--- @field GetTransformRules fun()
--- @field UpdateTransformRules fun()


--- @class Ext.Types
--- @field GetAllTypes fun():FixedString[]
--- @field GetObjectType fun()
--- @field GetTypeInfo fun(a1:FixedString):TypeInformation


--- @class Ext.Utils
--- @field GameVersion fun():STDString|nil
--- @field GetDifficulty fun():uint32
--- @field GetGameMode fun():STDString
--- @field GetGlobalSwitches fun():GlobalSwitches
--- @field GetHandleType fun(a1:ComponentHandle):STDString
--- @field Include fun()
--- @field MonotonicTime fun():int32
--- @field Print fun()
--- @field PrintError fun()
--- @field PrintWarning fun()
--- @field Random fun():int64
--- @field Round fun(a1:double):int64
--- @field ShowErrorAndExitGame fun(a1:STDWString)
--- @field Version fun():int32


--- @class ExtClient.Audio
--- @field GetRTPC fun():int32
--- @field PauseAllSounds fun():int32
--- @field PlayExternalSound fun():int32
--- @field PostEvent fun():int32
--- @field ResetRTPC fun():int32
--- @field ResumeAllSounds fun():int32
--- @field SetRTPC fun():int32
--- @field SetState fun():int32
--- @field SetSwitch fun():int32
--- @field Stop fun():int32


--- @class ExtClient.Client
--- @field GetGameState fun()
--- @field GetModManager fun():ModManager
--- @field UpdateShroud fun(a1:float, a2:float, a3:ShroudType, a4:int32)


--- @class ExtClient.Entity
--- @field GetAiGrid fun():EocAiGrid
--- @field GetCharacter fun()
--- @field GetCurrentLevel fun():EclLevel
--- @field GetGameObject fun():IEoCClientObject
--- @field GetInventory fun(a1:ComponentHandle):EclInventory
--- @field GetItem fun()
--- @field GetStatus fun():EclStatus
--- @field NullHandle fun():ComponentHandle


--- @class ExtClient.Net
--- @field PostMessageToServer fun(a1:CString, a2:CString)


--- @class ExtClient.Template
--- @field GetCacheTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetLocalCacheTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetLocalTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetRootTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetTemplate fun(a1:FixedString):GameObjectTemplate


--- @class ExtClient.UI
--- @field Create fun(a1:CString, a2:CString, a3:int32):UIObject
--- @field Destroy fun(a1:CString)
--- @field DoubleToHandle fun(a1:double):ComponentHandle
--- @field EnableCustomDrawCallDebugging fun(a1:bool)
--- @field GetByName fun(a1:CString):UIObject
--- @field GetByPath fun(a1:CString):UIObject
--- @field GetByType fun(a1:int32):UIObject
--- @field GetCharacterCreationWizard fun():EclCharacterCreationUICharacterCreationWizard
--- @field GetDragDrop fun():DragDropManager
--- @field GetPickingState fun(a1:int32|nil)
--- @field GetViewportSize fun():ivec2
--- @field HandleToDouble fun(a1:ComponentHandle):double
--- @field LoadFlashLibrary fun(a1:STDString, a2:STDString):bool
--- @field SetDirty fun(a1:ComponentHandle, a2:uint64)


--- @class ExtClient.Visual
--- @field Create fun(a1:vec3):EclLuaVisualClientMultiVisual
--- @field CreateOnCharacter fun(a1:vec3):EclLuaVisualClientMultiVisual
--- @field CreateOnItem fun(a1:vec3):EclLuaVisualClientMultiVisual
--- @field Get fun(a1:ComponentHandle):EclLuaVisualClientMultiVisual
--- @field GetVisualObject fun(a1:ComponentHandle):Visual


--- @class ExtServer.Ai
--- @field GetAiHelpers fun():EsvAiHelpers
--- @field GetArchetypes fun():EsvAiModifiers


--- @class ExtServer.CustomStat
--- @field Create fun(a1:CString, a2:CString):FixedString|nil
--- @field GetAll fun()
--- @field GetById fun(a1:CString)
--- @field GetByName fun(a1:CString)


--- @class ExtServer.Effect
--- @field CreateEffect fun(a1:FixedString, a2:ComponentHandle, a3:FixedString|nil):EsvEffect
--- @field GetAllEffectHandles fun():ComponentHandle[]
--- @field GetEffect fun(a1:ComponentHandle):EsvEffect


--- @class ExtServer.Entity
--- @field GetAiGrid fun():EocAiGrid
--- @field GetAlignmentManager fun():EsvAlignmentContainer
--- @field GetAllCharacterGuids fun(a1:FixedString|nil):FixedString[]
--- @field GetAllItemGuids fun(a1:FixedString|nil):FixedString[]
--- @field GetAllTriggerGuids fun(a1:FixedString|nil):FixedString[]
--- @field GetCharacter fun()
--- @field GetCharacterGuidsAroundPosition fun(a1:float, a2:float, a3:float, a4:float):FixedString[]
--- @field GetCombat fun(a1:uint32)
--- @field GetCurrentLevel fun():EsvLevel
--- @field GetCurrentLevelData fun()
--- @field GetGameObject fun():IEoCServerObject
--- @field GetInventory fun(a1:ComponentHandle):EsvInventory
--- @field GetItem fun():EsvItem
--- @field GetItemGuidsAroundPosition fun(a1:float, a2:float, a3:float, a4:float):FixedString[]
--- @field GetStatus fun():EsvStatus
--- @field GetSurface fun(a1:ComponentHandle):EsvSurface
--- @field GetTrigger fun()
--- @field NullHandle fun():ComponentHandle


--- @class ExtServer.Net
--- @field BroadcastMessage fun(a1:CString, a2:CString, a3:CString|nil)
--- @field PlayerHasExtender fun(a1:CString):bool|nil
--- @field PostMessageToClient fun(a1:CString, a2:CString, a3:CString)
--- @field PostMessageToUser fun(a1:int32, a2:CString, a3:CString)


--- @class ExtServer.Osiris
--- @field IsCallable fun():bool
--- @field NewCall fun()
--- @field NewEvent fun()
--- @field NewQuery fun()
--- @field RegisterListener fun(a1:CString, a2:int32, a3:CString)


--- @class ExtServer.PropertyList
--- @field ExecuteExtraPropertiesOnPosition fun(a1:FixedString, a2:FixedString, a3:EsvCharacter, a4:vec3, a5:float, a6:StatsPropertyContext, a7:bool, a8:FixedString|nil)
--- @field ExecuteExtraPropertiesOnTarget fun(a1:FixedString, a2:FixedString, a3:EsvCharacter, a4:EsvCharacter, a5:vec3, a6:StatsPropertyContext, a7:bool, a8:FixedString|nil)
--- @field ExecuteSkillPropertiesOnPosition fun()
--- @field ExecuteSkillPropertiesOnTarget fun()


--- @class ExtServer.Server
--- @field GetGameState fun()
--- @field GetModManager fun():ModManager


--- @class ExtServer.Surface.Action
--- @field Cancel fun(a1:ComponentHandle)
--- @field Create fun(a1:SurfaceActionType):EsvSurfaceAction
--- @field Execute fun(a1:EsvSurfaceAction)


--- @class ExtServer.Template
--- @field CreateCacheTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetCacheTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetLocalCacheTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetLocalTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetRootTemplate fun(a1:FixedString):GameObjectTemplate
--- @field GetTemplate fun(a1:FixedString):GameObjectTemplate


