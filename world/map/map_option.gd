extends TextureButton

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	print("Botão clicado:", name)
	print("Grupos:", get_groups())

	if is_in_group("combat"):
		var random_map = randi_range(1, 5)
		get_tree().change_scene_to_file("res://world/combat/combat_%d.tscn" % random_map)

	elif is_in_group("boss"):
		get_tree().change_scene_to_file("res://world/combat/combat_boss.tscn")

	elif is_in_group("question_mark"):
		var random_event = randi_range(1, 100)

		if random_event <= 40:
			var random_combat = randi_range(1, 5)
			get_tree().change_scene_to_file("res://world/combat/combat_%d.tscn" % random_combat)

		elif random_event <= 80:
			var player = get_tree().get_first_node_in_group("Player")
			if player:
				player.health += player.total_health * 0.25
				print("Player curado")

		else:
			var random_test = randi_range(1, 3)
			get_tree().change_scene_to_file("res://world/combat/test_%d.tscn" % random_test)

	elif is_in_group("rest"):
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.health += player.total_health * 0.25
			print("Player descansou")

	elif is_in_group("test"):
		var random_map = randi_range(1, 3)
		get_tree().change_scene_to_file("res://world/combat/test_%d.tscn" % random_map)
