extends AIController3D

var n_steps_without_positive_reward = 0


func reset():
	done = true
	n_steps = 0
	n_steps_without_positive_reward = 0
	reward = 0.0
	needs_reset = false


func get_obs():
	var next_waypoint_position = GameManager.get_next_waypoint(_player).position

	var goal_distance = position.distance_to(next_waypoint_position)
	goal_distance = clamp(goal_distance, 0.0, 40.0)
	var goal_vector = (next_waypoint_position - position).normalized()
	goal_vector = goal_vector.rotated(Vector3.UP, -rotation.y)
	var obs = []
	obs.append(goal_distance / 40.0)
	obs.append_array([goal_vector.x, goal_vector.y, goal_vector.z])

	var next_next_waypoint_position = GameManager.get_next_next_waypoint(_player).position

	var next_next_goal_distance = position.distance_to(next_next_waypoint_position)
	next_next_goal_distance = clamp(next_next_goal_distance, 0.0, 80.0)
	var next_next_goal_vector = (next_next_waypoint_position - position).normalized()
	next_next_goal_vector = next_next_goal_vector.rotated(Vector3.UP, -rotation.y)
	obs.append(next_next_goal_distance / 80.0)
	obs.append_array([next_next_goal_vector.x, next_next_goal_vector.y, next_next_goal_vector.z])

	obs.append(clamp(_player.brake / 40.0, -1.0, 1.0))
	obs.append(clamp(_player.engine_force / 40.0, -1.0, 1.0))
	obs.append(clamp(_player.steering, -1.0, 1.0))
	obs.append_array(
		[
			clamp(_player.linear_velocity.x / 40.0, -1.0, 1.0),
			clamp(_player.linear_velocity.y / 40.0, -1.0, 1.0),
			clamp(_player.linear_velocity.z / 40.0, -1.0, 1.0)
		]
	)
	obs.append_array(_player.sensor.get_observation())
	return {"obs": obs}


func get_action_space():
	return {
		"turn": {"size": 1, "action_type": "continuous"},
		"accelerate": {"size": 2, "action_type": "discrete"},
		"brake": {"size": 2, "action_type": "discrete"},
	}


func set_action(action):
	_player.turn_action = action["turn"][0]
	_player.acc_action = action["accelerate"] == 1
	_player.brake_action = action["brake"] == 1


func get_reward():
	var total_reward = reward + shaping_reward()
	if total_reward <= 0.0:
		n_steps_without_positive_reward += 1
	else:
		n_steps_without_positive_reward -= 1
		n_steps_without_positive_reward = max(0, n_steps_without_positive_reward)
	return total_reward


func shaping_reward():
	var s_reward = 0.0
	var goal_distance = _player.position.distance_to(
		GameManager.get_next_waypoint(_player).position
	)
	#prints(goal_distance, best_goal_distance, best_goal_distance - goal_distance)
	if goal_distance < _player.best_goal_distance:
		s_reward += _player.best_goal_distance - goal_distance
		_player.best_goal_distance = goal_distance

	# A speed based reward
	var speed_reward = _player.linear_velocity.length() / 100
	speed_reward = clamp(speed_reward, 0.0, 0.1)

	return s_reward + speed_reward
