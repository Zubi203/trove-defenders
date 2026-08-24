class_name NumberEffect
extends Label

@export var heal_color: Color
@export var damage_color: Color

func animate(number: int):
	position = Vector2(-(size.x / 2), -(size.y / 2))
	text = str(abs(number))
	label_settings.font_color = heal_color if number >= 0 else damage_color
	var tween = get_tree().create_tween()
	var base_pos = position
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "position:y", base_pos.y - 40, 1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.tween_callback(queue_free)
