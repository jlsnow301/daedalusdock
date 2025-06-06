/obj/docking_port/mobile/arrivals
	name = "arrivals shuttle"
	id = "arrivals"

	dwidth = 3
	width = 7
	height = 15
	dir = WEST
	port_direction = SOUTH

	callTime = INFINITY
	ignitionTime = 50

	movement_force = list("KNOCKDOWN" = 3, "THROW" = 0)

	bolt_doors = TRUE

	var/sound_played
	var/damaged //too damaged to undock?
	var/list/areas //areas in our shuttle
	var/list/on_arrival_callbacks //people coming in that we have to announce
	var/obj/machinery/requests_console/console
	var/force_depart = FALSE
	var/perma_docked = FALSE //highlander with RESPAWN??? OH GOD!!!
	var/obj/docking_port/stationary/target_dock  // for badminry

/obj/docking_port/mobile/arrivals/Initialize(mapload)
	. = ..()
	preferred_direction = dir
	return INITIALIZE_HINT_LATELOAD //for latejoin list

/obj/docking_port/mobile/arrivals/register()
	..()
	if(SSshuttle.arrivals)
		log_mapping("More than one arrivals docking_port placed on map! Ignoring duplicates.")
	SSshuttle.arrivals = src

/obj/docking_port/mobile/arrivals/LateInitialize()
	areas = list()

	var/list/new_latejoin = list()
	for(var/area/shuttle/arrival/A in GLOB.areas)
		areas += A

	for(var/obj/structure/chair/C as anything in INSTANCES_OF(/obj/structure/chair))
		if(get_area(C) in areas)
			new_latejoin += C

	if(!console)
		for(var/obj/machinery/requests_console/RQ as anything in INSTANCES_OF(/obj/machinery/requests_console))
			if(get_area(RQ) in areas)
				console = RQ
				break

	if(SSjob.latejoin_trackers.len)
		log_mapping("Map contains predefined latejoin spawn points and an arrivals shuttle. Using the arrivals shuttle.")

	if(!new_latejoin.len)
		log_mapping("Arrivals shuttle contains no chairs for spawn points. Reverting to latejoin landmarks.")
		if(!SSjob.latejoin_trackers.len)
			log_mapping("No latejoin landmarks exist. Players will spawn unbuckled on the shuttle.")
		return

	SSjob.latejoin_trackers = new_latejoin

/obj/docking_port/mobile/arrivals/check()
	. = ..()

	if(perma_docked)
		if(mode != SHUTTLE_CALL)
			sound_played = FALSE
			mode = SHUTTLE_IDLE
		else
			SendToStation()
		return

	if(damaged)
		if(!CheckTurfsPressure())
			damaged = FALSE
			if(console)
				console.say("Repairs complete, launching soon.")
		return

//If this proc is high on the profiler add a cooldown to the stuff after this line

	else if(CheckTurfsPressure())
		damaged = TRUE
		if(console)
			console.say("Alert, hull breach detected!")
		if (length(GLOB.announcement_systems))
			var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
			if(!QDELETED(announcer))
				announcer.announce("ARRIVALS_BROKEN", channels = list())
		if(mode != SHUTTLE_CALL)
			sound_played = FALSE
			mode = SHUTTLE_IDLE
		else
			SendToStation()
		return

	var/found_awake = PersonCheck() || NukeDiskCheck()
	if(mode == SHUTTLE_CALL)
		if(found_awake)
			SendToStation()
	else if(mode == SHUTTLE_IGNITING)
		if(found_awake && !force_depart)
			mode = SHUTTLE_IDLE
			sound_played = FALSE
		else if(!sound_played)
			hyperspace_sound(HYPERSPACE_WARMUP, areas)
			sound_played = TRUE
	else if(!found_awake)
		Launch(FALSE)

/obj/docking_port/mobile/arrivals/proc/CheckTurfsPressure()
	for(var/I in SSjob.latejoin_trackers)
		var/turf/open/T = get_turf(I)
		var/pressure = T.unsafe_return_air().returnPressure()
		if(pressure < HAZARD_LOW_PRESSURE || pressure > HAZARD_HIGH_PRESSURE) //simple safety check
			return TRUE
	return FALSE

/obj/docking_port/mobile/arrivals/proc/PersonCheck()
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((get_area(M) in areas) && M.stat != DEAD)
			if(!iscameramob(M))
				return TRUE
			var/mob/camera/C = M
			if(C.move_on_shuttle)
				return TRUE
	return FALSE

