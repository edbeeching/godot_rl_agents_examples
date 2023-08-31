extends CharacterBody3D
class_name Player

signal reset_signal

const SPEED := 30.0
const JUMP_VELOCITY := 4.5
const TURN_SENS := 2.0

@onready var ai_controller_3d = $AIController3D
@onready var health_bar = $HealthBar

var score := 0
var health := 3:
	set(value):
		health = value
		health_bar.update_health(health)
		if health == 0:
			game_over()


func _ready():
	ai_controller_3d.init(self)

func game_over():
	ai_controller_3d.done = true
	ai_controller_3d.needs_reset = true

func _physics_process(delta):
	if ai_controller_3d.needs_reset:
		reset()
		ai_controller_3d.reset()
		return
		
	var fb : float
	var turn : float
	
	if ai_controller_3d.heuristic == "human":
		fb = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		turn = Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")
	else:
		fb = ai_controller_3d.fb_action
		turn = ai_controller_3d.turn_action
	
	fb = clamp(fb, -1.0, 0.5) # limit reverse speed
	#prints(ai_controller_3d.reward, ai_controller_3d.done, fb)
	rotation.y += deg_to_rad(turn*TURN_SENS)
	var direction = (transform.basis * Vector3(0.0, 0, fb)) # .normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	var collided = move_and_slide()
	if collided:
		obstacle_hit() 

func reset():
	position = Vector3.ZERO
	health = 3
	score = 0
	reset_signal.emit()
	
func chest_collected():
	#print("chest collected")
	score += 1
	ai_controller_3d.reward += 1.0

func mine_hit():
	#print("mine hit")
	score -= 1	
	health -= 1
	ai_controller_3d.reward -= 1.0
	
func obstacle_hit():
	#print("obstacle hit")
	pass
	#ai_controller_3d.reward -= 0.01

func _on_game_area_body_exited(body):
	#print("left game area")
	game_over()
