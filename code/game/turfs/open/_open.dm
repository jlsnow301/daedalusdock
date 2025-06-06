/turf/open
	plane = FLOOR_PLANE
	initial_gas = OPENTURF_DEFAULT_ATMOS
	z_flags = Z_ATMOS_IN_UP|Z_ATMOS_OUT_UP

	///negative for faster, positive for slower
	var/slowdown = 0
	var/footstep = null
	var/barefootstep = null
	var/clawfootstep = null
	var/heavyfootstep = null

/turf/open/indestructible
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = TRUE
	simulated = FALSE

/turf/open/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/indestructible/singularity_act()
	return

/turf/open/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/open/indestructible/white
	icon_state = "white"

/turf/open/indestructible/dark
	icon_state = "darkfull"

/turf/open/indestructible/light
	icon_state = "light_on-1"

/turf/open/indestructible/permalube
	icon_state = "darkfull"

/turf/open/indestructible/permalube/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wet_floor, TURF_WET_LUBE, INFINITY, 0, INFINITY, TRUE)

/turf/open/indestructible/honk
	name = "bananium floor"
	icon_state = "bananium"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	var/sound = 'sound/effects/clownstep1.ogg'

/turf/open/indestructible/honk/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wet_floor, TURF_WET_SUPERLUBE, INFINITY, 0, INFINITY, TRUE)

/turf/open/indestructible/honk/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(ismob(arrived))
		playsound(src, sound, 50, TRUE)

/turf/open/indestructible/paper
	name = "notebook floor"
	desc = "A floor made of invulnerable notebook paper."
	icon_state = "paperfloor"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	tiled_dirt = FALSE

/turf/open/indestructible/binary
	name = "tear in the fabric of reality"
	can_atmos_pass = CANPASS_NEVER
	baseturfs = /turf/open/indestructible/binary
	icon_state = "binary"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null

/turf/open/indestructible/airblock
	icon_state = "bluespace"
	blocks_air = TRUE
	baseturfs = /turf/open/indestructible/airblock

/turf/open/GetHeatCapacity()
	. = unsafe_return_air().getHeatCapacity()

/turf/open/return_temperature()
	. = unsafe_return_air().temperature

/turf/open/TakeTemperature(temp)
	return_air().temperature += temp

/turf/open/proc/freeze_turf()
	for(var/obj/I in contents)
		if(!HAS_TRAIT(I, TRAIT_FROZEN) && !(I.obj_flags & FREEZE_PROOF))
			I.AddElement(/datum/element/frozen)

	for(var/mob/living/L in contents)
		if(L.bodytemperature <= 50)
			L.apply_status_effect(/datum/status_effect/freon)
	MakeSlippery(TURF_WET_PERMAFROST, 50)
	return TRUE

/turf/open/proc/water_vapor_gas_act()
	MakeSlippery(TURF_WET_WATER, min_wet_time = 100, wet_time_to_add = 50)

	for(var/mob/living/simple_animal/slime/M in src)
		M.apply_water()

	wash(CLEAN_WASH)
	for(var/atom/movable/movable_content as anything in src)
		if(ismopable(movable_content)) // Will have already been washed by the wash call above at this point.
			continue
		movable_content.wash(CLEAN_WASH)
	return TRUE

