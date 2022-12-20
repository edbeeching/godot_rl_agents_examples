extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child = child as MeshInstance3D
		if child:
			child.create_trimesh_collision()
	
