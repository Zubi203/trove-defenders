extends Control

@export var move_speed: float = 200.0
@export var extent: float = 1024
@onready var start_pos: Vector2 = position

func _process(delta: float) -> void:
	_move_background(delta)
	if position.x - start_pos.x >= extent:
		position = start_pos
		

func _move_background(delta):
	var dir = Vector2.RIGHT * move_speed * delta
	position += dir
