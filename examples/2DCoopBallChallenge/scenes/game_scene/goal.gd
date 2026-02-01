extends Area2D
class_name Goal

@export var goal_positions: GoalPositions
var current_position_index := 0

func _ready() -> void:
	if not goal_positions.is_node_ready():
		await goal_positions.ready
	move_to_random_position()


## Moves the goal to next position, and wraps around
func move_to_next_position():
	await get_tree().physics_frame # Prevents the goal from moving before the ball fully resets
	current_position_index = (current_position_index + 1) % goal_positions.goal_positions.size()
	global_position = goal_positions.goal_positions[current_position_index].global_position


func move_to_previous_position():
	await get_tree().physics_frame # Prevents the goal from moving before the ball fully resets
	current_position_index = max(current_position_index - 1, 0)
	global_position = goal_positions.goal_positions[current_position_index].global_position


func move_to_first_position():
	await get_tree().physics_frame # Prevents the goal from moving before the ball fully resets
	global_position = goal_positions.goal_positions[0].global_position


func move_to_random_position():
	await get_tree().physics_frame # Prevents the goal from moving before the ball fully resets
	global_position = goal_positions.goal_positions.pick_random().global_position
