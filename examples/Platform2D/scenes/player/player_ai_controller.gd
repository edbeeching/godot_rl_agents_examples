extends AIController2D
class_name PlayerAIController

@export var player: Player
@export var raycast_sensors: Array[Node2D]

var is_success := false


func _physics_process(_delta):
	n_steps += 1
	if needs_reset:
		reset()

	if n_steps > reset_after:
		player.end_episode(-0.1)

	# To help training, we reset the episode if there are any remaining coins
	# in the row above the player
	var previous_row_coins := player.map_manager.count_coins_in_grid_row(
		player.map_manager.get_grid_pos(player.global_position).y - 1
	)
	if previous_row_coins > 0:
		player.end_episode(-0.1)


func end_episode(final_reward := 0.0, success := false) -> void:
	is_success = success
	reward += final_reward
	done = true
	reset()



func get_info() -> Dictionary:
	if done:
		return {"is_success": is_success}
	return {}


func get_obs() -> Dictionary:
	var obs: Array[float]

	for sensor in raycast_sensors:
		obs.append_array(sensor.get_observation())

	var player_velocity := player.get_real_velocity()
	player_velocity /= Vector2(player.speed, player.jump_velocity)

	obs.append_array(
		[
			clampf(player_velocity.x, -1.0, 1.0),
			clampf(player_velocity.y, -1.0, 1.0),
			float(player.is_on_floor())
		]
	)

	var goal_pos_global := player.map_manager.goal_position
	var player_to_goal := player.to_local(goal_pos_global)
	var goal_direction := player_to_goal.normalized()
	var goal_dist := clampf(player_to_goal.length() / 640.0, 0, 1.0)

	obs.append_array([goal_direction.x, goal_direction.y, goal_dist])
	return {"obs": obs}


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {
		"move": {"size": 3, "action_type": "discrete"},
		"jump": {"size": 2, "action_type": "discrete"},
	}


func set_action(action) -> void:
	player.requested_movement = (action.move - 1)
	player.requested_jump = (action.jump == 1)
	
	reward -= action.jump * 0.01