/obj/docking_port/mobile/arrivals/proc/NukeDiskCheck()
	for (var/obj/item/disk/nuclear/N in SSpoints_of_interest.real_nuclear_disks)
		if (get_area(N) in areas)
			return TRUE
	return FALSE

/obj/docking_port/mobile/arrivals/proc/SendToStation()
	var/dockTime = CONFIG_GET(number/arrivals_shuttle_dock_window)
	var/announce_time = max(dockTime - 8 SECONDS, 0) //Ideally it's played around 8 seconds before dock, it sounds the nicest
	if(mode == SHUTTLE_CALL && timeLeft(1) > dockTime)
		if(console)
			spawn(announce_time)
				console.say(damaged ? "Initiating emergency docking for repairs!" : "Now approaching: [station_name()].")

		hyperspace_sound(HYPERSPACE_LAUNCH, areas) //for the new guy
		setTimer(dockTime)

/obj/docking_port/mobile/arrivals/perform_dock(obj/docking_port/stationary/S1, movement_direction, force)
	. = ..()
	var/docked = S1 == assigned_transit
	sound_played = FALSE
	if(docked) //about to launch
		if(!force_depart)
			var/cancel_reason
			if(PersonCheck())
				cancel_reason = "lifeform dectected on board"
			else if(NukeDiskCheck())
				cancel_reason = "critical station device detected on board"
			if(cancel_reason)
				mode = SHUTTLE_IDLE
				if(console)
					console.say("Launch cancelled, [cancel_reason].")
				return
		force_depart = FALSE

	. = ..()

	if(!. && !docked && !damaged)
		if(console)
			console.say("Welcome to [station_name()], have a safe and productive day!")
			playsound(console, 'sound/voice/ApproachingDaedalus.ogg', 50, FALSE, extrarange = 4)

		for(var/datum/callback/C in on_arrival_callbacks)
			C.InvokeAsync()
		LAZYCLEARLIST(on_arrival_callbacks)

/obj/docking_port/mobile/arrivals/check_effects()
	..()
	if(mode == SHUTTLE_CALL && !sound_played && timeLeft(1) <= HYPERSPACE_END_TIME)
		sound_played = TRUE
		hyperspace_sound(HYPERSPACE_END, areas)

/obj/docking_port/mobile/arrivals/canDock(obj/docking_port/stationary/S)
	. = ..()
	if(. == SHUTTLE_ALREADY_DOCKED)
		. = SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/arrivals/proc/Launch(pickingup)
	if(pickingup)
		force_depart = TRUE
	if(mode == SHUTTLE_IDLE)
		if(console)
			console.say(pickingup ? "Departing for new employee pickup." : "Shuttle departing.")
		var/obj/docking_port/stationary/target = target_dock
		if(QDELETED(target))
			target = SSshuttle.getDock("arrivals_stationary")
		request(target) //we will intentionally never return SHUTTLE_ALREADY_DOCKED

/obj/docking_port/mobile/arrivals/proc/RequireUndocked(mob/user)
	if(mode == SHUTTLE_CALL || damaged)
		return

	if(PersonCheck() || NukeDiskCheck())
		to_chat(user, span_notice(span_big("The shuttle is currently dropping off crewmembers. It will leave momentarily.")))
		for(var/i in 1 to 3)
			var/grace = world.time + 5 SECONDS
			console?.say("Please exit the shuttle so it may depart.")
			if(!(PersonCheck() || NukeDiskCheck()))
				break
			while(grace > world.time)
				stoplag()

	to_chat(user, span_notice("The transfer shuttle is now arriving..."))

	Launch(TRUE)

	while(mode != SHUTTLE_CALL && !damaged)
		stoplag()

/**
 * Queues an announcement arrival.
 *
 * Arguments:
 * * mob - The arriving mob.
 * * rank - The job of the arriving mob.
 */
/obj/docking_port/mobile/arrivals/proc/QueueAnnounce(mob, rank)
	if(mode != SHUTTLE_CALL)
		announce_arrival(mob, rank)
	else
		OnDock(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(announce_arrival), mob, rank))

/// Add a callback to execute when the shuttle is not in transit.
/obj/docking_port/mobile/arrivals/proc/OnDock(datum/callback/cb)
	if(mode != SHUTTLE_CALL)
		cb.InvokeAsync()
	else
		LAZYADD(on_arrival_callbacks, cb)

/obj/docking_port/mobile/arrivals/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, perma_docked))
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("arrivals shuttle", "[var_value ? "stopped" : "started"]"))
	return ..()
