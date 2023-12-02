extends Node3D


func set_mesh(mesh_name):
	var node = get_node(mesh_name)
	if node == null:
		print("mesh not found")
		return
	for child in get_children():
		child.set_visible(false)

	node.set_visible(true)
