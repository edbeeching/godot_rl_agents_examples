extends CharacterBody3D
class_name Player
const MOVE_SPEED = 12
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
const TURN_SENS = 2.0
const MAX_STEPS = 10000
 
@onready var cam = $Camera
var move_vec = Vector3()
var y_velo = 0

# RL related variables
@onready var robot = $Robot
@onready var virtual_camera = $RGBCameraSensor3D

var next = 1
var done = false
var needs_reset = false
var just_reached_negative = false
var just_reached_positive = false
var just_fell_off = false
var best_goal_distance := 10000.0
var grounded := false
var _heuristic := "player"
var move_action := 0.0
var turn_action := 0.0
var jump_action := false
var n_steps = 0

var reward = 0.0

func _ready():
	return
	#reset()

func _physics_process(_delta):
	
	n_steps +=1    
	if n_steps >= MAX_STEPS:
		done = true
		needs_reset = true

	if needs_reset:
		needs_reset = false
		reset()
		return
	
	move_vec *= 0
	move_vec = get_move_vec()
	#move_vec = move_vec.normalized()
	
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	set_velocity(move_vec)
	set_up_direction(Vector3(0, 1, 0))
	move_and_slide()
	
	# turning
	
	var turn_vec = get_turn_vec()
	rotation_degrees.y += turn_vec*TURN_SENS
 
	grounded = is_on_floor()

	y_velo -= GRAVITY
	var just_jumped = false

	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
	
	if y_velo < 0 and !grounded :
		robot.set_animation("falling-cycle")
	
	var horizontal_speed = Vector2(move_vec.x, move_vec.z)
	if horizontal_speed.length() < 0.1 and grounded:
		robot.set_animation("idle")
	elif horizontal_speed.length() >=1.0 and grounded:
		robot.set_animation("walk-cycle")    
#    elif horizontal_speed.length() >= 1.0 and grounded:
#        robot.set_animation("run-cycle")
	
	update_reward()
	
	if Input.is_action_just_pressed("r_key"):
		reset()
		

func get_move_vec() -> Vector3:
	if done:
		move_vec = Vector3.ZERO
		return move_vec
	
	if _heuristic == "model":
		return Vector3(
		0,
		0,
		clamp(move_action, -1.0, 0.5)
	)
		
	var move_vec := Vector3(
		0,
		0,
		clamp(Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards"),-1.0, 0.5)
		
	)
	return move_vec

func get_turn_vec() -> float:
	if _heuristic == "model":
		return turn_action
	var rotation_amount = Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	return rotation_amount

  
func reset():
	needs_reset = false
	next = 1
	n_steps = 0
	#done = false
	just_reached_negative = false
	just_reached_positive = false
	jump_action = false
	# Replace with function body.
	set_position(Vector3(0,1.5,0))
	rotation_degrees.y = randf_range(-180,180)
	y_velo = 0.1
	
func set_action(action):
	move_action = action["move"][0]
	turn_action = action["turn"][0]
	
func reset_if_done():
	if done:
		reset()

func get_obs():
	#print(virtual_camera.get_camera_pixel_encoding())
	return {
		"camera_2d": virtual_camera.get_camera_pixel_encoding(),
	}
	
func get_obs_space():
	# typs of obs space: box, discrete, repeated
	return {
		"camera_2d":{
			"size": virtual_camera.get_camera_shape(),
			"space":"box"
		},
	}
	
	
func update_reward():
	reward -= 0.01 # step penalty
	reward += shaping_reward()
	
	
	
func get_reward():
	return reward
	
func zero_reward():
	reward = 0.0
	
func shaping_reward():
	var s_reward = 0.0
	return s_reward   
 

func set_heuristic(heuristic):
	self._heuristic = heuristic

func get_obs_size():
	return len(get_obs())
   
func get_action_space():
	return {
		"move" : {
			"size": 1,
			"action_type": "continuous"
		},        
		"turn" : {
			"size": 1,
			"action_type": "continuous"
		}
	}

func get_done():
	return done
	
func set_done_false():
	done = false


func calculate_translation(other_pad_translation : Vector3) -> Vector3:
	var new_translation := Vector3.ZERO
	var distance = randf_range(12,16)
	var angle = randf_range(-180,180)
	new_translation.z = other_pad_translation.z + sin(deg_to_rad(angle))*distance 
	new_translation.x = other_pad_translation.x + cos(deg_to_rad(angle))*distance
	
	return new_translation



func _on_NegativeGoal_body_entered(body: Node) -> void:
	reward -= 1.0
	done = true
	reset()


func _on_PositiveGoal_body_entered(body: Node) -> void:
	reward += 1.0
	done = true
	reset()
