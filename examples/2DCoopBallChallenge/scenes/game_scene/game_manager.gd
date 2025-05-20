extends Node2D
class_name GameManager

@export var players: Players
@export var ball: Ball
@export var goal: Goal


func _ready():
	end_episode(0)


## If more steps passed than set in AI Controlled reset_after
func episode_timed_out():
	episode_failed()


func episode_failed():
	end_episode(-10.0)


func episode_success():
	end_episode(10.0, true)


func player_hit_ball(player):
	var index = players.players.find(player)
	assert(index != -1, "Player that hit ball is not in the players array")
	for i in players.players.size():
		if index == i:
			players.players[i].hit_ball()
		else:
			players.players[i].clear_hit_ball()


func on_ball_goal_reached():
	episode_success()


func end_episode(reward, success := false):
	players.end_episode(reward, success)
	ball.reset()
	goal.move_to_next_position()
