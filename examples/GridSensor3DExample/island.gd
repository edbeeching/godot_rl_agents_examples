extends Node3D


func get_mesh_aabb() -> AABB:
	return $Island.mesh.get_aabb()
