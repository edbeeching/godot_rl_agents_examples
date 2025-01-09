extends Level


var max_height: float = 20.0
# Parameters for the terrain
@export var noise_scale: float = 1.0
@export var noise: Noise
@export var seed_mesh : PlaneMesh
@export var mesh_material: StandardMaterial3D
@export var n_trees = 10

@onready var mesh_instance = $MeshInstance3D
var tree_scene = preload("res://scenes/objects/tree.tscn")

## Keeps references to spawned trees
var _trees: Array

func generate_level():
	prints("mesh", seed_mesh.get_size())
	var surface_tool = SurfaceTool.new()
	var data = MeshDataTool.new()
	var mesh = seed_mesh
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh.surface_get_arrays(0))
	data.create_from_surface(array_mesh, 0)

	# var array_plane = surface_tool.commit()

	for i in range(data.get_vertex_count()):
		
		var vertex = data.get_vertex(i)
		var x = vertex.x
		var z = vertex.z
		
		var y = noise.get_noise_2d(x, z) * noise_scale
		data.set_vertex(i, Vector3(x,y,z))

	array_mesh.clear_surfaces()
	data.commit_to_surface(array_mesh)
	# mesh_instance.mesh = array_mesh

	# array_plane.clear_surfaces()
	# data.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_mesh, 0)    
	surface_tool.generate_tangents()
	surface_tool.generate_normals()

	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
# mesh_instance.mesh._surface_set_material(0, mesh_materialq)

	build_trees()
	_adjust_ground()

func build_trees():
	for i in range(n_trees):
		var tree = tree_scene.instantiate()
		tree.position = get_random_location()
		add_child(tree)
		_trees.append(tree)


## Returns a free position for the character
func get_spawn_location() -> Vector3:
	return get_random_location(noise_scale + character.aabb.size.y / 2.0, 1.0)


func get_target_location() -> Vector3:
	return get_random_location(noise_scale + target.aabb.size.y / 2.0, 1.0)


func get_random_location(y_offset := 1.0, xz_padding := 0.0) -> Vector3:
	return Vector3(
		randf_range(-seed_mesh.size.x/2 + xz_padding, seed_mesh.size.x/2 - xz_padding), 
		y_offset,
		randf_range(-seed_mesh.size.y/2 + xz_padding, seed_mesh.size.y/2 - xz_padding)
	)


func _adjust_ground() -> void:
	get_node("Walls/Left").position = Vector3(-seed_mesh.size.x/2, 0, 0)
	get_node("Walls/Right").position = Vector3(seed_mesh.size.x/2, 0, 0)
	get_node("Walls/Forward").position = Vector3(0, 0, -seed_mesh.size.y/2)
	get_node("Walls/Backward").position = Vector3(0, 0, seed_mesh.size.y/2)


	get_node("Walls/Left").size.x = seed_mesh.size.y
	get_node("Walls/Right").size.x = seed_mesh.size.y
	get_node("Walls/Forward").size.x = seed_mesh.size.x
	get_node("Walls/Backward").size.x = seed_mesh.size.x
