extends Node
var scenario_to_load: String = ""
var map_to_load: String = "map_1"
var max_player_health: int = 80
var player_health: int = max_player_health
var level := 0
var is_player_turn := true

enum Context { MAIN_MENU, MAP, COMBAT }
var current_context := Context.MAIN_MENU

func end_game():
	print("end_game:", level)
	is_player_turn = true
	if level == -1:
		player_health = max_player_health
		level = 0
		get_tree().change_scene_to_file("res://main/main.tscn")
	elif level == 5:
		player_health = max_player_health
		level = 0
		get_tree().change_scene_to_file("res://main/main.tscn")
	else:
		get_tree().change_scene_to_file("res://world/%s.tscn" % map_to_load)
