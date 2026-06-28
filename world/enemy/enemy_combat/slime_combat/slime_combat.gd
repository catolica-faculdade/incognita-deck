extends Node2D

@export var idle_height := 8.0
@export var idle_speed := 2.0
@export var attack_distance := 40.0
@export var attack_time := 0.15

var base_damage := 10
var health := 30
var shield := 0
var poison := 3
var apply_block := 3
var apply_defend := 7
var heal_amount := 3
var self_heal_amount := 5
var start_position: Vector2
var is_attacking := false
var max_health := 30

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sound: AudioStreamPlayer = $AttackSound
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var hit_shield_sound: AudioStreamPlayer = $HitShieldSound
@onready var heal_sound: AudioStreamPlayer = $HealSound
@onready var poison_sound: AudioStreamPlayer = $PoisonSound
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var hud: Node2D = $EnemyHud

func _ready():
	start_position = position
	anim_sprite.flip_h = false
	anim_sprite.play("idle")
	hud.setup(health, max_health)

func _process(_delta):
	if not is_attacking:
		position.y = start_position.y + sin(Time.get_ticks_msec() / 1000.0 * idle_speed) * idle_height

func choose_action():
	shield = 0
	var action = randi_range(0, 100)
	if action < 50:
		await attack()
	elif action < 80:
		await applyPoison()
	else:
		heal()

func heal(amount := self_heal_amount):
	health = min(health + self_heal_amount, max_health)
	heal_sound.play()
	hud.update_hp(health)
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

func apply_shield(amount):
	shield += amount
	hud.update_shield(0)
	hud.update_shield(shield)
	await play_effect_animation()

func applyPoison():
	var player = get_tree().get_first_node_in_group("Player")
	is_attacking = true
	anim_sprite.play("attack")
	poison_sound.play()

	var tween := create_tween()
	tween.tween_property(self, "position:x", start_position.x + 40, 0.15)
	tween.tween_property(self, "position:x", start_position.x - 40, 0.12)
	tween.tween_callback(func():
		if player:
			player.receive_poison(poison)
	)
	tween.tween_property(self, "position:x", start_position.x, 0.15)
	await tween.finished

	is_attacking = false
	anim_sprite.play("idle")

func check_is_alive():
	if health <= 0:
		return false
	return true

func take_damage(amount):
	is_attacking = true
	anim_sprite.play("hit")
	var shield_before := shield

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
	
	hud.update_hp(health)
	hud.update_shield(shield)
	DamageNumberSpawner.spawn(global_position + Vector2(0, -150), amount, DamageNumberSpawner.COLOR_ENEMY)
	
	if health <= 0:
		remove_from_group("enemies")
		hit_sound.stop()
		hit_shield_sound.stop()
		death_sound.play()
		await get_tree().create_timer(3.0).timeout
		death_sound.stop()
		queue_free()
		return

	if shield_before > 0:
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
