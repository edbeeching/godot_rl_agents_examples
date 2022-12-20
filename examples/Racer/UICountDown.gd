extends Control
class_name UICountDown

@onready var label = $CountDownLabel

func run_countdown(callable):
	visible = true
	await get_tree().create_timer(1.0).timeout
	label.text = "2"
	await get_tree().create_timer(1.0).timeout
	label.text = "1"
	await get_tree().create_timer(1.0).timeout
	label.text = "GO"
	callable.call()
	emit_signal("countdown_finished")
	await get_tree().create_timer(1.0).timeout
	visible = false
	queue_free()
	
