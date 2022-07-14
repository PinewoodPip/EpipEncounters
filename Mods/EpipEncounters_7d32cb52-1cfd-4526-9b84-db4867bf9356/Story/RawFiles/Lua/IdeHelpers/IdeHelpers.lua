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
--- @alias Version int32[]
--- @alias ivec2 int32[]
--- @alias mat3 float[]
--- @alias mat4 float[]
--- @alias vec2 float[]
--- @alias vec3 float[]
--- @alias vec4 float[]


--- @alias AIFlags string | "'CanNotTargetFrozen'" | "'CanNotUse'" | "'IgnoreSelf'" | "'IgnoreDebuff'" | "'IgnoreBuff'" | "'IgnoreControl'" | "'StatusIsSecondary'"
--- @alias ActionDataType string | "'SkillBook'" | "'Identify'" | "'DisarmTrap'" | "'SpawnCharacter'" | "'Constrain'" | "'StoryUseInInventoryOnly'" | "'KickstarterMessageInABottle'" | "'Lockpick'" | "'Unknown'" | "'Destroy'" | "'DestroyParameters'" | "'Sticky'" | "'Craft'" | "'Lying'" | "'Recipe'" | "'Equip'" | "'Door'" | "'Pyramid'" | "'Consume'" | "'Repair'" | "'StoryUseInInventory'" | "'OpenClose'" | "'Book'" | "'Teleport'" | "'PlaySound'" | "'CreateSurface'" | "'ShowStoryElementUI'" | "'StoryUse'" | "'Sit'" | "'CreatePuddle'" | "'UseSkill'" | "'Ladder'"
--- @alias AiActionStep string | "'ScoreActions'" | "'ReevaluateActions'" | "'ScoreActionsAPSaving'" | "'CollectPossibleActions'" | "'CalculateFutureScores'" | "'ScoreActionsBehavior'" | "'Init'" | "'CalculateStandardAttack'" | "'ScoreActionsFallback'" | "'CalculateSkills'" | "'CalculateItems'" | "'CalculatePositionScores'" | "'SortActions'"
--- @alias AiActionType string | "'Skill'" | "'Consume'" | "'None'" | "'StandardAttack'" | "'FallbackCommand'"
--- @alias AiModifier string | "'MULTIPLIER_DAMAGE_ALLY_NEG'" | "'MULTIPLIER_BOOST_ALLY_POS'" | "'MULTIPLIER_FREE_ACTION'" | "'MULTIPLIER_MOVEMENT_COST_MULTPLIER'" | "'MULTIPLIER_SCORE_OUT_OF_COMBAT'" | "'MULTIPLIER_AP_BOOST'" | "'MULTIPLIER_FIRST_ACTION_BUFF'" | "'SCORE_MOD'" | "'MULTIPLIER_DOT_ENEMY_POS'" | "'MULTIPLIER_ARMOR_NEUTRAL_NEG'" | "'MULTIPLIER_CANNOT_EXECUTE_THIS_TURN'" | "'MULTIPLIER_DAMAGEBOOST'" | "'MULTIPLIER_DECAYING_TOUCH'" | "'MULTIPLIER_SHIELD_BLOCK'" | "'MULTIPLIER_CONTROL_ENEMY_NEG'" | "'MULTIPLIER_ENDPOS_ALLIES_NEARBY'" | "'MULTIPLIER_ENDPOS_TURNED_INVISIBLE'" | "'MULTIPLIER_CHARMED'" | "'MULTIPLIER_FEAR'" | "'MULTIPLIER_CONTACT_BOOST'" | "'MULTIPLIER_DAMAGE_NEUTRAL_NEG'" | "'MULTIPLIER_BOOST_NEUTRAL_POS'" | "'MULTIPLIER_VITALITYBOOST'" | "'MULTIPLIER_STATUS_CANCEL_INVISIBILITY'" | "'MULTIPLIER_MUTE'" | "'MULTIPLIER_SPARK'" | "'MULTIPLIER_DOT_NEUTRAL_POS'" | "'MULTIPLIER_HOT_SELF_NEG'" | "'MULTIPLIER_TARGET_MY_ENEMY'" | "'MULTIPLIER_ACTIVE_DEFENSE'" | "'MULTIPLIER_DODGE_BOOST'" | "'MULTIPLIER_SUMMON_PATH_INFLUENCES'" | "'BUFF_DIST_MAX'" | "'MULTIPLIER_CONTROL_ALLY_NEG'" | "'MULTIPLIER_ENDPOS_FLANKED'" | "'FALLBACK_ENEMIES_NEARBY'" | "'MULTIPLIER_SP_COSTBOOST'" | "'TURNS_REPLACEMENT_INFINITE'" | "'BUFF_DIST_MIN'" | "'MULTIPLIER_HEAL_SELF_NEG'" | "'MULTIPLIER_ARMOR_SELF_POS'" | "'MULTIPLIER_ACTION_COST_MULTIPLIER'" | "'MULTIPLIER_KILL_ENEMY_SUMMON'" | "'MULTIPLIER_LOSE_CONTROL'" | "'AVENGE_ME_RADIUS'" | "'MULTIPLIER_HOT_ENEMY_POS'" | "'MULTIPLIER_HIGH_ITEM_AMOUNT_MULTIPLIER'" | "'MULTIPLIER_TARGET_SUMMON'" | "'MULTIPLIER_HEAL_SHARING'" | "'SKILL_JUMP_MINIMUM_DISTANCE'" | "'MULTIPLIER_DAMAGE_SELF_POS'" | "'MULTIPLIER_DOT_ALLY_POS'" | "'MULTIPLIER_CONTROL_NEUTRAL_NEG'" | "'MULTIPLIER_ENDPOS_HEIGHT_DIFFERENCE'" | "'MULTIPLIER_ENDPOS_NOT_IN_SMOKE'" | "'MULTIPLIER_REMOVE_ARMOR'" | "'MULTIPLIER_POSITION_LEAVE'" | "'MULTIPLIER_HEAL_ENEMY_NEG'" | "'MULTIPLIER_ARMOR_ENEMY_POS'" | "'ENDPOS_NEARBY_DISTANCE'" | "'MULTIPLIER_SURFACE_STATUS_ON_MOVE'" | "'SURFACE_DAMAGE_MAX_TURNS'" | "'MULTIPLIER_AP_MAX'" | "'MULTIPLIER_HOT_NEUTRAL_POS'" | "'MULTIPLIER_TARGET_IN_SIGHT'" | "'MULTIPLIER_ARMORBOOST'" | "'MULTIPLIER_ADD_MAGIC_ARMOR'" | "'MULTIPLIER_COMBO_SCORE_POSITIONING'" | "'UNSTABLE_BOMB_NEARBY'" | "'MULTIPLIER_DAMAGE_ENEMY_POS'" | "'MULTIPLIER_BOOST_SELF_NEG'" | "'MOVESKILL_AP_DIFF_REQUIREMENT'" | "'MULTIPLIER_BLIND'" | "'ENABLE_SAVING_ACTION_POINTS'" | "'CHARMED_MAX_CONSUMABLES_PER_TURN'" | "'MULTIPLIER_HEAL_ALLY_NEG'" | "'MULTIPLIER_ARMOR_ALLY_POS'" | "'MULTIPLIER_STATUS_FAILED'" | "'MULTIPLIER_DEATH_RESIST'" | "'MULTIPLIER_HOT_ALLY_POS'" | "'MULTIPLIER_CONTROL_SELF_POS'" | "'MULTIPLIER_LOW_ITEM_AMOUNT_MULTIPLIER'" | "'MULTIPLIER_TARGET_KNOCKED_DOWN'" | "'MULTIPLIER_SURFACE_REMOVE'" | "'MULTIPLIER_RESISTANCE'" | "'MULTIPLIER_DAMAGE_ALLY_POS'" | "'MULTIPLIER_BOOST_ENEMY_NEG'" | "'MULTIPLIER_ENDPOS_ENEMIES_NEARBY'" | "'MULTIPLIER_SCORE_ON_ALLY'" | "'MAX_SCORE_ON_NEUTRAL'" | "'MULTIPLIER_MAIN_ATTRIB'" | "'MULTIPLIER_MAGICAL_SULFUR'" | "'MULTIPLIER_HEAL_NEUTRAL_NEG'" | "'MULTIPLIER_ARMOR_NEUTRAL_POS'" | "'MULTIPLIER_EXPLOSION_DISTANCE_MIN'" | "'MULTIPLIER_INCAPACITATE'" | "'MULTIPLIER_SHACKLES_OF_PAIN'" | "'MULTIPLIER_CONTROL_ENEMY_POS'" | "'MULTIPLIER_TARGET_UNPREFERRED'" | "'MULTIPLIER_DISARMED'" | "'MULTIPLIER_SECONDARY_ATTRIB'" | "'MULTIPLIER_COMBO_SCORE_INTERACTION'" | "'MULTIPLIER_DAMAGE_NEUTRAL_POS'" | "'MULTIPLIER_DOT_ALLY_NEG'" | "'MULTIPLIER_BOOST_ALLY_NEG'" | "'MAX_HEAL_SELF_MULTIPLIER'" | "'MULTIPLIER_CRITICAL'" | "'MULTIPLIER_MAGICAL_SULFUR_CURRENTLY_DAM'" | "'AVENGE_ME_VITALITY_LEVEL'" | "'MULTIPLIER_DOT_ENEMY_NEG'" | "'MULTIPLIER_COOLDOWN_MULTIPLIER'" | "'DANGEROUS_ITEM_NEARBY'" | "'MULTIPLIER_GUARDIAN_ANGEL'" | "'MULTIPLIER_AP_COSTBOOST'" | "'MULTIPLIER_CONTROL_ALLY_POS'" | "'MULTIPLIER_SOURCE_COST_MULTIPLIER'" | "'MULTIPLIER_ENDPOS_STENCH'" | "'MULTIPLIER_KILL_ENEMY'" | "'MIN_TURNS_SCORE_EXISTING_STATUS'" | "'UNSTABLE_BOMB_RADIUS'" | "'MULTIPLIER_HEAL_SELF_POS'" | "'MULTIPLIER_BOOST_NEUTRAL_NEG'" | "'MULTIPLIER_TARGET_HOSTILE_COUNT_TWO_OR_'" | "'MULTIPLIER_BONUS_WEAPON_BOOST'" | "'MULTIPLIER_INVISIBLE'" | "'MULTIPLIER_DOT_SELF_POS'" | "'MULTIPLIER_DOT_NEUTRAL_NEG'" | "'MULTIPLIER_TARGET_MY_HOSTILE'" | "'MOVESKILL_ITEM_AP_DIFF_REQUIREMENT'" | "'MULTIPLIER_DAMAGE_ON_MOVE'" | "'MULTIPLIER_RESURRECT'" | "'MULTIPLIER_HOT_ALLY_NEG'" | "'MULTIPLIER_CONTROL_NEUTRAL_POS'" | "'MULTIPLIER_ENDPOS_NOT_IN_AIHINT'" | "'MULTIPLIER_DESTROY_INTERESTING_ITEM'" | "'MULTIPLIER_AP_RECOVERY'" | "'MULTIPLIER_PUDDLE_RADIUS'" | "'MULTIPLIER_HEAL_ENEMY_POS'" | "'MULTIPLIER_ARMOR_SELF_NEG'" | "'MAX_HEAL_MULTIPLIER'" | "'MULTIPLIER_KILL_ALLY_SUMMON'" | "'MULTIPLIER_GROUNDED'" | "'ENABLE_ACTIVE_DEFENSE_OFFENSIVE_USE'" | "'MULTIPLIER_HOT_ENEMY_NEG'" | "'MULTIPLIER_TARGET_AGGRO_MARKED'" | "'MULTIPLIER_KNOCKDOWN'" | "'SKILL_TELEPORT_MINIMUM_DISTANCE'" | "'MULTIPLIER_DAMAGE_SELF_NEG'" | "'MULTIPLIER_BOOST_SELF_POS'" | "'MULTIPLIER_INVISIBLE_MOVEMENT_COST_MULT'" | "'FALLBACK_WANTED_ENEMY_DISTANCE'" | "'MULTIPLIER_WINDWALKER'" | "'MULTIPLIER_DEFLECT_PROJECTILES'" | "'MULTIPLIER_HEAL_ALLY_POS'" | "'MULTIPLIER_HOT_SELF_POS'" | "'MULTIPLIER_ARMOR_ENEMY_NEG'" | "'MULTIPLIER_TARGET_HOSTILE_COUNT_ONE'" | "'MULTIPLIER_STATUS_REMOVE'" | "'MULTIPLIER_ACC_BOOST'" | "'MULTIPLIER_HOT_NEUTRAL_NEG'" | "'MULTIPLIER_TARGET_INCAPACITATED'" | "'MULTIPLIER_ENDPOS_NOT_IN_DANGEROUS_SURF'" | "'FALLBACK_ALLIES_NEARBY'" | "'MULTIPLIER_REMOVE_MAGIC_ARMOR'" | "'MULTIPLIER_SOURCE_POINT'" | "'MULTIPLIER_DAMAGE_ENEMY_NEG'" | "'MULTIPLIER_BOOST_ENEMY_POS'" | "'MULTIPLIER_SCORE_ON_NEUTRAL'" | "'MULTIPLIER_KILL_ALLY'" | "'MULTIPLIER_STATUS_CANCEL_SLEEPING'" | "'MULTIPLIER_REFLECT_DAMAGE'" | "'TARGET_WEAK_ALLY'" | "'MULTIPLIER_HEAL_NEUTRAL_POS'" | "'MULTIPLIER_ARMOR_ALLY_NEG'" | "'MULTIPLIER_STATUS_OVERWRITE'" | "'MULTIPLIER_SOURCE_MUTE'" | "'MULTIPLIER_POS_SECONDARY_SURFACE'" | "'MULTIPLIER_DOT_SELF_NEG'" | "'MULTIPLIER_CONTROL_SELF_NEG'" | "'MULTIPLIER_TARGET_PREFERRED'" | "'MULTIPLIER_ADD_ARMOR'" | "'MULTIPLIER_MOVEMENT_BOOST'"
--- @alias AiScoreReasonFlags string | "'ResurrectOutOfCombat'" | "'BreakInvisibilityForNoEnemies'" | "'MustStayInAiHint'" | "'TooFar'" | "'MoveSkillCannotExecute'" | "'TargetBlocked'" | "'RemoveMadnessSelf'" | "'BreakInvisibility'" | "'KillSelf'" | "'ResurrectByCharmedPlayer'" | "'ScoreTooLow'" | "'TooComplex'" | "'CannotTargetFrozen'" | "'NoMovement'" | "'StupidInvisibility'"
--- @alias CauseType string | "'Offhand'" | "'SurfaceMove'" | "'SurfaceCreate'" | "'None'" | "'SurfaceStatus'" | "'GM'" | "'StatusEnter'" | "'StatusTick'" | "'Attack'"
--- @alias CraftingStationType string | "'Misc4'" | "'Anvil'" | "'Wetstone'" | "'BoilingPot'" | "'Beehive'" | "'SpinningWheel'" | "'Cauldron'" | "'Misc1'" | "'Misc3'" | "'None'" | "'Oven'" | "'Misc2'" | "'Well'"
--- @alias ESurfaceFlag string | "'Poison'" | "'Irreplaceable'" | "'IrreplaceableCloud'" | "'Oil'" | "'Deepwater'" | "'CloudSurfaceBlock'" | "'HasItem'" | "'Frozen'" | "'Cursed'" | "'CloudElectrified'" | "'Deathfog'" | "'Lava'" | "'ShockwaveCloud'" | "'Source'" | "'HasInteractableObject'" | "'MovementBlock'" | "'ProjectileBlock'" | "'Water'" | "'FireCloud'" | "'HasCharacter'" | "'WaterCloud'" | "'Blessed'" | "'Occupied'" | "'BloodCloud'" | "'SurfaceExclude'" | "'PoisonCloud'" | "'ElectrifiedDecay'" | "'Fire'" | "'Sulfurium'" | "'SmokeCloud'" | "'ExplosionCloud'" | "'CloudBlessed'" | "'FrostCloud'" | "'CloudCursed'" | "'GroundSurfaceBlock'" | "'Blood'" | "'Purified'" | "'CloudPurified'" | "'Web'" | "'Electrified'" | "'SomeDecay'"
--- @alias ExtComponentType string | "'ClientCharacter'" | "'ClientItem'" | "'ServerCustomStatDefinition'" | "'Max'" | "'ServerCharacter'" | "'ServerItem'" | "'Combat'" | "'ServerProjectile'"
--- @alias GameActionType string | "'RainAction'" | "'StormAction'" | "'WallAction'" | "'TornadoAction'" | "'PathAction'" | "'GameObjectMoveAction'" | "'StatusDomeAction'"
--- @alias GameObjectTemplateFlags string | "'IsCustom'"
--- @alias HealEffect string | "'ResistDeath'" | "'Behavior'" | "'Unknown4'" | "'Lifesteal'" | "'NegativeDamage'" | "'Unknown9'" | "'HealSharing'" | "'Heal'" | "'Script'" | "'None'" | "'Sitting'" | "'Surface'" | "'HealSharingReflected'" | "'Necromantic'"
--- @alias IngredientTransformType string | "'Poison'" | "'Boost'" | "'Transform'" | "'Consume'" | "'None'"
--- @alias IngredientType string | "'Object'" | "'Property'" | "'Category'" | "'None'"
--- @alias InputType string | "'Hold'" | "'Unknown'" | "'Press'" | "'ValueChange'" | "'Repeat'" | "'AcceleratedRepeat'" | "'Release'"
--- @alias ItemDataRarity string | "'Common'" | "'Sentinel'" | "'Divine'" | "'Uncommon'" | "'Legendary'" | "'Epic'" | "'Rare'" | "'Unique'"
--- @alias LuaTypeId string | "'Object'" | "'Module'" | "'Array'" | "'Void'" | "'Enumeration'" | "'Map'" | "'Nullable'" | "'Unknown'" | "'Integer'" | "'Any'" | "'Float'" | "'Set'" | "'Boolean'" | "'Function'" | "'String'" | "'Tuple'"
--- @alias MultiEffectHandlerFlags string | "'FaceSource'" | "'KeepRot'" | "'FollowScale'" | "'EffectAttached'" | "'Detach'" | "'Beam'"
--- @alias NetMessage string | "'NETMSG_HOST_REFUSEPLAYER'" | "'NETMSG_CHARACTER_ASSIGN'" | "'NETMSG_ITEM_MOVE_TO_INVENTORY'" | "'NETMSG_TURNBASED_ROUND'" | "'NETMSG_SECRET_UPDATE'" | "'NETMSG_DIALOG_NODE_MESSAGE'" | "'NETMSG_GM_CHANGE_NAME'" | "'NETMSG_CHANGE_COMBAT_FORMATION'" | "'NETMSG_RUNECRAFT'" | "'NETMSG_SHOW_ERROR'" | "'NETMSG_HOST_LEFT'" | "'NETMSG_CHARACTER_SET_STORY_NAME'" | "'NETMSG_CHARACTER_BOOST'" | "'NETMSG_PROJECTILE_EXPLOSION'" | "'NETMSG_SKILL_LEARN'" | "'NETMSG_MYSTERY_STATE'" | "'NETMSG_GM_SYNC_VIGNETTES'" | "'NETMSG_GM_REMOVE_STATUS'" | "'NETMSG_UNLOCK_ITEM'" | "'NETMSG_LOBBY_CHARACTER_SELECT'" | "'NETMSG_PLAYER_JOINED'" | "'NETMSG_CHARACTER_ITEM_USED'" | "'NETMSG_SHROUD_UPDATE'" | "'NETMSG_FORCE_SHEATH'" | "'NETMSG_OPEN_WAYPOINT_UI_MESSAGE'" | "'NETMSG_GM_ITEM_CHANGE'" | "'NETMSG_GM_UI_OPEN_STICKY'" | "'NETMSG_CAMERA_ACTIVATE'" | "'NETMSG_LOBBY_COMMAND'" | "'NETMSG_CHARACTER_DESTROY'" | "'NETMSG_CHARACTER_SELECTEDSKILLSET'" | "'NETMSG_ITEM_ACTION'" | "'NETMSG_ITEM_CONFIRMATION'" | "'NETMSG_ALIGNMENT_CLEAR'" | "'NETMSG_DIALOG_HISTORY_MESSAGE'" | "'NETMSG_GM_REMOVE_ROLL'" | "'NETMSG_GM_SET_INTERESTED_CHARACTER'" | "'NETMSG_MODULE_LOAD'" | "'NETMSG_JOURNALDIALOGLOG_UPDATE'" | "'NETMSG_PARTYCREATEGROUP'" | "'NETMSG_CHARACTER_COMPANION_CUSTOMIZATION'" | "'NETMSG_SURFACE_META'" | "'NETMSG_CHARACTER_UPGRADE'" | "'NETMSG_EGG_DESTROY'" | "'NETMSG_TURNBASED_SETTEAM'" | "'NETMSG_TURNBASED_FLEECOMBATRESULT'" | "'NETMSG_JOURNAL_RESET'" | "'NETMSG_GAMEOVER'" | "'NETMSG_GM_SYNC_ASSETS'" | "'NETMSG_GM_SET_START_POINT'" | "'NETMSG_LOAD_START'" | "'NETMSG_ACHIEVEMENT_UNLOCKED_MESSAGE'" | "'NETMSG_SET_CHARACTER_ARCHETYPE'" | "'NETMSG_TRIGGER_UPDATE'" | "'NETMSG_CHARACTER_DIALOG'" | "'NETMSG_COMBAT_TURN_TIMER'" | "'NETMSG_SKILL_CREATE'" | "'NETMSG_CLOSE_CUSTOM_BOOK_UI_MESSAGE'" | "'NETMSG_JOURNALRECIPE_UPDATE'" | "'NETMSG_QUEST_TRACK'" | "'NETMSG_DIALOG_ANSWER_HIGHLIGHT_MESSAGE'" | "'NETMSG_GM_SPAWN'" | "'NETMSG_GM_MAKE_TRADER'" | "'NETMSG_GM_SET_REPUTATION'" | "'NETMSG_UNLOCK_WAYPOINT'" | "'NETMSG_CUSTOM_STATS_DEFINITION_UPDATE'" | "'NETMSG_SCRIPT_EXTENDER'" | "'NETMSG_CLIENT_LEFT'" | "'NETMSG_CHARACTER_ACTIVATE'" | "'NETMSG_PARTYORDER'" | "'NETMSG_INVENTORY_DESTROY'" | "'NETMSG_EFFECT_CREATE'" | "'NETMSG_NOTIFICATION'" | "'NETMSG_GM_TOGGLE_VIGNETTE'" | "'NETMSG_GM_HEAL'" | "'NETMSG_GM_MAKE_FOLLOWER'" | "'NETMSG_SAVEGAME_LOAD_FAIL'" | "'NETMSG_MUSIC_EVENT'" | "'NETMSG_CHARACTER_CUSTOMIZATION'" | "'NETMSG_ITEM_DEACTIVATE'" | "'NETMSG_NET_ENTITY_DESTROY'" | "'NETMSG_CHARACTER_ERROR'" | "'NETMSG_CLOSED_MESSAGE_BOX_MESSAGE'" | "'NETMSG_GM_TOGGLE_PAUSE'" | "'NETMSG_GM_ROLL'" | "'NETMSG_GM_REQUEST_CAMPAIGN_DATA'" | "'NETMSG_GAMETIME_SYNC'" | "'NETMSG_UPDATE_ITEM_TAGS'" | "'NETMSG_CUSTOM_STATS_UPDATE'" | "'NETMSG_VOICEDATA'" | "'NETMSG_UPDATE_COMBAT_GROUP_INFO'" | "'NETMSG_ITEM_MOVE_UUID'" | "'NETMSG_SCREEN_FADE'" | "'NETMSG_PARTY_CONSUMED_ITEMS'" | "'NETMSG_GM_TELEPORT'" | "'NETMSG_GM_HOST'" | "'NETMSG_SAVEGAMEHANDSHAKE'" | "'NETMSG_SESSION_LOADED'" | "'NETMSG_DIPLOMACY'" | "'NETMSG_CHARACTER_POSITION'" | "'NETMSG_CHARACTER_ACTION'" | "'NETMSG_CHARACTER_STATUS_LIFETIME'" | "'NETMSG_INVENTORY_VIEW_DESTROY'" | "'NETMSG_TURNBASED_ORDER'" | "'NETMSG_TROPHY_UPDATE'" | "'NETMSG_GM_ADD_EXPERIENCE'" | "'NETMSG_GM_ASSETS_PENDING_SYNCS_INFO'" | "'NETMSG_GM_DUPLICATE'" | "'NETMSG_CHAT'" | "'NETMSG_SERVER_COMMAND'" | "'NETMSG_OPEN_CRAFT_UI_MESSAGE'" | "'NETMSG_STORY_VERSION'" | "'NETMSG_CLIENT_CONNECT'" | "'NETMSG_CHARACTER_TELEPORT'" | "'NETMSG_PARTY_CREATE'" | "'NETMSG_INVENTORY_VIEW_UPDATE_PARENTS'" | "'NETMSG_SKILL_UNLEARN'" | "'NETMSG_GAMECONTROL_UPDATE_C2S'" | "'NETMSG_MYSTERY_UPDATE'" | "'NETMSG_GM_CREATE_ITEM'" | "'NETMSG_GM_SET_ATMOSPHERE'" | "'NETMSG_SAVEGAME'" | "'NETMSG_CHARACTER_CHANGE_OWNERSHIP'" | "'NETMSG_TELEPORT_PYRAMID'" | "'NETMSG_CLIENT_GAME_SETTINGS'" | "'NETMSG_SECRET_REGION_UNLOCK'" | "'NETMSG_ITEM_CREATE'" | "'NETMSG_PLAYSOUND'" | "'NETMSG_SHOW_ENTER_REGION_UI_MESSAGE'" | "'NETMSG_PARTY_SPLIT_NOTIFICATION'" | "'NETMSG_GM_DRAW_SURFACE'" | "'NETMSG_CAMERA_ROTATE'" | "'NETMSG_LEVEL_SWAP_COMPLETE'" | "'NETMSG_LOBBY_STARTGAME'" | "'NETMSG_PAUSE'" | "'NETMSG_CUSTOM_STATS_DEFINITION_REMOVE'" | "'NETMSG_CHARACTER_STEERING'" | "'NETMSG_ITEM_STATUS'" | "'NETMSG_INVENTORY_ITEM_UPDATE'" | "'NETMSG_CACHETEMPLATE'" | "'NETMSG_GM_TICK_ROLLS'" | "'NETMSG_GM_TRAVEL_TO_DESTINATION'" | "'NETMSG_MODULE_LOADED'" | "'NETMSG_TELEPORT_WAYPOINT'" | "'NETMSG_ARENA_RESULTS'" | "'NETMSG_UNPAUSE'" | "'NETMSG_GAMEACTION'" | "'NETMSG_CHARACTER_OFFSTAGE'" | "'NETMSG_TURNBASED_START'" | "'NETMSG_ALIGNMENT_RELATION'" | "'NETMSG_QUEST_UPDATE'" | "'NETMSG_GM_LOAD_CAMPAIGN'" | "'NETMSG_GM_CHANGE_SCENE_NAME'" | "'NETMSG_LEVEL_SWAP_READY'" | "'NETMSG_PING_BEACON'" | "'NETMSG_HACK_TELL_BUILDNAME'" | "'NETMSG_HOST_WELCOME'" | "'NETMSG_CHARACTER_USE_AP'" | "'NETMSG_ITEM_MOVE_TO_WORLD'" | "'NETMSG_SKILL_DESTROY'" | "'NETMSG_QUEST_POSTPONE'" | "'NETMSG_DIALOG_STATE_MESSAGE'" | "'NETMSG_GM_GIVE_REWARD'" | "'NETMSG_CHARACTERCREATION_READY'" | "'NETMSG_LOCK_WAYPOINT'" | "'NETMSG_PLAYER_CONNECT'" | "'NETMSG_CHARACTER_ACTION_REQUEST_RESULT'" | "'NETMSG_CHARACTER_CONTROL'" | "'NETMSG_PARTYUPDATE'" | "'NETMSG_PROJECTILE_CREATE'" | "'NETMSG_EFFECT_FORGET'" | "'NETMSG_FLAG_UPDATE'" | "'NETMSG_GM_SYNC_OVERVIEW_MAPS'" | "'NETMSG_GM_DEACTIVATE'" | "'NETMSG_LOBBY_DATAUPDATE'" | "'NETMSG_LOBBY_SPECTATORUPDATE'" | "'NETMSG_CHARACTER_LOOT_CORPSE'" | "'NETMSG_ITEM_DESTINATION'" | "'NETMSG_INVENTORY_VIEW_UPDATE_ITEMS'" | "'NETMSG_ALIGNMENT_CREATE'" | "'NETMSG_OPEN_MESSAGE_BOX_MESSAGE'" | "'NETMSG_GM_REQUEST_ROLL'" | "'NETMSG_GM_EDIT_CHARACTER'" | "'NETMSG_PARTY_NPC_DATA'" | "'NETMSG_CHARACTERCREATION_NOT_READY'" | "'NETMSG_AITEST_UPDATE'" | "'NETMSG_PLAYER_DISCONNECT'" | "'NETMSG_SKIPMOVIE_RESULT'" | "'NETMSG_ITEM_STATUS_LIFETIME'" | "'NETMSG_INVENTORY_CREATE'" | "'NETMSG_SCREEN_FADE_DONE'" | "'NETMSG_OPEN_CUSTOM_BOOK_UI_MESSAGE'" | "'NETMSG_DIALOG_ANSWER_MESSAGE'" | "'NETMSG_GM_CAMPAIGN_SAVE'" | "'NETMSG_LEVEL_LOAD'" | "'NETMSG_DIFFICULTY_CHANGED'" | "'NETMSG_TRIGGER_CREATE'" | "'NETMSG_CUSTOM_STATS_DEFINITION_CREATE'" | "'NETMSG_CHARACTER_STATUS'" | "'NETMSG_CHARACTER_SKILLBAR'" | "'NETMSG_TURNBASED_SUMMONS'" | "'NETMSG_PEER_ACTIVATE'" | "'NETMSG_MARKER_UI_CREATE'" | "'NETMSG_GM_REORDER_ELEMENTS'" | "'NETMSG_GM_ITEM_USE'" | "'NETMSG_ITEM_ENGRAVE'" | "'NETMSG_UPDATE_CHARACTER_TAGS'" | "'NETMSG_DLC_UPDATE'" | "'NETMSG_CLIENT_ACCEPT'" | "'NETMSG_CHARACTER_IN_DIALOG'" | "'NETMSG_PARTY_DESTROY'" | "'NETMSG_SKILL_ACTIVATE'" | "'NETMSG_QUEST_CATEGORY_UPDATE'" | "'NETMSG_PARTYFORMATION'" | "'NETMSG_GM_EDIT_ITEM'" | "'NETMSG_GM_INVENTORY_OPERATION'" | "'NETMSG_DIALOG_LISTEN'" | "'NETMSG_CHARACTER_CONFIRMATION'" | "'NETMSG_ITEM_DESTROY'" | "'NETMSG_ITEM_MOVED_INFORM'" | "'NETMSG_PLAYMOVIE'" | "'NETMSG_GM_TOGGLE_OVERVIEWMAP'" | "'NETMSG_GM_DAMAGE'" | "'NETMSG_CAMERA_TARGET'" | "'NETMSG_SHOW_TUTORIAL_MESSAGE'" | "'NETMSG_LOBBY_SURRENDER'" | "'NETMSG_CHARACTER_STATS_UPDATE'" | "'NETMSG_ITEM_TRANSFORM'" | "'NETMSG_NET_ENTITY_CREATE'" | "'NETMSG_OVERHEADTEXT'" | "'NETMSG_GM_CHANGE_LEVEL'" | "'NETMSG_GM_CONFIGURE_CAMPAIGN'" | "'NETMSG_MODULES_DOWNLOAD'" | "'NETMSG_CAMERA_SPLINE'" | "'NETMSG_CUSTOM_STATS_CREATE'" | "'NETMSG_CHARACTER_CREATE'" | "'NETMSG_COMBAT_COMPONENT_SYNC'" | "'NETMSG_INVENTORY_CREATE_AND_OPEN'" | "'NETMSG_TURNBASED_STOP'" | "'NETMSG_QUEST_STATE'" | "'NETMSG_REGISTER_WAYPOINT'" | "'NETMSG_GM_POSSESS'" | "'NETMSG_ATMOSPHERE_OVERRIDE'" | "'NETMSG_CHARACTER_ANIMATION_SET_UPDATE'" | "'NETMSG_LEVEL_START'" | "'NETMSG_GIVE_REWARD'" | "'NETMSG_HOST_REFUSE'" | "'NETMSG_CHARACTER_DEACTIVATE'" | "'NETMSG_CHARACTER_AOO'" | "'NETMSG_INVENTORY_VIEW_CREATE'" | "'NETMSG_SKILL_UPDATE'" | "'NETMSG_UI_QUESTSELECTED'" | "'NETMSG_GM_REMOVE_EXPORTED'" | "'NETMSG_GM_SET_STATUS'" | "'NETMSG_SERVER_NOTIFICATION'" | "'NETMSG_ACHIEVEMENT_PROGRESS_MESSAGE'" | "'NETMSG_CRAFT_RESULT'" | "'NETMSG_PLAYER_ACCEPT'" | "'NETMSG_CHARACTER_TRANSFORM'" | "'NETMSG_PARTYUSER'" | "'NETMSG_EFFECT_DESTROY'" | "'NETMSG_GAMECONTROL_UPDATE_S2C'" | "'NETMSG_DIALOG_ACTORLEAVES_MESSAGE'" | "'NETMSG_GM_DELETE'" | "'NETMSG_GM_CLEAR_STATUSES'" | "'NETMSG_TRADE_ACTION'" | "'NETMSG_LOBBY_USERUPDATE'" | "'NETMSG_LOAD_GAME_WITH_ADDONS'" | "'NETMSG_MULTIPLE_TARGET_OPERATION'" | "'NETMSG_SHROUD_FRUSTUM_UPDATE'" | "'NETMSG_ITEM_UPDATE'" | "'NETMSG_ALIGNMENT_SET'" | "'NETMSG_PARTY_UNLOCKED_RECIPE'" | "'NETMSG_GM_PASS_ROLL'" | "'NETMSG_REQUESTAUTOSAVE'" | "'NETMSG_LEVEL_INSTANTIATE_SWAP'" | "'NETMSG_TELEPORT_ACK'" | "'NETMSG_SURFACE_CREATE'" | "'NETMSG_CHARACTER_POSITION_SYNC'" | "'NETMSG_INVENTORY_VIEW_SORT'" | "'NETMSG_EGG_CREATE'" | "'NETMSG_CLOSE_UI_MESSAGE'" | "'NETMSG_GM_VIGNETTE_ANSWER'" | "'NETMSG_GM_SYNC_SCENES'" | "'NETMSG_LEVEL_LOADED'" | "'NETMSG_DISCOVERED_PORTALS'" | "'NETMSG_TRIGGER_DESTROY'" | "'NETMSG_CHARACTER_UPDATE'" | "'NETMSG_CHARACTER_PICKPOCKET'" | "'NETMSG_PEER_DEACTIVATE'" | "'NETMSG_GAMECONTROL_PRICETAG'" | "'NETMSG_MARKER_UI_UPDATE'" | "'NETMSG_GM_TOGGLE_PEACE'" | "'NETMSG_GM_SOUND_PLAYBACK'" | "'NETMSG_STORY_ELEMENT_UI'" | "'NETMSG_GM_JOURNAL_UPDATE'" | "'NETMSG_MUTATORS_ENABLED'" | "'NETMSG_CLIENT_JOINED'" | "'NETMSG_CHARACTER_CORPSE_LOOTABLE'" | "'NETMSG_PARTYGROUP'" | "'NETMSG_ITEM_USE_REMOTELY'" | "'NETMSG_SKILL_REMOVED'" | "'NETMSG_STOP_FOLLOW'" | "'NETMSG_PARTY_MERGE_NOTIFICATION'" | "'NETMSG_GM_SYNC_NOTES'" | "'NETMSG_GM_REQUEST_CHARACTERS_REROLL'" | "'NETMSG_CHARACTERCREATION_DONE'" | "'NETMSG_MUSIC_STATE'" | "'NETMSG_CHARACTER_ACTION_DATA'" | "'NETMSG_ITEM_ACTIVATE'" | "'NETMSG_INVENTORY_LOCKSTATE_SYNC'" | "'NETMSG_PLAY_HUD_SOUND'" | "'NETMSG_GM_EXPORT'" | "'NETMSG_GM_STOP_TRAVELING'" | "'NETMSG_CAMERA_MODE'" | "'NETMSG_NOTIFY_COMBINE_FAILED_MESSAGE'" | "'NETMSG_REALTIME_MULTIPLAY'" | "'NETMSG_LOBBY_RETURN'" | "'NETMSG_PLAYER_LEFT'" | "'NETMSG_CHARACTER_LOCK_ABILITY'" | "'NETMSG_ITEM_OFFSTAGE'" | "'NETMSG_COMBATLOG'" | "'NETMSG_COMBATLOGITEMINTERACTION'" | "'NETMSG_OPEN_KICKSTARTER_BOOK_UI_MESSAGE'" | "'NETMSG_DIALOG_ACTORJOINS_MESSAGE'" | "'NETMSG_GM_POSITION_SYNC'" | "'NETMSG_GM_CHANGE_SCENE_PATH'" | "'NETMSG_SESSION_LOAD'" | "'NETMSG_READYCHECK'" | "'NETMSG_LOAD_GAME_WITH_ADDONS_FAIL'"
--- @alias ObjectHandleType string | "'MeshProxy'" | "'ServerTeleportTrigger'" | "'IndexBuffer'" | "'SRV'" | "'ContainerComponent'" | "'Shader'" | "'VertexBuffer'" | "'TextureRemoveData'" | "'Text3D'" | "'ClientOverviewMap'" | "'ServerCustomStatDefinitionComponent'" | "'VertexFormat'" | "'ClientAtmosphereTrigger'" | "'SamplerState'" | "'ServerEocPointTrigger'" | "'BlendState'" | "'ServerAIHintAreaTrigger'" | "'ServerSoundVolumeTrigger'" | "'DepthState'" | "'ClientInventoryView'" | "'RasterizerState'" | "'UIObject'" | "'ClientRegionTrigger'" | "'Constant'" | "'TerrainObject'" | "'ClientCustomStatDefinitionComponent'" | "'ServerInventoryView'" | "'ConstantBuffer'" | "'Unknown'" | "'GrannyFile'" | "'ServerEventTrigger'" | "'CompiledShader'" | "'GMJournalNode'" | "'ClientProjectile'" | "'ClientSecretRegionTrigger'" | "'StructuredBuffer'" | "'TexturedFont'" | "'ClientEgg'" | "'ClientPointTrigger'" | "'Effect'" | "'ClientCharacter'" | "'ClientAiSeederTrigger'" | "'ClientItem'" | "'ClientPointSoundTriggerDummy'" | "'ServerEocAreaTrigger'" | "'SoundVolumeTrigger'" | "'ClientScenery'" | "'ServerStatsAreaTrigger'" | "'ClientWallBase'" | "'ClientAlignmentData'" | "'ClientInventory'" | "'ClientPointSoundTrigger'" | "'ServerMusicVolumeTrigger'" | "'ClientAlignment'" | "'ServerOverviewMap'" | "'Texture'" | "'ClientSkill'" | "'ServerCrimeAreaTrigger'" | "'Visual'" | "'Scene'" | "'ClientWallConstruction'" | "'ClientStatus'" | "'ServerSecretRegionTrigger'" | "'Dummy'" | "'ClientParty'" | "'ClientCullTrigger'" | "'ClientVignette'" | "'ClientDummyGameObject'" | "'Light'" | "'ClientNote'" | "'ServerStartTrigger'" | "'ServerExplorationTrigger'" | "'CustomStatsComponent'" | "'ClientSurface'" | "'ServerRegionTrigger'" | "'Reference'" | "'ContainerElementComponent'" | "'ClientGameAction'" | "'ServerEgg'" | "'ClientSpectatorTrigger'" | "'ServerCharacter'" | "'ServerItem'" | "'ServerSurfaceAction'" | "'ClientSoundVolumeTrigger'" | "'ServerInventory'" | "'ServerAtmosphereTrigger'" | "'ClientWallIntersection'" | "'ServerParty'" | "'Decal'" | "'Trigger'" | "'ClientCameraLockTrigger'" | "'ServerVignette'" | "'CombatComponent'" | "'ServerProjectile'" | "'ServerNote'" | "'ServerCrimeRegionTrigger'"
--- @alias PathRootType string | "'Root'" | "'MyDocuments'" | "'GameStorage'" | "'Public'" | "'Data'"
--- @alias PlayerUpgradeAttribute string | "'Finesse'" | "'Strength'" | "'Intelligence'" | "'Constitution'" | "'Wits'" | "'Memory'"
--- @alias RecipeCategory string | "'Runes'" | "'Common'" | "'Arrows'" | "'Grimoire'" | "'Armour'" | "'Potions'" | "'Weapons'" | "'Grenades'" | "'Objects'" | "'Food'"
--- @alias ResourceType string | "'Animation'" | "'AnimationBlueprint'" | "'MeshProxy'" | "'AnimationSet'" | "'Material'" | "'Sound'" | "'VisualSet'" | "'Atmosphere'" | "'Physics'" | "'Effect'" | "'Texture'" | "'Script'" | "'Visual'" | "'MaterialSet'"
--- @alias ScriptCheckType string | "'Variable'" | "'Operator'"
--- @alias ScriptOperatorType string | "'Or'" | "'And'" | "'None'" | "'Not'"
--- @alias ShroudType string | "'Shroud'" | "'Sight'" | "'Sneak'" | "'RegionMask'"
--- @alias SkillType string | "'Rain'" | "'Dome'" | "'Path'" | "'Zone'" | "'Wall'" | "'ProjectileStrike'" | "'Quake'" | "'SkillHeal'" | "'Jump'" | "'Shout'" | "'Tornado'" | "'Rush'" | "'MultiStrike'" | "'Teleportation'" | "'Target'" | "'Summon'" | "'Projectile'" | "'Storm'"
--- @alias StatAttributeFlags string | "'DrunkImmunity'" | "'InvisibilityImmunity'" | "'FreezeContact'" | "'KnockdownImmunity'" | "'BurnContact'" | "'InfectiousDiseasedImmunity'" | "'StunContact'" | "'SuffocatingImmunity'" | "'PoisonContact'" | "'LootableWhenEquipped'" | "'ChillContact'" | "'Unbreakable'" | "'LoseDurabilityOnCharacterHit'" | "'PetrifiedImmunity'" | "'Unrepairable'" | "'Unstorable'" | "'ClairvoyantImmunity'" | "'Grounded'" | "'HastedImmunity'" | "'BleedingImmunity'" | "'TauntedImmunity'" | "'AcidImmunity'" | "'RegeneratingImmunity'" | "'EnragedImmunity'" | "'EntangledContact'" | "'BlessedImmunity'" | "'IgnoreClouds'" | "'SlippingImmunity'" | "'MadnessImmunity'" | "'FreezeImmunity'" | "'ProtectFromSummon'" | "'ChickenImmunity'" | "'BurnImmunity'" | "'Floating'" | "'IgnoreCursedOil'" | "'StunImmunity'" | "'ShockedImmunity'" | "'PoisonImmunity'" | "'CrippledImmunity'" | "'WebImmunity'" | "'PickpocketableWhenEquipped'" | "'CharmImmunity'" | "'DisarmedImmunity'" | "'MagicalSulfur'" | "'FearImmunity'" | "'ShacklesOfPainImmunity'" | "'ThrownImmunity'" | "'MuteImmunity'" | "'ChilledImmunity'" | "'WarmImmunity'" | "'SleepingImmunity'" | "'WetImmunity'" | "'DeflectProjectiles'" | "'BlindImmunity'" | "'CursedImmunity'" | "'WeakImmunity'" | "'DiseasedImmunity'" | "'Torch'" | "'Arrow'" | "'SlowedImmunity'" | "'DecayingImmunity'"
--- @alias StatusHealType string | "'PhysicalArmor'" | "'Vitality'" | "'MagicArmor'" | "'AllArmor'" | "'None'" | "'Source'" | "'All'"
--- @alias StatusType string | "'LINGERING_WOUNDS'" | "'AOO'" | "'INVISIBLE'" | "'ROTATE'" | "'INFECTIOUS_DISEASED'" | "'ENCUMBERED'" | "'FEAR'" | "'MATERIAL'" | "'MUTED'" | "'IDENTIFY'" | "'LEADERSHIP'" | "'FLANKED'" | "'ADRENALINE'" | "'LYING'" | "'WIND_WALKER'" | "'DARK_AVENGER'" | "'SOURCE_MUTED'" | "'HEAL_SHARING_CASTER'" | "'HEAL'" | "'KNOCKED_DOWN'" | "'CLEAN'" | "'SUMMONING'" | "'FLOATING'" | "'STORY_FROZEN'" | "'UNLOCK'" | "'EXTRA_TURN'" | "'SHACKLES_OF_PAIN'" | "'ACTIVE_DEFENSE'" | "'SNEAKING'" | "'CHALLENGE'" | "'SITTING'" | "'DECAYING_TOUCH'" | "'DAMAGE_ON_MOVE'" | "'SPARK'" | "'THROWN'" | "'UNHEALABLE'" | "'SPIRIT'" | "'DEMONIC_BARGAIN'" | "'DYING'" | "'SMELLY'" | "'CHANNELING'" | "'GUARDIAN_ANGEL'" | "'SPIRIT_VISION'" | "'COMBAT'" | "'UNSHEATHED'" | "'FORCE_MOVE'" | "'REMORSE'" | "'CLIMBING'" | "'DISARMED'" | "'INCAPACITATED'" | "'PLAY_DEAD'" | "'STANCE'" | "'SHACKLES_OF_PAIN_CASTER'" | "'INSURFACE'" | "'CONSTRAINED'" | "'HEALING'" | "'INFUSED'" | "'HIT'" | "'BLIND'" | "'DEACTIVATED'" | "'EFFECT'" | "'TUTORIAL_BED'" | "'TELEPORT_FALLING'" | "'CONSUME'" | "'OVERPOWER'" | "'EXPLODE'" | "'COMBUSTION'" | "'REPAIR'" | "'POLYMORPHED'" | "'BOOST'" | "'HEAL_SHARING'" | "'CHARMED'" | "'DRAIN'" | "'DAMAGE'"
--- @alias SurfaceActionType string | "'CreateSurfaceAction'" | "'ChangeSurfaceOnPathAction'" | "'RectangleSurfaceAction'" | "'CreatePuddleAction'" | "'SwapSurfaceAction'" | "'PolygonSurfaceAction'" | "'ExtinguishFireAction'" | "'ZoneAction'" | "'TransformSurfaceAction'"
--- @alias SurfaceLayer string | "'Cloud'" | "'Ground'" | "'None'"
--- @alias SurfaceTransformActionType string | "'Curse'" | "'Shatter'" | "'Purify'" | "'Oilify'" | "'Bless'" | "'Electrify'" | "'Condense'" | "'None'" | "'Vaporize'" | "'Freeze'" | "'Bloodify'" | "'Contaminate'" | "'Ignite'" | "'Melt'"
--- @alias SurfaceType string | "'BloodFrozen'" | "'Poison'" | "'BloodElectrified'" | "'BloodBlessed'" | "'BloodCloudElectrifiedCursed'" | "'BloodCursed'" | "'Custom'" | "'FireCloudPurified'" | "'BloodPurified'" | "'BloodCloudCursed'" | "'Sentinel'" | "'PoisonBlessed'" | "'SmokeCloudPurified'" | "'WaterElectrifiedCursed'" | "'PoisonCursed'" | "'Oil'" | "'Deepwater'" | "'BloodFrozenCursed'" | "'PoisonPurified'" | "'OilBlessed'" | "'WaterCloudPurified'" | "'OilCursed'" | "'PoisonCloudPurified'" | "'WaterElectrified'" | "'BloodElectrifiedPurified'" | "'OilPurified'" | "'BloodElectrifiedBlessed'" | "'WebBlessed'" | "'WebCursed'" | "'WaterCloudElectrified'" | "'WebPurified'" | "'WaterCloudElectrifiedCursed'" | "'BloodCloudPurified'" | "'CustomBlessed'" | "'WaterFrozenCursed'" | "'CustomCursed'" | "'BloodFrozenPurified'" | "'CustomPurified'" | "'BloodCloudElectrifiedBlessed'" | "'FireCloudCursed'" | "'BloodCloudElectrified'" | "'SmokeCloudBlessed'" | "'Deathfog'" | "'WaterElectrifiedBlessed'" | "'Lava'" | "'BloodCloudElectrifiedPurified'" | "'ShockwaveCloud'" | "'BloodFrozenBlessed'" | "'Source'" | "'WaterCloudBlessed'" | "'PoisonCloudBlessed'" | "'Water'" | "'FireCloud'" | "'WaterElectrifiedPurified'" | "'WaterFrozenPurified'" | "'WaterCloud'" | "'FireBlessed'" | "'FireCloudBlessed'" | "'BloodCloud'" | "'FireCursed'" | "'BloodCloudBlessed'" | "'PoisonCloud'" | "'Fire'" | "'FirePurified'" | "'WaterCloudElectrifiedBlessed'" | "'SmokeCloud'" | "'SmokeCloudCursed'" | "'WaterFrozen'" | "'WaterFrozenBlessed'" | "'ExplosionCloud'" | "'WaterBlessed'" | "'BloodElectrifiedCursed'" | "'FrostCloud'" | "'WaterCursed'" | "'Blood'" | "'WaterCloudCursed'" | "'WaterCloudElectrifiedPurified'" | "'WaterPurified'" | "'Web'" | "'PoisonCloudCursed'"
--- @alias TemplateType string | "'RootTemplate'" | "'LocalTemplate'" | "'GlobalCacheTemplate'" | "'GlobalTemplate'" | "'LevelCacheTemplate'"
--- @alias UIObjectFlags string | "'OF_PreventCameraMove'" | "'OF_Loaded'" | "'OF_Visible'" | "'OF_Activated'" | "'OF_PlayerInput1'" | "'OF_KeepInScreen'" | "'OF_PlayerTextInput4'" | "'OF_PlayerInput2'" | "'OF_PauseRequest'" | "'OF_PlayerInput3'" | "'OF_SortOnAdd'" | "'OF_PlayerInput4'" | "'OF_FullScreen'" | "'OF_PlayerModal1'" | "'OF_PlayerTextInput1'" | "'OF_PlayerModal2'" | "'OF_PlayerModal3'" | "'OF_PlayerModal4'" | "'OF_RequestDelete'" | "'OF_DontHideOnDelete'" | "'OF_Load'" | "'OF_PlayerTextInput2'" | "'OF_KeepCustomInScreen'" | "'OF_PrecacheUIData'" | "'OF_PlayerTextInput3'" | "'OF_DeleteOnChildDestroy'"
--- @alias VisualAttachmentFlags string | "'UseLocalTransform'" | "'Weapon'" | "'Horns'" | "'InheritAnimations'" | "'KeepRot'" | "'KeepScale'" | "'DoNotUpdate'" | "'Overhead'" | "'DestroyWithParent'" | "'Wings'" | "'WeaponFX'" | "'ParticleSystem'" | "'BonusWeaponFX'" | "'WeaponOverlayFX'" | "'ExcludeFromBounds'" | "'Armor'"
--- @alias VisualComponentFlags string | "'VisualSetLoaded'" | "'ForceUseAnimationBlueprint'"
--- @alias VisualFlags string | "'CastShadow'" | "'IsShadowProxy'" | "'ReceiveDecal'" | "'Reflecting'" | "'AllowReceiveDecalWhenAnimated'"
--- @alias VisualTemplateColorIndex string | "'Hair'" | "'Cloth'" | "'Skin'"
--- @alias VisualTemplateVisualIndex string | "'HairHelmet'" | "'Trousers'" | "'Visual8'" | "'Head'" | "'Visual9'" | "'Beard'" | "'Torso'" | "'Boots'" | "'Arms'"
--- @alias EclCharacterFlags string | "'Invisible_M'" | "'NoSound'" | "'PartyFollower'" | "'InCombat'" | "'CharCreationInProgress'" | "'VisualsUpdated'" | "'Invisible_M2'" | "'IsRunning'" | "'WeaponSheathed'" | "'DisableSneaking'" | "'NoCover'" | "'NoRotate'" | "'IsPlayer'" | "'UseOverlayMaterials'" | "'CanShootThrough'" | "'CharacterCreationFinished'" | "'Floating'" | "'WalkThrough'" | "'Global'" | "'SpotSneakers'" | "'Dead'" | "'HasCustomVisualIndices'" | "'Activated'" | "'IsHuge'" | "'InParty'" | "'OffStage'" | "'Multiplayer'" | "'HasOwner'" | "'StoryNPC'" | "'Summon'" | "'InDialog'" | "'CannotMove'"
--- @alias EclEntityComponentIndex string | "'AnimationBlueprint'" | "'CameraLockTrigger'" | "'Sound'" | "'CustomStats'" | "'Character'" | "'SpectatorTrigger'" | "'GMJournalNode'" | "'GameMaster'" | "'Effect'" | "'SecretRegionTrigger'" | "'SoundVolumeTrigger'" | "'LightProbe'" | "'ParentEntity'" | "'AtmosphereTrigger'" | "'PointTrigger'" | "'ContainerElement'" | "'Visual'" | "'OverviewMap'" | "'Scenery'" | "'CullTrigger'" | "'Vignette'" | "'RegionTrigger'" | "'PointSoundTrigger'" | "'AiSeederTrigger'" | "'Spline'" | "'Light'" | "'Egg'" | "'PingBeacon'" | "'Container'" | "'PublishingRequest'" | "'Note'" | "'CustomStatDefinition'" | "'Item'" | "'EquipmentVisualsComponent'" | "'Decal'" | "'Combat'" | "'Net'" | "'Projectile'" | "'PointSoundTriggerDummy'"
--- @alias EclEntitySystemIndex string | "'VisualSystem'" | "'AtmosphereManager'" | "'LightManager'" | "'DecalManager'" | "'SoundSystem'" | "'CustomStats'" | "'PublishingSystem'" | "'GrannySystem'" | "'GameActionManager'" | "'GameMasterManager'" | "'TurnManager'" | "'PingBeaconManager'" | "'AnimationBlueprintSystem'" | "'SceneryManager'" | "'TriggerManager'" | "'GMJournalNode'" | "'ItemManager'" | "'GameMaster'" | "'EggManager'" | "'SeeThroughManager'" | "'GameMasterCampaignManager'" | "'PhysXScene'" | "'SurfaceManager'" | "'LEDSystem'" | "'PickingHelperManager'" | "'GMJournalSystem'" | "'CharacterManager'" | "'EquipmentVisualsSystem'" | "'ContainerElement'" | "'CameraSplineSystem'" | "'MusicManager'" | "'ContainerElementComponent'" | "'CustomStatsSystem'" | "'ContainerComponentSystem'" | "'Container'" | "'LightProbeManager'" | "'EncounterManager'" | "'ProjectileManager'"
--- @alias EclGameState string | "'Paused'" | "'BuildStory'" | "'LoadLoca'" | "'Idle'" | "'Lobby'" | "'Running'" | "'Movie'" | "'Unknown'" | "'Save'" | "'InitMenu'" | "'InitNetwork'" | "'Menu'" | "'InitConnection'" | "'LoadMenu'" | "'SwapLevel'" | "'LoadLevel'" | "'LoadModule'" | "'LoadSession'" | "'Init'" | "'LoadGMCampaign'" | "'UnloadLevel'" | "'UnloadModule'" | "'UnloadSession'" | "'PrepareRunning'" | "'Disconnect'" | "'Join'" | "'StartLoading'" | "'StopLoading'" | "'StartServer'" | "'Installation'" | "'Exit'" | "'GameMasterPause'" | "'ModReceiving'"
--- @alias EclItemFlags string | "'IsDoor'" | "'Invisible'" | "'PositionUpdatePending'" | "'HideHP'" | "'Wadable'" | "'Walkable'" | "'DontAddToBottomBar'" | "'CanBePickedUp'" | "'CanWalkThrough'" | "'Known'" | "'CanBeMoved'" | "'PhysicsFlag1'" | "'PhysicsFlag2'" | "'Sticky'" | "'PhysicsFlag3'" | "'CoverAmount'" | "'FoldDynamicStats'" | "'CanShootThrough'" | "'InteractionDisabled'" | "'CanUse'" | "'IsContainer'" | "'IsCraftingIngredient'" | "'Floating'" | "'Global'" | "'FreezeGravity'" | "'StoryItem'" | "'Fade'" | "'IsLadder'" | "'IsSourceContainer'" | "'Activated'" | "'IsSecretDoor'" | "'Invulnerable'" | "'EnableHighlights'" | "'Destroyed'" | "'TeleportOnUse'" | "'Hostile'" | "'PinnedContainer'" | "'Unimportant'"
--- @alias EclItemFlags2 string | "'IsKey'" | "'UseSoundsLoaded'" | "'Consumable'" | "'UnEquipLocked'" | "'CanUseRemotely'" | "'Stolen'"
--- @alias EclItemPhysicsFlags string | "'RequestWakeNeighbours'" | "'PhysicsDisabled'" | "'RequestRaycast'"
--- @alias EclStatusFlags string | "'RequestDelete'" | "'HasVisuals'" | "'Started'" | "'KeepAlive'"
--- @alias EocCombatComponentFlags string | "'Guarded'" | "'RequestEnterCombat'" | "'IsBoss'" | "'InArena'" | "'CanFight'" | "'TurnEnded'" | "'CanJoinCombat'" | "'RequestTakeExtraTurn'" | "'IsTicking'" | "'CanGuard'" | "'RequestEndTurn'" | "'CanForceEndTurn'" | "'IsInspector'" | "'FleeOnEndTurn'" | "'GuardOnEndTurn'" | "'EnteredCombat'" | "'TookExtraTurn'" | "'DelayDeathCount'" | "'CounterAttacked'"
--- @alias EocSkillBarItemType string | "'Skill'" | "'None'" | "'ItemTemplate'" | "'Action'" | "'Item'"
--- @alias EsvCharacterFlags string | "'PartyFollower'" | "'CharCreationInProgress'" | "'DisableFlee_M'" | "'Loaded'" | "'IgnoresTriggers'" | "'RegisteredForAutomatedDialog'" | "'IsCompanion_M'" | "'GMReroll'" | "'Passthrough'" | "'CharacterControl'" | "'DeferredRemoveEscapist'" | "'Temporary'" | "'InArena'" | "'NoRotate'" | "'DontCacheTemplate'" | "'IsPlayer'" | "'CoverAmount'" | "'CanShootThrough'" | "'LevelTransitionPending'" | "'CharacterCreationFinished'" | "'Floating'" | "'WalkThrough'" | "'SpotSneakers'" | "'NeedsMakePlayerUpdate'" | "'Totem'" | "'CustomLookEnabled'" | "'Dead'" | "'Activated'" | "'ForceNonzeroSpeed'" | "'IsHuge'" | "'InParty'" | "'OffStage'" | "'Multiplayer'" | "'HostControl'" | "'CannotDie'" | "'HasOwner'" | "'StoryNPC'" | "'InDialog'" | "'Summon'" | "'FightMode'" | "'RequestStartTurn'" | "'CannotMove'" | "'Deactivated'" | "'FindValidPositionOnActivate'" | "'CannotRun'"
--- @alias EsvCharacterFlags2 string | "'Resurrected'" | "'HasDefaultDialog'" | "'TreasureGeneratedForTrader'" | "'Global'" | "'HasOsirisDialog'" | "'Trader'"
--- @alias EsvCharacterFlags3 string | "'IsSpectating'" | "'HasWalkSpeedOverride'" | "'ManuallyLeveled'" | "'HasRunSpeedOverride'" | "'IsPet'" | "'IsGameMaster'" | "'IsPossessed'" | "'NoReptuationEffects'"
--- @alias EsvCharacterTransformFlags string | "'ReplaceInventory'" | "'ReplaceCustomLooks'" | "'ReplaceScripts'" | "'ReplaceOriginalTemplate'" | "'ReplaceStats'" | "'Immediate'" | "'ReplaceTags'" | "'ReplaceCustomNameIcon'" | "'ReplaceScale'" | "'ReplaceSkills'" | "'ReplaceVoiceSet'" | "'ImmediateSync'" | "'ReplaceCurrentTemplate'" | "'DiscardOriginalDisplayName'" | "'DontCheckRootTemplate'" | "'ReleasePlayerData'" | "'SaveOriginalDisplayName'" | "'DontReplaceCombatState'" | "'ReplaceEquipment'"
--- @alias EsvCharacterTransformType string | "'TransformToTemplate'" | "'TransformToCharacter'"
--- @alias EsvEntityComponentIndex string | "'AnimationBlueprint'" | "'EventTrigger'" | "'AIHintAreaTrigger'" | "'CustomStats'" | "'Character'" | "'MusicVolumeTrigger'" | "'GMJournalNode'" | "'GameMaster'" | "'SecretRegionTrigger'" | "'Effect'" | "'CrimeAreaTrigger'" | "'SoundVolumeTrigger'" | "'AtmosphereTrigger'" | "'StatsAreaTrigger'" | "'ContainerElement'" | "'OverviewMap'" | "'Vignette'" | "'RegionTrigger'" | "'Spline'" | "'Egg'" | "'CrimeRegionTrigger'" | "'Container'" | "'Note'" | "'CustomStatDefinition'" | "'EoCPointTrigger'" | "'ExplorationTrigger'" | "'Item'" | "'EoCAreaTrigger'" | "'StartTrigger'" | "'Combat'" | "'Net'" | "'Projectile'" | "'TeleportTrigger'"
--- @alias EsvEntitySystemIndex string | "'EnvironmentalStatusManager'" | "'VisualSystem'" | "'LightManager'" | "'DecalManager'" | "'CharacterSplineSystem'" | "'SoundSystem'" | "'SightManager'" | "'CustomStats'" | "'PublishingSystem'" | "'GameActionManager'" | "'GameMasterManager'" | "'TurnManager'" | "'AnimationBlueprintSystem'" | "'TriggerManager'" | "'GMJournalNode'" | "'ItemManager'" | "'GameMaster'" | "'EggManager'" | "'GameMasterCampaignManager'" | "'SurfaceManager'" | "'GMJournalSystem'" | "'CharacterManager'" | "'ContainerElement'" | "'CameraSplineSystem'" | "'ContainerElementComponent'" | "'CustomStatsSystem'" | "'ContainerComponentSystem'" | "'Container'" | "'EffectManager'" | "'NetEntityManager'" | "'RewardManager'" | "'ShroudManager'" | "'LightProbeManager'" | "'ProjectileManager'"
--- @alias EsvGameState string | "'Paused'" | "'BuildStory'" | "'Idle'" | "'Running'" | "'Unknown'" | "'Save'" | "'Sync'" | "'LoadLevel'" | "'LoadModule'" | "'LoadSession'" | "'Init'" | "'LoadGMCampaign'" | "'UnloadLevel'" | "'UnloadModule'" | "'UnloadSession'" | "'Uninitialized'" | "'Disconnect'" | "'ReloadStory'" | "'Installation'" | "'Exit'" | "'GameMasterPause'"
--- @alias EsvItemFlags string | "'IsDoor'" | "'Invisible'" | "'WakePhysics'" | "'CanOnlyBeUsedByOwner'" | "'HideHP'" | "'NoCover'" | "'Destroy'" | "'Frozen'" | "'CanBePickedUp'" | "'Known'" | "'CanBeMoved'" | "'Sticky'" | "'WalkOn'" | "'CanShootThrough'" | "'LoadedTemplate'" | "'InteractionDisabled'" | "'ClientSync1'" | "'WalkThrough'" | "'CanUse'" | "'IsContainer'" | "'Floating'" | "'FreezeGravity'" | "'ForceSync'" | "'IsSurfaceBlocker'" | "'StoryItem'" | "'IsLadder'" | "'DontAddToHotbar'" | "'Totem'" | "'PositionChanged'" | "'Activated'" | "'GMFolding'" | "'OffStage'" | "'IsSecretDoor'" | "'Invulnerable'" | "'TransformChanged'" | "'ClientSync2'" | "'SourceContainer'" | "'Destroyed'" | "'Summon'" | "'IsSurfaceCloudBlocker'" | "'TeleportOnUse'" | "'PinnedContainer'"
--- @alias EsvItemFlags2 string | "'UseRemotely'" | "'TreasureGenerated'" | "'IsKey'" | "'UnsoldGenerated'" | "'UnEquipLocked'" | "'Global'" | "'CanConsume'"
--- @alias EsvItemTransformFlags string | "'ReplaceScripts'" | "'ReplaceStats'" | "'Immediate'"
--- @alias EsvStatusFlags0 string | "'IsFromItem'" | "'Channeled'" | "'InitiateCombat'" | "'IsLifeTimeSet'" | "'KeepAlive'" | "'Influence'" | "'IsOnSourceSurface'"
--- @alias EsvStatusFlags1 string | "'IsHostileAct'" | "'BringIntoCombat'" | "'IsInvulnerable'" | "'IsResistingDeath'"
--- @alias EsvStatusFlags2 string | "'RequestDelete'" | "'ForceStatus'" | "'ForceFailStatus'" | "'Started'" | "'RequestClientSync2'" | "'RequestDeleteAtTurnEnd'" | "'RequestClientSync'"
--- @alias EsvStatusMaterialApplyFlags string | "'ApplyOnBody'" | "'ApplyOnArmor'" | "'ApplyOnWeapon'" | "'ApplyOnWings'" | "'ApplyOnHorns'" | "'ApplyOnOverhead'"
--- @alias EsvSystemType string | "'AnimationBlueprint'" | "'NetEntity'" | "'Shroud'" | "'CharacterSpline'" | "'CameraSpline'" | "'GMJournal'" | "'SightManager'" | "'EnvironmentalStatus'" | "'Character'" | "'TurnManager'" | "'CustomStat'" | "'Reward'" | "'Effect'" | "'ContainerElement'" | "'GM'" | "'GameAction'" | "'Egg'" | "'Container'" | "'Surface'" | "'Item'" | "'Trigger'" | "'GMCampaign'" | "'Projectile'"
--- @alias StatsAbilityType string | "'WarriorLore'" | "'AirSpecialist'" | "'EarthSpecialist'" | "'Brewmaster'" | "'MagicArmorMastery'" | "'FireSpecialist'" | "'Charm'" | "'Runecrafting'" | "'Sentinel'" | "'Necromancy'" | "'Sulfurology'" | "'Summoning'" | "'Ranged'" | "'Polymorph'" | "'PainReflection'" | "'Telekinesis'" | "'WaterSpecialist'" | "'Barter'" | "'Sourcery'" | "'Crafting'" | "'Thievery'" | "'Wand'" | "'Loremaster'" | "'Reflexes'" | "'Repair'" | "'Sneaking'" | "'RangerLore'" | "'Pickpocket'" | "'RogueLore'" | "'Reason'" | "'Persuasion'" | "'Intimidate'" | "'Leadership'" | "'DualWielding'" | "'Perseverance'" | "'PhysicalArmorMastery'" | "'VitalityMastery'" | "'Shield'" | "'Luck'" | "'SingleHanded'" | "'TwoHanded'"
--- @alias StatsArmorType string | "'Sentinel'" | "'Mail'" | "'Robe'" | "'None'" | "'Cloth'" | "'Plate'" | "'Leather'"
--- @alias StatsCharacterFlags string | "'Invisible'" | "'DrinkedPotion'" | "'EquipmentValidated'" | "'IsPlayer'" | "'Blind'" | "'InParty'" | "'IsSneaking'"
--- @alias StatsCharacterStatGetterType string | "'CriticalChance'" | "'PhysicalResistance'" | "'Dodge'" | "'Hearing'" | "'Finesse'" | "'Strength'" | "'APStart'" | "'Intelligence'" | "'Constitution'" | "'CorrosiveResistance'" | "'Sight'" | "'BlockChance'" | "'PoisonResistance'" | "'LifeSteal'" | "'MaxMp'" | "'ChanceToHitBoost'" | "'Initiative'" | "'APMaximum'" | "'APRecovery'" | "'ShadowResistance'" | "'Wits'" | "'Accuracy'" | "'Movement'" | "'PiercingResistance'" | "'FireResistance'" | "'EarthResistance'" | "'WaterResistance'" | "'CustomResistance'" | "'Memory'" | "'AirResistance'" | "'MagicResistance'" | "'DamageBoost'"
--- @alias StatsCriticalRoll string | "'Roll'" | "'Critical'" | "'NotCritical'"
--- @alias StatsDamageType string | "'Poison'" | "'Sentinel'" | "'Air'" | "'Piercing'" | "'Physical'" | "'Corrosive'" | "'Shadow'" | "'Earth'" | "'Magic'" | "'Chaos'" | "'None'" | "'Water'" | "'Fire'" | "'Sulfuric'"
--- @alias StatsDeathType string | "'Lifetime'" | "'Acid'" | "'Sentinel'" | "'PetrifiedShatter'" | "'Piercing'" | "'Physical'" | "'Hang'" | "'Sulfur'" | "'None'" | "'Incinerate'" | "'Electrocution'" | "'DoT'" | "'FrozenShatter'" | "'Surrender'" | "'KnockedDown'" | "'Arrow'" | "'Explode'"
--- @alias StatsEquipmentStatsType string | "'Weapon'" | "'Shield'" | "'Armor'"
--- @alias StatsHandednessType string | "'One'" | "'Any'" | "'Two'"
--- @alias StatsHighGroundBonus string | "'EvenGround'" | "'LowGround'" | "'Unknown'" | "'HighGround'"
--- @alias StatsHitFlag string | "'DamagedMagicArmor'" | "'CriticalHit'" | "'FromSetHP'" | "'Dodged'" | "'NoDamageOnOwner'" | "'DamagedVitality'" | "'Flanking'" | "'CounterAttack'" | "'Backstab'" | "'Poisoned'" | "'Hit'" | "'Bleeding'" | "'DamagedPhysicalArmor'" | "'NoEvents'" | "'Burning'" | "'DontCreateBloodSurface'" | "'Reflection'" | "'PropagatedFromOwner'" | "'ProcWindWalker'" | "'Missed'" | "'FromShacklesOfPain'" | "'DoT'" | "'Blocked'" | "'Surface'"
--- @alias StatsHitType string | "'Ranged'" | "'Melee'" | "'Magic'" | "'DoT'" | "'Surface'" | "'WeaponDamage'" | "'Reflected'"
--- @alias StatsItemSlot string | "'Breast'" | "'Sentinel'" | "'Weapon'" | "'Gloves'" | "'Ring2'" | "'Horns'" | "'Belt'" | "'Helmet'" | "'Amulet'" | "'Overhead'" | "'Wings'" | "'Shield'" | "'Leggings'" | "'Boots'" | "'Ring'"
--- @alias StatsItemSlot32 string | "'Breast'" | "'Sentinel'" | "'Weapon'" | "'Gloves'" | "'Ring2'" | "'Horns'" | "'Belt'" | "'Helmet'" | "'Amulet'" | "'Overhead'" | "'Wings'" | "'Shield'" | "'Leggings'" | "'Boots'" | "'Ring'"
--- @alias StatsPropertyContext string | "'Self'" | "'SelfOnHit'" | "'AoE'" | "'SelfOnEquip'" | "'Target'"
--- @alias StatsPropertyType string | "'CustomDescription'" | "'Custom'" | "'Status'" | "'Force'" | "'OsirisTask'" | "'Extender'" | "'Sabotage'" | "'GameAction'" | "'SurfaceChange'" | "'Summon'"
--- @alias StatsRequirementType string | "'WarriorLore'" | "'TALENT_Reason'" | "'TALENT_StandYourGround'" | "'TALENT_Human_Inventive'" | "'TALENT_Sadist'" | "'AirSpecialist'" | "'TALENT_ChanceToHitMelee'" | "'TALENT_Luck'" | "'TALENT_ElementalRanger'" | "'TALENT_RogueLoreDaggerAPBonus'" | "'TALENT_ViolentMagic'" | "'TALENT_Haymaker'" | "'EarthSpecialist'" | "'TALENT_ResistStun'" | "'TALENT_Escapist'" | "'TALENT_ResurrectToFullHealth'" | "'TRAIT_Independent'" | "'TALENT_WildMag'" | "'MagicArmorMastery'" | "'Vitality'" | "'FireSpecialist'" | "'Charm'" | "'TALENT_Awareness'" | "'TALENT_Raistlin'" | "'TALENT_Politician'" | "'TALENT_Jitterbug'" | "'Necromancy'" | "'TALENT_InventoryAccess'" | "'TALENT_Kickstarter'" | "'TALENT_RogueLoreMovementBonus'" | "'Finesse'" | "'Summoning'" | "'TALENT_MrKnowItAll'" | "'TALENT_FiveStarRestaurant'" | "'TALENT_Perfectionist'" | "'Ranged'" | "'Polymorph'" | "'TALENT_IncreasedArmor'" | "'TALENT_Leech'" | "'TRAIT_Vindictive'" | "'Strength'" | "'PainReflection'" | "'TALENT_ExtraStatPoints'" | "'TALENT_Bully'" | "'TALENT_NoAttackOfOpportunity'" | "'TALENT_Elementalist'" | "'Intelligence'" | "'Telekinesis'" | "'TALENT_EarthSpells'" | "'TALENT_LoneWolf'" | "'TALENT_WalkItOff'" | "'TALENT_WarriorLoreNaturalHealth'" | "'TALENT_MagicCycles'" | "'Constitution'" | "'WaterSpecialist'" | "'TALENT_SurpriseAttack'" | "'TALENT_Zombie'" | "'TALENT_Dwarf_Sneaking'" | "'Barter'" | "'TALENT_ActionPoints'" | "'TALENT_LightningRod'" | "'TALENT_Demon'" | "'TALENT_DualWieldingDodging'" | "'TALENT_LivingArmor'" | "'Sourcery'" | "'TALENT_ResistPoison'" | "'TALENT_IceKing'" | "'TRAIT_Materialistic'" | "'Tag'" | "'Crafting'" | "'TALENT_FireSpells'" | "'TALENT_WeatherProof'" | "'TALENT_Stench'" | "'TALENT_RogueLoreGrenadePrecision'" | "'TALENT_Soulcatcher'" | "'Thievery'" | "'Wand'" | "'TALENT_AvoidDetection'" | "'TALENT_ExtraWandCharge'" | "'TALENT_Elf_Lore'" | "'TALENT_Lizard_Resistance'" | "'Loremaster'" | "'TALENT_ItemMovement'" | "'TALENT_WhatARush'" | "'TALENT_Executioner'" | "'TALENT_Memory'" | "'TALENT_ResistFear'" | "'TALENT_RangerLoreRangedAPBonus'" | "'TALENT_Torturer'" | "'TRAIT_Altruistic'" | "'Reflexes'" | "'TALENT_ChanceToHitRanged'" | "'TALENT_ExtraSkillPoints'" | "'TALENT_Unstable'" | "'TALENT_Gladiator'" | "'Repair'" | "'Sneaking'" | "'TALENT_Intimidate'" | "'TALENT_FolkDancer'" | "'TRAIT_Forgiving'" | "'RangerLore'" | "'Pickpocket'" | "'TALENT_LightStep'" | "'TALENT_WarriorLoreNaturalResistance'" | "'TALENT_RogueLoreDaggerBackStab'" | "'TALENT_Dwarf_Sturdy'" | "'TRAIT_Bold'" | "'None'" | "'RogueLore'" | "'TALENT_Flanking'" | "'TALENT_ActionPoints2'" | "'TALENT_ElementalAffinity'" | "'TALENT_Ambidextrous'" | "'TRAIT_Timid'" | "'Reason'" | "'Persuasion'" | "'TALENT_Backstab'" | "'TALENT_ResistSilence'" | "'TRAIT_Obedient'" | "'TRAIT_Considerate'" | "'Intimidate'" | "'TALENT_Trade'" | "'TALENT_WaterSpells'" | "'TALENT_Courageous'" | "'TALENT_RogueLoreHoldResistance'" | "'TRAIT_Pragmatic'" | "'TALENT_MasterThief'" | "'Wits'" | "'Leadership'" | "'TALENT_Lockpick'" | "'TALENT_AnimalEmpathy'" | "'TALENT_WarriorLoreNaturalArmor'" | "'TALENT_Human_Civil'" | "'TRAIT_Romantic'" | "'DualWielding'" | "'TALENT_ItemCreation'" | "'TALENT_Damage'" | "'TALENT_FaroutDude'" | "'TALENT_QuickStep'" | "'TRAIT_Spiritual'" | "'Perseverance'" | "'TALENT_Sight'" | "'TALENT_ResistKnockdown'" | "'TALENT_WarriorLoreGrenadeRange'" | "'TRAIT_Egotistical'" | "'TRAIT_Righteous'" | "'PhysicalArmorMastery'" | "'TALENT_Carry'" | "'TALENT_Durability'" | "'TALENT_RangerLoreArrowRecover'" | "'TRAIT_Renegade'" | "'TALENT_Indomitable'" | "'TALENT_Kinetics'" | "'TALENT_Initiative'" | "'TALENT_SpillNoBlood'" | "'TRAIT_Blunt'" | "'Shield'" | "'Luck'" | "'TALENT_Repair'" | "'TALENT_Scientist'" | "'TALENT_Elf_CorpseEater'" | "'TALENT_Lizard_Persuasion'" | "'TRAIT_Heartless'" | "'TALENT_Criticals'" | "'TALENT_ExpGain'" | "'TALENT_Sourcerer'" | "'MinKarma'" | "'Memory'" | "'SingleHanded'" | "'TALENT_ResistDead'" | "'TALENT_Vitality'" | "'TALENT_RangerLoreEvasionBonus'" | "'TRAIT_Compassionate'" | "'MaxKarma'" | "'Level'" | "'TwoHanded'" | "'TALENT_AttackOfOpportunity'" | "'TALENT_AirSpells'" | "'TALENT_Charm'" | "'TALENT_GoldenMage'" | "'Combat'" | "'Immobile'" | "'TALENT_GreedyVessel'"
--- @alias StatsTalentType string | "'Kickstarter'" | "'RangerLoreArrowRecover'" | "'MasterThief'" | "'StandYourGround'" | "'Courageous'" | "'WarriorLoreNaturalHealth'" | "'NoAttackOfOpportunity'" | "'GreedyVessel'" | "'SurpriseAttack'" | "'Leech'" | "'GoldenMage'" | "'Quest_SpidersKiss_Int'" | "'MagicCycles'" | "'Vitality'" | "'Charm'" | "'LightStep'" | "'WalkItOff'" | "'Scientist'" | "'ElementalAffinity'" | "'FolkDancer'" | "'RogueLoreGrenadePrecision'" | "'ItemCreation'" | "'Raistlin'" | "'IceKing'" | "'SpillNoBlood'" | "'RogueLoreDaggerBackStab'" | "'Flanking'" | "'MrKnowItAll'" | "'Lizard_Persuasion'" | "'Backstab'" | "'WhatARush'" | "'Human_Inventive'" | "'ResurrectExtraHealth'" | "'Lockpick'" | "'ChanceToHitMelee'" | "'FaroutDude'" | "'Human_Civil'" | "'WildMag'" | "'ActionPoints2'" | "'ExpGain'" | "'ElementalRanger'" | "'RangerLoreEvasionBonus'" | "'Dwarf_Sneaking'" | "'Criticals'" | "'Durability'" | "'LightningRod'" | "'WarriorLoreGrenadeRange'" | "'Dwarf_Sturdy'" | "'IncreasedArmor'" | "'Sight'" | "'Politician'" | "'Elf_Lore'" | "'Quest_SpidersKiss_Per'" | "'ResistFear'" | "'WeatherProof'" | "'Demon'" | "'Perfectionist'" | "'ResistKnockdown'" | "'FiveStarRestaurant'" | "'LoneWolf'" | "'Executioner'" | "'ResistStun'" | "'RogueLoreMovementBonus'" | "'ViolentMagic'" | "'ActionPoints'" | "'ResistPoison'" | "'Lizard_Resistance'" | "'QuickStep'" | "'Sadist'" | "'ResistSilence'" | "'Carry'" | "'Initiative'" | "'BeastMaster'" | "'NaturalConductor'" | "'ResistDead'" | "'Repair'" | "'ExtraSkillPoints'" | "'Quest_GhostTree'" | "'Throwing'" | "'WarriorLoreNaturalResistance'" | "'RangerLoreRangedAPBonus'" | "'LivingArmor'" | "'None'" | "'Zombie'" | "'DualWieldingDodging'" | "'Torturer'" | "'Reason'" | "'Quest_SpidersKiss_Null'" | "'Ambidextrous'" | "'ItemMovement'" | "'AttackOfOpportunity'" | "'ExtraStatPoints'" | "'Intimidate'" | "'Unstable'" | "'AnimalEmpathy'" | "'WarriorLoreNaturalArmor'" | "'Quest_Rooted'" | "'Rager'" | "'Trade'" | "'Awareness'" | "'RogueLoreHoldResistance'" | "'WandCharge'" | "'PainDrinker'" | "'Max'" | "'Escapist'" | "'Quest_SpidersKiss_Str'" | "'Sourcerer'" | "'Damage'" | "'FireSpells'" | "'DeathfogResistant'" | "'Elementalist'" | "'WaterSpells'" | "'ResurrectToFullHealth'" | "'Bully'" | "'Haymaker'" | "'AirSpells'" | "'Luck'" | "'RogueLoreDaggerAPBonus'" | "'Gladiator'" | "'EarthSpells'" | "'Elf_CorpseEating'" | "'Indomitable'" | "'InventoryAccess'" | "'Stench'" | "'Memory'" | "'Quest_TradeSecrets'" | "'Jitterbug'" | "'ChanceToHitRanged'" | "'AvoidDetection'" | "'Soulcatcher'"
--- @alias StatsWeaponType string | "'Sentinel'" | "'Spear'" | "'Club'" | "'Bow'" | "'Wand'" | "'Rifle'" | "'None'" | "'Knife'" | "'Sword'" | "'Crossbow'" | "'Axe'" | "'Staff'" | "'Arrow'"


