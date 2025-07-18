//spears
TYPEINFO_DEF(/obj/item/spear)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	default_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)

/obj/item/spear
	icon_state = "spearglass0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."

	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

	force = 7
	force_wielded = 14
	throwforce = 15
	throw_speed = 1.5

	special_attack_type = /datum/special_attack/ranged_stab

	embedding = list("impact_pain_mult" = 2, "remove_pain_mult" = 4, "jostle_chance" = 2.5)
	armor_penetration = 10

	hitsound = 'sound/weapons/attack/flesh_stab.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	sharpness = SHARP_EDGED // i know the whole point of spears is that they're pointy, but edged is more devastating at the moment so
	max_integrity = 200

	var/war_cry = "AAAAARGH!!!"
	var/icon_prefix = "spearglass"

/obj/item/spear/Initialize(mapload)
	. = ..()
	icon_state_wielded = "[icon_prefix]1"
	AddComponent(/datum/component/butchering, 100, 70) //decent in a pinch, but pretty bad.
	AddComponent(/datum/component/jousting)
	update_appearance()

/obj/item/spear/update_icon_state()
	icon_state = "[icon_prefix]0"
	return ..()

/obj/item/spear/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in contents
	if(tip)
		if (istype(tip, /obj/item/shard/plasma))
			force = 8
			force_wielded = 16
			throwforce = 21
			icon_prefix = "spearplasma"
			icon_state_wielded = "[icon_prefix]1"

		else if (istype(tip, /obj/item/shard/titanium))
			force = 10
			force_wielded = 20
			throwforce = 21
			throw_range = 8
			throw_speed = 5
			icon_prefix = "speartitanium"
			icon_state_wielded = "[icon_prefix]1"

		else if (istype(tip, /obj/item/shard/plastitanium))
			force = 12
			force_wielded = 24
			throwforce = 22
			throw_range = 9
			throw_speed = 5
			icon_prefix = "spearplastitanium"
			icon_state_wielded = "[icon_prefix]1"
		update_appearance()
		parts_list -= tip
		qdel(tip)
	return ..()

/obj/item/spear/explosive
	name = "explosive lance"
	icon_state = "spearbomb0"
	base_icon_state = "spearbomb"
	icon_prefix = "spearbomb"

	force = 10

	var/obj/item/grenade/explosive = null

/obj/item/spear/explosive/Initialize(mapload)
	. = ..()
	set_explosive(new /obj/item/grenade/iedcasing/spawned()) //For admin-spawned explosive lances

/obj/item/spear/explosive/proc/set_explosive(obj/item/grenade/G)
	if(explosive)
		QDEL_NULL(explosive)
	G.forceMove(src)
	explosive = G
	desc = "A makeshift spear with [G] attached to it"

/obj/item/spear/explosive/CheckParts(list/parts_list)
	var/obj/item/grenade/G = locate() in parts_list
	if(G)
		var/obj/item/spear/lancePart = locate() in parts_list
		force = lancePart.force
		force_wielded = lancePart.force_wielded
		throwforce = lancePart.throwforce
		icon_prefix = lancePart.icon_prefix

		parts_list -= G
		parts_list -= lancePart
		set_explosive(G)

		qdel(lancePart)
	..()

/obj/item/spear/explosive/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("[war_cry]", forced="spear warcry")
	explosive.forceMove(user)
	explosive.detonate()
	user.gib()
	qdel(src)
	return BRUTELOSS

/obj/item/spear/explosive/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to set your war cry.")

/obj/item/spear/explosive/AltClick(mob/user)
	if(user.canUseTopic(src, USE_CLOSE))
		..()
		if(istype(user) && loc == user)
			var/input = tgui_input_text(user, "What do you want your war cry to be? You will shout it when you hit someone in melee.", "War Cry", max_length = 50)
			if(input)
				src.war_cry = input

/obj/item/spear/explosive/afterattack(atom/target, mob/user, list/modifiers)
	. = ..()
	if(!wielded || !ismovable(target))
		return
	if(target.resistance_flags & INDESTRUCTIBLE) //due to the lich incident of 2021, embedding grenades inside of indestructible structures is forbidden
		return

	if(ismob(target))
		var/mob/mob_target = target
		if(mob_target.status_flags & GODMODE) //no embedding grenade phylacteries inside of ghost poly either
			return

	if(iseffect(target)) //and no accidentally wasting your moment of glory on graffiti
		return

	user.say("[war_cry]", forced="spear warcry")
	explosive.forceMove(target)
	explosive.detonate(lanced_by=user)
	qdel(src)

//GREY TIDE
/obj/item/spear/grey_tide
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Mars security staff."
	attack_verb_continuous = list("gores")
	attack_verb_simple = list("gore")

	force = 15
	force_wielded = 25

/obj/item/spear/grey_tide/afterattack(atom/target, mob/living/user, list/modifiers)
	. = ..()

	user.faction |= "greytide([REF(user)])"

	if(!isliving(target))
		return

	var/mob/living/L = target
	if(istype (L, /mob/living/simple_animal/hostile/illusion))
		return

	if(!L.stat && prob(50))
		var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
		M.faction = user.faction.Copy()
		M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
		M.GiveTarget(L)

/*
 * Bone Spear
 */
/obj/item/spear/bonespear //Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon_state = "bone_spear0"
	base_icon_state = "bone_spear0"
	icon_prefix = "bone_spear"

	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."

	armor_penetration = 15 //Enhanced armor piercing

/*
 * Bamboo Spear
 */
/obj/item/spear/bamboospear //Blatant imitation of spear, but all natural. Also not valid for explosive modification.
	icon_state = "bamboo_spear0"
	base_icon_state = "bamboo_spear0"
	icon_prefix = "bamboo_spear"
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."

	force = 8
	force_wielded = 16
	throwforce = 22	//Better to throw

