extends Node2D

signal status_changed
const TRAJECTORY_SCENE = preload("res://world/player/trajectory.tscn")
var health := GameManager.player_health
var poison_amount := 0
var shield_amount := 0
var strength := 0
var weak := 0
var thorns := 0
var is_acting := false
var trajectory: Line2D
@onready var anim_sprite: AnimatedSprite2D = $Player/AnimatedSprite2D

func _ready() -> void:
	global_position = Vector2(-40, -240)
	add_to_group("Player")
	var trajectory_root := TRAJECTORY_SCENE.instantiate()
	add_child(trajectory_root)
	trajectory = trajectory_root.get_node("Trajectory")
	anim_sprite.play("idle")

func play_attack() -> void:
	is_acting = true
	anim_sprite.play("attack")
	await anim_sprite.animation_finished
	anim_sprite.play("idle")
	is_acting = false

func on_card_hovered() -> void:
	if not is_acting:
		anim_sprite.play("card")

func on_card_exited() -> void:
	if not is_acting:
		anim_sprite.play("idle")

func take_damage(amount: int, bypass_shield: bool = false) -> int:
	var incoming := maxi(amount, 0)
	var absorbed := 0 if bypass_shield else mini(shield_amount, incoming)
	shield_amount -= absorbed
	var damage := mini(health, incoming - absorbed)
	health -= damage
	GameManager.player_health = health
	status_changed.emit()
	is_acting = true
	anim_sprite.play("hit")
	DamageNumberSpawner.spawn(global_position + Vector2(0, -120), damage, DamageNumberSpawner.COLOR_PLAYER)
	await anim_sprite.animation_finished
	anim_sprite.play("idle")
	is_acting = false
	return damage

func heal(amount: int) -> void:
	health = mini(health + maxi(amount, 0), GameManager.max_player_health)
	GameManager.player_health = health
	status_changed.emit()

func apply_shield(amount: int) -> void:
	shield_amount += maxi(amount, 0)
	status_changed.emit()

func receive_poison(amount: int) -> void:
	poison_amount += maxi(amount, 0)
	status_changed.emit()

func receive_weak(turns: int) -> void:
	weak += maxi(turns, 0)
	status_changed.emit()

func apply_effects(effects: Dictionary) -> void:
	if int(effects.cleanse) > 0:
		poison_amount = 0
	strength += int(effects.strength)
	thorns += int(effects.thorns)
	heal(int(effects.heal))
	apply_shield(int(effects.shield))

func begin_turn() -> void:
	# Bloqueio/espinhos duram até o próximo turno do dono; veneno ignora bloqueio.
	shield_amount = 0
	thorns = 0
	if poison_amount > 0:
		await take_damage(poison_amount, true)
		poison_amount = maxi(poison_amount - 1, 0)
	status_changed.emit()

func finish_turn() -> void:
	weak = maxi(weak - 1, 0)
	status_changed.emit()

func attack_damage(base: int) -> int:
	return maxi(int((base + strength) * (0.75 if weak > 0 else 1.0)), 0)

func check_is_alive() -> bool:
	return health > 0

func play_death() -> void:
	anim_sprite.play("hit")
	await get_tree().create_timer(0.5).timeout
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	await tween.finished

func get_player_status() -> Dictionary:
	return {"health":health,"max_health":GameManager.max_player_health,"poison_amount":poison_amount,
		"shield":shield_amount,"strength":strength,"weak":weak,"thorns":thorns}
