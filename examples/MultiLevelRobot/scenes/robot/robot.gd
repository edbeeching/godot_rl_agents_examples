extends CharacterBody3D
class_name Robot

@export var level_manager: LevelManager
@export var wheels: Array[Node3D]

@export var acceleration: float = 25.0
@export var rotation_speed: float = 15.0
@export var friction: float = 15.0
@export var max_horizontal_speed: float = 10.0

@export var gravity := Vector3.DOWN * 16.0

@onready var robot_visual: Node3D = $"robot"
@onready var ai_controller: RobotAIController = $AIController3D

var current_level: int
var next_level

var requested_movement: Vector3
var max_level_reached: int = 0
var current_goal_transform: Transform3D
var previous_distance_to_goal: float

var conveyor_belt_areas_entered: int
var conveyor_belt_direction: int
var conveyor_belt_speed: float = 15.0


func _ready():
	reset()


func reset():
	velocity = Vector3.ZERO
	global_position = level_manager.get_spawn_position(current_level)
	current_goal_transform = level_manager.randomize_goal(current_level)
	previous_distance_to_goal = global_position.distance_to(current_goal_transform.origin)


func _physics_process(delta):
	reset_on_needs_reset()
	handle_movement(delta)


func reset_on_needs_reset():
	if ai_controller.needs_reset:
		level_manager.reset_coins(current_level)
		if next_level == null:
			if randi_range(1, 6) == 1:
				current_level = randi_range(0, current_level)
		else:
			current_level = next_level
			next_level = null
		level_manager.reset_coins(current_level)
		reset()
		ai_controller.reset()


func handle_movement(delta):
	var movement := Vector3()

	if ai_controller.heuristic == "human":
		if Input.is_action_pressed("ui_up"):
			movement.x = -1
		if Input.is_action_pressed("ui_down"):
			movement.x = 1
		if Input.is_action_pressed("ui_left"):
			movement.z = 1
		if Input.is_action_pressed("ui_right"):
			movement.z = -1
		movement = movement.normalized()
	else:
		movement = requested_movement

	apply_acceleration(movement, delta)
	apply_gravity(delta)
	apply_friction(delta)
	apply_conveyor_belt_velocity(delta)
	limit_horizontal_speed()

	move_and_slide()

	rotate_toward_movement(delta)
	update_wheels_and_visual_rotation(delta)

func apply_conveyor_belt_velocity(delta):
	if conveyor_belt_areas_entered > 0:
		velocity += Vector3.LEFT * conveyor_belt_direction * conveyor_belt_speed * delta


func limit_horizontal_speed():
	var horizontal_velocity := Vector2(velocity.x, velocity.z).limit_length(max_horizontal_speed)
	velocity = Vector3(horizontal_velocity.x, velocity.y, horizontal_velocity.y)


func apply_acceleration(direction, delta):
	velocity += direction * acceleration * delta


func apply_friction(delta):
	velocity = velocity.move_toward(Vector3(0, velocity.y, 0), friction * delta)


func apply_gravity(delta):
	velocity += gravity * delta


func rotate_toward_movement(delta):
	var movement = Vector3(velocity.x, 0, velocity.z).normalized()
	var look_at_target: Vector3 = global_position + movement

	if look_at_target.distance_to(global_position) > 0:
		robot_visual.global_transform = (
			robot_visual
			. global_transform
			. interpolate_with(global_transform.looking_at(look_at_target), rotation_speed * delta)
			. orthonormalized()
		)


func update_wheels_and_visual_rotation(delta):
	var movement := Vector2(velocity.x, velocity.z).length()
	for wheel in wheels:
		wheel.rotate_object_local(Vector3.LEFT, movement * delta)
	robot_visual.rotation.x = -0.01 * movement


func _on_area_3d_area_entered(area):
	if area.get_collision_layer_value(1):
		#print("Level goal reached")
		if not level_manager.check_all_coins_collected(current_level):
			return
		if current_level > max_level_reached:
			max_level_reached = current_level
			print("max level passed: ", max_level_reached)
		next_level = (current_level + 1) % level_manager.levels.	size()
		end_episode(1.0)
	if area.get_collision_layer_value(2):
		#print("Coin picked up")
		level_manager.deactivate_coin(area, current_level)
		ai_controller.reward += 1
	if area.get_collision_layer_value(3):
		#print("On conveyor belt")
		conveyor_belt_direction = 1 if randi_range(0, 1) == 0 else -1
		conveyor_belt_areas_entered += 1
		pass
	if area.get_collision_layer_value(4):
		#print("Enemy collision")
		end_episode(-1.0)


func _on_area_3d_body_entered(body):
	if body.get_collision_layer_value(10):
		#print("Robot fell down")
		end_episode(-1.0)


func end_episode(reward: float):
	ai_controller.reward += reward
	ai_controller.done = true
	ai_controller.needs_reset = true


func _on_area_3d_area_exited(area):
	if area.get_collision_layer_value(3):
		conveyor_belt_areas_entered -= 1
