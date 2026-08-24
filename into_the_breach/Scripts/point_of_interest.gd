class_name Chest
extends MapObject

func _ready() -> void:
	_set_sprite()

func _set_sprite():
	if sprite == null:
		return
	sprite.flip_h = bool(randi_range(0, 1))
