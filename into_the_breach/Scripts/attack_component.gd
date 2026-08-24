class_name AttackComponent
extends Node2D

var data: AttackData
var effect_data: AttackEffectData
var sprite: Sprite2D = null
var audio_component: AudioComponent
var additional_damage: int = 0

func _ready() -> void:
	_fetch_data.call_deferred()

func _fetch_data():
	var parent = get_parent()
	if parent is Unit:
		data = parent.data.attack_data
		effect_data = parent.data.attack_effect_data
	for child in parent.get_children():
		if child is Controller:
			child.ShootProjectile.connect(_create_command)
		if child is Sprite2D:
			sprite = child
		if child is AudioComponent:
			audio_component = child

func _shoot_projectile(target_pos: Vector2i):
	if data == null:
		return
	_play_attack_sound()
	_attack_animation()
	var projectile: BaseProjectile = data.projectile_scene.instantiate()
	projectile._set_projectile(get_parent(), global_position, GameManager.current_board.map_to_local(target_pos), data, additional_damage)
	get_tree().current_scene.add_child(projectile)
	projectile.ProjectileImpact.connect(_on_projectile_impact)

func _on_projectile_impact(impact_tile: Vector2i):
	if effect_data == null:
		return
	if not GameManager.current_board_data.has(impact_tile):
		return
	var pos = GameManager.current_board.local_to_map(global_position)
	effect_data.activate_effect(impact_tile, pos)

func _create_command(target_pos: Vector2i):
	var cmd = AttackCommand.create(self, target_pos)
	GameManager.QueueCommand.emit(cmd)

func _attack_animation():
	if sprite == null:
		return
	var base_scale = sprite.scale
	var base_offset_y = sprite.offset.y
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_parallel(true)
	tween.tween_property(sprite, "scale:y", base_scale.y - 0.3, 0.1)
	tween.tween_property(sprite, "scale:x", base_scale.x + 0.2, 0.1)
	tween.set_parallel(false)
	tween.tween_interval(0.1)
	tween.set_parallel(true)
	tween.tween_property(sprite, "offset:y", base_offset_y - 4, 0.1)
	tween.tween_property(sprite, "scale:y", base_scale.y + 0.2, 0.1)
	tween.tween_property(sprite, "scale:x", base_scale.x - 0.1, 0.1)
	tween.set_parallel(false)
	tween.tween_interval(0.1)
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale:y", base_scale.y, 0.2)
	tween.tween_property(sprite, "scale:x", base_scale.x, 0.2)
	tween.tween_property(sprite, "offset:y", base_offset_y, 0.2)
	
func _play_attack_sound():
	if audio_component == null:
		return
	if data == null:
		return
	audio_component.play_sound_random_pitch(data.attack_sound)

func _flash():
	if sprite == null:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "material:shader_parameter/progress_white", 1.0, 0.07)
	tween.tween_property(sprite, "material:shader_parameter/progress_white", 0, 0.2)
