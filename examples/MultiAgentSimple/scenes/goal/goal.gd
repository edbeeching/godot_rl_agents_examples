extends Area3D
class_name Goal

@onready var initial_position = global_position
@export var game_manager: GameSceneManager
@export var player_ai_controller: PlayerAIController

## Nodes that this goal will spawn on (it will reset to the platform that has the largest distance from the player)
@onready var spawn_positions := game_manager.player_goal_spawn_positions


func reset():
	await get_tree().physics_frame  # Wait a physics frame before moving to avoid detecting player on reset
	var farthest_distance: float = 0.0
	var farthest_node: Node3D
	for node in spawn_positions:
		var distance = node.global_position.distance_squared_to(
			player_ai_controller.player.global_position
		)
		if distance > farthest_distance:
			farthest_distance = distance
			farthest_node = node
	global_position = farthest_node.global_position + Vector3.UP * 1.5