--- @class Actor
--- @field MeshBindings MeshBinding[]
--- @field PhysicsRagdoll PhysicsRagdoll
--- @field Skeleton Skeleton
--- @field TextKeyPrepareFlags uint8
--- @field Time GameTime
--- @field Visual Visual


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


--- @class IActionData
--- @field Type ActionDataType


--- @class IEoCClientObject : IGameObject
--- @field DisplayName STDWString|nil
--- @field GetStatus fun(self: IEoCClientObject, statusId: FixedString):EclStatus
--- @field GetStatusByType fun(self: IEoCClientObject, type: StatusType):EclStatus
--- @field GetStatusObjects fun(self: IEoCClientObject)
--- @field GetStatuses fun(self: IEoCClientObject):FixedString[]


--- @class IEoCServerObject : IGameObject
--- @field DisplayName STDWString|nil
--- @field CreateCacheTemplate fun(self: IEoCServerObject):GameObjectTemplate
--- @field ForceSyncToPeers fun(self: IEoCServerObject)
--- @field GetStatus fun(self: IEoCServerObject, statusId: FixedString):EsvStatus
--- @field GetStatusByHandle fun(self: IEoCServerObject, handle: ComponentHandle):EsvStatus
--- @field GetStatusByType fun(self: IEoCServerObject, type: StatusType):EsvStatus
--- @field GetStatusObjects fun(self: IEoCServerObject)
--- @field GetStatuses fun(self: IEoCServerObject):FixedString[]
--- @field TransformTemplate fun(self: IEoCServerObject, tmpl: GameObjectTemplate)


