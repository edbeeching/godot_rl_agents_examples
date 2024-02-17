extends AIController3D


func _physics_process(_delta):
	n_steps += 1
	if n_steps >= reset_after:
		done = true
		needs_reset = true

	if needs_reset:
		_player.emit_signal("reset", _player)
		reset()

func get_obs() -> Dictionary:
	var obs = []
	var ray_obs = $RayCastSensor3D.calculate_raycasts()

	var goal_distance = _player.global_transform.origin.distance_to(_player.goal.global_transform.origin)
	var goal_vector = (_player.goal.global_transform.origin - _player.global_transform.origin).normalized()
	goal_vector = goal_vector.rotated(Vector3.UP, -_player.rotation.y)
	goal_distance = clamp(goal_distance, 0.0, 20.0)


	obs.append_array(ray_obs)
	obs.append_array([goal_distance/20.0, goal_vector.x, goal_vector.y, goal_vector.z])
	obs.append(_player.is_on_floor())
	var level_obs = [0.0,0.0,0.0,0.0]
	level_obs[_player.current_level] = 1.0
	obs.append_array(level_obs)

	return {"obs":obs}

func get_reward():
	var current_reward = reward
	reward = 0  # reset the reward to zero checked every decision step
	return current_reward
	
func get_action_space():
	return {
		"jump": {"size": 1, "action_type": "continuous"},
		"move": {"size": 2, "action_type": "continuous"},
		"turn": {"size": 2, "action_type": "continuous"}
	}
	
func set_action(action):
	_player.move_action = Vector2(action["move"][0], action["move"][1])
	_player.turn_action = Vector2(action["turn"][0], action["turn"][1])
	_player.jump_action = action["jump"][0] > 0

func get_obs_space() -> Dictionary:
	var obs = get_obs()
	return {
		"obs": {
			"size": [len(obs["obs"])],
			"space": "box"
		},
	}
