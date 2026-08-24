extends Node2D


var spawn_queue: Array[UnitData] = []
@export var unit_scene: PackedScene
@export var unit_container: Node2D
@export var spawn_cursor: Node2D
var spawn_tiles: Array[Vector2i]
var game_over: bool = false
var player_command_queue: Array[Command] = []
var enemy_move_command_queue: Array[Command] = []
var enemy_attack_command_queue: Array[Command] = []
var last_player_command: Command = null

var enemy_units: Array[MapObject] = []
var player_units: Array[MapObject] = []
var chests: Array[MapObject] = []

func _ready() -> void:
	GameManager.QueueCommand.connect(_append_command_queue)
	GameManager.ObjectDestroyed.connect(_check_units)
	GameManager.UndoButtonPressed.connect(_on_undo_button_pressed)
	_start_state_enter.call_deferred()

func _process(_delta: float) -> void:
	match GameManager.current_turn:
		GameManager.TurnState.START:
			if spawn_queue.is_empty():
				_start_state_exit()
			else:
				if spawn_cursor:
					spawn_cursor.unit = spawn_queue[0]
					var cursor_pos = GameManager.current_board.local_to_map(get_global_mouse_position())
					if cursor_pos in spawn_tiles:
						spawn_cursor.show()
					else:
						spawn_cursor.hide()
					spawn_cursor.global_position = GameManager.current_board.map_to_local(cursor_pos)
					
		GameManager.TurnState.PLAYER:
			_execute_player_command()
		GameManager.TurnState.ENEMY:
			_execute_enemy_move_command()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and GameManager.current_turn == GameManager.TurnState.START:
		var pos = GameManager.current_board.local_to_map(get_global_mouse_position())
		for idx in len(spawn_tiles) - 1:
			if spawn_tiles[idx] == pos:
				GameManager.HideTelegraphs.emit(GameManager.Telegraph.SPAWN, [spawn_tiles[idx]] as Array[Vector2i])
				_spawn_unit(spawn_queue.pop_front(), GameManager.current_board.map_to_local(spawn_tiles.pop_at(idx)))

func _start_state_enter():
	spawn_queue.append_array(GameManager.party_members)
	spawn_tiles = GameManager.get_spawn_tiles()
	GameManager.ShowTelegraphs.emit(GameManager.Telegraph.SPAWN, spawn_tiles)
	GameManager.current_turn = GameManager.TurnState.START
	GameManager.TurnStart.emit(GameManager.current_turn)

func _start_state_exit():
	if spawn_cursor:
		spawn_cursor.hide()
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.SPAWN, spawn_tiles)
	next_turn()

func _spawn_unit(unit: UnitData, pos: Vector2):
	if unit_scene == null:
		return
	var new_unit: Unit = unit_scene.instantiate()
	new_unit.global_position = pos
	if unit_container:
		unit_container.add_child(new_unit)
	else:
		add_child(new_unit)
	new_unit.data = unit
	GameManager.UpdateBoard.emit()

func next_turn():
	GameManager.UpdateBoard.emit()
	_check_units()
	if game_over:
		return
	
	if GameManager.current_turn == GameManager.TurnState.ENEMY:
		enemy_turn_end()
		player_turn_start()
	else:
		player_turn_end()
		enemy_turn_start()
	

func player_turn_start():
	GameManager.current_turn = GameManager.TurnState.PLAYER
	GameManager.TurnStart.emit(GameManager.current_turn)

func enemy_turn_start():
	GameManager.current_turn = GameManager.TurnState.ENEMY
	GameManager.TurnStart.emit(GameManager.current_turn)
	await get_tree().create_timer(1).timeout
	for cmd in enemy_attack_command_queue:
		_execute_enemy_attack_command()
		await get_tree().create_timer(1).timeout
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.ENEMY_ATTACK, GameManager.current_board_data.keys() as Array[Vector2i])
	await _move_enemy_units()
	await _set_enemy_attacks()
	next_turn()

func _move_enemy_units():
	for unit in enemy_units:
		if unit == null:
			continue
		for child in unit.get_children():
			if child is AIController:
				child.decide_ai_move_action()
		await get_tree().create_timer(1).timeout

func _set_enemy_attacks():
	for unit in enemy_units:
		if unit == null:
			return
		for child in unit.get_children():
			if child is AIController:
				await child.decide_ai_attack_action()
		await get_tree().create_timer(1).timeout

func player_turn_end():
	GameManager.TurnEnd.emit(GameManager.current_turn)

func enemy_turn_end():
	GameManager.TurnEnd.emit(GameManager.current_turn)

func _check_units(_obj: MapObject = null):
	enemy_units.clear()
	player_units.clear()
	chests.clear()
	for object: MapObject in get_tree().get_nodes_in_group("MapObject"):
		if object is Unit:
			for child in object.get_children():
				if child is PlayerController:
					player_units.append(object)
					break
				elif child is AIController:
					enemy_units.append(object)
					break
		if object is Chest:
			chests.append(object)
	if enemy_units.is_empty():
		game_over = true
		GameManager.GameOver.emit(true)
		GameManager.cleared_levels[GameManager.current_scene] = true
		return
	if player_units.is_empty():
		game_over = true
		GameManager.GameOver.emit(false)
		return
	if chests.is_empty():
		game_over = true
		GameManager.GameOver.emit(false)
		return

func _on_end_turn_button_pressed() -> void:
	next_turn()

func _execute_player_command():
	if player_command_queue.is_empty():
		return
	var cmd: Command = player_command_queue.pop_front()
	cmd.execute()
	last_player_command = cmd
	_check_undo_button()
	_check_remaining_actions()

func _check_undo_button():
	if last_player_command is MoveCommand:
		GameManager.ToggleUndoButton.emit(true)
	else:
		GameManager.ToggleUndoButton.emit(false)

func _on_undo_button_pressed():
	last_player_command.undo()
	last_player_command = null
	_check_undo_button()

func _check_remaining_actions():
	var total_actions_remaining: int = 0
	for unit in player_units:
		if unit == null:
			continue
		for child in unit.get_children():
			if child is PlayerController:
				total_actions_remaining += child.remaining_action_count
	if total_actions_remaining <= 0:
		GameManager.ActionsDepleted.emit()

func _execute_enemy_move_command():
	if enemy_move_command_queue.is_empty():
		return
	var cmd: Command = enemy_move_command_queue.pop_front()
	if enemy_attack_command_queue.size() == 1:
		cmd = enemy_attack_command_queue[0]
		enemy_attack_command_queue.clear()
	cmd.execute()

func _execute_enemy_attack_command():
	if enemy_attack_command_queue.is_empty():
		return
	var cmd: Command = enemy_attack_command_queue.pop_front()
	cmd.execute()

func _append_command_queue(cmd: Command):
	match GameManager.current_turn:
		GameManager.TurnState.PLAYER:
			player_command_queue.append(cmd)
		GameManager.TurnState.ENEMY:
			if cmd is MoveCommand:
				enemy_move_command_queue.append(cmd)
			elif cmd is AttackCommand:
				enemy_attack_command_queue.append(cmd)
