class_name AttackComponent
extends Node2D

var data: AttackData
var effect_data: AttackEffectData
var sprite: Sprite2D = null
var audio_component: AudioComponent
var additional_damage: int = 0
@export var arrow: ArrowTelegraph = null
var target_tile: Vector2i
var attack_pending: bool = false

func _ready() -> void:
	GameManager.UpdateBoard.connect(_refresh_telegraph)
	_fetch_data.call_deferred()

func _fetch_data():
	var parent = get_parent()
	if parent is Unit and not parent.data == null:
		data = parent.data.attack_data
		effect_data = parent.data.attack_effect_data
	for child in parent.get_children():
		if child is Controller:
			child.ShootProjectile.connect(_create_command)
		if child is Sprite2D:
			sprite = child
		if child is AudioComponent:
			audio_component = child
	if arrow:
		arrow.hide()

func _shoot_projectile():
	attack_pending = false
	if arrow:
		arrow.hide()
	if data == null:
		return
	if not GameManager.current_board_data.has(target_tile):
		return
	_play_attack_sound()
	_attack_animation()
	var projectile: BaseProjectile = data.projectile_scene.instantiate()
	projectile._set_projectile(get_parent(), global_position, GameManager.current_board.map_to_local(target_tile), data, additional_damage)
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
	attack_pending = true
	if arrow:
		arrow.show()
		var dir: Vector2 = get_parent().global_position.direction_to(GameManager.current_board.map_to_local(target_pos))
		arrow.rotation = dir.angle()
	var cmd = AttackCommand.create(self)
	target_tile = target_pos
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

func _update_target_tile(target_neighbor: TileSet.CellNeighbor):
	if not GameManager.current_board_data.has(target_tile):
		return
	var target_pos = GameManager.current_board.get_neighbor_cell(target_tile, target_neighbor)
	if not GameManager.current_board_data.has(target_pos):
		target_tile = Vector2i.ZERO
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.ENEMY_ATTACK, [target_tile] as Array[Vector2i])
	target_tile = target_pos
	GameManager.ShowTelegraphs.emit(GameManager.Telegraph.ENEMY_ATTACK, [target_tile] as Array[Vector2i])

func _exit_tree() -> void:
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.ENEMY_ATTACK, [target_tile] as Array[Vector2i])

func _refresh_telegraph():
	if attack_pending:
		GameManager.ShowTelegraphs.emit(GameManager.Telegraph.ENEMY_ATTACK, [target_tile] as Array[Vector2i])
