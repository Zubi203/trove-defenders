class_name PartyButton
extends TextureButton

signal PartyButtonPressed (button: PartyButton)

@export var unit: UnitData:
	set(value):
		unit = value
		_set_sprite()
@export var sprite: TextureRect
@export var selection_indicator: TextureRect
var mouse_in_button: bool = false

func _ready() -> void:
	_set_sprite()

func _set_sprite():
	if sprite:
		sprite.texture = unit.texture


func _on_pressed() -> void:
	PartyButtonPressed.emit(self)

func show_selection_indicator():
	if selection_indicator:
		selection_indicator.show()

func hide_selection_indicator():
	if selection_indicator:
		selection_indicator.hide()
