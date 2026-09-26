extends Sprite2D

@export var gradient: Gradient
@export var transition_duration: float = 0.5
var gradient_sample: float = 1

func _ready() -> void:
	GameManager.TurnStart.connect(_transition)

func _process(_delta: float) -> void:
	if not self_modulate == gradient.sample(gradient_sample):
		self_modulate = gradient.sample(gradient_sample)

#change background color depending on whose turn it is
#red for enemy, blue for player
#gradient is used for a smooth color transition
func _transition(turn_state: GameManager.TurnState):
	var tween = create_tween()
	if turn_state == GameManager.TurnState.ENEMY:
		tween.tween_property(self, "gradient_sample", 0, transition_duration)
	else:
		tween.tween_property(self, "gradient_sample", 1, transition_duration)
