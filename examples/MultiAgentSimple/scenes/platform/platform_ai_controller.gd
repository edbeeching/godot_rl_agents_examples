extends AIController3D
class_name PlatformAIController

@export var game_manager: GameSceneManager
@export var goal: Goal
@export var player_ai_controller: PlayerAIController

@onready var platform: Platform = $Platform
@onready var initial_position = position


func get_obs() -> Dictionary:
	var obs: Array
	var goal_relative = (platform.to_local(goal.global_position) / 20.0).limit_length(1.0)
	var player_relative = (
		(platform.to_local(player_ai_controller.player.global_position) / 10.0).limit_length(1.0)
	)

	var platform_velocity = platform.velocity.limit_length(platform.speed) / platform.speed
	var player_speed = player_ai_controller.player.speed
	var player_velocity = player_ai_controller.player.velocity.limit_length(player_speed) / player_speed
	obs.append_array(
		[
			goal_relative.x,
			goal_relative.y,
			goal_relative.z,
			player_relative.x,
			player_relative.y,
			player_relative.z,
			platform_velocity.x,
			platform_velocity.y,
			platform_velocity.z,
			player_velocity.x,
			player_velocity.y,
			player_velocity.z
		]
	)
	return {"obs": obs}


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {
		"movement": {"size": 1, "action_type": "continuous"},
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if heuristic == "human":
		set_action()


func set_action(action = null) -> void:
	if action == null:
		platform.requested_movement = (
			Input.get_action_strength("platform_right") - Input.get_action_strength("platform_left")
		)
		return

	platform.requested_movement = clamp(action.movement[0], -1.0, 1.0)


func reset():
	super.reset()
	position = position
	platform.position = Vector3.ZERO
	platform.velocity = Vector3.ZERO
