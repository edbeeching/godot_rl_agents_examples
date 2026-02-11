extends AIController2D
class_name CarAIController

@export var raycast_sensors: Array[Node2D]
@export var terrain_manager: TerrainManager
@export var goal_area: GoalArea

## Minimum car spawn offset (from the left side of the terrain)
@export var car_spawn_min_x_offset = 5500
## Goal offset (from the right side of the terrain)
@export var goal_x_offset = 2500

@onready var car: Car = $Car

var is_success: bool = false
var previous_distance_to_goal


func _ready():
	super._ready()
	car.terrain_manager = terrain_manager
	heuristic_init()


func get_info() -> Dictionary:
	return {"is_success": is_success}


func get_obs() -> Dictionary:
	var observations: Array

	var terrain_length: float = terrain_manager.get_terrain_length()
	var velocity_scale_factor: float = 0.000116667

	var car_base: RigidBody2D = car.base
	var goal_position: Vector2 = car_base.to_local(goal_area.global_position) / terrain_length
	var relative_velocity: Vector2 = (
		car_base.global_transform.basis_xform_inv(car_base.linear_velocity) * velocity_scale_factor
	)

	var angular_velocity := clampf(car_base.angular_velocity / 2.0, 0, 1.0)

	var car_orientation := car.base.global_transform.x
	(
		observations
		. append_array(
			[
				car_orientation.x,
				car_orientation.y,
				clampf(goal_position.x, -1.0, 1.0),
				clampf(goal_position.y, -1.0, 1.0),
				clampf(relative_velocity.x, -1.0, 1.0),
				clampf(relative_velocity.y, -1.0, 1.0),
				angular_velocity,
			]
		)
	)

	for sensor in raycast_sensors:
		observations.append_array(sensor.get_observation())

	return {"obs": observations}


func get_reward() -> float:
	var distance_to_goal = abs(goal_area.global_position.x - car.base.global_position.x)
	if not previous_distance_to_goal:
		previous_distance_to_goal = distance_to_goal
#
	if distance_to_goal < previous_distance_to_goal:
		reward += ((previous_distance_to_goal - distance_to_goal) / 225_000.0)
		previous_distance_to_goal = distance_to_goal
	return reward


func get_action_space() -> Dictionary:
	return {
		"wheel_torque": {"size": 1, "action_type": "continuous"},
	}


func _physics_process(_delta):
	n_steps += 1
	if n_steps > reset_after:
		game_over()

	if needs_reset:
		reset()

	heuristic_process()


func reset():
	super.reset()
	previous_distance_to_goal = null
	terrain_manager.generate_terrain()
	var new_car_pos = terrain_manager.get_terrain_position(
		car_spawn_min_x_offset + randf_range(0, 200), -600
	)
	goal_area.global_position = terrain_manager.get_goal_position(goal_x_offset, 0)
	car.reset(new_car_pos)


func set_action(action = null) -> void:
	if action:
		car.requested_torque = clampf(action.wheel_torque[0], -1.0, 1.0)


func heuristic_process() -> void:
	if heuristic == "human":
		car.requested_torque = (
			float(Input.is_action_pressed("move_right"))
			- float(Input.is_action_pressed("move_left"))
		)


func heuristic_init() -> void:
	if heuristic == "human":
		reset()


func _on_roof_collision_detector_body_entered(_body):
	game_over(-1)


func game_over(final_reward = 0, success := false):
	is_success = success
	reward += final_reward
	done = true
	reset()


func _on_goal_area_body_entered(body: Node2D) -> void:
	game_over(+1, true)
