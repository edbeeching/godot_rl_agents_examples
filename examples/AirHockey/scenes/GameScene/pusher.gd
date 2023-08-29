extends RigidBody3D
class_name Pusher

@export var acceleration := 1000
var requested_movement: Vector3

@onready var _AIController3D: AIController3D = $AIController3D
@export var puck: Puck
@export var goal: Area3D
@export var other_player: Pusher

var _initial_position: Vector3

func _ready():
	_AIController3D.init(self)
	_initial_position = position

func reset():
	position = _initial_position
	
func _physics_process(_delta):
	if _AIController3D.needs_reset:
		_AIController3D.reset()
		reset()
	
	var movement: Vector3
	
	if _AIController3D.heuristic != "human":
		movement = requested_movement
	else:
		if Input.is_action_pressed("forward"):
			movement.z -= 1
		if Input.is_action_pressed("backward"):
			movement.z += 1
					
		if Input.is_action_pressed("left"):
			movement.x -= 1
		if Input.is_action_pressed("right"):
			movement.x += 1
	
	if movement:
		apply_central_force(
			global_transform.basis *
			movement.limit_length(1) *
			acceleration
			)
		
	# Small penalty for standing still
	if linear_velocity.length() < 0.1:
		_AIController3D.reward -= 0.00075


func _on_body_entered(body: PhysicsBody3D):
	if body == puck:
		# Reward for hitting the puck based on velocity
		_AIController3D.reward += 0.085 * linear_velocity.length()


func _on_goal_body_entered(_body):
	_AIController3D.reward += 10
	_AIController3D.done = true
	_AIController3D.needs_reset = true
	
	other_player._AIController3D.reward -= 1
	other_player._AIController3D.done = true
	other_player._AIController3D.needs_reset = true
