/*********************Hivelord stabilizer****************/
/obj/item/hivelordstabilizer
	name = "stabilizing serum"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject certain types of monster organs with this stabilizer to preserve their healing powers indefinitely."
	w_class = WEIGHT_CLASS_TINY

/obj/item/hivelordstabilizer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ismob(interacting_with))
		return NONE

	var/obj/item/organ/regenerative_core/C = interacting_with
	if(!istype(C, /obj/item/organ/regenerative_core))
		to_chat(user, span_warning("The stabilizer only works on certain types of monster organs, generally regenerative in nature."))
		return ITEM_INTERACT_BLOCKING

	C.preserved()
	to_chat(user, span_notice("You inject the [interacting_with] with the stabilizer. It will no longer go inert."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/************************Hivelord core*******************/
/obj/item/organ/regenerative_core
	name = "regenerative core"
	desc = "All that remains of a hivelord. It can be used to help keep your body going, but it will rapidly decay into uselessness."
	icon_state = "roro core 2"
	visual = FALSE
	item_flags = NOBLUDGEON
	slot = ORGAN_SLOT_REGENERATIVE_CORE
	organ_flags = NONE
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0

/obj/item/organ/regenerative_core/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(inert_check)), 2400)

/obj/item/organ/regenerative_core/proc/inert_check()
	if(!preserved)
		go_inert()

/obj/item/organ/regenerative_core/proc/preserved(implanted = 0)
	inert = FALSE
	preserved = TRUE
	update_appearance()
	desc = "All that remains of a hivelord. It is preserved, allowing you to use it to heal completely without danger of decay."
	if(implanted)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "implanted"))
	else
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "stabilizer"))

/obj/item/organ/regenerative_core/proc/go_inert()
	inert = TRUE
	name = "decayed regenerative core"
	desc = "All that remains of a hivelord. It has decayed, and is completely useless."
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "inert"))
	update_appearance()

/obj/item/organ/regenerative_core/ui_action_click()
	if(inert)
		to_chat(owner, span_notice("[src] breaks down as it tries to activate."))
	else
		owner.revive(full_heal = TRUE, admin_revive = FALSE)
	qdel(src)

/obj/item/organ/regenerative_core/on_life(delta_time, times_fired)
	. = ..()
	if(owner.health <= owner.crit_threshold)
		ui_action_click()

///Handles applying the core, logging and status effects.
/obj/item/organ/regenerative_core/proc/applyto(atom/target, mob/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(inert)
			to_chat(user, span_notice("[src] has decayed and can no longer be used to heal."))
			return
		else
			if(H.stat == DEAD)
				to_chat(user, span_notice("[src] is useless on the dead."))
				return
			if(H != user)
				H.visible_message(span_notice("[user] forces [H] to apply [src]... Black tendrils entangle and reinforce [H.p_them()]!"))
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
			else
				to_chat(user, span_notice("You start to smear [src] on yourself. Disgusting tendrils hold you together and allow you to keep moving, but for how long?"))
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
			H.apply_status_effect(/datum/status_effect/regenerative_core)
			qdel(src)

/obj/item/organ/regenerative_core/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ismob(interacting_with))
		return NONE

	applyto(interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/organ/regenerative_core/attack_self(mob/user)
	if(user.canUseTopic(src, USE_CLOSE|USE_IGNORE_TK))
		applyto(user, user)

/obj/item/organ/regenerative_core/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(!.)
		return

	if(!preserved && !inert)
		preserved(TRUE)
		owner.visible_message(span_notice("[src] stabilizes as it's inserted."))

/obj/item/organ/regenerative_core/Remove(mob/living/carbon/M, special = 0)
	if(!inert && !special)
		owner.visible_message(span_notice("[src] rapidly decays as it's removed."))
		go_inert()
	return ..()

/*************************Legion core********************/
/obj/item/organ/regenerative_core/legion
	desc = "A strange rock that crackles with power. It can be used to heal completely, but it will rapidly decay into uselessness."
	icon_state = "legion_soul"

/obj/item/organ/regenerative_core/legion/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/organ/regenerative_core/update_icon_state()
	if (inert)
		icon_state = "legion_soul_inert"
	if (preserved)
		icon_state = "legion_soul"
	if (!inert && !preserved)
		icon_state = "legion_soul_unstable"
	return ..()

/obj/item/organ/regenerative_core/legion/go_inert()
	..()
	desc = "[src] has become inert. It has decayed, and is completely useless."

/obj/item/organ/regenerative_core/legion/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It is preserved, allowing you to use it to heal completely without danger of decay."
