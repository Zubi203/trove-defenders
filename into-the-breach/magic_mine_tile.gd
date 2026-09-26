extends HazardTile

@export var projectile_data: AttackData

func _spawn_projectile(target_pos: Vector2i):
	if projectile_data == null:
		return
	var projectile: BaseProjectile = projectile_data.projectile_scene.instantiate()
	projectile._set_projectile(null, global_position, GameManager.current_board.map_to_local(target_pos), projectile_data)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = GameManager.current_board.map_to_local(target_pos)

func _destroy_tile():
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	var target_tiles: Array[Vector2i] = GameManager._get_tiles_cross_pattern(grid_pos, 10)
	target_tiles.append(grid_pos)
	GameManager.ShakeCamera.emit()
	for tile in target_tiles:
		_spawn_projectile(tile)
	queue_free()
