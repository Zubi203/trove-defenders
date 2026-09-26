class_name AreaPush
extends AttackEffectData

var push_directions: Array[TileSet.CellNeighbor] = [
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE
]

@warning_ignore("unused_parameter")

#push targets on surrounding tiles
func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	
	#get an array of adjacent tiles in 4 cardinal directions
	var surrounding_cells: Array[Vector2i] = GameManager.current_board.get_surrounding_cells(target_tile)
	for cell in surrounding_cells:
		if not GameManager.current_board_data.has(cell):
			continue
		var object: MapObject = GameManager.current_board_data[cell].object
		if object == null:
			continue
		
		#get push direction based on which side of the original tile
		#the adjacent tile lies on
		var cell_neighbor_target: TileSet.CellNeighbor
		for dir in push_directions:
			if cell == GameManager.current_board.get_neighbor_cell(target_tile, dir):
				cell_neighbor_target = dir
				break
		
		#call push function in the target's attached movement component
		for child in object.get_children():
			if child is MovementComponent:
				child.try_push(cell_neighbor_target)
	GameManager.ShakeCamera.emit()
	GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.PUSH, target_tile)
