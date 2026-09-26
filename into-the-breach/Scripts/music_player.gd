extends Node

@export var level_scenes: Array[GameManager.Scenes]
@export var menu_scenes: Array[GameManager.Scenes]
@export var battle_music: AudioStreamPlayer
@export var menu_music: AudioStreamPlayer
@export var victory_music: AudioStreamPlayer
@export var defeat_music: AudioStreamPlayer
@export var fade_duration: float = 1


func fade_out(soundtrack: AudioStreamPlayer):
	var tween = get_tree().create_tween()
	tween.tween_property(soundtrack, "volume_db", -30, fade_duration)
	tween.tween_callback(soundtrack.stop)

func fade_in(soundtrack: AudioStreamPlayer):
	var tween = get_tree().create_tween()
	soundtrack.volume_db = -30
	tween.tween_callback(soundtrack.play)
	tween.tween_property(soundtrack, "volume_db", 0, fade_duration)

func _on_scene_changed(scene: GameManager.Scenes):
	if scene in level_scenes and not battle_music.playing:
		await fade_out(menu_music)
		await get_tree().create_timer(fade_duration).timeout
		fade_in(battle_music)
	elif scene in menu_scenes and not menu_music.playing:
		await fade_out(battle_music)
		await get_tree().create_timer(fade_duration).timeout
		fade_in(menu_music)

func on_game_over(player_won: bool):
	if player_won:
		victory_music.play()
	else:
		defeat_music.play()
