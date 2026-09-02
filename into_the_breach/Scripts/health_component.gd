class_name HealthComponent
extends Node2D

signal HealthDepleted

@export var override_hit_sound: AudioStream = null
@export var override_heal_sound: AudioStream = null
var audio_component: AudioComponent = null
var unit_data: UnitData = null

@export var number_effect: PackedScene
@export var default_max_health: int = 2
var max_health: int = 2:
	set(value):
		max_health = value
		health = max_health
var health: int:
	set(value):
		health = value
		if health_bar:
			health_bar.current_value = health
		if health <= 0:
			HealthDepleted.emit()
			defeated()
var health_bar: HealthBar = null

var sprite: Sprite2D
@export var shake_magnitude: float = 1

func _ready() -> void:
	for child in get_parent().get_children():
		if child is HealthBar:
			health_bar = child
		if child is Controller:
			child.HealSelf.connect(heal)
		if child is Sprite2D:
			sprite = child
		if child is AudioComponent:
			audio_component = child
	_set_health.call_deferred()

func _set_health():
	var parent = get_parent()
	if parent is Unit:
		if parent.data != null:
			unit_data = parent.data
			max_health = parent.data.health
	else:
		max_health = default_max_health
	if health_bar == null:
		return
	health_bar.max_value = max_health
	health_bar.current_value = max_health

func take_damage(amount: int):
	health -= amount
	GameManager.ShakeCamera.emit()
	_spawn_number(-amount)
	_play_damage_sound()
	_damage_animation(amount)
	_flash()

func heal(amount: int):
	_flash(true)
	_play_heal_sound()
	if health <= max_health:
		health += amount
	_spawn_number(amount)


func _spawn_number(hp_change: int):
	if number_effect == null:
		return
	var num: NumberEffect = number_effect.instantiate()
	num.position = position
	get_parent().add_child(num)
	var is_positive: bool = true if hp_change > 0 else false
	var operand = "+" if hp_change > 0 else ""
	num.animate(operand + str(hp_change), is_positive)

func defeated():
	var parent = get_parent()
	if parent is MapObject:
		GameManager.ObjectDestroyed.emit.call_deferred(parent)
	if unit_data:
		GameManager.last_defeated_unit = unit_data
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 0.2)
	tween.tween_callback(parent.queue_free)
	

func _heal_animation():
	if sprite == null:
		return

func _damage_animation(multiplier: int):
	if sprite == null:
		return
	var tween = get_tree().create_tween()
	var shake_amount = clamp(shake_magnitude * multiplier, 0, 3)
	tween.set_loops(3)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "offset:x", shake_amount, 0.02)
	tween.tween_property(sprite, "offset:x", -shake_amount, 0.04)
	tween.tween_property(sprite, "offset:x", 0, 0.02)

func _flash(is_heal: bool = false):
	if sprite == null:
		return
	var tween = get_tree().create_tween()
	if not is_heal:
		if sprite.material:
			tween.tween_property(sprite, "material:shader_parameter/progress_white", 1.0, 0.07)
			tween.tween_property(sprite, "material:shader_parameter/progress_white", 0, 0.2)
	else:
		if sprite.material:
			tween.tween_property(sprite, "material:shader_parameter/progress_green", 1.0, 0.07)
			tween.tween_property(sprite, "material:shader_parameter/progress_green", 0, 0.2)

func _play_heal_sound():
	if audio_component == null:
		return
	var sound: AudioStream = null
	if override_heal_sound:
		sound = override_heal_sound
	else:
		if unit_data:
			sound = unit_data.heal_sound
	audio_component.play_sound_random_pitch(sound)

func _play_damage_sound():
	if audio_component == null:
		return
	var sound: AudioStream = null
	if override_hit_sound:
		sound = override_hit_sound
	else:
		if unit_data:
			sound = unit_data.hit_sound
	audio_component.play_sound_random_pitch(sound)
