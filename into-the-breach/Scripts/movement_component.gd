class_name MovementComponent
extends Node2D

@warning_ignore("unused_signal")
signal UndoMove

var sprite: Sprite2D
var audio_component: AudioComponent

#get references to required sibling components if avaiable
func _ready() -> void:
	for child in get_parent().get_children():
		if child is Controller:
			child.MoveUnit.connect(_create_command)
		if child is Sprite2D:
			sprite = child
		if child is AudioComponent:
			audio_component = child

func _on_move_unit(target_pos: Vector2i):
	_move_end_animation()
	_play_move_sound()
	get_parent().global_position = GameManager.current_board.map_to_local(target_pos)
	_check_water_tile()
	GameManager.UpdateBoard.emit()
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.MOVE, GameManager.current_board_data.keys() as Array[Vector2i])

#create a command and queue it in the level_manager script via signal
func _create_command (target_pos: Vector2i):
	var cmd = MoveCommand.create(self, target_pos)
	GameManager.QueueCommand.emit(cmd)

#tween based animation that plays when a unit moves to its target position
func _move_end_animation():
	if sprite == null:
		return
	var base_scale = sprite.scale
	var base_offset_y = sprite.offset.y
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_parallel(true)
	tween.tween_property(sprite, "offset:y", base_offset_y - 4, 0.1)
	tween.tween_property(sprite, "scale:y", base_scale.y + 0.2, 0.1)
	tween.tween_property(sprite, "scale:x", base_scale.x - 0.1, 0.1)
	tween.set_parallel(false)
	tween.tween_interval(0.1)
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale:y", base_scale.y - 0.3, 0.1)
	tween.tween_property(sprite, "scale:x", base_scale.x + 0.2, 0.1)
	tween.tween_property(sprite, "offset:y", base_offset_y, 0.2)
	tween.set_parallel(false)
	tween.tween_interval(0.1)
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale:y", base_scale.y, 0.2)
	tween.tween_property(sprite, "scale:x", base_scale.x, 0.2)
	
	
func _play_move_sound():
	if audio_component == null:
		return
	var parent = get_parent()
	if parent is Unit:
		if parent.data:
			audio_component.play_sound_random_pitch(parent.data.move_sound)

func _check_water_tile():
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	var tile_data: TileData = GameManager.current_board.get_cell_tile_data(grid_pos) as TileData
	if tile_data.get_custom_data("is_water"):
		var parent = get_parent()
		if parent == null:
			return
		var unit_data: UnitData = null
		if parent is Unit:
			unit_data = parent.data
		if unit_data == null:
			for sibling in get_parent().get_children():
				if sibling is HealthComponent:
					sibling.take_damage(99)
		else:
			if unit_data.is_flying:
				return
			else:
				for sibling in get_parent().get_children():
					if sibling is HealthComponent:
						sibling.take_damage(99)

func try_push(push_target_tile: TileSet.CellNeighbor):
	var parent: Node2D = get_parent()
	if parent == null:
		return
	var grid_pos: Vector2i = GameManager.current_board.local_to_map(parent.global_position)
	var target_grid_pos: Vector2i = GameManager.current_board.get_neighbor_cell(grid_pos, push_target_tile)
	if not GameManager.current_board_data.has(target_grid_pos):
		return
	
	var target_global_pos: Vector2 = GameManager.current_board.map_to_local(target_grid_pos)
	
	#play push animation toward target tile
	var tween = create_tween()
	tween.tween_property(parent, "global_position", target_global_pos, 0.2)
	
	#check target tile object
	var object: MapObject = GameManager.current_board_data[target_grid_pos].object
	
	#if no object exists, move to tile
	if object == null:
		for child in parent.get_children():
			if child is AttackComponent:
				child._update_target_tile(push_target_tile)
		_on_move_unit(target_grid_pos)
		
	
	#if object exists, animate push back to original tile. damage target tile object and self by 1
	else:
		tween.tween_property(parent, "global_position", GameManager.current_board.map_to_local(grid_pos), 0.2)
		for child in parent.get_children():
			if child is HealthComponent:
				child.take_damage(1)
		for child in object.get_children():
			if child is HealthComponent:
				child.take_damage(1)
		_on_move_unit(grid_pos)
	
