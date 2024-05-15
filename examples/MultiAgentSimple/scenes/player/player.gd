extends CharacterBody3D
class_name Player

@export var speed = 3.0
@export var gravity_strength = 10.0
@export var visual_rotation_update_speed = 8.0
@export var wheels: Array[Node3D]

var requested_movement: Vector2
var requested_jump: bool

@onready var robot_visual = $robot

## Value set by AIController
var game_manager: GameSceneManager
var last_movement_direction: Vector3


func _physics_process(delta: float) -> void:
	if global_position.y < -5:
		game_manager.reset_game(-5, false)

	if not is_on_floor():
		velocity += Vector3.DOWN * gravity_strength * delta

	velocity.x = requested_movement.x * speed
	velocity.z = requested_movement.y * speed

	if velocity:
		last_movement_direction = Vector3(requested_movement.x, 0, requested_movement.y)

	_update_visual_rotation(delta)
	_update_wheels_rotation(delta)
	move_and_slide()


func _update_visual_rotation(delta):
	var direction: Vector3 = last_movement_direction

	if direction:
		var target_basis := Basis.looking_at(direction)
		robot_visual.global_basis = robot_visual.global_basis.orthonormalized().slerp(
			target_basis, delta * visual_rotation_update_speed
		)


func _update_wheels_rotation(delta):
	var movement := Vector2(requested_movement.x, requested_movement.y).length()
	for wheel in wheels:
		wheel.rotate_object_local(Vector3.LEFT, movement * speed * delta * 2.0)
