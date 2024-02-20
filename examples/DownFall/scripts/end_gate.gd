extends Node3D

func _on_end_point_body_entered(body:Node3D):
	if body is Player:
		body.level_complete()
