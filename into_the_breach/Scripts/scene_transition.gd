extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func transition(target_level: GameManager.Scenes, current_level: GameManager.Scenes):
	animation_player.play("side_transition")
	await get_tree().create_timer(0.8).timeout
	_change_scene(target_level, current_level)
	animation_player.play("side_transition_exit")
	
func _change_scene(target_level: GameManager.Scenes, _current_level: GameManager.Scenes):
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	var scene = load(GameManager.SCENE_PATHS[target_level]).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	GameManager.current_scene = target_level
	MusicPlayer._on_scene_changed(GameManager.current_scene)
