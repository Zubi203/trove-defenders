extends PointProjectile


func _point_projectile_animation():
	_disable_collider()
	sprite.scale = Vector2.ZERO
	var base_offset = sprite.offset
	global_position = GameManager.current_board.map_to_local(target_cell)
	var tween = get_tree().create_tween()
	tween.tween_callback(_enable_collider)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween.tween_property(sprite, "scale:x", 0.6, animation_duration * 0.6)
	tween.tween_property(sprite, "scale:y", 1, animation_duration * 0.6)
	tween.set_parallel(false)
	tween.tween_interval(animation_duration * 0.8)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(sprite, "scale:y", 0, animation_duration * 0.4)
	tween.tween_property(sprite, "offset:y", base_offset.y - 10, animation_duration * 0.4)
	tween.tween_callback(_impact)
