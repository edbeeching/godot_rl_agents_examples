extends Control
class_name UI

@export var left_score_robot: Robot
@export var right_score_robot: Robot

@onready var winner = $VBoxContainer/Winner
@onready var get_ready = $VBoxContainer/GetReady


func _ready():
	if left_score_robot:
		left_score_robot.score_label = $LeftScore
	if right_score_robot:
		right_score_robot.score_label = $RightScore
	winner.visible = false


func show_get_ready_text(seconds_remaining: int):
	get_ready.visible = true
	for seconds in range(seconds_remaining, 0, -1):
		get_ready.text = "Get ready! Game starting in: %d" % seconds
		await get_tree().create_timer(1, true, true).timeout
	deactivate_get_ready_text()


func show_winner_text(winner_name: String, seconds_until_deactivated: int = 0):
	winner.text = "The winner is %s!" % winner_name
	winner.visible = true
	await get_tree().create_timer(seconds_until_deactivated, true, true).timeout
	deactivate_winner_text()


func deactivate_get_ready_text():
	get_ready.visible = false


func deactivate_winner_text():
	winner.visible = false