--- @class IGameObject
--- @field Base BaseComponent
--- @field Handle ComponentHandle
--- @field Height float
--- @field MyGuid FixedString
--- @field NetID NetId
--- @field Rotation mat3
--- @field Scale float
--- @field Translate vec3
--- @field Velocity vec3
--- @field Visual Visual
--- @field GetTags fun(self: IGameObject):FixedString[]
--- @field HasTag fun(self: IGameObject, a1: FixedString):bool
--- @field IsTagged fun(self: IGameObject, tag: FixedString):bool


--- @class IdentifyActionData : IActionData
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


--- @class PhysicsRagdoll


--- @class PhysicsShape
--- @field Name FixedString
--- @field Rotate mat3
--- @field Scale float
--- @field Translate vec3


--- @class PlaySoundActionData : IActionData
--- @field ActivateSoundEvent FixedString
--- @field PlayOnHUD bool


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


--- @class SoundVolumeTriggerData
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
--- @field Rotate mat3
--- @field Rotate2 mat3
--- @field SyncFlags uint16
--- @field Translate vec3
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


--- @class EclCharacter : IEoCClientObject
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
--- @field Global bool
--- @field HasCustomVisualIndices bool
--- @field HasOwner bool
--- @field InCombat bool
--- @field InDialog bool
--- @field InParty bool
--- @field InventoryHandle ComponentHandle
--- @field Invisible_M bool
--- @field Invisible_M2 bool
--- @field IsHuge bool
--- @field IsPlayer bool
--- @field IsRunning bool
--- @field ItemTags FixedString[]
--- @field LadderPosition vec3
--- @field LootedByHandle ComponentHandle
--- @field MovementStartPosition vec3
--- @field Multiplayer bool
--- @field NetID2 NetId
--- @field NetID3 NetId
--- @field NoCover bool
--- @field NoRotate bool
--- @field NoSound bool
--- @field OffStage bool
--- @field OriginalDisplayName TranslatedString
--- @field OriginalTemplate CharacterTemplate
--- @field OwnerCharacterHandle ComponentHandle
--- @field PartyFollower bool
--- @field PlayerCustomData EocPlayerCustomData
--- @field PlayerData EclPlayerData
--- @field PlayerUpgrade EocPlayerUpgrade
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


