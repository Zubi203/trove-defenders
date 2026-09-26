class_name MoveCommand
extends Command

var move_component: MovementComponent
var target_pos: Vector2i
var original_pos: Vector2i

#scene constructor function
static func create(move_comp: MovementComponent, pos: Vector2i) -> MoveCommand:
	var cmd = MoveCommand.new()
	cmd.move_component = move_comp
	cmd.target_pos = pos
	cmd.original_pos = GameManager.current_board.local_to_map(move_comp.global_position)
	return cmd

func execute():
	move_component._on_move_unit(target_pos)

func undo():
	if move_component == null:
		return
	move_component._on_move_unit(original_pos)
	move_component.UndoMove.emit()
