extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body is Player:
		body.chest_collected()
		queue_free()

func get_mesh_aabb() -> AABB:
	var aabb = mesh.get_aabb()
	aabb.position *= 2.0
	aabb.size *= 2.0
	return aabb
