class_name AIController
extends Controller

var target_scores: Dictionary[Vector2i, int]
var location_scores: Dictionary[Vector2i, int]
var data: UnitData
var prev_target: Vector2i = Vector2i.ZERO
var prev_move_location: Vector2i = Vector2i.ZERO

@export_category("Scoring Settings")
@export var player_target_score: int = 5
@export var enemy_target_score: int = -2
@export var hazard_tile_score: int = -10
@export var prev_target_score: int = -1
@export var low_hp_target_score: int = 1

func _ready() -> void:
	_set_unit_data.call_deferred()
	_try_get_sprite()

func _set_unit_data():
	var parent = get_parent()
	if parent is Unit:
		data = parent.data

func _fetch_location_tiles():
	var grid_pos: Vector2i = GameManager.current_board.local_to_map(get_parent().global_position)
	var tiles: Array[Vector2i] = []
	tiles = GameManager.get_movable_tiles(grid_pos, data.max_move_distance, data.is_flying)
	location_scores.clear()
	for tile in tiles:
		location_scores[tile] = 0


func _fetch_attack_tiles():
	var grid_pos: Vector2i = GameManager.current_board.local_to_map(get_parent().global_position)
	var tiles: Array[Vector2i] = []
	tiles = GameManager.get_attack_tiles(grid_pos, data.range_type, data.dead_zone_type, data.attack_range, data.dead_zone)
	target_scores.clear()
	for tile in tiles:
		target_scores[tile] = 0

func _score_location_tiles():
	if location_scores.is_empty():
		return
	
	for key in location_scores.keys():
		var closest_target: MapObject = null
		var closest_dist: float = 99999
		
		for object: MapObject in get_tree().get_nodes_in_group("MapObject"):
			if object is Chest:
				var dist = key.distance_to(GameManager.current_board.local_to_map(object.global_position))
				if dist < closest_dist:
					closest_dist = dist
					closest_target = object
			elif object is Unit:
				for child in object.get_children():
					if child is PlayerController:
						var dist = key.distance_to(GameManager.current_board.local_to_map(object.global_position))
						if dist < closest_dist:
							closest_dist = dist
							closest_target = object
		
		if closest_target:
			location_scores[key] = round((1 - (closest_dist / 10)) * 10)
			
		
		if key == prev_move_location:
			location_scores[key] += prev_target_score
	
	for key in location_scores.keys():
		await get_tree().process_frame
		var attack_tiles: Array[Vector2i] = GameManager.get_attack_tiles(key, data.range_type, data.dead_zone_type, data.attack_range, data.dead_zone)
		var player_targets: int = 0
		var enemy_targets: int = 0
		for tile in attack_tiles:
			var tile_object: MapObject = GameManager.current_board_data[tile].object
			if tile_object == null:
				continue
			if tile_object is Unit:
				for child in tile_object.get_children():
					if child is PlayerController:
						player_targets += 1
					elif child is AIController:
						enemy_targets += 1
			elif tile_object is Chest:
				player_targets += 1
		location_scores[key] += (player_targets * player_target_score) + (enemy_targets * enemy_target_score)
		
		var tile_data: TileData = GameManager.current_board.get_cell_tile_data(key) as TileData
		if not data.is_flying and tile_data.get_custom_data("is_water"):
			location_scores[key] += hazard_tile_score
		
		if GameManager.current_board_data[key].hazard:
			location_scores[key] += hazard_tile_score

func _score_targets():
	if target_scores.is_empty():
		return
	
	for key in target_scores.keys():
		await get_tree().process_frame
		var tile_object: MapObject = GameManager.current_board_data[key].object
		var score: int = 0
		if tile_object == null:
			continue
		if tile_object is Unit:
			for child in tile_object.get_children():
				if child is PlayerController:
					score += player_target_score
				elif child is AIController:
					score += enemy_target_score
		elif tile_object is Chest:
			score += player_target_score
		
		if tile_object:
			for child in tile_object.get_children():
				if child is HealthComponent:
					if child.health <= data.attack_data.damage:
						score += low_hp_target_score
		
		if key == prev_target:
			score += prev_target_score
		
		target_scores[key] += score

func decide_ai_move_action():
	if is_ensnared:
		return
	_fetch_location_tiles()
	_move_start_animation()
	GameManager.ShowTelegraphs.emit(GameManager.Telegraph.MOVE, location_scores.keys() as Array[Vector2i])
	await get_tree().create_timer(1).timeout
	await _score_location_tiles()
	var highest_score: int = 0
	for score in location_scores.values():
		if score > highest_score:
			highest_score = score
	var possible_actions: Array[Vector2i] = []
	for key in location_scores.keys():
		if location_scores[key] == highest_score:
			possible_actions.append(key)
	var target_tile: Vector2i
	if possible_actions.is_empty():
		if not location_scores.keys().is_empty():
			target_tile = location_scores.keys().pick_random()
	else:
		target_tile = possible_actions.pick_random()
	prev_move_location = target_tile
	if GameManager.current_board_data.has(target_tile):
		MoveUnit.emit(target_tile)
		GameManager.HideTelegraphs.emit(GameManager.Telegraph.MOVE, location_scores.keys() as Array[Vector2i])
	else:
		return

func decide_ai_attack_action():
	_fetch_attack_tiles()
	await _score_targets()
	var highest_score: int = 0
	for score in target_scores.values():
		if score > highest_score:
			highest_score = score
	var possible_actions: Array[Vector2i] = []
	for key in target_scores.keys():
		if target_scores[key] == highest_score:
			possible_actions.append(key)
	var target_tile: Vector2i
	if possible_actions.is_empty():
		target_tile = target_scores.keys().pick_random()
	else:
		target_tile = possible_actions.pick_random()
	prev_target = target_tile
	GameManager.ShowTelegraphs.emit(GameManager.Telegraph.ENEMY_ATTACK, [target_tile] as Array[Vector2i])
	ShootProjectile.emit(target_tile)
