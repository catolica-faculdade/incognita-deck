extends Node2D

@export var idle_height := 8.0
@export var idle_speed := 2.0
@export var attack_distance := 40.0
@export var attack_time := 0.15

var base_damage := 10

var health := 20
var shield := 0

var poison := 2

var apply_block := 3
var apply_defend := 7

var heal_amount := 3
var self_heal_amount := 5


var start_position: Vector2
var is_attacking := false

func _ready():
	start_position = position

func choose_action():
	shield = 0

	var action = randi_range(0, 100)

	if action < 50:
		await attack()
	elif action < 80:
		defend()
	else:
		defend_all()

func _process(delta):
	if not is_attacking:
		position.y = start_position.y + sin(Time.get_ticks_msec() / 1000.0 * idle_speed) * idle_height

func heal():
	health = health
	
func attack():
	var player = get_tree().get_first_node_in_group("Player")
	
	if is_attacking:
		return

	is_attacking = true

	var tween := create_tween()

	tween.tween_property(self, "position", start_position + Vector2(40, 0), 0.15)
	tween.tween_property(self, "position", start_position + Vector2(-40, 0), 0.12)

	tween.tween_callback(func():
		if player:
			player.take_damage(base_damage)
	)

	tween.tween_property(self, "position", start_position, 0.15)

	await tween.finished
	is_attacking = false


func defend():
	shield += apply_defend

func apply_shield(amount):
	shield += amount


func defend_all():
	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		enemy.apply_shield(apply_block)

func check_is_alive():
	if(health > 0):
		return true
	else:
		get_tree().change_scene_to_file("res://world/map_1.tscn")
	
func take_damage(amount):
	var tween := create_tween()

	tween.tween_property(self, "position", start_position + Vector2(40, 0), 0.15)
	tween.tween_property(self, "position", start_position + Vector2(80, 0), 0.12)

	tween.tween_callback(func():
		if(shield > 0):
			amount - shield
			if(amount > 0):
				shield = 0
			
		if(amount > 0):
			health -= amount
			
		check_is_alive()
	)

	tween.tween_property(self, "position", start_position, 0.15)

	await tween.finished
