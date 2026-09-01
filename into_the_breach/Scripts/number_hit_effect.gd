class_name NumberEffect
extends Label

@export var heal_color: Color
@export var damage_color: Color

func animate(input_text: String, is_positive: bool):
	position = Vector2(-(size.x / 2), -(size.y / 2))
	text = input_text
	label_settings.font_color = heal_color if is_positive else damage_color
	var tween = create_tween()
	var base_pos = position
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "position:y", base_pos.y - 40, 1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.tween_callback(queue_free)
