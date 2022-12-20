extends Node3D
class_name AIController

var _player : Player

# ------------------ Godot RL Agents Logic ------------------------------------#
var heuristic := "human"
var done := false
# example actions

var movement_action := Vector2(0.0, 0.0)
var look_action := Vector2(0.0, 0.0)
var jump_action := false
var shoot_action := false

var needs_reset := false
var reward := 0.0
var n_steps_without_positive_reward = 0
var n_steps = 0

@onready var wide_raycast_sensor = $WideRaycastSensor
@onready var narrow_raycast_sensor = $NarrowRaycastSensor

func init(player):
	_player=player

func reset():
	n_steps_without_positive_reward = 0
	n_steps = 0

func reset_if_done():
	if done:
		reset()

func get_obs():
	var obs = []
	obs.append_array(wide_raycast_sensor.get_observation())
	obs.append_array(narrow_raycast_sensor.get_observation())
	return {
		"obs":obs
	}

func get_reward():	
	var  total_reward = reward + shaping_reward()
	if total_reward <= 0.0:
		n_steps_without_positive_reward += 1
	else:
		n_steps_without_positive_reward -= 1
		n_steps_without_positive_reward = max(0, n_steps_without_positive_reward)
	return total_reward

func zero_reward():
	reward = 0.0

func shaping_reward():
	var s_reward = 0.0
	return s_reward


func set_heuristic(h):
	# sets the heuristic from "human" or "model" nothing to change here
	heuristic = h
   
func get_obs_space():
	var obs = get_obs()
	return {
		"obs": {
			"size": [len(obs["obs"])],
			"space": "box"
		},
	}

func get_action_space():
	return {
		"movement_action" : {
			"size": 2,
			"action_type": "continuous"
		},  
		"look_action" : {
			"size": 2,
			"action_type": "continuous"
		},      
		"jump_action" : {
			"size": 2,
			"action_type": "discrete"
		},
		"shoot_action" : {
			"size": 2,
			"action_type": "discrete"
		},
	}

func get_done():
	return done
	
func set_done_false():
	done = false

func set_action(action):	
	movement_action = Vector2(clamp(action["movement_action"][0],-1.0,1.0), clamp(action["movement_action"][1],-1.0,1.0))
	look_action =  Vector2(clamp(action["look_action"][0],-1.0,1.0), clamp(action["look_action"][1],-1.0,1.0))
	jump_action = action["jump_action"] == 1
	shoot_action = action["shoot_action"] == 1


func _physics_process(delta):
	n_steps += 1
	if n_steps > 4000:
		_player.needs_respawn = true
