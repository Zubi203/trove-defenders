class_name LobbedProjectile
extends BaseProjectile

@export var travel_time: float = 0.6
@export var sprite_spin_interval: float = 0.1
@export var max_arc_height: float = 45
var last_spin_time: float

var impact_initiated: bool = false

func _ready() -> void:
	_arc_animation.call_deferred()

func _move(_delta: float):
	if not target_cell_entered:
		speed = distance_to_target / travel_time
		translate(target_direction * speed * _delta)
	else:
		global_position = global_position.lerp(GameManager.current_board.map_to_local(target_cell), _delta * 10)

func  _check_range_end():
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if target_cell_entered:
		if collider.disabled:
			_enable_collider.call_deferred()
		if impact_initiated:
			return
		else:
			impact_initiated = true
			await get_tree().create_timer(0.2).timeout
			_impact(GameManager.current_board.map_to_local(target_cell))
	else:
		target_cell_entered = grid_pos == target_cell

func _process(_delta: float) -> void:
	_spin_sprite()

func _spin_sprite():
	var time = Time.get_unix_time_from_system()
	if time - last_spin_time < sprite_spin_interval:
		return
	last_spin_time = time
	sprite.rotation += deg_to_rad(90)

func _arc_animation():
	var tween = create_tween()
	_disable_collider()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "position:y", -max_arc_height, travel_time * 0.5)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "position:y", 0, travel_time * 0.5)

func _check_start_tile():
	pass
