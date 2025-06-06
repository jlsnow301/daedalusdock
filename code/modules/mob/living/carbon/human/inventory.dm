/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	return dna.species.can_equip(I, slot, disable_warning, src, bypass_equip_delay_self, ignore_equipped)

// Return the item currently in the slot ID
/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BELT)
			return belt
		if(ITEM_SLOT_ID)
			return wear_id
		if(ITEM_SLOT_EARS)
			return ears
		if(ITEM_SLOT_EYES)
			return glasses
		if(ITEM_SLOT_GLOVES)
			return gloves
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_FEET)
			return shoes
		if(ITEM_SLOT_OCLOTHING)
			return wear_suit
		if(ITEM_SLOT_ICLOTHING)
			return w_uniform
		if(ITEM_SLOT_LPOCKET)
			return l_store
		if(ITEM_SLOT_RPOCKET)
			return r_store
		if(ITEM_SLOT_SUITSTORE)
			return s_store

	return ..()

/mob/living/carbon/human/get_slot_by_item(obj/item/looking_for)
	if(looking_for == belt)
		return ITEM_SLOT_BELT

	if(looking_for == wear_id)
		return ITEM_SLOT_ID

	if(looking_for == ears)
		return ITEM_SLOT_EARS

	if(looking_for == glasses)
		return ITEM_SLOT_EYES

	if(looking_for == gloves)
		return ITEM_SLOT_GLOVES

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	if(looking_for == shoes)
		return ITEM_SLOT_FEET

	if(looking_for == wear_suit)
		return ITEM_SLOT_OCLOTHING

	if(looking_for == w_uniform)
		return ITEM_SLOT_ICLOTHING

	if(looking_for == r_store)
		return ITEM_SLOT_RPOCKET

	if(looking_for == l_store)
		return ITEM_SLOT_LPOCKET

	if(looking_for == s_store)
		return ITEM_SLOT_SUITSTORE

	return ..()

///Returns a list of every item slot contents on the user.
/mob/living/carbon/human/get_all_worn_items(include_pockets = TRUE)
	. = return_extra_wearables() + return_worn_clothing() + return_cuff_slots()
	if(include_pockets)
		. += return_pocket_slots()

///Returns a list of worn "clothing" items.
/mob/living/carbon/human/proc/return_worn_clothing()
	return list(
		wear_suit,
		gloves,
		shoes,
		w_uniform,
		head,
		glasses,
		wear_mask,
		ears,
		wear_neck
	)

///Returns a list of items in slots like the ID slot, belt, backpack
/mob/living/carbon/human/proc/return_extra_wearables()
	return list(
		wear_id,
		belt,
		back
	)

///Returns a list of items in the "*_store" slots
/mob/living/carbon/human/proc/return_pocket_slots()
	return list(
		l_store,
		r_store,
		s_store
	)

