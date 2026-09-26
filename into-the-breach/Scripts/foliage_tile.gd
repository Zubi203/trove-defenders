extends HazardTile


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is BaseProjectile:
		#delete this tile if a projectile hits it,and spawn a fire tile
		var grid_pos = GameManager.current_board.local_to_map(global_position)
		GameManager.SpawnHazardTile.emit(HazardTileManager.HazardTiles.FIRE, grid_pos)
		_destroy_tile()
