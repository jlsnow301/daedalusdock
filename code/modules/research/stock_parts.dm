/*Power cells are in code\modules\power\cell.dm

If you create T5+ please take a pass at mech_fabricator.dm. The parts being good enough allows it to go into minus values and create materials out of thin air when printing stuff.*/
/obj/item/storage/part_replacer
	name = "rapid part exchange device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "RPED"
	inhand_icon_state = "RPED"
	worn_icon_state = "RPED"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	var/works_from_distance = FALSE
	var/pshoom_or_beepboopblorpzingshadashwoosh = 'sound/items/rped.ogg'
	var/alt_sound = null

/obj/item/storage/part_replacer/Initialize()
	. = ..()

	atom_storage.allow_quick_empty = TRUE
	atom_storage.allow_quick_gather = TRUE
	atom_storage.max_slots = 50
	atom_storage.max_total_storage = 100
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.numerical_stacking = TRUE
	atom_storage.set_holdable(list(/obj/item/stock_parts), null)

/obj/item/storage/part_replacer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery) && !istype(interacting_with, /obj/structure/frame/machine))
		return NONE

	if(istype(interacting_with, /obj/machinery))
		var/obj/machinery/attacked_machinery = interacting_with

		if(!LAZYLEN(attacked_machinery.component_parts))
			return ITEM_INTERACT_BLOCKING

		if(works_from_distance)
			user.Beam(attacked_machinery, icon_state = "rped_upgrade", time = 5)

		return attacked_machinery.exchange_parts(user, src) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

	if(istype(interacting_with, /obj/structure/frame/machine))
		var/obj/structure/frame/machine/attacked_frame = interacting_with

		if(!LAZYLEN(attacked_frame.components))
			return ITEM_INTERACT_BLOCKING

		if(works_from_distance)
			user.Beam(attacked_frame, icon_state = "rped_upgrade", time = 5)

		attacked_frame.attackby(src, user)
		return ITEM_INTERACT_SUCCESS

/obj/item/storage/part_replacer/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(works_from_distance)
		return interact_with_atom(interacting_with, user, modifiers)

/obj/item/storage/part_replacer/proc/play_rped_sound()
	//Plays the sound for RPED exhanging or installing parts.
	if(alt_sound && prob(1))
		playsound(src, alt_sound, 40, TRUE)
	else
		playsound(src, pshoom_or_beepboopblorpzingshadashwoosh, 40, TRUE)

/obj/item/storage/part_replacer/bluespace
	name = "bluespace rapid part exchange device"
	desc = "A version of the RPED that allows for replacement of parts and scanning from a distance, along with higher capacity for parts."
	icon_state = "BS_RPED"
	w_class = WEIGHT_CLASS_NORMAL
	works_from_distance = TRUE
	pshoom_or_beepboopblorpzingshadashwoosh = 'sound/items/pshoom.ogg'
	alt_sound = 'sound/items/pshoom_2.ogg'

/obj/item/storage/part_replacer/bluespace/Initialize(mapload)
	. = ..()

	atom_storage.max_slots = 400
	atom_storage.max_total_storage = 800
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC

	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_part_entered))
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_part_exited))

/**
 * Signal handler for when a part has been inserted into the BRPED.
 *
 * If the inserted item is a rigged or corrupted cell, does some logging.
 *
 * If it has a reagent holder, clears the reagents and registers signals to prevent new
 * reagents being added and registers clean up signals on inserted item's removal from
 * the BRPED.
 */
/obj/item/storage/part_replacer/bluespace/proc/on_part_entered(datum/source, obj/item/inserted_component)
	SIGNAL_HANDLER
	if(inserted_component.reagents)
		if(length(inserted_component.reagents.reagent_list))
			inserted_component.reagents.clear_reagents()
			to_chat(usr, span_notice("[src] churns as [inserted_component] has its reagents emptied into bluespace."))
		RegisterSignal(inserted_component.reagents, COMSIG_REAGENTS_PRE_ADD_REAGENT, PROC_REF(on_insered_component_reagent_pre_add))


	if(!istype(inserted_component, /obj/item/stock_parts/cell))
		return

	var/obj/item/stock_parts/cell/inserted_cell = inserted_component

	if(inserted_cell.rigged || inserted_cell.corrupted)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has inserted rigged/corrupted [inserted_cell] into [src].")
		log_game("[key_name(usr)] has inserted rigged/corrupted [inserted_cell] into [src].")
		usr.log_message("inserted rigged/corrupted [inserted_cell] into [src]", LOG_ATTACK)

