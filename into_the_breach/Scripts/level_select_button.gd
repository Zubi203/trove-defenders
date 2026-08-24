class_name LevelSelectButton
extends TextureButton

signal LevelButtonPressed (target_scene: GameManager.Scenes)

@export var level: GameManager.Scenes
@export var levels_needed_to_unlock: int = 0
@export var label: Label

@export var star_sprite: TextureRect
@export var empty_star: Texture2D
@export var cleared_star: Texture2D

func _ready() -> void:
	pressed.connect(_level_button_pressed)
	_set_button()

func _set_button():
	if label == null:
		return
	var num_cleared_levels: int = 0
	for value in GameManager.cleared_levels.values():
		if value == true:
			num_cleared_levels += 1
	if num_cleared_levels < levels_needed_to_unlock:
		disabled = true
		modulate.a = 0.6
	else: 
		disabled = false
		modulate.a = 1
	var string: String = GameManager.Scenes.find_key(level)
	label.text = string.replace("_", " ")
	if star_sprite == null or cleared_star == null or empty_star == null:
		return
	star_sprite.texture = cleared_star if GameManager.cleared_levels[level] else empty_star

func _level_button_pressed():
	LevelButtonPressed.emit(level)
