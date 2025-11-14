extends AIController3D
class_name RobotAIController


func get_obs() -> Dictionary:
	_player = _player as Robot

	var observations: Array[float] = []

	for sensor in _player.sensors:
		observations.append_array(sensor.get_observation())

	observations.append(clampf(_player._jump_timer / 1.0, 0, 1.0))
	observations.append_array(_player.turret.get_current_aiming_orientation_obs())
	return {"obs": observations}


func reset():
	super.reset()


func _physics_process(_delta):
	n_steps += 1
	if n_steps > reset_after:
		reset()
		done = true


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {
		"move": {"size": 3, "action_type": "discrete"},
		"jump": {"size": 2, "action_type": "discrete"},
	}


func set_action(action) -> void:
	_player.requested_movement_sideways = action.move - 1
	_player.requested_jump = bool(action.jump)

	# Small penalties to potentially minimize unecessary movement/jumping
	reward -= 0.01 * float(_player.requested_jump)
	reward -= 0.001 * abs(action.move - 1)