--- @class EclItem : IEoCClientObject
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
--- @field HideHP bool
--- @field Hostile bool
--- @field InUseByCharacterHandle ComponentHandle
--- @field InUseByUserId int32
--- @field InteractionDisabled bool
--- @field InventoryHandle ComponentHandle
--- @field InventoryParentHandle ComponentHandle
--- @field Invisible bool
--- @field Invulnerable bool
--- @field IsContainer bool
--- @field IsCraftingIngredient bool
--- @field IsDoor bool
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
--- @field PhysicsDisabled bool
--- @field PhysicsFlag1 bool
--- @field PhysicsFlag2 bool
--- @field PhysicsFlag3 bool
--- @field PhysicsFlags EclItemPhysicsFlags
--- @field PinnedContainer bool
--- @field PositionUpdatePending bool
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
--- @field WorldPos vec3
--- @field GetDeltaMods fun(self: EclItem):FixedString[]
--- @field GetInventoryItems fun(self: EclItem):FixedString[]
--- @field GetOwnerCharacter fun(self: EclItem):FixedString|nil


--- @class EclLevel : Level
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


--- @class EocCombatTeamId
--- @field CombinedId uint32


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


--- @class EsvAtmosphereTrigger


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


--- @class EsvExtinguishFireAction : EsvCreateSurfaceActionBase
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
--- @field DontAddToHotbar bool
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
--- @field HideHP bool
--- @field InUseByCharacterHandle ComponentHandle
--- @field InteractionDisabled bool
--- @field InventoryHandle ComponentHandle
--- @field Invisible bool
--- @field Invulnerable bool
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


