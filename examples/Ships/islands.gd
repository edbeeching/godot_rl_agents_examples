extends Node3D

var island_mesh : MeshInstance3D

func init():
	var n_meshes = get_child_count() - 2
	var mesh_id = randi_range(0, n_meshes-1)
	
	for child in get_children():
		if child is MeshInstance3D:
			child.hide()
			
	island_mesh = get_child(mesh_id) as MeshInstance3D
	island_mesh.show()
	
	var col_shape = island_mesh.mesh.create_convex_shape()
	$Area3D/CollisionShape3D.shape = col_shape
	$StaticBody3D/CollisionShape3D.shape = col_shape
	
func get_mesh_aabb() -> AABB:
	if island_mesh == null:
		init()
	return island_mesh.mesh.get_aabb()
