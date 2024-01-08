extends Area3D


func _on_body_entered(body):
	body = body as VehicleBody3D
	if body:
		body.bonus_reward()
