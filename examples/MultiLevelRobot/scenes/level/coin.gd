extends Node3D
class_name Coin

var coin_rotation_speed := 1.5

func _physics_process(delta):
	rotate_y(coin_rotation_speed * delta)