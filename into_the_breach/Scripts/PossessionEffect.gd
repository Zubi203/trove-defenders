class_name PossessionEffect
extends AttackEffectData

@warning_ignore("unused_parameter")
func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	var object: MapObject = GameManager.current_board_data[target_tile].object
	if object == null:
		return
	if not object.tree_exited.is_connected(_try_revive_unit):
		object.tree_exited.connect(_try_revive_unit.bind(target_tile))

func _try_revive_unit(target_pos: Vector2i):
	if GameManager.current_board_data[target_pos].object == null and GameManager.last_defeated_unit != null:
		GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.UNIT, target_pos)
