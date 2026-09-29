extends Node

enum MatchMenu {
	AUTO,
	TRANSITION,
	WHO_GOT_FIRST,
	BLUE_SHIFT_1,
	RED_SHIFT_1,
	BLUE_SHIFT_2,
	RED_SHIFT_2,
	ENDGAME,
	POST_GAME
}

func woah_to_qrs(s, m): #stats, match number
	var scouter = s[MatchMenu.POST_GAME]["scouter"]
	var match_number = m
	var robot = ""
	match Global.config["alliance_member"]:
		"red_1": robot = "R1"
		"red_2": robot = "R2"
		"red_3": robot = "R3"
		"blue_1": robot = "B1"
		"blue_2": robot = "B2"
		"blue_3": robot = "B3"
	var team_num = Global.matches[m]["alliance_member"]
	
	
	
	var preloaded_8 = 8
	var afuel = max(s[MatchMenu.AUTO]["scored"] - 8, 0) # func means find me which one is bigger not find the bigger number
	var aclimb = bool(s[MatchMenu.AUTO]["climb"])
	
	
	
	var tfuel = s[MatchMenu.TRANSITION]["scored"]
	var shift = s[MatchMenu.TRANSITION]["first_shift"]
	
	
	
	if Global.config["alliance_member"].begins_with("red"):
		var a1fuel = s[MatchMenu.RED_SHIFT_1]["scored"]
		var a1shut = s[MatchMenu.RED_SHIFT_1]["shuttled"] + s[MatchMenu.BLUE_SHIFT_1]["shuttled"] / 1.75 # should  be / 2 but this feels better
		var a1def = s[MatchMenu.RED_SHIFT_1]["defended"] + s[MatchMenu.BLUE_SHIFT_1]["defended"] * 7.5 # 15 points stopped per 2 seconds
		var a1role = "o"
		if a1fuel < 10 and a1shut < 10 and a1def < 10:
			a1role = "x"
		else:
			match max(a1fuel,a1shut,a1def):
				a1fuel: a1role = "s"
				a1shut: a1role = "l"
				a1def: a1role = "d"
	else:
		var a1fuel = s[MatchMenu.BLUE_SHIFT_1]["scored"]
		var a1shut = s[MatchMenu.RED_SHIFT_1]["shuttled"] + s[MatchMenu.BLUE_SHIFT_1]["shuttled"] / 1.75 # should  be / 2 but this feels better
		var a1def = s[MatchMenu.RED_SHIFT_1]["defended"] + s[MatchMenu.BLUE_SHIFT_1]["defended"] * 7.5 # 15 points stopped per 2 seconds
		var a1role = "o"
		if a1fuel < 10 and a1shut < 10 and a1def < 10:
			a1role = "x"
		else:
			match max(a1fuel,a1shut,a1def):
				a1fuel: a1role = "s"
				a1shut: a1role = "l"
				a1def: a1role = "d"
	
	
	
	
	if Global.config["alliance_member"].begins_with("red"):
		var a2fuel = s[MatchMenu.RED_SHIFT_1]["scored"]
		var a2shut = s[MatchMenu.RED_SHIFT_1]["shuttled"] + s[MatchMenu.BLUE_SHIFT_1]["shuttled"] / 1.75 # should  be / 2 but this feels better
		var a2def = s[MatchMenu.RED_SHIFT_1]["defended"] + s[MatchMenu.BLUE_SHIFT_1]["defended"] * 7.5 # 15 points stopped per 2 seconds
		var a2role = "o"
		if a2fuel < 10 and a2shut < 10 and a2def < 10:
			a2role = "x"
		else:
			match max(a2fuel,a2shut,a2def):
				a2fuel: a2role = "s"
				a2shut: a2role = "l"
				a2def: a2role = "d"
	else:
		var a2fuel = s[MatchMenu.BLUE_SHIFT_2]["scored"]
		var a2shut = s[MatchMenu.RED_SHIFT_2]["shuttled"] + s[MatchMenu.BLUE_SHIFT_2]["shuttled"] / 1.75 # should  be / 2 but this feels better
		var a2def = s[MatchMenu.RED_SHIFT_2]["defended"] + s[MatchMenu.BLUE_SHIFT_2]["defended"] * 7.5 # 15 points stopped per 2 seconds
		var a2role = "o"
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
	var rank = s[MatchMenu.POST_GAME]["alliance_rank"]
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
