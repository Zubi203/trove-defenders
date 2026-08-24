extends PointProjectile



func _point_projectile_animation():
	_disable_collider()
	sprite.scale = Vector2.ZERO
	global_position = GameManager.current_board.map_to_local(target_cell)
	var tween = get_tree().create_tween()
	tween.tween_callback(_enable_collider)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween.tween_property(sprite, "scale:x", 1, animation_duration * 0.8)
	tween.tween_property(sprite, "scale:y", 1, animation_duration * 0.6)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_parallel(false)
	tween.tween_property(sprite, "modulate:a", 0, animation_duration * 0.2)
	tween.tween_callback(_impact)
