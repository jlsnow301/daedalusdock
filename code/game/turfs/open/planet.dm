/turf/open/misc/dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	base_icon_state = "dirt"
	baseturfs = /turf/open/chasm/jungle
	initial_gas = OPENTURF_LOW_PRESSURE

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/misc/dirt/dark
	icon_state = "greenerdirt"
	base_icon_state = "greenerdirt"

/turf/open/misc/dirt/jungle
	slowdown = 0.5
	initial_gas = OPENTURF_DEFAULT_ATMOS

/turf/open/misc/dirt/jungle/dark
	icon_state = "greenerdirt"
	base_icon_state = "greenerdirt"

/turf/open/misc/dirt/jungle/wasteland //Like a more fun version of living in Arizona.
	name = "cracked earth"
	desc = "Looks a bit dry."
	icon = 'icons/turf/floors.dmi'
	icon_state = "wasteland"
	base_icon_state = "wasteland"
	slowdown = 1
	var/floor_variance = 15

/turf/open/misc/dirt/jungle/wasteland/Initialize(mapload)
	.=..()
	if(prob(floor_variance))
		icon_state = "[initial(icon_state)][rand(0,12)]"

/turf/open/misc/dirt/jungle/wasteland/break_tile()
	. = ..()
	icon_state = "[initial(icon_state)]0"

/turf/open/misc/grass/jungle
	name = "jungle grass"
	initial_gas = OPENTURF_DEFAULT_ATMOS

	baseturfs = /turf/open/misc/dirt
	desc = "Greener on the other side."
	icon_state = "junglegrass"
	base_icon_state = "junglegrass"
	smooth_icon = 'icons/turf/floors/junglegrass.dmi'

/turf/closed/mineral/random/jungle
	mineralSpawnChanceList = list(/datum/ore/uranium = 5, /datum/ore/diamond = 1, /datum/ore/gold = 10,
		/datum/ore/silver = 12, /datum/ore/plasma = 20, /datum/ore/iron = 40, /datum/ore/titanium = 11,
		/datum/ore/bluespace_crystal = 1)
	baseturfs = /turf/open/misc/dirt/dark
