extends VehicleBody3D
class_name Player

const STEER_SPEED = 6.0
const STEER_LIMIT = 0.4
var steer_target = 0

@export var controlled = false
@export var engine_force_value = 40
@export var brake_force_value = 60


enum VEHICLE_TYPES {RedConvertible, Car, GreenJeep,PoliceCar, FireTruck, Delivery, GarbageTruck, Hatchback}
var  VEHICLE_TYPES_STRINGS = ["RedConvertible", "Car", "GreenJeep","PoliceCar", "FireTruck", "Delivery", "GarbageTruck", "Hatchback"]
@export var vehicle_type : VEHICLE_TYPES = VEHICLE_TYPES.RedConvertible

# ------------------ Godot RL Agents Logic ------------------------------------#
var _heuristic := "human"
var done := false
# example actions
var turn_action := 0.0
var acc_action := false
var brake_action := false
var needs_reset := false
var reward := 0.0
var starting_position : Vector3
var starting_rotation : Vector3
var best_goal_distance 
var n_steps_without_positive_reward = 0
var n_steps = 0
@onready var sensor = $RayCastSensor3D


	

func reset():
	position = starting_position
	rotation = starting_rotation
	n_steps_without_positive_reward = 0
	n_steps = 0
	reward = 0.0
	GameManager.reset_waypoints(self)
	best_goal_distance = position.distance_to(GameManager.get_next_waypoint(self).position)
	# The reset logic e.g reset if a player dies etc, reset health, ammo, position, etc ...
	pass


func reset_if_done():
	if done:
		reset()

func get_obs():
	var next_waypoint_position = GameManager.get_next_waypoint(self).position
		
	var goal_distance = position.distance_to(next_waypoint_position)
	goal_distance = clamp(goal_distance, 0.0, 40.0)
	var goal_vector = (next_waypoint_position - position).normalized()
	goal_vector = goal_vector.rotated(Vector3.UP, -rotation.y)
	var obs = []
	obs.append(goal_distance/40.0)
	obs.append_array([goal_vector.x, 
					goal_vector.y, 
					goal_vector.z])
					
	var next_next_waypoint_position = GameManager.get_next_next_waypoint(self).position
		
	var next_next_goal_distance = position.distance_to(next_next_waypoint_position)
	next_next_goal_distance = clamp(next_next_goal_distance, 0.0, 80.0)
	var next_next_goal_vector = (next_next_waypoint_position - position).normalized()
	next_next_goal_vector = next_next_goal_vector.rotated(Vector3.UP, -rotation.y)					
	obs.append(next_next_goal_distance/80.0)
	obs.append_array([next_next_goal_vector.x, 
				next_next_goal_vector.y, 
				next_next_goal_vector.z])	
				
	obs.append(clamp(brake/40.0,-1.0,1.0))	
	obs.append(clamp(engine_force/40.0,-1.0,1.0))
	obs.append(clamp(steering,-1.0, 1.0))
	obs.append_array([clamp(linear_velocity.x/40.0,-1.0,1.0), 
				clamp(linear_velocity.y/40.0,-1.0,1.0), 
				clamp(linear_velocity.z/40.0,-1.0,1.0)])	
	obs.append_array(sensor.get_observation())
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
	var goal_distance = position.distance_to(GameManager.get_next_waypoint(self).position)
	#prints(goal_distance, best_goal_distance, best_goal_distance - goal_distance)
	if goal_distance < best_goal_distance:
		
		s_reward += best_goal_distance - goal_distance
		best_goal_distance = goal_distance
	
	# A speed based reward
	var speed_reward = linear_velocity.length() / 100
	speed_reward = clamp(speed_reward, 0.0, 0.1)

	return s_reward + speed_reward


