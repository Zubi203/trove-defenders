class_name AttackCommand
extends Command

var attack_component: AttackComponent

static func create(attack_comp: AttackComponent) -> AttackCommand:
	var cmd = AttackCommand.new()
	cmd.attack_component = attack_comp
	return cmd

func execute():
	if attack_component:
		attack_component._shoot_projectile()
