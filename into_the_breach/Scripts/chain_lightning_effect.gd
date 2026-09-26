class_name ChainLightningEffect
extends AttackEffectData

@warning_ignore("unused_parameter")
func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	var targets: Array[MapObject] = []
	
	#get all targets connected to the impact tile
	_check_surrounding_targets(target_tile, targets)
	
	#exclude the initial target from the list of targets to damage
	if GameManager.current_board_data[target_tile].object:
		if targets.has(GameManager.current_board_data[target_tile].object):
			targets.erase(GameManager.current_board_data[target_tile].object)
	
	#deal damage to each target in the array
	#short 0.05s delay between each loop to give the illusion of lightning bouncing between targets
	for target in targets:
		for child in target.get_children():
			if child is HealthComponent:
				child.take_damage(1)
				GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.CHAIN_LIGHTNING, GameManager.current_board.local_to_map(target.global_position))
				await target.get_tree().create_timer(0.05).timeout

#recursive function that takes a start coord and an empty array as parameters
#the array is appended with all the map objects that are adjacent to each other, beginning at the start coords
#the resulting array is a collection of map object directly or indirectly linked to the start coords
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
	
