extends Control

@export var alliance_member: OptionButton

func _ready():
	load_config()
	
func load_config():
	Global.load_config()
	
	if not Global.config or Global.config == {}:
		Global.config = {"alliance_member": "red_1"}
		Global.save_config()
	
	for i in alliance_member.item_count:
		if alliance_member.get_item_text(i) == Global.config["alliance_member"]:
			alliance_member.selected = i
	
func save_config():
	var am = alliance_member.get_item_text(alliance_member.selected)
	Global.config["alliance_member"] = am
	Global.save_config()


func _on_save_pressed() -> void:
	save_config()
	get_tree().change_scene_to_file("res://scouter.tscn")


func _on_cancel_pressed() -> void:
	get_tree().change_scene_to_file("res://scouter.tscn")
