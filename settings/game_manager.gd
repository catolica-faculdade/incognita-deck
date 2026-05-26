extends Node
var scenario_to_load: String = ""
var map_to_load: String = "map_1"

var level := 0
var is_player_turn := true

func end_game():
	get_tree().change_scene_to_file("res://world/%s.tscn" % map_to_load)
	
