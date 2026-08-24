extends Camera2D

@export var shake_intensity: float = 1.5
@export var shake_falloff: float = 6
var intensity: float

func _ready() -> void:
	GameManager.ShakeCamera.connect(_damage_shake)

func _process(delta: float) -> void:
	if intensity > 0:
		offset = _get_random_offset()
		intensity = lerp(intensity, 0.0, shake_falloff * delta)

func _damage_shake():
	intensity = shake_intensity

func _get_random_offset() -> Vector2:
	var x = randf_range(-intensity, intensity)
	var y = randf_range(-intensity, intensity)
	
	return Vector2(x, y)
