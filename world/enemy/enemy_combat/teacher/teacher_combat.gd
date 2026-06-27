extends Node2D

@export var min_random_scale := 0.7
@export var max_random_scale := 1.3
@export var idle_height := 8.0
@export var idle_speed := 2.0
@export var attack_distance := 40.0
@export var attack_time := 0.15

var teleport_positions := [
	Vector2(590, -300),
	Vector2(282, -380),
	Vector2(800, -250),
	Vector2(400, -395),
	Vector2(650, -280)
]

var base_damage := 10
var health := 50
var shield := 0
var poison := 2
var apply_block := 3
var apply_defend := 7
var heal_amount := 3
var self_heal_amount := 5
var start_position: Vector2
var is_attacking := false

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sound: AudioStreamPlayer = $AttackSound
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var hit_shield_sound: AudioStreamPlayer = $HitShieldSound
@onready var heal_sound: AudioStreamPlayer = $HealSound
@onready var poison_sound: AudioStreamPlayer = $PoisonSound
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var teleport_sound: AudioStreamPlayer = $TeleportSound

func _ready():
	start_position = position
	anim_sprite.flip_h = false
	anim_sprite.play("idle")

func _process(_delta):
	if not is_attacking:
		position.y = start_position.y + sin(Time.get_ticks_msec() / 1000.0 * idle_speed) * idle_height

func choose_action():
	shield = 0
	var action = randi_range(0, 100)
	if health <= 8 and action < 35:
		await heal()
	elif action < 45:
		await attack()
	elif action < 60:
		await apply_poison()
	elif action < 80:
		await defend()
	elif action < 95:
		await defend_all()
	else:
		await apply_all_heal()

func heal(amount := self_heal_amount):
	health += amount
	heal_sound.play()
	await play_effect_animation()

func apply_heal():
	var enemy = get_tree().get_first_node_in_group("enemies")
	heal_sound.play()
	await play_effect_animation()
	if enemy and enemy.has_method("heal"):
		await enemy.heal(self_heal_amount)

func apply_all_heal():
	var enemies = get_tree().get_nodes_in_group("enemies")
	heal_sound.play()
	await play_effect_animation()
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("heal"):
			await enemy.heal(heal_amount)

func attack():
	var player = get_tree().get_first_node_in_group("Player")
	if is_attacking:
		return
	is_attacking = true
	teleport_sound.stop()
	anim_sprite.play("attack")
	attack_sound.play()

	var tween := create_tween()
	tween.tween_property(self, "position:x", start_position.x + attack_distance, attack_time)
	tween.tween_property(self, "position:x", start_position.x - attack_distance, 0.12)
	tween.tween_callback(func():
		if player:
			player.take_damage(base_damage)
	)
	tween.tween_property(self, "position:x", start_position.x, attack_time)
	await tween.finished

	is_attacking = false
	anim_sprite.play("idle")

func defend():
	shield += apply_defend
	await play_effect_animation()

func apply_shield(amount):
	shield += amount
	await play_effect_animation()

func defend_all():
	var enemies = get_tree().get_nodes_in_group("enemies")
	await play_effect_animation()
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("apply_shield"):
			await enemy.apply_shield(apply_block)

func apply_poison():
	var player = get_tree().get_first_node_in_group("Player")
	if is_attacking:
		return
	is_attacking = true
	anim_sprite.play("attack")
	poison_sound.play()

	var tween := create_tween()
	tween.tween_property(self, "position:x", start_position.x + attack_distance, attack_time)
	tween.tween_property(self, "position:x", start_position.x - attack_distance, 0.12)
	tween.tween_callback(func():
		if player:
			player.receive_poison(poison)
	)
	tween.tween_property(self, "position:x", start_position.x, attack_time)
	await tween.finished

	is_attacking = false
	anim_sprite.play("idle")

func check_is_alive():
	if health <= 0:
		return false
	return true

func take_damage(amount):
	if is_attacking:
		return
	is_attacking = true
	anim_sprite.play("hit")

	var cur_pos := position
	var random_offset := Vector2(randf_range(-30, 10), randf_range(0, 50))
	var new_scale := scale * 0.60

	var tween := create_tween()
	tween.tween_property(self, "position:x", cur_pos.x + 40, 0.08)
	tween.tween_property(self, "scale", new_scale, 0.15)
	tween.parallel().tween_property(self, "position:x", cur_pos.x + random_offset.x, 0.15)
	tween.tween_callback(func():
		if shield > 0:
			if amount >= shield:
				amount -= shield
				shield = 0
			else:
				shield -= amount
				amount = 0
		if amount > 0:
			health -= amount
	)
	await tween.finished

	if health <= 0:
		remove_from_group("enemies")
		hit_sound.stop()
		hit_shield_sound.stop()
		death_sound.play()
		await get_tree().create_timer(3.0).timeout
		death_sound.stop()
		queue_free()
		return

	if shield > 0:
		hit_shield_sound.play()
	else:
		hit_sound.play()

	await teleport_randomly()
	is_attacking = false

func teleport_randomly():
	anim_sprite.play("teleport")
	teleport_sound.play()
	await get_tree().create_timer(1.0).timeout

	var new_position: Vector2 = teleport_positions.pick_random()
	var new_scale_value := randf_range(min_random_scale, max_random_scale)
	global_position = new_position
	start_position = position
	scale = Vector2(new_scale_value, new_scale_value)
	anim_sprite.play("idle")
	await get_tree().create_timer(1).timeout

func play_effect_animation():
	var original_x = position.x
	var tween := create_tween()
	tween.tween_property(self, "position:x", original_x + 8, 0.04)
	tween.tween_property(self, "position:x", original_x - 8, 0.04)
	tween.tween_property(self, "position:x", original_x + 6, 0.03)
	tween.tween_property(self, "position:x", original_x, 0.03)
	await tween.finished

func lock():
	modulate = Color(1.0, 0.4, 0.4)

func unlock():
	modulate = Color.WHITE
