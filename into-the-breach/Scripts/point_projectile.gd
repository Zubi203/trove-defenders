class_name PointProjectile
extends BaseProjectile

@export var animation_duration: float = 1

func _ready() -> void:
	_point_projectile_animation.call_deferred()


func _point_projectile_animation():
	pass

func _check_start_tile():
	pass
