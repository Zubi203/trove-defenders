class_name PlayerButton
extends Button

signal MoveButtonPressed
signal AttackButtonPressed
signal HealButtonPressed

enum ButtonType {
	MOVE,
	HEAL,
	ATTACK
}
@export var action_icons: Dictionary[ButtonType, Texture2D] = {
	ButtonType.MOVE: null,
	ButtonType.ATTACK: null,
	ButtonType.HEAL: null
}
@export var button_type: ButtonType
@export var button_icon: TextureRect
@export var button_text_main: Label
@export var button_text_secondary: Label
var data: UnitData

func _ready() -> void:
	pressed.connect(_on_pressed)
	

func set_button():
	if button_icon == null or button_text_main == null or button_text_secondary == null:
		return
	if data == null:
		return
	button_icon.texture = action_icons[button_type]
	match button_type:
		ButtonType.MOVE:
			button_text_main.text = "Move"
			button_text_secondary.text = str(data.max_move_distance)
		ButtonType.HEAL:
			button_text_secondary.text = str(data.heal_amount)
			button_text_main.text = "Heal"
		ButtonType.ATTACK:
			button_text_secondary.text = str(data.attack_data.damage)
			button_text_main.text = "Attack"

func _on_pressed():
	match button_type:
		ButtonType.MOVE:
			MoveButtonPressed.emit()
		ButtonType.HEAL:
			HealButtonPressed.emit()
		ButtonType.ATTACK:
			AttackButtonPressed.emit()

func _process(_delta: float) -> void:
	if disabled:
		modulate.a = 0.7
	else:
		modulate.a = 1
