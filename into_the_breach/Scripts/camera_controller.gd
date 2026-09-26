extends Camera2D

@export var shake_intensity: float = 1.5
@export var shake_falloff: float = 6
var intensity: float

func _ready() -> void:
	GameManager.ForceStopScreenShake.connect(force_stop_shake)
	GameManager.ShakeCamera.connect(_damage_shake)

func _process(delta: float) -> void:
	
	#if intensity is greater than zero
	if intensity > 0:
		#randomly offset the camera every frame based on intensity
		offset = _get_random_offset()
		#gradually decrease the intensity to zero
		intensity = lerp(intensity, 0.0, shake_falloff * delta)

#this func is connected to a global signal to allow any script to access screen shake
func _damage_shake():
	intensity = shake_intensity

func _get_random_offset() -> Vector2:
	var x = randf_range(-intensity, intensity)
	var y = randf_range(-intensity, intensity)
	
	return Vector2(x, y)

#this func is connected to a global signal to allow scripts to instantly nullify screen shake
#this is primarily used to stop screen shake immediately when a pause menu or end screen activates
func force_stop_shake():
	intensity = 0
