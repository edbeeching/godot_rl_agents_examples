extends Node3D

func _ready():
	var i = 0
	for child in get_children():
		child.set_id(i)
		i += 1
	
	GameManager.n_waypoints = get_child_count()
	GameManager.waypoints = self
