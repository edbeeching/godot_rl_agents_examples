extends AIController3D

@export var raycast_sensor: Node3D
@export var other_player_raycast_sensor: Node3D
@export var puck: RigidBody3D

const POSITION_NORMALIZATION_FACTOR: float = 6.50
const VELOCITY_NORMALIZATION_FACTOR: float = 5.8


func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
		done = true
		reward -= 10


func get_obs() -> Dictionary:
	# Positions and velocities are converted to the player's frame of reference
	# Scaled to be mostly within the -1 to 1 range

	var puck_position = _player.to_local(puck.global_position) / POSITION_NORMALIZATION_FACTOR
	var puck_velocity = (
		(_player.global_transform.basis.inverse() * puck.linear_velocity)
		/ VELOCITY_NORMALIZATION_FACTOR
	)
	var player_velocity = (
		(_player.global_transform.basis.inverse() * _player.linear_velocity)
		/ VELOCITY_NORMALIZATION_FACTOR
	)
	var goal_position = (
		_player.to_local(_player.goal.global_position) / POSITION_NORMALIZATION_FACTOR
	)

	var other_player_relative_position = (
		_player.to_local(_player.other_player.global_position) / POSITION_NORMALIZATION_FACTOR
	)
	var other_player_velocity = (
		(_player.global_transform.basis.inverse() * _player.other_player.linear_velocity)
		/ VELOCITY_NORMALIZATION_FACTOR
	)
	var other_player_goal_position = (
		_player.to_local(_player.other_player.goal.global_position) / POSITION_NORMALIZATION_FACTOR
	)


	var obs = [
		# How much of the episode has elapsed
		n_steps / float(reset_after),
		puck_position.x,
		puck_position.z,
		player_velocity.x,
		player_velocity.z,
		puck_velocity.x,
		puck_velocity.z,
		goal_position.x,
		goal_position.z,
		#region Optional: Data from the other player
		#other_player_relative_position.x,
		#other_player_relative_position.z,
		#other_player_velocity.x,
		#other_player_velocity.z,
		#endregion
		other_player_goal_position.x,
		other_player_goal_position.z,
		#clampf(_player._time_since_puck_pushed / 3.0, 0, 3.0) # Optional
	]

	# Information for the current and previous frame from raycast sensors
	# (using two frames to include information about velocity)
	var ray_obs = raycast_sensor.get_observation()
	obs.append_array(ray_obs)

#region Optional: Data from the other player
	#var other_player_ray_obs = other_player_raycast_sensor.get_observation()
	#obs.append_array(other_player_ray_obs)
#endregion

	return {"obs": obs}


func reset():
	n_steps = 0
	needs_reset = false


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {"move": {"size": 2, "action_type": "continuous"}}


func set_action(action) -> void:
	_player.requested_movement = Vector3(
		clampf(action.move[0], -1, 1), 0, clampf(action.move[1], -1, 1)
	)
