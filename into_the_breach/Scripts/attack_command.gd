class_name AttackCommand
extends Command

var attack_component: AttackComponent
var target_pos: Vector2i

static func create(attack_comp: AttackComponent, pos: Vector2i) -> AttackCommand:
	var cmd = AttackCommand.new()
	cmd.attack_component = attack_comp
	cmd.target_pos = pos
	return cmd

func execute():
	if attack_component:
		attack_component._shoot_projectile(target_pos)
