extends Node3D



func set_mesh(name):
	var node = get_node(name)
	if node == null:
		print("mesh not found")
		return
	for child in get_children():
		child.set_visible(false)
		
	node.set_visible(true)
		
	
