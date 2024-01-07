extends Control
class_name UI

@export var current_lap: Label
@export var get_ready: Label
@export var winner: Label

var total_laps: int

func _ready():
	winner.visible = false

func set_current_lap_text(lap: int):
	if not current_lap.visible:
		current_lap.visible = true

	if total_laps == 0:
		current_lap.text = "Lap: %d/∞" % lap
	else:
		current_lap.text = "Lap: %d/%d" % [lap, total_laps]


func show_get_ready_text(seconds_remaining: int):
	get_ready.visible = true
	for seconds in range(seconds_remaining, 0, -1):
		get_ready.text = "Get ready! Race starting in: %d" % seconds
		await get_tree().create_timer(1, true, true).timeout
	deactivate_get_ready_text()

func deactivate_get_ready_text():
	get_ready.visible = false

func show_winner_text(winner_name: String, seconds_until_deactivated: int = 0):
	winner.text = "The winner is %s!" % winner_name
	winner.visible = true
	await get_tree().create_timer(seconds_until_deactivated, true, true).timeout
	deactivate_winner_text()

func deactivate_winner_text():
	winner.visible = false
