///Called on user, from base of /datum/strippable_item/alternate_action() (atom/target)
#define COMSIG_TRY_ALT_ACTION "try_alt_action"
	#define COMPONENT_CANT_ALT_ACTION (1<<0)
///Called on /basic when updating its speed, from base of /mob/living/basic/update_basic_mob_varspeed(): ()
#define POST_BASIC_MOB_UPDATE_VARSPEED "post_basic_mob_update_varspeed"
///from base of /mob/Login(): ()
#define COMSIG_MOB_LOGIN "mob_login"
///from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
///from base of mob/set_stat(): (new_stat, old_stat)
#define COMSIG_MOB_STATCHANGE "mob_statchange"
///from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_CLICKON "mob_clickon"
///from base of mob/MiddleClickOn(): (atom/A)
#define COMSIG_MOB_MIDDLECLICKON "mob_middleclickon"
///from base of mob/AltClickOn(): (atom/A)
#define COMSIG_MOB_ALTCLICKON "mob_altclickon"
	#define COMSIG_MOB_CANCEL_CLICKON (1<<0)
///from base of mob/alt_click_on_secodary(): (atom/A)
#define COMSIG_MOB_ALTCLICKON_SECONDARY "mob_altclickon_secondary"
/// From base of /mob/living/simple_animal/bot/proc/bot_step()
#define COMSIG_MOB_BOT_PRE_STEP "mob_bot_pre_step"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMPONENT_MOB_BOT_BLOCK_PRE_STEP COMPONENT_MOVABLE_BLOCK_PRE_MOVE
/// From base of /mob/living/simple_animal/bot/proc/bot_step()
#define COMSIG_MOB_BOT_STEP "mob_bot_step"

/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_PRE_LIVING_MOVE "mob_client_pre_living_move"
	/// Should we stop the current living movement attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// From base of /client/Move(): (list/move_args)
#define COMSIG_MOB_CLIENT_PRE_MOVE "mob_client_pre_move"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	/// The argument of move_args which corresponds to the loc we're moving to
	#define MOVE_ARG_NEW_LOC 1
	/// The arugment of move_args which dictates our movement direction
	#define MOVE_ARG_DIRECTION 2
/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_MOVED "mob_client_moved"
/// From base of /client/proc/change_view() (mob/source, new_size)
#define COMSIG_MOB_CLIENT_CHANGE_VIEW "mob_client_change_view"
/// From base of /mob/proc/reset_perspective() (mob/source)
#define COMSIG_MOB_RESET_PERSPECTIVE "mob_reset_perspective"
/// from base of /client/proc/set_eye() : (atom/old_eye, atom/new_eye)
#define COMSIG_CLIENT_SET_EYE "client_set_eye"
/// from base of /datum/view_data/proc/afterViewChange() : (view)
#define COMSIG_VIEWDATA_UPDATE "viewdata_update"


///from mind/transfer_to. Sent to the receiving mob.
#define COMSIG_MOB_MIND_TRANSFERRED_INTO "mob_mind_transferred_into"

///from base of obj/allowed(mob/M): (/obj) returns ACCESS_ALLOWED if mob has id access to the obj
#define COMSIG_MOB_TRIED_ACCESS "tried_access"
	#define ACCESS_ALLOWED (1<<0)
	#define ACCESS_DISALLOWED (1<<1)
	#define LOCKED_ATOM_INCOMPATIBLE (1<<2)

///from base of mob/can_cast_magic(): (mob/user, magic_flags, charge_cost)
#define COMSIG_MOB_RESTRICT_MAGIC "mob_cast_magic"
///from base of mob/can_block_magic(): (mob/user, casted_magic_flags, charge_cost)
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_MAGIC_BLOCKED (1<<0)

///from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"

/// from /mob/living/proc/apply_damage(): (list/damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
/// allows you to add multiplicative damage modifiers to the damage mods argument to adjust incoming damage
/// not sent if the apply damage call was forced
#define COMSIG_MOB_APPLY_DAMAGE_MODIFIERS "mob_apply_damage_modifiers"
/// from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone, blocked, sharpness, attack_direction, attacking_item)
#define COMSIG_MOB_APPLY_DAMAGE "mob_apply_damage"
/// from /mob/living/proc/apply_damage(): (damage, damagetype, def_zone, blocked, sharpness, attack_direction, attacking_item)
/// works like above but after the damage is actually inflicted
#define COMSIG_MOB_AFTER_APPLY_DAMAGE "mob_after_apply_damage"
///from base of /mob/living/attack_alien(): (user)
#define COMSIG_MOB_ATTACK_ALIEN "mob_attack_alien"
///from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_THROW "mob_throw"
///from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
///from /mob/living/handle_eye_contact(): (mob/living/other_mob)
#define COMSIG_MOB_EYECONTACT "mob_eyecontact"
	/// return this if you want to block printing this message to this person, if you want to print your own (does not affect the other person's message)
	#define COMSIG_BLOCK_EYECONTACT (1<<0)
