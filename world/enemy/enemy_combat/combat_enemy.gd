extends Node2D
## As intenções são escolhidas antes do turno e executadas sem novo sorteio oculto.

@export var idle_height := 6.0
@export var idle_speed := 2.0
@export var attack_distance := 40.0
@export var attack_time := 0.15
var max_health := 20
var base_damage := 7
var poison := 3
var apply_block := 4
var apply_defend := 7
var heal_amount := 5
var self_heal_amount := 5
var display_name := "Inimigo"
var combat_name := ""
var health: int
var shield := 0
var poison_amount := 0
var vulnerable := 0
var strength := 0
var turns_taken := 0
var start_position: Vector2
var is_attacking := false
var flip_on_attack := false
var planned_action := "attack"
var rng := RandomNumberGenerator.new()
var enemy_seed := 1
var difficulty_tier := 1
var is_dying := false
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hud: Node2D = $EnemyHud

func configure_archetype() -> void:
	pass

func _ready() -> void:
	# Aplicar o perfil depois das propriedades da PackedScene herdada.
	configure_archetype()
	rng.seed = enemy_seed
	max_health = int(max_health * (1.0 + (difficulty_tier - 1) * 0.15))
	base_damage += difficulty_tier - 1
	health = max_health
	start_position = position
	anim_sprite.flip_h = false
	anim_sprite.modulate = Color.WHITE
	anim_sprite.play("idle")
	add_to_group("enemies")
	hud.setup(health, max_health)
	plan_next_action()
	_refresh_hud()

func _process(_delta: float) -> void:
	hud.scale = Vector2(1.0 / scale.x, 1.0 / scale.y)
	var texture := anim_sprite.sprite_frames.get_frame_texture(anim_sprite.animation, anim_sprite.frame)
	var half_height := float(texture.get_height()) * absf(anim_sprite.scale.y * scale.y) * 0.5
	var half_width := float(texture.get_width()) * absf(anim_sprite.scale.x * scale.x) * 0.5
	var header_at := anim_sprite.global_position + Vector2(-56, -half_height - 20.0)
	var top_limit := get_canvas_transform().affine_inverse() * Vector2(0, 118)
	header_at.y = maxf(header_at.y, top_limit.y)
	hud.global_position = header_at
	hud.track_body(Rect2(anim_sprite.global_position - Vector2(half_width, half_height), Vector2(half_width * 2, half_height * 2)))
	if not is_attacking and check_is_alive():
		position.y = start_position.y + sin(Time.get_ticks_msec() / 1000.0 * idle_speed) * idle_height

func check_is_alive() -> bool:
	return health > 0 and not is_dying

func choose_action() -> String:
	return "attack"

func plan_next_action() -> void:
	planned_action = choose_action()
	_refresh_hud()

func intent_text() -> String:
	match planned_action:
		"attack": return "Ataque %d" % (base_damage + strength)
		"heavy": return "Ataque forte %d" % ((base_damage + strength) * 2)
		"drain": return "Drenar %d + cura" % (base_damage + strength)
		"defend": return "Escudo +%d" % apply_defend
		"guard_all": return "Protege todos +%d" % apply_block
		"poison": return "Veneno +%d" % poison
		"heal_all": return "Cura aliados +%d" % heal_amount
		"heal": return "Cura +%d" % self_heal_amount
		"weak": return "Fraqueza: 2 turnos"
		"charge": return "Força +3"
		"teleport": return "Teleporte + escudo"
	return planned_action

func take_turn() -> void:
	if not check_is_alive():
		return
	shield = 0
	if poison_amount > 0:
		var tick := poison_amount
		poison_amount = maxi(poison_amount - 1, 0)
		await take_damage(tick, true, false)
		if not check_is_alive():
			return
	_refresh_hud()
	match planned_action:
		"attack": await attack()
		"heavy": await _attack_player(false, 2)
		"drain":
			var damage: int = await _attack_player(false)
			if check_is_alive():
				await heal(maxi(int(damage / 2.0), 1))
		"defend": await defend()
		"guard_all": await defend_all()
		"poison": await apply_poison()
		"heal": await heal()
		"heal_all": await apply_all_heal()
		"weak":
			var player = get_tree().get_first_node_in_group("Player")
			player.receive_weak(2)
			await play_effect_animation()
		"charge":
			strength += 3
			await play_effect_animation()
		"teleport":
			await defend()
			await after_surviving_hit()
	vulnerable = maxi(vulnerable - 1, 0)
	turns_taken += 1
	if check_is_alive():
		plan_next_action()