///Returns the cuff slot contents as a list
/mob/living/carbon/human/proc/return_cuff_slots()
	return list(
		legcuffed,
		handcuffed,
	)


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
// Initial is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, initial = FALSE, redraw_mob = FALSE)
	if(!..()) //a check failed or the item has already found its slot
		return

	var/not_handled = FALSE //Added in case we make this type path deeper one day
	switch(slot)
		if(ITEM_SLOT_BELT)
			if(belt)
				return
			belt = I

		if(ITEM_SLOT_ID)
			if(wear_id)
				return

			wear_id = I

		if(ITEM_SLOT_EARS)
			if(ears)
				return

			ears = I

		if(ITEM_SLOT_EYES)
			if(glasses)
				return

			glasses = I

			var/obj/item/clothing/glasses/G = I
			if(G.glass_colour_type)
				update_glasses_color(G, 1)

			if(G.vision_correction)
				clear_fullscreen("nearsighted")

		if(ITEM_SLOT_GLOVES)
			if(gloves)
				return

			gloves = I

		if(ITEM_SLOT_FEET)
			if(shoes)
				return

			shoes = I

		if(ITEM_SLOT_OCLOTHING)
			if(wear_suit)
				return

			wear_suit = I

			if(wear_suit.breakouttime) //when equipping a straightjacket
				ADD_TRAIT(src, TRAIT_ARMS_RESTRAINED, SUIT_TRAIT)
				release_all_grabs() //can't pull if restrained
				update_mob_action_buttons() //certain action buttons will no longer be usable

		if(ITEM_SLOT_ICLOTHING)
			if(w_uniform)
				return

			w_uniform = I
			update_suit_sensors()

		if(ITEM_SLOT_LPOCKET)
			l_store = I
			update_pockets()

		if(ITEM_SLOT_RPOCKET)
			r_store = I
			update_pockets()

		if(ITEM_SLOT_SUITSTORE)
			if(s_store)
				return

			s_store = I

		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))

	//Item is handled and in slot, valid to call callback, for this proc should always be true
	if(!not_handled)
		afterEquipItem(I, slot, initial)

		// Send a signal for when we equip an item that used to cover our feet/shoes. Used for bloody feet
		if((I.body_parts_covered & FEET) || (I.flags_inv | I.transparent_protection) & HIDESHOES)
			SEND_SIGNAL(src, COMSIG_CARBON_EQUIP_SHOECOVER, I, slot, initial, redraw_mob)

	return not_handled //For future deeper overrides

/mob/living/carbon/human/equipped_speed_mods()
	. = ..()
	for(var/sloties in get_equipped_items(FALSE))
		var/obj/item/thing = sloties
		. += thing?.slowdown

/mob/living/carbon/human/tryUnequipItem(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE, use_unequip_delay = FALSE, slot = get_slot_by_item(I))
	var/index = get_held_index_of_item(I)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return

	var/handled = TRUE

	if(index && !QDELETED(src) && dna.species.mutanthands) //hand freed, fill with claws, skip if we're getting deleted.
		put_in_hand(new dna.species.mutanthands(), index)

	if(I == wear_suit)
		if(s_store && invdrop)
			dropItemToGround(s_store, TRUE) //It makes no sense for your suit storage to stay on you if you drop your suit.

		if(wear_suit.breakouttime) //when unequipping a straightjacket
			REMOVE_TRAIT(src, TRAIT_ARMS_RESTRAINED, SUIT_TRAIT)
			drop_all_held_items() //suit is restraining
			update_mob_action_buttons() //certain action buttons may be usable again.

		wear_suit = null

	else if(I == w_uniform)
		if(invdrop)
			if(r_store)
				dropItemToGround(r_store, TRUE) //Again, makes sense for pockets to drop.
			if(l_store)
				dropItemToGround(l_store, TRUE)
			if(wear_id)
				dropItemToGround(wear_id)
			if(belt)
				dropItemToGround(belt)

		w_uniform = null
		update_suit_sensors()

	else if(I == gloves)
		gloves = null
		handled = TRUE

	else if(I == glasses)
		glasses = null

		var/obj/item/clothing/glasses/G = I
		if(G.glass_colour_type)
			update_glasses_color(G, 0)

		if(G.vision_correction && HAS_TRAIT(src, TRAIT_NEARSIGHT))
			overlay_fullscreen("nearsighted", /atom/movable/screen/fullscreen/impaired, 1)

	else if(I == ears)
		ears = null

	else if(I == belt)
		belt = null

	else if(I == wear_id)
		wear_id = null

	else if(I == r_store)
		r_store = null

	else if(I == l_store)
		l_store = null

	else if(I == s_store)
		s_store = null

	else
		handled = FALSE

	if(handled && !QDELING(src))
		update_slots_for_item(I, slot)
		hud_used?.update_locked_slots()

	// Send a signal for when we unequip an item that used to cover our feet/shoes. Used for bloody feet
	if((I.body_parts_covered & FEET) || (I.flags_inv | I.transparent_protection) & HIDESHOES)
		SEND_SIGNAL(src, COMSIG_CARBON_UNEQUIP_SHOECOVER, I, force, newloc, no_move, invdrop, silent)

