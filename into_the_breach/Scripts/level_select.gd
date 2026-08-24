extends Control

@export var level_button_container: GridContainer
@export var party_sprites: Array[TextureRect]

func _ready() -> void:
	if level_button_container:
		for child in level_button_container.get_children():
			if child is LevelSelectButton:
				child.LevelButtonPressed.connect(_on_level_button_pressed)
	_set_party_sprites()

func _set_party_sprites():
	if party_sprites.size() < GameManager.party_members.size():
		return
	for idx in party_sprites.size():
		party_sprites[idx].texture = GameManager.party_members[idx].texture

func _on_team_select_button_pressed() -> void:
	SceneTransition.transition(GameManager.Scenes.TEAM_SELECT, GameManager.Scenes.LEVEL_SELECT)

func _on_level_button_pressed(target_scene: GameManager.Scenes):
	SceneTransition.transition(target_scene, GameManager.Scenes.LEVEL_SELECT)
