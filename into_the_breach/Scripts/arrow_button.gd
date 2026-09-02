extends TextureButton

@export var offset_amount: float = 0.3
@export var anim_speed: float = 4

func _process(_delta: float) -> void:
	var time = Time.get_unix_time_from_system()
	var dist = sin(time * anim_speed) * offset_amount
	position.x -= dist
