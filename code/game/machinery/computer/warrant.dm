/obj/machinery/computer/warrant//TODO:SANITY
	name = "security warrant console"
	desc = "Used to view crewmember security records"
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/warrant
	light_color = COLOR_SOFT_RED
	var/screen = null
	var/datum/data/record/security/current = null

/obj/machinery/computer/warrant/ui_interact(mob/user)
	. = ..()

	var/list/dat = list("Logged in as: ")
	if(authenticated)
		dat += {"<a href='?src=[REF(src)];choice=Logout'>[authenticated]</a><hr>"}
		if(current)
			var/background
			var/notice = ""
			switch(current.fields[DATACORE_CRIMINAL_STATUS])
				if(CRIMINAL_WANTED)
					background = "background-color:#990000;"
					notice = "<br>**REPORT TO THE BRIG**"
				if(CRIMINAL_INCARCERATED)
					background = "background-color:#CD6500;"
				if(CRIMINAL_SUSPECT)
					background = "background-color:#CD6500;"
				if(CRIMINAL_PAROLE)
					background = "background-color:#CD6500;"
				if(CRIMINAL_DISCHARGED)
					background = "background-color:#006699;"
				if(CRIMINAL_NONE)
					background = "background-color:#4F7529;"
				if("")
					background = "''" //"'background-color:#FFFFFF;'"
			dat += "<font size='4'><b>Warrant Data</b></font>"
			dat += {"<table>
			<tr><td>Name:</td><td>&nbsp;[current.fields[DATACORE_NAME]]&nbsp;</td></tr>
			<tr><td>ID:</td><td>&nbsp;[current.fields[DATACORE_ID]]&nbsp;</td></tr>
			</table>"}
			dat += {"Criminal Status:<br>
			<div style='[background] padding: 3px; text-align: center;'>
			<strong>[current.fields[DATACORE_CRIMINAL_STATUS]][notice]</strong>
			</div>"}

			dat += "<br><br>Citations:"

			dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
			<tr>
			<th>Crime</th>
			<th>Fine</th>
			<th>Author</th>
			<th>Time Added</th>
			<th>Amount Due</th>
			<th>Make Payment</th>
			</tr>"}
			for(var/datum/data/crime/c in current.fields[DATACORE_CITATIONS])
				var/owed = c.fine - c.paid
				dat += {"<tr><td>[c.crimeName]</td>
				<td>[c.fine] FM</td>
				<td>[c.author]</td>
				<td>[c.time]</td>"}
				if(owed > 0)
					dat += {"<td>[owed] FM</td>
					<td><A href='?src=[REF(src)];choice=Pay;field=citation_pay;cdataid=[c.dataId]'>\[Pay\]</A></td>"}
				else
					dat += "<td colspan='2'>All Paid Off</td>"
				dat += "</tr>"
			dat += "</table>"

			dat += "<br>Crimes:"
			dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
			<tr>
			<th>Crime</th>
			<th>Details</th>
			<th>Author</th>
			<th>Time Added</th>
			</tr>"}
			for(var/datum/data/crime/c in current.fields[DATACORE_CRIMES])
				dat += {"<tr><td>[c.crimeName]</td>
				<td>[c.crimeDetails]</td>
				<td>[c.author]</td>
				<td>[c.time]</td>
				</tr>"}
			dat += "</table>"
		else
			dat += {"<span>** No security record found for this ID **</span>"}
	else
		dat += {"<a href='?src=[REF(src)];choice=Login'>------------</a><hr>"}

	var/datum/browser/popup = new(user, "warrant", "Security Warrant Console", 600, 400)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/computer/warrant/Topic(href, href_list)
	if(..())
		return
	var/mob/M = usr
	switch(href_list["choice"])
		if("Login")
			if(isliving(M))
				var/mob/living/L = M
				var/obj/item/card/id/scan = L.get_idcard(TRUE)
				if (!scan)
					say("You do not have a registered ID!")
					return
				authenticated = scan.registered_name
				if(authenticated)
					current = SSdatacore.get_record_by_name(authenticated, DATACORE_RECORDS_SECURITY)
					playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)

		if("Logout")
			current = null
			authenticated = null
			playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)

		if("Pay")
			for(var/datum/data/crime/p in current.fields[DATACORE_CITATIONS])
				if(p.dataId == text2num(href_list["cdataid"]))
					var/obj/item/stack/spacecash/C = M.is_holding_item_of_type(/obj/item/stack/spacecash)
					if(istype(C))
						var/pay = C.get_item_credit_value()
						if(!pay)
							to_chat(M, span_warning("[C] doesn't seem to be worth anything!"))
						else
							var/diff = p.fine - p.paid
							current.pay_citation(text2num(href_list["cdataid"]), pay)
							to_chat(M, span_notice("You have paid [pay] credit\s towards your fine."))
							if (pay == diff || pay > diff || pay >= diff)
								investigate_log("Citation Paid off: <strong>[p.crimeName]</strong> Fine: [p.fine] | Paid off by [key_name(usr)]", INVESTIGATE_RECORDS)
								to_chat(M, span_notice("The fine has been paid in full."))

								var/overflow = pay - diff
								if(overflow)
									SSeconomy.spawn_ones_for_amount(overflow, drop_location())
							SSblackbox.ReportCitation(text2num(href_list["cdataid"]),"","","","", 0, pay)
							qdel(C)
							playsound(src, SFX_TERMINAL_TYPE, 25, FALSE)
					else
						to_chat(M, span_warning("Fines can only be paid with holochips!"))
	updateUsrDialog()
	add_fingerprint(M)
