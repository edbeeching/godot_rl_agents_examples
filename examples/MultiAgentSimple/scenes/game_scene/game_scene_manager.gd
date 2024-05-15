extends Node3D
class_name GameSceneManager

@export var AIControllers: Array[Node]

## Used by the player and goal to calculate new positions
@export var player_goal_spawn_positions: Array[Node3D]

var resetables: Array
var steps := 0
var max_steps := 100

## Value set by training manager
var training_manager: TrainingManager


func _ready():
	for node in find_children("*"):
		if node.is_in_group("resetable"):
			resetables.append(node)


func reset_game(reward = 0, done = false):
	for agent in AIControllers:
		agent.reward += reward
		if done:
			agent.done = true
		agent.reset()

	for resetable in resetables:
		resetable.reset()


func set_agents_rewards(reward = 0):
	for agent in AIControllers:
		agent.reward += reward