--- @class EsvItemGeneration
--- @field Base FixedString
--- @field Boosts FixedString[]
--- @field ItemType FixedString
--- @field Level uint16
--- @field Random uint32


--- @class EsvLevel : Level
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
--- @field OwnerTeamId int32
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
--- @field StatusTargetHandle ComponentHandle


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
--- @field ApplyFlags EsvStatusMaterialApplyFlags
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


--- @class EsvSurfaceCell
--- @field Position i16vec2


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


--- @class EsvTrigger


--- @class EsvTurnManager
--- @field AttachedCombatComponents ComponentHandleWithType[]
--- @field CharacterPtrSet EsvCharacter[]
--- @field CombatEntities EntityHandle[]
--- @field CombatEntities2 EntityHandle[]
--- @field CombatGroupInfos table<FixedString, EsvTurnManagerCombatGroup>
--- @field Combats table<uint8, EsvTurnManagerCombat>
--- @field EntitesLeftCombatHandleSet ComponentHandle[]
--- @field EntityWrapperSet EsvTurnManagerEntityWrapper[]
--- @field FreeIdSet uint8[]
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


--- @class EsvTurnManagerCombatGroup
--- @field CombatTeamsOrdered EocCombatTeamId[]
--- @field Initiative uint16
--- @field LastAddedTeamIndex uint64
--- @field Party uint8


