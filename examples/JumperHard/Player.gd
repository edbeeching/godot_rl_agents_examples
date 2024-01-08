extends CharacterBody3D

const MOVE_SPEED = 12
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
const TURN_SENS = 2.0

@onready var cam = $Camera3D
var move_vec = Vector3()
var y_velo = 0
var needs_reset = false
# RL related variables
@onready var end_position = $"../EndPosition"
@onready var raycast_sensor = $"RayCastSensor3D"
@onready var first_jump_pad = $"../Pads/FirstPad"
@onready var second_jump_pad = $"../Pads/SecondPad"
@onready var robot = $Robot
@onready var ai_controller = $AIController3D

var next = 1
var just_reached_end = false
var just_reached_next = false
var just_fell_off = false
var best_goal_distance := 10000.0
var grounded := false
var move_action := 0.0
var turn_action := 0.0
var jump_action := false


func _ready():
	ai_controller.init(self)
	raycast_sensor.activate()
	game_over()


func _physics_process(_delta):
	move_vec = get_move_vec()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	set_velocity(move_vec)
	set_up_direction(Vector3(0, 1, 0))
	move_and_slide()

	# turning

	var turn_vec = get_turn_vec()
	rotation.y += deg_to_rad(turn_vec * TURN_SENS)

	grounded = is_on_floor()

	y_velo -= GRAVITY
	if grounded and get_jump_action():
		robot.set_animation("jump")
		y_velo = JUMP_FORCE
		grounded = false
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED

	if y_velo < 0 and !grounded:
		robot.set_animation("falling")

	var horizontal_speed = Vector2(move_vec.x, move_vec.z)
	if horizontal_speed.length() < 0.1 and grounded:
		robot.set_animation("idle")
	elif horizontal_speed.length() < 1.0 and grounded:
		robot.set_animation("walk")
	elif horizontal_speed.length() >= 1.0 and grounded:
		robot.set_animation("run")

	update_reward()

	if Input.is_action_just_pressed("r_key"):
		game_over()


func get_move_vec() -> Vector3:
	if ai_controller.done:
		return Vector3.ZERO

	if ai_controller.heuristic == "model":
		return Vector3(0, 0, clamp(move_action, -1.0, 0.5))

	return Vector3(
		0,
		0,
		clamp(
			(
				Input.get_action_strength("move_backwards")
				- Input.get_action_strength("move_forwards")
			),
			-1.0,
			0.5
		)
	)


func get_turn_vec() -> float:
	if ai_controller.heuristic == "model":
		return turn_action
	var rotation_amount = (
		Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")
	)

	return rotation_amount


func get_jump_action() -> bool:
	if ai_controller.done:
		jump_action = false
		return jump_action

	if ai_controller.heuristic == "model":
		return jump_action

	return Input.is_action_just_pressed("jump")


func game_over():
	next = 1
	first_jump_pad.position = Vector3.ZERO
	second_jump_pad.position = Vector3(0, 0, -12)
	just_reached_end = false
	just_fell_off = false
	jump_action = false

	set_position(Vector3(0, 5, 0))
	rotation.y = deg_to_rad(randf_range(-180, 180))
	y_velo = 0.1
	reset_best_goal_distance()
	ai_controller.reset()


func update_reward():
	ai_controller.reward -= 0.01  # step penalty
	ai_controller.reward += shaping_reward()


func shaping_reward():
	var s_reward = 0.0
	var goal_distance = 0
	if next == 0:
		goal_distance = position.distance_to(first_jump_pad.position)
	if next == 1:
		goal_distance = position.distance_to(second_jump_pad.position)
	#print(goal_distance)
	if goal_distance < best_goal_distance:
		s_reward += best_goal_distance - goal_distance
		best_goal_distance = goal_distance

	s_reward /= 1.0
	return s_reward


func reset_best_goal_distance():
	if next == 0:
		best_goal_distance = position.distance_to(first_jump_pad.position)
	if next == 1:
		best_goal_distance = position.distance_to(second_jump_pad.position)


func calculate_translation(other_pad_translation: Vector3) -> Vector3:
	var new_translation := Vector3.ZERO
	var distance = randf_range(12, 16)
	var angle = randf_range(-180, 180)
	new_translation.z = other_pad_translation.z + sin(deg_to_rad(angle)) * distance
	new_translation.x = other_pad_translation.x + cos(deg_to_rad(angle)) * distance

	return new_translation


func _on_First_Pad_Trigger_body_entered(_body):
	if next != 0:
		return
	ai_controller.reward += 100.0
	next = 1
	reset_best_goal_distance()
	second_jump_pad.position = calculate_translation(first_jump_pad.position)


func _on_Second_Trigger_body_entered(_body):
	if next != 1:
		return
	ai_controller.reward += 100.0
	next = 0
	reset_best_goal_distance()
	first_jump_pad.position = calculate_translation(second_jump_pad.position)


func _on_ResetTriggerBox_body_entered(_body):
	ai_controller.done = true
	game_over()
