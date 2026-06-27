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

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sound: AudioStreamPlayer = $AttackSound
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var hit_shield_sound: AudioStreamPlayer = $HitShieldSound
@onready var heal_sound: AudioStreamPlayer = $HealSound
@onready var death_sound: AudioStreamPlayer = $DeathSound

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
	if action < 50:
		await attack()
	elif action < 80:
		defend()
	else:
		await defend_all()

func heal():
	health += self_heal_amount
	heal_sound.play()
	await play_effect_animation()

func attack():
	var player = get_tree().get_first_node_in_group("Player")
	if is_attacking:
		return
	is_attacking = true
	anim_sprite.play("attack")
	attack_sound.play()

	var tween := create_tween()
	tween.tween_property(self, "position:x", start_position.x + 40, 0.15)
	tween.tween_property(self, "position:x", start_position.x - 40, 0.12)
	tween.tween_callback(func():
		if player:
			player.take_damage(base_damage)
	)
	tween.tween_property(self, "position:x", start_position.x, 0.15)
	await tween.finished

	is_attacking = false
	anim_sprite.play("idle")

func defend():
	shield += apply_defend
	await play_effect_animation()

func apply_shield(amount):
	shield += amount

func defend_all():
	var enemies = get_tree().get_nodes_in_group("enemies")
	await play_effect_animation()
	for enemy in enemies:
		enemy.apply_shield(apply_block)

func check_is_alive():
	if health <= 0:
		return false
	return true

func take_damage(amount):
	is_attacking = true
	anim_sprite.play("hit")

	var tween := create_tween()
	tween.tween_property(self, "position:x", start_position.x + 40, 0.15)
	tween.tween_property(self, "position:x", start_position.x + 80, 0.12)
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
	tween.tween_property(self, "position:x", start_position.x, 0.15)
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

	is_attacking = false
	anim_sprite.play("idle")

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
