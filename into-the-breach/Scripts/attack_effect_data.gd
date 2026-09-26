#Base resource class to store data for secondary effects of projectiles

class_name AttackEffectData
extends Resource

@export var effect_scene: PackedScene

@warning_ignore("unused_parameter")
func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	pass
