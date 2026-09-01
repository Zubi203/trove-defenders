extends TextureButton

@export var offset_amount: float = 0.3
@export var anim_speed: float = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = Time.get_unix_time_from_system()
	var dist = sin(time * anim_speed) * offset_amount
	position.x -= dist
