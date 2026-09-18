extends Control

@export var during_game: Control
@export var post_game: Control

@export var team_num: Label
@export var period: Label
@export var time_left: Label
@export var time_until: Label

@export var blue_gets_first: Button
@export var opponent_box: Control
@export var defend_button: Button
@export var climb_option: OptionButton
@export var auto_box: Control
@export var no_auto: CheckBox
@export var climb_auto: CheckBox
@export var blue_got_first: Button

@export var neutral_points_box: Control
@export var neutral_plus: Button
@export var neutral_count: Label
@export var neutral_minus: Button
@export var who_got_label: Label
@export var select_who_got: Label

@export var red_gets_first: Button
@export var red_points_box: Control
@export var red_plus: Button
@export var red_count: Label
@export var red_minus: Button
@export var red_got_first: Button

@export var auto_menu: Control
@export var menu_back: Button
@export var auto_switch: Button
@export var menu_next: Button
@export var manual_switch: Button

@export var robot_disabled: CheckBox
@export var side_climb: CheckBox
@export var alliance_rank: OptionButton
@export var scouting_confidence: OptionButton
@export var drive_skill: OptionButton
@export var defense_skill: OptionButton
@export var accuracy: OptionButton
@export var comments: TextEdit

@export var done: Button

@export var timer: Timer

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

enum MatchPeriod {
	AUTO,
	TRANSITION,
	SHIFT_1,
	SHIFT_2,
	SHIFT_3,
	SHIFT_4,
	ENDGAME,
	POST_GAME
}


var short_names = {
	MatchPeriod.AUTO: "AUTO",
	MatchPeriod.TRANSITION: "TRANS",
	MatchPeriod.SHIFT_1: "SHIFT 1",
	MatchPeriod.SHIFT_2: "SHIFT 2",
	MatchPeriod.SHIFT_3: "SHIFT 3",
	MatchPeriod.SHIFT_4: "SHIFT 4",
	MatchPeriod.ENDGAME: "END",
	MatchPeriod.POST_GAME: "DONE"
}

var auto_screen_switch = false
var first_shift = ""

var current_period: MatchPeriod
var current_menu: MatchMenu

var menu_configs_red = {}

var defending = false

var stats = {
	MatchMenu.AUTO: {
		"defended": 0.0,
		"shuttled": 0,
		"scored": 0,
		"no_auto": false,
		"climb": 0,
	},
	MatchMenu.TRANSITION: {
		"defended": 0.0,
		"shuttled": 0,
		"scored": 0,
	},
	MatchMenu.RED_SHIFT_1: {
		"defended": 0.0,
		"shuttled": 0,
		"scored": 0,
	},
	MatchMenu.BLUE_SHIFT_1: {
		"defended": 0.0,
		"shuttled": 0,
	},
	MatchMenu.RED_SHIFT_2: {
		"defended": 0.0,
		"shuttled": 0,
		"scored": 0,
	},
	MatchMenu.BLUE_SHIFT_2: {
		"defended": 0.0,
		"shuttled": 0,
	},
	MatchMenu.ENDGAME: {
		"defended": 0.0,
		"shuttled": 0,
		"scored": 0,
		"climb": 0,
	},
	MatchMenu.POST_GAME: {
		"robot_disabled": false,
		"side_climb": false,
		"alliance_rank": 1,
		"scouting_confidence": "Caught Most",
		"drive_skill": 0,
		"defense_skill": 0,
		"accuracy": 0,
		"comments": ""
	}
}

var ends = {
	MatchPeriod.AUTO: 20,
	MatchPeriod.TRANSITION: 30,
	MatchPeriod.SHIFT_1: 55,
	MatchPeriod.SHIFT_2: 80,
	MatchPeriod.SHIFT_3: 105,
	MatchPeriod.SHIFT_4: 130,
	MatchPeriod.ENDGAME: 160,
	MatchPeriod.POST_GAME: 9999,
}

