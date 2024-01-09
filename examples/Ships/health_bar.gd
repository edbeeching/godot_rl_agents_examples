extends Sprite3D

@onready var health_bar_2d = $SubViewport/HealthBar2D


func _ready():
	update_health(3.0)


func update_health(value):
	health_bar_2d.update_health(value, 3.0)
