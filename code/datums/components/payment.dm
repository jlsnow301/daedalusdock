
/**
 * Handles simple payment operations where the cost of the object in question doesn't change.
 *
 * What this is useful for:
 * Basic forms of vending.
 * Objects that can drain the owner's money linearly.
 * What this is not useful for:
 * Things where the seller may want to fluxuate the price of the object.
 * Improving standardizing every form of payment handing, as some custom handling is specific to that object.
 **/
/datum/component/payment
	dupe_mode = COMPONENT_DUPE_UNIQUE ///NO OVERRIDING TO CHEESE BOUNTIES
	///Standardized of operation.
	var/cost = 10
	///Flavor style for handling cash (Friendly? Hostile? etc.)
	var/transaction_style = "Clinical"
	///Who's getting paid?
	var/datum/bank_account/target_acc

/datum/component/payment/Initialize(_cost, _target, _style)
	target_acc = _target
	if(!target_acc)
		target_acc = SSeconomy.station_master

	cost = _cost
	transaction_style = _style
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE, PROC_REF(attempt_charge))
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE, PROC_REF(change_cost))

/datum/component/payment/proc/attempt_charge(datum/source, atom/movable/target, extra_fees = 0)
	SIGNAL_HANDLER

	if(!cost) //In case a free variant of anything is made it'll skip charging anyone.
		return
	if(!ismob(target))
		return COMPONENT_OBJ_CANCEL_CHARGE
	var/mob/living/user = target
	var/obj/item/card/id/card
	if(istype(user))
		card = user.get_idcard(TRUE)
	if(!card)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("ID not detected, sorry [user]!"))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("WHERE IS YOUR GOD DAMN CARD! GOD DAMNIT!"))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID card not present. Aborting."))
		return COMPONENT_OBJ_CANCEL_CHARGE
	if(!card.registered_account)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("There's no account detected on your ID, how mysterious!"))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("ARE YOU JOKING. YOU DON'T HAVE A BANK ACCOUNT ON YOUR ID YOU IDIOT."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID Card lacks a bank account. Aborting."))
		return COMPONENT_OBJ_CANCEL_CHARGE
	if(!(card.registered_account.has_money(cost + extra_fees)))
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("I'm so sorry... You don't seem to have enough money."))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("YOU MORON. YOU ABSOLUTE BAFOON. YOU INSUFFERABLE TOOL. YOU ARE POOR."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID Card lacks funds. Aborting."))
		return COMPONENT_OBJ_CANCEL_CHARGE
	target_acc.transfer_money(card.registered_account, cost + extra_fees)
	card.registered_account.bank_card_talk("[cost + extra_fees] marks deducted from your account.")
	playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)
	SSeconomy.track_purchase(card.registered_account, cost + extra_fees, parent)

/datum/component/payment/proc/change_cost(datum/source, new_cost)
	SIGNAL_HANDLER
	if(!isnum(new_cost))
		CRASH("change_cost called with variable new_cost as not a number.")
	cost = new_cost
