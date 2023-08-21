extends Sprite3D

@onready var health_bar_2d = $SubViewport/HealthBar2D

func _ready():
	#texture = $SubViewport.get_texture()
	update_health(3.0)
	pass

func update_health(value):
	health_bar_2d.update_health(value, 3.0)
