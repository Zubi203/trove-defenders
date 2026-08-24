extends CanvasLayer


@export var pause_menu: Control
@export var turn_label: Label
@export var end_turn_button: Button
@export var undo_button: Button
@export var units_label: Label
@export var chests_label: Label
@export var end_turn_button_gradient: Gradient


var max_player_units: int = 0
var max_chests: int = 0
var current_player_units: int = 0
var current_chests: int = 0
var end_turn_button_flash: bool = false
var oscillating_point: float = 0
var end_button_flash_tween: Tween


func _ready() -> void:
	GameManager.TurnStart.connect(_on_turn_start)
	GameManager.TurnEnd.connect(_toggle_end_turn_button)
	GameManager.UpdateBoard.connect(update_remaining_units_and_chests)
	GameManager.ObjectDestroyed.connect(update_remaining_units_and_chests)
	GameManager.ActionsDepleted.connect(_on_actions_depleted)
	GameManager.ToggleUndoButton.connect(_toggle_undo_button)
	max_chests = _get_chest_count()
	max_player_units = GameManager.party_members.size()
	update_remaining_units_and_chests()

func _start_oscillating_point(start: bool):
	if end_button_flash_tween:
		end_button_flash_tween.kill()
	if start:
		end_button_flash_tween = get_tree().create_tween()
		end_button_flash_tween.set_loops(20)
		end_button_flash_tween.tween_property(self, "oscillating_point", 1.0, 0.3)
		end_button_flash_tween.tween_property(self, "oscillating_point", 0, 0.3)
	

func _process(_delta: float) -> void:
	if end_turn_button == null:
		return
	if end_turn_button_flash:
		end_turn_button.self_modulate = end_turn_button_gradient.sample(oscillating_point)
	else:
		end_turn_button.self_modulate = Color.WHITE

func _on_actions_depleted():
	end_turn_button_flash = true
	_start_oscillating_point(true)

func _on_pause_button_pressed() -> void:
	if pause_menu:
		pause_menu.show()
		Engine.time_scale = 0.0


func _on_resume_button_pressed() -> void:
	if pause_menu:
		pause_menu.hide()
		Engine.time_scale = 1.0


func _on_level_select_button_pressed() -> void:
	Engine.time_scale = 1.0
	SceneTransition.transition(GameManager.Scenes.LEVEL_SELECT, GameManager.current_scene)

func _on_turn_start(turn: GameManager.TurnState):
	if turn_label == null:
		return
	match turn:
		GameManager.TurnState.ENEMY:
			turn_label.text = "ENEMY TURN"
		GameManager.TurnState.PLAYER:
			turn_label.text = "YOUR TURN"
		GameManager.TurnState.START:
			turn_label.text = "DEPLOY UNITS"
	turn_label.show()
	var tween = get_tree().create_tween()
	turn_label.position.x = 1200
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(turn_label, "position:x", 453, 0.5)
	tween.tween_interval(1)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(turn_label, "position:x", -1200, 0.5)
	tween.tween_callback(turn_label.hide)

func _toggle_end_turn_button(turn: GameManager.TurnState):
	if end_turn_button == null:
		return
	end_turn_button_flash = false
	_start_oscillating_point(false)
	if turn == GameManager.TurnState.ENEMY:
		end_turn_button.disabled = false
	else:
		end_turn_button.disabled = true

func _toggle_undo_button(toggle_on: bool):
	if undo_button == null:
		return
	undo_button.disabled = not toggle_on

func update_remaining_units_and_chests(_obj: MapObject = null):
	current_chests = _get_chest_count()
	current_player_units = _get_player_unit_count()
	_update_unit_and_chest_labels()

func _update_unit_and_chest_labels():
	if units_label == null or chests_label == null:
		return
	chests_label.text = str(current_chests) + "/" + str(max_chests)
	units_label.text = str(current_player_units) + "/" + str(max_player_units)

func _get_player_unit_count() -> int:
	var num_units: int = 0
	for object: MapObject in get_tree().get_nodes_in_group("MapObject"):
		if object is Unit:
			for child in object.get_children():
				if child is PlayerController:
					num_units += 1
	return num_units

func _get_chest_count() -> int:
	var num_chests: int = 0
	for object: MapObject in get_tree().get_nodes_in_group("MapObject"):
		if object is Chest:
			num_chests += 1
	return num_chests


func _on_undo_move_button_pressed() -> void:
	GameManager.UndoButtonPressed.emit()


func _on_settings_button_pressed() -> void:
	GameManager.ShowSettingsMenu.emit()
