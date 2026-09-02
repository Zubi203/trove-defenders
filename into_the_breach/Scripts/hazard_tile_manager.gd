class_name HazardTileManager
extends Node2D

enum HazardTiles {
	FOLIAGE,
	FIRE,
	MAGIC_MINE,
	WEB,
	ROOTS
}

@export var hazard_tile_scenes: Dictionary[HazardTiles, PackedScene] = {
	HazardTiles.FOLIAGE: null,
	HazardTiles.FIRE: null,
	HazardTiles.MAGIC_MINE: null,
	HazardTiles.WEB: null,
	HazardTiles.ROOTS: null
}

func _ready() -> void:
	GameManager.SpawnHazardTile.connect(spawn_tile)


func spawn_tile(type: HazardTiles, grid_pos: Vector2i):
	if hazard_tile_scenes[type] == null:
		return
	if GameManager._check_water_tile(grid_pos):
		return
	var existing_tile = GameManager.current_board_data[grid_pos].hazard
	if existing_tile != null:
		existing_tile._destroy_tile()
		GameManager.current_board_data[grid_pos].hazard = null
	var tile: HazardTile = hazard_tile_scenes[type].instantiate()
	tile.global_position = GameManager.current_board.map_to_local(grid_pos)
	add_child(tile)
