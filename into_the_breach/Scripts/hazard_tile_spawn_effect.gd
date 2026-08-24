class_name HazardTileSpawnEffect
extends AttackEffectData

@export var tile_to_spawn: HazardTileManager.HazardTiles

func activate_effect(target_tile: Vector2i, attacker_pos: Vector2i):
	GameManager.SpawnHazardTile.emit(tile_to_spawn, target_tile)