func attack() -> void:
	await _attack_player(false)

func apply_poison() -> void:
	await _attack_player(true)

func _attack_player(with_poison: bool, multiplier: int = 1) -> int:
	var player = get_tree().get_first_node_in_group("Player")
	if is_attacking or not check_is_alive() or not is_instance_valid(player):
		return 0
	is_attacking = true
	anim_sprite.flip_h = flip_on_attack
	anim_sprite.play("attack")
	_play_sound("PoisonSound" if with_poison else "AttackSound")
	var tween := create_tween()
	tween.tween_property(self, "position:x", start_position.x + attack_distance, attack_time)
	tween.tween_property(self, "position:x", start_position.x - attack_distance, 0.12)
	await tween.finished
	var dealt := 0
	if with_poison:
		player.receive_poison(poison)
	else:
		dealt = await player.take_damage((base_damage + strength) * multiplier)
	tween = create_tween()
	tween.tween_property(self, "position:x", start_position.x, attack_time)
	await tween.finished
	anim_sprite.flip_h = false
	anim_sprite.play("idle")
	is_attacking = false
	if not with_poison and player.thorns > 0:
		await take_damage(player.thorns, true, false)
	return dealt

func heal(amount: int = -1) -> void:
	if not check_is_alive():
		return
	var recovery := self_heal_amount if amount < 0 else amount
	health = mini(health + maxi(recovery, 0), max_health)
	_play_sound("HealSound")
	_refresh_hud()
	await play_effect_animation()

func apply_shield(amount: int) -> void:
	if check_is_alive():
		shield += maxi(amount, 0)
		_refresh_hud()
		await play_effect_animation()

func defend() -> void:
	await apply_shield(apply_defend)

func defend_all() -> void:
	await play_effect_animation()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.check_is_alive():
			await enemy.apply_shield(apply_block)

func apply_all_heal() -> void:
	_play_sound("HealSound")
	await play_effect_animation()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.check_is_alive():
			await enemy.heal(heal_amount)

func receive_poison(amount: int) -> void:
	poison_amount += maxi(amount, 0)
	_refresh_hud()

func receive_vulnerable(amount: int) -> void:
	vulnerable += maxi(amount, 0)
	_refresh_hud()

func take_damage(amount: int, bypass_shield: bool = false, react: bool = true) -> void:
	if not check_is_alive():
		return
	is_attacking = true
	anim_sprite.play("hit")
	var incoming := maxi(amount, 0)
	if vulnerable > 0 and react:
		incoming = int(incoming * 1.5)
	var absorbed := 0 if bypass_shield else mini(shield, incoming)
	shield -= absorbed
	var damage := mini(health, incoming - absorbed)
	health -= damage
	_refresh_hud()
	DamageNumberSpawner.spawn(global_position + Vector2(0, -110), damage, DamageNumberSpawner.COLOR_ENEMY)
	_play_sound("HitShieldSound" if absorbed > 0 else "HitSound")
	await animate_hit()
	if health <= 0:
		is_dying = true
		remove_from_group("enemies")
		_play_sound("DeathSound")
		await get_tree().create_timer(0.6).timeout
		queue_free()
		return
	if react:
		await after_surviving_hit()
	anim_sprite.play("idle")
	is_attacking = false

func animate_hit() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", start_position.x + 20, 0.12)
	tween.tween_property(self, "position:x", start_position.x, 0.12)
	await tween.finished

func after_surviving_hit() -> void:
	pass

func play_effect_animation() -> void:
	is_attacking = true
	var original_x := position.x
	var tween := create_tween()
	tween.tween_property(self, "position:x", original_x + 8, 0.04)
	tween.tween_property(self, "position:x", original_x - 8, 0.04)
	tween.tween_property(self, "position:x", original_x, 0.04)
	await tween.finished
	is_attacking = false

func lock() -> void:
	modulate = Color(1.0, 0.65, 0.65)

func unlock() -> void:
	modulate = Color.WHITE

func _refresh_hud() -> void:
	if not is_instance_valid(hud):
		return
	hud.update_hp(health)
	hud.update_shield(shield)
	hud.update_poison(poison_amount)
	hud.update_name(combat_name if not combat_name.is_empty() else display_name)

func _play_sound(node_name: String) -> void:
	var sound := get_node_or_null(node_name) as AudioStreamPlayer
	if sound:
		sound.play()
