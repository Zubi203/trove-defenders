extends PointProjectile

func _set_data():
	pass

func _point_projectile_animation():
	_disable_collider()
	$AnimationPlayer.play("dark_energy")
	await $AnimationPlayer.animation_finished
	_impact(global_position)
