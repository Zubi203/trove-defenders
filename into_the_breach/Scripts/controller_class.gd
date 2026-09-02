class_name Controller
extends Node2D

@warning_ignore_start("unused_signal")
signal MoveUnit (target_pos: Vector2)
signal ShootProjectile (target_pos: Vector2i)
signal HealSelf (amount: int)

var is_ensnared: bool = false
@export var sprite: Sprite2D
var base_sprite_offset: Vector2
var base_sprite_scale: Vector2

func _try_get_sprite():
	var parent = get_parent()
	for sibling in parent.get_children():
		if sibling is Sprite2D:
			sprite = sibling
			base_sprite_offset = sprite.offset
			base_sprite_scale = sprite.scale
	GameManager.UpdateBoard.connect(try_remove_snare)

func _move_start_animation():
	if sprite == null:
		return
	sprite.scale = base_sprite_scale
	sprite.offset = base_sprite_offset
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "offset:y", base_sprite_offset.y - 6, 0.1)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y + 0.1, 0.1)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x - 0.1, 0.1)
	tween.set_parallel(false)
	tween.tween_interval(0.1)
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y, 0.1)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x, 0.1)
	tween.set_parallel(false)
	tween.tween_property(sprite, "offset:y", base_sprite_offset.y, 0.1)
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y - 0.1, 0.1)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x + 0.1, 0.1)
	tween.set_parallel(false)
	tween.tween_interval(0.1)
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y, 0.1)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x, 0.1)

func _on_spawn_animation():
	if sprite == null:
		return
	sprite.scale = base_sprite_scale
	sprite.offset = base_sprite_offset
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y - 0.2, 0.05)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x + 0.2, 0.05)
	tween.set_parallel(false)
	tween.tween_interval(0.05)
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y, 0.1)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x, 0.1)
	for sibling in get_parent().get_children():
		if sibling is MovementComponent:
			sibling._play_move_sound()

func ensnare():
	is_ensnared = true
	

func try_remove_snare():
	var grid_pos: Vector2i = GameManager.current_board.local_to_map(get_parent().global_position)
	if not GameManager.current_board_data.has(grid_pos):
		return
	if not GameManager.current_board_data[grid_pos].hazard is SnareTile:
		is_ensnared = false
	
