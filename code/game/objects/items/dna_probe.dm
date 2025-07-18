#define DNA_PROBE_SCAN_PLANTS (1<<0)
#define DNA_PROBE_SCAN_ANIMALS (1<<1)
#define DNA_PROBE_SCAN_HUMANS (1<<2)

/**
 * DNA Probe
 *
 * Used for scanning DNA, and can be uploaded to a DNA vault.
 */

/obj/item/dna_probe
	name = "DNA Sampler"
	desc = "Can be used to take chemical and genetic samples of pretty much anything."
	icon = 'icons/obj/syringe.dmi'
	inhand_icon_state = "sampler"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "sampler"
	item_flags = NOBLUDGEON
	///Whether we have Carp DNA
	var/carp_dna_loaded = FALSE
	///What sources of DNA this sampler can extract from.
	var/allowed_scans = DNA_PROBE_SCAN_PLANTS | DNA_PROBE_SCAN_ANIMALS | DNA_PROBE_SCAN_HUMANS
	///List of all Animal DNA scanned with this sampler.
	var/list/stored_dna_animal = list()
	///List of all Plant DNA scanned with this sampler.
	var/list/stored_dna_plants = list()
	///List of all Human DNA scanned with this sampler.
	var/list/stored_dna_human = list()

/obj/item/dna_probe/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/atom/target = interacting_with // Yes i am supremely lazy

	if(allowed_scans & DNA_PROBE_SCAN_ANIMALS)
		var/static/list/non_simple_animals = typecacheof(list(/mob/living/carbon/alien))
		if(isanimal_or_basicmob(target) || is_type_in_typecache(target, non_simple_animals) || ismonkey(target))
			if(istype(target, /mob/living/simple_animal/hostile/carp))
				carp_dna_loaded = TRUE
			var/mob/living/living_target = target
			if(stored_dna_animal[living_target.type])
				to_chat(user, span_alert("Animal data already present in local storage."))
				return
			if(!(living_target.mob_biotypes & MOB_ORGANIC))
				to_chat(user, span_alert("No compatible DNA detected."))
				return
			stored_dna_animal[living_target.type] = TRUE
			to_chat(user, span_notice("Animal data added to local storage."))
			return ITEM_INTERACT_SUCCESS

	if((allowed_scans & DNA_PROBE_SCAN_HUMANS) && ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(stored_dna_human[human_target.dna.unique_identity])
			to_chat(user, span_notice("Humanoid data already present in local storage."))
			return
		if(!(human_target.mob_biotypes & MOB_ORGANIC))
			to_chat(user, span_alert("No compatible DNA detected."))
			return
		stored_dna_human[human_target.dna.unique_identity] = TRUE
		to_chat(user, span_notice("Humanoid data added to local storage."))
		return ITEM_INTERACT_SUCCESS

#define CARP_MIX_DNA_TIMER (15 SECONDS)

///Used for scanning carps, and then turning yourself into one.
/obj/item/dna_probe/carp_scanner
	name = "Carp DNA Sampler"
	desc = "Can be used to take chemical and genetic samples of animals."
	allowed_scans = DNA_PROBE_SCAN_ANIMALS

/obj/item/dna_probe/carp_scanner/examine_more(mob/user)
	. = ..()
	if(user.mind.has_antag_datum(/datum/antagonist/traitor))
		. = list(span_notice("Using this on a Space Carp will harvest its DNA. Use it in-hand once complete to mutate it with yourself."))

/obj/item/dna_probe/carp_scanner/attack_self(mob/user, modifiers)
	. = ..()
	if(!is_special_character(user))
		return
	if(!carp_dna_loaded)
		to_chat(user, span_notice("Space carp DNA is required to use the self-mutation mechanism!"))
		return
	to_chat(user, span_notice("You pull out the needle from [src] and flip the switch, and start injecting yourself with it."))
	if(!do_after(user, time = CARP_MIX_DNA_TIMER))
		return
	var/mob/living/simple_animal/hostile/space_dragon/new_dragon = user.change_mob_type(/mob/living/simple_animal/hostile/space_dragon, location = loc, delete_old_mob = TRUE)
	new_dragon.permanant_empower()
	priority_announce("A large organic energy flux has been recorded near of [station_name()], please stand-by.", FLAVOR_ANANKE_STATION, send_to_newscaster = TRUE)
	qdel(src)

#undef CARP_MIX_DNA_TIMER

#undef DNA_PROBE_SCAN_PLANTS
#undef DNA_PROBE_SCAN_ANIMALS
#undef DNA_PROBE_SCAN_HUMANS
