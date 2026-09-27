extends Node

# --------------------------- Global signals ------------------------------

@warning_ignore_start("unused_signal")
signal ShowTelegraphs (telegraph_type: Telegraph, tiles: Array[Vector2i])
signal HideTelegraphs (telegraph_type: Telegraph, tiles: Array[Vector2i])
signal UpdateBoard
signal UpdateUnitCard (unit: UnitData)
signal QueueCommand (cmd: Command)
signal GameOver (player_won: bool)
signal ObjectDestroyed (object: MapObject)
signal TurnStart (turn: TurnState)
signal TurnEnd (turn: TurnState)
signal ActionsDepleted
signal ShakeCamera
signal ToggleUndoButton (toggle_on: bool)
signal UndoButtonPressed
signal SpawnHazardTile (tile_type: HazardTileManager, grid_pos: Vector2i)
signal ShowSettingsMenu
signal SpawnAttackEffect (effect_type: AttackEffectManager.AttackEffects, target_tile: Vector2i, direction: Vector2i, target_object: MapObject)
signal ForceStopScreenShake

enum TurnState {
	START,
	PLAYER,
	ENEMY
}

enum Scenes {
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	LEVEL_4,
	LEVEL_5,
	LEVEL_6,
	TITLE_SCREEN,
	TEAM_SELECT,
	LEVEL_SELECT,
	END_SCREEN
}

var current_scene: Scenes
const SCENE_PATHS: Dictionary[Scenes, String] = {
	Scenes.LEVEL_1 : "uid://dcgep28qdrops",
	Scenes.LEVEL_2 : "uid://mcvujja50cf8",
	Scenes.LEVEL_3 : "uid://cnwrpup71ddyu",
	Scenes.LEVEL_4 : "uid://c3txvb2py3i8i",
	Scenes.LEVEL_5 : "uid://b3yrjd58d1gpt",
	Scenes.LEVEL_6 : "uid://xkbja6xkk27",
	Scenes.LEVEL_SELECT : "uid://c07r024es45w5",
	Scenes.TITLE_SCREEN : "uid://m1hbhgjo3o8p",
	Scenes.TEAM_SELECT : "uid://80bi5n7nx6ew"
}

var cleared_levels: Dictionary[Scenes, bool] = {
	Scenes.LEVEL_1 : false,
	Scenes.LEVEL_2 : false,
	Scenes.LEVEL_3 : false,
	Scenes.LEVEL_4 : false,
	Scenes.LEVEL_5 : false,
	Scenes.LEVEL_6 : false,
}

enum Telegraph {
	MOVE,
	ATTACK,
	ENEMY_ATTACK,
	SPAWN
}
enum AttackTypes {
	STRAIGHT,
	LOBBED,
	POINT
}
enum AttackRangeTypes {
	CROSS,
	DIAMOND,
	FULL_BOARD,
	DIAGONAL
}

class TileInfo:
	var object: MapObject = null
	var hazard: HazardTile = null

var current_board_data: Dictionary[Vector2i, TileInfo] = {}
var current_board: TileMapLayer = null
var party_members: Array[UnitData] = []
var current_turn: TurnState = TurnState.START
var last_defeated_unit: UnitData = null

func reset():
	#clear board data
	current_board_data.clear()
	current_board = null
	
	#clear party
	party_members = []
	
	#reset cleared levels
	for key in cleared_levels:
		cleared_levels[key] = false

#this method returns an array of valid grid coordinates that units can move to
func get_movable_tiles(tile_pos: Vector2i, move_range: int, is_flying: bool = true) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	_get_tiles_diamond_pattern(cells, tile_pos, move_range, true, !is_flying)
	return cells

#this method returns an array of valid grid coordinates that units target and attack
func get_attack_tiles(tile_pos: Vector2i, range_type: AttackRangeTypes, dead_zone_type: AttackRangeTypes, attack_range: int, dead_zone: int) -> Array[Vector2i]:
	var positive_space: Array[Vector2i] = []
	var negative_space: Array[Vector2i] = []
	match range_type:
		AttackRangeTypes.CROSS:
			positive_space = _get_tiles_cross_pattern(tile_pos, attack_range)
		AttackRangeTypes.DIAMOND:
			_get_tiles_diamond_pattern(positive_space, tile_pos, attack_range)
		AttackRangeTypes.FULL_BOARD:
			positive_space = _get_tiles_full_board(tile_pos)
		AttackRangeTypes.DIAGONAL:
			positive_space = _get_tiles_diagonal_pattern(tile_pos, attack_range)
	
	match dead_zone_type:
		AttackRangeTypes.CROSS:
			negative_space = _get_tiles_cross_pattern(tile_pos, dead_zone)
		AttackRangeTypes.DIAMOND:
			_get_tiles_diamond_pattern(negative_space, tile_pos, dead_zone)
		AttackRangeTypes.FULL_BOARD:
			negative_space = _get_tiles_full_board(tile_pos)
		AttackRangeTypes.DIAGONAL:
			negative_space = _get_tiles_diagonal_pattern(tile_pos, dead_zone)
	
	positive_space = positive_space.filter(func(item): return not item in negative_space)
	positive_space = positive_space.filter(func(item): return not item == tile_pos)
	
	return positive_space

