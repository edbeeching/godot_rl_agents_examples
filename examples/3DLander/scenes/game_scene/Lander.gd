extends Node3D
class_name Lander

## Main class for the Lander, also handles setting rewards and restarting the episode.
@export var show_successful_landing_debug_text := false

@export var min_initial_velocity: float = 5.0
@export var max_initial_velocity: float = 10.0
@export var max_random_position_distance_from_center: float = 50.0

@export var up_thruster_max_force: float = 500.0
@export var navigation_thruster_max_force: float = 250.0

@onready var ai_controller: LanderAIController = $AIController3D

# In case of error: "Trying to assign value of type 'Node3D'...",
# try to double click on blender\lander.blend in Godot and click reimport.
# (if needed, repeat for landing-leg.blend too)
@onready var _lander: RigidBody3D = $Lander
var _landing_legs: Array[RigidBody3D]
var _landing_leg_initial_transforms: Dictionary

@export var terrain: Terrain
@export var raycast_sensor: RayCastSensor3D

@export var up_thruster: Thruster
@export var left_thruster: Thruster
@export var right_thruster: Thruster
@export var forward_thruster: Thruster
@export var back_thruster: Thruster
@export var turn_left_thruster: Thruster
@export var turn_right_thruster: Thruster

var thrusters: Array

var landing_position := Vector3(0.0, 0.0, 0.0)
var episode_ended_unsuccessfully_reward := -5.0

var times_restarted := 0
var _initial_transform: Transform3D

var _legs_in_contact_with_ground: int

var	_previous_goal_distance: float
var	_previous_angular_velocity: float
var	_previous_direction_difference: float
var	_previous_linear_velocity: float

var _thruster_reward_multiplier: float = 0.0325
var _shaped_reward_multiplier: float = 0.3

var _previous_thruster_usage: float

func _ready():
	ai_controller.init(self)

	_landing_legs.append_array([
		$LandingLeg,
		$LandingLeg2,
		$LandingLeg3,
		$LandingLeg4
	])

	for landing_leg in _landing_legs:
		_landing_leg_initial_transforms[landing_leg] = landing_leg.global_transform

	_initial_transform = _lander.global_transform

	thrusters.append_array([
		up_thruster,
		left_thruster,
		right_thruster,
		forward_thruster,
		back_thruster,
		turn_left_thruster,
		turn_right_thruster
	])

	reset()

func reset():
	terrain.maybe_generate_terrain()
	times_restarted += 1

	var random_velocity = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized() * randf_range(min_initial_velocity, max_initial_velocity)

	var random_position_offset = Vector3(
		randf_range(-1.0, 1.0),
		0,
		randf_range(-1.0, 1.0)
	).normalized() * randf_range(0.0, max_random_position_distance_from_center)

	_lander.global_transform = _initial_transform
	_lander.global_transform.origin += random_position_offset
	_lander.linear_velocity = random_velocity
	_lander.angular_velocity = Vector3.ZERO

	for landing_leg in _landing_legs:
		landing_leg.global_transform = _landing_leg_initial_transforms[landing_leg]
		landing_leg.global_transform.origin += random_position_offset
		landing_leg.linear_velocity = random_velocity
		landing_leg.angular_velocity = Vector3.ZERO

	for thruster in thrusters:
		thruster.thruster_strength = 0.0

	landing_position = terrain.landing_position

	_previous_linear_velocity = get_normalized_linear_velocity()
	_previous_goal_distance = _get_normalized_distance_to_goal()
	_previous_angular_velocity = get_normalized_angular_velocity()
	_previous_direction_difference = get_player_goal_direction_difference()
	
	_previous_thruster_usage = _get_normalized_current_total_thruster_strength()
	pass

func _physics_process(delta):
	_end_episode_on_goal_reached()
	_update_reward()

	if (ai_controller.heuristic == "human"):
		up_thruster.thruster_strength = (
			int(Input.is_action_pressed("up_thruster"))
		) * up_thruster_max_force

		left_thruster.thruster_strength = (
			int(Input.is_action_pressed("left_thruster"))
		) * navigation_thruster_max_force

		right_thruster.thruster_strength = (
			int(Input.is_action_pressed("right_thruster"))
		) * navigation_thruster_max_force

		forward_thruster.thruster_strength = (
			int(Input.is_action_pressed("forward_thruster"))
		) * navigation_thruster_max_force

		back_thruster.thruster_strength = (
			int(Input.is_action_pressed("back_thruster"))
		) * navigation_thruster_max_force

		turn_left_thruster.thruster_strength = (
			int(Input.is_action_pressed("turn_left_thruster"))
		) * navigation_thruster_max_force

		turn_right_thruster.thruster_strength = (
			int(Input.is_action_pressed("turn_right_thruster"))
		) * navigation_thruster_max_force

	for thruster in thrusters:
		_lander.apply_force(
			thruster.global_transform.basis.y * thruster.thruster_strength,
			thruster.global_position - _lander.global_position
		)

	_reset_if_needed()
	pass

