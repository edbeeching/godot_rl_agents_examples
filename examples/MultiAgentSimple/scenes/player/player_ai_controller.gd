extends AIController3D
class_name PlayerAIController

@export var game_manager: GameSceneManager
@export var platform_ai_controller: PlatformAIController
@export var goal: Goal

@onready var player: Player = $Player
@onready var raycast_sensor = $Player/RayCastSensor3D
@onready var spawn_positions = game_manager.player_goal_spawn_positions

var previous_distance_to_goal


func _ready():
	super._ready()
	player.game_manager = game_manager


func get_obs() -> Dictionary:
	var obs: Array
	obs.append_array(raycast_sensor.get_observation())
	var platform: Platform = platform_ai_controller.platform
	var platform_relative = (player.to_local(platform.global_position) / 10.0).limit_length(1.0)
	var goal_relative = (player.to_local(goal.global_position) / 20.0).limit_length(1.0)

	var player_velocity = player.velocity.limit_length(player.speed) / player.speed
	var platform_velocity = platform.velocity.limit_length(platform.speed) / platform.speed

	obs.append_array(
		[
			goal_relative.x,
			goal_relative.y,
			goal_relative.z,
			platform_relative.x,
			platform_relative.y,
			platform_relative.z,
			player_velocity.x,
			player_velocity.y,
			player_velocity.z,
			platform_velocity.x,
			platform_velocity.y,
			platform_velocity.z
		]
	)

	return {"obs": obs}


func get_reward() -> float:
	var distance_to_goal = player.global_position.distance_to(goal.global_position)

	if not previous_distance_to_goal:
		previous_distance_to_goal = distance_to_goal

	#if distance_to_goal < previous_distance_to_goal:
	game_manager.set_agents_rewards(previous_distance_to_goal - distance_to_goal)
	previous_distance_to_goal = distance_to_goal

	return reward


func reset():
	super.reset()
	previous_distance_to_goal = null

	global_position = spawn_positions.pick_random().global_position + Vector3.UP * 1.5
	player.position = Vector3.ZERO
	player.velocity = Vector3.ZERO


func get_action_space() -> Dictionary:
	return {
		"movement": {"size": 2, "action_type": "continuous"},
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if heuristic == "human":
		set_action()


func set_action(action = null) -> void:
	if action == null:
		player.requested_movement = Input.get_vector(
			"robot_left", "robot_right", "robot_forward", "robot_back"
		)
		return

	player.requested_movement = Vector2(
		clamp(action.movement[0], -1.0, 1.0), clamp(action.movement[1], -1.0, 1.0)
	)


func _on_goal_body_entered(body: Node3D) -> void:
	if body is Player:
		goal.reset()
		game_manager.set_agents_rewards(5)
		previous_distance_to_goal = null
