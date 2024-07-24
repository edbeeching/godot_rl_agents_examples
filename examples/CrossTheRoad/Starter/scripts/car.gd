extends Node3D
class_name Car

## Car, moves along x axis,
## and changes direction once left or right edge is reached

#region Initialized by car manager
var step_size: int
var left_edge_x: int
var right_edge_x: int
var current_direction: int = 1
#endregion

func _physics_process(_delta: float) -> void:
	if not (position.x > left_edge_x and position.x < right_edge_x):
		current_direction = -current_direction
		rotation.y = current_direction / 2.0 * PI
	position.x += step_size * current_direction
