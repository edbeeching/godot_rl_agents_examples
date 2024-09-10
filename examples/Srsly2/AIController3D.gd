extends AIController3D

var move = Vector2.ZERO
var jump = false
@onready var red = $".."
@onready var green = $"../../Green"


func get_obs() -> Dictionary:
	var obs := [
		red.position.x,
		red.position.z,
		green.position.x,
		green.position.z,
	]
	return {"obs": obs}

func get_reward() -> float:
	return reward

func get_action_space() -> Dictionary:
	return {
		"move" : {
			"size": 2,
			"action_type": "continuous"
		},
		"jump": {
			"size": 1,
			"action_type": "discrete"
		}
	}

func set_action(action) -> void:
	move.x = action["move"][0]
	move.y = action["move"][1]
	jump = action["jump"] == 1
