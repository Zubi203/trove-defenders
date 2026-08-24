class_name PossessionEffect
extends AttackEffectData

func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	await GameManager.get_tree().create_timer(1).timeout
	_try_revive_unit(target_tile)

func _try_revive_unit(target_pos: Vector2i):
	if GameManager.current_board_data[target_pos].object == null:
		GameManager.SpawnAttackEffect.emit(AttackEffectManager.AttackEffects.UNIT, target_pos)
