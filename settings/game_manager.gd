extends Node
var scenario_to_load: String = ""
var map_to_load: String = "map_1"
var max_player_health: int = 80
var player_health: int = max_player_health
var level := 0
var is_player_turn := true


func end_game():
	is_player_turn = true
	if(level == -1):
		get_tree().change_scene_to_file("res://main/main.tscn")
	else:
		get_tree().change_scene_to_file("res://world/%s.tscn" % map_to_load)
	
