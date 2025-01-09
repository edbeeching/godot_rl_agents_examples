extends Node3D
class_name AITarget

## A reference to the main mesh, used for AABB overlap checks
@export var aabb_mesh: Mesh
@onready var aabb := aabb_mesh.get_aabb()
