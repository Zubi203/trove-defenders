extends HazardTile

@export var damage_amount: int = 1

#at the start of every enemy turn, if a unit is on the same grid coords as this tile, deal damage to it
func _on_turn_start(_turn: GameManager.TurnState):
	#if board doesnt exist, cancel execution
	if GameManager.current_board == null:
		return
	#if board tile data is null, cancel execution
	if GameManager.current_board_data.is_empty():
		return
	#if its the player's turn, cancel execution
	if _turn == GameManager.TurnState.PLAYER:
		return
	
	#check for map object on this tile
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if GameManager.current_board_data[grid_pos].object:
		var object: MapObject = GameManager.current_board_data[grid_pos].object
		#if the map object on this tile has a health component, deal damage to it
		for child in object.get_children():
			if child is HealthComponent:
				child.take_damage(damage_amount)
