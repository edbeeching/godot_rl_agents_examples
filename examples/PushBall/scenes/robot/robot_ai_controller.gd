extends AIController3D
class_name RobotAIController

@export var raycast_sensors: Array[Node3D]
@onready var player = get_parent() as Player
var is_success: bool = false


func get_obs() -> Dictionary:
	var observations: Array[float] = []
	for raycast_sensor in raycast_sensors:
		var obs = raycast_sensor.get_observation()
		observations.append_array(obs)

	var player_to_goal := player.to_local(player.goal.global_position)
	var player_to_goal_dir := player_to_goal.normalized()
	var player_to_goal_dist := clampf(player_to_goal.length() / 5.0, 0, 1.0)

	var player_to_ball := player.to_local(player.ball.global_position)
	var player_to_ball_dir := player_to_ball.normalized()
	var player_to_ball_dist := clampf(player_to_ball.length() / 10.0, 0, 1.0)

	var player_velocity = player.linear_velocity
	player_velocity = player.global_basis.inverse() * player_velocity
	player_velocity = player_velocity.limit_length(4) / 4

	var player_angular_velocity = player.angular_velocity.y
	player_angular_velocity = clampf(player_angular_velocity / 4.0, 0.0, 1.0)

	var ball_velocity = player.ball.linear_velocity
	ball_velocity = player.global_basis.inverse() * ball_velocity
	ball_velocity = ball_velocity.limit_length(4) / 4

	(
		observations
		. append_array(
			[
				player_to_goal_dir.x,
				player_to_goal_dir.z,
				player_to_goal_dist,
				player_to_ball_dir.x,
				player_to_ball_dir.z,
				player_to_ball_dist,
				player_velocity.x,
				player_velocity.z,
				ball_velocity.x,
				ball_velocity.z,
				n_steps / float(reset_after),
			]
		)
	)

	return {"obs": observations}


func get_info() -> Dictionary:
	return {"is_success": is_success}


func get_reward() -> float:
	return reward


func _physics_process(_delta: float) -> void:
	# Reset on timeout, this is implemented in parent class to set needs_reset to true,
	# we are re-implementing here to call player.game_over() that handles the game reset.
	n_steps += 1
	if n_steps > reset_after:
		n_steps = 0
		player.game_over(-10, false)

	# In training or onnx inference modes, this method will be called by sync node with actions provided,
	# For human control mode the method will not be called, so we call it here without any actions provided.
	if control_mode == ControlModes.HUMAN:
		set_action()


func get_action_space() -> Dictionary:
	return {
		"move": {"size": 1, "action_type": "continuous"},
		"turn": {"size": 1, "action_type": "continuous"}
	}


func get_action() -> Array:
	return [player.requested_movement, player.requested_turn, player.requested_ball_kick]


func set_action(action = null) -> void:
	# If there's no action provided, it means that AI is not controlling the robot (human control)
	if not action:
		var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		player.requested_movement = input.y
		player.requested_turn = -input.x
	else:
		player.requested_movement = clampf(action.move[0], -1.0, 0.2)
		player.requested_turn = clampf(action.turn[0], -1.0, 1.0)
