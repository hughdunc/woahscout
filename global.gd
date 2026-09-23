extends Node


var subbing = ""


var current_match: int = 1
var team_scouting: int = 0
var current_event = "ORSAL"

const SAVE_PATH = "res://matches.json"

# Example game data you want to save
var statistics = {}
var matches
var config
var rotations

func _ready() -> void:
	# Test saving and loading on start
	load_matches()

func save_matches() -> void:
	var json_string = JSON.stringify(matches, "\t")
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("Matches saved successfully to: ", ProjectSettings.globalize_path(SAVE_PATH))
	else:
		print("Failed to open file for writing.")

func load_matches() -> void:
	# Check if the file actually exists before trying to read it
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return
	
	# Open the file for reading
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	
	# Parse the JSON string back into usable data
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		matches = json.get_data()
		print("Matches data loaded succesfully!")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())


func get_matches_left_in_rotation(current_match_num: int) -> int:
	load_matches()
	if current_match_num > matches.size() or current_match_num < 1:
		return 0
		
	var current_rot = matches[current_match_num - 1]["rotation"]
	var count = 0
	
	# Look forward from the current match and count consecutive matches with the same rotation
	for i in range(current_match_num - 1, matches.size()):
		if matches[i]["rotation"] == current_rot:
			count += 1
		else:
			break # Hit a different rotation, stop counting
			
	return count

func load_rotations():
	var rot_path = "res://rotations.json"
	if not FileAccess.file_exists(rot_path):
		print("No save file found.")
		return
	
	# Open the file for reading
	var file = FileAccess.open(rot_path, FileAccess.READ)
	var json_string = file.get_as_text()
	
	# Parse the JSON string back into usable data
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		rotations = json.get_data()
		print("Rotations data loaded succesfully!")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())



func save_config() -> void:
	var json_string = JSON.stringify(config, "\t")
	
	var file = FileAccess.open("user://config.json", FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("Matches saved successfully to: ", ProjectSettings.globalize_path("user://config.json"))
	else:
		print("Failed to open file for writing.")

func load_config() -> void:
	# Check if the file actually exists before trying to read it
	if not FileAccess.file_exists("user://config.json"):
		Global.config = {"alliance_member": "red_1"}
		Global.save_config()
		print("Made new config.")
		return
	
	# Open the file for reading
	var file = FileAccess.open("user://config.json", FileAccess.READ)
	var json_string = file.get_as_text()
	
	# Parse the JSON string back into usable data
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		config = json.get_data()
		print("Config data loaded succesfully!")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())


func stats(ms):
	statistics[current_match][team_scouting] = ms
