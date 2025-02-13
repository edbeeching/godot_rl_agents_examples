extends RigidBody3D
class_name Player

#region Set by LevelManager
@onready var ball: Ball
@onready var goal: Area3D
#endregion

## Reward given when the robot or ball falls
## (affects training behavior only)
var fall_reward = -2.0

## Node with player animations
@export var animation_player: AnimationPlayer
## Movement speed of the robot
@export var movement_speed := 2.0
## Rotation speed of the robot
@export var rotation_speed := 12.0

@onready var _ai_controller := $AIController3D
@onready var _initial_transform = transform
@onready var level_manager := get_parent() as LevelManager
@onready var visual_robot: Node3D = $robot
@onready var floor_sensor := $FloorSensor

var closest_goal_dist
var closest_ball_dist

#region Set by AIController
var requested_movement: float
var requested_turn: float
#endregion


func _physics_process(_delta):
	# Set to true by the sync node when reset is requested from Python (starting training, evaluation, etc.)
	if _ai_controller.needs_reset:
		reset()
		_ai_controller.reset()

	_process_movement()
	_process_rotation()

	_process_fell_down_check()
	_process_distance_rewards()


## Gives positive rewards when:
## - Ball approaches the goal position
## - Player approaches the ball position


func _process_distance_rewards():
#region Reward for the ball approaching the goal
	var current_dist = get_goal_dist()
	if not closest_goal_dist:
		closest_goal_dist = current_dist

	if current_dist < closest_goal_dist:
		_ai_controller.reward += (closest_goal_dist - current_dist)
		closest_goal_dist = current_dist
#endregion

#region Reward for the robot approaching the ball
	var current_ball_dist = global_position.distance_to(ball.global_position)
	if not closest_ball_dist:
		closest_ball_dist = current_ball_dist

	if current_ball_dist < closest_ball_dist:
		_ai_controller.reward += (closest_ball_dist - current_ball_dist)
		closest_ball_dist = current_ball_dist
#endregion


## Ensures that the player (or ball) did not fall down
## otherwise, restarts the episode with fall_reward
func _process_fell_down_check():
	if ball.global_position.y < 0 or global_position.y < 0:
		game_over(fall_reward)


func _process_rotation():
	if not floor_sensor.is_colliding():
		return
	if requested_turn:
		apply_torque(Vector3.UP * requested_turn * rotation_speed)


func _process_movement():
	if not floor_sensor.is_colliding():
		return
	if requested_movement:
		apply_central_force(global_basis.z * (requested_movement * movement_speed))

		animation_player.play("walking")
	else:
		animation_player.play("idle")


func game_over(reward = 0.0, success := false):
	reset()
	_ai_controller.reset()
	_ai_controller.reward += reward
	_ai_controller.done = true
	_ai_controller.is_success = success


## Returns the ball's distance to the goal
func get_goal_dist():
	return ball.global_position.distance_to(goal.global_position)


func reset():
	level_manager.reset_all_resetables()
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	transform = _initial_transform
	await get_tree().physics_frame
	closest_goal_dist = null
	closest_ball_dist = null


func _on_goal_body_entered(body: Node3D) -> void:
	if body is Ball:
		game_over(10.0, true)
