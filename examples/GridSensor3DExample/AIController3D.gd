extends AIController3D


@onready var grid_sensor_3d = $GridSensor3D

var fb_action : float = 0.0
var turn_action : float = 0.0

func get_obs() -> Dictionary:
	var obs = grid_sensor_3d.get_observation()
	return {"obs": obs}

func get_reward() -> float:
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"fb" : {
			"size": 1,
			"action_type": "continuous"
		},
		"turn" : {
			"size": 1,
			"action_type": "continuous"
		},
	}
	
func set_action(action) -> void:	
	fb_action = clamp(action["fb"][0], -1.0, 1.0)
	turn_action = clamp(action["turn"][0], -1.0, 1.0)
