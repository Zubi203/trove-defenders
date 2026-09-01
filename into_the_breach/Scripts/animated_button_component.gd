class_name AnimatedButtonComponent
extends Node2D

var button_parent: BaseButton = null
@export var hover_scale_increase: float = 0.05
@export var pressed_scale_increase: float = 0.1
var base_scale: Vector2 = Vector2.ONE
@export var animation_duration: float = 0.1
var tween: Tween

func _ready() -> void:
	if get_parent() is BaseButton:
		button_parent = get_parent()
		base_scale = button_parent.scale
	_connect_button_signals.call_deferred()

func _connect_button_signals():
	if button_parent == null:
		return
	button_parent.pivot_offset.y = button_parent.size.y / 2
	button_parent.pivot_offset.x = button_parent.size.x / 2
	button_parent.mouse_entered.connect(_on_mouse_entered)
	button_parent.mouse_exited.connect(_on_mouse_exited)
	button_parent.pressed.connect(_on_pressed)

func _on_mouse_entered():
	if button_parent.disabled:
		_reset()
		return
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button_parent, "scale", base_scale + Vector2.ONE * hover_scale_increase, animation_duration)

func _on_mouse_exited():
	if button_parent.disabled:
		_reset()
		return
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(button_parent, "scale", base_scale, animation_duration)

func _on_pressed():
	if button_parent.disabled:
		_reset()
		return
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button_parent, "scale", base_scale + Vector2.ONE * pressed_scale_increase, animation_duration)
	tween.tween_property(button_parent, "scale", base_scale, animation_duration)

func _reset():
	button_parent.scale = base_scale