/**
 * Signal handler for when the reagents datum of an inserted part has reagents added to it.
 *
 * Registers the PRE_ADD variant which allows the signal handler to stop reagents being
 * added.
 *
 * Simply returns COMPONENT_CANCEL_REAGENT_ADD. We never want to allow people to add
 * reagents to beakers in BRPEDs as they can then be used for spammable remote bombing.
 */
/obj/item/storage/part_replacer/bluespace/proc/on_insered_component_reagent_pre_add(datum/source, reagent, amount, reagtemp, data, no_react)
	SIGNAL_HANDLER

	return COMPONENT_CANCEL_REAGENT_ADD

/**
 * Signal handler for a part is removed from the BRPED.
 *
 * Does signal registration cleanup on its reagents, if it has any.
 */
/obj/item/storage/part_replacer/bluespace/proc/on_part_exited(datum/source, obj/item/removed_component)
	SIGNAL_HANDLER

	if(removed_component.reagents)
		UnregisterSignal(removed_component.reagents, COMSIG_REAGENTS_PRE_ADD_REAGENT)


/obj/item/storage/part_replacer/bluespace/tier1

/obj/item/storage/part_replacer/bluespace/tier1/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/manipulator(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)
		new /obj/item/stock_parts/cell/high(src)

/obj/item/storage/part_replacer/bluespace/tier2

/obj/item/storage/part_replacer/bluespace/tier2/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/adv(src)
		new /obj/item/stock_parts/scanning_module/adv(src)
		new /obj/item/stock_parts/manipulator/nano(src)
		new /obj/item/stock_parts/micro_laser/high(src)
		new /obj/item/stock_parts/matter_bin/adv(src)
		new /obj/item/stock_parts/cell/super(src)

/obj/item/storage/part_replacer/bluespace/tier3

/obj/item/storage/part_replacer/bluespace/tier3/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/super(src)
		new /obj/item/stock_parts/scanning_module/phasic(src)
		new /obj/item/stock_parts/manipulator/pico(src)
		new /obj/item/stock_parts/micro_laser/ultra(src)
		new /obj/item/stock_parts/matter_bin/super(src)
		new /obj/item/stock_parts/cell/hyper(src)

/obj/item/storage/part_replacer/bluespace/tier4

