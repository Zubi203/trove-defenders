class_name UnitData
extends Resource

@export_category("Visual")
@export var texture: Texture2D
@export var name: String = "BASE_UNIT"
@export_multiline() var description: String = "DESCRIPTION_HERE"

@export_category("Attack")
@export var attack_data: AttackData
@export var attack_effect_data: AttackEffectData
@export var range_type: GameManager.AttackRangeTypes
@export var dead_zone_type: GameManager.AttackRangeTypes
@export var attack_range: int = 3
@export var dead_zone: int = 0

@export_category("Movement")
@export var max_move_distance: int = 3
@export var is_pushable: bool = true
@export var is_flying: bool = false

@export_category("Other")
@export var health: int = 3
@export var heal_amount: int = 1
@export var hit_sound: AudioStream
@export var heal_sound: AudioStream
@export var move_sound: AudioStream
