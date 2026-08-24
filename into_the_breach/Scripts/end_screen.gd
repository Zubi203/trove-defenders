class_name EndScreen
extends ColorRect

@export var panel: PanelContainer
@export var replay_button: Button
@export var level_select_button: Button
@export var label: Label

@export var animation_duration: float = 1
@export var victory_color: Color
@export var defeat_color: Color

func _ready() -> void:
	_reset()
	GameManager.GameOver.connect(_start_animation)

func _reset():
	if label == null or panel == null or replay_button == null or level_select_button == null:
		return
	label.text = ""
	panel.custom_minimum_size.x = 0
	replay_button.hide()
	level_select_button.hide()
	color.a = 0
	hide()

func _start_animation(player_won: bool):
	if label == null or panel == null or replay_button == null or level_select_button == null:
		return
	show()
	MusicPlayer.on_game_over(player_won)
	Engine.time_scale = 0
	var tween = get_tree().create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	tween.tween_property(self, "color:a", 0.5, animation_duration * 0.2)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(panel, "custom_minimum_size:x", 500, animation_duration * 0.6)
	tween.tween_interval(animation_duration * 0.1)
	tween.set_trans(Tween.TRANS_LINEAR)
	var label_text = "VICTORY!" if player_won else "DEFEAT!"
	label.label_settings.font_color = victory_color if player_won else defeat_color
	tween.tween_property(label, "text", label_text, animation_duration * 0.3)
	tween.tween_callback(replay_button.show)
	tween.tween_callback(level_select_button.show)


func _on_play_again_button_pressed() -> void:
	Engine.time_scale = 1
	SceneTransition.transition(GameManager.current_scene, GameManager.current_scene)


func _on_level_select_button_pressed() -> void:
	Engine.time_scale = 1
	SceneTransition.transition(GameManager.Scenes.LEVEL_SELECT, GameManager.current_scene)
