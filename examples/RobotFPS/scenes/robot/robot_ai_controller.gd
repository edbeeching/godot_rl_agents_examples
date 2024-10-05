extends AIController3D
class_name RobotAIController

## How many frames of observations to stack
## E.g. 1 means current frame only, 2 means current and previous frame
@export var obs_frame_stack: int = 3

@export var playing_area_size: float = 30
@onready var raycast_sensor = $RaycastSensor as RayCastSensor3D

## Reference set by game manager
var game_manager: GameManager


func reset():
	n_steps = 0
	needs_reset = false
	obs_history.clear()


# Includes the history of observations for n frames (including current)
var obs_history: Array[Array]


## Returns stacked observations for n frames
func get_obs() -> Dictionary:
	var current_frame_obs := get_current_frame_obs()

	if obs_history.is_empty():
		obs_history.resize(obs_frame_stack)
		obs_history.fill(current_frame_obs)

	obs_history.append(current_frame_obs)
	obs_history.remove_at(0)

	var stacked_obs: Array[float]

	for obs_array in obs_history:
		stacked_obs.append_array(obs_array)

	return {"obs": stacked_obs}


## Returns observations for the current frame as an array
func get_current_frame_obs() -> Array:
	return raycast_sensor.get_observation()


## Overriden method to exclude reset on timeout
func _physics_process(_delta):
	n_steps += 1
	#if n_steps > reset_after:
	#needs_reset = true


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {
		"accelerate_forward": {"size": 3, "action_type": "discrete"},
		"accelerate_sideways": {"size": 3, "action_type": "discrete"},
		"turn": {"size": 3, "action_type": "discrete"},
		"shoot": {"size": 2, "action_type": "discrete"},
	}


func set_action(action: Dictionary) -> void:
	_player.requested_acceleration_forward = action.accelerate_forward - 1
	_player.requested_acceleration_sideways = action.accelerate_sideways - 1
	_player.requested_turn = action.turn - 1
	_player.shoot_ball_requested = bool(action.shoot)
