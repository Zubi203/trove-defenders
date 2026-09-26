class_name AnimatedButtonComponent
extends Node2D

var button_parent: BaseButton = null
@export var hover_scale_increase: float = 0.1
@export var pressed_scale_increase: float = 0.2
@export var scale_with_width: bool = true
@export var width_full_rotation: float = 400
@export var rotate_on_hover: bool = true
var base_scale: Vector2 = Vector2.ONE
var base_rotation_degress: float
@export var animation_duration: float = 1
var tween: Tween

func _ready() -> void:
	if get_parent() is BaseButton:
		button_parent = get_parent()
		base_scale = button_parent.scale
		base_rotation_degress = button_parent.rotation_degrees
	_connect_button_signals.call_deferred()

func _connect_button_signals():
	if button_parent == null:
		return
	button_parent.pivot_offset.y = button_parent.size.y / 2
	button_parent.pivot_offset.x = button_parent.size.x / 2
	button_parent.mouse_entered.connect(_on_mouse_entered)
	button_parent.mouse_exited.connect(_on_mouse_exited)

#increase button scale when hovered
func _on_mouse_entered():
	if button_parent.disabled:
		#_reset()
		return
	
	#set button pivot point to center
	button_parent.pivot_offset.y = button_parent.size.y / 2
	button_parent.pivot_offset.x = button_parent.size.x / 2
	
	#scale button's rotation based on its scale
	#this makes longer buttons looks smoother and less jarring
	#when playing the rotation animation
	var scale_ratio: float = clampf(width_full_rotation / button_parent.size.x, 0.5, 1.0)
	if not scale_with_width:
		scale_ratio = 1.0
	var scale_target: Vector2 = base_scale + Vector2.ONE * hover_scale_increase * scale_ratio
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	#scale x and y axes with different timngs to make the button look squishier
	tween.tween_property(button_parent, "scale:x", scale_target.x, animation_duration * 0.2)
	tween.parallel().tween_property(button_parent, "scale:y", scale_target.y, animation_duration * 0.35)
	if rotate_on_hover:
		tween.parallel().tween_property(button_parent, "rotation_degrees", 2.0 * scale_ratio * [-1.0, 1.0].pick_random(), animation_duration * 0.1)
		tween.parallel().tween_property(button_parent, "rotation_degrees", 0.0, animation_duration * 0.1).set_delay(animation_duration * 0.1)

#reset to base rotation and scale when mouse exits the button
func _on_mouse_exited():
	
	button_parent.pivot_offset.y = button_parent.size.y / 2
	button_parent.pivot_offset.x = button_parent.size.x / 2
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(button_parent, "scale", base_scale, animation_duration * 0.3)
	if rotate_on_hover:
		tween.parallel().tween_property(button_parent, "rotation_degrees", 0.0, animation_duration * 0.1)

func _reset():
	button_parent.scale = base_scale
	button_parent.rotation_degrees = base_rotation_degress
