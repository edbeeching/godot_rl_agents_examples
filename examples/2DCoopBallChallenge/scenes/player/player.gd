extends CharacterBody2D
class_name Player

@export var speed := 2400.0
@export var jump_velocity := -1400.0
@export var ai_controller: PlayerAIController

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var initial_transform := transform

var requested_movement: float
var requested_jump: bool

var last_to_hit_ball: bool

func hit_ball():
	last_to_hit_ball = true
	$CanHitBallIndicator.visible = false


func clear_hit_ball():
	last_to_hit_ball = false
	$CanHitBallIndicator.visible = true


func _physics_process(delta: float) -> void:
	handle_movement(delta)


func handle_movement(delta: float):
	apply_gravity(delta)
	
	# Controls (human or AI controlled)
	var direction: float
	if ai_controller.control_mode == AIController2D.ControlModes.HUMAN:
		direction = Input.get_axis("move_left", "move_right")
		requested_jump = Input.is_action_pressed("jump")
	else:
		direction = requested_movement

	# Horizontal movement
	velocity.x = direction * speed
	if velocity.x:
		animated_sprite.flip_h = velocity.x < 0
		if is_on_floor():
			animated_sprite.animation = "move"
			animated_sprite.play()

	# Jump
	if requested_jump and is_on_floor():
		velocity.y = jump_velocity
		requested_jump = false
		animated_sprite.animation = "jump"
		animated_sprite.play()

	# Stop animation if not moving
	if velocity.length_squared() < 0.01 and is_on_floor():
		animated_sprite.animation = "move"
		animated_sprite.stop()

	move_and_slide()


func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += Vector2.DOWN * 14000 * delta


func reset() -> void:
	transform = initial_transform

	var state := PhysicsServer2D.body_get_direct_state(get_rid())
	state.transform = global_transform
	velocity = Vector2.ZERO
	requested_movement = 0
	requested_jump = 0
	clear_hit_ball()
