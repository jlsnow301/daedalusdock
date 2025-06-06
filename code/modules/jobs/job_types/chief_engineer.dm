/datum/job/chief_engineer
	title = JOB_CHIEF_ENGINEER
	description = "Coordinate engineering, ensure equipment doesn't get stolen, \
		make sure the Supermatter doesn't blow up, maintain telecommunications."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	head_announce = list(RADIO_CHANNEL_ENGINEERING)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	selection_color = "#7f6e2c"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_ENGINEERING
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/daedalus,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/ce,
		),
	)

	departments_list = list(
		/datum/job_department/engineering,
		/datum/job_department/company_leader,
	)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_ENG

	liver_traits = list(TRAIT_ENGINEER_METABOLISM, TRAIT_ROYAL_METABOLISM)

	family_heirlooms = list(/obj/item/clothing/head/hardhat/white, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)

	mail_goodies = list(
		/obj/item/food/cracker = 25, //you know. for poly
		/obj/item/stack/sheet/mineral/diamond = 15,
		/obj/item/stack/sheet/mineral/uranium/five = 15,
		/obj/item/stack/sheet/mineral/plasma/five = 15,
		/obj/item/stack/sheet/mineral/gold = 15,
		/obj/effect/spawner/random/engineering/tool_advanced = 3
	)
	rpg_title = "Head Crystallomancer"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

	voice_of_god_power = 1.4 //Command staff has authority


/datum/job/chief_engineer/get_captaincy_announcement(mob/living/captain)
	return "Due to staffing shortages, newly promoted Acting Captain [captain.real_name] on deck!"


/datum/outfit/job/ce
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	id = /obj/item/card/id/advanced/silver
	id_template = /datum/access_template/job/chief_engineer
	uniform = /obj/item/clothing/under/rank/engineering/chief_engineer
	backpack_contents = list(
		/obj/item/assembly/flash/handheld
	)
	belt = /obj/item/storage/belt/utility/chief/full
	ears = /obj/item/radio/headset/heads/ce
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/hardhat/white
	shoes = /obj/item/clothing/shoes/sneakers/brown
	l_pocket = /obj/item/modular_computer/tablet/pda/heads/ce

	back = /obj/item/storage/backpack/industrial

	box = /obj/item/storage/box/survival/engineer
	chameleon_extras = /obj/item/stamp/ce
	skillchips = list(/obj/item/skillchip/job/engineer)
	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/ce/mod
	name = "Chief Engineer (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/advanced
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/color/yellow
	head = null
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/magboots/advance
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null