--- @class EsvTurnManagerCombatTeam
--- @field AddedNextTurnNotification bool
--- @field CombatGroup EsvTurnManagerCombatGroup
--- @field CombatTeamRound uint16
--- @field ComponentHandle ComponentHandleWithType
--- @field EntityWrapper EsvTurnManagerEntityWrapper
--- @field Initiative uint16
--- @field StillInCombat bool
--- @field TeamId EocCombatTeamId


--- @class EsvTurnManagerEntityWrapper
--- @field Character EsvCharacter
--- @field CombatComponentPtr EocCombatComponent
--- @field Handle EntityHandle
--- @field Item EsvItem


--- @class EsvTurnManagerTimeoutOverride
--- @field Handle ComponentHandleWithType
--- @field Timeout float


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
local Ext_ClientEntity = {}

--- @return EocAiGrid
function Ext_ClientEntity.GetAiGrid() end


function Ext_ClientEntity.GetCharacter() end

--- @return EclLevel
function Ext_ClientEntity.GetCurrentLevel() end

--- @return IEoCClientObject
function Ext_ClientEntity.GetGameObject() end

--- @param handle ComponentHandle 
--- @return EclInventory
function Ext_ClientEntity.GetInventory(handle) end


function Ext_ClientEntity.GetItem() end

