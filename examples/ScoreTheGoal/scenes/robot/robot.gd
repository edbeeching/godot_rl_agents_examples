extends RigidBody3D
class_name Robot

@export var ball: Ball
@export var goals: Array[Goal]
@export var category_count: int

@onready var ai_controller: AIController3D = $AIController3D
@onready var animation_player: AnimationPlayer = $robot/AnimationPlayer

var acceleration: float = 700
var torque_multiplier: float = 60
var requested_acceleration: float
var requested_steering: float
var initial_transform: Transform3D
var ball_hit: bool


func _ready():
	initial_transform = transform
	ai_controller.init(self)
	reset_goals()
	reset_ball(true)


func get_ball() -> Ball:
	return ball


func reset():
	transform = initial_transform
	ball_hit = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	reset_ball(true)


func reset_goals():
	var starting_category: int = randi() % category_count
	var i: int = 0
	for goal in goals:
		goal.set_category(i, category_count)
		i += 1


func reset_ball(randomize_category: bool = false):
	# Set a slightly randomized ball position
	var ball_position := Vector3(randf_range(-0.2, 0.2), 0.3, randf_range(-1.8, -2.2))
	# Randomize the ball category
	if randomize_category:
		ball.set_random_category(category_count)
	ball.position = ball_position
	ball.rotation = Vector3.ZERO
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO

	# Set the correct goal reference
	for goal in goals:
		if goal.get_category() == ball.category:
			ball.correct_goal = goal


func _physics_process(_delta):
	reset_if_needed()

	if ai_controller.heuristic == "human":
		requested_acceleration = (
			Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
		)
		requested_steering = (
			Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")
		)

	var force: Vector3 = requested_acceleration * acceleration * -global_transform.basis.z
	var torque: Vector3 = requested_steering * torque_multiplier * Vector3.UP

	if requested_acceleration < 0:
		# Slows down movement in reverse
		requested_acceleration /= 2.0

	# Only applies movement if the ball hasn't been hit already
	if not ball_hit:
		apply_central_force(force)
		apply_torque(torque)

	handle_animation(linear_velocity)


func handle_animation(velocity: Vector3):
	if velocity.length() > 0.05:
		animation_player.play("walking", -1, 1.75)
	else:
		animation_player.play("idle")


func reset_if_needed():
	if ai_controller.needs_reset:
		reset()
		ai_controller.reset()


func _on_ball_entered_goal(ball_goal_category_match: bool):
	if ball_goal_category_match:
		game_over(1)
	else:
		game_over(-1)


func _on_ball_body_entered(body):
	if body is Robot:
		ball_hit = true
		ai_controller.reward += (ball.linear_velocity.normalized().dot(
			ball.global_position.direction_to(ball.correct_goal.global_position)
		))
	elif body is Wall or body is Goal:
		game_over(-1)


func game_over(reward: float = 0):
	ai_controller.reward += reward
	ai_controller.needs_reset = true
	ai_controller.done = true


func _on_body_entered(body: Node) -> void:
	if body is Wall:
		game_over(-1)


func _on_robot_entered_goal() -> void:
	game_over(-1)
