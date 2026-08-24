class_name AttackData
extends Resource

@export var name: String = ""
@export var damage: int = 1
@export var type: GameManager.AttackTypes = GameManager.AttackTypes.STRAIGHT
@export var texture: Texture2D
@export var is_piercing: bool = false
@export var projectile_scene: PackedScene
@export var attack_sound: AudioStream
