extends ColorRect

@export var description_label: Label
@export var sprite: TextureRect
@export var unit_data: UnitData

func _ready() -> void:
	_set_data()
	GameManager.TurnStart.connect(_show_warning)

func _set_data():
	if unit_data == null or description_label == null or sprite == null:
		return
	sprite.texture = unit_data.texture
	description_label.text = "The " + unit_data.name + ":\n" + unit_data.description

func _show_warning(turn: GameManager.TurnState):
	if turn == GameManager.TurnState.START:
		await get_tree().create_timer(1).timeout
		show()
		Engine.time_scale = 0
	

func _hide_warning():
	hide()
	Engine.time_scale = 1


func _on_button_pressed() -> void:
	_hide_warning()
