extends VehicleBody3D
class_name Car

@export var playing_area_x_size: float = 20
@export var playing_area_z_size: float = 20

@export var acceleration: float = 200
@export var max_steer_angle: float = 20

@export var parking_manager: ParkingManager
@export var goal_marker: Node3D

@onready var max_velocity = acceleration / mass * 40
@onready var ai_controller: AIController3D = $AIController3D
@onready var raycast_sensor: RayCastSensor3D = $RayCastSensor3D

var goal_parking_spot: Transform3D

var requested_acceleration: float
var requested_steering: float
var _initial_transform: Transform3D
var times_restarted: int

var _smallest_distance_to_goal: float = 0
var _max_goal_dist: float = 1

var episode_ended_unsuccessfully_reward: float = -6

var _rear_lights: Array[MeshInstance3D]
@export var braking_material: StandardMaterial3D
@export var reversing_material: StandardMaterial3D

func get_normalized_velocity():
	return linear_velocity.normalized() * (linear_velocity.length() / max_velocity)
	
func _ready():
	ai_controller.init(self)
	_initial_transform = transform
	
	_rear_lights.resize(2)
	_rear_lights[0] = $"car_base/Rear-light" as MeshInstance3D
	_rear_lights[1] = $"car_base/Rear-light_001" as MeshInstance3D
	
	_max_goal_dist = (
		Vector2(
			playing_area_x_size,
			playing_area_z_size
		).length()
	)
		
func reset():
	times_restarted += 1
	
	transform = _initial_transform
	
	if randi_range(0, 1) == 0:
		transform.origin = -transform.origin
		transform.basis = transform.basis.rotated(Vector3.UP, PI)

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	transform.basis = transform.basis.rotated(Vector3.UP, randf_range(-0.3, 0.3))
	
	parking_manager.disable_random_cars()
	
	goal_parking_spot = parking_manager.get_random_free_parking_spot_transform()
	goal_marker.global_position = goal_parking_spot.origin + Vector3.UP * 3

	_smallest_distance_to_goal = _get_current_distance_to_goal()
	
func _physics_process(delta):
	_reset_if_needed()
	_update_reward()
	
	if (ai_controller.heuristic != "human"):
		engine_force = (requested_acceleration) * acceleration
		steering = move_toward(steering, deg_to_rad(requested_steering * max_steer_angle), delta)
	else:
		engine_force = (
			int(Input.is_action_pressed("move_forward")) -
			int(Input.is_action_pressed("move_backward"))
		) * acceleration
		steering = move_toward(
			steering,
			deg_to_rad((
				int(Input.is_action_pressed("steer_left")) -
				int(Input.is_action_pressed("steer_right"))
			) * max_steer_angle),
			delta
		)
		
	_update_rear_lights()
	_reset_on_out_of_bounds()
	_reset_on_turned_over()
	_reset_on_went_away_from_goal()
	_end_episode_on_goal_reached()

func _update_rear_lights():
	var velocity := get_normalized_velocity_in_player_reference().z
	
	set_rear_light_material(null)
	
	var brake_or_reverse_requested: bool
	if (ai_controller.heuristic != "human"):
		brake_or_reverse_requested = requested_acceleration < 0
	else:
		brake_or_reverse_requested = Input.is_action_pressed("move_backward")
	
	if velocity >= 0:
		if brake_or_reverse_requested:
			set_rear_light_material(braking_material)
	elif velocity <= -0.015:
		set_rear_light_material(reversing_material)

func set_rear_light_material(material: StandardMaterial3D):
	_rear_lights[0].set_surface_override_material(0, material)
	_rear_lights[1].set_surface_override_material(0, material)

func _reset_on_out_of_bounds():
	if (position.y < -2 or abs(position.x) > 10 or abs(position.z) > 10):
		_end_episode(episode_ended_unsuccessfully_reward)

# If the agent was near the goal but has since moved away,
# end the episode with a negative reward	
func _reset_on_went_away_from_goal():
	var goal_dist = _get_current_distance_to_goal()
	if _smallest_distance_to_goal < 1.5 and goal_dist > _smallest_distance_to_goal + 3.5:
		_end_episode(episode_ended_unsuccessfully_reward)

# If the goal condition is reached, provide a reward based on:
# how quickly the goal was reached,
# the current velocity,
# direction alignment, 
# and distance from the goal position
func _end_episode_on_goal_reached():
	var goal_dist = _get_current_distance_to_goal()
	if _is_goal_reached(goal_dist):
		var parked_succesfully_reward: float = (
			10
			- _get_direction_difference() * 4
			- (float(ai_controller.n_steps) / ai_controller.reset_after) * 2
			- get_normalized_velocity().length()
			- (goal_dist / _max_goal_dist)
		)
		_end_episode(parked_succesfully_reward)

func _reset_on_turned_over():
	if global_transform.basis.y.dot(Vector3.UP) < 0.6:
		_end_episode(episode_ended_unsuccessfully_reward)

func _end_episode(final_reward: float = 0):
	ai_controller.reward += final_reward
	ai_controller.needs_reset = true
	ai_controller.done = true

func _reset_if_needed():
	if ai_controller.needs_reset:
		reset()
		ai_controller.reset()
		
func _update_reward():
	if times_restarted == 0:
		return
	
	var goal_dist = _get_current_distance_to_goal()
	
#	# If the car is close to the goal parking spot,
	# we modify the reward based on the angle
	var direction_multiplier = 1
	if goal_dist < 1:
		direction_multiplier = (1 - _get_direction_difference()) * 1.5

	if goal_dist < _smallest_distance_to_goal:
		ai_controller.reward += (
			(_smallest_distance_to_goal - goal_dist) *
			direction_multiplier
		)
		_smallest_distance_to_goal = goal_dist
		
	# Encourage shorter paths
	if goal_dist > 2:
		ai_controller.reward -= 10 * (get_normalized_velocity().length() / ai_controller.reset_after)
		
# Returns the difference between current direction and goal direction in range 0,1
# If 1, the angle is 180 degrees, if 0, the direction is perfectly aligned.
func _get_direction_difference() -> float:
	return (global_transform.basis.z.dot(-goal_parking_spot.basis.z) + 1) / 2

func _is_goal_reached(current_goal_dist: float) -> bool:
	return (
		current_goal_dist < 0.5 and
		linear_velocity.length() < 0.05 and
		_get_direction_difference() < 0.07
	)

func _get_current_distance_to_goal() -> float:
	# Exclude Y difference from the calculated distance 
	var goal_transform: Transform3D = goal_parking_spot
	goal_transform.origin.y = global_position.y
	return goal_transform.origin.distance_to(global_position)

func get_normalized_velocity_in_player_reference() -> Vector3:
	return (
		global_transform.basis.inverse() *
		get_normalized_velocity()
		)

func _on_green_space_body_entered(body):
	_end_episode(episode_ended_unsuccessfully_reward)

func _on_walls_body_entered(body):
	_end_episode(episode_ended_unsuccessfully_reward)

func _on_body_entered(body: PhysicsBody3D):
	if body is StaticCar:
		_end_episode(episode_ended_unsuccessfully_reward)
