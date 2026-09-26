class_name SnareTile
extends HazardTile


func tile_setup():
	GameManager.UpdateBoard.connect(_check_unit_on_tile)
	_check_unit_on_tile()

func _check_unit_on_tile():
	#if a unit is on this tile, disable its movement
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if not GameManager.current_board_data.has(grid_pos):
		return
	if not GameManager.current_board_data[grid_pos].object:
		return
	var target_object: MapObject = GameManager.current_board_data[grid_pos].object
	for child in target_object.get_children():
		if child is Controller:
			child.ensnare()

func _destroy_tile():
	#enable movement on any unit that was standing on this tile when it is destroyed
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if not GameManager.current_board_data.has(grid_pos):
		return
	if not GameManager.current_board_data[grid_pos].object:
		return
	var target_object: MapObject = GameManager.current_board_data[grid_pos].object
	for child in target_object.get_children():
		if child is Controller:
			child.is_ensnared = false
	queue_free()
