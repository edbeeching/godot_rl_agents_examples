extends AIController3D
class_name PlayerAIController

@export var player: Player
@export var raycast_sensors: Array[RayCastSensor3D]


func _physics_process(delta):
	n_steps += 1

	if n_steps > reset_after:
		player.game_scene_manager.reset()


func end_episode():
	done = true
	reset()


func get_obs() -> Dictionary:
	var obs: PackedFloat32Array = []
	for sensor in raycast_sensors:
		obs.append_array(sensor.get_observation())

	var level_size: float = 10
	var relative_goal_position: Vector3 = player.to_local(player.goal.global_position)
	var relative_obstacle_position: Vector3 = player.to_local(player.obstacle.global_position)
	obs.append_array(
		[
			relative_goal_position.x / level_size,
			relative_goal_position.z / level_size,
			relative_obstacle_position.x / level_size,
			relative_obstacle_position.z / level_size
		]
	)
	return {"obs": obs}


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {"move_action": {"size": 2, "action_type": "continuous"}}


func set_action(action) -> void:
	player.requested_movement = Vector2(action.move_action[0], action.move_action[1])
