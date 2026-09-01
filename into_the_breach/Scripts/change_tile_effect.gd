class_name ChangeTileEffect
extends AttackEffectData

@export var target_tile_atlas_coords: Vector2i = Vector2i(0, 10)

func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	if GameManager.current_board_data[target_tile].object:
		return
	if GameManager.current_board_data[target_tile].hazard:
		GameManager.current_board_data[target_tile].hazard._destroy_tile()
	GameManager.ShakeCamera.emit()
	GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.DUST, target_tile)
	GameManager.current_board.set_cell(target_tile, 0, target_tile_atlas_coords)
