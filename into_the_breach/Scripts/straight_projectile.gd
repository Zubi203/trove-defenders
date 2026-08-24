class_name StraightProjectile
extends BaseProjectile

func _move(_delta: float):
	translate(target_direction * speed * _delta)

func _process(_delta: float) -> void:
	sprite.rotation = target_direction.angle()
	sprite.rotation += deg_to_rad(90)
