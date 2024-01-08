extends CharacterBody3D
class_name Player
const MOVE_SPEED = 12
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
const TURN_SENS = 2.0

@onready var cam = $Camera
var move_vec = Vector3()
var y_velo = 0

# RL related variables
@onready var ai_controller := $AIController3D
@onready var robot = $Robot
@onready var virtual_camera = $RGBCameraSensor3D

var next = 1
var just_reached_negative = false
var just_reached_positive = false
var just_fell_off = false
var best_goal_distance := 10000.0
var grounded := false
var move_action := 0.0
var turn_action := 0.0
var jump_action := false


func _ready():
	ai_controller.init(self)


func _physics_process(_delta):
	move_vec = get_move_vec()
	#move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	velocity = move_vec
	move_and_slide()

	# turning

	var turn_vec = get_turn_vec()
	rotation_degrees.y += turn_vec * TURN_SENS

	grounded = is_on_floor()

	y_velo -= GRAVITY

	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED

	if y_velo < 0 and !grounded:
		robot.set_animation("falling-cycle")

	var horizontal_speed = Vector2(move_vec.x, move_vec.z)
	if horizontal_speed.length() < 0.1 and grounded:
		robot.set_animation("idle")
	elif horizontal_speed.length() >= 1.0 and grounded:
		robot.set_animation("walk-cycle")
#    elif horizontal_speed.length() >= 1.0 and grounded:
#        robot.set_animation("run-cycle")

	update_reward()

	if Input.is_action_just_pressed("r_key"):
		reset()


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


func reset():
	next = 1
	just_reached_negative = false
	just_reached_positive = false
	jump_action = false
	set_position(Vector3(0, 1.5, 0))
	rotation_degrees.y = randf_range(-180, 180)
	y_velo = 0.1
	ai_controller.reset()


func update_reward():
	ai_controller.reward -= 0.01  # step penalty


func calculate_translation(other_pad_translation: Vector3) -> Vector3:
	var new_translation := Vector3.ZERO
	var distance = randf_range(12, 16)
	var angle = randf_range(-180, 180)
	new_translation.z = other_pad_translation.z + sin(deg_to_rad(angle)) * distance
	new_translation.x = other_pad_translation.x + cos(deg_to_rad(angle)) * distance

	return new_translation


func _on_NegativeGoal_body_entered(_body: Node) -> void:
	ai_controller.reward -= 1.0
	ai_controller.done = true
	reset()


func _on_PositiveGoal_body_entered(_body: Node) -> void:
	ai_controller.reward += 1.0
	ai_controller.done = true
	reset()
