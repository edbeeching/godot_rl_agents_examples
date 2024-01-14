## TODO: Try not ending episodes, just giving the rewards.

extends Node3D
class_name GameManager

@export var players: Array[Robot]

## Training mode disables UI and game-resetting
@export var training_mode: bool = true
## Applies if the training mode is disabled
@export var infinite_game: bool = true
## Applies if the training mode is disabled
@export var victory_at_score: int = 11
@export var ui: UI

var ball_hit_in_row_count: int
var last_ball_hit_player: Robot

@onready var ball = $Ball

var game_just_reset: bool = false


func get_hit_ball_count(robot: Robot):
	if last_ball_hit_player != robot:
		return 0.0
	return ball_hit_in_row_count / 2.0


func _ready():
	for player in players:
		player.ball = ball
		player.game_manager = self
	activate_game_reset()


func _physics_process(_delta):
	if ball.global_position.y < -2:
		activate_game_reset()

	if game_just_reset and not training_mode:
		reset_ball(players.pick_random())
		process_mode = Node.PROCESS_MODE_DISABLED
		ui.show_get_ready_text(3)
		await get_tree().create_timer(3, true, true).timeout
		game_just_reset = false

		for player in players:
			player = player as Robot
			player.score = 0
			player.global_position = player.initial_position
			player.linear_velocity = Vector3.ZERO

		ball_hit_in_row_count = 0
		process_mode = Node.PROCESS_MODE_ALWAYS


func _on_ball_body_entered(body):
	var player = body as Robot
	if player:
		if not ball.ball_served:
			player.ai_controller.reward += 1.0

		if last_ball_hit_player == player:
			ball_hit_in_row_count += 1
		else:
			ball_hit_in_row_count = 1
			last_ball_hit_player = player

		if ball_hit_in_row_count > 2:
			player.ai_controller.reward -= 1.0
			player.other_player.score += 1
			reset_ball(player.other_player)


func handle_goal_hit(goal: Area3D):
	for player in players:
		if player.goal == goal:
			player.ai_controller.reward -= 1.0
			player.other_player.score += 1
			reset_ball(player.other_player)


func calc_ball_position(player: Robot):
	return player.initial_position + Vector3.UP * 1.1 + Vector3.RIGHT * randf_range(-0.5, 0.5)


func _on_goal_ball_entered(goal):
	handle_goal_hit(goal)


func reset_ball(player: Robot):
	handle_victory(player)
	ball_hit_in_row_count = 0
	ball.ball_served = false
	player.ai_controller.is_serving = true
	player.other_player.ai_controller.is_serving = false

	for robot in players:
		robot.ai_controller.steps_without_ball_hit_while_serving = 0

	ball.reset(calc_ball_position(player))


func handle_victory(potential_winner: Robot):
	if training_mode:
		return

	if check_if_game_winner(potential_winner):
		if potential_winner.ai_controller.control_mode == AIController3D.ControlModes.HUMAN:
			ui.show_winner_text("Player", 3)
		else:
			ui.show_winner_text(potential_winner.name, 3)
		activate_game_reset()


func check_if_game_winner(robot: Robot):
	if infinite_game:
		return

	if robot.score >= victory_at_score:
		return true
	return false


func activate_game_reset():
	game_just_reset = true
