extends PanelContainer

@export var description_text: Label
@export var name_text: Label
@export var sprite: TextureRect

func _ready() -> void:
	GameManager.UpdateUnitCard.connect(_on_change_unit_card)

func _on_change_unit_card(unit: UnitData):
	if description_text:
		description_text.text = unit.description
	if name_text:
		name_text.text = unit.name
	if sprite:
		sprite.texture = unit.texture