/obj/item/storage/part_replacer/bluespace/tier4/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/manipulator/femto(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
		new /obj/item/stock_parts/cell/bluespace(src)

/obj/item/storage/part_replacer/cargo //used in a cargo crate

/obj/item/storage/part_replacer/cargo/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/manipulator(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)

/obj/item/storage/part_replacer/cyborg
	name = "rapid part exchange device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "borgrped"
	inhand_icon_state = "RPED"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

/proc/cmp_rped_sort(obj/item/A, obj/item/B)
	return B.get_part_rating() - A.get_part_rating()

/obj/item/stock_parts
	name = "stock part"
	desc = "What?"
	icon = 'icons/obj/stock_parts.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/rating = 1
	///Used when a base part has a different name to higher tiers of part. For example, machine frames want any manipulator and not just a micro-manipulator.
	var/base_name
	var/energy_rating = 1

/obj/item/stock_parts/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/item/stock_parts/get_part_rating()
	return rating

//Rating 1

TYPEINFO_DEF(/obj/item/stock_parts/capacitor)
	default_materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor"

TYPEINFO_DEF(/obj/item/stock_parts/scanning_module)
	default_materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"

TYPEINFO_DEF(/obj/item/stock_parts/manipulator)
	default_materials = list(/datum/material/iron=30)

/obj/item/stock_parts/manipulator
	name = "micro-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	base_name = "manipulator"

TYPEINFO_DEF(/obj/item/stock_parts/micro_laser)
	default_materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"

TYPEINFO_DEF(/obj/item/stock_parts/matter_bin)
	default_materials = list(/datum/material/iron=80)

/obj/item/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container designed to hold compressed matter awaiting reconstruction."
	icon_state = "matter_bin"

//Rating 2

TYPEINFO_DEF(/obj/item/stock_parts/capacitor/adv)
	default_materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	icon_state = "adv_capacitor"
	rating = 2
	energy_rating = 3

TYPEINFO_DEF(/obj/item/stock_parts/scanning_module/adv)
	default_materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "adv_scan_module"
	rating = 2
	energy_rating = 3

TYPEINFO_DEF(/obj/item/stock_parts/manipulator/nano)
	default_materials = list(/datum/material/iron=30)

/obj/item/stock_parts/manipulator/nano
	name = "nano-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "nano_mani"
	rating = 2
	energy_rating = 3

TYPEINFO_DEF(/obj/item/stock_parts/micro_laser/high)
	default_materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "high_micro_laser"
	rating = 2
	energy_rating = 3

TYPEINFO_DEF(/obj/item/stock_parts/matter_bin/adv)
	default_materials = list(/datum/material/iron=80)

/obj/item/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = "A container designed to hold compressed matter awaiting reconstruction."
	icon_state = "advanced_matter_bin"
	rating = 2
	energy_rating = 3

//Rating 3

TYPEINFO_DEF(/obj/item/stock_parts/capacitor/super)
	default_materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/capacitor/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "super_capacitor"
	rating = 3
	energy_rating = 5

TYPEINFO_DEF(/obj/item/stock_parts/scanning_module/phasic)
	default_materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/scanning_module/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "super_scan_module"
	rating = 3
	energy_rating = 5

TYPEINFO_DEF(/obj/item/stock_parts/manipulator/pico)
	default_materials = list(/datum/material/iron=30)

/obj/item/stock_parts/manipulator/pico
	name = "pico-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "pico_mani"
	rating = 3
	energy_rating = 5

TYPEINFO_DEF(/obj/item/stock_parts/micro_laser/ultra)
	default_materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/micro_laser/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	desc = "A tiny laser used in certain devices."
	rating = 3
	energy_rating = 5

TYPEINFO_DEF(/obj/item/stock_parts/matter_bin/super)
	default_materials = list(/datum/material/iron=80)

/obj/item/stock_parts/matter_bin/super
	name = "super matter bin"
	desc = "A container designed to hold compressed matter awaiting reconstruction."
	icon_state = "super_matter_bin"
	rating = 3
	energy_rating = 5

// Subspace stock parts

TYPEINFO_DEF(/obj/item/stock_parts/subspace/ansible)
	default_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = "A compact module capable of sensing extradimensional activity."

TYPEINFO_DEF(/obj/item/stock_parts/subspace/filter)
	default_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."

TYPEINFO_DEF(/obj/item/stock_parts/subspace/amplifier)
	default_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."

TYPEINFO_DEF(/obj/item/stock_parts/subspace/treatment)
	default_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."

TYPEINFO_DEF(/obj/item/stock_parts/subspace/analyzer)
	default_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."

TYPEINFO_DEF(/obj/item/stock_parts/subspace/crystal)
	default_materials = list(/datum/material/glass=50)

/obj/item/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = "A crystal made from pure glass used to transmit laser databursts to subspace."

TYPEINFO_DEF(/obj/item/stock_parts/subspace/transmitter)
	default_materials = list(/datum/material/iron=50)

/obj/item/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."

// Misc. Parts

TYPEINFO_DEF(/obj/item/stock_parts/card_reader)
	default_materials = list(/datum/material/iron=50, /datum/material/glass=10)

/obj/item/stock_parts/card_reader
	name = "card reader"
	icon_state = "card_reader"
	desc = "A small magnetic card reader, used for devices that take and transmit holocredits."

TYPEINFO_DEF(/obj/item/stock_parts/water_recycler)
	default_materials = list(/datum/material/plastic=200, /datum/material/iron=50)

/obj/item/stock_parts/water_recycler
	name = "water recycler"
	icon_state = "water_recycler"
	desc = "A chemical reclaimation component, which serves to re-accumulate and filter water over time."

/obj/item/research//Makes testing much less of a pain -Sieve
	name = "research"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	desc = "A debug item for research."
