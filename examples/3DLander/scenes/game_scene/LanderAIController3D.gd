extends AIController3D
class_name LanderAIController

## AIController for the Lander. Handles the action definitions, actions, observations, 
## passes the rewards and resets the episode on timeout.

func get_obs() -> Dictionary:
	_player = _player as Lander

	# Positions and velocities are converted to the player's frame of reference
	var player_velocity = _player.get_velocity_in_player_reference() / 50.0
	var player_angular_velocity = _player.get_angular_velocity_in_player_reference() / 10.0

	var observations : Array = [
		n_steps / float(reset_after),
		player_velocity.x,
		player_velocity.y,
		player_velocity.z,
		player_angular_velocity.x,
		player_angular_velocity.y,
		player_angular_velocity.z,
		_player._legs_in_contact_with_ground / 4.0
	]

	observations.append_array(_player.get_orientation_as_array())

	# After the first reset, the landing position will be assigned
	if _player.times_restarted == 0:
		observations.append_array([0.0, 0.0, 0.0, 0.0])
	else:
		var goal_position: Vector3 = (
		_player.get_goal_position_in_player_reference()
		)
		observations.append_array(
			[
				goal_position.x,
				goal_position.y,
				goal_position.z,
				_player.get_player_goal_direction_difference()
			]
		)
	observations.append_array(_player.raycast_sensor.get_observation())
	return {"obs": observations}

func get_reward() -> float:
	return reward

func get_action_space() -> Dictionary:
	return {
		"back_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"forward_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"left_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"right_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"turn_left_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"turn_right_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"up_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
	}

func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
		done = true
		reward = _player.episode_ended_unsuccessfully_reward / 10.0

func set_action(action) -> void:
	_player.up_thruster.thruster_strength = (
		action.up_thruster
		) * _player.up_thruster_max_force
	_player.forward_thruster.thruster_strength = (
		action.forward_thruster
		) * _player.navigation_thruster_max_force
	_player.back_thruster.thruster_strength = (
		action.back_thruster
		) * _player.navigation_thruster_max_force
	_player.left_thruster.thruster_strength = (
		action.left_thruster
		) * _player.navigation_thruster_max_force
	_player.right_thruster.thruster_strength = (
		action.right_thruster
		) * _player.navigation_thruster_max_force
	_player.turn_left_thruster.thruster_strength = (
		action.turn_left_thruster
		) * _player.navigation_thruster_max_force
	_player.turn_right_thruster.thruster_strength = (
		action.turn_right_thruster
		) * _player.navigation_thruster_max_force