--- @return EclStatus
function Ext_ClientEntity.GetStatus() end

--- @return ComponentHandle
function Ext_ClientEntity.NullHandle() end



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
--- @return Visual
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



--- @class Ext_ServerAi
local Ext_ServerAi = {}

--- @return EsvAiHelpers
function Ext_ServerAi.GetAiHelpers() end

--- @return EsvAiModifiers
function Ext_ServerAi.GetArchetypes() end



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
function Ext_ServerEntity.GetCombat(combatId) end

--- @return EsvLevel
function Ext_ServerEntity.GetCurrentLevel() end


function Ext_ServerEntity.GetCurrentLevelData() end

--- @return IEoCServerObject
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

--- @return int64
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
Ext = {}


--- @class ExtServer
--- @field Debug Ext_Debug
--- @field IO Ext_IO
--- @field Json Ext_Json
--- @field L10N Ext_L10N
--- @field Math Ext_Math
--- @field Mod Ext_Mod
--- @field Resource Ext_Resource
--- @field Ai Ext_ServerAi
--- @field ServerAi Ext_ServerAi
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
Ext = {}


--- @class Ext
--- @field Audio Ext_ClientAudio
--- @field ClientAudio Ext_ClientAudio
--- @field Client Ext_ClientClient
--- @field ClientClient Ext_ClientClient
--- @field Entity Ext_ClientEntity|Ext_ServerEntity
--- @field ClientEntity Ext_ClientEntity
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
--- @field Ai Ext_ServerAi
--- @field ServerAi Ext_ServerAi
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
Ext = {}