func _end_episode_on_goal_reached():
	if _is_goal_reached():
		if show_successful_landing_debug_text:
			print("Successfully landed")

		# The reward for succesfully landing is reduced by
		# the distance from the goal position
		var successfully_landed_reward: float = (
			10.0
			- _get_normalized_distance_to_goal() * 6.0
		)
		_end_episode(successfully_landed_reward)

func _end_episode(final_reward: float = 0.0):
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

	# Positive reward if the parameters are approaching the goal values,
	# negative reward if they are moving away from the goal values	
	var vel_reward := (_previous_linear_velocity - get_normalized_linear_velocity())
	var thruster_usage_reward := (_previous_thruster_usage - _get_normalized_current_total_thruster_strength()) * 0.06
	var ang_vel_reward := (_previous_angular_velocity - get_normalized_angular_velocity())
		
	var dist_reward := 0.0
	var dir_reward := 0.0

	if _legs_in_contact_with_ground == 0:
		dist_reward = (_previous_goal_distance - _get_normalized_distance_to_goal()) * 6.0
		dir_reward = (_previous_direction_difference - get_player_goal_direction_difference()) * 0.25

	ai_controller.reward += (
		dist_reward +
		vel_reward +
		dir_reward +
		ang_vel_reward + 
		thruster_usage_reward
		) * 65.0 * _shaped_reward_multiplier

	_previous_linear_velocity = get_normalized_linear_velocity()
	_previous_goal_distance = _get_normalized_distance_to_goal()
	_previous_angular_velocity = get_normalized_angular_velocity()
	_previous_direction_difference = get_player_goal_direction_difference()
	
	_previous_thruster_usage = _get_normalized_current_total_thruster_strength()
	pass

# Returns the difference between current direction and goal direction in range 0,1
# If 1, the angle is 180 degrees, if 0, the direction is perfectly aligned.
func get_player_goal_direction_difference() -> float:
	return (1.0 + _lander.global_transform.basis.y.dot(-Vector3.UP)) / 2.0

func _is_goal_reached() -> bool:
	return (
		not ai_controller.done and
		_legs_in_contact_with_ground == 4 and
		_lander.linear_velocity.length() < 0.015 and
		_lander.angular_velocity.length() < 0.5 and
		_get_normalized_current_total_thruster_strength() < 0.01
	)

func _get_current_distance_to_goal() -> float:
	return _lander.global_position.distance_to(landing_position)

func _get_normalized_distance_to_goal() -> float:
	var playing_area_size = get_playing_area_size()
	return (
		_lander.global_position.distance_to(landing_position) /
		Vector3(
			playing_area_size.x / 2,
			playing_area_size.y,
			playing_area_size.x / 2,
		).length()
	)

func get_goal_position_in_player_reference() -> Vector3:

	var local_position: Vector3 = _lander.to_local(landing_position)
	var playing_area_size: Vector3 = get_playing_area_size()

	var local_size: Vector3 = (
		_lander.global_transform.basis.inverse() *
		Vector3(
			playing_area_size.x / 2.0,
			playing_area_size.y,
			playing_area_size.z / 2.0,
		)
	)
	return local_position / local_size

## Returns the normalized position of the center of the terrain in player's reference
func get_terrain_center_position_in_player_reference() -> Vector3:
	var local_position = _lander.to_local(terrain.global_position)
	var playing_area_size = get_playing_area_size()
	var local_size = (
		_lander.global_transform.basis.inverse() *
		Vector3(
			playing_area_size.x / 2,
			playing_area_size.y,
			playing_area_size.x / 2,
		)
	)
	return local_position / local_size

func get_velocity_in_player_reference() -> Vector3:
	return (
		_lander.global_transform.basis.inverse() *
		_lander.linear_velocity
		)

func _get_normalized_current_total_thruster_strength() -> float:
	var thruster_strength_total: float = 0.0
	for thruster in thrusters:
		thruster_strength_total += thruster.thruster_strength / up_thruster_max_force
	return thruster_strength_total

func get_angular_velocity_in_player_reference() -> Vector3:
	return _lander.global_transform.basis.inverse() * _lander.angular_velocity

func get_playing_area_size() -> Vector3:
	return Vector3(
		terrain.size.x,
		250.0,
		terrain.size.y
	)

func get_orientation_as_array() -> Array[float]:
	var basis_y: Vector3 = _lander.global_transform.basis.y
	var basis_x: Vector3 = _lander.global_transform.basis.x
	return [
		basis_y.x,
		basis_y.y,
		basis_y.z,
		basis_x.x,
		basis_x.y,
		basis_x.z
	]
	
func get_normalized_linear_velocity() -> float:
	return minf(50.0, _lander.linear_velocity.length()) / 50.0

func get_normalized_angular_velocity() -> float:
	return minf(10.0, _lander.angular_velocity.length()) / 10.0

func _on_lander_body_entered(body):
	_end_episode(episode_ended_unsuccessfully_reward)

func get_lander_global_position():
	return _lander.global_position

func _on_landing_leg_body_exited(body):
	# Possible bug to consider: upon restarting, this reward may be given in the first frame of the next episode
	_legs_in_contact_with_ground -= 1
	ai_controller.reward -= 0.25

func _on_landing_leg_body_entered(body):
	_legs_in_contact_with_ground += 1
	ai_controller.reward += 0.25
