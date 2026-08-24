class_name PotionSpawnEffect
extends AttackEffectData

func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	var spawnable_cells: Array[Vector2i] = []
	if not GameManager.current_board_data.has(target_tile):
		return
	if GameManager.current_board_data[target_tile].object == null:
		GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.POTION, target_tile)
		return
	for tile in GameManager.current_board.get_surrounding_cells(target_tile):
		if not GameManager.current_board_data.has(tile):
			continue
		if GameManager.current_board_data[tile].object == null:
			spawnable_cells.append(tile)
	GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.POTION, spawnable_cells.pick_random())
