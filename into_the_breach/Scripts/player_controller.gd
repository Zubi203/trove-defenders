class_name PlayerController
extends Controller

var unit_data: UnitData
enum State {
	NOT_SELECTED,
	SELECTED,
	MOVE,
	ATTACK,
}
var current_state: State = State.NOT_SELECTED
var temp_tile_array: Array[Vector2i]
var player_ui: UnitUI = null
@export var max_total_actions: int = 2
var actions_available: Dictionary[PlayerButton.ButtonType, bool] = {
	PlayerButton.ButtonType.MOVE: false,
	PlayerButton.ButtonType.ATTACK: false,
	PlayerButton.ButtonType.HEAL: false,
}
var remaining_action_count: int = 0

func _ready() -> void:
	GameManager.TurnStart.connect(_try_restore_actions)
	_set_unit_data.call_deferred()
	for child in get_parent().get_children():
		if child is UnitUI:
			player_ui = child
			for button: PlayerButton in player_ui.buttons:
				button.MoveButtonPressed.connect(_move_state_enter)
				button.AttackButtonPressed.connect(_attack_state_enter)
				button.HealButtonPressed.connect(_heal)
	_try_get_sprite()
	_on_spawn_animation.call_deferred()

func _set_unit_data():
	var parent = get_parent()
	if parent is Unit:
		unit_data = parent.data
	for child in parent.get_children():
		if child is MovementComponent:
			child.UndoMove.connect(_on_undo_move)

func _try_restore_actions(turn_state: GameManager.TurnState):
	if not turn_state == GameManager.TurnState.PLAYER:
		return
	for key in actions_available.keys():
		actions_available[key] = true
	if is_ensnared:
		actions_available[PlayerButton.ButtonType.MOVE] = false
	remaining_action_count = max_total_actions

func _on_action_performed(action_type: PlayerButton.ButtonType):
	remaining_action_count -= 1
	actions_available[action_type] = false

func select():
	current_state = State.SELECTED
	if player_ui:
		player_ui.show()
	_move_start_animation()

func deselect():
	if player_ui:
		player_ui.hide()
	current_state = State.NOT_SELECTED
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.MOVE, temp_tile_array)
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.ATTACK, temp_tile_array)
	temp_tile_array.clear()

func _move_state_enter():
	if remaining_action_count <= 0:
		return
	if not actions_available[PlayerButton.ButtonType.MOVE]:
		return
	if current_state == State.NOT_SELECTED:
		return
	current_state = State.MOVE
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.ATTACK, temp_tile_array)
	temp_tile_array.clear()
	temp_tile_array = GameManager.get_movable_tiles(GameManager.current_board.local_to_map(global_position) , unit_data.max_move_distance)
	GameManager.ShowTelegraphs.emit(GameManager.Telegraph.MOVE, temp_tile_array)

func _attack_state_enter():
	if remaining_action_count <= 0:
		return
	if not actions_available[PlayerButton.ButtonType.ATTACK]:
		return
	if current_state == State.NOT_SELECTED:
		return
	current_state = State.ATTACK
	GameManager.HideTelegraphs.emit(GameManager.Telegraph.MOVE, temp_tile_array)
	temp_tile_array.clear()
	temp_tile_array = GameManager.get_attack_tiles(GameManager.current_board.local_to_map(global_position) , unit_data.range_type, unit_data.dead_zone_type, unit_data.attack_range, unit_data.dead_zone)
	GameManager.ShowTelegraphs.emit(GameManager.Telegraph.ATTACK, temp_tile_array)

func _move():
	var mouse_grid_coord = GameManager.current_board.local_to_map(get_global_mouse_position())
	if temp_tile_array.has(mouse_grid_coord):
		_on_action_performed(PlayerButton.ButtonType.MOVE)
		MoveUnit.emit(mouse_grid_coord)
	await get_tree().create_timer(0.1).timeout
	deselect()

func _attack():
	
	var mouse_grid_coord = GameManager.current_board.local_to_map(get_global_mouse_position())
	if temp_tile_array.has(mouse_grid_coord):
		_on_action_performed(PlayerButton.ButtonType.ATTACK)
		ShootProjectile.emit(mouse_grid_coord)
	await get_tree().create_timer(0.1).timeout
	deselect()

func _heal():
	if remaining_action_count <= 0:
		return
	if not actions_available[PlayerButton.ButtonType.HEAL]:
		return
		
	for sibling in get_parent().get_children():
		if sibling is HealthComponent:
			if sibling.health < sibling.max_health:
				_on_action_performed(PlayerButton.ButtonType.HEAL)
				HealSelf.emit(unit_data.heal_amount)
	await get_tree().create_timer(0.1).timeout
	deselect()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		match current_state:
			State.MOVE:
				_move()
			State.ATTACK:
				_attack()

func ensnare():
	is_ensnared = true
	actions_available[PlayerButton.ButtonType.MOVE] = false

func _on_undo_move():
	deselect()
	if not actions_available[PlayerButton.ButtonType.MOVE]:
		actions_available[PlayerButton.ButtonType.MOVE] = true
		remaining_action_count += 1
