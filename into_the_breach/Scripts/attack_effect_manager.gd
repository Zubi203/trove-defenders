#central hub script to manage the spawning and 
#placement of projectile secondary effects

class_name AttackEffectManager
extends Node2D

enum AttackEffects{
	CHAIN_LIGHTNING,
	PUSH,
	POTION,
	UNIT,
	DUST
}

@export var effect_scenes: Dictionary[AttackEffects, PackedScene] = {
	AttackEffects.CHAIN_LIGHTNING: null,
	AttackEffects.PUSH: null,
	AttackEffects.POTION: null,
	AttackEffects.UNIT: null,
	AttackEffects.DUST: null
}
@export var number_effect: PackedScene = null
@export var unit_container: Node2D

func _ready() -> void:
	GameManager.SpawnAttackEffect.connect(spawn_effect)

func spawn_effect(effect_type: AttackEffects, spawn_tile: Vector2i, _direction_tile: Vector2i = Vector2i.ZERO, _target_object: MapObject = null):
	
	#if requested effect doesnt have a scene reference in the dictionary, cancel execution
	if effect_scenes[effect_type] == null:
		return
	
	#create effect instance
	var effect = effect_scenes[effect_type].instantiate()
	effect.global_position = GameManager.current_board.map_to_local(spawn_tile)
	add_child.call_deferred(effect)
	
	#unit revival logic (Spirit Caller ability)
	if effect is Unit:
		
		#revive visual effect
		if number_effect:
			var num: NumberEffect = number_effect.instantiate()
			effect.add_child(num)
			num.position = effect.position
			num.animate("REVIVED", true)
		
		#attach PlayerController component to revived unit
		var controller = PlayerController.new()
		effect.add_child(controller)
		
		#assign appropriate unit data to revived unit
		effect.data = GameManager.last_defeated_unit
		
		#add the revived unit as a child to the unit container
		if unit_container and effect.get_parent() != null:
			effect.reparent(unit_container)
		
		#update the game board
		GameManager.UpdateBoard.emit()
