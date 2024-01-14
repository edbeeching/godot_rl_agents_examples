extends RigidBody3D
class_name Robot

@export var other_player: Robot
@export var goal: Area3D

@export var wheels: Array[Node3D]

@export var acceleration: float = 100.0
@export var rotation_speed: float = 15.0
@export var jump_force: float = 290

@export var gravity := Vector3.DOWN * 60.0

@onready var robot_visual: Node3D = $robot
@onready var jump_sensor: RayCast3D = $JumpSensor
@onready var ai_controller: RobotAIController = $AIController3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var initial_position = global_position

var game_manager: GameManager
var ball: Ball

var requested_movement: float
var jump_requested: bool
var velocity: Vector3
var last_movement_direction: float = 1

## If set, the score from this Robot will be displayed in the label
var score_label: Label
var score : int:
	set(value):
		score = value
		if score_label:
			score_label.text = str(value)


func _ready():
	score = 0
	reset()


func reset():
	linear_velocity = Vector3.ZERO
	global_position = initial_position


func _physics_process(delta):
	reset_on_needs_reset()
	handle_movement(delta)


func reset_on_needs_reset():
	if ai_controller.needs_reset:
		reset()
		ai_controller.reset()
	pass


func handle_movement(delta):
	var movement := Vector3()

	if ai_controller.heuristic == "human":
		if Input.is_action_pressed("move_left"):
			movement.x = -1
		if Input.is_action_pressed("move_right"):
			movement.x = 1
		if Input.is_action_pressed("jump"):
			if jump_sensor.is_colliding():
				apply_force(Vector3.UP * jump_force)
	else:
		movement = global_basis.z * requested_movement
		if jump_sensor.is_colliding() and jump_requested:
			apply_force(Vector3.UP * jump_force)

	if movement:
		last_movement_direction = sign(movement.x)
		apply_acceleration(movement.normalized())

	update_particle_effects()
	update_wheels_and_visual_rotation(delta)
	rotate_toward_movement(delta)
	apply_gravity()


func apply_acceleration(direction):
	apply_force(direction * acceleration)


func apply_gravity():
	apply_force(gravity)


func rotate_toward_movement(delta):
	if abs(last_movement_direction) > 0.005:
		robot_visual.global_transform = (
			robot_visual
			. global_transform
			. interpolate_with(
				robot_visual.global_transform.looking_at(
					(
						robot_visual.global_transform.origin
						+ Vector3(last_movement_direction, 0, +0.01)
					)
				),
				rotation_speed * delta
			)
			. orthonormalized()
		)


func update_wheels_and_visual_rotation(delta):
	var abs_movement = abs(linear_velocity.x)

	for wheel in wheels:
		wheel.rotate_object_local(Vector3.LEFT, abs_movement * 1.3 * delta)
	robot_visual.rotation.x = -0.01 * abs_movement


func update_particle_effects():
	if linear_velocity.x > 0.25 and jump_sensor.is_colliding():
		particles.emitting = true
	else:
		particles.emitting = false


func end_episode(reward: float):
	ai_controller.reward += reward
	ai_controller.done = true
	ai_controller.needs_reset = true
	pass
