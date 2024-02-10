extends AIController3D


func _physics_process(_delta):
	n_steps += 1
	if n_steps >= reset_after:
		done = true
		needs_reset = true

	if needs_reset:
		_player.game_over()


func get_obs():
	var goal_distance = 0.0
	var goal_position = Vector3.ZERO
	if _player.next == 0:
		goal_distance = _player.position.distance_to(_player.first_jump_pad.position)
		goal_position = _player.first_jump_pad.global_position

	if _player.next == 1:
		goal_distance = _player.position.distance_to(_player.second_jump_pad.position)
		goal_position = _player.second_jump_pad.global_position


	var goal_vector = _player.to_local(goal_position).normalized()

	goal_distance = clamp(goal_distance, 0.0, 20.0)
	var obs = []
	obs.append_array(
		[
			_player.move_vec.x / _player.MOVE_SPEED,
			_player.move_vec.y / _player.MAX_FALL_SPEED,
			_player.move_vec.z / _player.MOVE_SPEED
		]
	)
	obs.append_array([goal_distance / 20.0, goal_vector.x, goal_vector.y, goal_vector.z])
	obs.append(_player.grounded)
	obs.append_array(_player.raycast_sensor.get_observation())

	return {
		"obs": obs,
	}


func set_action(action):
	_player.move_action = action["move"][0]
	_player.turn_action = action["turn"][0]
	_player.jump_action = action["jump"][0] > 0


func get_action_space():
	return {
		"jump": {"size": 1, "action_type": "continuous"},
		"move": {"size": 1, "action_type": "continuous"},
		"turn": {"size": 1, "action_type": "continuous"}
	}


func get_reward():
	var current_reward = reward
	reward = 0  # reset the reward to zero checked every decision step
	return current_reward