func get_menu_order() -> Array:
	if first_shift == "red":
		return [
			MatchMenu.AUTO,
			MatchMenu.TRANSITION,
			MatchMenu.RED_SHIFT_1,
			MatchMenu.BLUE_SHIFT_1,
			MatchMenu.RED_SHIFT_2,
			MatchMenu.BLUE_SHIFT_2,
			MatchMenu.ENDGAME,
			MatchMenu.POST_GAME
		]
	elif first_shift == "blue":
		return [
			MatchMenu.AUTO,
			MatchMenu.TRANSITION,
			MatchMenu.BLUE_SHIFT_1,
			MatchMenu.RED_SHIFT_1,
			MatchMenu.BLUE_SHIFT_2,
			MatchMenu.RED_SHIFT_2,
			MatchMenu.ENDGAME,
			MatchMenu.POST_GAME
		]
	else:
		# Default order if first shift hasn't been chosen yet
		return [
			MatchMenu.AUTO,
			MatchMenu.TRANSITION,
			MatchMenu.WHO_GOT_FIRST,
			MatchMenu.RED_SHIFT_1,
			MatchMenu.BLUE_SHIFT_1,
			MatchMenu.RED_SHIFT_2,
			MatchMenu.BLUE_SHIFT_2,
			MatchMenu.ENDGAME,
			MatchMenu.POST_GAME
		]

func get_auto_switch_name(menu: MatchMenu) -> String:
	match menu:
		MatchMenu.AUTO:
			return "AUTONOMOUS"
		MatchMenu.TRANSITION:
			return "TRANSITION"
		MatchMenu.WHO_GOT_FIRST:
			return "WHO SHIFT 1"
		MatchMenu.RED_SHIFT_1:
			return "SHIFT 2" if first_shift == "blue" else "SHIFT 1"
		MatchMenu.BLUE_SHIFT_1:
			return "SHIFT 1" if first_shift == "blue" else "SHIFT 2"
		MatchMenu.RED_SHIFT_2:
			return "SHIFT 4" if first_shift == "blue" else "SHIFT 3"
		MatchMenu.BLUE_SHIFT_2:
			return "SHIFT 3" if first_shift == "blue" else "SHIFT 4"
		MatchMenu.ENDGAME:
			return "ENDGAME"
		MatchMenu.POST_GAME:
			return "POST GAME"
	return "MENU"

func load_menu(menu: MatchMenu):
	current_menu = menu
	auto_switch.text = get_auto_switch_name(menu)
	
	var c = menu_configs_red[menu]
	var fs_no = first_shift == "" and menu in [MatchMenu.RED_SHIFT_1, MatchMenu.BLUE_SHIFT_1, MatchMenu.BLUE_SHIFT_2, MatchMenu.RED_SHIFT_2]
	if fs_no:
		for n in c["visible"]:
				n.visible = false
		for n in c["hidden"]:
			n.visible = false
		during_game.visible = true
		select_who_got.visible = true
	else:
		for n in c["visible"]:
				n.visible = true
		for n in c["hidden"]:
			n.visible = false
		select_who_got.visible = false
	
	
	update_points()

func _on_menu_next_pressed():
	var order = get_menu_order()
	var current_index = order.find(current_menu)
	if current_index != -1:
		var next_index = (current_index + 1) % order.size()
		load_menu(order[next_index])
	else:
		load_menu(order[0])

func _on_menu_back_pressed():
	var order = get_menu_order()
	var current_index = order.find(current_menu)
	if current_index != -1:
		var prev_index = (current_index - 1 + order.size()) % order.size()
		load_menu(order[prev_index])
	else:
		load_menu(order[0])


