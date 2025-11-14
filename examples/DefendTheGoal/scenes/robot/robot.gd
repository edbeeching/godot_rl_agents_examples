extends RigidBody3D
class_name Robot

@export var sensors: Array[Node]
@export var turret: Turret
@onready var ai_controller: AIController3D = $AIController3D
@onready var animation_player: AnimationPlayer = $robot/AnimationPlayer
@onready var ground_sensor: RayCast3D = $GroundSensor

var acceleration: float = 1500
var jump_strength: float = 40
var requested_movement_sideways: float
var requested_jump: bool
var initial_transform: Transform3D

var _jump_timer := 1.0


func _ready():
	initial_transform = transform
	ai_controller.init(self)


func is_on_ground() -> bool:
	return ground_sensor.is_colliding()


func reposition_robot():
	transform = initial_transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


func _physics_process(delta):
	_jump_timer += delta
	var should_jump: bool = requested_jump

	if ai_controller.heuristic == "human":
		requested_movement_sideways = (
			Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
		)
		should_jump = Input.is_action_just_pressed("jump")


	var force_sideways: Vector3 = (
		requested_movement_sideways * acceleration * global_transform.basis.x
	)

	if should_jump and _jump_timer > 1.0:
		set_axis_velocity(Vector3.UP * jump_strength)
		$robot.rotation.x = requested_movement_sideways * 0.2
		_jump_timer = 0


	# Only applies movement if the ball hasn't been hit already
	if is_on_ground():
		apply_central_force(force_sideways)
		if abs(linear_velocity.y) < 0.1:
			$robot.rotation.x = 0

	handle_animation(linear_velocity)


func handle_animation(velocity: Vector3):
	if velocity.length() > 0.05:
		animation_player.play("walking")
	else:
		animation_player.play("idle")


func _on_ball_entered_goal():
	ai_controller.reward -= 1


func _on_ball_body_entered(_body):
	# Uncomment if you want to add a reward for hitting the ball
	#if _body is Robot:
	#ai_controller.reward += 1.0
	return


func _on_body_entered(body: Node) -> void:
	if body is RobotBoundaries:
		ai_controller.reward -= 1.0
		reposition_robot()
