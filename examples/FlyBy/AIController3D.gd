extends AIController3D


func get_obs():
	if _player.cur_goal == null:
		_player.game_over()
	var goal_vector = to_local(_player.cur_goal.position)
	var goal_distance = goal_vector.length()
	goal_vector = goal_vector.normalized()
	goal_distance = clamp(goal_distance, 0.0, 50.0)

	var next_goal = _player.environment.get_next_goal(_player.cur_goal)
	var next_goal_vector = to_local(next_goal.position)
	var next_goal_distance = next_goal_vector.length()
	next_goal_vector = next_goal_vector.normalized()
	next_goal_distance = clamp(next_goal_distance, 0.0, 50.0)

	var obs = [
		goal_vector.x,
		goal_vector.y,
		goal_vector.z,
		goal_distance / 50.0,
		next_goal_vector.x,
		next_goal_vector.y,
		next_goal_vector.z,
		next_goal_distance / 50.0
	]

	return {"obs": obs}


func get_action_space():
	return {
		"pitch": {"size": 1, "action_type": "continuous"},
		"turn": {"size": 1, "action_type": "continuous"}
	}


func set_action(action):
	_player.turn_input = action["turn"][0]
	_player.pitch_input = action["pitch"][0]


func get_reward():
	return reward