/turf/open/handle_slip(mob/living/carbon/slipper, knockdown_amount, obj/slippable, lube, paralyze_amount, force_drop)
	if(slipper.movement_type & (FLYING | FLOATING))
		return FALSE
	if(!has_gravity(src))
		return FALSE

	var/slide_distance = 4
	if(lube & SLIDE_ICE)
		// Ice slides only go 1 tile, this is so you will slip across ice until you reach a non-slip tile
		slide_distance = 1
	else if(HAS_TRAIT(slipper, TRAIT_NO_SLIP_SLIDE))
		// Stops sliding
		slide_distance = 0

	var/obj/buckled_obj
	if(slipper.buckled)
		if(!(lube & GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
			return FALSE
		buckled_obj = slipper.buckled
	else
		if(!(lube & SLIP_WHEN_CRAWLING) && (slipper.body_position == LYING_DOWN || !(slipper.status_flags & CANKNOCKDOWN))) // can't slip unbuckled mob if they're lying or can't fall.
			return FALSE
		if(slipper.m_intent == MOVE_INTENT_WALK && (lube & NO_SLIP_WHEN_WALKING))
			return FALSE

	if(!(lube & SLIDE_ICE))
		// Ice slides are intended to be combo'd so don't give the feedback
		to_chat(slipper, span_notice("You slipped[ slippable ? " on the [slippable.name]" : ""]!"))
		playsound(slipper.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)

	SEND_SIGNAL(slipper, COMSIG_ON_CARBON_SLIP)

	if(force_drop)
		for(var/obj/item/item in slipper.held_items)
			slipper.accident(item)

	var/olddir = slipper.dir
	slipper.moving_diagonally = 0 //If this was part of diagonal move slipping will stop it.
	if(lube & SLIDE_ICE)
		// They need to be kept upright to maintain the combo effect (So don't knockdown)
		slipper.Immobilize(1 SECONDS)
		slipper.incapacitate(1 SECONDS)
	else
		slipper.Knockdown(knockdown_amount)
		slipper.Paralyze(paralyze_amount)
		slipper.release_all_grabs()
		slipper.client?.give_award(/datum/award/achievement/slip, slipper)

	if(buckled_obj)
		buckled_obj.unbuckle_mob(slipper)
		// This is added onto the end so they slip "out of their chair" (one tile)
		lube |= SLIDE_ICE
		slide_distance = 1

	if(slide_distance)
		var/turf/target = get_ranged_target_turf(slipper, olddir, slide_distance)
		if(lube & SLIDE)
			slipper.AddComponent(/datum/component/force_move, target, TRUE)
		else if(lube & SLIDE_ICE)
			slipper.AddComponent(/datum/component/force_move, target, FALSE)//spinning would be bad for ice, fucks up the next dir
	return TRUE

/turf/open/proc/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent)
	AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)

/turf/open/proc/MakeDry(wet_setting = TURF_WET_WATER, immediate = FALSE, amount = INFINITY)
	SEND_SIGNAL(src, COMSIG_TURF_MAKE_DRY, wet_setting, immediate, amount)

/turf/open/get_dumping_location()
	return src

/turf/open/proc/ClearWet()//Nuclear option of immediately removing slipperyness from the tile instead of the natural drying over time
	qdel(GetComponent(/datum/component/wet_floor))

/// Builds with rods. This doesn't exist to be overriden, just to remove duplicate logic for turfs that want
/// To support floor tile creation
/// I'd make it a component, but one of these things is space. So no.
/turf/open/proc/build_with_rods(obj/item/stack/rods/used_rods, mob/user)
	var/obj/structure/lattice/catwalk_bait = locate(/obj/structure/lattice, src)
	var/obj/structure/lattice/catwalk/existing_catwalk = locate(/obj/structure/lattice/catwalk, src)
	if(existing_catwalk)
		to_chat(user, span_warning("There is already a catwalk here!"))
		return

	if(catwalk_bait)
		if(used_rods.use(1))
			qdel(catwalk_bait)
			to_chat(user, span_notice("You construct a catwalk."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/catwalk(src)
		else
			to_chat(user, span_warning("You need two rods to build a catwalk!"))
		return

	if(used_rods.use(1))
		to_chat(user, span_notice("You construct a lattice."))
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		new /obj/structure/lattice(src)
	else
		to_chat(user, span_warning("You need one rod to build a lattice."))

/// Very similar to build_with_rods, this exists to allow consistent behavior between different types in terms of how
/// Building floors works
/turf/open/proc/build_with_floor_tiles(obj/item/stack/tile/iron/used_tiles, user)
	var/obj/structure/lattice/soon_to_be_floor = locate(/obj/structure/lattice, src)
	if(!soon_to_be_floor)
		to_chat(user, span_warning("The plating is going to need some support! Place metal rods first."))
		return
	if(!used_tiles.use(1))
		to_chat(user, span_warning("You need one floor tile to build a floor!"))
		return

	qdel(soon_to_be_floor)
	playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
	to_chat(user, span_notice("You build a floor."))
	PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)

/// Used primarily for heretic's temple. To be removed.
/turf/open/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturfs = /turf/open/indestructible/necropolis
	initial_gas = OPENTURF_LOW_PRESSURE
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	tiled_dirt = FALSE

/turf/open/indestructible/necropolis/Initialize(mapload)
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/open/indestructible/necropolis/air
	initial_gas = OPENTURF_DEFAULT_ATMOS
