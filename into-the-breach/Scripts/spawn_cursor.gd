extends Node2D

var unit: UnitData = null:
	set(value):
		unit = value
		_set_sprite()
@export var unit_sprite: Sprite2D

func _set_sprite():
	if unit_sprite == null or unit == null:
		return
	unit_sprite.texture = unit.texture
