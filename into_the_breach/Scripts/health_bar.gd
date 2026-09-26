class_name HealthBar
extends CenterContainer

@export_color_no_alpha var fill_color: Color
@export_color_no_alpha var depleted_color: Color
@export var visible_timer: Timer
var max_value: int = 3:
	set(value):
		max_value = value
		$HealthBar.custom_minimum_size.x = value * 7
		for color_rect in color_rect_array:
			color_rect.hide()
		if not color_rect_array.is_empty():
			for i in value:
				color_rect_array[i].show()
var current_value: int = 3:
	set(value):
		current_value = value
		for color_rect in color_rect_array:
			color_rect.color = depleted_color
		if not color_rect_array.is_empty():
			for i in value:
				color_rect_array[i].color = fill_color
		if visible_timer:
			visible_timer.start()

var color_rect_array: Array[ColorRect] = []
var mouse_grid_pos: Vector2i
var player_controller: PlayerController = null

func _ready() -> void:
	_try_get_player_controller_sibling.call_deferred()
	
	#create health bar segments equal to the amount of health this unit has
	for child in $HealthBar/MarginContainer/ColorRectContainer.get_children():
		if child is ColorRect:
			color_rect_array.append(child)
			child.hide()

func _try_get_player_controller_sibling():
	for child in get_parent().get_children():
		if child is PlayerController:
			player_controller = child

func _process(_delta: float) -> void:
	if visible_timer == null:
		return
	
	#check if mouse is hovered over this unit's tile position
	var grid_pos = GameManager.current_board.local_to_map(get_parent().global_position)
	mouse_grid_pos = GameManager.current_board.local_to_map(get_global_mouse_position())
	
	#start timer if mouse is hovered over this unit
	if grid_pos == mouse_grid_pos:
		visible_timer.start()
	
	#start timer if this unit is selected
	if player_controller and player_controller.current_state != PlayerController.State.NOT_SELECTED:
		visible_timer.start()
	
	#timer only counts down if mouse is not hovered over this tile or if this unit is not selected
	if visible_timer.time_left:
		show()
	else:
		hide()
