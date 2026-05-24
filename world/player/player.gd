extends Node2D
var health := 100
var poisoned := false
var poison_amount := 0

const trajectory_scene = preload("res://world/player/trajectory.tscn")

func _ready() -> void:
	global_position = Vector2(100, 0)
	var trajectory = trajectory_scene.instantiate()
	add_child(trajectory)

func take_damage(amount):
	health -= amount
	check_is_alive()
	
func receive_poison(amount):
	var poisoned := true
	poison_amount += amount
	
func on_end_turn():
	if(poisoned):
		if(poison_amount > 0):
			health -= poison_amount
			poison_amount -= 1
			check_is_alive()
		else:
			var poisoned := false
			poison_amount = 0

func check_is_alive():
	if(health > 0):
		return true
	else:
		get_tree().change_scene_to_file("res://world/main_menu.tscn")
