extends Node

@export var mn: SpinBox
@export var amn: OptionButton
@export var qrn: QRCodeRect


enum MatchMenu {
	AUTO,
	TRANSITION,
	WHO_GOT_FIRST,
	RED_SHIFT_1,
	BLUE_SHIFT_1,
	RED_SHIFT_2,
	BLUE_SHIFT_2,
	ENDGAME,
	POST_GAME
}

func _ready():
	Global.load_config()
	mn.value = Global.current_match - 1
	match Global.config["alliance_member"]:
		"red_1": amn.selected = 0
		"red_2": amn.selected = 1
		"red_3": amn.selected = 2
		"blue_1": amn.selected = 3
		"blue_2": amn.selected = 4
		"blue_3": amn.selected = 5
	make_qr()

func woah_to_qrs(s, m, am): #stats, match number, alliance_member
	var scouter = Global.rotations[Global.matches[m]["rotation"] - 1][am]
	var match_number = m
	var robot = ""
	match am:
		"red_1": robot = "R1"
		"red_2": robot = "R2"
		"red_3": robot = "R3"
		"blue_1": robot = "B1"
		"blue_2": robot = "B2"
		"blue_3": robot = "B3"
	var team_num = int(Global.matches[m][am])
	
	
	
	var preloaded_8 = 8
	var afuel = max(s[MatchMenu.AUTO]["scored"] - 8, 0) # func means find me which one is bigger not find the bigger number
	var aclimb = bool(s[MatchMenu.AUTO]["climb"])
	
	
	
	var tfuel = s[MatchMenu.TRANSITION]["scored"]
	var shift = s[MatchMenu.TRANSITION]["first_shift"]
	
	
	var a1fuel
	var a1role
	if am.begins_with("red"):
		print(s[MatchMenu.RED_SHIFT_1])
		a1fuel = s[MatchMenu.RED_SHIFT_1]["scored"]
		var a1shut = s[MatchMenu.RED_SHIFT_1]["shuttled"] + s[MatchMenu.BLUE_SHIFT_1]["shuttled"] / 1.75 # should  be / 2 but this feels better
		var a1def = s[MatchMenu.RED_SHIFT_1]["defended"] + s[MatchMenu.BLUE_SHIFT_1]["defended"] * 7.5 # 15 points stopped per 2 seconds
		a1role = "o"
		if a1fuel < 10 and a1shut < 10 and a1def < 10:
			a1role = "x"
		else:
			match max(a1fuel,a1shut,a1def):
				a1fuel: a1role = "s"
				a1shut: a1role = "l"
				a1def: a1role = "d"
	else:
		a1fuel = s[MatchMenu.BLUE_SHIFT_1]["scored"]
		var a1shut = s[MatchMenu.RED_SHIFT_1]["shuttled"] + s[MatchMenu.BLUE_SHIFT_1]["shuttled"] / 1.75 # should  be / 2 but this feels better
		var a1def = s[MatchMenu.RED_SHIFT_1]["defended"] + s[MatchMenu.BLUE_SHIFT_1]["defended"] * 7.5 # 15 points stopped per 2 seconds
		a1role = "o"
		if a1fuel < 10 and a1shut < 10 and a1def < 10:
			a1role = "x"
		else:
			match max(a1fuel,a1shut,a1def):
				a1fuel: a1role = "s"
				a1shut: a1role = "l"
				a1def: a1role = "d"
	
	
	
	var a2fuel
	var a2role
	if am.begins_with("red"):
		a2fuel = s[MatchMenu.RED_SHIFT_1]["scored"]
		var a2shut = s[MatchMenu.RED_SHIFT_1]["shuttled"] + s[MatchMenu.BLUE_SHIFT_1]["shuttled"] / 1.75 # should  be / 2 but this feels better
		var a2def = s[MatchMenu.RED_SHIFT_1]["defended"] + s[MatchMenu.BLUE_SHIFT_1]["defended"] * 7.5 # 15 points stopped per 2 seconds
		a2role = "o"
		if a2fuel < 10 and a2shut < 10 and a2def < 10:
			a2role = "x"
		else:
			match max(a2fuel,a2shut,a2def):
				a2fuel: a2role = "s"
				a2shut: a2role = "l"
				a2def: a2role = "d"
	else:
		a2fuel = s[MatchMenu.BLUE_SHIFT_2]["scored"]
		var a2shut = s[MatchMenu.RED_SHIFT_2]["shuttled"] + s[MatchMenu.BLUE_SHIFT_2]["shuttled"] / 1.75 # should  be / 2 but this feels better
		var a2def = s[MatchMenu.RED_SHIFT_2]["defended"] + s[MatchMenu.BLUE_SHIFT_2]["defended"] * 7.5 # 15 points stopped per 2 seconds
		a2role = "o"
		if a2fuel < 10 and a2shut < 10 and a2def < 10:
			a2role = "x"
		else:
			match max(a2fuel,a2shut,a2def):
				a2fuel: a2role = "s"
				a2shut: a2role = "l"
				a2def: a2role = "d"
	
	
	
	var efuel = s[MatchMenu.ENDGAME]["scored"]
	var eclimb = "0"
	match s[MatchMenu.ENDGAME]["climb"]:
		0: eclimb = "x"
		1: eclimb = 1
		2: eclimb = 2
		3: eclimb = 3
		4: eclimb = 0
	
	
	
	var disabled = s[MatchMenu.POST_GAME]["robot_disabled"]
	var aside = s[MatchMenu.POST_GAME]["side_climb"]
	var arank = s[MatchMenu.POST_GAME]["alliance_rank"]
	var sCon
	match s[MatchMenu.POST_GAME]["scouting_confidence"]:
		"Missed Much": sCon = -1
		"Caught Most": sCon = 0
		"Caught All": sCon = 1
	var drSkill
	match s[MatchMenu.POST_GAME]["drive_skill"]:
		0: drSkill = "x"
		1: drSkill = -1
		2: drSkill = -0.5
		3: drSkill = 0
		4: drSkill = 0.5
		5: drSkill = 1
	var dSkill
	match s[MatchMenu.POST_GAME]["defense_skill"]:
		0: dSkill = "x"
		1: dSkill = -1
		2: dSkill = -0.5
		3: dSkill = 0
		4: dSkill = 0.5
		5: dSkill = 1
	var aSkill
	match s[MatchMenu.POST_GAME]["accuracy"]:
		0: aSkill = "x"
		1: aSkill = -1
		2: aSkill = -0.5
		3: aSkill = 0
		4: aSkill = 0.5
		5: aSkill = 1
	var comm = s[MatchMenu.POST_GAME]["comments"]
	
	var list_in_order = [scouter, match_number, robot, team_num, preloaded_8, afuel, aclimb, tfuel, shift, a1fuel, a1role, a2fuel, a2role, efuel, eclimb, disabled, aside, arank, sCon, drSkill, dSkill, aSkill, comm]
	for x in list_in_order:
		print(x)
	var qrs_string = " ".join(list_in_order.map(str)) + "\n"
	print(qrs_string)
	return qrs_string



func make_qr():
	var am = amn.get_item_text(amn.selected).to_snake_case()
	var key = int(mn.value)
	print(str(key),am)

	# 1. Safely retrieve the dictionary for the given mn.value key
	var stats_group = Global.statistics.get(key)

	# 2. Check if the group exists and contains the key 'am'
	if stats_group is Dictionary and stats_group.has(am):
		var stat_value = stats_group[am]
		if stat_value != null:
			var qrs_string = woah_to_qrs(stat_value, key, am)
			qrn.data = qrs_string
			qrn.show() # or qrn.visible = true
			return

	# 3. If any check fails, hide the QR code node
	qrn.hide() # or qrn.visible = false



func _on_option_button_item_selected(_s):
	make_qr()


func _on_spin_box_value_changed(value):
	make_qr()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scouter.tscn")
