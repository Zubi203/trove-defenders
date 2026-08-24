extends Control




func _on_play_button_pressed() -> void:
	SceneTransition.transition(GameManager.Scenes.TEAM_SELECT, GameManager.Scenes.TITLE_SCREEN)


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	GameManager.ShowSettingsMenu.emit()
