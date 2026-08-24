class_name ChainLightningEffect
extends AttackEffectData

func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	for tile in GameManager.current_board.get_surrounding_cells(target_tile):
		if not GameManager.current_board_data.has(tile):
			continue
		var tile_object = GameManager.current_board_data[tile].object
		if tile_object == null:
			continue
		GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.CHAIN_LIGHTNING, target_tile, tile)
