extends AIController3D
class_name RobotAIController

@onready var robot: Robot = get_parent()
@onready var sensors: Array[Node] = $"../Sensors".get_children()
@onready var level_manager = robot.level_manager

var closest_goal_position

func reset():
	super.reset()
	closest_goal_position = xz_distance(robot.global_position,
	robot.current_goal_transform.origin)

func _physics_process(_delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
		done = true
		reward -= 1
		
func get_obs() -> Dictionary:
	var velocity: Vector3 = robot.get_real_velocity().limit_length(20.0) / 20.0
	
	var current_goal_position: Vector3 = robot.current_goal_transform.origin
	var local_goal_position = robot.to_local(current_goal_position).limit_length(40.0) / 40.0
	
	var closest_coin = level_manager.get_closest_active_coin(robot.global_position, robot.current_level)
	var closest_coin_position: Vector3 = Vector3.ZERO
	
	if closest_coin:
		closest_coin_position = robot.to_local(closest_coin.global_position)
		if closest_coin_position.length() > 30.0:
			closest_coin_position = Vector3.ZERO

	var closest_enemy: Enemy = level_manager.get_closest_enemy(robot.global_position)
	var closest_enemy_position: Vector3 = Vector3.ZERO
	var closest_enemy_direction: float = 0.0
	
	if closest_enemy:
		closest_enemy_position = robot.to_local(closest_enemy.global_position)
		closest_enemy_direction = float(closest_enemy.movement_direction)
		if closest_enemy_position.length() > 30.0:
			closest_enemy_position = Vector3.ZERO
			closest_enemy_direction = 0.0
		
		
	var observations: Array[float] = [
		float(n_steps) / reset_after,
		local_goal_position.x,
		local_goal_position.y,
		local_goal_position.z,
		closest_coin_position.x,
		closest_coin_position.y,
		closest_coin_position.z,
		closest_enemy_position.x,
		closest_enemy_position.y,
		closest_enemy_position.z,
		closest_enemy_direction,
		velocity.x,
		velocity.y,
		velocity.z,
		float(robot.level_manager.check_all_coins_collected(robot.current_level))
	]
	observations.append_array(get_raycast_sensor_obs())
	
	return {"obs": observations}
	
func xz_distance(vector1: Vector3, vector2: Vector3):
	var vec1_xz := Vector2(vector1.x, vector1.z)
	var vec2_xz := Vector2(vector2.x, vector2.z)
	return vec1_xz.distance_to(vec2_xz) 

func get_reward() -> float:	
	var current_goal_position = xz_distance(robot.global_position,
	robot.current_goal_transform.origin)
	
	if not closest_goal_position:
		closest_goal_position = current_goal_position
		
	if current_goal_position < closest_goal_position:
		reward += (closest_goal_position - current_goal_position) / 10.0
		closest_goal_position = current_goal_position	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"movement" : {
			"size": 2,
			"action_type": "continuous"
		}
		}
	
func set_action(action) -> void:	
	robot.requested_movement = Vector3(
		clampf(action.movement[0], -1.0, 1.0), 
		0.0, 
		clampf(action.movement[1], -1.0, 1.0)).limit_length(1.0)

func get_raycast_sensor_obs():
	var all_raycast_sensor_obs: Array[float] = []
	for raycast_sensor in sensors:
		all_raycast_sensor_obs.append_array(raycast_sensor.get_observation())
	return all_raycast_sensor_obs
