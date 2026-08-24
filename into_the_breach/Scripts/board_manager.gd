extends Node2D

@export var tile_map: TileMapLayer
@export var hover_cursor: Sprite2D
@export var select_cursor: Sprite2D
@export var telegraph_container: Node2D
@export var telegraph_textures: Dictionary[GameManager.Telegraph, Texture2D] = {
	GameManager.Telegraph.MOVE: null,
	GameManager.Telegraph.ATTACK: null,
	GameManager.Telegraph.SPAWN: null,
	GameManager.Telegraph.ENEMY_ATTACK: null
}
var selected_object: MapObject = null
var hovered_tile: Vector2i


func _ready() -> void:
	if tile_map == null:
		return
	
	GameManager.current_board = tile_map
	GameManager.ShowTelegraphs.connect(telegraph_tiles)
	GameManager.HideTelegraphs.connect(clear_telegraph)
	GameManager.UpdateBoard.connect(_update_board)
	GameManager.ObjectDestroyed.connect(_update_board)
	GameManager.TurnEnd.connect(_on_turn_end)
	_update_board()
	
	for cell in tile_map.get_used_cells():
		for key in telegraph_textures.keys():
			_spawn_telegraph_tile(key, cell)

func _spawn_telegraph_tile(type: GameManager.Telegraph, tile: Vector2i):
	if telegraph_container == null:
		return
	var tile_sprite: Sprite2D = Sprite2D.new()
	tile_sprite.texture = telegraph_textures[type]
	telegraph_container.add_child(tile_sprite)
	tile_sprite.global_position = tile_map.map_to_local(tile)
	tile_sprite.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and GameManager.current_turn == GameManager.TurnState.PLAYER:
		if hovered_tile.length():
			_select_tile(hovered_tile)
		else:
			_deselect_tile()
	if event is InputEventMouseMotion:
		hovered_tile = _get_hovered_tile()

func _get_hovered_tile() -> Vector2i:
	if hover_cursor == null:
		return Vector2i.ZERO
	var cursor_pos = tile_map.local_to_map(get_global_mouse_position())
	if GameManager.current_board_data.keys().has(cursor_pos):
		hover_cursor.show()
		hover_cursor.global_position = tile_map.map_to_local(cursor_pos)
		return cursor_pos
	else:
		hover_cursor.hide()
		return Vector2i.ZERO

func _try_select_unit(unit: Unit):
	for child in unit.get_children():
		if child is PlayerController:
			selected_object = unit
			if child.current_state == PlayerController.State.NOT_SELECTED:
				child.select()
				if select_cursor:
					select_cursor.show()
					select_cursor.global_position = selected_object.global_position
			break
		_deselect_tile()

func _select_tile(coords: Vector2i):
	if GameManager.current_board_data[coords].object and GameManager.current_board_data[coords].object is Unit:
		_try_select_unit(GameManager.current_board_data[coords].object)
	else:
		_deselect_tile()

func _deselect_tile():
	if selected_object == null:
		return
	for child in selected_object.get_children():
		if child is PlayerController:
			child.deselect()
	selected_object = null
	if select_cursor:
		select_cursor.hide()

func _update_board(_obj: MapObject = null):
	# clear and reset the board
	GameManager.current_board_data.clear()
	for cell in tile_map.get_used_cells():
		GameManager.current_board_data[cell] = GameManager.TileInfo.new()
	
	# check units and objects
	for object: MapObject in get_tree().get_nodes_in_group("MapObject"):
		var object_grid_pos = tile_map.local_to_map(object.global_position)
		for key in GameManager.current_board_data.keys():
			if object_grid_pos == key:
				GameManager.current_board_data[key].object = object
				object.global_position = tile_map.map_to_local(object_grid_pos)
			
	# check hazards
	for tile: HazardTile in get_tree().get_nodes_in_group("HazardTile"):
		var tile_grid_pos = tile_map.local_to_map(tile.global_position)
		for key in GameManager.current_board_data.keys():
			if tile_grid_pos == key:
				GameManager.current_board_data[key].hazard = tile
				tile.global_position = tile_map.map_to_local(tile_grid_pos)

func _execute_hazard_tiles():
	pass

func telegraph_tiles(telegraph_type: GameManager.Telegraph, tiles: Array[Vector2i]):
	if telegraph_container == null:
		return
	if telegraph_textures[telegraph_type] == null:
		return
	
	for tile in tiles:
		for telegraph: Sprite2D in telegraph_container.get_children():
			if telegraph_textures[telegraph_type] == telegraph.texture and tile_map.local_to_map(telegraph.global_position) == tile:
				telegraph.visible = true

func clear_telegraph(telegraph_type: GameManager.Telegraph, tiles: Array[Vector2i]):
	if telegraph_container == null:
		return
	for tile in tiles:
		for child: Sprite2D in telegraph_container.get_children():
			if tile_map.local_to_map(child.global_position) == tile and child.texture == telegraph_textures[telegraph_type]:
				child.visible = false

func _on_turn_end(turn: GameManager.TurnState):
	match turn:
		GameManager.TurnState.PLAYER:
			_deselect_tile()