func _ready():
	menu_configs_red = {
		MatchMenu.AUTO: {
			"name": "AUTONOMOUS",
			"visible": [during_game, auto_box, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus, no_auto, climb_auto],
			"hidden": [post_game, opponent_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.TRANSITION: {
			"name": "TRANSITION",
			"visible": [during_game, opponent_box, blue_gets_first, red_gets_first, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [post_game, climb_option, auto_box, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.WHO_GOT_FIRST: {
			"name": "WHO SHIFT 1",
			"visible": [during_game, blue_got_first, who_got_label, red_got_first],
			"hidden": [post_game, opponent_box, defend_button, blue_gets_first, red_gets_first, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus, climb_option, auto_box],
		},
		MatchMenu.RED_SHIFT_1: {
			"name": "RED SHIFT 1",
			"visible": [during_game, opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [post_game, climb_option, auto_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.BLUE_SHIFT_1: {
			"name": "BLUE SHIFT 1",
			"visible": [during_game, opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [post_game, climb_option, auto_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first, red_points_box],
		},
		MatchMenu.RED_SHIFT_2: {
			"name": "RED SHIFT 2",
			"visible": [during_game, opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [post_game, climb_option, auto_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.BLUE_SHIFT_2: {
			"name": "BLUE SHIFT 2",
			"visible": [during_game, opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [post_game, climb_option, auto_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first, red_points_box],
		},
		MatchMenu.ENDGAME: {
			"name": "ENDGAME",
			"visible": [during_game, opponent_box, climb_option, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [post_game, auto_box, blue_got_first, blue_gets_first, red_gets_first, who_got_label, red_got_first],
		},
		MatchMenu.POST_GAME: {
			"name": "POST GAME",
			"visible": [post_game],
			"hidden": [during_game, blue_gets_first, opponent_box, defend_button, climb_option, auto_box, no_auto, climb_auto, blue_got_first, neutral_points_box, neutral_plus, neutral_count, neutral_minus, who_got_label, red_gets_first, red_points_box, red_plus, red_count, red_minus, red_got_first],
		}
	}
	
	load_menu(MatchMenu.AUTO)
	menu_next.pressed.connect(_on_menu_next_pressed)
	menu_back.pressed.connect(_on_menu_back_pressed)
	blue_gets_first.disabled = false
	blue_got_first.disabled = false
	red_gets_first.disabled = false
	red_got_first.disabled = false
	blue_gets_first.pressed.connect(_blue_first)
	blue_got_first.pressed.connect(_blue_first)
	red_gets_first.pressed.connect(_red_first)
	red_got_first.pressed.connect(_red_first)
	
	defend_button.button_down.connect(func(): defending = true)
	defend_button.button_up.connect(func(): defending = false)
	red_plus.pressed.connect(func(): change_points("scored", 5))
	red_minus.pressed.connect(func(): change_points("scored", -5))
	neutral_plus.pressed.connect(func(): change_points("shuttled", 5))
	neutral_minus.pressed.connect(func(): change_points("shuttled", -5))
	climb_option.item_selected.connect(func(i): change_bool("climb", i))
	no_auto.toggled.connect(func(on): change_bool("no_auto", on))
	climb_auto.toggled.connect(func(on): change_bool("climb", 1 if on else 0))
	
	robot_disabled.toggled.connect(func(on): change_bool("robot_disabled", on))
	side_climb.toggled.connect(func(on): change_bool("side_climb", on))
	alliance_rank.item_selected.connect(func(i): change_bool("alliance_rank",i+1))
	scouting_confidence.item_selected.connect(func(i): change_bool("scouting_confidence",scouting_confidence.get_item_text(i)))
	drive_skill.item_selected.connect(func(i): change_bool("drive_skill",i))
	defense_skill.item_selected.connect(func(i): change_bool("defense_skill",i))
	accuracy.item_selected.connect(func(i): change_bool("accuracy",i))
	comments.text_set.connect(func(t): change_bool("comments", t))
	
	done.pressed.connect(func(): print(stats))

	
	
	manual_switch.pressed.connect(_switch_to_manual)
	auto_switch.pressed.connect(_switch_to_auto_switch)
	
	_switch_to_auto_switch()
	
	timer.start()

func change_points(type, amt):
	stats[current_menu][type] += amt
	if stats[current_menu][type] < 0:
		stats[current_menu][type] = 0
	update_points()

func change_bool(type, on):
	stats[current_menu][type] = on
	update_points()

func update_points():
	if red_count.is_visible_in_tree():
		red_count.text = str(stats[current_menu]["scored"])
	if neutral_count.is_visible_in_tree():
		neutral_count.text = str(stats[current_menu]["shuttled"])
	if climb_option.is_visible_in_tree():
		climb_option.selected = stats[current_menu]["climb"]
	if no_auto.is_visible_in_tree():
		no_auto.button_pressed = stats[current_menu]["no_auto"]
	if climb_auto.is_visible_in_tree():
		climb_auto.button_pressed = stats[current_menu]["climb"] > 0
	if defend_button.is_visible_in_tree():
		defend_button.text = "HOLD WHILE DEFENDING\n" + format_time(ceil(stats[current_menu]["defended"]))

func _blue_first():
	first_shift = "blue"
	blue_gets_first.disabled = true
	blue_got_first.disabled = true
	red_gets_first.disabled = false
	red_got_first.disabled = false
	
	if current_menu == MatchMenu.WHO_GOT_FIRST:
		load_menu(MatchMenu.BLUE_SHIFT_1)
	else:
		load_menu(current_menu)

func _red_first():
	first_shift = "red"
	blue_gets_first.disabled = false
	blue_got_first.disabled = false
	red_gets_first.disabled = true
	red_got_first.disabled = true
	
	if current_menu == MatchMenu.WHO_GOT_FIRST:
		load_menu(MatchMenu.RED_SHIFT_1)
	else:
		load_menu(current_menu)

func format_time(total_seconds: float) -> String:
	var minutes: int = int(total_seconds) / 60
	var seconds: int = int(total_seconds) % 60
	
	# Returns a padded string like "02:05" instead of "2:5"
	return "%02d:%02d" % [minutes, seconds]

func get_current_period():
	var t = 160.0 - timer.time_left
	for p in ends:
		if t <= ends[p]:
			current_period = p
			time_until.text = format_time(ends[p] - t) + " to " + short_names[current_period + 1]
			break
	period.text = short_names[current_period]
	time_left.text = format_time(timer.time_left)
			
func _switch_to_auto_switch():
	if auto_screen_switch: return
	auto_screen_switch = true
	manual_switch.visible = true   # Show the button to switch back to manual
	auto_menu.visible = false      # Hide the manual menu bar

func _switch_to_manual():
	if not auto_screen_switch: return
	auto_screen_switch = false
	manual_switch.visible = false  # Hide the manual switch button
	auto_menu.visible = true


func _process(delta):
	get_current_period()
	if auto_screen_switch and not timer.is_stopped():
		
		if current_period == MatchPeriod.AUTO:
			if current_menu != MatchMenu.AUTO:
				load_menu(MatchMenu.AUTO)
		elif current_period == MatchPeriod.TRANSITION:
			if current_menu != MatchMenu.TRANSITION:
				load_menu(MatchMenu.TRANSITION)
		elif current_period == MatchPeriod.SHIFT_1:
			if first_shift == "red":
				if current_menu != MatchMenu.RED_SHIFT_1:
					load_menu(MatchMenu.RED_SHIFT_1)
			elif first_shift == "blue":
				if current_menu != MatchMenu.BLUE_SHIFT_1:
					load_menu(MatchMenu.BLUE_SHIFT_1)
			else:
				if current_menu != MatchMenu.WHO_GOT_FIRST:
					load_menu(MatchMenu.WHO_GOT_FIRST)
		elif current_period == MatchPeriod.SHIFT_2:
			if first_shift == "red":
				if current_menu != MatchMenu.BLUE_SHIFT_1:
					load_menu(MatchMenu.BLUE_SHIFT_1)
			elif first_shift == "blue":
				if current_menu != MatchMenu.RED_SHIFT_1:
					load_menu(MatchMenu.RED_SHIFT_1)
			else:
				if current_menu != MatchMenu.WHO_GOT_FIRST:
					load_menu(MatchMenu.WHO_GOT_FIRST)
		elif current_period == MatchPeriod.SHIFT_3:
			if first_shift == "red":
				if current_menu != MatchMenu.RED_SHIFT_2:
					load_menu(MatchMenu.RED_SHIFT_2)
			elif first_shift == "blue":
				if current_menu != MatchMenu.BLUE_SHIFT_2:
					load_menu(MatchMenu.BLUE_SHIFT_2)
			else:
				if current_menu != MatchMenu.WHO_GOT_FIRST:
					load_menu(MatchMenu.WHO_GOT_FIRST)
		elif current_period == MatchPeriod.SHIFT_4:
			if first_shift == "red":
				if current_menu != MatchMenu.BLUE_SHIFT_2:
					load_menu(MatchMenu.BLUE_SHIFT_2)
			elif first_shift == "blue":
				if current_menu != MatchMenu.RED_SHIFT_2:
					load_menu(MatchMenu.RED_SHIFT_2)
			else:
				if current_menu != MatchMenu.WHO_GOT_FIRST:
					load_menu(MatchMenu.WHO_GOT_FIRST)
		elif current_period == MatchPeriod.ENDGAME:
			if current_menu != MatchMenu.ENDGAME:
				load_menu(MatchMenu.ENDGAME)
	
	
	if defending:
		stats[current_menu]["defended"] += delta
		defend_button.text = "HOLD WHILE DEFENDING\n" + format_time(ceil(stats[current_menu]["defended"]))
