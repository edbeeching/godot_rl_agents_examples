extends CharacterBody3D

# Maximum airspeed
var max_flight_speed = 30
# Turn rate
@export var turn_speed = 5.0
@export var level_speed = 12.0
@export var turn_acc = 4.0
# Climb/dive rate
var pitch_speed = 2.0
# Wings "autolevel" speed
# Throttle change speed
var throttle_delta = 30
# Acceleration/deceleration
var acceleration = 6.0
# Current speed
var forward_speed = 0
# Throttle input speed
var target_speed = 0

#var velocity = Vector3.ZERO
var found_goal = false
var exited_arena = false
var cur_goal = null
@onready var environment = get_parent()
@onready var ai_controller = $AIController3D
# ------- #
var turn_input = 0
var pitch_input = 0
var best_goal_distance := 10000.0
var transform_backup = null


func _ready():
	ai_controller.init(self)
	transform_backup = transform


func game_over():
	cur_goal = environment.get_next_goal(null)
	transform_backup = transform_backup
	position.x = 0 + randf_range(-2, 2)
	position.y = 27 + randf_range(-2, 2)
	position.z = 0 + randf_range(-2, 2)
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	found_goal = false
	exited_arena = false
	best_goal_distance = to_local(cur_goal.position).length()
	ai_controller.reset()


func update_reward():
	ai_controller.reward -= 0.01  # step penalty
	ai_controller.reward += shaping_reward()


func shaping_reward():
	var s_reward = 0.0
	var goal_distance = to_local(cur_goal.position).length()
	if goal_distance < best_goal_distance:
		s_reward += best_goal_distance - goal_distance
		best_goal_distance = goal_distance

	s_reward /= 1.0
	return s_reward


func set_heuristic(heuristic):
	self._heuristic = heuristic


func _physics_process(delta):
	if ai_controller.needs_reset:
		game_over()
		return

	if cur_goal == null:
		game_over()
	set_input()
	if Input.is_action_just_pressed("r_key"):
		game_over()
	# Rotate the transform based checked the input values
	transform.basis = transform.basis.rotated(
		transform.basis.x.normalized(), pitch_input * pitch_speed * delta
	)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	$PlaneModel.rotation.z = lerp($PlaneModel.rotation.z, -float(turn_input), level_speed * delta)
	$PlaneModel.rotation.x = lerp($PlaneModel.rotation.x, -float(pitch_input), level_speed * delta)

	# Movement is always forward
	velocity = -transform.basis.z.normalized() * max_flight_speed
	# Handle landing/taking unchecked
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	update_reward()


func set_input():
	if ai_controller.heuristic == "model":
		return
	else:
		turn_input = (
			Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")
		)
		pitch_input = (
			Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
		)


func goal_reached(goal):
	if goal == cur_goal:
		ai_controller.reward += 100.0
		cur_goal = environment.get_next_goal(cur_goal)


func exited_game_area():
	ai_controller.done = true
	ai_controller.reward -= 10.0
	exited_arena = true
	game_over()
