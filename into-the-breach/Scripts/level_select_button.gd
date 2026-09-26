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
	
	#check if the required amount of levels have been cleared
	var num_cleared_levels: int = 0
	for value in GameManager.cleared_levels.values():
		if value == true:
			num_cleared_levels += 1
	
	#enable/disable button, set transparency
	disabled = num_cleared_levels < levels_needed_to_unlock
	modulate.a = 0.6 if disabled else 1.0
	
	#set text on level button
	var string: String = GameManager.Scenes.find_key(level)
	label.text = string.replace("_", " ")
	
	#display star sprite on the level button if it has been cleared
	if star_sprite == null or cleared_star == null or empty_star == null:
		return
	star_sprite.texture = cleared_star if GameManager.cleared_levels[level] else empty_star

func _level_button_pressed():
	LevelButtonPressed.emit(level)
	
