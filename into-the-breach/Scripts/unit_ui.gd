class_name UnitUI
extends CanvasLayer

@export var buttons: Array[PlayerButton]
@export var unit_icon: TextureRect
var data: UnitData
var player_controller: PlayerController

func _ready() -> void:
	_fetch_parent_data.call_deferred()

func _process(_delta: float) -> void:
	_update_buttons()

func _update_buttons():
	if player_controller == null:
		return
	for button in buttons:
		button.disabled = not player_controller.actions_available[button.button_type] or not player_controller.remaining_action_count > 0

func _fetch_parent_data():
	var parent = get_parent()
	if parent is Unit:
		data = parent.data
		for child in parent.get_children():
			if child is PlayerController:
				player_controller = child
	_set_icon()
	for button in buttons:
		button.data = data
		button.set_button()

func _set_icon():
	if unit_icon == null or data == null:
		return
	unit_icon.texture = data.texture
