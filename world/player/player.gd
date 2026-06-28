extends Node2D

var health := GameManager.player_health
var poisoned := false
var poison_amount := 0
var shield := 0
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

func receive_poison(amount):
	poisoned = true
	poison_amount += amount
	status_changed.emit()

func on_end_turn():
	if poisoned:
		await take_damage(poison_amount)
		poisoned = false
		poison_amount = 0
		status_changed.emit()

func check_is_alive():
	if health > 0:
		return true
	return false

func play_death() -> void:
	anim_sprite.play("hit")
	await get_tree().create_timer(0.5).timeout
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished

func get_player_status() -> Dictionary:
	return {
		"health": health,
		"max_health": GameManager.max_player_health,
		"poison": poisoned,
		"poison_amount": poison_amount,
		"shield": shield_amount
	}
