class_name ChainLightningEffect
extends AttackEffectData

@warning_ignore("unused_parameter")
func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	var targets: Array[MapObject] = []
	_check_surrounding_targets(target_tile, targets)
	if GameManager.current_board_data[target_tile].object:
		if targets.has(GameManager.current_board_data[target_tile].object):
			targets.erase(GameManager.current_board_data[target_tile].object)
	for target in targets:
		for child in target.get_children():
			if child is HealthComponent:
				child.take_damage(1)
				GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.CHAIN_LIGHTNING, GameManager.current_board.local_to_map(target.global_position))
				await target.get_tree().create_timer(0.05).timeout

func _check_surrounding_targets(target_tile: Vector2i, current_targets: Array[MapObject]):
	for tile in GameManager.current_board.get_surrounding_cells(target_tile):
		if not GameManager.current_board_data.has(tile):
			continue
		var tile_object: MapObject = GameManager.current_board_data[tile].object
		if tile_object == null:
			continue
		if current_targets.has(tile_object):
			continue
		current_targets.append(tile_object)
		_check_surrounding_targets(tile, current_targets)
	