func set_heuristic(heuristic):
	# sets the heuristic from "human" or "model" nothing to change here
	self._heuristic = heuristic
   
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
		"turn" : {
			"size": 1,
			"action_type": "continuous"
		},        
		"accelerate" : {
			"size": 2,
			"action_type": "discrete"
		},
		"brake" : {
			"size": 2,
			"action_type": "discrete"
		},
	}

func get_done():
	return done


func set_action(action):	
	turn_action = action["turn"][0]
	acc_action = action["accelerate"] == 1
	brake_action = action["brake"] == 1
# ----------------------------------------------------------------------------#

func get_steer_target():
	if _heuristic == "human":
		return Input.get_axis("turn_right", "turn_left")
	else:
		return clamp(turn_action, -1.0, 1.0)

func get_accelerate_value():
	if _heuristic == "human":
		return Input.is_action_pressed("accelerate")
	else:
		return acc_action

func get_brake_value():
	if _heuristic == "human":
		return Input.is_action_pressed("reverse")
	else:
		return brake_action

func _ready():
	GameManager.register_player(self)
	best_goal_distance = position.distance_to(GameManager.get_next_waypoint(self).position)
	$Node/Camera3D.current = controlled
	starting_position = position
	starting_rotation = rotation
	
	$Meshes.set_mesh(VEHICLE_TYPES_STRINGS[vehicle_type])

func set_control(value:bool):
	controlled = value
	$Node/Camera3D.current = value

func crossed_waypoint():
	reward += 100.0

	best_goal_distance = position.distance_to(GameManager.get_next_waypoint(self).position)

func bonus_reward():
	print("bonus reward")
	reward += 50.0

func set_done_false():
	done = false

func check_reset_conditions():
	if done: 
		return

	n_steps += 1
	
	if n_steps > 10000:
		print("resetting due to n_steps >10000")
		done = true
		reset()
		return			
	
#	#var up_axis = transform
	if n_steps_without_positive_reward > 1000:
		print("resetting due to n_steps_without_positive_reward >1000")
		reward -= 10.0
		done = true
		reset()
		return		
	
	if transform.basis.y.dot(Vector3.UP) < 0.0:
		print("resetting due to transform.basis.y.dot(Vector3.UP) < 0.0")
		#reward -= 10.0
		done = true
		reset()
		return
	
	if position.y < -5.0:
		print("resetting due to position.y < -5.0")
		reward -= 10.0
		done = true	
		reset()
		return
	

func _print_goal_info():
	var next_waypoint_position = GameManager.get_next_waypoint(self).position
		
	var goal_distance = position.distance_to(next_waypoint_position)
	goal_distance = clamp(goal_distance, 0.0, 20.0)
	var goal_vector = (next_waypoint_position - position).normalized()
	goal_vector = goal_vector.rotated(Vector3.UP, -rotation.y)
	
	prints(goal_distance, goal_vector)

func _physics_process(delta):
	if  _heuristic == "human" and not controlled: return
	if needs_reset:
		needs_reset = false
		reset()
		return
	check_reset_conditions()
	#_print_goal_info()
	var fwd_mps = (linear_velocity * transform.basis).x
	#shaping_reward()
	steer_target = get_steer_target()
	steer_target *= STEER_LIMIT
	var accelerating = false
	if get_accelerate_value():
		accelerating = true
		# Increase engine force at low speeds to make the initial acceleration faster.
		var speed = linear_velocity.length()
		if speed < 5 and speed != 0:
			engine_force = clamp(engine_force_value * 5 / speed, 0, 100)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0
		
	$Arrow3D.look_at(GameManager.get_next_waypoint(self).position)
	
	if not accelerating and get_brake_value():
		# Increase engine force at low speeds to make the initial acceleration faster.
		if fwd_mps >= -1:
			var speed = linear_velocity.length()
			if speed < 5 and speed != 0:
				engine_force = -clamp(engine_force_value * 5 / speed, 0, 100)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1*brake_force_value
	else:
		brake = 0.0

	steering = move_toward(steering, steer_target, STEER_SPEED * delta)

	
		
