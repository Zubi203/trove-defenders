@tool

#tool script to help make placement of obstacles with varying sprites easier

class_name Obstacle
extends MapObject

enum ObstacleTypes {
	LOG,
	ROCK,
	STONE
}
enum ObstacleSizes {
	SMALL,
	MEDIUM,
	LARGE
}

@export var type: ObstacleTypes = ObstacleTypes.LOG
@export var size : ObstacleSizes = ObstacleSizes.SMALL

@export var obstacle_textures: Dictionary[String, Texture2D] = {
	"SMALL LOG": null,
	"MEDIUM LOG": null,
	"LARGE LOG": null,
	"SMALL ROCK": null,
	"MEDIUM ROCK": null,
	"LARGE ROCK": null,
	"SMALL STONE": null,
	"MEDIUM STONE": null,
	"LARGE STONE": null
}

func _ready() -> void:
	_set_sprite()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_set_sprite()


func _set_sprite():
	if sprite == null:
		return
	sprite.texture = obstacle_textures[ObstacleSizes.find_key(size) + " " + ObstacleTypes.find_key(type)]
