class_name ChainLightning
extends BaseProjectile

func _ready() -> void:
	_disable_collider.call_deferred()

func _move(_delta: float):
	translate(target_direction * speed * _delta)

func _on_area_entered(area: Area2D):
	if area == owner_object:
		return
	if area is MapObject:
		for child in area.get_children():
			if child is HealthComponent:
				child.take_damage(1)
				var target_tile = GameManager.current_board.local_to_map(area.global_position)
				for tile in GameManager.current_board.get_surrounding_cells(target_tile):
					if not GameManager.current_board_data.has(tile):
						continue
					var tile_object = GameManager.current_board_data[tile].object
					if tile_object == null:
						continue
					GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.CHAIN_LIGHTNING, target_tile, tile, area)
		_impact()

func _check_range_end():
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if target_cell_entered:
		if collider.disabled:
			_enable_collider.call_deferred()
		if grid_pos != target_cell:
			_impact()
	else:
		target_cell_entered = grid_pos == target_cell

func _impact():
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if not attack_data.is_piercing or not GameManager.current_board_data.has(grid_pos):
		_disable_collider.call_deferred()
		set_process(false)
		set_physics_process(false)
		await get_tree().create_timer(0.05).timeout
		queue_free()
