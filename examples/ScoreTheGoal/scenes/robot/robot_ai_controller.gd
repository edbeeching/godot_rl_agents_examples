extends AIController3D
class_name RobotAIController

@export var playing_area_x_size: float = 1
@export var playing_area_z_size: float = 1

@onready var _playing_area_half_x_size: float = playing_area_x_size / 2
@onready var _playing_area_half_z_size: float = playing_area_z_size / 2

var ball: Ball
var wall_raycast_sensor: RayCastSensor3D


## In the observations for this example, we include:
## Position of the ball relative to the player,
## position of the each goal relative to the player,
## for each goal, whether the goal is the "correct goal" as 0 or 1,
## whether the ball was already hit in episode (movement is disabled after hitting the ball),
## observations from the wall raycast sensor (it's not allowed to hit a wall)
func get_obs() -> Dictionary:
	_player = _player as Robot

	if not ball:
		ball = _player.get_ball()

	if not wall_raycast_sensor:
		wall_raycast_sensor = $WallRaycastSensor

	var observations: Array[float] = []

	var ball_position = _player.to_local(ball.global_position)
	ball_position.x /= playing_area_x_size
	ball_position.z /= playing_area_z_size

	observations.append_array([ball_position.x, ball_position.z])

	for goal in _player.goals:
		var goal_in_player_reference: Vector3 = _player.to_local(goal.global_position)
		goal_in_player_reference.x /= playing_area_x_size
		goal_in_player_reference.z /= playing_area_z_size

		var target_goal := false
		if goal == ball.correct_goal:
			target_goal = true

		observations.append_array(
			[goal_in_player_reference.x, goal_in_player_reference.z, float(target_goal)]
		)

	observations.append(float(_player.ball_hit))

	observations.append_array(wall_raycast_sensor.get_observation())

	return {"obs": observations}


func get_one_hot_encoded_category(category: int, number_of_categories: int):
	var result: Array[int]
	result.resize(number_of_categories)
	result.fill(0)
	result[category] = 1
	return result


func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		reward -= 1
		needs_reset = true
		done = true


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {
		"accelerate": {"size": 1, "action_type": "continuous"},
		"steer": {"size": 1, "action_type": "continuous"},
	}


func set_action(action) -> void:
	_player.requested_acceleration = action.accelerate[0]
	_player.requested_steering = action.steer[0]
