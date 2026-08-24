extends PointProjectile


func _point_projectile_animation():
	_disable_collider()
	sprite.offset.y -= 10
	var base_scale = sprite.scale
	sprite.scale.y = 0
	global_position = GameManager.current_board.map_to_local(target_cell)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(_enable_collider)
	tween.tween_property(sprite, "scale:y", base_scale.y, animation_duration * 0.8)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(sprite, "modulate:a", 0, animation_duration * 0.2)
	tween.tween_callback(_impact)