///from base of /mob/update_sight(): ()
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"
////from /mob/living/say(): ()
#define COMSIG_MOB_SAY "mob_say"
	#define COMPONENT_UPPERCASE_SPEECH (1<<0)
	// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	#define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	#define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	#define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7
	#define SPEECH_FILTERPROOF 8
	#define SPEECH_RANGE 9

///from /mob/say_dead(): (mob/speaker, message)
#define COMSIG_MOB_DEADSAY "mob_deadsay"
	#define MOB_DEADSAY_SIGNAL_INTERCEPT (1<<0)
///from /mob/living/emote(): ()
#define COMSIG_MOB_EMOTE "mob_emote"

///from base of mob/try_swap_hand(): (obj/item/currently_held_item)
#define COMSIG_MOB_SWAPPING_HANDS "mob_swapping_hands"
	#define COMPONENT_BLOCK_SWAP (1<<0)
/// from foot of mob/try_swap_hand(): ()
/// Performed after the hands are swapped.
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"

///from base of /mob/verb/pointed: (atom/A)
#define COMSIG_MOB_POINTED "mob_pointed"
///Mob is trying to open the wires of a target [/atom], from /datum/wires/interactable(): (atom/target)
#define COMSIG_TRY_WIRES_INTERACT "try_wires_interact"
	#define COMPONENT_CANT_INTERACT_WIRES (1<<0)
#define COMSIG_MOB_EMOTED(emote_key) "mob_emoted_[emote_key]"
///sent when a mob/login() finishes: (client)
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
//from base of client/MouseDown(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEUP "client_mouseup"
	#define COMPONENT_CLIENT_MOUSEUP_INTERCEPT (1<<0)
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDRAG "client_mousedrag"
///Called on user, from base of /datum/strippable_item/try_(un)equip() (atom/target, obj/item/equipping?)
#define COMSIG_TRY_STRIP "try_strip"
	#define COMPONENT_CANT_STRIP (1<<0)
///From /datum/component/creamed/Initialize()
#define COMSIG_MOB_CREAMED "mob_creamed"
///From /obj/item/gun/proc/check_botched()
#define COMSIG_MOB_CLUMSY_SHOOT_FOOT "mob_clumsy_shoot_foot"
///from /obj/item/hand_item/slapper/attack_obj(): (source=obj/structure/table/slammed_table, mob/living/slammer)
#define COMSIG_TABLE_SLAMMED "table_slammed"
///from base of atom/attack_hand(): (mob/user, modifiers)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
///from base of /obj/item/attack(): (mob/M, mob/user)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
///from base of obj/item/afterattack(): (atom/target, obj/item/weapon, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
///from base of obj/item/afterattack_secondary(): (atom/target, obj/item/weapon, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK_SECONDARY "mob_item_afterattack_secondary"
///from base of mob/RangedAttack(): (atom/A, modifiers)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
///from base of mob/ranged_secondary_attack(): (atom/target, modifiers)
#define COMSIG_MOB_ATTACK_RANGED_SECONDARY "mob_attack_ranged_secondary"
///From base of atom/ctrl_click(): (atom/A)
#define COMSIG_MOB_CTRL_CLICKED "mob_ctrl_clicked"
///From base of mob/update_movespeed():area
#define COMSIG_MOB_MOVESPEED_UPDATED "mob_update_movespeed"
/// From /atom/movable/screen/zone_sel/proc/set_selected_zone.
/// Fires when the user has changed their selected body target.
#define COMSIG_MOB_SELECTED_ZONE_SET "mob_set_selected_zone"
/// from base of [/client/proc/handle_spam_prevention] (message, mute_type)
#define COMSIG_MOB_AUTOMUTE_CHECK "client_automute_check" // The check is performed by the client.
	/// Prevents the automute system checking this client for repeated messages.
	#define WAIVE_AUTOMUTE_CHECK (1<<0)

/// from base of [/datum/preference/toggle/motion_sickness] (new_value)
#define COMSIG_MOB_MOTION_SICKNESS_UPDATE "client_prefs_motion_sickness_change"
