extends Control

@export var match_num: SpinBox
@export var scouter_name: Label
@export var matches_till_done: Label
@export var team_num: Label
@export var alliance_member: Label
@export var subbing_checkbox: CheckBox
@export var subbing_lineedit: LineEdit


func _ready() -> void:
	get_match_data()

func get_match_data():
	Global.load_matches()
	Global.load_rotations()
	Global.load_config()
	match_num.max_value = len(Global.matches)
	var num = Global.matches[int(match_num.value - 1)][Global.config["alliance_member"]]
	team_num.text = str(int(num))
	scouter_name.text = Global.rotations[Global.matches[int(match_num.value - 1)]["rotation"] - 1][Global.config["alliance_member"]]
	if Global.config["alliance_member"].begins_with("blue"):
		team_num.add_theme_color_override("font_color", Color("53a1f0"))
	else:
		team_num.add_theme_color_override("font_color", Color("f26145"))
	match Global.config["alliance_member"]:
		"red_1": alliance_member.text = "(red 1)"
		"red_2": alliance_member.text = "(red 2)"
		"red_3": alliance_member.text = "(red 3)"
		"blue_1": alliance_member.text = "(blue 1)"
		"blue_2": alliance_member.text = "(blue 2)"
		"blue_3": alliance_member.text = "(blue 3)"

	var left = Global.get_matches_left_in_rotation(int(match_num.value))
	matches_till_done.text = str(left) + " match" + ("" if left == 1 else "es") + " until done scouting"



func _on_start_pressed() -> void:
	Global.current_match = int(match_num.value)
	Global.team_scouting = str(int(Global.matches[int(match_num.value - 1)][Global.config["alliance_member"]]))
	if subbing_checkbox.button_pressed:
		Global.subbing = subbing_lineedit.text
	Global.load_config()
	if Global.config["alliance_member"].begins_with("red"):
		get_tree().change_scene_to_file("res://red.tscn")
	else:
		get_tree().change_scene_to_file("res://blue.tscn")


func _on_check_box_toggled(toggled_on: bool) -> void:
	subbing_lineedit.visible = toggled_on


func _on_spin_box_value_changed(value: float) -> void:
	get_match_data()


func _on_no_show_pressed() -> void:
	if subbing_lineedit.text == "config":
		get_tree().change_scene_to_file("res://config.tscn")
