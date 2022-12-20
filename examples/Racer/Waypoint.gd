extends Area3D

var id := -1


func set_id(val):
	id = val
	$Label3D.text = "%s" % str(id)

func _on_waypoint_body_entered(body):
	body = body as VehicleBody3D
	
	if body:
		GameManager.player_crossed_waypoint(body, id)
		

func _on_waypoint_body_exited(body):
	body = body as VehicleBody3D

