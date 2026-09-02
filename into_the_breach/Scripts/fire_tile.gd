extends HazardTile

@export var damage_amount: int = 1

func _on_turn_start(_turn: GameManager.TurnState):
	if GameManager.current_board == null:
		return
	if GameManager.current_board_data.is_empty():
		return
	if _turn == GameManager.TurnState.PLAYER:
		return
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if GameManager.current_board_data[grid_pos].object:
		var object: MapObject = GameManager.current_board_data[grid_pos].object
		for child in object.get_children():
			if child is HealthComponent:
				child.take_damage(damage_amount)
