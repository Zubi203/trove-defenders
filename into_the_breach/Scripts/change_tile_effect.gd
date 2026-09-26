class_name ChangeTileEffect
extends AttackEffectData

@export var target_tile_atlas_coords: Vector2i = Vector2i(0, 10)

func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	#if target tile has a unit or object on it, cancel execution
	if GameManager.current_board_data[target_tile].object:
		return
	
	#if target tile has a hazard tile on it, delete the hazard tile
	if GameManager.current_board_data[target_tile].hazard:
		GameManager.current_board_data[target_tile].hazard.queue_free()
		GameManager.current_board_data[target_tile].hazard = null
	
	#change target tile to the altas coords assigned in the export var
	GameManager.ShakeCamera.emit()
	GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.DUST, target_tile)
	GameManager.current_board.set_cell(target_tile, 0, target_tile_atlas_coords)
	GameManager.UpdateBoard.emit()
