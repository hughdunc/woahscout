extends Control

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

@export var red_gets_first: Button
@export var red_points_box: Control
@export var red_plus: Button
@export var red_count: Label
@export var red_minus: Button
@export var red_got_first: Button

@export var menu_back: Button
@export var auto_menu: Button
@export var menu_next: Button
@export var manual_menu: Button

@export var timer: Timer

enum MatchMenu {
	AUTO,
	TRANSITION,
	WHO_GOT_FIRST,
	RED_SHIFT_1,
	BLUE_SHIFT_1,
	RED_SHIFT_2,
	BLUE_SHIFT_2,
	ENDGAME
}

enum MatchPeriod {
	AUTO,
	TRANSITION,
	SHIFT_1,
	SHIFT_2,
	SHIFT_3,
	SHIFT_4,
	ENDGAME
}


var auto_screen_switch = true
var first_shift = ""

var current_period: MatchPeriod
var current_menu: MatchMenu

var menu_configs_red = {}

var stats = {
	MatchMenu.AUTO: {
		"defended": 0.0,
		"shuttled": 0,
		"scored": 0,
		"no_auto": false,
		"climb": false,
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
	}
}

var ends = {
	MatchPeriod.AUTO: 20,
	MatchPeriod.TRANSITION: 30,
	MatchPeriod.SHIFT_1: 55,
	MatchPeriod.SHIFT_2: 80,
	MatchPeriod.SHIFT_3: 105,
	MatchPeriod.SHIFT_4: 130,
	MatchPeriod.ENDGAME: 160
}

func load_menu(menu: MatchMenu):
		var c = menu_configs_red[menu]
		auto_menu.text = c["name"]
		for n in c["visible"]:
			print(n)
			n.visible = true
		for n in c["hidden"]:
			n.visible = false
		current_menu = menu


func _ready():
	menu_configs_red = {
		MatchMenu.AUTO: {
			"name": "AUTONOMOUS",
			"visible": [auto_box, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [opponent_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.TRANSITION: {
			"name": "TRANSITION",
			"visible": [opponent_box, blue_gets_first, red_gets_first, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [climb_option, auto_box, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.WHO_GOT_FIRST: {
			"name": "WHO GOT FIRST",
			"visible": [blue_got_first, who_got_label, red_got_first],
			"hidden": [opponent_box, defend_button, blue_gets_first, red_gets_first, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus, climb_option, auto_box],
		},
		MatchMenu.RED_SHIFT_1: {
			"name": "RED SHIFT 1",
			"visible": [opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [climb_option, auto_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.BLUE_SHIFT_1: {
			"name": "BLUE SHIFT 1",
			"visible": [opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [climb_option, auto_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first, red_points_box],
		},
		MatchMenu.RED_SHIFT_2: {
			"name": "RED SHIFT 2",
			"visible": [opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [climb_option, auto_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.BLUE_SHIFT_2: {
			"name": "BLUE SHIFT 2",
			"visible": [opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [climb_option, auto_box, blue_gets_first, red_gets_first, blue_got_first, who_got_label, red_got_first, red_points_box],
		},
		MatchMenu.ENDGAME: {
			"name": "ENDGAME",
			"visible": [opponent_box, climb_option, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [auto_box, blue_got_first, blue_gets_first, red_gets_first, who_got_label, red_got_first],
		},
	}
	
	load_menu(MatchMenu.AUTO)
	menu_next.connect("pressed", _on_menu_next_pressed)
	menu_back.connect("pressed", _on_menu_back_pressed)
	blue_gets_first.disabled = false
	blue_got_first.disabled = false
	red_gets_first.disabled = false
	red_got_first.disabled = false
	blue_gets_first.connect("pressed", _blue_first)
	blue_got_first.connect("pressed", _blue_first)
	red_gets_first.connect("pressed", _red_first)
	red_got_first.connect("pressed", _red_first)
	
func _on_menu_next_pressed():
	var total_menus = MatchMenu.size()
	var next_index = (int(current_menu) + 1) % total_menus
	load_menu(next_index as MatchMenu)

func _on_menu_back_pressed():
	var total_menus = MatchMenu.size()
	var prev_index = (int(current_menu) - 1 + total_menus) % total_menus
	load_menu(prev_index as MatchMenu)

func _blue_first():
	first_shift = "blue"
	blue_gets_first.disabled = true
	blue_got_first.disabled = true
	red_gets_first.disabled = false
	red_got_first.disabled = false

func _red_first():
	first_shift = "red"
	blue_gets_first.disabled = false
	blue_got_first.disabled = false
	red_gets_first.disabled = true
	red_got_first.disabled = true

func get_current_period():
	var t = 160 - timer.time_left
	for p in ends:
		if p > t:
			current_period = t

func _process(delta):
	if auto_screen_switch and not timer.is_stopped():
		get_current_period()
		if current_period == MatchPeriod.AUTO:
			if current_menu != MatchMenu.AUTO:
				load_menu(MatchMenu.AUTO)
		elif current_period == MatchPeriod.TRANSITION:
			if current_menu != MatchMenu.TRANSITION:
				load_menu(MatchMenu.TRANSITION)
		elif current_period == MatchPeriod.SHIFT_1:
			if first_shift == "red":
				current_menu = MatchMenu.RED_SHIFT_1
			elif first_shift == "blue":
				current_menu = MatchMenu.BLUE_SHIFT_1
			else:
				current_menu = MatchMenu.WHO_GOT_FIRST
		elif current_period == MatchPeriod.SHIFT_2:
			if first_shift == "red":
				current_menu = MatchMenu.BLUE_SHIFT_1
			elif first_shift == "blue":
				current_menu = MatchMenu.RED_SHIFT_1
			else:
				current_menu = MatchMenu.WHO_GOT_FIRST
		elif current_period == MatchPeriod.SHIFT_3:
			if first_shift == "red":
				current_menu = MatchMenu.RED_SHIFT_2
			elif first_shift == "blue":
				current_menu = MatchMenu.BLUE_SHIFT_2
			else:
				current_menu = MatchMenu.WHO_GOT_FIRST
		elif current_period == MatchPeriod.SHIFT_4:
			if first_shift == "red":
				current_menu = MatchMenu.BLUE_SHIFT_2
			elif first_shift == "blue":
				current_menu = MatchMenu.RED_SHIFT_2
			else:
				current_menu = MatchMenu.WHO_GOT_FIRST
		elif current_period == MatchPeriod.ENDGAME:
			if current_menu != MatchMenu.ENDGAME:
				load_menu(MatchMenu.ENDGAME)
