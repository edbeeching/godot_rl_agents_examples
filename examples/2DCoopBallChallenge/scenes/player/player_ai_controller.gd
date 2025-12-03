extends AIController2D
class_name PlayerAIController

@export var players: Players
@export var sensors: Array[Node2D]

var is_success := false


func _ready():
	super._ready()


func _physics_process(_delta):
	n_steps += 1
	if needs_reset:
		reset()
		
	if n_steps > reset_after:
		players.game_manager.episode_timed_out()


func end_episode(final_reward := 0.0, success := false) -> void:
	is_success = success
	reward += final_reward
	done = true
	reset()


func reset():
	old_obs.clear()
	super.reset()


func get_info() -> Dictionary:
	if done:
		return {"is_success": is_success}
	return {}


var old_obs: PackedFloat32Array

func get_obs() -> Dictionary:
	var obs: PackedFloat32Array

	for sensor in sensors:
		obs.append_array(sensor.get_observation())

	for player in players.players:
		(
			obs
			. append_array(
				[
					float(player.is_on_floor()),
					float(player.last_to_hit_ball)
				]
			)
		)
	return {"obs": obs}


func get_reward() -> float:
	reward += players.game_manager.ball.get_approach_goal_reward()
	return reward


func get_action_space() -> Dictionary:
	return {
		"actions_p1": {"size": 2, "action_type": "continuous"},
		"actions_p2": {"size": 2, "action_type": "continuous"},
	}


func set_action(action: Dictionary) -> void:
	players.players[0].requested_movement = action.actions_p1[0]
	players.players[0].requested_jump = action.actions_p1[1] > 0.8

	players.players[1].requested_movement = action.actions_p2[0]
	players.players[1].requested_jump = action.actions_p2[1] > 0.8
