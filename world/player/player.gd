extends Node2D

var health := GameManager.player_health
var poisoned := false
var poison_amount := 0
var shield := false
var shield_amount := 0

signal status_changed

const trajectory_scene = preload("res://world/player/trajectory.tscn")

@onready var anim_sprite: AnimatedSprite2D = $Player/AnimatedSprite2D

func _ready() -> void:
	global_position = Vector2(-40, -240)
	var trajectory = trajectory_scene.instantiate()
	add_child(trajectory)
	anim_sprite.play("idle")

func play_attack() -> void:
	anim_sprite.play("attack")
	await anim_sprite.animation_finished
	anim_sprite.play("idle")

func on_card_hovered() -> void:
	anim_sprite.play("card")

func on_card_exited() -> void:
	anim_sprite.play("idle")

func take_damage(amount):
	anim_sprite.play("hit")
	health -= amount
	GameManager.player_health = health
	status_changed.emit()
	DamageNumberSpawner.spawn(global_position + Vector2(0, -120), amount, DamageNumberSpawner.COLOR_PLAYER)
	await anim_sprite.animation_finished
	anim_sprite.play("idle")
	check_is_alive()

func receive_poison(amount):
	poisoned = true
	poison_amount += amount
	status_changed.emit()

func on_end_turn():
	if poisoned:
		if poison_amount > 0:
			await take_damage(poison_amount)
			poison_amount -= 1
			check_is_alive()
		else:
			poisoned = false
			poison_amount = 0

func check_is_alive():
	if health > 0:
		return true
	else:
		get_tree().change_scene_to_file("res://main/main.tscn")

func get_player_status() -> Dictionary:
	return {
		"health": health,
		"max_health": GameManager.max_player_health,
		"poison": poisoned,
		"poison_amount": poison_amount,
		"shield": shield,
		"shield_amount": shield_amount
	}
