extends ProgressBar
class_name HealthBar

var stylebox: StyleBoxFlat
@export var full_hp_color = Color.GREEN
@export var empty_hp_color = Color.RED
var current_color: Color = full_hp_color


func _ready() -> void:
	stylebox = StyleBoxFlat.new()
	add_theme_color_override("font_color", Color.BLACK)
	add_theme_stylebox_override("background", stylebox)


func set_health(health := 100.0):
	if not is_node_ready():
		await ready

	value = health
	current_color = full_hp_color.lerp(empty_hp_color, (100 - health) / 100.0)
	stylebox.bg_color = current_color
