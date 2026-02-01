extends Node2D
class_name Players

@export var game_manager: GameManager
@export var players: Array[Player]
@export var ai_controller: PlayerAIController


func get_random_player():
	return players.pick_random()


func end_episode(reward, success := false):
	ai_controller.end_episode(reward, success)
	for player in players:
		player.reset()


func add_player_reward(reward: float):
	ai_controller.reward += reward
