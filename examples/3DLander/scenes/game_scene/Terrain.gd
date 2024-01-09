@tool
extends StaticBody3D
class_name Terrain

## Generates the terrain for the environment.

## Training mode disables calculating normals 
## and ambient occlusion texture to speed up generation.
## The maybe_generate_terrain() method will not generate terrain
## every time it is called if this is set to true.
@export var training_mode: bool = true

## Noise used for the terrain generation.
@export var noise: FastNoiseLite
@onready var _meshInstance3D = $MeshInstance3D
@onready var _collisionShape3D = $CollisionShape3D

## The size of the terrain.
@export var size := Vector2(80.0, 80.0)

## How many subdivisions the terrain will have.
## Setting this too high could cause performance issues.
@export var subdivisions := Vector2i(20, 20)
@export var noise_seed := 0

## The height of the terrain is scaled by this multiplier.
@export var height_multiplier := 10.0

## When enabled, the terrain shape will be random every time it is generated.
## If disabled, the terrain shape depends on the noise seed entered.
@export var use_random_seed := true

## Radius of the landing surface which will be mostly flat to make it easier to land.
@export var landing_surface_radius := 10.0

## How far away from the center of the terrain can the randomly selected landing position be.
@export_range(0.0, 0.8) var landing_surface_max_dist_from_center_ratio := 0.5

@export var wall_colliders: Array[CollisionShape3D]

## Click to regenerate the terrain in editor. 
@export var regenerate_terrain := false:
	get:
		return false
	set(_value):
		generate_terrain()
		
@export var LandingSpotMarker: MeshInstance3D
var landing_position := Vector3(0.0, 0.0, 0.0)
		
func _ready():
	generate_terrain()

## Will always generate terrain if not in training mode,
## otherwise it will only sometimes generate terrain
## to slightly increase training fps.
func maybe_generate_terrain():
	if not training_mode:
		generate_terrain()
	else:
		if randi_range(0, 3) == 0:
			generate_terrain()

func generate_terrain():
	#print("generating terrain")
	if use_random_seed:
		noise.seed = randi()
	else:
		noise.seed = noise_seed
		
	# Create a temporary plane mesh
	var plane = PlaneMesh.new()
	plane.size = size
	plane.subdivide_depth = subdivisions.y
	plane.subdivide_width = subdivisions.x
	
	# Modify the height of vertices based on the noise data
	var vertices = plane.get_mesh_arrays()[Mesh.ARRAY_VERTEX]
	
	var range_multiplier = landing_surface_max_dist_from_center_ratio / 2
	
	var landing_center := Vector2(
		randf_range(-size.x * range_multiplier, size.x * range_multiplier), 
		randf_range(-size.y * range_multiplier, size.y * range_multiplier) 
		)
		
	landing_position = to_global(Vector3(landing_center.x, 0.0, landing_center.y))
	
	var edge_radius = landing_surface_radius * 3
					
	for i in range(0, vertices.size()):
		var height = height_multiplier	
		var vertex = vertices[i]
		var dist_from_center = Vector2(vertex.x, vertex.z).distance_to(landing_center)
		
		# Flatten a part of the terrain around the landing position
		if dist_from_center <= landing_surface_radius:
			height = 0
		elif dist_from_center <= edge_radius: 
			height *= (dist_from_center - landing_surface_radius) / (edge_radius - landing_surface_radius)

		vertices[i].y = noise.get_noise_2d(vertex.x, vertex.z) * height
	
	# Create a new mesh and assign the vertices
	var new_mesh = ArrayMesh.new()
	var arrays = plane.get_mesh_arrays()
	arrays[Mesh.ARRAY_VERTEX] = vertices
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	# Use the new mesh as the terrain mesh
	_meshInstance3D.mesh = new_mesh
	
	# Generate the normals for the terrain mesh
	if not training_mode:
		var st = SurfaceTool.new()
		st.create_from(_meshInstance3D.mesh, 0)
		st.generate_normals()
		st.commit(_meshInstance3D.mesh)
	
	# Set the collision shape for the terrain
	_collisionShape3D.shape = _meshInstance3D.mesh.create_trimesh_shape()
	
	# Set the ambient occlusion texture for the terrain
	if not training_mode:
		var texture: NoiseTexture2D = NoiseTexture2D.new()
		texture.noise = noise.duplicate()
		texture.width = size.x
		texture.height = size.y
		texture.noise.offset = Vector3(-size.x / 2.0, -size.y / 2.0, 0)
		texture.normalize = false
		var material: StandardMaterial3D = _meshInstance3D.get_active_material(0)
		material.ao_texture = texture
		material.ao_light_affect = 0.7
	
	# Update the invisible wall collider positions
	for wall_collider in wall_colliders:
		wall_collider.shape.size.x = size.x
		wall_collider.shape.size.y = 800
		wall_collider.shape.size.z = size.y
		
	wall_colliders[0].position = Vector3(
		size.x,
		100,
		0
	)
	wall_colliders[1].position = Vector3(
		-size.x,
		100,
		0
	)
	wall_colliders[2].position = Vector3(
		0,
		100,
		size.y
	)
	wall_colliders[3].position = Vector3(
		0,
		100,
		-size.y
	)
	wall_colliders[4].position = Vector3(
		0,
		800,
		0
	)
	
	LandingSpotMarker.global_position = landing_position + Vector3.DOWN * 0.05
	var LandingSpotMarkerMesh = LandingSpotMarker.mesh as SphereMesh
	LandingSpotMarkerMesh.radius = landing_surface_radius
	LandingSpotMarkerMesh.height = landing_surface_radius