/mob/living/carbon/human/toggle_internals(obj/item/tank, is_external = FALSE)
	// Just close the tank if it's the one the mob already has open.
	var/obj/item/existing_tank = is_external ? external : internal
	if(tank == existing_tank)
		return toggle_close_internals(is_external)
	// Use breathing tube regardless of mask.
	if(can_breathe_tube())
		return toggle_open_internals(tank, is_external)

	// Use mask in absence of tube.
	if(isclothing(wear_mask) && ((wear_mask.visor_flags & MASKINTERNALS) || (wear_mask.clothing_flags & MASKINTERNALS)))
		// Adjust dishevelled breathing mask back onto face.
		if (wear_mask.mask_adjusted)
			wear_mask.adjustmask(src)
		return toggle_open_internals(tank, is_external)

	// Use helmet in absence of tube or valid mask.
	if(can_breathe_helmet())
		return toggle_open_internals(tank, is_external)

	// Notify user of missing valid breathing apparatus.
	if (wear_mask)
		// Invalid mask
		to_chat(src, span_warning("[wear_mask] can't use [tank]!"))

	else if (head)
		// Invalid headgear
		to_chat(src, span_warning("[head] isn't airtight! You need a mask!"))
	else
		// Not wearing any breathing apparatus.
		to_chat(src, span_warning("You need a mask!"))

/// Returns TRUE if the tank successfully toggles open/closed. Opens the tank only if a breathing apparatus is found.
/mob/living/carbon/human/toggle_externals(obj/item/tank)
	return toggle_internals(tank, TRUE)

/mob/living/carbon/human/wear_mask_update(obj/item/I, toggle_off = 1)
	if(invalid_internals())
		cutoff_internals()
	if(I.flags_inv & HIDEEYES)
		update_worn_glasses()
	sec_hud_set_security_status()
	update_appearance(UPDATE_NAME)
	..()

/mob/living/carbon/human/proc/equipOutfit(outfit, visualsOnly = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visualsOnly)


//delete all equipment without dropping anything
/mob/living/carbon/human/proc/delete_equipment()
	for(var/slot in get_all_worn_items())//order matters, dependant slots go first
		qdel(slot)
	for(var/obj/item/I in held_items)
		qdel(I)

/// take the most recent item out of a slot or place held item in a slot

/mob/living/carbon/human/proc/smart_equip_targeted(slot_type = ITEM_SLOT_BELT, slot_item_name = "belt")
	if(incapacitated())
		return

	var/obj/item/thing = get_active_held_item()
	var/obj/item/equipped_item = get_item_by_slot(slot_type)
	if(!equipped_item) // We also let you equip an item like this
		if(!thing)
			to_chat(src, span_warning("You have no [slot_item_name] to take something out of!"))
			return

		if(equip_to_slot_if_possible(thing, slot_type))
			update_held_items()
		return

	var/datum/storage/storage = equipped_item.atom_storage
	if(!storage)
		if(!thing)
			equipped_item.attack_hand(src)
		else
			to_chat(src, span_warning("You can't fit [thing] into your [equipped_item.name]!"))
		return

	if(thing) // put thing in storage item
		if(!equipped_item.atom_storage?.attempt_insert(thing, src))
			to_chat(src, span_warning("You can't fit [thing] into your [equipped_item.name]!"))
		return

	var/atom/real_location = storage.get_real_location()
	if(!real_location.contents.len) // nothing to take out
		to_chat(src, span_warning("There's nothing in your [equipped_item.name] to take out!"))
		return

	var/obj/item/stored = real_location.contents[real_location.contents.len]
	if(!stored || stored.on_found(src))
		return

	stored.attack_hand(src) // take out thing from item in storage slot
	return

