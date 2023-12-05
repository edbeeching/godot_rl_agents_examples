extends AIController3D


func _physics_process(_delta):
	n_steps += 1
	if n_steps >= reset_after:
		done = true
		needs_reset = true

	if needs_reset:
		reset()


func set_action(action):
	_player.move_action = action["move"][0]
	_player.turn_action = action["turn"][0]


func get_obs():
	return {
		"camera_2d": _player.virtual_camera.get_camera_pixel_encoding(),
	}


func get_obs_space():
	# types of obs space: box, discrete, repeated
	return {
		"camera_2d": {"size": _player.virtual_camera.get_camera_shape(), "space": "box"},
	}


func get_action_space():
	return {
		"move": {"size": 1, "action_type": "continuous"},
		"turn": {"size": 1, "action_type": "continuous"}
	}


func get_reward():
	return reward
