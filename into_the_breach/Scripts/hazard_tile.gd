class_name HazardTile
extends Sprite2D

@export var tile_data: HazardTileData
@export var hazard_tile_ui: CanvasLayer
@export var tile_ui_icon: TextureRect
@export var tile_description_label: Label
var turns_lifespan_left: int = 1

func _ready() -> void:
	GameManager.TurnEnd.connect(_on_turn_end)
	GameManager.TurnStart.connect(_on_turn_start)
	if tile_data:
		turns_lifespan_left = tile_data.turn_duration
		texture = tile_data.texture
		_set_tile_ui()
	tile_setup()

func _set_tile_ui():
	if tile_description_label == null or tile_ui_icon == null:
		return
	tile_description_label.text = tile_data.name + ":\n" + tile_data.description
	tile_ui_icon.texture = tile_data.texture 

func _process(_delta: float) -> void:
	_check_mouse_position()

func _check_mouse_position():
	if hazard_tile_ui == null:
		return
	if GameManager.current_board == null:
		return
	var mouse_grid_pos = GameManager.current_board.local_to_map(get_global_mouse_position())
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if mouse_grid_pos == grid_pos:
		hazard_tile_ui.show()
	else:
		hazard_tile_ui.hide()

func tile_setup():
	pass

func _on_turn_start(_turn: GameManager.TurnState):
	pass

func _on_turn_end(_turn: GameManager.TurnState):
	turns_lifespan_left -= 1
	if turns_lifespan_left == 0:
		_destroy_tile()

func _destroy_tile():
	queue_free()

func _exit_tree() -> void:
	GameManager.UpdateBoard.emit()
