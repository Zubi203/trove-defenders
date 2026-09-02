class_name BaseProjectile
extends Area2D

signal ProjectileImpact (impact_tile: Vector2i)

var attack_data: AttackData = null:
	set(value):
		attack_data = value
		_set_data()
@export var sprite: Sprite2D
@export var collider: CollisionShape2D
@export var speed: float = 150
var distance_to_target: float = 0
var target_direction: Vector2 = Vector2.ZERO
var owner_object: MapObject = null
var target_cell_entered: bool = false
var target_cell: Vector2i
var start_cell: Vector2i
var in_start_cell: bool = true
var check_start_pos: bool = true
var additional_damage: int = 0

func _set_data():
	if sprite:
		sprite.texture = attack_data.texture

func _physics_process(delta: float) -> void:
	_move(delta)
	_check_board_edge()
	_check_range_end()
	if check_start_pos:
		_check_start_tile()

func _move(_delta: float):
	pass

func _check_board_edge():
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if not GameManager.current_board_data.has(grid_pos):
		_impact(global_position)

func _check_range_end():
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if target_cell_entered:
		if grid_pos != target_cell:
			_impact(GameManager.current_board.map_to_local(target_cell))
	else:
		target_cell_entered = grid_pos == target_cell

func _check_start_tile():
	var grid_pos = GameManager.current_board.local_to_map(global_position)
	if not in_start_cell:
		_enable_collider.call_deferred()
		check_start_pos = false
	else:
		in_start_cell = grid_pos == start_cell

func _set_projectile(projectile_owner: MapObject, pos: Vector2, target_pos: Vector2, data: AttackData, bonus_damage: int = 0):
	area_entered.connect(_on_area_entered)
	additional_damage = bonus_damage
	global_position = pos
	owner_object = projectile_owner
	attack_data = data
	target_cell = GameManager.current_board.local_to_map(target_pos)
	start_cell = GameManager.current_board.local_to_map(pos)
	target_direction = pos.direction_to(target_pos)
	distance_to_target = pos.distance_to(target_pos)
	_disable_collider.call_deferred()

func _on_area_entered(area: Area2D):
	if area == owner_object:
		return
	if area is MapObject:
		for child in area.get_children():
			if child is HealthComponent:
				child.take_damage(attack_data.damage + additional_damage)
		if not attack_data.type == GameManager.AttackTypes.POINT:
			_impact(global_position)

func _impact(pos: Vector2):
	ProjectileImpact.emit(GameManager.current_board.local_to_map(pos))
	var grid_pos = GameManager.current_board.local_to_map(pos)
	if not attack_data.is_piercing or not GameManager.current_board_data.has(grid_pos):
		_disable_collider.call_deferred()
		set_process(false)
		set_physics_process(false)
		await get_tree().create_timer(0.05).timeout
		queue_free()

func _disable_collider():
	if collider:
		collider.disabled = true

func _enable_collider():
	if collider:
		collider.disabled = false
