class_name SinglePush
extends AttackEffectData

var push_directions: Array[TileSet.CellNeighbor] = [
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE
]

func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	var object: MapObject = GameManager.current_board_data[target_tile].object
	var cell_neighbor_target: TileSet.CellNeighbor
	for dir in push_directions:
		var tiles: Array[Vector2i] = GameManager._get_tiles_straight_line(attacker_pos, 10, dir)
		if tiles.has(target_tile):
			cell_neighbor_target = dir
			break
	if object == null:
		return
	
	for child in object.get_children():
		if child is MovementComponent:
			child.try_push(cell_neighbor_target)
