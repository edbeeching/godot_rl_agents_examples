extends MeshInstance3D
@onready var area_3d = $Area3D

func _on_area_3d_body_entered(body):
	if body is Player:
		body.chest_collected()
		call_deferred("respawn")
		
func respawn():
	hide()
	area_3d.set_monitoring(false)
	area_3d.set_monitorable(false)	
	await get_tree().create_timer(10.0).timeout
	area_3d.set_monitoring(true)
	area_3d.set_monitorable(true)	
	show()

func get_mesh_aabb() -> AABB:
	var aabb = mesh.get_aabb()
	aabb.position *= scale.x
	aabb.size *= scale.x
	return aabb
