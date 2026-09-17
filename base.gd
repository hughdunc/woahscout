extends Control

@export var team_num: Label
@export var period: Label
@export var time_left: Label
@export var time_until: Label

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

@export var red_points_box: Control
@export var red_plus: Button
@export var red_count: Label
@export var red_minus: Button
@export var red_got_first: Button

@export var menu_back: Button
@export var auto_menu: Button
@export var menu_next: Button
@export var manual_menu: Button

enum MatchMenu {
	AUTO,
	TRANSITION,
	WHO_GOT_FIRST,
	RED_SHIFT,
	BLUE_SHIFT,
	ENDGAME
}

enum MatchPeriod {
	AUTO,
	TRANSITION,
	SHIFT_1,
	SHIFT_2,
	ENDGAME
}



var auto = true

var current_period = MatchPeriod.AUTO
var current_menu: MatchMenu

var menu_configs_red = {}


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
			"hidden": [opponent_box, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.TRANSITION: {
			"name": "TRANSITION",
			"visible": [opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [climb_option, auto_box, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.WHO_GOT_FIRST: {
			"name": "WHO GOT FIRST",
			"visible": [blue_got_first, who_got_label, red_got_first],
			"hidden": [opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus, climb_option, auto_box],
		},
		MatchMenu.RED_SHIFT: {
			"name": "RED SHIFT",
			"visible": [opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [climb_option, auto_box, blue_got_first, who_got_label, red_got_first],
		},
		MatchMenu.BLUE_SHIFT: {
			"name": "BLUE SHIFT",
			"visible": [opponent_box, defend_button, neutral_plus, neutral_count, neutral_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [climb_option, auto_box, blue_got_first, who_got_label, red_got_first, red_points_box],
		},
		MatchMenu.ENDGAME: {
			"name": "ENDGAME",
			"visible": [opponent_box, climb_option, defend_button, neutral_plus, neutral_count, neutral_points_box, red_points_box, neutral_minus, red_plus, red_count, red_minus],
			"hidden": [auto_box, blue_got_first, who_got_label, red_got_first],
		},
	}
	
	load_menu(MatchMenu.AUTO)
	menu_next.connect("pressed", _on_menu_next_pressed)
	menu_back.connect("pressed", _on_menu_back_pressed)
	
func _on_menu_next_pressed():
	var total_menus = MatchMenu.size()
	var next_index = (int(current_menu) + 1) % total_menus
	load_menu(next_index as MatchMenu)

func _on_menu_back_pressed():
	var total_menus = MatchMenu.size()
	var prev_index = (int(current_menu) - 1 + total_menus) % total_menus
	load_menu(prev_index as MatchMenu)
