extends AIController3D


# ------------------ Godot RL Agents Logic ------------------------------------#
# example actions

var movement_action := Vector2(0.0, 0.0)
var look_action := Vector2(0.0, 0.0)
var jump_action := false
var shoot_action := false

var n_steps_without_positive_reward = 0

@onready var wide_raycast_sensor = $WideRaycastSensor
@onready var narrow_raycast_sensor = $NarrowRaycastSensor

func init(player):
	_player=player

func set_team(value):
	wide_raycast_sensor.team = value
	narrow_raycast_sensor.team = value
	if value == 0:
		wide_raycast_sensor.team_collision_mask = 8
		wide_raycast_sensor.enemy_collision_mask = 16
		narrow_raycast_sensor.team_collision_mask = 8
		narrow_raycast_sensor.enemy_collision_mask = 16
	elif value == 1:
		wide_raycast_sensor.team_collision_mask = 16
		wide_raycast_sensor.enemy_collision_mask = 8
		narrow_raycast_sensor.team_collision_mask = 16
		narrow_raycast_sensor.enemy_collision_mask = 8
	

func reset():
	n_steps_without_positive_reward = 0
	n_steps = 0

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


func shaping_reward():
	var s_reward = 0.0
	return s_reward


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


func set_action(action):	
	movement_action = Vector2(clamp(action["movement_action"][0],-1.0,1.0), clamp(action["movement_action"][1],-1.0,1.0))
	look_action =  Vector2(clamp(action["look_action"][0],-1.0,1.0), clamp(action["look_action"][1],-1.0,1.0))
	jump_action = action["jump_action"] == 1
	shoot_action = action["shoot_action"] == 1


func _physics_process(_delta):
	n_steps += 1
	if n_steps > 4000:
		_player.needs_respawn = true
