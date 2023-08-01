extends AIController2D

@onready var raycast_sensor = $"RaycastSensor2D"

var player = null

func _ready():
	raycast_sensor.activate()

# Stores the action sampled for the agent's policy, running in python
var move_action : float = 0.0

func get_obs():
	var relative = player.fruit.position - position
	var distance = relative.length() / 1500.0 
	relative = relative.normalized() 
	var result := []
	result.append(((player.position.x / WIDTH)-0.5) * 2)
	result.append(((player.position.y / HEIGHT)-0.5) * 2)  
	result.append(relative.x)
	result.append(relative.y)
	result.append(distance)
	var raycast_obs = raycast_sensor.get_observation()
	result.append_array(raycast_obs)

	return {
		"obs": result,
	}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 1,
			"action_type": "continuous"
		},
		}
	
func set_action(action) -> void:	
	move_action = clamp(action["move_action"][0], -1.0, 1.0)
