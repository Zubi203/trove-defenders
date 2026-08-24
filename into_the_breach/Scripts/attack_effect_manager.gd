class_name AttackEffectManager
extends Node2D

enum AttackEffects{
	CHAIN_LIGHTNING,
	PUSH,
	POTION,
	UNIT
}

@export var effect_scenes: Dictionary[AttackEffects, PackedScene] = {
	AttackEffects.CHAIN_LIGHTNING: null,
	AttackEffects.PUSH: null,
	AttackEffects.POTION: null,
	AttackEffects.UNIT: null
}
@export var chain_lightning_data: AttackData
@export var unit_container: Node2D

func _ready() -> void:
	GameManager.SpawnAttackEffect.connect(spawn_effect)

func spawn_effect(effect_type: AttackEffects, spawn_tile: Vector2i, direction_tile: Vector2i = Vector2i.ZERO, target_object: MapObject = null):
	if effect_scenes[effect_type] == null:
		return
	var effect = effect_scenes[effect_type].instantiate()
	effect.global_position = GameManager.current_board.map_to_local(spawn_tile)
	add_child.call_deferred(effect)
	if effect is ChainLightning:
		var pos = GameManager.current_board.map_to_local(spawn_tile)
		var target_pos = GameManager.current_board.map_to_local(direction_tile)
		effect._set_projectile(null, pos, target_pos, chain_lightning_data)
	if effect is Unit:
		var controller = PlayerController.new()
		effect.add_child(controller)
		effect.data = GameManager.last_defeated_unit
		if unit_container and effect.get_parent() != null:
			effect.reparent(unit_container)