#function that returns an array of grid coordinates in a cross (+) pattern from the starting point
func _get_tiles_cross_pattern(tile_pos: Vector2i, distance: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	cells.append_array(_get_tiles_straight_line(tile_pos, distance, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE))
	cells.append_array(_get_tiles_straight_line(tile_pos, distance, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE))
	cells.append_array(_get_tiles_straight_line(tile_pos, distance, TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE))
	cells.append_array(_get_tiles_straight_line(tile_pos, distance, TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE))
	return cells

#function that returns an array of grid coordinates in an X pattern from the starting point
func _get_tiles_diagonal_pattern(tile_pos: Vector2i, distance: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	cells.append_array(_get_tiles_straight_line(tile_pos, distance, TileSet.CELL_NEIGHBOR_BOTTOM_CORNER))
	cells.append_array(_get_tiles_straight_line(tile_pos, distance, TileSet.CELL_NEIGHBOR_LEFT_CORNER))
	cells.append_array(_get_tiles_straight_line(tile_pos, distance, TileSet.CELL_NEIGHBOR_RIGHT_CORNER))
	cells.append_array(_get_tiles_straight_line(tile_pos, distance, TileSet.CELL_NEIGHBOR_TOP_CORNER))
	return cells

#recursive function that returns and array of tiles in a straight line
#this line starts at a given grid coord and extends in the chosen cardinal direction (which is determined by the CellNeighbor property)
func _get_tiles_straight_line(tile_pos: Vector2i, dist: int, cell_neighbor: TileSet.CellNeighbor, _check_obstacles: bool = false) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var original_cell: Vector2i = tile_pos
	for i in dist:
		var cell = current_board.get_neighbor_cell(original_cell, cell_neighbor)
		if not current_board_data.has(cell):
			continue
		if _check_obstacles and _check_obstacle_on_tile(tile_pos):
			continue
		cells.append(cell)
		original_cell = cell
	return cells

#this method returns and array of all valid grid coordinates where units can be deployed
func get_spawn_tiles() -> Array[Vector2i]:
	
	#start with all the tiles on the board
	var spawn_tiles: Array[Vector2i] = current_board_data.keys()
	var filter_array: Array[Vector2i] = []
	for key in current_board_data.keys():
		
		#filter out tiles that are in a 3x3 area of a map_object
		if current_board_data[key].object:
			filter_array.append(key)
			filter_array.append_array(_get_all_surrounding_tiles(key))
		
		#filter out water tiles
		if current_board.get_cell_tile_data(key).get_custom_data("is_water"):
			filter_array.append(key)
	
	spawn_tiles = spawn_tiles.filter(func(tile): return tile not in filter_array)
	
	return spawn_tiles

#this method returns an array of neighbor grid coords in all 8 cardinal directions
func _get_all_surrounding_tiles(tile_pos: Vector2i) -> Array[Vector2i]:
	var temp_array = current_board.get_surrounding_cells(tile_pos)
	temp_array.append(current_board.get_neighbor_cell(tile_pos, TileSet.CELL_NEIGHBOR_BOTTOM_CORNER))
	temp_array.append(current_board.get_neighbor_cell(tile_pos, TileSet.CELL_NEIGHBOR_TOP_CORNER))
	temp_array.append(current_board.get_neighbor_cell(tile_pos, TileSet.CELL_NEIGHBOR_RIGHT_CORNER))
	temp_array.append(current_board.get_neighbor_cell(tile_pos, TileSet.CELL_NEIGHBOR_LEFT_CORNER))
	return temp_array

#this method returns an array of all valid grid coords on the current board
func _get_tiles_full_board(tile_pos: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for key in current_board_data.keys():
		if key != tile_pos:
			cells.append(key)
	return cells

#recursive function that returns an array of tiles in a diamond pattern
#this pattern starts at a given grid coordinate and extends as far as the "distance" parameter
func _get_tiles_diamond_pattern(input_array: Array[Vector2i], tile_pos: Vector2i, distance: int, _check_obstacles: bool = false, _check_water: bool = false):
	for i in distance:
		var cells = current_board.get_surrounding_cells(tile_pos)
		for cell in cells:
			if not current_board_data.has(cell):
				continue
			if _check_obstacles and _check_obstacle_on_tile(cell):
				continue
			if _check_water and _check_water_tile(cell):
				continue
			input_array.append(cell)
			_get_tiles_diamond_pattern(input_array, cell, distance - 1, _check_obstacles, _check_water)

#method that returns true if the parameter grid coordinate has a MapObject on it
func _check_obstacle_on_tile(tile_pos: Vector2i) -> bool:
	if current_board_data[tile_pos].object == null:
		return false
	else:
		return true

#method that returns true if the parameter grid coordinate is a water tile
func _check_water_tile(tile_pos: Vector2i) -> bool:
	var tile_data: TileData = current_board.get_cell_tile_data(tile_pos) as TileData
	return tile_data.get_custom_data("is_water")
