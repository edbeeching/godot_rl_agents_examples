extends RigidBody3D
class_name Puck

var _initial_position: Vector3

func _ready():
	_initial_position = position
	reset()

func _on_goal_body_entered(_body):
	reset()

func reset():
	position = _initial_position + (Vector3.RIGHT * randf_range(-1.2,1.2))
	linear_velocity = Vector3.ZERO
