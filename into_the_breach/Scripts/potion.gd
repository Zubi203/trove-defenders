extends Area2D

enum PotionType {
	HEAL,
	ATTACK
}

var type: PotionType
@export var buff_amount: int = 1
@export var sprites: Dictionary[PotionType, Texture2D] = {
	PotionType.HEAL: null,
	PotionType.ATTACK: null
}
@export var sprite: Sprite2D

func _ready() -> void:
	if randf() < 0.5:
		type = PotionType.ATTACK
	else:
		type = PotionType.HEAL
	
	if sprites[type] != null and sprite != null:
		sprite.texture = sprites[type]


func _on_area_entered(area: Area2D) -> void:
	if not area is MapObject:
		return
	for child in area.get_children():
		if child is HealthComponent and type == PotionType.HEAL:
			child.heal(buff_amount)
			queue_free()
		if child is AttackComponent and type == PotionType.ATTACK:
			child.additional_damage += buff_amount
			child._flash()
			queue_free()
