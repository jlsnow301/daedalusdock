
/obj/item/clothing/head/beekeeper_head
	name = "beekeeper hat"
	desc = "Keeps the lil buzzing buggers out of your eyes."
	icon_state = "beekeeper"
	inhand_icon_state = "beekeeper"
	clothing_flags = THICKMATERIAL | SNUG_FIT


/obj/item/clothing/suit/beekeeper_suit
	name = "beekeeper suit"
	desc = "Keeps the lil buzzing buggers away from your squishy bits."
	icon_state = "beekeeper"
	inhand_icon_state = "beekeeper"
	clothing_flags = THICKMATERIAL
	allowed = list(
		/obj/item/melee/flyswatter,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/plant_analyzer,
		/obj/item/seeds,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/hatchet,
		/obj/item/storage/bag/plants
	)
