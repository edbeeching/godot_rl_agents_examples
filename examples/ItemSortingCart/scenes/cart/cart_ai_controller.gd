extends AIController3D
class_name CartAIController

@export var playing_area_x_size: float = 20
@export var playing_area_z_size: float = 20

@onready var _playing_area_half_x_size : float = playing_area_x_size / 2
@onready var _playing_area_half_z_size : float = playing_area_z_size / 2

func get_obs() -> Dictionary:
	_player = _player as Cart

	var observations: Array = [
		n_steps / float(reset_after),
		_player.item_collected,
		_player.position.z / _playing_area_half_z_size,
		_player.get_normalized_velocity().z,
		_player.engine_force / _player.acceleration,
		(_player.item.global_position.z - _player.global_position.z) / playing_area_z_size,
		(_player.item.global_position.y - _player.global_position.y) / 15.0,
		_player.item.linear_velocity.y / 10.0,
		_player.item.linear_velocity.z / 10.0,
		(_player.destination.global_position.z - _player.global_position.z) / playing_area_z_size,
		(_player.destination2.global_position.z - _player.global_position.z) / playing_area_z_size,
		_player.item.item_category,
	]
	
	# Clamp obs to -1 to 1 range
	for obs_idx in observations.size():
		observations[obs_idx] = clampf(observations[obs_idx], -1.0, 1.0)
	
	return {"obs": observations}

func get_reward() -> float:
	return reward

func get_action_space() -> Dictionary:
	return {
		"acceleration" : {
			"size": 1,
			"action_type": "continuous"
		}
	}

func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		done = true
		_player.reset()
		reset()

func set_action(action) -> void:
	_player.requested_acceleration = action.acceleration[0]
