extends Control

var best_lap_time = null
var current_lap_time = null


func _ready():
	EventManager.event_lap_started.connect(lap_started)
	EventManager.event_lap_finished.connect(lap_finished)
	
func _process(delta):
	if current_lap_time != null:
		current_lap_time += delta
		var time = Utils.time_convert_ms(current_lap_time)
		$HBoxContainer/CurrentLabel.text = time

func lap_started(body):
	print("lap started")
	current_lap_time = 0.0


func lap_finished(body):
	print("lap finished")
	if !best_lap_time:
		best_lap_time = current_lap_time
	else:
		if current_lap_time < best_lap_time:
			best_lap_time = current_lap_time
	
	$HBoxContainer/BestLabel.text = Utils.time_convert_ms(best_lap_time)
	current_lap_time = 0.0
	
	
