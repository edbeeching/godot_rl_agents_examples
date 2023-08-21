extends TextureProgressBar

var bar_red = preload("res://assets/bar_red.png")
var bar_green = preload("res://assets/bar_green.png")
var bar_yellow = preload("res://assets/bar_yellow.png")


func _ready():
	show()
	texture_progress = bar_green

func update_health(_value, max_value):
	value = _value
	texture_progress = bar_green
	if value < 0.75 * max_value:
		texture_progress = bar_yellow
	if value < 0.45 * max_value:
		texture_progress = bar_red
