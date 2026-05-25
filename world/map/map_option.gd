extends TextureButton

var current_map_level := 1
@export var level := 0

func _ready():
	pressed.connect(_on_pressed)
	validate_level()

func validate_level():
	disabled = level != GameManager.level

	if disabled:
		modulate.a = 0.35
	else:
		modulate.a = 1.0

func _on_pressed():
	if disabled:
		return
	var scenario_path: String = ""
	
	var tree = get_tree()
	if not tree: return

	if is_in_group("combat"):
		var random_map = randi_range(1, 5)
		scenario_path = "res://world/combat/combat_%d.tscn" % random_map
		
		GameManager.scenario_to_load = scenario_path
		tree.change_scene_to_file("res://world/battle_system/battle_system.tscn")

	elif is_in_group("boss"):
		scenario_path = "res://world/combat/combat_boss.tscn"

	elif is_in_group("question_mark"):
		var random_event = randi_range(1, 100)

		if random_event <= 40:
			var random_combat = randi_range(1, 5)
			scenario_path = "res://world/combat/combat_%d.tscn" % random_combat

		elif random_event <= 80:
			var player = tree.get_first_node_in_group("Player")
			if player:
				player.health += player.total_health * 0.25
				print("Player curado")
			return

		else:
			var random_test = randi_range(1, 3)
			scenario_path = "res://world/combat/test_%d.tscn" % random_test

	elif is_in_group("rest"):
		var player = tree.get_first_node_in_group("Player")
		if player:
			player.health += player.total_health * 0.25
			print("Player descansou")
		return

	elif is_in_group("test"):
		var random_map = randi_range(1, 3)
		scenario_path = "res://world/combat/test_%d.tscn" % random_map
		
	elif is_in_group("boss"):
		scenario_path = "res://world/combat/combat_boss.tscn"
		
		
	if scenario_path != "":
		GameManager.scenario_to_load = scenario_path
		tree.change_scene_to_file("res://world/battle_system/battle_system.tscn")
