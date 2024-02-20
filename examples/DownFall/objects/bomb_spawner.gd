extends Node3D

@onready var Bomb = preload("res://objects/bomb.tscn")

func _on_timer_timeout():
	spawn_bomb()

func spawn_bomb():
	var bomb = Bomb.instantiate()
	bomb.position = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	add_child(bomb)
	
