extends Control



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://base.tscn")


func _on_check_box_toggled(toggled_on: bool) -> void:
	$MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/LineEdit.visible = toggled_on
