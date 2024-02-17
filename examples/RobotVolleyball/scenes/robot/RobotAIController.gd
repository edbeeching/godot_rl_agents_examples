extends AIController3D
class_name RobotAIController

@onready var robot: Robot = get_parent()
@onready var sensors: Array[Node] = $"../Sensors".get_children()

var steps_without_ball_hit_while_serving: int
var is_serving: bool


func reset():
	super.reset()


func _physics_process(_delta):
	n_steps += 1

	if is_serving:
		steps_without_ball_hit_while_serving += 1

	if steps_without_ball_hit_while_serving > 400:
		reward -= 1
		robot.other_player.score += 1
		robot.game_manager.reset_ball(robot.other_player)


func get_obs() -> Dictionary:
	var ball_position = robot.to_local(robot.ball.global_position) / 8.0
	var ball_goal_position = robot.goal.to_local(robot.ball.global_position) / 5.0
	var robot_velocity = (
		(robot.global_transform.basis.inverse() * robot.linear_velocity.limit_length(10.0)) / 10.0
	)
	var ball_velocity = (
		(robot.global_transform.basis.inverse() * robot.ball.linear_velocity.limit_length(8.0))
		/ 8.0
	)

	var observations: Array[float] = [
		ball_position.y,
		ball_position.z,
		ball_goal_position.x,
		ball_goal_position.z,
		robot_velocity.y,
		robot_velocity.z,
		ball_velocity.y,
		ball_velocity.z,
		float(robot.jump_sensor.is_colliding()),
		float(float(is_serving)),
		float(robot.ball.ball_served),
		robot.game_manager.get_hit_ball_count(robot),
		steps_without_ball_hit_while_serving / 400.0
	]

	observations.append_array(get_raycast_sensor_obs())

	return {"obs": observations}


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {
		"jump": {"size": 1, "action_type": "continuous"},
		"movement": {"size": 1, "action_type": "continuous"}
	}


func set_action(action) -> void:
	robot.requested_movement = clamp(action.movement[0], -1.0, 1.0)
	robot.jump_requested = action.jump[0] > 0


func get_raycast_sensor_obs():
	var all_raycast_sensor_obs: Array[float] = []
	for raycast_sensor in sensors:
		all_raycast_sensor_obs.append_array(raycast_sensor.get_observation())
	return all_raycast_sensor_obs
