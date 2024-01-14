extends RigidBody3D
class_name Ball

@export var max_velocity: float = 8.0

var is_resetting: bool
var ball_served: bool
var new_position: Vector3


func _integrate_forces(state):
	state.linear_velocity = state.linear_velocity.limit_length(max_velocity)


func reset(position_after_reset: Vector3):
	ball_served = false
	is_resetting = true
	gravity_scale = 0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_position = position_after_reset
	new_position = position_after_reset


func _on_body_entered(body):
	if ball_served:
		return

	var player = body as Robot

	if player and player.ai_controller.is_serving and not ball_served:
		ball_served = true
		player.ai_controller.is_serving = false
		gravity_scale = 1.45
