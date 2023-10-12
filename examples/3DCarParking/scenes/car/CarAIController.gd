extends AIController3D
class_name CarAIController

func get_obs() -> Dictionary:
	
	# Positions and velocities are converted to the player's frame of reference
	var player_velocity = _player.get_normalized_velocity_in_player_reference()

	var observations : Array = [
		n_steps / float(reset_after),
		player_velocity.x,
		player_velocity.z,
		_player.angular_velocity.y * 1.5,
		_player.steering / deg_to_rad(_player.max_steer_angle)
	]

	# After the first reset, the goal parking position will be assigned,
	# so we provide zero values for those positions before then
	# (used for detecting the size of the observation space)
	if _player.times_restarted == 0:
		observations.append_array([0.0, 0.0, 0.0, 0.0])
	else:
		var goal_transform: Transform3D = _player.goal_parking_spot
		var goal_position = (
		_player.to_local(goal_transform.origin) /
		Vector2(
			_player.playing_area_x_size,
			_player.playing_area_z_size
		).length()
		)
		observations.append_array(
			[
				goal_position.x,
				goal_position.z,
				(goal_transform.basis.z - _player.global_transform.basis.z).x,
				(goal_transform.basis.z - _player.global_transform.basis.z).z,
			]
		)
			
	observations.append_array(_player.raycast_sensor.get_observation())
	return {"obs": observations}

func get_reward() -> float:
	return reward

func get_action_space() -> Dictionary:
	return {
		"acceleration" : {
			"size": 1,
			"action_type": "continuous"
		},
		"steering" : {
			"size": 1,
			"action_type": "continuous"
		},
		}

func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
		done = true

func set_action(action) -> void:
	_player.requested_acceleration = clampf(action.acceleration[0], -1.0, 1.0)
	_player.requested_steering = clampf(action.steering[0], -1.0, 1.0)
