// Knife Template, should not appear in game normaly //
TYPEINFO_DEF(/obj/item/knife)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)
	default_materials = list(/datum/material/iron=12000)

/obj/item/knife
	name = "knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	inhand_icon_state = "knife"
	worn_icon_state = "knife"
	desc = "The original knife, it is said that all other knives are only copies of this one."
	flags_1 = CONDUCT_1
	force = 15
	w_class = WEIGHT_CLASS_SMALL

	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'

	throwforce = 10
	throw_speed = 1.5
	throw_range = 6

	attack_verb_continuous = list("slashes",, "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

	sharpness = SHARP_EDGED
	special_attack_type = /datum/special_attack/basic/stab

	var/bayonet = FALSE //Can this be attached to a gun?
	tool_behaviour = TOOL_KNIFE

/obj/item/knife/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)
	set_butchering()

///Adds the butchering component, used to override stats for special cases
/obj/item/knife/proc/set_butchering()
	AddComponent(/datum/component/butchering, 80 - force, 100, force - 10) //bonus chance increases depending on force

/obj/item/knife/suicide_act(mob/user)
	user.visible_message(pick(span_suicide("[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."), \
						span_suicide("[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."), \
						span_suicide("[user] is slitting [user.p_their()] stomach open with the [src.name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
	return (BRUTELOSS)
/////

/obj/item/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "bone_blade"
	inhand_icon_state = "bone_blade"
	worn_icon_state = "bone_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/knife/bloodletter
	name = "bloodletter"
	desc = "An occult looking dagger that is cold to the touch. Somehow, the flawless orb on the pommel is made entirely of liquid blood."
	icon = 'icons/obj/ice_moon/artifacts.dmi'
	icon_state = "bloodletter"
	worn_icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL
	/// Bleed stacks applied when an organic mob target is hit
	var/bleed_stacks_per_hit = 3

/obj/item/knife/bloodletter/afterattack(atom/target, mob/user, list/modifiers)
	. = ..()
	if(!isliving(target))
		return

	var/mob/living/M = target
	if(!(M.mob_biotypes & MOB_ORGANIC))
		return

	var/datum/status_effect/stacking/saw_bleed/bloodletting/B = M.has_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting)
	if(!B)
		M.apply_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting, bleed_stacks_per_hit)
	else
		B.add_stacks(bleed_stacks_per_hit)

TYPEINFO_DEF(/obj/item/knife/butcher)
	default_materials = list(/datum/material/iron=18000)

/obj/item/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	inhand_icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown by-products."
	flags_1 = CONDUCT_1
	force = 15
	throwforce = 10
	attack_verb_continuous = list("cleaves", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("cleave", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = PAYCHECK_ASSISTANT * 5

/obj/item/knife/hunting
	name = "hunting knife"
	desc = "Despite its name, it's mainly used for cutting meat from dead prey rather than actual hunting."
	inhand_icon_state = "huntingknife"
	icon_state = "huntingknife"

/obj/item/knife/hunting/set_butchering()
	AddComponent(/datum/component/butchering, 80 - force, 100, force + 10)

/obj/item/knife/combat
	name = "combat knife"
	icon_state = "buckknife"
	desc = "A military combat utility survival knife."
	embedding = list("pain_mult" = 4, "embed_chance" = 65, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE)
	force = 20
	throwforce = 20
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "cut")
	bayonet = TRUE

/obj/item/knife/combat/survival
	name = "survival knife"
	icon_state = "survivalknife"
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15
	bayonet = TRUE

TYPEINFO_DEF(/obj/item/knife/combat/bone)
	default_materials = null

/obj/item/knife/combat/bone
	name = "bone dagger"
	inhand_icon_state = "bone_dagger"
	icon_state = "bone_dagger"
	worn_icon_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A sharpened bone. The bare minimum in survival."
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	force = 15
	throwforce = 15

/obj/item/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife_cyborg"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."

TYPEINFO_DEF(/obj/item/knife/shiv)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	default_materials = list(/datum/material/glass=400)

/obj/item/knife/shiv
	name = "glass shiv"
	icon = 'icons/obj/shards.dmi'
	icon_state = "shiv"
	inhand_icon_state = "shiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A makeshift glass shiv."
	force = 8
	throwforce = 12
	attack_verb_continuous = list("shanks", "shivs")
	attack_verb_simple = list("shank", "shiv")

/obj/item/knife/shiv/CheckParts(list/parts_list)
	var/obj/item/shard/shard = locate() in contents
	if(shard)
		if (istype(shard, /obj/item/shard/plasma))
			force = 9
			throwforce = 13
			icon_state = "plasmashiv"
			inhand_icon_state = "plasmashiv"
			set_custom_materials(list(/datum/material/glass=400, /datum/material/plasma=200))
		else if (istype(shard, /obj/item/shard/titanium))
			throwforce = 14
			throw_range = 7
			icon_state = "titaniumshiv"
			inhand_icon_state = "titaniumshiv"
			set_custom_materials(list(/datum/material/glass=400, /datum/material/titanium=200))
		else if (istype(shard, /obj/item/shard/plastitanium))
			force = 10
			throwforce = 15
			throw_speed = 1.5
			throw_range = 8
			icon_state = "plastitaniumshiv"
			inhand_icon_state = "plastitaniumshiv"
			set_custom_materials(list(/datum/material/glass=400, /datum/material/alloy/plastitanium=200))
		update_appearance()
		parts_list -= shard
		qdel(shard)
	return ..()

TYPEINFO_DEF(/obj/item/knife/shiv/carrot)
	default_materials = null

/obj/item/knife/shiv/carrot
	name = "carrot shiv"
	icon_state = "carrotshiv"
	inhand_icon_state = "carrotshiv"
	icon = 'icons/obj/kitchen.dmi'
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."

/obj/item/knife/shiv/carrot/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] forcefully drives \the [src] into [user.p_their()] eye! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS
