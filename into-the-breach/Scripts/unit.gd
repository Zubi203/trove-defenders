class_name Unit
extends MapObject

@export var data: UnitData:
	set(value):
		data = value
		_set_data()


func _set_data():
	if sprite == null or data == null:
		return
	sprite.texture = data.texture
